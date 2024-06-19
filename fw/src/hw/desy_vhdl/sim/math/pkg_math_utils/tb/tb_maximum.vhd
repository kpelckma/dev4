-------------------------------------------------------------------------------
--          ____  _____________  __                                          --
--         / __ \/ ____/ ___/\ \/ /                 _   _   _                --
--        / / / / __/  \__ \  \  /                 / \ / \ / \               --
--       / /_/ / /___ ___/ /  / /               = ( M | S | K )=             --
--      /_____/_____//____/  /_/                   \_/ \_/ \_/               --
--                                                                           --
-------------------------------------------------------------------------------
--! @copyright  (c) 2021 DESY
--! @license    SPDX-License-Identifier: CERN-OHL-W-2.0
-------------------------------------------------------------------------------
--! @ref  git@gitlab.msktools.desy.de:fpgafw/lib/desy_math.git
--! @dir  sim/math_utils/tb
--! @file tb_maximum.vhd
-------------------------------------------------------------------------------
--! @brief  Testbench for the desy_math.f_maximum function
-------------------------------------------------------------------------------
--! @author Andrea Bellandi
--! @email andrea.bellandi@desy.de
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real;

library desy;
use desy.math_utils;

entity tb_maximum is
end entity tb_maximum;

architecture tb of tb_maximum is

  constant C_MAX   : real := real(2 ** 20);
  constant C_MIN   : real := real(-2 ** 20);
  constant C_TESTS : integer := 1000000;

begin

  prs_checker : process is

    variable var_a, var_b         : real;
    variable var_a_int, var_b_int : integer;
    variable var_seed1            : positive := 12345;
    variable var_seed2            : positive := 42;

  begin

    for i in 0 to C_TESTS - 1 loop

      math_real.uniform(var_seed1, var_seed2, var_a);
      math_real.uniform(var_seed1, var_seed2, var_b);
      var_a     := var_a * (C_MAX - C_MIN) - C_MIN;
      var_b     := var_b * (C_MAX - C_MIN) - C_MIN;
      var_a_int := integer(var_a);
      var_b_int := integer(var_b);

      if (var_a_int > var_b_int) then
        assert math_utils.f_maximum(var_a_int,
                                      var_b_int) = var_a_int
          report "Test FAILED: f_maximum comparison between var_a (" &
                 integer'image(var_a_int) & ") and var_b (" &
                 integer'image(var_b_int) & ") is incorrect"
          severity error;
      else
        assert math_utils.f_maximum(var_a_int,
                                      var_b_int) = var_b_int
          report "Test FAILED: f_maximum comparison between var_a (" &
                 integer'image(var_a_int) & ") and var_b (" &
                 integer'image(var_b_int) & ") is incorrect"
          severity error;
      end if;

    end loop;

    report "Test PASSED"
      severity note;
    wait;

  end process prs_checker;

end architecture tb;
