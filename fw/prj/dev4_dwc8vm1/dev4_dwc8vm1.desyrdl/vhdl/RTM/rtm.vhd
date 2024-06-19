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

use work.pkg_rtm.all;

entity rtm is
  port (
    pi_clock : in std_logic;
    pi_reset : in std_logic;
    -- TOP subordinate memory mapped interface
    pi_s_reset : in std_logic := '0';
    pi_s_top   : in  t_rtm_m2s;
    po_s_top   : out t_rtm_s2m;
    -- to logic interface
    pi_addrmap : in  t_addrmap_rtm_in;
    po_addrmap : out t_addrmap_rtm_out
  );
end entity rtm;

architecture arch of rtm is

  type t_data_out is array (natural range<>) of std_logic_vector(C_DATA_WIDTH-1 downto 0) ;

  --
  signal reg_data_out_vect : t_data_out(20-1 downto 0);
  signal reg_rd_stb   : std_logic_vector(20-1 downto 0);
  signal reg_wr_stb   : std_logic_vector(20-1 downto 0);
  signal reg_data_out : std_logic_vector(C_DATA_WIDTH-1 downto 0);
  signal reg_data_in  : std_logic_vector(C_DATA_WIDTH-1 downto 0);
  --

begin

  ins_decoder_axi4l : entity work.rtm_decoder_axi4l
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
      for idx in 0 to 20-1 loop
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
    inst_ID: entity work.rtm_ID
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
    inst_VERSION: entity work.rtm_VERSION
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
  -- reg name: RF_PERMIT  reg type: RF_PERMIT
  -- ---------------------------------------------------------------------------
  blk_RF_PERMIT : block
  begin  --
    inst_RF_PERMIT: entity work.rtm_RF_PERMIT
      port map(
        pi_clock        => pi_clock,
        pi_reset        => pi_reset,
        -- to/from adapter
        pi_decoder_rd_stb => reg_rd_stb(2),
        pi_decoder_wr_stb => reg_wr_stb(2),
        pi_decoder_data   => reg_data_in,
        po_decoder_data   => reg_data_out_vect(2),

        pi_reg  => pi_addrmap.RF_PERMIT,
        po_reg  => po_addrmap.RF_PERMIT
      );--
  end block;--
  -- ---------------------------------------------------------------------------
  -- reg name: ATT_SEL  reg type: ATT_SEL
  -- ---------------------------------------------------------------------------
  blk_ATT_SEL : block
  begin  --
    inst_ATT_SEL: entity work.rtm_ATT_SEL
      port map(
        pi_clock        => pi_clock,
        pi_reset        => pi_reset,
        -- to/from adapter
        pi_decoder_rd_stb => reg_rd_stb(3),
        pi_decoder_wr_stb => reg_wr_stb(3),
        pi_decoder_data   => reg_data_in,
        po_decoder_data   => reg_data_out_vect(3),

        pi_reg  => pi_addrmap.ATT_SEL,
        po_reg  => po_addrmap.ATT_SEL
      );--
  end block;--
  -- ---------------------------------------------------------------------------
  -- reg name: ATT_VAL  reg type: ATT_VAL
  -- ---------------------------------------------------------------------------
  blk_ATT_VAL : block
  begin  --
    inst_ATT_VAL: entity work.rtm_ATT_VAL
      port map(
        pi_clock        => pi_clock,
        pi_reset        => pi_reset,
        -- to/from adapter
        pi_decoder_rd_stb => reg_rd_stb(4),
        pi_decoder_wr_stb => reg_wr_stb(4),
        pi_decoder_data   => reg_data_in,
        po_decoder_data   => reg_data_out_vect(4),

        pi_reg  => pi_addrmap.ATT_VAL,
        po_reg  => po_addrmap.ATT_VAL
      );--
  end block;--
  -- ---------------------------------------------------------------------------
  -- reg name: ATT_STATUS  reg type: ATT_STATUS
  -- ---------------------------------------------------------------------------
  blk_ATT_STATUS : block
  begin  --
    inst_ATT_STATUS: entity work.rtm_ATT_STATUS
      port map(
        pi_clock        => pi_clock,
        pi_reset        => pi_reset,
        -- to/from adapter
        pi_decoder_rd_stb => reg_rd_stb(5),
        pi_decoder_wr_stb => reg_wr_stb(5),
        pi_decoder_data   => reg_data_in,
        po_decoder_data   => reg_data_out_vect(5),

        pi_reg  => pi_addrmap.ATT_STATUS,
        po_reg  => po_addrmap.ATT_STATUS
      );--
  end block;--
  -- ---------------------------------------------------------------------------
  -- reg name: ADC_A  reg type: ADC_A
  -- ---------------------------------------------------------------------------
  blk_ADC_A : block
  begin  --
    inst_ADC_A: entity work.rtm_ADC_A
      port map(
        pi_clock        => pi_clock,
        pi_reset        => pi_reset,
        -- to/from adapter
        pi_decoder_rd_stb => reg_rd_stb(6),
        pi_decoder_wr_stb => reg_wr_stb(6),
        pi_decoder_data   => reg_data_in,
        po_decoder_data   => reg_data_out_vect(6),

        pi_reg  => pi_addrmap.ADC_A,
        po_reg  => po_addrmap.ADC_A
      );--
  end block;--
  -- ---------------------------------------------------------------------------
  -- reg name: ADC_B  reg type: ADC_B
  -- ---------------------------------------------------------------------------
  blk_ADC_B : block
  begin  --
    inst_ADC_B: entity work.rtm_ADC_B
      port map(
        pi_clock        => pi_clock,
        pi_reset        => pi_reset,
        -- to/from adapter
        pi_decoder_rd_stb => reg_rd_stb(7),
        pi_decoder_wr_stb => reg_wr_stb(7),
        pi_decoder_data   => reg_data_in,
        po_decoder_data   => reg_data_out_vect(7),

        pi_reg  => pi_addrmap.ADC_B,
        po_reg  => po_addrmap.ADC_B
      );--
  end block;--
  -- ---------------------------------------------------------------------------
  -- reg name: ADC_C  reg type: ADC_C
  -- ---------------------------------------------------------------------------
  blk_ADC_C : block
  begin  --
    inst_ADC_C: entity work.rtm_ADC_C
      port map(
        pi_clock        => pi_clock,
        pi_reset        => pi_reset,
        -- to/from adapter
        pi_decoder_rd_stb => reg_rd_stb(8),
        pi_decoder_wr_stb => reg_wr_stb(8),
        pi_decoder_data   => reg_data_in,
        po_decoder_data   => reg_data_out_vect(8),

        pi_reg  => pi_addrmap.ADC_C,
        po_reg  => po_addrmap.ADC_C
      );--
  end block;--
  -- ---------------------------------------------------------------------------
  -- reg name: ADC_D  reg type: ADC_D
  -- ---------------------------------------------------------------------------
  blk_ADC_D : block
  begin  --
    inst_ADC_D: entity work.rtm_ADC_D
      port map(
        pi_clock        => pi_clock,
        pi_reset        => pi_reset,
        -- to/from adapter
        pi_decoder_rd_stb => reg_rd_stb(9),
        pi_decoder_wr_stb => reg_wr_stb(9),
        pi_decoder_data   => reg_data_in,
        po_decoder_data   => reg_data_out_vect(9),

        pi_reg  => pi_addrmap.ADC_D,
        po_reg  => po_addrmap.ADC_D
      );--
  end block;--
  -- ---------------------------------------------------------------------------
  -- reg name: ADC_READ_ENA  reg type: ADC_READ_ENA
  -- ---------------------------------------------------------------------------
  blk_ADC_READ_ENA : block
  begin  --
    inst_ADC_READ_ENA: entity work.rtm_ADC_READ_ENA
      port map(
        pi_clock        => pi_clock,
        pi_reset        => pi_reset,
        -- to/from adapter
        pi_decoder_rd_stb => reg_rd_stb(10),
        pi_decoder_wr_stb => reg_wr_stb(10),
        pi_decoder_data   => reg_data_in,
        po_decoder_data   => reg_data_out_vect(10),

        pi_reg  => pi_addrmap.ADC_READ_ENA,
        po_reg  => po_addrmap.ADC_READ_ENA
      );--
  end block;--
  -- ---------------------------------------------------------------------------
  -- reg name: ADC_STATUS  reg type: ADC_STATUS
  -- ---------------------------------------------------------------------------
  blk_ADC_STATUS : block
  begin  --
    inst_ADC_STATUS: entity work.rtm_ADC_STATUS
      port map(
        pi_clock        => pi_clock,
        pi_reset        => pi_reset,
        -- to/from adapter
        pi_decoder_rd_stb => reg_rd_stb(11),
        pi_decoder_wr_stb => reg_wr_stb(11),
        pi_decoder_data   => reg_data_in,
        po_decoder_data   => reg_data_out_vect(11),

        pi_reg  => pi_addrmap.ADC_STATUS,
        po_reg  => po_addrmap.ADC_STATUS
      );--
  end block;--
  -- ---------------------------------------------------------------------------
  -- reg name: DACAB  reg type: DACAB
  -- ---------------------------------------------------------------------------
  blk_DACAB : block
  begin  --
    inst_DACAB: entity work.rtm_DACAB
      port map(
        pi_clock        => pi_clock,
        pi_reset        => pi_reset,
        -- to/from adapter
        pi_decoder_rd_stb => reg_rd_stb(12),
        pi_decoder_wr_stb => reg_wr_stb(12),
        pi_decoder_data   => reg_data_in,
        po_decoder_data   => reg_data_out_vect(12),

        pi_reg  => pi_addrmap.DACAB,
        po_reg  => po_addrmap.DACAB
      );--
  end block;--
  -- ---------------------------------------------------------------------------
  -- reg name: DAC_STATUS  reg type: DAC_STATUS
  -- ---------------------------------------------------------------------------
  blk_DAC_STATUS : block
  begin  --
    inst_DAC_STATUS: entity work.rtm_DAC_STATUS
      port map(
        pi_clock        => pi_clock,
        pi_reset        => pi_reset,
        -- to/from adapter
        pi_decoder_rd_stb => reg_rd_stb(13),
        pi_decoder_wr_stb => reg_wr_stb(13),
        pi_decoder_data   => reg_data_in,
        po_decoder_data   => reg_data_out_vect(13),

        pi_reg  => pi_addrmap.DAC_STATUS,
        po_reg  => po_addrmap.DAC_STATUS
      );--
  end block;--
  -- ---------------------------------------------------------------------------
  -- reg name: DAC  reg type: DAC
  -- ---------------------------------------------------------------------------
  blk_DAC : block
  begin  --
    gen_m: for idx_m in 0 to 2-1 generate
      inst_DAC: entity work.rtm_DAC
        port map(
          pi_clock        => pi_clock,
          pi_reset        => pi_reset,
          -- to/from adapter
          pi_decoder_rd_stb => reg_rd_stb(14+idx_m),
          pi_decoder_wr_stb => reg_wr_stb(14+idx_m),
          pi_decoder_data   => reg_data_in,
          po_decoder_data   => reg_data_out_vect(14+idx_m),

          pi_reg  => pi_addrmap.DAC(idx_m),
          po_reg  => po_addrmap.DAC(idx_m)
        );
    end generate;--
  end block;--
  -- ---------------------------------------------------------------------------
  -- reg name: EXT_INTERLOCK  reg type: EXT_INTERLOCK
  -- ---------------------------------------------------------------------------
  blk_EXT_INTERLOCK : block
  begin  --
    inst_EXT_INTERLOCK: entity work.rtm_EXT_INTERLOCK
      port map(
        pi_clock        => pi_clock,
        pi_reset        => pi_reset,
        -- to/from adapter
        pi_decoder_rd_stb => reg_rd_stb(16),
        pi_decoder_wr_stb => reg_wr_stb(16),
        pi_decoder_data   => reg_data_in,
        po_decoder_data   => reg_data_out_vect(16),

        pi_reg  => pi_addrmap.EXT_INTERLOCK,
        po_reg  => po_addrmap.EXT_INTERLOCK
      );--
  end block;--
  -- ---------------------------------------------------------------------------
  -- reg name: HYT271_TEMP  reg type: HYT271_TEMP
  -- ---------------------------------------------------------------------------
  blk_HYT271_TEMP : block
  begin  --
    inst_HYT271_TEMP: entity work.rtm_HYT271_TEMP
      port map(
        pi_clock        => pi_clock,
        pi_reset        => pi_reset,
        -- to/from adapter
        pi_decoder_rd_stb => reg_rd_stb(17),
        pi_decoder_wr_stb => reg_wr_stb(17),
        pi_decoder_data   => reg_data_in,
        po_decoder_data   => reg_data_out_vect(17),

        pi_reg  => pi_addrmap.HYT271_TEMP,
        po_reg  => po_addrmap.HYT271_TEMP
      );--
  end block;--
  -- ---------------------------------------------------------------------------
  -- reg name: HYT271_HUMI  reg type: HYT271_HUMI
  -- ---------------------------------------------------------------------------
  blk_HYT271_HUMI : block
  begin  --
    inst_HYT271_HUMI: entity work.rtm_HYT271_HUMI
      port map(
        pi_clock        => pi_clock,
        pi_reset        => pi_reset,
        -- to/from adapter
        pi_decoder_rd_stb => reg_rd_stb(18),
        pi_decoder_wr_stb => reg_wr_stb(18),
        pi_decoder_data   => reg_data_in,
        po_decoder_data   => reg_data_out_vect(18),

        pi_reg  => pi_addrmap.HYT271_HUMI,
        po_reg  => po_addrmap.HYT271_HUMI
      );--
  end block;--
  -- ---------------------------------------------------------------------------
  -- reg name: HYT271_READ_ENA  reg type: HYT271_READ_ENA
  -- ---------------------------------------------------------------------------
  blk_HYT271_READ_ENA : block
  begin  --
    inst_HYT271_READ_ENA: entity work.rtm_HYT271_READ_ENA
      port map(
        pi_clock        => pi_clock,
        pi_reset        => pi_reset,
        -- to/from adapter
        pi_decoder_rd_stb => reg_rd_stb(19),
        pi_decoder_wr_stb => reg_wr_stb(19),
        pi_decoder_data   => reg_data_in,
        po_decoder_data   => reg_data_out_vect(19),

        pi_reg  => pi_addrmap.HYT271_READ_ENA,
        po_reg  => po_addrmap.HYT271_READ_ENA
      );--
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
