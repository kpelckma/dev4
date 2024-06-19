------------------------------------------------------------------------------
--          ____  _____________  __                                         --
--         / __ \/ ____/ ___/\ \/ /                 _   _   _               --
--        / / / / __/  \__ \  \  /                 / \ / \ / \              --
--       / /_/ / /___ ___/ /  / /               = ( M | S | K )=            --
--      /_____/_____//____/  /_/                   \_/ \_/ \_/              --
--                                                                          --
------------------------------------------------------------------------------
--! @copyright Copyright 2021-2022 DESY
--! SPDX-License-Identifier: Apache-2.0
------------------------------------------------------------------------------
--! @date 2021-04-07
--! @author Michael Büchler <michael.buechler@desy.de>
--! @author Lukasz Butkowski <lukasz.butkowski@desy.de>
------------------------------------------------------------------------------
--! @brief
--! Top component of DesyRDL address space decoder for {node.type_name}
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library desyrdl;
use desyrdl.common.all;

use work.pkg_fpga_config_manager.all;

entity fpga_config_manager is
  port (
    pi_clock : in std_logic;
    pi_reset : in std_logic;
    -- TOP subordinate memory mapped interface
    pi_s_reset : in std_logic := '0';
    pi_s_top   : in  t_fpga_config_manager_m2s;
    po_s_top   : out t_fpga_config_manager_s2m;
    -- to logic interface
    pi_addrmap : in  t_addrmap_fpga_config_manager_in;
    po_addrmap : out t_addrmap_fpga_config_manager_out
  );
end entity fpga_config_manager;

architecture arch of fpga_config_manager is

  type t_data_out is array (natural range<>) of std_logic_vector(C_DATA_WIDTH-1 downto 0) ;

  --
  signal reg_data_out_vect : t_data_out(17-1 downto 0);
  signal reg_rd_stb   : std_logic_vector(17-1 downto 0);
  signal reg_wr_stb   : std_logic_vector(17-1 downto 0);
  signal reg_data_out : std_logic_vector(C_DATA_WIDTH-1 downto 0);
  signal reg_data_in  : std_logic_vector(C_DATA_WIDTH-1 downto 0);
  --
  signal mem_data_out_vect : t_data_out(2-1 downto 0);
  signal mem_stb      : std_logic_vector(2-1 downto 0);
  signal mem_we       : std_logic;
  signal mem_addr     : std_logic_vector(C_ADDR_WIDTH-1 downto 0);
  signal mem_data_out : std_logic_vector(C_DATA_WIDTH-1 downto 0);
  signal mem_data_in  : std_logic_vector(C_DATA_WIDTH-1 downto 0);
  signal mem_ack      : std_logic;
  --

begin

  ins_decoder_axi4l : entity work.fpga_config_manager_decoder_axi4l
  generic map (
    g_addr_width    => C_ADDR_WIDTH,
    g_data_width    => C_DATA_WIDTH
  )
  port map (
    pi_clock      => pi_clock,
    pi_reset      => pi_reset,

    --
    po_reg_rd_stb => reg_rd_stb,
    po_reg_wr_stb => reg_wr_stb,
    po_reg_data   => reg_data_in,
    pi_reg_data   => reg_data_out,
    --
    --
    --
    po_mem_stb    => mem_stb,
    po_mem_we     => mem_we,
    po_mem_addr   => mem_addr,
    po_mem_data   => mem_data_in,
    pi_mem_data   => mem_data_out,
    pi_mem_ack    => mem_ack,
    --
    --
    pi_s_reset  => pi_s_reset,
    pi_s_top    => pi_s_top,
    po_s_top    => po_s_top
  );
  --
  prs_reg_rd_mux: process(pi_clock)
  begin
    if rising_edge(pi_clock) then
      for idx in 0 to 17-1 loop
        if reg_rd_stb(idx) = '1' then
          reg_data_out <= reg_data_out_vect(idx);
        end if;
      end loop;
    end if;
  end process prs_reg_rd_mux;
  --
  --
  --
  prs_mem_rd_mux: process(pi_clock)
  begin
    if rising_edge(pi_clock) then
      for idx in 0 to 2-1 loop
        if mem_stb(idx) = '1' then
          mem_data_out <= mem_data_out_vect(idx);
        end if;
      end loop;
    end if;
  end process prs_mem_rd_mux;
  --

  -- ===========================================================================
  -- generated registers instances
  -- ---------------------------------------------------------------------------
  -- reg name: SPI_DIVIDER  reg type: SPI_DIVIDER
  -- ---------------------------------------------------------------------------
  blk_SPI_DIVIDER : block
  begin  --
    inst_SPI_DIVIDER: entity work.fpga_config_manager_SPI_DIVIDER
      port map(
        pi_clock        => pi_clock,
        pi_reset        => pi_reset,
        -- to/from adapter
        pi_decoder_rd_stb => reg_rd_stb(0),
        pi_decoder_wr_stb => reg_wr_stb(0),
        pi_decoder_data   => reg_data_in,
        po_decoder_data   => reg_data_out_vect(0),

        pi_reg  => pi_addrmap.SPI_DIVIDER,
        po_reg  => po_addrmap.SPI_DIVIDER
      );--
  end block;--
  -- ---------------------------------------------------------------------------
  -- reg name: BYTES_TO_WRITE  reg type: BYTES_TO_WRITE
  -- ---------------------------------------------------------------------------
  blk_BYTES_TO_WRITE : block
  begin  --
    inst_BYTES_TO_WRITE: entity work.fpga_config_manager_BYTES_TO_WRITE
      port map(
        pi_clock        => pi_clock,
        pi_reset        => pi_reset,
        -- to/from adapter
        pi_decoder_rd_stb => reg_rd_stb(1),
        pi_decoder_wr_stb => reg_wr_stb(1),
        pi_decoder_data   => reg_data_in,
        po_decoder_data   => reg_data_out_vect(1),

        pi_reg  => pi_addrmap.BYTES_TO_WRITE,
        po_reg  => po_addrmap.BYTES_TO_WRITE
      );--
  end block;--
  -- ---------------------------------------------------------------------------
  -- reg name: BYTES_TO_READ  reg type: BYTES_TO_READ
  -- ---------------------------------------------------------------------------
  blk_BYTES_TO_READ : block
  begin  --
    inst_BYTES_TO_READ: entity work.fpga_config_manager_BYTES_TO_READ
      port map(
        pi_clock        => pi_clock,
        pi_reset        => pi_reset,
        -- to/from adapter
        pi_decoder_rd_stb => reg_rd_stb(2),
        pi_decoder_wr_stb => reg_wr_stb(2),
        pi_decoder_data   => reg_data_in,
        po_decoder_data   => reg_data_out_vect(2),

        pi_reg  => pi_addrmap.BYTES_TO_READ,
        po_reg  => po_addrmap.BYTES_TO_READ
      );--
  end block;--
  -- ---------------------------------------------------------------------------
  -- reg name: CONTROL  reg type: CONTROL
  -- ---------------------------------------------------------------------------
  blk_CONTROL : block
  begin  --
    inst_CONTROL: entity work.fpga_config_manager_CONTROL
      port map(
        pi_clock        => pi_clock,
        pi_reset        => pi_reset,
        -- to/from adapter
        pi_decoder_rd_stb => reg_rd_stb(3),
        pi_decoder_wr_stb => reg_wr_stb(3),
        pi_decoder_data   => reg_data_in,
        po_decoder_data   => reg_data_out_vect(3),

        pi_reg  => pi_addrmap.CONTROL,
        po_reg  => po_addrmap.CONTROL
      );--
  end block;--
  -- ---------------------------------------------------------------------------
  -- reg name: JTAG_TCK  reg type: JTAG_TCK
  -- ---------------------------------------------------------------------------
  blk_JTAG_TCK : block
  begin  --
    inst_JTAG_TCK: entity work.fpga_config_manager_JTAG_TCK
      port map(
        pi_clock        => pi_clock,
        pi_reset        => pi_reset,
        -- to/from adapter
        pi_decoder_rd_stb => reg_rd_stb(4),
        pi_decoder_wr_stb => reg_wr_stb(4),
        pi_decoder_data   => reg_data_in,
        po_decoder_data   => reg_data_out_vect(4),

        pi_reg  => pi_addrmap.JTAG_TCK,
        po_reg  => po_addrmap.JTAG_TCK
      );--
  end block;--
  -- ---------------------------------------------------------------------------
  -- reg name: JTAG_TMS  reg type: JTAG_TMS
  -- ---------------------------------------------------------------------------
  blk_JTAG_TMS : block
  begin  --
    inst_JTAG_TMS: entity work.fpga_config_manager_JTAG_TMS
      port map(
        pi_clock        => pi_clock,
        pi_reset        => pi_reset,
        -- to/from adapter
        pi_decoder_rd_stb => reg_rd_stb(5),
        pi_decoder_wr_stb => reg_wr_stb(5),
        pi_decoder_data   => reg_data_in,
        po_decoder_data   => reg_data_out_vect(5),

        pi_reg  => pi_addrmap.JTAG_TMS,
        po_reg  => po_addrmap.JTAG_TMS
      );--
  end block;--
  -- ---------------------------------------------------------------------------
  -- reg name: JTAG_TDI  reg type: JTAG_TDI
  -- ---------------------------------------------------------------------------
  blk_JTAG_TDI : block
  begin  --
    inst_JTAG_TDI: entity work.fpga_config_manager_JTAG_TDI
      port map(
        pi_clock        => pi_clock,
        pi_reset        => pi_reset,
        -- to/from adapter
        pi_decoder_rd_stb => reg_rd_stb(6),
        pi_decoder_wr_stb => reg_wr_stb(6),
        pi_decoder_data   => reg_data_in,
        po_decoder_data   => reg_data_out_vect(6),

        pi_reg  => pi_addrmap.JTAG_TDI,
        po_reg  => po_addrmap.JTAG_TDI
      );--
  end block;--
  -- ---------------------------------------------------------------------------
  -- reg name: JTAG_TDO  reg type: JTAG_TDO
  -- ---------------------------------------------------------------------------
  blk_JTAG_TDO : block
  begin  --
    inst_JTAG_TDO: entity work.fpga_config_manager_JTAG_TDO
      port map(
        pi_clock        => pi_clock,
        pi_reset        => pi_reset,
        -- to/from adapter
        pi_decoder_rd_stb => reg_rd_stb(7),
        pi_decoder_wr_stb => reg_wr_stb(7),
        pi_decoder_data   => reg_data_in,
        po_decoder_data   => reg_data_out_vect(7),

        pi_reg  => pi_addrmap.JTAG_TDO,
        po_reg  => po_addrmap.JTAG_TDO
      );--
  end block;--
  -- ---------------------------------------------------------------------------
  -- reg name: MAGIC  reg type: MAGIC
  -- ---------------------------------------------------------------------------
  blk_MAGIC : block
  begin  --
    inst_MAGIC: entity work.fpga_config_manager_MAGIC
      port map(
        pi_clock        => pi_clock,
        pi_reset        => pi_reset,
        -- to/from adapter
        pi_decoder_rd_stb => reg_rd_stb(8),
        pi_decoder_wr_stb => reg_wr_stb(8),
        pi_decoder_data   => reg_data_in,
        po_decoder_data   => reg_data_out_vect(8),

        pi_reg  => pi_addrmap.MAGIC,
        po_reg  => po_addrmap.MAGIC
      );--
  end block;--
  -- ---------------------------------------------------------------------------
  -- reg name: REV_SWITCH  reg type: REV_SWITCH
  -- ---------------------------------------------------------------------------
  blk_REV_SWITCH : block
  begin  --
    inst_REV_SWITCH: entity work.fpga_config_manager_REV_SWITCH
      port map(
        pi_clock        => pi_clock,
        pi_reset        => pi_reset,
        -- to/from adapter
        pi_decoder_rd_stb => reg_rd_stb(9),
        pi_decoder_wr_stb => reg_wr_stb(9),
        pi_decoder_data   => reg_data_in,
        po_decoder_data   => reg_data_out_vect(9),

        pi_reg  => pi_addrmap.REV_SWITCH,
        po_reg  => po_addrmap.REV_SWITCH
      );--
  end block;--
  -- ---------------------------------------------------------------------------
  -- reg name: REV_SEL  reg type: REV_SEL
  -- ---------------------------------------------------------------------------
  blk_REV_SEL : block
  begin  --
    inst_REV_SEL: entity work.fpga_config_manager_REV_SEL
      port map(
        pi_clock        => pi_clock,
        pi_reset        => pi_reset,
        -- to/from adapter
        pi_decoder_rd_stb => reg_rd_stb(10),
        pi_decoder_wr_stb => reg_wr_stb(10),
        pi_decoder_data   => reg_data_in,
        po_decoder_data   => reg_data_out_vect(10),

        pi_reg  => pi_addrmap.REV_SEL,
        po_reg  => po_addrmap.REV_SEL
      );--
  end block;--
  -- ---------------------------------------------------------------------------
  -- reg name: CRC_ERROR  reg type: CRC_ERROR
  -- ---------------------------------------------------------------------------
  blk_CRC_ERROR : block
  begin  --
    inst_CRC_ERROR: entity work.fpga_config_manager_CRC_ERROR
      port map(
        pi_clock        => pi_clock,
        pi_reset        => pi_reset,
        -- to/from adapter
        pi_decoder_rd_stb => reg_rd_stb(11),
        pi_decoder_wr_stb => reg_wr_stb(11),
        pi_decoder_data   => reg_data_in,
        po_decoder_data   => reg_data_out_vect(11),

        pi_reg  => pi_addrmap.CRC_ERROR,
        po_reg  => po_addrmap.CRC_ERROR
      );--
  end block;--
  -- ---------------------------------------------------------------------------
  -- reg name: CRC_ERROR_CNT  reg type: CRC_ERROR_CNT
  -- ---------------------------------------------------------------------------
  blk_CRC_ERROR_CNT : block
  begin  --
    inst_CRC_ERROR_CNT: entity work.fpga_config_manager_CRC_ERROR_CNT
      port map(
        pi_clock        => pi_clock,
        pi_reset        => pi_reset,
        -- to/from adapter
        pi_decoder_rd_stb => reg_rd_stb(12),
        pi_decoder_wr_stb => reg_wr_stb(12),
        pi_decoder_data   => reg_data_in,
        po_decoder_data   => reg_data_out_vect(12),

        pi_reg  => pi_addrmap.CRC_ERROR_CNT,
        po_reg  => po_addrmap.CRC_ERROR_CNT
      );--
  end block;--
  -- ---------------------------------------------------------------------------
  -- reg name: ECC_ERROR_CNT  reg type: ECC_ERROR_CNT
  -- ---------------------------------------------------------------------------
  blk_ECC_ERROR_CNT : block
  begin  --
    inst_ECC_ERROR_CNT: entity work.fpga_config_manager_ECC_ERROR_CNT
      port map(
        pi_clock        => pi_clock,
        pi_reset        => pi_reset,
        -- to/from adapter
        pi_decoder_rd_stb => reg_rd_stb(13),
        pi_decoder_wr_stb => reg_wr_stb(13),
        pi_decoder_data   => reg_data_in,
        po_decoder_data   => reg_data_out_vect(13),

        pi_reg  => pi_addrmap.ECC_ERROR_CNT,
        po_reg  => po_addrmap.ECC_ERROR_CNT
      );--
  end block;--
  -- ---------------------------------------------------------------------------
  -- reg name: ECC_SYNDROME  reg type: ECC_SYNDROME
  -- ---------------------------------------------------------------------------
  blk_ECC_SYNDROME : block
  begin  --
    inst_ECC_SYNDROME: entity work.fpga_config_manager_ECC_SYNDROME
      port map(
        pi_clock        => pi_clock,
        pi_reset        => pi_reset,
        -- to/from adapter
        pi_decoder_rd_stb => reg_rd_stb(14),
        pi_decoder_wr_stb => reg_wr_stb(14),
        pi_decoder_data   => reg_data_in,
        po_decoder_data   => reg_data_out_vect(14),

        pi_reg  => pi_addrmap.ECC_SYNDROME,
        po_reg  => po_addrmap.ECC_SYNDROME
      );--
  end block;--
  -- ---------------------------------------------------------------------------
  -- reg name: ID  reg type: ID
  -- ---------------------------------------------------------------------------
  blk_ID : block
  begin  --
    inst_ID: entity work.fpga_config_manager_ID
      port map(
        pi_clock        => pi_clock,
        pi_reset        => pi_reset,
        -- to/from adapter
        pi_decoder_rd_stb => reg_rd_stb(15),
        pi_decoder_wr_stb => reg_wr_stb(15),
        pi_decoder_data   => reg_data_in,
        po_decoder_data   => reg_data_out_vect(15),

        pi_reg  => pi_addrmap.ID,
        po_reg  => po_addrmap.ID
      );--
  end block;--
  -- ---------------------------------------------------------------------------
  -- reg name: VERSION  reg type: VERSION
  -- ---------------------------------------------------------------------------
  blk_VERSION : block
  begin  --
    inst_VERSION: entity work.fpga_config_manager_VERSION
      port map(
        pi_clock        => pi_clock,
        pi_reset        => pi_reset,
        -- to/from adapter
        pi_decoder_rd_stb => reg_rd_stb(16),
        pi_decoder_wr_stb => reg_wr_stb(16),
        pi_decoder_data   => reg_data_in,
        po_decoder_data   => reg_data_out_vect(16),

        pi_reg  => pi_addrmap.VERSION,
        po_reg  => po_addrmap.VERSION
      );--
  end block;--

  -- ===========================================================================
  -- generated registers instances in regfiles 

  -- ===========================================================================
  -- Generated Meme Instances
  --
  mem_ack <= '1'; -- not used at the moment from external memories
  -- ---------------------------------------------------------------------------
  -- mem name: WRITE_BUF  mem type: WRITE_BUF
  -- ---------------------------------------------------------------------------
  blk_WRITE_BUF : block
  begin--
    mem_data_out_vect(0)(32-1 downto 0) <= pi_addrmap.WRITE_BUF.data;--
    po_addrmap.WRITE_BUF.addr <= mem_addr(12-1 downto 0);
    po_addrmap.WRITE_BUF.data <= mem_data_in(32-1 downto 0);
    po_addrmap.WRITE_BUF.en <= mem_stb(0);
    po_addrmap.WRITE_BUF.we <= mem_we;--
  end block;
  -- ---------------------------------------------------------------------------
  -- mem name: READ_BUF  mem type: READ_BUF
  -- ---------------------------------------------------------------------------
  blk_READ_BUF : block
  begin--
    mem_data_out_vect(1)(32-1 downto 0) <= pi_addrmap.READ_BUF.data;--
    po_addrmap.READ_BUF.addr <= mem_addr(12-1 downto 0);
    po_addrmap.READ_BUF.data <= mem_data_in(32-1 downto 0);
    po_addrmap.READ_BUF.en <= mem_stb(1);
    po_addrmap.READ_BUF.we <= mem_we;--
  end block;
  -- ---------------------------------------------------------------------------

  -- ===========================================================================
  -- External Busses

end architecture;
