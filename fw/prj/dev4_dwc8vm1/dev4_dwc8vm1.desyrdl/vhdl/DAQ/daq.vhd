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

use work.pkg_daq.all;

entity daq is
  port (
    pi_clock : in std_logic;
    pi_reset : in std_logic;
    -- TOP subordinate memory mapped interface
    pi_s_reset : in std_logic := '0';
    pi_s_top   : in  t_daq_m2s;
    po_s_top   : out t_daq_s2m;
    -- to logic interface
    pi_addrmap : in  t_addrmap_daq_in;
    po_addrmap : out t_addrmap_daq_out
  );
end entity daq;

architecture arch of daq is

  type t_data_out is array (natural range<>) of std_logic_vector(C_DATA_WIDTH-1 downto 0) ;

  --
  signal reg_data_out_vect : t_data_out(17-1 downto 0);
  signal reg_rd_stb   : std_logic_vector(17-1 downto 0);
  signal reg_wr_stb   : std_logic_vector(17-1 downto 0);
  signal reg_data_out : std_logic_vector(C_DATA_WIDTH-1 downto 0);
  signal reg_data_in  : std_logic_vector(C_DATA_WIDTH-1 downto 0);
  --
  signal mem_data_out_vect : t_data_out(3-1 downto 0);
  signal mem_stb      : std_logic_vector(3-1 downto 0);
  signal mem_we       : std_logic;
  signal mem_addr     : std_logic_vector(C_ADDR_WIDTH-1 downto 0);
  signal mem_data_out : std_logic_vector(C_DATA_WIDTH-1 downto 0);
  signal mem_data_in  : std_logic_vector(C_DATA_WIDTH-1 downto 0);
  signal mem_ack      : std_logic;
  --

begin

  ins_decoder_axi4l : entity work.daq_decoder_axi4l
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
      for idx in 0 to 3-1 loop
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
    inst_ID: entity work.daq_ID
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
    inst_VERSION: entity work.daq_VERSION
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
  -- reg name: ENABLE  reg type: ENABLE
  -- ---------------------------------------------------------------------------
  blk_ENABLE : block
  begin  --
    inst_ENABLE: entity work.daq_ENABLE
      port map(
        pi_clock        => pi_clock,
        pi_reset        => pi_reset,
        -- to/from adapter
        pi_decoder_rd_stb => reg_rd_stb(2),
        pi_decoder_wr_stb => reg_wr_stb(2),
        pi_decoder_data   => reg_data_in,
        po_decoder_data   => reg_data_out_vect(2),

        pi_reg  => pi_addrmap.ENABLE,
        po_reg  => po_addrmap.ENABLE
      );--
  end block;--
  -- ---------------------------------------------------------------------------
  -- reg name: TAB_SEL  reg type: TAB_SEL
  -- ---------------------------------------------------------------------------
  blk_TAB_SEL : block
  begin  --
    gen_m: for idx_m in 0 to 1-1 generate
      inst_TAB_SEL: entity work.daq_TAB_SEL
        port map(
          pi_clock        => pi_clock,
          pi_reset        => pi_reset,
          -- to/from adapter
          pi_decoder_rd_stb => reg_rd_stb(3+idx_m),
          pi_decoder_wr_stb => reg_wr_stb(3+idx_m),
          pi_decoder_data   => reg_data_in,
          po_decoder_data   => reg_data_out_vect(3+idx_m),

          pi_reg  => pi_addrmap.TAB_SEL(idx_m),
          po_reg  => po_addrmap.TAB_SEL(idx_m)
        );
    end generate;--
  end block;--
  -- ---------------------------------------------------------------------------
  -- reg name: STROBE_DIV  reg type: STROBE_DIV
  -- ---------------------------------------------------------------------------
  blk_STROBE_DIV : block
  begin  --
    gen_m: for idx_m in 0 to 1-1 generate
      inst_STROBE_DIV: entity work.daq_STROBE_DIV
        port map(
          pi_clock        => pi_clock,
          pi_reset        => pi_reset,
          -- to/from adapter
          pi_decoder_rd_stb => reg_rd_stb(4+idx_m),
          pi_decoder_wr_stb => reg_wr_stb(4+idx_m),
          pi_decoder_data   => reg_data_in,
          po_decoder_data   => reg_data_out_vect(4+idx_m),

          pi_reg  => pi_addrmap.STROBE_DIV(idx_m),
          po_reg  => po_addrmap.STROBE_DIV(idx_m)
        );
    end generate;--
  end block;--
  -- ---------------------------------------------------------------------------
  -- reg name: STROBE_CNT  reg type: STROBE_CNT
  -- ---------------------------------------------------------------------------
  blk_STROBE_CNT : block
  begin  --
    gen_m: for idx_m in 0 to 1-1 generate
      inst_STROBE_CNT: entity work.daq_STROBE_CNT
        port map(
          pi_clock        => pi_clock,
          pi_reset        => pi_reset,
          -- to/from adapter
          pi_decoder_rd_stb => reg_rd_stb(5+idx_m),
          pi_decoder_wr_stb => reg_wr_stb(5+idx_m),
          pi_decoder_data   => reg_data_in,
          po_decoder_data   => reg_data_out_vect(5+idx_m),

          pi_reg  => pi_addrmap.STROBE_CNT(idx_m),
          po_reg  => po_addrmap.STROBE_CNT(idx_m)
        );
    end generate;--
  end block;--
  -- ---------------------------------------------------------------------------
  -- reg name: SAMPLES  reg type: SAMPLES
  -- ---------------------------------------------------------------------------
  blk_SAMPLES : block
  begin  --
    gen_m: for idx_m in 0 to 1-1 generate
      inst_SAMPLES: entity work.daq_SAMPLES
        port map(
          pi_clock        => pi_clock,
          pi_reset        => pi_reset,
          -- to/from adapter
          pi_decoder_rd_stb => reg_rd_stb(6+idx_m),
          pi_decoder_wr_stb => reg_wr_stb(6+idx_m),
          pi_decoder_data   => reg_data_in,
          po_decoder_data   => reg_data_out_vect(6+idx_m),

          pi_reg  => pi_addrmap.SAMPLES(idx_m),
          po_reg  => po_addrmap.SAMPLES(idx_m)
        );
    end generate;--
  end block;--
  -- ---------------------------------------------------------------------------
  -- reg name: DOUBLE_BUF_ENA  reg type: DOUBLE_BUF_ENA
  -- ---------------------------------------------------------------------------
  blk_DOUBLE_BUF_ENA : block
  begin  --
    inst_DOUBLE_BUF_ENA: entity work.daq_DOUBLE_BUF_ENA
      port map(
        pi_clock        => pi_clock,
        pi_reset        => pi_reset,
        -- to/from adapter
        pi_decoder_rd_stb => reg_rd_stb(7),
        pi_decoder_wr_stb => reg_wr_stb(7),
        pi_decoder_data   => reg_data_in,
        po_decoder_data   => reg_data_out_vect(7),

        pi_reg  => pi_addrmap.DOUBLE_BUF_ENA,
        po_reg  => po_addrmap.DOUBLE_BUF_ENA
      );--
  end block;--
  -- ---------------------------------------------------------------------------
  -- reg name: ACTIVE_BUF  reg type: ACTIVE_BUF
  -- ---------------------------------------------------------------------------
  blk_ACTIVE_BUF : block
  begin  --
    inst_ACTIVE_BUF: entity work.daq_ACTIVE_BUF
      port map(
        pi_clock        => pi_clock,
        pi_reset        => pi_reset,
        -- to/from adapter
        pi_decoder_rd_stb => reg_rd_stb(8),
        pi_decoder_wr_stb => reg_wr_stb(8),
        pi_decoder_data   => reg_data_in,
        po_decoder_data   => reg_data_out_vect(8),

        pi_reg  => pi_addrmap.ACTIVE_BUF,
        po_reg  => po_addrmap.ACTIVE_BUF
      );--
  end block;--
  -- ---------------------------------------------------------------------------
  -- reg name: INACTIVE_BUF_ID  reg type: INACTIVE_BUF_ID
  -- ---------------------------------------------------------------------------
  blk_INACTIVE_BUF_ID : block
  begin  --
    gen_m: for idx_m in 0 to 1-1 generate
      inst_INACTIVE_BUF_ID: entity work.daq_INACTIVE_BUF_ID
        port map(
          pi_clock        => pi_clock,
          pi_reset        => pi_reset,
          -- to/from adapter
          pi_decoder_rd_stb => reg_rd_stb(9+idx_m),
          pi_decoder_wr_stb => reg_wr_stb(9+idx_m),
          pi_decoder_data   => reg_data_in,
          po_decoder_data   => reg_data_out_vect(9+idx_m),

          pi_reg  => pi_addrmap.INACTIVE_BUF_ID(idx_m),
          po_reg  => po_addrmap.INACTIVE_BUF_ID(idx_m)
        );
    end generate;--
  end block;--
  -- ---------------------------------------------------------------------------
  -- reg name: FIFO_STATUS  reg type: FIFO_STATUS
  -- ---------------------------------------------------------------------------
  blk_FIFO_STATUS : block
  begin  --
    gen_m: for idx_m in 0 to 1-1 generate
      inst_FIFO_STATUS: entity work.daq_FIFO_STATUS
        port map(
          pi_clock        => pi_clock,
          pi_reset        => pi_reset,
          -- to/from adapter
          pi_decoder_rd_stb => reg_rd_stb(10+idx_m),
          pi_decoder_wr_stb => reg_wr_stb(10+idx_m),
          pi_decoder_data   => reg_data_in,
          po_decoder_data   => reg_data_out_vect(10+idx_m),

          pi_reg  => pi_addrmap.FIFO_STATUS(idx_m),
          po_reg  => po_addrmap.FIFO_STATUS(idx_m)
        );
    end generate;--
  end block;--
  -- ---------------------------------------------------------------------------
  -- reg name: SENT_BURST_CNT  reg type: SENT_BURST_CNT
  -- ---------------------------------------------------------------------------
  blk_SENT_BURST_CNT : block
  begin  --
    gen_m: for idx_m in 0 to 1-1 generate
      inst_SENT_BURST_CNT: entity work.daq_SENT_BURST_CNT
        port map(
          pi_clock        => pi_clock,
          pi_reset        => pi_reset,
          -- to/from adapter
          pi_decoder_rd_stb => reg_rd_stb(11+idx_m),
          pi_decoder_wr_stb => reg_wr_stb(11+idx_m),
          pi_decoder_data   => reg_data_in,
          po_decoder_data   => reg_data_out_vect(11+idx_m),

          pi_reg  => pi_addrmap.SENT_BURST_CNT(idx_m),
          po_reg  => po_addrmap.SENT_BURST_CNT(idx_m)
        );
    end generate;--
  end block;--
  -- ---------------------------------------------------------------------------
  -- reg name: TRG_DELAY_VAL  reg type: TRG_DELAY_VAL
  -- ---------------------------------------------------------------------------
  blk_TRG_DELAY_VAL : block
  begin  --
    gen_m: for idx_m in 0 to 1-1 generate
      inst_TRG_DELAY_VAL: entity work.daq_TRG_DELAY_VAL
        port map(
          pi_clock        => pi_clock,
          pi_reset        => pi_reset,
          -- to/from adapter
          pi_decoder_rd_stb => reg_rd_stb(12+idx_m),
          pi_decoder_wr_stb => reg_wr_stb(12+idx_m),
          pi_decoder_data   => reg_data_in,
          po_decoder_data   => reg_data_out_vect(12+idx_m),

          pi_reg  => pi_addrmap.TRG_DELAY_VAL(idx_m),
          po_reg  => po_addrmap.TRG_DELAY_VAL(idx_m)
        );
    end generate;--
  end block;--
  -- ---------------------------------------------------------------------------
  -- reg name: TRG_DELAY_ENA  reg type: TRG_DELAY_ENA
  -- ---------------------------------------------------------------------------
  blk_TRG_DELAY_ENA : block
  begin  --
    inst_TRG_DELAY_ENA: entity work.daq_TRG_DELAY_ENA
      port map(
        pi_clock        => pi_clock,
        pi_reset        => pi_reset,
        -- to/from adapter
        pi_decoder_rd_stb => reg_rd_stb(13),
        pi_decoder_wr_stb => reg_wr_stb(13),
        pi_decoder_data   => reg_data_in,
        po_decoder_data   => reg_data_out_vect(13),

        pi_reg  => pi_addrmap.TRG_DELAY_ENA,
        po_reg  => po_addrmap.TRG_DELAY_ENA
      );--
  end block;--
  -- ---------------------------------------------------------------------------
  -- reg name: TRG_CNT_BUF0  reg type: TRG_CNT_BUF0
  -- ---------------------------------------------------------------------------
  blk_TRG_CNT_BUF0 : block
  begin  --
    gen_m: for idx_m in 0 to 1-1 generate
      inst_TRG_CNT_BUF0: entity work.daq_TRG_CNT_BUF0
        port map(
          pi_clock        => pi_clock,
          pi_reset        => pi_reset,
          -- to/from adapter
          pi_decoder_rd_stb => reg_rd_stb(14+idx_m),
          pi_decoder_wr_stb => reg_wr_stb(14+idx_m),
          pi_decoder_data   => reg_data_in,
          po_decoder_data   => reg_data_out_vect(14+idx_m),

          pi_reg  => pi_addrmap.TRG_CNT_BUF0(idx_m),
          po_reg  => po_addrmap.TRG_CNT_BUF0(idx_m)
        );
    end generate;--
  end block;--
  -- ---------------------------------------------------------------------------
  -- reg name: TRG_CNT_BUF1  reg type: TRG_CNT_BUF1
  -- ---------------------------------------------------------------------------
  blk_TRG_CNT_BUF1 : block
  begin  --
    gen_m: for idx_m in 0 to 1-1 generate
      inst_TRG_CNT_BUF1: entity work.daq_TRG_CNT_BUF1
        port map(
          pi_clock        => pi_clock,
          pi_reset        => pi_reset,
          -- to/from adapter
          pi_decoder_rd_stb => reg_rd_stb(15+idx_m),
          pi_decoder_wr_stb => reg_wr_stb(15+idx_m),
          pi_decoder_data   => reg_data_in,
          po_decoder_data   => reg_data_out_vect(15+idx_m),

          pi_reg  => pi_addrmap.TRG_CNT_BUF1(idx_m),
          po_reg  => po_addrmap.TRG_CNT_BUF1(idx_m)
        );
    end generate;--
  end block;--
  -- ---------------------------------------------------------------------------
  -- reg name: TIMESTAMP_RST  reg type: TIMESTAMP_RST
  -- ---------------------------------------------------------------------------
  blk_TIMESTAMP_RST : block
  begin  --
    inst_TIMESTAMP_RST: entity work.daq_TIMESTAMP_RST
      port map(
        pi_clock        => pi_clock,
        pi_reset        => pi_reset,
        -- to/from adapter
        pi_decoder_rd_stb => reg_rd_stb(16),
        pi_decoder_wr_stb => reg_wr_stb(16),
        pi_decoder_data   => reg_data_in,
        po_decoder_data   => reg_data_out_vect(16),

        pi_reg  => pi_addrmap.TIMESTAMP_RST,
        po_reg  => po_addrmap.TIMESTAMP_RST
      );--
  end block;--

  -- ===========================================================================
  -- generated registers instances in regfiles 

  -- ===========================================================================
  -- Generated Meme Instances
  --
  mem_ack <= '1'; -- not used at the moment from external memories
  -- ---------------------------------------------------------------------------
  -- mem name: DAQ_TIMES_0  mem type: DAQ_TIMES_0
  -- ---------------------------------------------------------------------------
  blk_DAQ_TIMES_0 : block
  begin--
    mem_data_out_vect(0)(32-1 downto 0) <= pi_addrmap.DAQ_TIMES_0.data;--
    po_addrmap.DAQ_TIMES_0.addr <= mem_addr(12-1 downto 0);
    po_addrmap.DAQ_TIMES_0.data <= mem_data_in(32-1 downto 0);
    po_addrmap.DAQ_TIMES_0.en <= mem_stb(0);
    po_addrmap.DAQ_TIMES_0.we <= mem_we;--
  end block;
  -- ---------------------------------------------------------------------------
  -- mem name: DAQ_TIMES_1  mem type: DAQ_TIMES_1
  -- ---------------------------------------------------------------------------
  blk_DAQ_TIMES_1 : block
  begin--
    mem_data_out_vect(1)(32-1 downto 0) <= pi_addrmap.DAQ_TIMES_1.data;--
    po_addrmap.DAQ_TIMES_1.addr <= mem_addr(12-1 downto 0);
    po_addrmap.DAQ_TIMES_1.data <= mem_data_in(32-1 downto 0);
    po_addrmap.DAQ_TIMES_1.en <= mem_stb(1);
    po_addrmap.DAQ_TIMES_1.we <= mem_we;--
  end block;
  -- ---------------------------------------------------------------------------
  -- mem name: DAQ_TIMES_2  mem type: DAQ_TIMES_2
  -- ---------------------------------------------------------------------------
  blk_DAQ_TIMES_2 : block
  begin--
    mem_data_out_vect(2)(32-1 downto 0) <= pi_addrmap.DAQ_TIMES_2.data;--
    po_addrmap.DAQ_TIMES_2.addr <= mem_addr(12-1 downto 0);
    po_addrmap.DAQ_TIMES_2.data <= mem_data_in(32-1 downto 0);
    po_addrmap.DAQ_TIMES_2.en <= mem_stb(2);
    po_addrmap.DAQ_TIMES_2.we <= mem_we;--
  end block;
  -- ---------------------------------------------------------------------------

  -- ===========================================================================
  -- External Busses

end architecture;
