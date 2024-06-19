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
--! Test-bench for AD79XX Module w/ 3-wire SPI Interface
-------------------------------------------------------------------------------

library ieee;
USE ieee.std_logic_1164.ALL;

entity tb_ad79xx is
end tb_ad79xx;
 
architecture behavior of tb_ad79xx is 
 
   -- Component Declaration for the Unit Under Test (UUT)

   component ad79xx
   generic(
      G_CLK_DIV : natural := 50  -- Clock division for SPI Communication
   );
   port(
      pi_clock      : in std_logic;
      pi_reset      : in std_logic;
      po_data       : out std_logic_vector(11 downto 0); -- Data from ADC
      pi_start_conv : in std_logic; -- Start conversion flag (Active high)
      
      -- SPI Interface
      po_sclk      : out std_logic;
      pi_sdata     : in  std_logic;
      po_cs_n      : out std_logic
   );
   end component;
    

   --Inputs
   signal pi_clock : std_logic := '0';
   signal pi_reset : std_logic := '0';
   signal pi_start_conv : std_logic := '0';
   signal pi_sdata : std_logic := '0';

    --Outputs
   signal po_data : std_logic_vector(11 downto 0);
   signal po_sclk : std_logic;
   signal po_cs_n : std_logic;

   -- Clock period definitions
   constant PI_CLOCK_PERIOD : time := 20 ns;
 
begin
 
    -- Instantiate the Unit Under Test (UUT)
   uut : ad79xx 
   port map (
      pi_clock => pi_clock,
      pi_reset => pi_reset,
      po_data => po_data,
      pi_start_conv => pi_start_conv,
      po_sclk => po_sclk,
      pi_sdata => pi_sdata,
      po_cs_n => po_cs_n
   );

   -- Clock process definitions
   pi_clk_proc :process
   begin
        pi_clock <= '0';
        wait for PI_CLOCK_PERIOD/2;
        pi_clock <= '1';
        wait for PI_CLOCK_PERIOD/2;
   end process;
 
   -- Stimulus process
   stim_proc: process
   begin        
      pi_reset <= '1';
      -- hold reset state for 100 ns.
      wait for 100 ns;  
      wait for PI_CLOCK_PERIOD/2;
      pi_reset <= '0';
      wait for PI_CLOCK_PERIOD/2;
      pi_start_conv <='1';
      
      wait for 10*PI_CLOCK_PERIOD/2;
      pi_sdata <= '1';           -- Data[15]
      wait for 10*PI_CLOCK_PERIOD;    
      pi_sdata <= '1';           -- Data[14]
      pi_start_conv <='0';       -- Strobe ends
      wait for 10*PI_CLOCK_PERIOD;  
      pi_sdata <= '1';           -- Data[13]
      wait for 10*PI_CLOCK_PERIOD;
      pi_sdata <= '1';           -- Data[12]
      wait for 10*PI_CLOCK_PERIOD;
      pi_sdata <= '1';           -- Data[11]
      wait for 10*PI_CLOCK_PERIOD;
      pi_sdata <= '1';           -- Data[10]
      wait for 10*PI_CLOCK_PERIOD;
      pi_sdata <= '1';           -- Data[9]
      wait for 10*PI_CLOCK_PERIOD;
      pi_sdata <= '0';           -- Data[8]
      wait for 10*PI_CLOCK_PERIOD;
      pi_sdata <= '0';           -- Data[7]
      wait for 10*PI_CLOCK_PERIOD;
      pi_sdata <= '0';           -- Data[6]
      wait for 10*PI_CLOCK_PERIOD;
      pi_sdata <= '0';           -- Data[5]
      wait for 10*PI_CLOCK_PERIOD;
      pi_sdata <= '0';           -- Data[4]
      wait for 10*PI_CLOCK_PERIOD;
      pi_sdata <= '0';           -- Data[3]
      wait for 10*PI_CLOCK_PERIOD;
      pi_sdata <= '1';           -- Data[2]
      wait for 10*PI_CLOCK_PERIOD;
      pi_sdata <= '1';           -- Data[1]
      wait for 10*PI_CLOCK_PERIOD;
      pi_sdata <= '1';           -- Data[0]    
      wait for 10*PI_CLOCK_PERIOD;
      pi_sdata <= '1';           -- Transmision ends       
      wait for 10*PI_CLOCK_PERIOD*10;
      -- insert stimulus here 

      wait;
   end process;

END;
