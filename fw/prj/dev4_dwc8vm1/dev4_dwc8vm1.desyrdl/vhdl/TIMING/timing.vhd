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

use work.pkg_timing.all;

entity timing is
  port (
    pi_clock : in std_logic;
    pi_reset : in std_logic;
    -- TOP subordinate memory mapped interface
    pi_s_reset : in std_logic := '0';
    pi_s_top   : in  t_timing_m2s;
    po_s_top   : out t_timing_s2m;
    -- to logic interface
    pi_addrmap : in  t_addrmap_timing_in;
    po_addrmap : out t_addrmap_timing_out
  );
end entity timing;

architecture arch of timing is

  type t_data_out is array (natural range<>) of std_logic_vector(C_DATA_WIDTH-1 downto 0) ;

  --
  signal reg_data_out_vect : t_data_out(30-1 downto 0);
  signal reg_rd_stb   : std_logic_vector(30-1 downto 0);
  signal reg_wr_stb   : std_logic_vector(30-1 downto 0);
  signal reg_data_out : std_logic_vector(C_DATA_WIDTH-1 downto 0);
  signal reg_data_in  : std_logic_vector(C_DATA_WIDTH-1 downto 0);
  --

begin

  ins_decoder_axi4l : entity work.timing_decoder_axi4l
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
    pi_s_reset  => pi_s_reset,
    pi_s_top    => pi_s_top,
    po_s_top    => po_s_top
  );
  --
  prs_reg_rd_mux: process(pi_clock)
  begin
    if rising_edge(pi_clock) then
      for idx in 0 to 30-1 loop
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
    inst_ID: entity work.timing_ID
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
    inst_VERSION: entity work.timing_VERSION
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
    inst_ENABLE: entity work.timing_ENABLE
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
  -- reg name: SOURCE_SEL  reg type: SOURCE_SEL
  -- ---------------------------------------------------------------------------
  blk_SOURCE_SEL : block
  begin  --
    gen_m: for idx_m in 0 to 3-1 generate
      inst_SOURCE_SEL: entity work.timing_SOURCE_SEL
        port map(
          pi_clock        => pi_clock,
          pi_reset        => pi_reset,
          -- to/from adapter
          pi_decoder_rd_stb => reg_rd_stb(3+idx_m),
          pi_decoder_wr_stb => reg_wr_stb(3+idx_m),
          pi_decoder_data   => reg_data_in,
          po_decoder_data   => reg_data_out_vect(3+idx_m),

          pi_reg  => pi_addrmap.SOURCE_SEL(idx_m),
          po_reg  => po_addrmap.SOURCE_SEL(idx_m)
        );
    end generate;--
  end block;--
  -- ---------------------------------------------------------------------------
  -- reg name: SYNC_SEL  reg type: SYNC_SEL
  -- ---------------------------------------------------------------------------
  blk_SYNC_SEL : block
  begin  --
    gen_m: for idx_m in 0 to 3-1 generate
      inst_SYNC_SEL: entity work.timing_SYNC_SEL
        port map(
          pi_clock        => pi_clock,
          pi_reset        => pi_reset,
          -- to/from adapter
          pi_decoder_rd_stb => reg_rd_stb(6+idx_m),
          pi_decoder_wr_stb => reg_wr_stb(6+idx_m),
          pi_decoder_data   => reg_data_in,
          po_decoder_data   => reg_data_out_vect(6+idx_m),

          pi_reg  => pi_addrmap.SYNC_SEL(idx_m),
          po_reg  => po_addrmap.SYNC_SEL(idx_m)
        );
    end generate;--
  end block;--
  -- ---------------------------------------------------------------------------
  -- reg name: DIVIDER_VALUE  reg type: DIVIDER_VALUE
  -- ---------------------------------------------------------------------------
  blk_DIVIDER_VALUE : block
  begin  --
    gen_m: for idx_m in 0 to 3-1 generate
      inst_DIVIDER_VALUE: entity work.timing_DIVIDER_VALUE
        port map(
          pi_clock        => pi_clock,
          pi_reset        => pi_reset,
          -- to/from adapter
          pi_decoder_rd_stb => reg_rd_stb(9+idx_m),
          pi_decoder_wr_stb => reg_wr_stb(9+idx_m),
          pi_decoder_data   => reg_data_in,
          po_decoder_data   => reg_data_out_vect(9+idx_m),

          pi_reg  => pi_addrmap.DIVIDER_VALUE(idx_m),
          po_reg  => po_addrmap.DIVIDER_VALUE(idx_m)
        );
    end generate;--
  end block;--
  -- ---------------------------------------------------------------------------
  -- reg name: TRIGGER_CNT  reg type: TRIGGER_CNT
  -- ---------------------------------------------------------------------------
  blk_TRIGGER_CNT : block
  begin  --
    gen_m: for idx_m in 0 to 3-1 generate
      inst_TRIGGER_CNT: entity work.timing_TRIGGER_CNT
        port map(
          pi_clock        => pi_clock,
          pi_reset        => pi_reset,
          -- to/from adapter
          pi_decoder_rd_stb => reg_rd_stb(12+idx_m),
          pi_decoder_wr_stb => reg_wr_stb(12+idx_m),
          pi_decoder_data   => reg_data_in,
          po_decoder_data   => reg_data_out_vect(12+idx_m),

          pi_reg  => pi_addrmap.TRIGGER_CNT(idx_m),
          po_reg  => po_addrmap.TRIGGER_CNT(idx_m)
        );
    end generate;--
  end block;--
  -- ---------------------------------------------------------------------------
  -- reg name: EXT_TRIGGER_CNT  reg type: EXT_TRIGGER_CNT
  -- ---------------------------------------------------------------------------
  blk_EXT_TRIGGER_CNT : block
  begin  --
    gen_m: for idx_m in 0 to 8-1 generate
      inst_EXT_TRIGGER_CNT: entity work.timing_EXT_TRIGGER_CNT
        port map(
          pi_clock        => pi_clock,
          pi_reset        => pi_reset,
          -- to/from adapter
          pi_decoder_rd_stb => reg_rd_stb(15+idx_m),
          pi_decoder_wr_stb => reg_wr_stb(15+idx_m),
          pi_decoder_data   => reg_data_in,
          po_decoder_data   => reg_data_out_vect(15+idx_m),

          pi_reg  => pi_addrmap.EXT_TRIGGER_CNT(idx_m),
          po_reg  => po_addrmap.EXT_TRIGGER_CNT(idx_m)
        );
    end generate;--
  end block;--
  -- ---------------------------------------------------------------------------
  -- reg name: DELAY_ENABLE  reg type: DELAY_ENABLE
  -- ---------------------------------------------------------------------------
  blk_DELAY_ENABLE : block
  begin  --
    inst_DELAY_ENABLE: entity work.timing_DELAY_ENABLE
      port map(
        pi_clock        => pi_clock,
        pi_reset        => pi_reset,
        -- to/from adapter
        pi_decoder_rd_stb => reg_rd_stb(23),
        pi_decoder_wr_stb => reg_wr_stb(23),
        pi_decoder_data   => reg_data_in,
        po_decoder_data   => reg_data_out_vect(23),

        pi_reg  => pi_addrmap.DELAY_ENABLE,
        po_reg  => po_addrmap.DELAY_ENABLE
      );--
  end block;--
  -- ---------------------------------------------------------------------------
  -- reg name: DELAY_VALUE  reg type: DELAY_VALUE
  -- ---------------------------------------------------------------------------
  blk_DELAY_VALUE : block
  begin  --
    gen_m: for idx_m in 0 to 3-1 generate
      inst_DELAY_VALUE: entity work.timing_DELAY_VALUE
        port map(
          pi_clock        => pi_clock,
          pi_reset        => pi_reset,
          -- to/from adapter
          pi_decoder_rd_stb => reg_rd_stb(24+idx_m),
          pi_decoder_wr_stb => reg_wr_stb(24+idx_m),
          pi_decoder_data   => reg_data_in,
          po_decoder_data   => reg_data_out_vect(24+idx_m),

          pi_reg  => pi_addrmap.DELAY_VALUE(idx_m),
          po_reg  => po_addrmap.DELAY_VALUE(idx_m)
        );
    end generate;--
  end block;--
  -- ---------------------------------------------------------------------------
  -- reg name: MANUAL_TRG  reg type: MANUAL_TRG
  -- ---------------------------------------------------------------------------
  blk_MANUAL_TRG : block
  begin  --
    gen_m: for idx_m in 0 to 3-1 generate
      inst_MANUAL_TRG: entity work.timing_MANUAL_TRG
        port map(
          pi_clock        => pi_clock,
          pi_reset        => pi_reset,
          -- to/from adapter
          pi_decoder_rd_stb => reg_rd_stb(27+idx_m),
          pi_decoder_wr_stb => reg_wr_stb(27+idx_m),
          pi_decoder_data   => reg_data_in,
          po_decoder_data   => reg_data_out_vect(27+idx_m),

          pi_reg  => pi_addrmap.MANUAL_TRG(idx_m),
          po_reg  => po_addrmap.MANUAL_TRG(idx_m)
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

end architecture;
