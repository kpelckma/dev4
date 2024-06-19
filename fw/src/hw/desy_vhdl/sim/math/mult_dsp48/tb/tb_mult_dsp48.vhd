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
--! @date 2021-12-09
--! @author Shweta Prasad <shweta.prasad@desy.de>
-------------------------------------------------------------------------------
--! @brief
--! This is a test-bench for pipelined NXM multiplier with 6 pipelined stages using dsp48.
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all; 
library std;
use std.textio.all;
 
ENTITY tb_mult_dsp48 IS
END tb_mult_dsp48;
 
ARCHITECTURE behavior OF tb_mult_dsp48 IS   
   -- component generics
   constant g_a_data_width  : natural := 32;
   constant g_b_data_width  : natural := 32;

   -- component ports
   signal pi_clock : std_logic := '1';
   signal pi_reset : std_logic := '0';
   signal pi_data_a : std_logic_vector(31 downto 0) := (others => '0');
   signal pi_data_b : std_logic_vector(31 downto 0) := (others => '0');
   signal po_mult : std_logic_vector(63 downto 0);
   constant A_INPUT_VECTOR : string  := "a_input.txt";
   constant B_INPUT_VECTOR : string  := "b_input.txt";   
   constant MULT_OUT_VECTOR : string  := "pipelined_mult_out.txt";  
   signal mult_out : std_logic_vector(63 downto 0);
 
BEGIN

  -- component instantiation 
    DUT: entity work.mult_dsp48
    generic map (
      g_a_data_width  => g_a_data_width,
      g_b_data_width  => g_b_data_width
         )
    port map (
          pi_clock => pi_clock,
          pi_reset => pi_reset,
          pi_data_a => pi_data_a,
          pi_data_b => pi_data_b,
          po_mult => po_mult
        );
        
  -- clock generation
   pi_clock <= not pi_clock after 5 ns;

---------------------for 32x32 Test--------------------------
   
  -- Reading the input data from text file to pi_data_a
   stim_proc_a_array: process
    file f_inp    : text;
    variable v_file_status  : file_open_status;
    variable v_line         : line;
    variable v_line_count : integer range 0 to 9:= 0;
    variable v_test_data    : std_logic_vector(31 downto 0);

   begin

    -- insert signal assignments here
     pi_reset <= '1';
     wait for 100 ns;
     wait until pi_clock = '1';
     pi_reset <= '0';
     wait for 100 ns;
     wait until rising_edge(pi_clock);  
    
     file_open(v_file_status, f_inp, A_INPUT_VECTOR, read_mode);
     while(not endfile(f_inp)) loop
       readline(f_inp,v_line);
       read(v_line,v_test_data);
       pi_data_a <= v_test_data;
       v_line_count := v_line_count + 1;   
       wait until rising_edge(pi_clock);
     end loop;  
    wait;  
   end process stim_proc_a_array; 
   
   -- Reading the input data from text file to pi_data_b  
   stim_proc_b_array: process
    file f_inp    : text;
    variable v_file_status  : file_open_status;
    variable v_line         : line;
    variable v_line_count : integer range 0 to 9:= 0;
    variable v_test_data    : std_logic_vector(31 downto 0);

   begin

    -- insert signal assignments here
     pi_reset <= '1';
     wait for 100 ns;
     wait until pi_clock = '1';
     pi_reset <= '0';
     wait for 100 ns;
     wait until rising_edge(pi_clock);  
    
     file_open(v_file_status, f_inp, B_INPUT_VECTOR, read_mode);
     while(not endfile(f_inp)) loop
       readline(f_inp,v_line);
       read(v_line,v_test_data);
       pi_data_b <= v_test_data;
       v_line_count := v_line_count + 1;   
       wait until rising_edge(pi_clock);
     end loop;   
    wait;   
   end process stim_proc_b_array; 
   
   -- Comparing the MATLAB multiplication output with the Xilinx Simulator multiplication output 
   stim_proc_mult: process
    file f_inp    : text;
    variable v_file_status  : file_open_status;
    variable v_line         : line;
    variable v_line_count : integer range 0 to 9:= 0;
    variable v_test_data    : std_logic_vector(63 downto 0);

   begin
   
     pi_reset <= '1';
     mult_out <= (others => '0');
     wait for 100 ns;
     wait until pi_clock = '1';
     pi_reset <= '0';
     mult_out <= mult_out;
     wait for 160 ns;
     wait until rising_edge(pi_clock); 
    
     file_open(v_file_status, f_inp, MULT_OUT_VECTOR, read_mode);
     while(not endfile(f_inp)) loop
       readline(f_inp,v_line);
       read(v_line,v_test_data);
       mult_out <= v_test_data;
       v_line_count := v_line_count + 1;      
       if  po_mult = mult_out then  
         report "Test " & integer'image(v_line_count) & " PASSED";
       else
         report "Test " & integer'image(v_line_count) & " FAILED" severity error;
       end if;
       wait until rising_edge(pi_clock);
     end loop; 
    report "End of Test!";    
    wait;   
   end process stim_proc_mult; 
   
-------------------------------------------------------------------  
   
--   stim_proc: process
--   begin	
--    pi_reset <= '1';	
--    wait until rising_edge(pi_clock);    
--------------------- 35x35 (Virtex 4 and Spartan 6 Family)----------------------
----	pi_data_a<="01000000000000000000000000000000000";
----	pi_data_b<="01000000000000000000000000000000000";
--		
----	pi_data_a<="01111111111111111111111111111111111";
----	pi_data_b<="01111111111111111111111111111111111";
--		
----	pi_data_a<="00000000000000000000000000000001111";
----	pi_data_b<="00000000000000000000000000000001111";
--		
----  pi_data_a<="10000000000000000000000000000000000";
----  pi_data_b<="10000000000000000000000000000000000";
--		
----	pi_data_a<="10000000000000000000000000000000000";
----	pi_data_b<="01111111111111111111111111111111111";
-- 
---------------------------------------------------------------------------------
--
-----------------------42x35 (For Virtex-7 family)-------------------------------
--
----	pi_data_a<="000000000000000000000000000000000000001110";
----	pi_data_b<="00000000000000111111111111111100000";
--
----	pi_data_a<="100000000000000000000000000000000000000000";
----  pi_data_b<="01111111111111111111111111111111111";
--		
----	pi_data_a<="011111111111111111111111111111111111111111";
----	pi_data_b<="01111111111111111111111111111111111";		
--		
-----------------------------------------------------------------------------------	
--
-----------------------44x35(For UltraScale Family)--------------------------------
--
----	pi_data_a<="01000000000000000000000000000000000000000000";
----	pi_data_b<="01000000000000000000000000000000000";
--
----	pi_data_a<="10000000000000000000000000000000000000000000";
----  pi_data_b<="01111111111111111111111111111111111";
-- 
-----------------------------------------------------------------------------------
--		wait for 10 ns;
--    pi_reset <= '0'; 
--    wait;
--   end process;
   

END;
