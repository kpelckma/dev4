------------------------------------------------------------------------------
--          ____  _____________  __                                         --
--         / __ \/ ____/ ___/\ \/ /                 _   _   _               --
--        / / / / __/  \__ \  \  /                 / \ / \ / \              --
--       / /_/ / /___ ___/ /  / /               = ( M | S | K )=            --
--      /_____/_____//____/  /_/                   \_/ \_/ \_/              --
--                                                                          --
------------------------------------------------------------------------------
--! @copyright Copyright 2021 DESY
--! SPDX-License-Identifier: CERN-OHL-W-2.0
------------------------------------------------------------------------------
--! @date 2018-10-25
--! @author Dariusz Makowski
--! @author Grzegorz Jablonski
--! @author Konrad Przygoda
--! @author Lukasz Butkowski <lukasz.butkowski@desy.de>
--! @author Cagil Gumus <cagil.guemues@desy.de>
------------------------------------------------------------------------------
--! @brief
--! Handles the programming of the onboard flash as well as changing
--! FPGA configuration + error correction capabilities
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library desyrdl;
use desyrdl.pkg_fpga_config_manager.all;

entity fpga_config_manager_top is
  generic (
    g_arch           : string := "";    --! Allowed values: VIRTEX5,VIRTEX5,SPARTAN6,7SERIES,ULTRASCALE
    g_icap_clk_div   : natural := 2;    --! Clock divider for ICAP component
    g_ecc_enable     : natural := 0;    --! Enable Error Correction
    g_mem_addr_width : natural := 23
  );
  port(
    pi_clock          : in  std_logic;  --! Clock input
    pi_reset          : in  std_logic;  --! Reset port

    pi_s_top          : in  t_fpga_config_manager_m2s;
    po_s_top          : out t_fpga_config_manager_s2m;

    pi_jtag_tdo       : in  std_logic;  --! JTAG Connections
    po_jtag_tdi       : out std_logic;
    po_jtag_tms       : out std_logic;
    po_jtag_tck       : out std_logic;

    pi_spi_sdi        : in  std_logic;  --! SPI Connections
    po_spi_sdo        : out std_logic;
    po_spi_cs_n       : out std_logic;
    po_spi_clk        : out std_logic;

    pi_ext_spi_enable : in  std_logic;  --! SPI Forwarding (eg SPI control from MicroBlaze)
    pi_ext_spi_sdo    : in  std_logic;
    pi_ext_spi_cs_n   : in  std_logic;
    po_ext_spi_sdi    : out std_logic;
    pi_ext_spi_clk    : in  std_logic
  );
end fpga_config_manager_top;

architecture arch of fpga_config_manager_top is

  signal addrmap_i : t_addrmap_fpga_config_manager_in;
  signal addrmap_o : t_addrmap_fpga_config_manager_out;

  --! JTAG Signals
  signal jtag_tck : std_logic_vector(0 downto 0);
  signal jtag_tms : std_logic_vector(0 downto 0);
  signal jtag_tdi : std_logic_vector(0 downto 0);
  signal jtag_tdo : std_logic_vector(0 downto 0);

  --! Programmer Signals
  signal prog_bytes_write      : std_logic_vector(15 downto 0);
  signal prog_bytes_read       : std_logic_vector(15 downto 0);
  signal prog_spi_clk_div      : std_logic_vector(15 downto 0);
  signal prog_ctrl_data_rdy    : std_logic;
  signal prog_ctrl_data_out    : std_logic_vector(7 downto 0);
  signal prog_ctrl_data_we     : std_logic;
  signal prog_spi_sdi          : std_logic;
  signal prog_spi_sdo          : std_logic;
  signal prog_spi_cs_n         : std_logic;
  signal prog_spi_clk          : std_logic;
  signal prog_dpm_wr_out       : std_logic_vector(7 downto 0);
  signal prog_dpm_rd_out       : std_logic_vector(7 downto 0);

  --! ICAP Signals
  signal icap_switch : std_logic_vector(31 downto 0);
  signal icap_sel    : std_logic_vector(1 downto 0);

  --! ECC Signals
  signal crc_error        : std_logic_vector(0 downto 0);
  signal ecc_error        : std_logic_vector(0 downto 0);
  signal ecc_error_single : std_logic_vector(0 downto 0);
  signal far_register     : std_logic_vector(25 downto 0);
  signal syn_bit          : std_logic_vector(4 downto 0);
  signal syndrome_value   : std_logic_vector(12 downto 0);
  signal syndrome_vld     : std_logic;
  signal syn_word         : std_logic_vector(6 downto 0);
  signal crc_error_cnt    : std_logic_vector (31 downto 0):= x"00000000";
  signal ecc_error_cnt    : std_logic_vector (31 downto 0):= x"00000000";

begin

  --==============================================================================
  -- IO Connections
  --==============================================================================
  po_jtag_tck  <= jtag_tck(0); --! Coming from IBUS
  po_jtag_tms  <= jtag_tms(0);
  po_jtag_tdi  <= jtag_tdi(0);
  jtag_tdo(0)  <= pi_jtag_tdo;

  ins_top_reg : entity desyrdl.fpga_config_manager
  port map (
    pi_clock => pi_clock,
    pi_reset => pi_reset,

    pi_s_top => pi_s_top,
    po_s_top => po_s_top,

    pi_addrmap => addrmap_i,
    po_addrmap => addrmap_o
  );

  -- registers
  addrmap_i.MAGIC.data.data <= X"0ABCDE" & x"04";
  addrmap_i.CONTROL.data.we <= prog_ctrl_data_we;
  addrmap_i.CONTROL.data.data <= prog_ctrl_data_out;
  addrmap_i.CRC_ERROR.data.data <= crc_error;
  addrmap_i.CRC_ERROR_CNT.data.data <= crc_error_cnt;
  addrmap_i.ECC_ERROR_CNT.data.data <= ecc_error_cnt;
  addrmap_i.ECC_SYNDROME.data.data <= syndrome_value;

  icap_switch <= addrmap_o.REV_SWITCH.data.data;
  icap_sel    <= addrmap_o.REV_SEL.data.data;


  addrmap_i.JTAG_TDO.data.data <= jtag_tdo;
  jtag_tck <= addrmap_o.JTAG_TCK.data.data when rising_edge(pi_clock);
  jtag_tms <= addrmap_o.JTAG_TMS.data.data when rising_edge(pi_clock);
  jtag_tdi <= addrmap_o.JTAG_TDI.data.data when rising_edge(pi_clock);

  prog_bytes_write   <= addrmap_o.BYTES_TO_WRITE.data.data ;
  prog_bytes_read    <= addrmap_o.BYTES_TO_READ.data.data ;
  prog_spi_clk_div   <= addrmap_o.SPI_DIVIDER.data.data;
  prog_ctrl_data_rdy <= addrmap_o.CONTROL.data.swmod;

  -- memories
  addrmap_i.WRITE_BUF.data(7 downto 0) <= prog_dpm_wr_out;
  addrmap_i.READ_BUF.data(7 downto 0) <= prog_dpm_rd_out;

  --==============================================================================
  -- IO Control (STARTUP Primitives Wrapper)
  -- Handles the SPI IO connections
  --==============================================================================
  ins_spi_io : entity work.fpga_spi_io_phy
  generic map(
    g_arch          => g_arch
  )
  port map(
    pi_clock        => pi_clock,

    po_prog_spi_sdi     => prog_spi_sdi,    --! SPI Connections to/from programmer
    pi_prog_spi_sdo     => prog_spi_sdo,
    pi_prog_spi_cs_n    => prog_spi_cs_n,
    pi_prog_spi_clk     => prog_spi_clk,

    pi_spi_sdi          => pi_spi_sdi,      --! SPI Connections to/from outside
    po_spi_sdo          => po_spi_sdo,
    po_spi_cs_n         => po_spi_cs_n,
    po_spi_clk          => po_spi_clk,

    pi_ext_spi_en      => pi_ext_spi_enable,
    pi_ext_spi_sdo     => pi_ext_spi_sdo,
    pi_ext_spi_cs_n    => pi_ext_spi_cs_n,
    po_ext_spi_sdi     => po_ext_spi_sdi,
    pi_ext_spi_clk     => pi_ext_spi_clk
  );

  --==============================================================================
  -- SPI Controller/Programmer for writing and reading from the board flash memory
  --==============================================================================
  ins_programmer: entity work.fpga_spi_programmer
  port map(
    pi_clock               => pi_clock,
    pi_reset               => pi_reset,

    pi_spi_sdi             => prog_spi_sdi,
    po_spi_sdo             => prog_spi_sdo,
    po_spi_cs_n            => prog_spi_cs_n,
    po_spi_clk             => prog_spi_clk,

    pi_control_data_in     => addrmap_o.CONTROL.data.data,
    pi_control_rdy         => prog_ctrl_data_rdy,
    po_control_data_out    => prog_ctrl_data_out,
    po_control_data_we     => prog_ctrl_data_we,

    pi_dpm_wr_en           => addrmap_o.WRITE_BUF.en,
    pi_dpm_wr_we           => addrmap_o.WRITE_BUF.we,
    pi_dpm_wr_data         => addrmap_o.WRITE_BUF.data(7 downto 0),
    pi_dpm_wr_addr         => addrmap_o.WRITE_BUF.addr(9 downto 0),
    po_dpm_wr_out          => prog_dpm_wr_out,

    pi_dpm_rd_en           => addrmap_o.READ_BUF.en,
    pi_dpm_rd_addr         => addrmap_o.READ_BUF.addr(9 downto 0),
    po_dpm_rd_out          => prog_dpm_rd_out,

    pi_bytes_write         => prog_bytes_write,
    pi_bytes_read          => prog_bytes_read,

    pi_spi_clk_div         => prog_spi_clk_div
  );

  --==============================================================================
  -- ICAP Component
  --==============================================================================
  ins_icap : entity work.icap_handler
  generic map(
    g_arch           => g_arch,
    g_icap_clk_div   => g_icap_clk_div,
    g_mem_addr_width => g_mem_addr_width
  )
  port map(
    pi_clock    => pi_clock,
    pi_switch   => icap_switch,
    pi_prog_sel => icap_sel
  );

  --==============================================================================
  -- Error Correction (ECC)
  --==============================================================================
  gen_ecc : if g_ecc_enable = 1 generate
    signal ls_syndrome_value : std_logic_vector(12 downto 0);
  begin

    ins_frame_ecc: entity work.frame_ecc_wrapper
    generic map (
      g_arch => g_arch
    )
    port map (
      pi_clock                 => pi_clock,
      pi_reset                 => pi_reset,
      po_crc_error             => crc_error(0),
      po_ecc_error             => ecc_error(0),
      po_ecc_error_single      => ecc_error_single(0),
      po_far_register          => far_register,
      po_syn_bit               => syn_bit,
      po_syndrome_value        => ls_syndrome_value,
      po_syndrome_vld          => syndrome_vld,
      po_syn_word              => syn_word,
      po_crc_error_cnt         => crc_error_cnt,
      po_ecc_error_cnt         => ecc_error_cnt
    );
    -- save only syndrome with error information
    prs_syndrom_reg: process (pi_clock) is
    begin
      if rising_edge(pi_clock) then
        if syndrome_vld = '1' and ecc_error(0) = '1' then
          syndrome_value <= ls_syndrome_value;
        end if;
      end if;
    end process prs_syndrom_reg;

  end generate;
end architecture arch;
