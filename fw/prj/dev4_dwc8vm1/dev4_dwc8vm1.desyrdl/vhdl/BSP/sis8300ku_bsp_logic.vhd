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

use work.pkg_sis8300ku_bsp_logic.all;

entity sis8300ku_bsp_logic is
  port (
    pi_clock : in std_logic;
    pi_reset : in std_logic;
    -- TOP subordinate memory mapped interface
    pi_s_reset : in std_logic := '0';
    pi_s_top   : in  t_sis8300ku_bsp_logic_m2s;
    po_s_top   : out t_sis8300ku_bsp_logic_s2m;
    -- to logic interface
    pi_addrmap : in  t_addrmap_sis8300ku_bsp_logic_in;
    po_addrmap : out t_addrmap_sis8300ku_bsp_logic_out
  );
end entity sis8300ku_bsp_logic;

architecture arch of sis8300ku_bsp_logic is

  type t_data_out is array (natural range<>) of std_logic_vector(C_DATA_WIDTH-1 downto 0) ;

  --
  signal reg_data_out_vect : t_data_out(73-1 downto 0);
  signal reg_rd_stb   : std_logic_vector(73-1 downto 0);
  signal reg_wr_stb   : std_logic_vector(73-1 downto 0);
  signal reg_data_out : std_logic_vector(C_DATA_WIDTH-1 downto 0);
  signal reg_data_in  : std_logic_vector(C_DATA_WIDTH-1 downto 0);
  --
  signal ext_if_i     : t_axi4l_s2m_array(3-1 downto 0);
  signal ext_if_o     : t_axi4l_m2s_array(3-1 downto 0);
  --

begin

  ins_decoder_axi4l : entity work.sis8300ku_bsp_logic_decoder_axi4l
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
    --
    pi_ext      => ext_if_i,
    po_ext      => ext_if_o,
    --
    pi_s_reset  => pi_s_reset,
    pi_s_top    => pi_s_top,
    po_s_top    => po_s_top
  );
  --
  prs_reg_rd_mux: process(pi_clock)
  begin
    if rising_edge(pi_clock) then
      for idx in 0 to 73-1 loop
        if reg_rd_stb(idx) = '1' then
          reg_data_out <= reg_data_out_vect(idx);
        end if;
      end loop;
    end if;
  end process prs_reg_rd_mux;
  --
  --
  --

  -- ===========================================================================
  -- generated registers instances
  -- ---------------------------------------------------------------------------
  -- reg name: ID  reg type: ID
  -- ---------------------------------------------------------------------------
  blk_ID : block
  begin  --
    inst_ID: entity work.sis8300ku_bsp_logic_ID
      port map(
        pi_clock        => pi_clock,
        pi_reset        => pi_reset,
        -- to/from adapter
        pi_decoder_rd_stb => reg_rd_stb(0),
        pi_decoder_wr_stb => reg_wr_stb(0),
        pi_decoder_data   => reg_data_in,
        po_decoder_data   => reg_data_out_vect(0),

        pi_reg  => pi_addrmap.ID,
        po_reg  => po_addrmap.ID
      );--
  end block;--
  -- ---------------------------------------------------------------------------
  -- reg name: VERSION  reg type: VERSION
  -- ---------------------------------------------------------------------------
  blk_VERSION : block
  begin  --
    inst_VERSION: entity work.sis8300ku_bsp_logic_VERSION
      port map(
        pi_clock        => pi_clock,
        pi_reset        => pi_reset,
        -- to/from adapter
        pi_decoder_rd_stb => reg_rd_stb(1),
        pi_decoder_wr_stb => reg_wr_stb(1),
        pi_decoder_data   => reg_data_in,
        po_decoder_data   => reg_data_out_vect(1),

        pi_reg  => pi_addrmap.VERSION,
        po_reg  => po_addrmap.VERSION
      );--
  end block;--
  -- ---------------------------------------------------------------------------
  -- reg name: PRJ_ID  reg type: PRJ_ID
  -- ---------------------------------------------------------------------------
  blk_PRJ_ID : block
  begin  --
    inst_PRJ_ID: entity work.sis8300ku_bsp_logic_PRJ_ID
      port map(
        pi_clock        => pi_clock,
        pi_reset        => pi_reset,
        -- to/from adapter
        pi_decoder_rd_stb => reg_rd_stb(2),
        pi_decoder_wr_stb => reg_wr_stb(2),
        pi_decoder_data   => reg_data_in,
        po_decoder_data   => reg_data_out_vect(2),

        pi_reg  => pi_addrmap.PRJ_ID,
        po_reg  => po_addrmap.PRJ_ID
      );--
  end block;--
  -- ---------------------------------------------------------------------------
  -- reg name: PRJ_VERSION  reg type: PRJ_VERSION
  -- ---------------------------------------------------------------------------
  blk_PRJ_VERSION : block
  begin  --
    inst_PRJ_VERSION: entity work.sis8300ku_bsp_logic_PRJ_VERSION
      port map(
        pi_clock        => pi_clock,
        pi_reset        => pi_reset,
        -- to/from adapter
        pi_decoder_rd_stb => reg_rd_stb(3),
        pi_decoder_wr_stb => reg_wr_stb(3),
        pi_decoder_data   => reg_data_in,
        po_decoder_data   => reg_data_out_vect(3),

        pi_reg  => pi_addrmap.PRJ_VERSION,
        po_reg  => po_addrmap.PRJ_VERSION
      );--
  end block;--
  -- ---------------------------------------------------------------------------
  -- reg name: PRJ_SHASUM  reg type: PRJ_SHASUM
  -- ---------------------------------------------------------------------------
  blk_PRJ_SHASUM : block
  begin  --
    inst_PRJ_SHASUM: entity work.sis8300ku_bsp_logic_PRJ_SHASUM
      port map(
        pi_clock        => pi_clock,
        pi_reset        => pi_reset,
        -- to/from adapter
        pi_decoder_rd_stb => reg_rd_stb(4),
        pi_decoder_wr_stb => reg_wr_stb(4),
        pi_decoder_data   => reg_data_in,
        po_decoder_data   => reg_data_out_vect(4),

        pi_reg  => pi_addrmap.PRJ_SHASUM,
        po_reg  => po_addrmap.PRJ_SHASUM
      );--
  end block;--
  -- ---------------------------------------------------------------------------
  -- reg name: PRJ_TIMESTAMP  reg type: PRJ_TIMESTAMP
  -- ---------------------------------------------------------------------------
  blk_PRJ_TIMESTAMP : block
  begin  --
    inst_PRJ_TIMESTAMP: entity work.sis8300ku_bsp_logic_PRJ_TIMESTAMP
      port map(
        pi_clock        => pi_clock,
        pi_reset        => pi_reset,
        -- to/from adapter
        pi_decoder_rd_stb => reg_rd_stb(5),
        pi_decoder_wr_stb => reg_wr_stb(5),
        pi_decoder_data   => reg_data_in,
        po_decoder_data   => reg_data_out_vect(5),

        pi_reg  => pi_addrmap.PRJ_TIMESTAMP,
        po_reg  => po_addrmap.PRJ_TIMESTAMP
      );--
  end block;--
  -- ---------------------------------------------------------------------------
  -- reg name: SCRATCH  reg type: SCRATCH
  -- ---------------------------------------------------------------------------
  blk_SCRATCH : block
  begin  --
    inst_SCRATCH: entity work.sis8300ku_bsp_logic_SCRATCH
      port map(
        pi_clock        => pi_clock,
        pi_reset        => pi_reset,
        -- to/from adapter
        pi_decoder_rd_stb => reg_rd_stb(6),
        pi_decoder_wr_stb => reg_wr_stb(6),
        pi_decoder_data   => reg_data_in,
        po_decoder_data   => reg_data_out_vect(6),

        pi_reg  => pi_addrmap.SCRATCH,
        po_reg  => po_addrmap.SCRATCH
      );--
  end block;--
  -- ---------------------------------------------------------------------------
  -- reg name: RESET_N  reg type: RESET_N
  -- ---------------------------------------------------------------------------
  blk_RESET_N : block
  begin  --
    inst_RESET_N: entity work.sis8300ku_bsp_logic_RESET_N
      port map(
        pi_clock        => pi_clock,
        pi_reset        => pi_reset,
        -- to/from adapter
        pi_decoder_rd_stb => reg_rd_stb(7),
        pi_decoder_wr_stb => reg_wr_stb(7),
        pi_decoder_data   => reg_data_in,
        po_decoder_data   => reg_data_out_vect(7),

        pi_reg  => pi_addrmap.RESET_N,
        po_reg  => po_addrmap.RESET_N
      );--
  end block;--
  -- ---------------------------------------------------------------------------
  -- reg name: CLK_MUX  reg type: CLK_MUX
  -- ---------------------------------------------------------------------------
  blk_CLK_MUX : block
  begin  --
    gen_m: for idx_m in 0 to 6-1 generate
      inst_CLK_MUX: entity work.sis8300ku_bsp_logic_CLK_MUX
        port map(
          pi_clock        => pi_clock,
          pi_reset        => pi_reset,
          -- to/from adapter
          pi_decoder_rd_stb => reg_rd_stb(8+idx_m),
          pi_decoder_wr_stb => reg_wr_stb(8+idx_m),
          pi_decoder_data   => reg_data_in,
          po_decoder_data   => reg_data_out_vect(8+idx_m),

          pi_reg  => pi_addrmap.CLK_MUX(idx_m),
          po_reg  => po_addrmap.CLK_MUX(idx_m)
        );
    end generate;--
  end block;--
  -- ---------------------------------------------------------------------------
  -- reg name: CLK_SEL  reg type: CLK_SEL
  -- ---------------------------------------------------------------------------
  blk_CLK_SEL : block
  begin  --
    inst_CLK_SEL: entity work.sis8300ku_bsp_logic_CLK_SEL
      port map(
        pi_clock        => pi_clock,
        pi_reset        => pi_reset,
        -- to/from adapter
        pi_decoder_rd_stb => reg_rd_stb(14),
        pi_decoder_wr_stb => reg_wr_stb(14),
        pi_decoder_data   => reg_data_in,
        po_decoder_data   => reg_data_out_vect(14),

        pi_reg  => pi_addrmap.CLK_SEL,
        po_reg  => po_addrmap.CLK_SEL
      );--
  end block;--
  -- ---------------------------------------------------------------------------
  -- reg name: CLK_RST  reg type: CLK_RST
  -- ---------------------------------------------------------------------------
  blk_CLK_RST : block
  begin  --
    inst_CLK_RST: entity work.sis8300ku_bsp_logic_CLK_RST
      port map(
        pi_clock        => pi_clock,
        pi_reset        => pi_reset,
        -- to/from adapter
        pi_decoder_rd_stb => reg_rd_stb(15),
        pi_decoder_wr_stb => reg_wr_stb(15),
        pi_decoder_data   => reg_data_in,
        po_decoder_data   => reg_data_out_vect(15),

        pi_reg  => pi_addrmap.CLK_RST,
        po_reg  => po_addrmap.CLK_RST
      );--
  end block;--
  -- ---------------------------------------------------------------------------
  -- reg name: CLK_FREQ  reg type: CLK_FREQ
  -- ---------------------------------------------------------------------------
  blk_CLK_FREQ : block
  begin  --
    gen_m: for idx_m in 0 to 8-1 generate
      inst_CLK_FREQ: entity work.sis8300ku_bsp_logic_CLK_FREQ
        port map(
          pi_clock        => pi_clock,
          pi_reset        => pi_reset,
          -- to/from adapter
          pi_decoder_rd_stb => reg_rd_stb(16+idx_m),
          pi_decoder_wr_stb => reg_wr_stb(16+idx_m),
          pi_decoder_data   => reg_data_in,
          po_decoder_data   => reg_data_out_vect(16+idx_m),

          pi_reg  => pi_addrmap.CLK_FREQ(idx_m),
          po_reg  => po_addrmap.CLK_FREQ(idx_m)
        );
    end generate;--
  end block;--
  -- ---------------------------------------------------------------------------
  -- reg name: CLK_ERR  reg type: CLK_ERR
  -- ---------------------------------------------------------------------------
  blk_CLK_ERR : block
  begin  --
    inst_CLK_ERR: entity work.sis8300ku_bsp_logic_CLK_ERR
      port map(
        pi_clock        => pi_clock,
        pi_reset        => pi_reset,
        -- to/from adapter
        pi_decoder_rd_stb => reg_rd_stb(24),
        pi_decoder_wr_stb => reg_wr_stb(24),
        pi_decoder_data   => reg_data_in,
        po_decoder_data   => reg_data_out_vect(24),

        pi_reg  => pi_addrmap.CLK_ERR,
        po_reg  => po_addrmap.CLK_ERR
      );--
  end block;--
  -- ---------------------------------------------------------------------------
  -- reg name: SPI_DIV_SEL  reg type: SPI_DIV_SEL
  -- ---------------------------------------------------------------------------
  blk_SPI_DIV_SEL : block
  begin  --
    inst_SPI_DIV_SEL: entity work.sis8300ku_bsp_logic_SPI_DIV_SEL
      port map(
        pi_clock        => pi_clock,
        pi_reset        => pi_reset,
        -- to/from adapter
        pi_decoder_rd_stb => reg_rd_stb(25),
        pi_decoder_wr_stb => reg_wr_stb(25),
        pi_decoder_data   => reg_data_in,
        po_decoder_data   => reg_data_out_vect(25),

        pi_reg  => pi_addrmap.SPI_DIV_SEL,
        po_reg  => po_addrmap.SPI_DIV_SEL
      );--
  end block;--
  -- ---------------------------------------------------------------------------
  -- reg name: SPI_DIV_BUSY  reg type: SPI_DIV_BUSY
  -- ---------------------------------------------------------------------------
  blk_SPI_DIV_BUSY : block
  begin  --
    inst_SPI_DIV_BUSY: entity work.sis8300ku_bsp_logic_SPI_DIV_BUSY
      port map(
        pi_clock        => pi_clock,
        pi_reset        => pi_reset,
        -- to/from adapter
        pi_decoder_rd_stb => reg_rd_stb(26),
        pi_decoder_wr_stb => reg_wr_stb(26),
        pi_decoder_data   => reg_data_in,
        po_decoder_data   => reg_data_out_vect(26),

        pi_reg  => pi_addrmap.SPI_DIV_BUSY,
        po_reg  => po_addrmap.SPI_DIV_BUSY
      );--
  end block;--
  -- ---------------------------------------------------------------------------
  -- reg name: ADC_ENA  reg type: ADC_ENA
  -- ---------------------------------------------------------------------------
  blk_ADC_ENA : block
  begin  --
    inst_ADC_ENA: entity work.sis8300ku_bsp_logic_ADC_ENA
      port map(
        pi_clock        => pi_clock,
        pi_reset        => pi_reset,
        -- to/from adapter
        pi_decoder_rd_stb => reg_rd_stb(27),
        pi_decoder_wr_stb => reg_wr_stb(27),
        pi_decoder_data   => reg_data_in,
        po_decoder_data   => reg_data_out_vect(27),

        pi_reg  => pi_addrmap.ADC_ENA,
        po_reg  => po_addrmap.ADC_ENA
      );--
  end block;--
  -- ---------------------------------------------------------------------------
  -- reg name: ADC_IDELAY_CNT  reg type: ADC_IDELAY_CNT
  -- ---------------------------------------------------------------------------
  blk_ADC_IDELAY_CNT : block
  begin  --
    gen_m: for idx_m in 0 to 5-1 generate
      inst_ADC_IDELAY_CNT: entity work.sis8300ku_bsp_logic_ADC_IDELAY_CNT
        port map(
          pi_clock        => pi_clock,
          pi_reset        => pi_reset,
          -- to/from adapter
          pi_decoder_rd_stb => reg_rd_stb(28+idx_m),
          pi_decoder_wr_stb => reg_wr_stb(28+idx_m),
          pi_decoder_data   => reg_data_in,
          po_decoder_data   => reg_data_out_vect(28+idx_m),

          pi_reg  => pi_addrmap.ADC_IDELAY_CNT(idx_m),
          po_reg  => po_addrmap.ADC_IDELAY_CNT(idx_m)
        );
    end generate;--
  end block;--
  -- ---------------------------------------------------------------------------
  -- reg name: ADC_REVERT_CLK  reg type: ADC_REVERT_CLK
  -- ---------------------------------------------------------------------------
  blk_ADC_REVERT_CLK : block
  begin  --
    inst_ADC_REVERT_CLK: entity work.sis8300ku_bsp_logic_ADC_REVERT_CLK
      port map(
        pi_clock        => pi_clock,
        pi_reset        => pi_reset,
        -- to/from adapter
        pi_decoder_rd_stb => reg_rd_stb(33),
        pi_decoder_wr_stb => reg_wr_stb(33),
        pi_decoder_data   => reg_data_in,
        po_decoder_data   => reg_data_out_vect(33),

        pi_reg  => pi_addrmap.ADC_REVERT_CLK,
        po_reg  => po_addrmap.ADC_REVERT_CLK
      );--
  end block;--
  -- ---------------------------------------------------------------------------
  -- reg name: SPI_ADC_SEL  reg type: SPI_ADC_SEL
  -- ---------------------------------------------------------------------------
  blk_SPI_ADC_SEL : block
  begin  --
    inst_SPI_ADC_SEL: entity work.sis8300ku_bsp_logic_SPI_ADC_SEL
      port map(
        pi_clock        => pi_clock,
        pi_reset        => pi_reset,
        -- to/from adapter
        pi_decoder_rd_stb => reg_rd_stb(34),
        pi_decoder_wr_stb => reg_wr_stb(34),
        pi_decoder_data   => reg_data_in,
        po_decoder_data   => reg_data_out_vect(34),

        pi_reg  => pi_addrmap.SPI_ADC_SEL,
        po_reg  => po_addrmap.SPI_ADC_SEL
      );--
  end block;--
  -- ---------------------------------------------------------------------------
  -- reg name: SPI_ADC_BUSY  reg type: SPI_ADC_BUSY
  -- ---------------------------------------------------------------------------
  blk_SPI_ADC_BUSY : block
  begin  --
    inst_SPI_ADC_BUSY: entity work.sis8300ku_bsp_logic_SPI_ADC_BUSY
      port map(
        pi_clock        => pi_clock,
        pi_reset        => pi_reset,
        -- to/from adapter
        pi_decoder_rd_stb => reg_rd_stb(35),
        pi_decoder_wr_stb => reg_wr_stb(35),
        pi_decoder_data   => reg_data_in,
        po_decoder_data   => reg_data_out_vect(35),

        pi_reg  => pi_addrmap.SPI_ADC_BUSY,
        po_reg  => po_addrmap.SPI_ADC_BUSY
      );--
  end block;--
  -- ---------------------------------------------------------------------------
  -- reg name: DAC_ENA  reg type: DAC_ENA
  -- ---------------------------------------------------------------------------
  blk_DAC_ENA : block
  begin  --
    inst_DAC_ENA: entity work.sis8300ku_bsp_logic_DAC_ENA
      port map(
        pi_clock        => pi_clock,
        pi_reset        => pi_reset,
        -- to/from adapter
        pi_decoder_rd_stb => reg_rd_stb(36),
        pi_decoder_wr_stb => reg_wr_stb(36),
        pi_decoder_data   => reg_data_in,
        po_decoder_data   => reg_data_out_vect(36),

        pi_reg  => pi_addrmap.DAC_ENA,
        po_reg  => po_addrmap.DAC_ENA
      );--
  end block;--
  -- ---------------------------------------------------------------------------
  -- reg name: DAC_IDELAY_INC  reg type: DAC_IDELAY_INC
  -- ---------------------------------------------------------------------------
  blk_DAC_IDELAY_INC : block
  begin  --
    inst_DAC_IDELAY_INC: entity work.sis8300ku_bsp_logic_DAC_IDELAY_INC
      port map(
        pi_clock        => pi_clock,
        pi_reset        => pi_reset,
        -- to/from adapter
        pi_decoder_rd_stb => reg_rd_stb(37),
        pi_decoder_wr_stb => reg_wr_stb(37),
        pi_decoder_data   => reg_data_in,
        po_decoder_data   => reg_data_out_vect(37),

        pi_reg  => pi_addrmap.DAC_IDELAY_INC,
        po_reg  => po_addrmap.DAC_IDELAY_INC
      );--
  end block;--
  -- ---------------------------------------------------------------------------
  -- reg name: DAC_IDELAY_CNT  reg type: DAC_IDELAY_CNT
  -- ---------------------------------------------------------------------------
  blk_DAC_IDELAY_CNT : block
  begin  --
    inst_DAC_IDELAY_CNT: entity work.sis8300ku_bsp_logic_DAC_IDELAY_CNT
      port map(
        pi_clock        => pi_clock,
        pi_reset        => pi_reset,
        -- to/from adapter
        pi_decoder_rd_stb => reg_rd_stb(38),
        pi_decoder_wr_stb => reg_wr_stb(38),
        pi_decoder_data   => reg_data_in,
        po_decoder_data   => reg_data_out_vect(38),

        pi_reg  => pi_addrmap.DAC_IDELAY_CNT,
        po_reg  => po_addrmap.DAC_IDELAY_CNT
      );--
  end block;--
  -- ---------------------------------------------------------------------------
  -- reg name: DDR_CALIB_DONE  reg type: DDR_CALIB_DONE
  -- ---------------------------------------------------------------------------
  blk_DDR_CALIB_DONE : block
  begin  --
    inst_DDR_CALIB_DONE: entity work.sis8300ku_bsp_logic_DDR_CALIB_DONE
      port map(
        pi_clock        => pi_clock,
        pi_reset        => pi_reset,
        -- to/from adapter
        pi_decoder_rd_stb => reg_rd_stb(39),
        pi_decoder_wr_stb => reg_wr_stb(39),
        pi_decoder_data   => reg_data_in,
        po_decoder_data   => reg_data_out_vect(39),

        pi_reg  => pi_addrmap.DDR_CALIB_DONE,
        po_reg  => po_addrmap.DDR_CALIB_DONE
      );--
  end block;--
  -- ---------------------------------------------------------------------------
  -- reg name: BOOT_STATUS  reg type: BOOT_STATUS
  -- ---------------------------------------------------------------------------
  blk_BOOT_STATUS : block
  begin  --
    inst_BOOT_STATUS: entity work.sis8300ku_bsp_logic_BOOT_STATUS
      port map(
        pi_clock        => pi_clock,
        pi_reset        => pi_reset,
        -- to/from adapter
        pi_decoder_rd_stb => reg_rd_stb(40),
        pi_decoder_wr_stb => reg_wr_stb(40),
        pi_decoder_data   => reg_data_in,
        po_decoder_data   => reg_data_out_vect(40),

        pi_reg  => pi_addrmap.BOOT_STATUS,
        po_reg  => po_addrmap.BOOT_STATUS
      );--
  end block;--
  -- ---------------------------------------------------------------------------
  -- reg name: PCIE_IRQ_ENA  reg type: PCIE_IRQ_ENA
  -- ---------------------------------------------------------------------------
  blk_PCIE_IRQ_ENA : block
  begin  --
    gen_m: for idx_m in 0 to 16-1 generate
      inst_PCIE_IRQ_ENA: entity work.sis8300ku_bsp_logic_PCIE_IRQ_ENA
        port map(
          pi_clock        => pi_clock,
          pi_reset        => pi_reset,
          -- to/from adapter
          pi_decoder_rd_stb => reg_rd_stb(41+idx_m),
          pi_decoder_wr_stb => reg_wr_stb(41+idx_m),
          pi_decoder_data   => reg_data_in,
          po_decoder_data   => reg_data_out_vect(41+idx_m),

          pi_reg  => pi_addrmap.PCIE_IRQ_ENA(idx_m),
          po_reg  => po_addrmap.PCIE_IRQ_ENA(idx_m)
        );
    end generate;--
  end block;--
  -- ---------------------------------------------------------------------------
  -- reg name: PCIE_IRQ_ACK_TIMEOUT  reg type: PCIE_IRQ_ACK_TIMEOUT
  -- ---------------------------------------------------------------------------
  blk_PCIE_IRQ_ACK_TIMEOUT : block
  begin  --
    gen_m: for idx_m in 0 to 16-1 generate
      inst_PCIE_IRQ_ACK_TIMEOUT: entity work.sis8300ku_bsp_logic_PCIE_IRQ_ACK_TIMEOUT
        port map(
          pi_clock        => pi_clock,
          pi_reset        => pi_reset,
          -- to/from adapter
          pi_decoder_rd_stb => reg_rd_stb(57+idx_m),
          pi_decoder_wr_stb => reg_wr_stb(57+idx_m),
          pi_decoder_data   => reg_data_in,
          po_decoder_data   => reg_data_out_vect(57+idx_m),

          pi_reg  => pi_addrmap.PCIE_IRQ_ACK_TIMEOUT(idx_m),
          po_reg  => po_addrmap.PCIE_IRQ_ACK_TIMEOUT(idx_m)
        );
    end generate;--
  end block;--

  -- ===========================================================================
  -- generated registers instances in regfiles 

  -- ===========================================================================
  -- Generated Meme Instances
  --
  -- ---------------------------------------------------------------------------

  -- ===========================================================================
  -- External Busses
  -- ---------------------------------------------------------------------------
  -- ext name: FCM  ext type: fpga_config_manager
  -- ---------------------------------------------------------------------------
  blk_FCM : block
  begin--
    --
    po_addrmap.FCM <= ext_if_o(0);
    ext_if_i(0) <= pi_addrmap.FCM;
    --
    ----
  end block;--
  -- ---------------------------------------------------------------------------
  -- ext name: AREA_SPI_DIV  ext type: spi_ad9510_desyrdl_interface_7a5f1e53
  -- ---------------------------------------------------------------------------
  blk_AREA_SPI_DIV : block
  begin--
    --
    po_addrmap.AREA_SPI_DIV <= ext_if_o(1);
    ext_if_i(1) <= pi_addrmap.AREA_SPI_DIV;
    --
    ----
  end block;--
  -- ---------------------------------------------------------------------------
  -- ext name: AREA_SPI_ADC  ext type: spi_ad9268_desyrdl_interface_7a5f1e53
  -- ---------------------------------------------------------------------------
  blk_AREA_SPI_ADC : block
  begin--
    --
    po_addrmap.AREA_SPI_ADC <= ext_if_o(2);
    ext_if_i(2) <= pi_addrmap.AREA_SPI_ADC;
    --
    ----
  end block;--

end architecture;
