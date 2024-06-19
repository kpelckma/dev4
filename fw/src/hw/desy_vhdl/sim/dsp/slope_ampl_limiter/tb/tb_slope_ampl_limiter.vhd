-------------------------------------------------------------------------------
--          ____  _____________  __                                          --
--         / __ \/ ____/ ___/\ \/ /                 _   _   _                --
--        / / / / __/  \__ \  \  /                 / \ / \ / \               --
--       / /_/ / /___ ___/ /  / /               = ( M | S | K )=             --
--      /_____/_____//____/  /_/                   \_/ \_/ \_/               --
--                                                                           --
-------------------------------------------------------------------------------
--! @copyright Copyright 2021 DESY
--! SPDX-License-Identifier: CERN-OHL-W-2.0
-------------------------------------------------------------------------------
--! @date 2022-02-22
--! @author Shweta Prasad <shweta.prasad@desy.de>
-------------------------------------------------------------------------------
--! @brief
--! This is a test-bench for amplitude limiter.
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

use ieee.numeric_std.all;
use ieee.math_real.all;

------------------------------------------------------------------------------------------------------------------------

entity tb_slope_ampl_limiter is

end entity tb_slope_ampl_limiter;

------------------------------------------------------------------------------------------------------------------------

architecture behavior of tb_slope_ampl_limiter is

  -- component generics
  constant g_data_width : natural := 18;

  -- component ports
  signal pi_clock          : std_logic:= '1';
  signal pi_slope_l_enable : std_logic:= '1';
  signal pi_slope_limit    : std_logic_vector(g_data_width-1 downto 0);
  signal pi_valid          : std_logic:= '0';
  signal pi_data           : std_logic_vector(g_data_width-1 downto 0);
  signal po_valid          : std_logic;
  signal po_data           : std_logic_vector(g_data_width-1 downto 0);
  signal pi_ampl_limit     : std_logic_vector(g_data_width-1 downto 0);
  signal pi_ampl_l_enable  : std_logic:= '1';

begin  -- architecture behavior

  -- component instantiation
  DUT: entity work.slope_ampl_limiter_limiter
    generic map (
      g_data_width      =>  g_data_width
    )
    port map (
      pi_clock          =>  pi_clock,
      pi_slope_l_enable =>  pi_slope_l_enable,
      pi_slope_limit    =>  pi_slope_limit,
      pi_ampl_limit     =>  pi_ampl_limit,      
      pi_valid          =>  pi_valid,
      pi_data           =>  pi_data,
      po_valid          =>  po_valid,
      po_data           =>  po_data,
      pi_ampl_l_enable  =>  pi_ampl_l_enable
    );

  pi_clock <= not pi_clock after 5 ns ;


  pi_valid <= not pi_valid when rising_edge(pi_clock);
  
  -- waveform generation
  WaveGen_Proc: process
  begin
    
    pi_data  <= std_logic_vector(to_signed(0,18));

    wait until rising_edge(pi_clock);
    pi_slope_limit <= std_logic_vector(to_signed(200,18));
    pi_ampl_limit <= std_logic_vector(to_signed(300,18));     

    wait for 100 ns ;
    wait until rising_edge(pi_clock);
    pi_data <= std_logic_vector(to_signed(1000,18));

    wait for 100 ns ;
    wait until rising_edge(pi_clock);
    pi_data <= std_logic_vector(to_signed(500,18));
    
    wait for 100 ns ;
    wait until rising_edge(pi_clock);
    pi_data <= std_logic_vector(to_signed(0,18));
    
    wait for 100 ns ;
    wait until rising_edge(pi_clock);
    pi_data <= std_logic_vector(to_signed(-800,18));
    
    wait for 1000 ns ;
    wait until rising_edge(pi_clock);
    pi_data <= std_logic_vector(to_signed(-500,18));

    wait ;
  end process WaveGen_Proc;
  
end architecture behavior;

------------------------------------------------------------------------------------------------------------------------
