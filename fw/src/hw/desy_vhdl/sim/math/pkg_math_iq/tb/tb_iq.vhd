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
--! @file tb_iq.vhd
-------------------------------------------------------------------------------
--! @brief  Testbench for the desy.math_iq function
-------------------------------------------------------------------------------
--! @author Andrea Bellandi
--! @email  andrea.bellandi@desy.de
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

library desy;
use desy.math_utils.all;
use desy.math_iq.all;

entity tb_iq is
end entity tb_iq;

architecture tb of tb_iq is

begin

  prs_checker : process is

    constant C_LENGTH               : natural := 18;
    constant C_LENGTH_RANDOM        : natural := 14;
    constant C_LENGTH_PROD          : natural := C_LENGTH * 2;
    constant C_LENGTH_HIGHER        : natural := 20;
    constant C_LENGTH_LOWER         : natural := 16;
    constant C_LENGTH_PROD_HIGHER   : natural := C_LENGTH_HIGHER * 2;
    constant C_LENGTH_PROD_LOWER    : natural := C_LENGTH_LOWER * 2;
    constant C_TESTS                : natural := 1000;
    constant C_SHIFT                : integer := 2;
    constant C_MAX_VAL              : real := real(f_max_val_for_length(C_LENGTH_RANDOM, true));
    constant C_MIN_VAL              : real := real(f_min_val_for_length(C_LENGTH_RANDOM, true));
    variable var_seed1              : positive := 123456;
    variable var_seed2              : positive := 424242;
    variable var_random             : real;
    variable var_i                  : signed(C_LENGTH - 1 downto 0);
    variable var_i_int              : integer;
    variable var_q                  : signed(C_LENGTH - 1 downto 0);
    variable var_q_int              : integer;
    variable var_a                  : t_iq(C_LENGTH - 1 downto 0);
    variable var_b                  : t_iq(C_LENGTH - 1 downto 0);
    variable var_higher             : t_iq(C_LENGTH_HIGHER - 1 downto 0);
    variable var_lower              : t_iq(C_LENGTH_LOWER - 1 downto 0);
    variable var_prod_matrix        : t_prod_matrix(C_LENGTH_PROD - 1 downto 0);
    variable var_prod_matrix_higher : t_prod_matrix(C_LENGTH_PROD_HIGHER - 1 downto 0);
    variable var_prod_matrix_lower  : t_prod_matrix(C_LENGTH_PROD_LOWER - 1 downto 0);
    variable var_c11                : signed(C_LENGTH_PROD - 1 downto 0);
    variable var_c12                : signed(C_LENGTH_PROD - 1 downto 0);
    variable var_c21                : signed(C_LENGTH_PROD - 1 downto 0);
    variable var_c22                : signed(C_LENGTH_PROD - 1 downto 0);
    variable var_c11_higher         : signed(C_LENGTH_PROD_HIGHER - 1 downto 0);
    variable var_c12_higher         : signed(C_LENGTH_PROD_HIGHER - 1 downto 0);
    variable var_c21_higher         : signed(C_LENGTH_PROD_HIGHER - 1 downto 0);
    variable var_c22_higher         : signed(C_LENGTH_PROD_HIGHER - 1 downto 0);
    variable var_c11_lower          : signed(C_LENGTH_PROD_LOWER - 1 downto 0);
    variable var_c12_lower          : signed(C_LENGTH_PROD_LOWER - 1 downto 0);
    variable var_c21_lower          : signed(C_LENGTH_PROD_LOWER - 1 downto 0);
    variable var_c22_lower          : signed(C_LENGTH_PROD_LOWER - 1 downto 0);

  begin

    var_a := f_new(0, 0, C_LENGTH);

    assert f_get_i(var_a) = 0
      report "TEST Failed: f_get_i(var_a) should be 0"
      severity error;

    assert f_get_q(var_a) = 0
      report "TEST Failed: f_get_q(var_a) should be 0"
      severity error;

    for i in 0 to C_TESTS - 1 loop

      uniform(var_seed1, var_seed2, var_random);
      var_i_int := integer(floor(C_MIN_VAL +
                                 (C_MAX_VAL - C_MIN_VAL) * var_random));

      var_i := to_signed(var_i_int, C_LENGTH);

      uniform(var_seed1, var_seed2, var_random);
      var_q_int := integer(floor(C_MIN_VAL +
                                 (C_MAX_VAL - C_MIN_VAL) * var_random));

      var_q := to_signed(var_q_int, C_LENGTH);

      var_a := f_new(0, 0, C_LENGTH);
      var_a := f_new(var_i_int,  var_q_int, C_LENGTH);

      assert f_get_i(var_a) = var_i_int
        report "TEST Failed: f_get_i(var_a) should be " & integer'image(var_i_int)
        severity error;

      assert f_get_q(var_a) = var_q_int
        report "TEST Failed: f_get_q(var_a) should be " & integer'image(var_q_int)
        severity error;

      var_a := f_new(0, 0, C_LENGTH);
      var_a := f_new(var_i,  var_q);

      assert f_get_i(var_a) = var_i_int
        report "TEST Failed: f_get_i(var_a) should be " & integer'image(var_i_int)
        severity error;

      assert f_get_q(var_a) = var_q_int
        report "TEST Failed: f_get_q(var_a) should be " & integer'image(var_q_int)
        severity error;

      var_a := f_new(0, 0, C_LENGTH);
      var_a := f_new(var_i_int,  var_q);

      assert f_get_i(var_a) = var_i_int
        report "TEST Failed: f_get_i(var_a) should be " & integer'image(var_i_int)
        severity error;

      assert f_get_q(var_a) = var_q_int
        report "TEST Failed: f_get_q(var_a) should be " & integer'image(var_q_int)
        severity error;

      var_a := f_new(0, 0, C_LENGTH);
      var_a := f_new(var_i,  var_q_int);

      assert f_get_i(var_a) = var_i_int
        report "TEST Failed: f_get_i(var_a) should be " & integer'image(var_i_int)
        severity error;

      assert f_get_q(var_a) = var_q_int
        report "TEST Failed: f_get_q(var_a) should be " & integer'image(var_q_int)
        severity error;

      prd_get_comp(var_a, var_i, var_q);

      assert var_i = to_signed(var_i_int, C_LENGTH)
        report "TEST Failed: var_i should be " & integer'image(var_i_int)
        severity error;

      assert var_q = to_signed(var_q_int, C_LENGTH)
        report "TEST Failed: var_q should be " & integer'image(var_q_int)
        severity error;

      var_a := f_new(0, 0, C_LENGTH);
      var_a := f_set_i(var_a, var_i);
      var_a := f_set_q(var_a, var_q);

      assert f_get_i(var_a) = var_i_int
        report "TEST Failed: f_get_i(var_a) should be " &
               integer'image(var_i_int)
        severity error;

      assert f_get_q(var_a) = var_q_int
        report "TEST Failed: f_get_q(var_a) should be " &
               integer'image(var_q_int)
        severity error;

      var_higher := f_new(0, 0, C_LENGTH_HIGHER);
      var_higher := f_resize(var_a, C_LENGTH_HIGHER);

      assert f_get_i(var_higher) = var_i_int
        report "TEST Failed: f_get_i(var_higher) should be " &
               integer'image(var_i_int)
        severity error;

      assert f_get_q(var_higher) = var_q_int
        report "TEST Failed: f_get_q(var_higher) should be " &
               integer'image(var_q_int)
        severity error;

      var_lower := f_new(0, 0, C_LENGTH_LOWER);
      var_lower := f_resize(var_a, C_LENGTH_LOWER);

      assert f_get_i(var_lower) = var_i_int
        report "TEST Failed: f_get_i(var_lower) should be " &
               integer'image(var_i_int)
        severity error;

      assert f_get_q(var_lower) = var_q_int
        report "TEST Failed: f_get_q(var_lower) should be " &
               integer'image(var_q_int)
        severity error;

      var_a := f_swap(var_a);

      assert f_get_i(var_a) = var_q_int
        report "TEST Failed: f_get_i(var_a) should be " & integer'image(var_q_int)
        severity error;

      assert f_get_q(var_a) = var_i_int
        report "TEST Failed: f_get_q(var_a) should be " & integer'image(var_i_int)
        severity error;

      var_a := f_new(var_i,  var_q);
      var_b := f_new(var_i,  var_q);

      assert var_a = var_b
        report "TEST Failed: var_a should be equal to var_b"
        severity error;

      assert not (var_a /= var_b)
        report "TEST Failed: var_a should not be different to var_b"
        severity error;

      assert not (var_a = var_a + f_new(1, 1, C_LENGTH))
        report "TEST Failed: var_a should not be equal to var_a + (1, 1)"
        severity error;

      assert var_a /= var_a + f_new(1, 1, C_LENGTH)
        report "TEST Failed: var_a should be different to var_a + (1, 1)"
        severity error;

      uniform(var_seed1, var_seed2, var_random);
      var_i_int := integer(floor(C_MIN_VAL +
                                 (C_MAX_VAL - C_MIN_VAL) * var_random));

      var_i := to_signed(var_i_int, C_LENGTH);

      uniform(var_seed1, var_seed2, var_random);
      var_q_int := integer(floor(C_MIN_VAL +
                                 (C_MAX_VAL - C_MIN_VAL) * var_random));

      var_q := to_signed(var_q_int, C_LENGTH);

      var_b := f_new(var_i_int,  var_q_int, C_LENGTH);

      uniform(var_seed1, var_seed2, var_random);
      var_i_int := integer(floor(C_MIN_VAL +
                                 (C_MAX_VAL - C_MIN_VAL) * var_random));

      var_i := to_signed(var_i_int, C_LENGTH);

      assert f_get_i(var_a + var_b) = f_get_i(var_a) + f_get_i(var_b)
        report "TEST Failed: f_get_i(var_a + var_b) " &
               "should be equal to f_get_i(var_a) + f_get_i(var_b)"
        severity error;

      assert f_get_i(var_a - var_b) = f_get_i(var_a) - f_get_i(var_b)
        report "TEST Failed: f_get_i(var_a - var_b) " &
               "should be equal to f_get_i(var_a) - f_get_i(var_b)"
        severity error;

      assert f_get_i(- var_a) = - f_get_i(var_a)
        report "TEST Failed: f_get_i(- var_a) should be equal to - f_get_i(var_a)"
        severity error;

      assert f_get_i(var_a * var_b) = f_get_i(var_a) * f_get_i(var_b)
        report "TEST Failed: f_get_i(var_a * var_b) " &
               "should be equal to f_get_i(var_a) * f_get_i(var_b)"
        severity error;

      assert f_get_i(var_a * var_i_int) = f_get_i(var_a) * var_i_int
        report "TEST Failed: f_get_i(var_a * var_i_int) " &
               "should be equal to f_get_i(var_a) * var_i_int"
        severity error;

      assert f_get_i(var_a * var_i) = f_get_i(var_a) * var_i
        report "TEST Failed: f_get_i(var_a * var_i) should " &
               "be equal to f_get_i(var_a) * var_i"
        severity error;

      assert f_get_q(var_a + var_b) = f_get_q(var_a) + f_get_q(var_b)
        report "TEST Failed: f_get_q(var_a + var_b) " &
               "should be equal to f_get_q(var_a) + f_get_q(var_b)"
        severity error;

      assert f_get_q(var_a - var_b) = f_get_q(var_a) - f_get_q(var_b)
        report "TEST Failed: f_get_q(var_a - var_b) " &
               "should be equal to f_get_q(var_a) - f_get_q(var_b)"
        severity error;

      assert f_get_q(- var_a) = - f_get_q(var_a)
        report "TEST Failed: f_get_q(- var_a) should be equal to - f_get_q(var_a)"
        severity error;

      assert f_get_q(var_a * var_b) = f_get_q(var_a) * f_get_q(var_b)
        report "TEST Failed: f_get_q(var_a * var_b) " &
               "should be equal to f_get_q(var_a) * f_get_q(var_b)"
        severity error;

      assert f_get_q(var_a * var_i_int) = f_get_q(var_a) * var_i_int
        report "TEST Failed: f_get_q(var_a * var_i_int) " &
               "should be equal to f_get_q(var_a) * var_i_int"
        severity error;

      assert f_get_q(var_a * var_i) = f_get_q(var_a) * var_i
        report "TEST Failed: f_get_q(var_a * var_i) " &
               "should be equal to f_get_q(var_a) * var_i"
        severity error;

      assert f_sum_comp(var_a) = f_get_i(var_a) + f_get_q(var_a)
        report "TEST Failed: f_sum_comp(var_a) " &
               "should be equal to f_get_i(a) + f_get_q(a)"
        severity error;

      assert f_conj(var_a) = f_new(f_get_i(var_a), - f_get_q(var_a))
        report "TEST Failed: f_sum_comp(var_a) " &
               "should be equal to f_get_i(a) + f_get_q(a)"
        severity error;

      assert f_get_i(f_shift_left(var_a, C_SHIFT)) =
              shift_left(f_get_i(var_a), C_SHIFT)
        report "TEST Failed: f_get_i(f_shift_left(var_a, C_SHIFT)) " &
               "should be equal to shift_left(f_get_i(var_a), C_SHIFT)"
        severity error;

      assert f_get_i(f_shift_right(var_a, C_SHIFT)) =
            shift_right(f_get_i(var_a), C_SHIFT)
        report "TEST Failed: f_get_i(f_shift_right(var_a, C_SHIFT)) " &
               "should be equal to shift_right(f_get_i(var_a), C_SHIFT)"
        severity error;

      assert f_get_q(f_shift_left(var_a, C_SHIFT)) =
      shift_left(f_get_q(var_a), C_SHIFT)
        report "TEST Failed: f_get_q(f_shift_left(var_a, C_SHIFT)) " &
               "should be equal to shift_left(f_get_q(var_a), C_SHIFT)"
        severity error;

      assert f_get_q(f_shift_right(var_a, C_SHIFT)) =
      shift_right(f_get_q(var_a), C_SHIFT)
        report "TEST Failed: f_get_q(f_shift_right(var_a, C_SHIFT)) " &
               "should be equal to shift_right(f_get_q(var_a), C_SHIFT)"
        severity error;

      assert f_shift(var_a, C_SHIFT) = f_shift_left(var_a, C_SHIFT)
        report "TEST Failed: f_shift(var_a, C_SHIFT)" &
               "should be equal to f_shift_left(var_a, C_SHIFT)"
        severity error;

      assert f_shift(var_a, - C_SHIFT) = f_shift_right(var_a, C_SHIFT)
        report "TEST Failed: f_shift(var_a, - C_SHIFT)" &
               "should be equal to f_shift_right(var_a, C_SHIFT)"
        severity error;

      var_prod_matrix := f_new(f_get_i(var_a) * f_get_i(var_b),
                               f_get_i(var_a) * f_get_q(var_b),
                               f_get_q(var_a) * f_get_i(var_b),
                               f_get_q(var_a) * f_get_q(var_b));

      prd_get_comp(var_prod_matrix,
                   var_c11,
                   var_c12,
                   var_c21,
                   var_c22);

      assert f_get_i(var_a) * f_get_i(var_b) = var_c11
        report "TEST Failed: f_get_i(var_a) * f_get_i(var_b) " &
               "should be equal to var_c11"
        severity error;

      assert f_get_i(var_a) * f_get_q(var_b) = var_c12
        report "TEST Failed: f_get_i(var_a) * f_get_q(var_b) " &
               "should be equal to var_c12"
        severity error;

      assert f_get_q(var_a) * f_get_i(var_b) = var_c21
        report "TEST Failed: f_get_q(var_a) * f_get_i(var_b) " &
               "should be equal to var_c21"
        severity error;

      assert f_get_q(var_a) * f_get_q(var_b) = var_c22
        report "TEST Failed: f_get_q(var_a) * f_get_q(var_b) " &
               "should be equal to var_c11"
        severity error;

      var_prod_matrix := f_prod_matrix(var_a, var_b);

      prd_get_comp(var_prod_matrix,
                   var_c11,
                   var_c12,
                   var_c21,
                   var_c22);

      assert f_get_i(var_a) * f_get_i(var_b) = var_c11
        report "TEST Failed: f_get_i(var_a) * f_get_i(var_b) " &
               "should be equal to var_c11"
        severity error;

      assert f_get_i(var_a) * f_get_q(var_b) = var_c12
        report "TEST Failed: f_get_i(var_a) * f_get_q(var_b) " &
               "should be equal to var_c12"
        severity error;

      assert f_get_q(var_a) * f_get_i(var_b) = var_c21
        report "TEST Failed: f_get_q(var_a) * f_get_i(var_b) " &
               "should be equal to var_c21"
        severity error;

      assert f_get_q(var_a) * f_get_q(var_b) = var_c22
        report "TEST Failed: f_get_q(var_a) * f_get_q(var_b) " &
               "should be equal to var_c22"
        severity error;

      assert var_a * var_i_int = var_i_int * var_a
        report "TEST Failed: commutation of product of vectors"
        severity error;

      assert var_a * var_i = var_i * var_a
        report "TEST Failed: commutation of product of vectors"
        severity error;

      assert f_dot_prod(var_prod_matrix) = var_c11 + var_c22
        report "TEST Failed: f_dot_prod(var_prod_matrix) " &
               "should be equal to var_c11 + var_c22"
        severity error;

      assert f_cross_prod(var_prod_matrix) = var_c12 - var_c21
        report "TEST Failed: f_cross_prod(var_prod_matrix) " &
               "should be equal to var_c12 - var_c21"
        severity error;

      assert f_cmplx_prod(var_prod_matrix) = f_new(var_c11 - var_c22,
                                                   var_c12 + var_c21)
        report "TEST Failed: f_cross_prod(var_prod_matrix) " &
               "should be equal to var_c12 - var_c21"
        severity error;

      var_prod_matrix_higher := f_resize(var_prod_matrix, C_LENGTH_PROD_HIGHER);
      prd_get_comp(var_prod_matrix_higher,
                   var_c11_higher,
                   var_c12_higher,
                   var_c21_higher,
                   var_c22_higher);

      assert resize(var_c11, C_LENGTH_PROD_HIGHER) = var_c11_higher
        report "TEST Failed: resize(var_c11, C_LENGTH_PROD_HIGHER) " &
               "should be equal to var_c11_higher"
        severity error;

      assert resize(var_c12, C_LENGTH_PROD_HIGHER) = var_c12_higher
        report "TEST Failed: resize(var_c12, C_LENGTH_PROD_HIGHER) " &
               "should be equal to var_c12_higher"
        severity error;

      assert resize(var_c21, C_LENGTH_PROD_HIGHER) = var_c21_higher
        report "TEST Failed: resize(var_c21, C_LENGTH_PROD_HIGHER) " &
               "should be equal to var_c21_higher"
        severity error;

      assert resize(var_c22, C_LENGTH_PROD_HIGHER) = var_c22_higher
        report "TEST Failed: resize(var_c22, C_LENGTH_PROD_HIGHER) " &
               "should be equal to var_c22_higher"
        severity error;

      var_prod_matrix_lower := f_resize(var_prod_matrix, C_LENGTH_PROD_LOWER);
      prd_get_comp(var_prod_matrix_lower,
                   var_c11_lower,
                   var_c12_lower,
                   var_c21_lower,
                   var_c22_lower);

      assert resize(var_c11, C_LENGTH_PROD_LOWER) = var_c11_lower
        report "TEST Failed: resize(var_c11, C_LENGTH_PROD_LOWER) " &
               "should be equal to var_c11_lower"
        severity error;

      assert resize(var_c12, C_LENGTH_PROD_LOWER) = var_c12_lower
        report "TEST Failed: resize(var_c12, C_LENGTH_PROD_LOWER) " &
               "should be equal to var_c12_lower"
        severity error;

      assert resize(var_c21, C_LENGTH_PROD_LOWER) = var_c21_lower
        report "TEST Failed: resize(var_c21, C_LENGTH_PROD_LOWER) " &
               "should be equal to var_c21_lower"
        severity error;

      assert resize(var_c22, C_LENGTH_PROD_LOWER) = var_c22_lower
        report "TEST Failed: resize(var_c22, C_LENGTH_PROD_LOWER) " &
               "should be equal to var_c22_lower"
        severity error;

      var_prod_matrix := f_shift_right(f_prod_matrix(var_a, var_b), C_SHIFT);

      prd_get_comp(var_prod_matrix,
                   var_c11,
                   var_c12,
                   var_c21,
                   var_c22);

      assert shift_right(f_get_i(var_a) * f_get_i(var_b), C_SHIFT) = var_c11
        report "TEST Failed: shift_right(f_get_i(var_a) * f_get_i(var_b), C_SHIFT) " &
               "should be equal to var_c11"
        severity error;

      assert shift_right(f_get_i(var_a) * f_get_q(var_b), C_SHIFT) = var_c12
        report "TEST Failed: shift_right(f_get_i(var_a) * f_get_q(var_b), C_SHIFT) " &
               "should be equal to var_c12"
        severity error;

      assert shift_right(f_get_q(var_a) * f_get_i(var_b), C_SHIFT) = var_c21
        report "TEST Failed: shift_right(f_get_q(var_a) * f_get_i(var_b), C_SHIFT) " &
               "should be equal to var_c21"
        severity error;

      assert shift_right(f_get_q(var_a) * f_get_q(var_b), C_SHIFT) = var_c22
        report "TEST Failed: shift_right(f_get_q(var_a) * f_get_q(var_b), C_SHIFT) " &
               "should be equal to var_c22"
        severity error;

      var_prod_matrix := f_shift_left(f_prod_matrix(var_a, var_b), C_SHIFT);

      prd_get_comp(var_prod_matrix,
                   var_c11,
                   var_c12,
                   var_c21,
                   var_c22);

      assert shift_left(f_get_i(var_a) * f_get_i(var_b), C_SHIFT) = var_c11
        report "TEST Failed: shift_left(f_get_i(var_a) * f_get_i(var_b), C_SHIFT) " &
               "should be equal to var_c11"
        severity error;

      assert shift_left(f_get_i(var_a) * f_get_q(var_b), C_SHIFT) = var_c12
        report "TEST Failed: shift_left(f_get_i(var_a) * f_get_q(var_b), C_SHIFT) " &
               "should be equal to var_c12"
        severity error;

      assert shift_left(f_get_q(var_a) * f_get_i(var_b), C_SHIFT) = var_c21
        report "TEST Failed: shift_left(f_get_q(var_a) * f_get_i(var_b), C_SHIFT) " &
               "should be equal to var_c21"
        severity error;

      assert shift_left(f_get_q(var_a) * f_get_q(var_b), C_SHIFT) = var_c22
        report "TEST Failed: shift_left(f_get_q(var_a) * f_get_q(var_b), C_SHIFT) " &
               "should be equal to var_c22"
        severity error;

      var_prod_matrix := f_shift(f_prod_matrix(var_a, var_b), C_SHIFT);

      prd_get_comp(var_prod_matrix,
                   var_c11,
                   var_c12,
                   var_c21,
                   var_c22);

      assert shift_left(f_get_i(var_a) * f_get_i(var_b), C_SHIFT) = var_c11
        report "TEST Failed: shift_left(f_get_i(var_a) * f_get_i(var_b), C_SHIFT) " &
               "should be equal to var_c11"
        severity error;

      assert shift_left(f_get_i(var_a) * f_get_q(var_b), C_SHIFT) = var_c12
        report "TEST Failed: shift_left(f_get_i(var_a) * f_get_q(var_b), C_SHIFT) " &
               "should be equal to var_c12"
        severity error;

      assert shift_left(f_get_q(var_a) * f_get_i(var_b), C_SHIFT) = var_c21
        report "TEST Failed: shift_left(f_get_q(var_a) * f_get_i(var_b), C_SHIFT) " &
               "should be equal to var_c21"
        severity error;

      assert shift_left(f_get_q(var_a) * f_get_q(var_b), C_SHIFT) = var_c22
        report "TEST Failed: shift_left(f_get_q(var_a) * f_get_q(var_b), C_SHIFT) " &
               "should be equal to var_c22"
        severity error;

      var_prod_matrix := f_shift(f_prod_matrix(var_a, var_b), - C_SHIFT);

      prd_get_comp(var_prod_matrix,
                   var_c11,
                   var_c12,
                   var_c21,
                   var_c22);

      assert shift_right(f_get_i(var_a) * f_get_i(var_b), C_SHIFT) = var_c11
        report "TEST Failed: shift_right(f_get_i(var_a) * f_get_i(var_b), C_SHIFT) " &
               "should be equal to var_c11"
        severity error;

      assert shift_right(f_get_i(var_a) * f_get_q(var_b), C_SHIFT) = var_c12
        report "TEST Failed: shift_right(f_get_i(var_a) * f_get_q(var_b), C_SHIFT) " &
               "should be equal to var_c12"
        severity error;

      assert shift_right(f_get_q(var_a) * f_get_i(var_b), C_SHIFT) = var_c21
        report "TEST Failed: shift_right(f_get_q(var_a) * f_get_i(var_b), C_SHIFT) " &
               "should be equal to var_c21"
        severity error;

      assert shift_right(f_get_q(var_a) * f_get_q(var_b), C_SHIFT) = var_c22
        report "TEST Failed: shift_right(f_get_q(var_a) * f_get_q(var_b), C_SHIFT) " &
               "should be equal to var_c22"
        severity error;

    end loop;

    report "TEST Success"
      severity note;

    wait;

  end process prs_checker;

end architecture tb;
