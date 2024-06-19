-------------------------------------------------------------------------------
--          ____  _____________  __                                          --
--         / __ \/ ____/ ___/\ \/ /                 _   _   _                --
--        / / / / __/  \__ \  \  /                 / \ / \ / \               --
--       / /_/ / /___ ___/ /  / /               = ( M | S | K )=             --
--      /_____/_____//____/  /_/                   \_/ \_/ \_/               --
--                                                                           --
-------------------------------------------------------------------------------
--! @copyright Copyright 2021 DESY
--! @license   SPDX-License-Identifier: CERN-OHL-W-2.0
-------------------------------------------------------------------------------
--! @created 2022-06-21
--! @author  Cagil Gumus <cagil.guemues@desy.de>
-------------------------------------------------------------------------------
--! @description
--! Test bench for the AD56XX DAC Module w/ SPI
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

entity tb_ad56xx is
end tb_ad56xx;
 
architecture behavior of tb_ad56xx is 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
  component ad56xx
    generic(
      G_CLK_DIV       : natural := 2;   -- Clock division for SPI Communication
      G_DATA_WIDTH    : natural := 12   -- DAC bit size AD5621 => (12 bits) 
      );                                --              AD5611 => (10 bits)
                                        --              AD5601 =>  (8 bits)
    port(                              
      pi_clock     : in std_logic;
      pi_reset     : in std_logic;
      pi_data      : in std_logic_vector(G_DATA_WIDTH-1 downto 0); -- Data to be send to DAC
      pi_data_rdy  : in std_logic;      -- pi_data Ready Strobe
      po_sclk      : out std_logic;
      po_sdin      : out std_logic;
      po_sync      : out std_logic
      );
  end component;

   --Inputs
   signal pi_clock    : std_logic := '0';
   signal pi_reset    : std_logic := '0';
   signal pi_data     : std_logic_vector(11 downto 0) := (others => '0');
   signal pi_data_rdy : std_logic := '0';

    --Outputs
   signal po_sclk : std_logic;
   signal po_sdin : std_logic;
   signal po_sync : std_logic;

   -- Clock period definitions
   constant C_CLOCK_PERIOD : time := 32 ns;   --31.25 MHz 
 
begin
 
    -- Instantiate the Unit Under Test (UUT)
   uut: ad56xx port map (
      pi_clock    => pi_clock,
      pi_reset    => pi_reset,
      pi_data     => pi_data,
      pi_data_rdy => pi_data_rdy,
      po_sclk     => po_sclk,
      po_sdin     => po_sdin,
      po_sync     => po_sync
    );

   -- Clock process definitions
   proc_clk :process
   begin
        pi_clock <= '0';
        wait for C_CLOCK_PERIOD/2;
        pi_clock <= '1';
        wait for C_CLOCK_PERIOD/2;
   end process;

   -- Stimulus process
   stim_proc: process
   begin        
      
      pi_reset <= '1'; 
      -- hold reset state for 100 ns.
      wait for 100 ns;  
      pi_reset     <= '0';
      pi_data      <= "010101011111"; -- 12 bit data 
      pi_data_rdy  <= '1';
      wait for C_CLOCK_PERIOD;
      pi_data_rdy  <= '1';
      wait for C_CLOCK_PERIOD*10;

      wait;
   end process;

end;
