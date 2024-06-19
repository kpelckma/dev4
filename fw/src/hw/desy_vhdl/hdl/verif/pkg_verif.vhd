--------------------------------------------------------------------------------
--          ____  _____________  __                                           --
--         / __ \/ ____/ ___/\ \/ /                 _   _   _                 --
--        / / / / __/  \__ \  \  /                 / \ / \ / \                --
--       / /_/ / /___ ___/ /  / /               = ( M | S | K )=              --
--      /_____/_____//____/  /_/                   \_/ \_/ \_/                --
--                                                                            --
--------------------------------------------------------------------------------
--! @copyright (c) 2021 DESY
--! SPDX-License-Identifier: CERN-OHL-W-2.0
--------------------------------------------------------------------------------
--! @date 2020-08-26
--! @author Burak Dursun <burak.dursun@desy.de>
--------------------------------------------------------------------------------
--! @brief Testbench utilities package
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.math_real.all;

package verif is

  subtype t_degree is integer range 0 to 359;
  subtype t_percent is integer range 0 to 100;
  type t_seed_array is array (1 downto 0) of positive;

  --! Clock properties
  type t_clock is record
    period      : time;
    jitter      : time;
    phase       : t_degree;
    duty_cycle  : t_percent;
    random_seed : t_seed_array;
  end record t_clock;

  --! Property of clean (no jitter, 50% duty cycle) clock at specified frequency (Hz) with zero phase
  function f_clean_clock (constant C_FREQ : positive) return t_clock;

  type t_clock_array is array (natural range<>) of t_clock;

  --! Test Clock Generator
  procedure prd_clock (
    constant  C_PROPERTY  : in  t_clock;
    signal    stop        : in  boolean;
    signal    clock       : out std_logic
  );

end package verif;

package body verif is

  procedure prd_clock (
    constant  C_PROPERTY  : in  t_clock;
    signal    stop        : in  boolean;
    signal    clock       : out std_logic
  ) is
    constant  C_DELAY       : time      := C_PROPERTY.period*C_PROPERTY.phase/360.0;
    variable  v_seed1       : positive  := C_PROPERTY.random_seed(0);
    variable  v_seed2       : positive  := C_PROPERTY.random_seed(1);
    variable  v_rand        : real;
    variable  v_period      : time;
    variable  v_high_period : time;
    variable  v_low_period  : time;
  begin
    wait for C_DELAY;
    while not(stop) loop
      uniform(v_seed1,v_seed2,v_rand);
      v_period      := C_PROPERTY.period+C_PROPERTY.jitter*(v_rand-0.5);
      v_high_period := v_period*C_PROPERTY.duty_cycle/100;
      v_low_period  := v_period-v_high_period;
      clock         <= '1';
      wait for v_high_period;
      clock       <= '0';
      wait for v_low_period;
    end loop;
  end procedure prd_clock;

  function f_clean_clock (constant C_FREQ : positive) return t_clock is
    variable v_property : t_clock;
  begin
    v_property.period       := 1 sec / C_FREQ;
    v_property.jitter       := 0 ns;
    v_property.phase        := 0;
    v_property.duty_cycle   := 50;
    v_property.random_seed  := (1, 1);
    return v_property;
  end function f_clean_clock;

end package body verif;
