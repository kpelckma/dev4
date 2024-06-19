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
--! @file tb_bit_length.vhd
-------------------------------------------------------------------------------
--! @brief  Testbench for the desy_math.bit_length function
-------------------------------------------------------------------------------
--! @author Michael Buechler
--! @email  michael.buechler@desy.de
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real;

library desy;
use desy.math_utils.all;
use desy.math_signed.all;

entity tb_manip is
end entity tb_manip;

architecture tb of tb_manip is

  constant C_LENGTH         : natural := 10;
  constant C_LENGTH_FINAL1  : natural := 8;
  constant C_LENGTH_FINAL2  : natural := 12;
  constant C_SHIFT_POSITIVE : integer := 2;
  constant C_SHIFT_NEGATIVE : integer := -3;

begin

  prs_checker : process is

    variable var_initial : signed(C_LENGTH - 1 downto 0);
    variable var_final1  : signed(C_LENGTH_FINAL1 - 1 downto 0);
    variable var_final2  : signed(C_LENGTH_FINAL2 - 1 downto 0);
    variable var_shift   : signed(C_LENGTH - 1 downto 0);

  begin

    for i in f_min_val_for_length(C_LENGTH, true) to
             f_max_val_for_length(C_LENGTH, true) loop

      var_initial := to_signed(i, C_LENGTH);
      var_final1  := f_resize_lsb(var_initial, C_LENGTH_FINAL1);

      assert var_final1 = shift_right(var_initial, C_LENGTH - C_LENGTH_FINAL1)
        report "Test FAILED: f_shift_right(var, C_LENGTH_FINAL1) is not equal to" &
               "shift_right(var, C_LENGTH - C_LENGTH_FINAL1)"
        severity error;

      var_final2 := f_resize_lsb(var_initial, C_LENGTH_FINAL2);

      assert var_final2 = shift_left(resize(var_initial, C_LENGTH_FINAL2),
                                     C_LENGTH_FINAL2 - C_LENGTH)
      report "Test FAILED: f_resize_lsb(var, C_LENGTH_FINAL2) is not equal to" &
             "var * 2 ** (C_LENGTH_FINAL2 - C_LENGTH)"
        severity error;

      var_shift := f_shift(var_initial, C_SHIFT_POSITIVE);

      assert var_shift = shift_left(var_initial, C_SHIFT_POSITIVE)
        report "Test FAILED: f_shift(var, C_SHIFT_POSITIVE) is not equal to " &
               "shift_left(var, C_SHIFT_POSITIVE)"
        severity error;

      var_shift := f_shift(var_initial, C_SHIFT_NEGATIVE);

      assert var_shift = shift_right(var_initial, -C_SHIFT_NEGATIVE)
        report "Test FAILED: f_shift(var, C_SHIFT_NEGATIVE) is not equal to " &
               "shift_right(var, -C_SHIFT_NEGATIVE)"
        severity error;

    end loop;

    report "Test PASSED"
      severity note;

    wait;

  end process prs_checker;

end architecture tb;
