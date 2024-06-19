------------------------------------------------------------------------------
--          ____  _____________  __                                         --
--         / __ \/ ____/ ___/\ \/ /                 _   _   _               --
--        / / / / __/  \__ \  \  /                 / \ / \ / \              --
--       / /_/ / /___ ___/ /  / /               = ( M | S | K )=            --
--      /_____/_____//____/  /_/                   \_/ \_/ \_/              --
--                                                                          --
------------------------------------------------------------------------------
-- @copyright Copyright 2021 DESY
-- SPDX-License-Identifier: CERN-OHL-W-2.0
------------------------------------------------------------------------------
-- @date 2021-09-14
-- @author Cagil Gumus  <cagil.guemues@desy.de>
------------------------------------------------------------------------------
-- @brief
-- Top of TIMING Module
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library desyrdl;
use desyrdl.pkg_TIMING.all;

library desy;
use desy.common_types.all;
use desy.common_numarray.all;

entity timing_top is
  generic (
    G_OUT_TRG : natural := 12;   -- total number of output trigger channels
    G_EXT_TRG : natural := 8     -- total number of external triggers
  );
  port(
    pi_clock : in std_logic;
    pi_reset : in std_logic;

    -- Register access bus
    pi_s_reg_reset : in  std_logic;
    pi_s_reg_if : in  t_timing_m2s;
    po_s_reg_if : out t_timing_s2m;

    pi_ext_trg  : in std_logic_vector(G_EXT_TRG-1 downto 0);      -- external trigger input
    po_trg      : out std_logic_vector(G_OUT_TRG-1 downto 0)   -- generated trigger channels
  );
end timing_top;

architecture behavioral of timing_top is

  -- Showing how this module is configured through the ID register. (So far it is only G_OUT_TRG and G_EXT_TRG
  constant C_CONF_ID : std_logic_vector(31 downto 0) := x"0000" & std_logic_vector(to_unsigned(G_EXT_TRG, 8)) & std_logic_vector(to_unsigned(G_OUT_TRG, 8));

  -- General signals--------------------------------------------------------------
  signal trg_cnt        : t_32b_slv_vector(G_OUT_TRG-1 downto 0);
  signal ext_trg_cnt    : t_32b_slv_vector(G_EXT_TRG-1 downto 0);
  signal enable         : std_logic_vector(G_OUT_TRG-1 downto 0); -- output enable
  signal source_sel     : t_natural_vector(G_OUT_TRG-1 downto 0);
  signal sync_sel       : t_natural_vector(G_OUT_TRG-1 downto 0); -- select synchronization source
  signal divider_value  : t_32b_slv_vector(G_OUT_TRG-1 downto 0);
  signal delay_enable   : std_logic_vector(G_OUT_TRG-1 downto 0);
  signal delay_value    : t_32b_slv_vector(G_OUT_TRG-1 downto 0);
  signal manual_trg_str : std_logic_vector(G_OUT_TRG-1 downto 0); -- Manual triggering strobe from IBUS
  signal manual_trg     : std_logic_vector(G_OUT_TRG-1 downto 0); -- Manual triggering from IBUS

   -- DesyRDL related signals
   signal addrmap_i : t_addrmap_timing_in;
   signal addrmap_o : t_addrmap_timing_out;
begin

  --========================--
  -- DesyRDL Instance
  -- (Register Access)
  --========================--
  ins_timing_desyrdl : entity desyrdl.timing
  port map (
    pi_clock     => pi_clock,
    pi_reset     => pi_s_reg_reset,
    pi_s_top     => pi_s_reg_if,
    po_s_top     => po_s_reg_if,
    pi_addrmap   => addrmap_i,
    po_addrmap   => addrmap_o
  );

  addrmap_i.ID.data.data <= C_CONF_ID;

  enable <= addrmap_o.ENABLE.data.data;

  gen_trg_param : for i in 0 to G_OUT_TRG-1 generate
    addrmap_i.TRIGGER_CNT(i).data.data <= trg_cnt(i);
    addrmap_i.EXT_TRIGGER_CNT(i).data.data <= ext_trg_cnt(i);

    source_sel(i)    <= to_integer(unsigned(addrmap_o.SOURCE_SEL(i).data.data)) when rising_edge(pi_clock);
    sync_sel(i)      <= to_integer(unsigned(addrmap_o.SYNC_SEL(i).data.data)) when rising_edge(pi_clock);
    divider_value(i) <= addrmap_o.DIVIDER_VALUE(i).data.data;
    delay_enable     <= addrmap_o.DELAY_ENABLE.data.data;
    delay_value(i)   <= addrmap_o.DELAY_VALUE(i).data.data;
    manual_trg(i)    <= addrmap_o.MANUAL_TRG(i).data.data(0) and addrmap_o.MANUAL_TRG(i).data.swmod; -- See SystemRDL V2.0 documentation page 49 for more info on
                                                            -- swmod property
  end generate;

  --============================================================================
  -- Counting the external trigger for debugging reasons
  --============================================================================
  gen_ext_trg_cnt : for i in 0 to G_EXT_TRG-1 generate
    signal ls_ext_trg_prev : std_logic;
  begin

    -- Assuming pi_ext_trg is synced to pi_clock_domain!
    -- count only rising edge
    process(pi_clock)
    begin
      if rising_edge(pi_clock) then
        if pi_reset = '1' then
          ext_trg_cnt(i)  <= (others=>'0');
          ls_ext_trg_prev <= '0';
        else
          ls_ext_trg_prev <= pi_ext_trg(i) ;
          if pi_ext_trg(i) = '1' and ls_ext_trg_prev = '0' then
            ext_trg_cnt(i) <= std_logic_vector(unsigned(ext_trg_cnt(i)) + 1);
          end if;
        end if;
      end if;
    end process;
  end generate;

  --============================================================================
  -- main trigger generation components
  --============================================================================
  blk_trigger_generation : block
    signal l_triggers          : std_logic_vector(G_OUT_TRG-1 downto 0); -- generated trigger channel w/o delay
    signal l_out_triggers      : std_logic_vector(G_OUT_TRG-1 downto 0); -- triggers going to output
    signal l_delayed_triggers  : std_logic_vector(G_OUT_TRG-1 downto 0); -- generated delayed trigger channel
  begin

    -- loop and create trigger channels
    gen_trg_channels: for i in 0 to G_OUT_TRG-1 generate  -- loops on all trigger channels

      l_out_triggers(i) <= l_triggers(i) when delay_enable(i) = '0' else l_delayed_triggers(i);
      -- po_trg(i) <= l_out_triggers(i) when enable(i)='1' else '0';
      prs_trg_reg: process(pi_clock)
      begin
        if rising_edge(pi_clock) then
          if enable(i) = '1' then
            po_trg(i) <= l_out_triggers(i);
          else
            po_trg(i) <= '0';
          end if;
        end if;
      end process prs_trg_reg;

      -- trigger generation
      ins_trg_gen: entity work.trigger_generation
      generic map(
        G_EXT_TRG   => G_EXT_TRG,
        G_OUT_TRG   => G_OUT_TRG
      )
      port map (
        pi_clock         => pi_clock,
        pi_reset         => pi_reset,
        pi_sync_sel      => sync_sel(i),
        pi_source_sel    => source_sel(i),
        pi_divider_value => divider_value(i),
        pi_manual_trg    => manual_trg(i),
        pi_ext_trg       => pi_ext_trg,
        pi_trg_loopback  => l_out_triggers,  -- generated triggers can be used again to source different trg channels
        po_trg_cnt       => trg_cnt(i),
        po_trg           => l_triggers(i)
      );

      ins_trigger_delay : entity desy.trigger_delay
      generic map (
        g_count_delayed_trg => 1
      )
      port map (
        pi_clock              => pi_clock,
        pi_main_trigger       => l_triggers(i),
        pi_delay_val(0)       => delay_value(i),
        po_delayed_trigger(0) => l_delayed_triggers(i)
      );

    end generate;
  end block;

end behavioral;
