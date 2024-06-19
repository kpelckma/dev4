--------------------------------------------------------------------------------
--          ____  _____________  __                                           --
--         / __ \/ ____/ ___/\ \/ /                 _   _   _                 --
--        / / / / __/  \__ \  \  /                 / \ / \ / \                --
--       / /_/ / /___ ___/ /  / /               = ( M | S | K )=              --
--      /_____/_____//____/  /_/                   \_/ \_/ \_/                --
--                                                                            --
--------------------------------------------------------------------------------
--! @copyright (c) 2017 DESY
--! SPDX-License-Identifier: CERN-OHL-W-2.0
--------------------------------------------------------------------------------
--! @date 2017-04-12
--! @author
--! Cagil Gumus <cagil.guemues@desy.de>
--! Lukasz Butkowski <lukasz.butkowski@desy.de>
--! Radoslaw Rybaniec
--! Jaroslaw Szewinski
--------------------------------------------------------------------------------
--! @brief Shifts IODELAY to set value
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity iodelay_shifter is
  generic(
    G_ARCH  : string  := ""
  );
  port (
    pi_reset  : in  std_logic := '0';
    pi_clock  : in  std_logic := '0';

    pi_valid  : in  std_logic := '0';
    pi_value  : in  std_logic_vector(5 downto 0);

    po_iodelay_rst    : out std_logic := '0'; --! IDELAY Reset 
    po_iodelay_ce     : out std_logic := '0'; --! IDELAY Clock Enable
    po_iodelay_inc    : out std_logic := '0'; --! IDELAY Increment
    po_iodelay_en_vtc : out std_logic := '0'  --! IDELAY ENable Voltage Temperature Compensation
  );
end entity iodelay_shifter;

architecture rtl of iodelay_shifter is

  --! Signals necesarry for Ultrascale devices
  type t_state is (IDLE, HOLD1, HOLD2, HOLD3, APPLY);

  --! ---------------------FSM Explanation--------------------------------------
  --! IDLE => Out of reset.
  --! HOLD1 => After start EN_VTC needs to be deassert for more than 10 clk cycles
  --! APPLY => INC and CE goes high to increment IDELAY tap selection
  --! HOLD2 => There needs to be 5 clock cycles between INC+CE assertion again 
  --! HOLD3 => After INC+CE toggles, EN_VTC asserted after min 10 clk cycles.
  --! --------------------------------------------------------------------------

  constant C_EN_VTC_DEASSERT_HOLD   : natural := 15;  --! Need to wait min 10 clk cycles before increment/decrement IDELAY
  constant C_MULTIPLE_UPDATES_HOLD  : natural := 7;   --! Min 5 clk cycles needed after each INC=1 and CE=1 event
  constant C_EN_VTC_ASSERT_SETUP    : natural := 15;  --! Need to wait min 10 clk cycles before asserting EN_VTC again
  
  signal hold1_counter  : natural range 0 to 31 := 0;
  signal hold2_counter  : natural range 0 to 31 := 0;
  signal hold3_counter  : natural range 0 to 31 := 0;
  signal apply_counter  : natural range 0 to 63 := 0;
  signal state          : t_state;
  signal valid          : std_logic;
  signal value          : std_logic_vector(5 downto 0);
   
  --! Signals necesarry for other than Ultrascale devices
  signal counter  : natural range 0 to 63 := 0;
   
begin

  gen_ultrascale: if G_ARCH = "ULTRASCALE" generate
    prs_fsm: process(pi_clock)
    begin
      if rising_edge(pi_clock) then
        if pi_reset = '1' then 
          state <= IDLE;
          po_iodelay_en_vtc <= '1'; --! Important to read: AR# 64198
          valid <= '0';
          value <= (others => '0');
        else
          -- Buffer these inputs for one clock cycle to improve timing,
          case state is
            when IDLE =>
              po_iodelay_rst <= '1';
              po_iodelay_ce <= '0';
              po_iodelay_en_vtc <= '1';
              hold1_counter <= C_EN_VTC_DEASSERT_HOLD; 
              hold2_counter <= C_MULTIPLE_UPDATES_HOLD; 
              hold3_counter <= C_EN_VTC_ASSERT_SETUP;
              apply_counter <= 0;  --! Counter for holding INC for time determined by pi_value
              if valid = '1' then 
                state <= HOLD1;
              end if;
              valid <= pi_valid;
              value <= pi_value;
            when HOLD1 => --! State to pull EN_VTC down for more than 10 clk cycles
              hold1_counter <= hold1_counter - 1;
              po_iodelay_en_vtc <= '0'; --! Deassert EN_VTC pin of the IDELAYE3
              if hold1_counter = 0 then
                state <= APPLY;
              end if;
            when APPLY =>
              po_iodelay_ce <= '1';
              po_iodelay_inc <= '1';
              apply_counter <= apply_counter + 1;
              hold2_counter <= C_MULTIPLE_UPDATES_HOLD;
              if apply_counter >= to_integer(unsigned(value)) then
                state <= HOLD3;
              else 
                state <= HOLD2; --! More INC CE events on the line
              end if;
            when HOLD2 => --! Wait min 5 clk cycles before asserting inc and ce
              hold2_counter <= hold2_counter - 1;
              po_iodelay_ce <= '0';
              po_iodelay_inc <= '0';
              if hold2_counter = 0 then
                state <= APPLY;
              end if;       
            when HOLD3 =>
              hold3_counter <= hold3_counter -1;
              po_iodelay_ce <= '0';
              po_iodelay_inc <= '0';
              po_iodelay_en_vtc <= '0';
              if hold3_counter = 0 then
                state <= IDLE;
              end if;
            when others =>
              state <= IDLE;
          end case;
        end if;
      end if;
    end process prs_fsm;
  end generate gen_ultrascale;

  gen_ultrascale_n: if G_ARCH /= "ULTRASCALE" generate
    prs_ctrl: process(pi_clock)
    begin
      if rising_edge(pi_clock) then
        if pi_reset = '1' or pi_valid = '1' then
          po_iodelay_rst <= '1';
          po_iodelay_ce <= '0';
          counter <= 0;
        else
          po_iodelay_rst <= '0';
          if counter < to_integer(unsigned(pi_value)) then
            po_iodelay_ce <= '1';
            counter <= counter + 1;
          else
            po_iodelay_ce <= '0';
          end if;
        end if;
      end if;
    end process prs_ctrl;
  end generate gen_ultrascale_n;

end architecture rtl;
