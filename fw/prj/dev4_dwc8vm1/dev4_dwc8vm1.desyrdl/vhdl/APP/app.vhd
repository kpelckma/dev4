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

use work.pkg_app.all;

entity app is
  port (
    pi_clock : in std_logic;
    pi_reset : in std_logic;
    -- TOP subordinate memory mapped interface
    pi_s_reset : in std_logic := '0';
    pi_s_top   : in  t_app_m2s;
    po_s_top   : out t_app_s2m;
    -- to logic interface
    pi_addrmap : in  t_addrmap_app_in;
    po_addrmap : out t_addrmap_app_out
  );
end entity app;

architecture arch of app is

  type t_data_out is array (natural range<>) of std_logic_vector(C_DATA_WIDTH-1 downto 0) ;

  --
  signal reg_data_out_vect : t_data_out(58-1 downto 0);
  signal reg_rd_stb   : std_logic_vector(58-1 downto 0);
  signal reg_wr_stb   : std_logic_vector(58-1 downto 0);
  signal reg_data_out : std_logic_vector(C_DATA_WIDTH-1 downto 0);
  signal reg_data_in  : std_logic_vector(C_DATA_WIDTH-1 downto 0);
  --
  signal mem_data_out_vect : t_data_out(4-1 downto 0);
  signal mem_stb      : std_logic_vector(4-1 downto 0);
  signal mem_we       : std_logic;
  signal mem_addr     : std_logic_vector(C_ADDR_WIDTH-1 downto 0);
  signal mem_data_out : std_logic_vector(C_DATA_WIDTH-1 downto 0);
  signal mem_data_in  : std_logic_vector(C_DATA_WIDTH-1 downto 0);
  signal mem_ack      : std_logic;
  --
  signal ext_if_i     : t_axi4l_s2m_array(4-1 downto 0);
  signal ext_if_o     : t_axi4l_m2s_array(4-1 downto 0);
  --

begin

  ins_decoder_axi4l : entity work.app_decoder_axi4l
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
      for idx in 0 to 58-1 loop
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
      for idx in 0 to 4-1 loop
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
  -- reg name: ID  reg type: ID
  -- ---------------------------------------------------------------------------
  blk_ID : block
  begin  --
    inst_ID: entity work.app_ID
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
    inst_VERSION: entity work.app_VERSION
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
  -- reg name: IRQ_ACK_CNT  reg type: IRQ_ACK_CNT
  -- ---------------------------------------------------------------------------
  blk_IRQ_ACK_CNT : block
  begin  --
    gen_m: for idx_m in 0 to 16-1 generate
      inst_IRQ_ACK_CNT: entity work.app_IRQ_ACK_CNT
        port map(
          pi_clock        => pi_clock,
          pi_reset        => pi_reset,
          -- to/from adapter
          pi_decoder_rd_stb => reg_rd_stb(2+idx_m),
          pi_decoder_wr_stb => reg_wr_stb(2+idx_m),
          pi_decoder_data   => reg_data_in,
          po_decoder_data   => reg_data_out_vect(2+idx_m),

          pi_reg  => pi_addrmap.IRQ_ACK_CNT(idx_m),
          po_reg  => po_addrmap.IRQ_ACK_CNT(idx_m)
        );
    end generate;--
  end block;--
  -- ---------------------------------------------------------------------------
  -- reg name: SCRATCH  reg type: SCRATCH
  -- ---------------------------------------------------------------------------
  blk_SCRATCH : block
  begin  --
    gen_m: for idx_m in 0 to 10-1 generate
      inst_SCRATCH: entity work.app_SCRATCH
        port map(
          pi_clock        => pi_clock,
          pi_reset        => pi_reset,
          -- to/from adapter
          pi_decoder_rd_stb => reg_rd_stb(18+idx_m),
          pi_decoder_wr_stb => reg_wr_stb(18+idx_m),
          pi_decoder_data   => reg_data_in,
          po_decoder_data   => reg_data_out_vect(18+idx_m),

          pi_reg  => pi_addrmap.SCRATCH(idx_m),
          po_reg  => po_addrmap.SCRATCH(idx_m)
        );
    end generate;--
  end block;--
  -- ---------------------------------------------------------------------------
  -- reg name: ADC_OV_LATCHED  reg type: ADC_OV_LATCHED
  -- ---------------------------------------------------------------------------
  blk_ADC_OV_LATCHED : block
  begin  --
    gen_m: for idx_m in 0 to 10-1 generate
      inst_ADC_OV_LATCHED: entity work.app_ADC_OV_LATCHED
        port map(
          pi_clock        => pi_clock,
          pi_reset        => pi_reset,
          -- to/from adapter
          pi_decoder_rd_stb => reg_rd_stb(28+idx_m),
          pi_decoder_wr_stb => reg_wr_stb(28+idx_m),
          pi_decoder_data   => reg_data_in,
          po_decoder_data   => reg_data_out_vect(28+idx_m),

          pi_reg  => pi_addrmap.ADC_OV_LATCHED(idx_m),
          po_reg  => po_addrmap.ADC_OV_LATCHED(idx_m)
        );
    end generate;--
  end block;--
  -- ---------------------------------------------------------------------------
  -- reg name: CNT_EVENTS  reg type: CNT_EVENTS
  -- ---------------------------------------------------------------------------
  blk_CNT_EVENTS : block
  begin  --
    gen_m: for idx_m in 0 to 10-1 generate
      inst_CNT_EVENTS: entity work.app_CNT_EVENTS
        port map(
          pi_clock        => pi_clock,
          pi_reset        => pi_reset,
          -- to/from adapter
          pi_decoder_rd_stb => reg_rd_stb(38+idx_m),
          pi_decoder_wr_stb => reg_wr_stb(38+idx_m),
          pi_decoder_data   => reg_data_in,
          po_decoder_data   => reg_data_out_vect(38+idx_m),

          pi_reg  => pi_addrmap.CNT_EVENTS(idx_m),
          po_reg  => po_addrmap.CNT_EVENTS(idx_m)
        );
    end generate;--
  end block;--
  -- ---------------------------------------------------------------------------
  -- reg name: FB_SWITCH  reg type: FB_SWITCH
  -- ---------------------------------------------------------------------------
  blk_FB_SWITCH : block
  begin  --
    inst_FB_SWITCH: entity work.app_FB_SWITCH
      port map(
        pi_clock        => pi_clock,
        pi_reset        => pi_reset,
        -- to/from adapter
        pi_decoder_rd_stb => reg_rd_stb(48),
        pi_decoder_wr_stb => reg_wr_stb(48),
        pi_decoder_data   => reg_data_in,
        po_decoder_data   => reg_data_out_vect(48),

        pi_reg  => pi_addrmap.FB_SWITCH,
        po_reg  => po_addrmap.FB_SWITCH
      );--
  end block;--
  -- ---------------------------------------------------------------------------
  -- reg name: MLVDS_I  reg type: MLVDS_I
  -- ---------------------------------------------------------------------------
  blk_MLVDS_I : block
  begin  --
    inst_MLVDS_I: entity work.app_MLVDS_I
      port map(
        pi_clock        => pi_clock,
        pi_reset        => pi_reset,
        -- to/from adapter
        pi_decoder_rd_stb => reg_rd_stb(49),
        pi_decoder_wr_stb => reg_wr_stb(49),
        pi_decoder_data   => reg_data_in,
        po_decoder_data   => reg_data_out_vect(49),

        pi_reg  => pi_addrmap.MLVDS_I,
        po_reg  => po_addrmap.MLVDS_I
      );--
  end block;--
  -- ---------------------------------------------------------------------------
  -- reg name: MLVDS_O  reg type: MLVDS_O
  -- ---------------------------------------------------------------------------
  blk_MLVDS_O : block
  begin  --
    inst_MLVDS_O: entity work.app_MLVDS_O
      port map(
        pi_clock        => pi_clock,
        pi_reset        => pi_reset,
        -- to/from adapter
        pi_decoder_rd_stb => reg_rd_stb(50),
        pi_decoder_wr_stb => reg_wr_stb(50),
        pi_decoder_data   => reg_data_in,
        po_decoder_data   => reg_data_out_vect(50),

        pi_reg  => pi_addrmap.MLVDS_O,
        po_reg  => po_addrmap.MLVDS_O
      );--
  end block;--
  -- ---------------------------------------------------------------------------
  -- reg name: MLVDS_OE  reg type: MLVDS_OE
  -- ---------------------------------------------------------------------------
  blk_MLVDS_OE : block
  begin  --
    inst_MLVDS_OE: entity work.app_MLVDS_OE
      port map(
        pi_clock        => pi_clock,
        pi_reset        => pi_reset,
        -- to/from adapter
        pi_decoder_rd_stb => reg_rd_stb(51),
        pi_decoder_wr_stb => reg_wr_stb(51),
        pi_decoder_data   => reg_data_in,
        po_decoder_data   => reg_data_out_vect(51),

        pi_reg  => pi_addrmap.MLVDS_OE,
        po_reg  => po_addrmap.MLVDS_OE
      );--
  end block;--
  -- ---------------------------------------------------------------------------
  -- reg name: TIMESTAMP  reg type: TIMESTAMP
  -- ---------------------------------------------------------------------------
  blk_TIMESTAMP : block
  begin  --
    inst_TIMESTAMP: entity work.app_TIMESTAMP
      port map(
        pi_clock        => pi_clock,
        pi_reset        => pi_reset,
        -- to/from adapter
        pi_decoder_rd_stb => reg_rd_stb(52),
        pi_decoder_wr_stb => reg_wr_stb(52),
        pi_decoder_data   => reg_data_in,
        po_decoder_data   => reg_data_out_vect(52),

        pi_reg  => pi_addrmap.TIMESTAMP,
        po_reg  => po_addrmap.TIMESTAMP
      );--
  end block;--
  -- ---------------------------------------------------------------------------
  -- reg name: CNT_RJ45  reg type: CNT_RJ45
  -- ---------------------------------------------------------------------------
  blk_CNT_RJ45 : block
  begin  --
    gen_m: for idx_m in 0 to 3-1 generate
      inst_CNT_RJ45: entity work.app_CNT_RJ45
        port map(
          pi_clock        => pi_clock,
          pi_reset        => pi_reset,
          -- to/from adapter
          pi_decoder_rd_stb => reg_rd_stb(53+idx_m),
          pi_decoder_wr_stb => reg_wr_stb(53+idx_m),
          pi_decoder_data   => reg_data_in,
          po_decoder_data   => reg_data_out_vect(53+idx_m),

          pi_reg  => pi_addrmap.CNT_RJ45(idx_m),
          po_reg  => po_addrmap.CNT_RJ45(idx_m)
        );
    end generate;--
  end block;--
  -- ---------------------------------------------------------------------------
  -- reg name: ROTATION  reg type: ROTATION
  -- ---------------------------------------------------------------------------
  blk_ROTATION : block
  begin  --
    inst_ROTATION: entity work.app_ROTATION
      port map(
        pi_clock        => pi_clock,
        pi_reset        => pi_reset,
        -- to/from adapter
        pi_decoder_rd_stb => reg_rd_stb(56),
        pi_decoder_wr_stb => reg_wr_stb(56),
        pi_decoder_data   => reg_data_in,
        po_decoder_data   => reg_data_out_vect(56),

        pi_reg  => pi_addrmap.ROTATION,
        po_reg  => po_addrmap.ROTATION
      );--
  end block;--
  -- ---------------------------------------------------------------------------
  -- reg name: DPM_MODE  reg type: DPM_MODE
  -- ---------------------------------------------------------------------------
  blk_DPM_MODE : block
  begin  --
    inst_DPM_MODE: entity work.app_DPM_MODE
      port map(
        pi_clock        => pi_clock,
        pi_reset        => pi_reset,
        -- to/from adapter
        pi_decoder_rd_stb => reg_rd_stb(57),
        pi_decoder_wr_stb => reg_wr_stb(57),
        pi_decoder_data   => reg_data_in,
        po_decoder_data   => reg_data_out_vect(57),

        pi_reg  => pi_addrmap.DPM_MODE,
        po_reg  => po_addrmap.DPM_MODE
      );--
  end block;--

  -- ===========================================================================
  -- generated registers instances in regfiles 

  -- ===========================================================================
  -- Generated Meme Instances
  --
  mem_ack <= '1'; -- not used at the moment from external memories
  -- ---------------------------------------------------------------------------
  -- mem name: REF_I  mem type: REF_I
  -- ---------------------------------------------------------------------------
  blk_REF_I : block
  begin--
    mem_data_out_vect(0)(32-1 downto 0) <= pi_addrmap.REF_I.data;--
    po_addrmap.REF_I.addr <= mem_addr(12-1 downto 0);
    po_addrmap.REF_I.data <= mem_data_in(32-1 downto 0);
    po_addrmap.REF_I.en <= mem_stb(0);
    po_addrmap.REF_I.we <= mem_we;--
  end block;
  -- ---------------------------------------------------------------------------
  -- mem name: REF_Q  mem type: REF_Q
  -- ---------------------------------------------------------------------------
  blk_REF_Q : block
  begin--
    mem_data_out_vect(1)(32-1 downto 0) <= pi_addrmap.REF_Q.data;--
    po_addrmap.REF_Q.addr <= mem_addr(12-1 downto 0);
    po_addrmap.REF_Q.data <= mem_data_in(32-1 downto 0);
    po_addrmap.REF_Q.en <= mem_stb(1);
    po_addrmap.REF_Q.we <= mem_we;--
  end block;
  -- ---------------------------------------------------------------------------
  -- mem name: FFD_I  mem type: FFD_I
  -- ---------------------------------------------------------------------------
  blk_FFD_I : block
  begin--
    mem_data_out_vect(2)(32-1 downto 0) <= pi_addrmap.FFD_I.data;--
    po_addrmap.FFD_I.addr <= mem_addr(12-1 downto 0);
    po_addrmap.FFD_I.data <= mem_data_in(32-1 downto 0);
    po_addrmap.FFD_I.en <= mem_stb(2);
    po_addrmap.FFD_I.we <= mem_we;--
  end block;
  -- ---------------------------------------------------------------------------
  -- mem name: FFD_Q  mem type: FFD_Q
  -- ---------------------------------------------------------------------------
  blk_FFD_Q : block
  begin--
    mem_data_out_vect(3)(32-1 downto 0) <= pi_addrmap.FFD_Q.data;--
    po_addrmap.FFD_Q.addr <= mem_addr(12-1 downto 0);
    po_addrmap.FFD_Q.data <= mem_data_in(32-1 downto 0);
    po_addrmap.FFD_Q.en <= mem_stb(3);
    po_addrmap.FFD_Q.we <= mem_we;--
  end block;
  -- ---------------------------------------------------------------------------

  -- ===========================================================================
  -- External Busses
  -- ---------------------------------------------------------------------------
  -- ext name: TIMING  ext type: timing
  -- ---------------------------------------------------------------------------
  blk_TIMING : block
  begin--
    --
    po_addrmap.TIMING <= ext_if_o(0);
    ext_if_i(0) <= pi_addrmap.TIMING;
    --
    ----
  end block;--
  -- ---------------------------------------------------------------------------
  -- ext name: DAQ  ext type: daq
  -- ---------------------------------------------------------------------------
  blk_DAQ : block
  begin--
    --
    po_addrmap.DAQ <= ext_if_o(1);
    ext_if_i(1) <= pi_addrmap.DAQ;
    --
    ----
  end block;--
  -- ---------------------------------------------------------------------------
  -- ext name: MIMO  ext type: mimo
  -- ---------------------------------------------------------------------------
  blk_MIMO : block
  begin--
    --
    po_addrmap.MIMO <= ext_if_o(2);
    ext_if_i(2) <= pi_addrmap.MIMO;
    --
    ----
  end block;--
  -- ---------------------------------------------------------------------------
  -- ext name: RTM  ext type: rtm
  -- ---------------------------------------------------------------------------
  blk_RTM : block
  begin--
    --
    po_addrmap.RTM <= ext_if_o(3);
    ext_if_i(3) <= pi_addrmap.RTM;
    --
    ----
  end block;--

end architecture;
