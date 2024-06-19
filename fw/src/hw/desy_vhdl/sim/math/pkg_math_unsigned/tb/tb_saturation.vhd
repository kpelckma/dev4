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
use desy.math_unsigned.all;

entity tb_saturation is
end entity tb_saturation;

architecture tb of tb_saturation is

  constant C_LENGTH_INITIAL       : natural := 18;
  constant C_LENGTH_FINAL         : natural := 14;
  constant C_TESTED_VALUE         : natural := 42;

  constant C_SHIFT                : natural := 2;
  constant C_LENGTH_AB            : natural := 8;

  signal sig_initial              : unsigned(C_LENGTH_INITIAL - 1 downto 0);
  signal sig_initial_a            : unsigned(C_LENGTH_AB - 1 downto 0);
  signal sig_initial_b            : unsigned(C_LENGTH_AB - 1 downto 0);
  signal sig_final_ext_ab         : unsigned(C_LENGTH_AB downto 0);
  signal sig_final_sat_ab         : unsigned(C_LENGTH_AB - 1 downto 0);
  signal sig_final_sat_ab_support : unsigned(C_LENGTH_AB - 1 downto 0);
  signal sig_final                : unsigned(C_LENGTH_FINAL - 1 downto 0);
  signal sig_sat                  : t_saturation;
  signal sig_sat_support          : t_saturation;

begin

  prs_checker : process is

  begin

    sig_initial <= to_unsigned(C_TESTED_VALUE, C_LENGTH_INITIAL);

    wait for 10 us;

    assert f_saturate(sig_initial, ST_SAT_OK) = sig_initial
      report "Test FAILED: f_saturate doesn't propagate the value on ST_SAT_OK"
      severity error;

    assert f_saturate(sig_initial, ST_SAT_OVERFLOWN) = f_max_val_of(sig_initial)
      report "Test FAILED: f_saturate saturate on ST_SAT_OVERFLOWN"
      severity error;

    assert f_saturate(sig_initial, ST_SAT_UNDERFLOWN) = f_min_val_of(sig_initial)
      report "Test FAILED: f_saturate saturate on ST_SAT_UNDERFLOWN"
      severity error;

    for i in f_min_val_for_length(C_LENGTH_FINAL, false) to
             f_max_val_for_length(C_LENGTH_FINAL, false) loop

      sig_initial <= to_unsigned(i, C_LENGTH_INITIAL);

      wait for 10 us;

      prd_resize_sat(arg => sig_initial,
                     length => C_LENGTH_FINAL,
                     result => sig_final,
                     sat => sig_sat);

      wait for 10 us;

      assert sig_final = sig_initial
        report "Test FAILED: sig_initial should be the same of sig_final"
        severity error;

      assert sig_sat = ST_SAT_OK
        report "Test FAILED: sat should be ST_SAT_OK"
        severity error;

    end loop;

    for i in f_max_val_for_length(C_LENGTH_FINAL, false) + 1 to
             f_max_val_for_length(C_LENGTH_INITIAL, false) loop

      sig_initial <= to_unsigned(i, C_LENGTH_INITIAL);

      wait for 10 us;

      prd_resize_sat(arg => sig_initial,
                     length => C_LENGTH_FINAL,
                     result => sig_final,
                     sat => sig_sat);

      wait for 10 us;

      assert sig_final = f_max_val_of(sig_final)
        report "Test FAILED: sig_final " & integer'image(i) &
               " should be saturated to the max"
        severity error;

      assert sig_sat = ST_SAT_OVERFLOWN
        report "Test FAILED: sig_sat should be ST_SAT_OVERFLOWN"
        severity error;

    end loop;

    for i in f_min_val_for_length(C_LENGTH_INITIAL, false) to
           f_max_val_for_length(C_LENGTH_INITIAL, false) loop

      sig_initial <= to_unsigned(i, C_LENGTH_INITIAL);

      wait for 10 us;

      prd_resize_sat(arg => sig_initial,
                     length => C_LENGTH_FINAL,
                     result => sig_final,
                     sat => sig_sat);

      wait for 10 us;

      assert f_resize_sat(sig_initial, C_LENGTH_FINAL) = sig_final
        report "Test FAILED: f_resize_sat gives a different result from prs_resize_sat"
        severity error;

    end loop;

    for i in f_min_val_for_length(C_LENGTH_AB, false) to
             f_max_val_for_length(C_LENGTH_AB, false) loop

      sig_initial_a <= to_unsigned(i, C_LENGTH_AB);

      wait for 10 us;

      for j in f_min_val_for_length(C_LENGTH_AB, false) to
              f_max_val_for_length(C_LENGTH_AB, false) loop

        sig_initial_b <= to_unsigned(j, C_LENGTH_AB);

        wait for 10 us;

        sig_final_ext_ab <= to_unsigned(i + j, C_LENGTH_AB + 1);

        wait for 10 us;

        assert f_sum_ext(sig_initial_a, sig_initial_b) = sig_final_ext_ab
          report "Test FAILED: f_sum_ext(" & integer'image(i) & "," & integer'image(j) &
                 ") differs from " & integer'image(i + j)
          severity error;

        prd_sum_sat(a => sig_initial_a,
                    b => sig_initial_b,
                    result => sig_final_sat_ab,
                    sat => sig_sat);

        sig_final_ext_ab <= f_sum_ext(sig_initial_a, sig_initial_b);

        wait for 10 us;

        prd_resize_sat(arg => sig_final_ext_ab,
                       length => C_LENGTH_AB,
                       result => sig_final_sat_ab_support,
                       sat => sig_sat_support);

        assert sig_final_sat_ab = sig_final_sat_ab_support
          report "Test FAILED: prd_sum_sat(" & integer'image(i) & "," & integer'image(j) &
                 ") gives wrong result"
          severity error;

        assert sig_sat = sig_sat_support
          report "Test FAILED: prd_sum_sat(" & integer'image(i) & "," & integer'image(j) &
                 ") gives wrong result"
          severity error;

        assert sig_final_sat_ab = f_sum_sat(sig_initial_a, sig_initial_b)
          report "Test FAILED: prd_sum_sat(" & integer'image(i) & "," & integer'image(j) &
                 ") is different from f_sum_sat"
          severity error;

        sig_final_ext_ab <= to_unsigned(i, C_LENGTH_AB + 1) - to_unsigned(j, C_LENGTH_AB + 1);

        wait for 10 us;

        prd_diff_sat(sig_initial_a, sig_initial_b, sig_final_sat_ab, sig_sat);
        prd_resize_sat(arg => sig_final_ext_ab,
                       length => C_LENGTH_AB,
                       result => sig_final_sat_ab_support,
                       sat => sig_sat_support);

        wait for 10 us;

        assert sig_final_sat_ab = sig_final_sat_ab_support
          report "Test FAILED: prd_diff_sat(" & integer'image(i) & "," & integer'image(j) &
                 ") gives wrong result"
          severity error;

        assert sig_sat = sig_sat_support
          report "Test FAILED: prd_diff_sat(" & integer'image(i) & "," & integer'image(j) &
                 ") gives wrong result"
          severity error;

        assert sig_final_sat_ab = f_diff_sat(sig_initial_a, sig_initial_b)
          report "Test FAILED: prd_diff_sat(" & integer'image(i) & "," & integer'image(j) &
                 ") is different from f_diff_sat"
          severity error;

      end loop;

    end loop;

    wait;

  end process prs_checker;

end architecture tb;
