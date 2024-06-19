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
--! This limits the maximum slope between two consecutive samples and 
--! the maximum amplitude.
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library desy;
use desy.math_basic.all;

entity slope_ampl_limiter is
  generic(
    g_data_width : natural
  );
  port (
    -- clock
    pi_clock          : in std_logic;
    -- CTRL
    pi_slope_l_enable : in std_logic;                             -- enable slope limiter
    pi_ampl_l_enable  : in std_logic;                             -- enable amplitude limiter
    pi_slope_limit    : in std_logic_vector(g_data_width-1 downto 0);
    pi_ampl_limit     : in std_logic_vector(g_data_width-1 downto 0);
    -- IN
    pi_valid          : in std_logic;
    pi_data           : in std_logic_vector(g_data_width-1 downto 0);
    -- OUT
    po_valid          : out std_logic;
    po_data           : out std_logic_vector(g_data_width-1 downto 0)
  );
end entity slope_ampl_limiter;

architecture arch of slope_ampl_limiter is
  signal slope_l_data       : std_logic_vector(g_data_width-1 downto 0);
  signal sig_slope_l_data   : std_logic_vector(g_data_width-1 downto 0); 
  signal slope_l_valid      : std_logic; 
    
  signal ampl_l_data        : std_logic_vector(g_data_width-1 downto 0);  
  signal sig_ampl_l_data    : std_logic_vector(g_data_width-1 downto 0);
  signal ampl_l_valid       : std_logic;  

begin
 ----------------------------------
  -- slope limiter
    ins_slope_limiter: entity desy.slope_limiter
      generic map (
        g_data_width => 18
      )
      port map (
        pi_clock  => pi_clock,

        pi_enable => pi_slope_l_enable,
        pi_limit  => pi_slope_limit,

        pi_valid  => pi_valid,
        pi_data   => pi_data,

        po_valid  => slope_l_valid,
        po_data   => slope_l_data
      );
  
  sig_slope_l_data <= slope_l_data;
  
  -- purpose: amplitude limiter
  prs_slope_ampl_limit: process (pi_clock) is
  begin
    if rising_edge(pi_clock) then
      if pi_ampl_l_enable = '0' then                            -- disable amplitude limit function
        ampl_l_data  <= slope_l_data ;
        ampl_l_valid <= slope_l_valid ;

      elsif slope_l_valid = '1' then
        ampl_l_valid  <= '1';
                                                              
        if abs(signed(sig_slope_l_data)) > signed(pi_ampl_limit) then
          if signed(sig_slope_l_data) <= 0 then               -- negative amplitude limit
            ampl_l_data <= u2vneg(pi_ampl_limit); 
          else                                                -- positive amplitude limit
            ampl_l_data <= (pi_ampl_limit);
          end if;
                                                              -- no limit
        else
          ampl_l_data <= slope_l_data;
        end if;
      else
        ampl_l_valid <= '0';
      end if;
    end if;
  end process prs_slope_ampl_limit;

  sig_ampl_l_data <= ampl_l_data;
  
  po_data <= ampl_l_data      when pi_slope_l_enable ='1' and pi_ampl_l_enable ='1' else
             sig_slope_l_data when pi_slope_l_enable ='1' and pi_ampl_l_enable ='0' else
             ampl_l_data      when pi_slope_l_enable ='0' and pi_ampl_l_enable ='1' else
             slope_l_data ;
                               
  po_valid <= ampl_l_valid  when pi_slope_l_enable ='1' and pi_ampl_l_enable ='1' else
              slope_l_valid when pi_slope_l_enable ='1' and pi_ampl_l_enable ='0' else
              ampl_l_valid  when pi_slope_l_enable ='0' and pi_ampl_l_enable ='1' else
              pi_valid ;

end architecture arch;
