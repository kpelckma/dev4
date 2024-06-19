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
--! @date 2021-09-14
--! @author Cagil Gumus  <cagil.guemues@desy.de>
------------------------------------------------------------------------------
--! @brief
--! Generates triggers from various sources, capable of dividing them
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library desy;
use desy.common_types.all;

entity trigger_generation is
generic (
  G_EXT_TRG  : natural := 8 ;
  G_OUT_TRG  : natural := 12 --! used for trg_loopback size
);
port (
  pi_clock         : in std_logic;
  pi_reset         : in std_logic;
  pi_sync_sel      : in natural; --! trigger synchronization selection
  pi_source_sel    : in natural; --! select source for trigger generation
  pi_divider_value : in std_logic_vector(31 downto 0);
  pi_manual_trg    : in std_logic;
  pi_ext_trg       : in std_logic_vector(G_EXT_TRG-1 downto 0);
  pi_trg_loopback  : in std_logic_vector(G_OUT_TRG-1 downto 0);
  po_trg_cnt       : out std_logic_vector(31 downto 0); --! trigger counter for debug purposes
  po_trg           : out std_logic --! generated triggers
);
end trigger_generation;

architecture arch of trigger_generation is

  signal no_edge_trg        : std_logic_vector(G_EXT_TRG downto 0); --! Triggers needing edge detection
  signal prev_trg           : std_logic_vector(G_EXT_TRG downto 0); --! previous value for edge_trg signals
  signal edge_trg           : std_logic_vector(G_EXT_TRG downto 0); --! Edge detected manual triggers
  signal trg_sources        : std_logic_vector(G_EXT_TRG + G_OUT_TRG + 1 downto 0); --! available trigger sources that can be selected for trigger generation
  signal trg_cnt            : std_logic_vector(31 downto 0); --! used for generating the triggers
  signal selected_trg       : std_logic;
  signal output_trg         : std_logic;
  signal trg_monitoring_cnt : std_logic_vector(31 downto 0); --! used for counting/monitoring the generated output triggers
  signal trg_loopback       : std_logic_vector(G_OUT_TRG-1 downto 0);
  signal sync_sources       : std_logic_vector(G_OUT_TRG+1 downto 0); --! synch sources gnd,loopback1,loopback2,.. etc
  signal sync_sig           : std_logic; --! sync signal from selected loopback triggers
begin

  --! @brief  we can generate triggers based on application clock, manual trigger, external triggers or we can loopback
  --! any trigger channel and create trigger based on this looped trigger. loopbacked triggers can be also selected
  --!for synchronization
  --!
  --!  Input clock          --> | --------------------- |
  --!  Manual trigger(IBUS) --> |                       |
  --!  External trigger 0   --> |                       |
  --!  External trigger 1   --> | trigger generation    |--> Output Triggers
  --!  External trigger 2   --> |                       |        |
  --!  External trigger 3   --> |                       |        |
  --!  Output triggers   |----> | --------------------- |        |
  --!                    |                                       |
  --!                    |---------------------------------------|
  --!                                    (Loopback)

 --! when using loopback to generate triggers do not forget that there will be 1 clock cycle delay!
 --! user can use delays to make them trigger at the same time

  po_trg <= output_trg; --! Trigger output
  po_trg_cnt <= trg_monitoring_cnt; --! counter output

  trg_sources(0) <= '1'; --! if user gives source_sel=0 we will divide the application clock to produce
  sync_sources(0) <= '0'; --! if user gives sync_sel=0 generated trigger will not be synched (free running)
  sync_sources(pi_trg_loopback'left+1 downto 1) <= pi_trg_loopback;

  no_edge_trg <= pi_ext_trg & pi_manual_trg;

  gen_edge_detect: for k in 0 to G_EXT_TRG generate
    --! edge detection for the external trigger sources.
    proc_edge_detect: process(pi_clock)
    begin
      if rising_edge(pi_clock) then
        prev_trg(k) <= no_edge_trg(k);
        edge_trg(k) <= no_edge_trg(k) and not prev_trg(k);
      end if;
    end process;

    trg_sources(k+1) <= edge_trg(k);

  end generate;

  trg_sources(trg_sources'left downto G_EXT_TRG+2) <= pi_trg_loopback;

  --! demux to select the main trigger source
  selected_trg <= trg_sources(pi_source_sel) when rising_edge(pi_clock);
  --! demux to select the sync signal for trigger generation
  sync_sig <= sync_sources(pi_sync_sel) when rising_edge(pi_clock);

 --! division of the selected trigger
 proc_division: process(pi_clock)
 begin
   if rising_edge(pi_clock) then
     if pi_reset = '1' then
       trg_cnt <= (others => '0');
       output_trg <= '0';
     else
       output_trg <= '0';

       if sync_sig = '1' then --! avoid missing trigger that is synchronous with sync
         if selected_trg = '1' and trg_cnt >= pi_divider_value then
           output_trg <= '1';
         end if;

         trg_cnt <= (others => '0');

       elsif selected_trg = '1' then --! incoming trigger, divide
         if trg_cnt < pi_divider_value then
           trg_cnt <= std_logic_vector(unsigned(trg_cnt) + 1);
         else
           trg_cnt <= (others => '0');
           output_trg <= '1';
         end if;
       end if;
     end if;
   end if;
 end process;

  --! trigger counter
  proc_trg_cnt: process(pi_clock)
  begin
    if rising_edge(pi_clock) then
      if pi_reset = '1' then
        trg_monitoring_cnt <= (others => '0');
      elsif output_trg = '1' then
        trg_monitoring_cnt <= std_logic_vector(unsigned(trg_monitoring_cnt) + 1);
      end if;
    end if;
  end process;

end arch;
