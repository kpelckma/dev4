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
--! @dir  sim/math_utils/tb
--! @file tb_max_min.vhd
-------------------------------------------------------------------------------
--! @brief  Testbench for the desy_math.f_max/min_val_of functions
-------------------------------------------------------------------------------
--! @author Andrea Bellandi
--! @email andrea.bellandi@desy.de
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real;

library desy;
use desy.math_utils.all;

entity tb_max_min is
end entity tb_max_min;

architecture tb of tb_max_min is

  constant C_LENGTH : natural := 10;
  constant C_UMAX_I : integer := (2 ** C_LENGTH) - 1;
  constant C_UMIN_I : integer := 0;
  constant C_SMAX_I : integer := (2 ** (C_LENGTH - 1)) - 1;
  constant C_SMIN_I : integer := - (2 ** (C_LENGTH - 1));
  constant C_UMAX_V : unsigned(C_LENGTH - 1 downto 0) := (others => '1');
  constant C_UMIN_V : unsigned(C_LENGTH - 1 downto 0) := (others => '0');
  constant C_SMAX_V : signed(C_LENGTH - 1 downto 0) :=
  (
    C_LENGTH - 1 => '0',
    others => '1'
  );
  constant C_SMIN_V : signed(C_LENGTH - 1 downto 0) :=
  (
    C_LENGTH - 1 => '1',
    others => '0'
  );

begin

  prs_checker : process is

    variable var_unsigned : unsigned(C_LENGTH-1 downto 0);
    variable var_signed   : signed(C_LENGTH-1 downto 0);

  begin

    assert f_max_val_for_length(C_LENGTH, false) = C_UMAX_I
      report "Test FAILED: f_max_val_of doesn't give the max value"
      severity error;

    assert f_min_val_for_length(C_LENGTH, false) = C_UMIN_I
      report "Test FAILED: f_min_val_of doesn't give the min value"
      severity error;

    assert f_max_val_of(var_unsigned) = C_UMAX_V
      report "Test FAILED: f_max_val_of doesn't give the max value"
      severity error;

    assert f_min_val_of(var_unsigned) = C_UMIN_V
      report "Test FAILED: f_min_val_of doesn't give the min value"
      severity error;

    assert f_max_val_for_length(C_LENGTH, true) = C_SMAX_I
      report "Test FAILED: f_max_val_of doesn't give the max value"
      severity error;

    assert f_min_val_for_length(C_LENGTH, true) = C_SMIN_I
      report "Test FAILED: f_min_val_of doesn't give the min value"
      severity error;

    assert f_max_val_of(var_signed) = C_SMAX_V
      report "Test FAILED: f_max_val_of doesn't give the max value"
      severity error;

    assert f_min_val_of(var_signed) = C_SMIN_V
      report "Test FAILED: f_min_val_of doesn't give the min value"
      severity error;

    assert f_is_max(C_UMAX_V)
      report "Test FAILED: f_is_max should be true"
      severity error;

    assert f_is_min(C_UMIN_V)
      report "Test FAILED: f_is_min should be true"
      severity error;

    assert f_is_max(C_SMAX_V)
      report "Test FAILED: f_is_max should be true"
      severity error;

    assert f_is_min(C_SMIN_V)
      report "Test FAILED: f_is_min should be true"
      severity error;

    for i in C_UMIN_I to C_UMAX_I - 1 loop

      var_unsigned := to_unsigned(i, C_LENGTH);
      assert not f_is_max(var_unsigned)
        report "Test FAILED: f_is_max should be false"
        severity error;

      var_unsigned := var_unsigned + 1;
      assert not f_is_min(var_unsigned)
        report "Test FAILED: f_is_min should be false"
        severity error;

    end loop;

    for i in C_SMIN_I to C_SMAX_I - 1 loop

      var_signed := to_signed(i, C_LENGTH);
      assert not f_is_max(var_signed)
        report "Test FAILED: f_is_max should be false"
        severity error;

      var_signed := var_signed + 1;
      assert not f_is_min(var_signed)
        report "Test FAILED: f_is_min should be false"
        severity error;

    end loop;

    report "Test PASSED"
      severity note;
    wait;

  end process prs_checker;

end architecture tb;
