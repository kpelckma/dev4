-------------------------------------------------------------------------------
--          ____  _____________  __                                          --
--         / __ \/ ____/ ___/\ \/ /                 _   _   _                --
--        / / / / __/  \__ \  \  /                 / \ / \ / \               --
--       / /_/ / /___ ___/ /  / /               = ( M | S | K )=             --
--      /_____/_____//____/  /_/                   \_/ \_/ \_/               --
--                                                                           --
-------------------------------------------------------------------------------
-- $Header: https://mskllrfredminesrv.desy.de/svn/utca_firmware_framework/trunk/modules/MISC/TIMING/tb/TB_ENT_TIMING.vhd 3665 2020-03-24 18:42:21Z mbuechl $
-------------------------------------------------------------------------------
--! @file   TB_ENT_TIMING.vhd
--! @brief  Testbench for Trigger generation entity on TIMING Module
--! @details This entity is responsible from generating trigger from app clock or from external trigger and it can divide them un run time
--! $Date: 2020-03-24 19:42:21 +0100 (Di, 24 Mär 2020) $
--! $Revision: 3665 $
--! $URL: https://mskllrfredminesrv.desy.de/svn/utca_firmware_framework/trunk/modules/MISC/TIMING/tb/TB_ENT_TIMING.vhd $
-------------------------------------------------------------------------------

library ieee;
library work;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.all; 
use work.PKG_TYPES.all;
use work.math_basic.all;

ENTITY TB_ENT_TIMING IS
END TB_ENT_TIMING;

ARCHITECTURE behavior OF TB_ENT_TIMING IS 

--! Simulation related generics
constant G_OUTPUT_TRG : natural := 8;  --! Total number of trigger outputs
constant G_EXT_TRG    : natural := 8;   --! Number of external triggers

--Inputs
signal pi_clk            : std_logic := '0';
signal pi_reset          : std_logic := '0';
signal pi_sync_sel        : T_NaturalArray(G_OUTPUT_TRG-1 downto 0);
signal pi_manual_trg      : std_logic_vector(G_OUTPUT_TRG-1 downto 0) := (others => '0');
signal pi_enable         : std_logic_vector(G_OUTPUT_TRG-1 downto 0) := (others => '0');
signal pi_source_sel     : T_NaturalArray(G_OUTPUT_TRG-1 downto 0) := (others => 0);
signal divider_value  : T_32BitArray(G_OUTPUT_TRG-1 downto 0) := (others => (others => '0'));
signal pi_ext_trg        : std_logic_vector(G_EXT_TRG-1 downto 0) := (others => '0');
signal delay_enable   : std_logic_vector(G_OUTPUT_TRG-1 downto 0);
signal delay_value    : T_32BitArray(G_OUTPUT_TRG-1 downto 0);

--Outputs
signal trg_cnt          : T_32BitArray(G_OUTPUT_TRG-1 downto 0);
signal l_trg          : std_logic_vector(G_OUTPUT_TRG-1 downto 0);
signal out_trg          : std_logic_vector(G_OUTPUT_TRG-1 downto 0);
signal l_delayed_trg  : std_logic_vector(G_OUTPUT_TRG-1 downto 0);
signal po_trg              : std_logic_vector(G_OUTPUT_TRG-1 downto 0);

-- Clock period definitions
constant pi_clk_period  : time := 20 ns;  -- 100 MHz

-- Simulation related signal

BEGIN

    -- =================================================================================================================================
    --! Generating trigger channels
    GEN_TRG_CHANNELS : for I in 0 to G_OUTPUT_TRG-1 generate  -- Loops on all trigger channels
      
      out_trg(I) <= l_trg(I) when delay_enable(I) = '0' else l_delayed_trg(I);
      po_trg(I) <= out_trg(I) when pi_enable(I)='1' else '0'; --! Output enable switch.
      
      --! Trigger generation for 1 channel
      INST_TRG_GEN: entity work.trigger_generation
      generic map(
        G_EXT_TRG       => G_EXT_TRG,
        G_OUTPUT_TRG    => G_OUTPUT_TRG
      )
      port map (
        pi_clock         => pi_clk,
        pi_reset         => pi_reset,
        pi_sync_sel      => pi_sync_sel(I),
        pi_manual_trg    => pi_manual_trg(I),
        pi_source_sel    => pi_source_sel(I),
        pi_divider_value => divider_value(I),
        pi_ext_trg       => pi_ext_trg,
        pi_trg_loopback  => out_trg, --! Generated triggers loops back
        po_trg_cnt       => trg_cnt(I),
        po_trg           => l_trg(I)
      );
 
      INST_TRIGGER_DELAY : entity work.trg_dly
      generic map (
        G_COUNT_DELAYED_TRG => 1  --! Because we are looping through each channel
      )
      port map (
        pi_clk             => pi_clk,
        pi_trg_main        => l_trg(I),
        pi_delay_val(0)    => delay_value(I),
        po_trg_delayed(0)  => l_delayed_trg(I)
      );
 
    end generate;
  
  -- Clock process definitions
  pi_clk_process :process
  begin
    pi_clk <= '0';
    wait for pi_clk_period/2;
    pi_clk <= '1';
    wait for pi_clk_period/2;
  end process;
 
  stim_main_story: process
  begin
     
    pi_reset <= '1'; 
    report "Hard reseted all" severity note;
    wait for 5*pi_clk_period;
    pi_reset <= '0';  
    report "deasserted all resets" severity note;
    wait for 5*pi_clk_period;
    wait until rising_edge(pi_clk);

    report "Selecting sources for each trigger channel" severity note;
    -- 0 -> App Clock
    -- 1 -> Manual trigger
    -- 2 -> External Trigger 0
    -- 3 -> External Trigger 1
    -- 4 -> External Trigger 2
    -- 5 -> External Trigger 3
    -- 6 -> External Trigger 4
    -- 7 -> External Trigger 5
    -- 8 -> External Trigger 6
    -- 9 -> External Trigger 7
    -- 10 -> Trigger Ch0 
    -- 11 -> Trigger Ch1 
    -- 12 -> Trigger Ch2 
    -- 13 -> Trigger Ch3 
    -- 14 -> Trigger Ch4
    -- 15 -> Trigger Ch5 
    -- 16 -> Trigger Ch6
    -- 17 -> Trigger Ch7 
 
   
    pi_source_sel(0) <= 0;
    pi_source_sel(1) <= 0;
    pi_source_sel(2) <= 0;
    pi_source_sel(3) <= 1;
    pi_source_sel(4) <= 0;
    pi_source_sel(5) <= 0;
    pi_source_sel(6) <= 0;
    pi_source_sel(7) <= 11;
    
        report "Selecting sync sources for each trigger channel" severity note;
    -- 0 -> No sync
    -- 1 -> Trigger Ch0 
    -- 2 -> Trigger Ch1 
    -- 3 -> Trigger Ch2 
    -- 4 -> Trigger Ch3 
    -- 5 -> Trigger Ch4
    -- 6 -> Trigger Ch5 
    -- 7 -> Trigger Ch6
    -- 8 -> Trigger Ch7 
    -- 9 -> Trigger Ch8  
    
    pi_sync_sel(1) <= 1; --! Choosing Channel 0 as sync
    
    
    report "Choosing the division value" severity note;
    divider_value(0) <= std_logic_vector(to_unsigned(100,32)); --! Trigger
    divider_value(1) <= std_logic_vector(to_unsigned(8,32));   --! Strobe
    divider_value(2) <= std_logic_vector(to_unsigned(1,32));   --! Dependent Strobe
    divider_value(3) <= std_logic_vector(to_unsigned(0,32));
    divider_value(4) <= std_logic_vector(to_unsigned(4,32));
    divider_value(5) <= std_logic_vector(to_unsigned(5,32));
    divider_value(6) <= std_logic_vector(to_unsigned(6,32));
    divider_value(7) <= std_logic_vector(to_unsigned(0,32));
           
    delay_enable(0) <= '0';
    delay_enable(1) <= '1';
    delay_enable(2) <= '0';
    delay_enable(3) <= '0';
    delay_enable(4) <= '0';
    delay_enable(5) <= '0';
    delay_enable(6) <= '0';
    delay_enable(7) <= '0';
    
    delay_value(0) <= std_logic_vector(to_unsigned(0,32));
    delay_value(1) <= std_logic_vector(to_unsigned(1,32));
    delay_value(2) <= std_logic_vector(to_unsigned(0,32));
    delay_value(3) <= std_logic_vector(to_unsigned(0,32));
    delay_value(4) <= std_logic_vector(to_unsigned(0,32));
    delay_value(5) <= std_logic_vector(to_unsigned(0,32));
    delay_value(6) <= std_logic_vector(to_unsigned(0,32));
    delay_value(7) <= std_logic_vector(to_unsigned(0,32));
    
    wait for 5*pi_clk_period;
    report "Enabling trigger outputs" severity note;
    --! Enabling all outputs
    pi_enable(0) <= '1';
    pi_enable(1) <= '1';
    pi_enable(2) <= '1';
    pi_enable(3) <= '1';
    pi_enable(4) <= '0';
    pi_enable(5) <= '0';
    pi_enable(6) <= '0';
    pi_enable(7) <= '0';
    
    wait for 5*pi_clk_period;
    pi_manual_trg <= (others => '1');
    wait for 5*pi_clk_period;
    pi_manual_trg <= (others => '0');
    wait for 5*pi_clk_period;
    pi_manual_trg <= (others => '1');
    wait for 5*pi_clk_period;
    pi_manual_trg <= (others => '0');
    wait;
  end process;  
  

END;

