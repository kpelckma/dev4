------------------------------------------------------------------------------
--          ____  _____________  __                                         --
--         / __ \/ ____/ ___/\ \/ /                 _   _   _               --
--        / / / / __/  \__ \  \  /                 / \ / \ / \              --
--       / /_/ / /___ ___/ /  / /               = ( M | S | K )=            --
--      /_____/_____//____/  /_/                   \_/ \_/ \_/              --
--                                                                          --
------------------------------------------------------------------------------
--! @copyright Copyright 2020-2022 DESY
--! SPDX-License-Identifier: CERN-OHL-W-2.0
------------------------------------------------------------------------------
--! @date 2022-07-12
--! @author Andrea Bellandi
------------------------------------------------------------------------------
--! @brief
--! Provides the T_IQ type
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library desy;
use desy.math_utils.all;
use desy.math_signed.all;

--! Package for the `IQ` type and related functions. Useful to describe a demodulated +
--! RF signal.
package math_iq is

  --! This package provides the type `t_iq` which represents an `IQ` vector.
  --! In the package multiple functions are defined that replicate `numeric_std`
  --!
  --! **Example**
  --! [source, vhdl]
  --! ----
  --! prs_test_iq : process
  --!   constant C_COMP_LENGTH : natural := 18 -- `IQ` component length
  --!   variable v_a           : t_iq(C_COMP_LENGTH-1 downto 0);
  --!   variable v_a_ex        : t_iq(C_COMP_LENGTH-1 downto 0);
  --!   variable v_b           : t_iq(C_COMP_LENGTH-1 downto 0);
  --!   variable v_sum         : t_iq(C_COMP_LENGTH-1 downto 0);
  --!   variable v_prod        : t_iq(C_COMP_LENGTH*2-1 downto 0);
  --!   variable v_sumq        : signed(C_COMP_LENGTH-1 downto 0);
  --!   variable v_prod_matrix : t_prod_matrix(C_COMP_LENGTH-1 downto 0);
  --!   variable v_dot_prod    : signed(C_COMP_LENGTH-1 downto 0);
  --! begin
  --!   v_a := f_new(-4, 9, C_COMP_LENGTH);                                      -- initialize with (I, Q) = (-4, 9)
  --!   v_b := f_new(to_signed(5, C_COMP_LENGTH), to_signed(-1, C_COMP_LENGTH)); -- initialize with (I, Q) = (5, -1)
  --!   v_sum := v_a + v_b;                                                  -- (I, Q) = (-4+5, 9-1) = (1, 8)
  --!   v_prod := v_a * v_b;                                                 -- (I, Q) = (-4*5, 9*-1) = (-20, -9)
  --!   v_a_ex := f_set_i(v_a, 6);                                             -- new I, (I, Q) = (6, 9)
  --!   v_sumq := f_get_q(v_a);                                                -- extract Q. v_sumq = 9
  --!   v_prod_matrix := f_prod_matrix(v_a, v_b);                            -- product matrix
  --!   v_dot_prod := f_dot_prod(v_prod_matrix);                               -- dot product
  --! end;
  --! ----
  --!

  --! `IQ` type. Represents a two components vector with In-phase and Quadrature +
  --! parts. The range of such vector is `(length-1 downto 0)` +
  --! where `length` is the bit length of the components.
  --! `I(i) = t_iq(i)(0)` and `Q(i) = t_iq(i)(0)`.
  type t_iq is array (integer range <>) of std_logic_vector(1 downto 0);

  function f_new (ivalue: integer; qvalue: signed) return t_iq;

  function f_new (ivalue: signed; qvalue: integer) return t_iq;

  --! Generates a new `IQ` value from signed. the final component length is equal +
  --! to `f_maximum(ivalue'length, qvalue'length)`.
  function f_new (ivalue: signed; qvalue: signed) return t_iq;

  --! Generates a new `IQ` value. Optionally values for `I` and `Q` can be passed.
  function f_new (
    ivalue: integer;
    qvalue: integer;
    length: natural) return t_iq;

  function f_set_i (a: t_iq; ivalue: integer) return t_iq;

  --! Updates the `IQ` vector with a new `I` value.
  function f_set_i (a: t_iq; ivalue: signed) return t_iq;

  function f_set_q (a: t_iq; qvalue: integer) return t_iq;

  --! Updates the `IQ` vector with a new `Q` value.
  function f_set_q (a: t_iq; qvalue: signed) return t_iq;

  --! Returns the `I` and `Q` components of `a`.
  procedure prd_get_comp (a: in t_iq; ivalue: out signed; qvalue: out signed);

  --! Returns the `I` component of `a`.
  function f_get_i (a: in t_iq) return signed;

  --! Returns the `Q` component of `a`.
  function f_get_q (a: in t_iq) return signed;

  --! Resize the iq vector with a new length. `length` must be even.
  function f_resize (a: t_iq; length: natural) return t_iq;

  --! Swap `I` and `Q` or `(Q,I)`
  function f_swap (a: t_iq) return t_iq;

  -- vsg_off: function_017

  --! Compare when `a` and `b` are equal.
  function "=" (a, b: t_iq) return boolean;

  --! Compare when `a` and `b` are not equal.
  function "/=" (a, b: t_iq) return boolean;

  --! Sum two `IQ` vectors. The resulting `IQ` has a length equal to +
  --! `f_maximum(a'length, b'length)`
  function "+" (a, b: t_iq) return t_iq;

  --! Subtract two `IQ` vectors. The resulting `IQ` has a length equal +
  --! to `f_maximum(a'length, b'length)`.
  function "-" (a, b: t_iq) return t_iq;

  --! Negates an `IQ` vector.
  function "-" (a: t_iq) return t_iq;

  --! Element-wise multiplication of two vectors. The result has a length +
  --! equal to `a'length + b'length`.
  function "*" (a, b: t_iq) return t_iq;

  function "*" (a: t_iq; scalar: signed) return t_iq;

  --! Element-wise multiplication of a vector and a scalar. The result has a length +
  --! equal to `a'length + scalar'length`.
  function "*" (scalar: signed; a : t_iq) return t_iq;

  function "*" (a: t_iq; scalar: integer) return t_iq;

  --! Element-wise multiplication of a vector and a scalar. The result has a length +
  --! equal to `a'length*2`.
  function "*" (scalar: integer; a : t_iq) return t_iq;

  -- vsg_on

  --! Sum `I` and `Q`.
  function f_sum_comp (a: t_iq) return signed;

  --! Get the conjugate or `(I, -Q)`.
  function f_conj (a: t_iq) return t_iq;

  -- vsg_off: function_017

  --! Arithmetic left shift of the `IQ` components.
  function f_shift_left (a: t_iq; shift: integer) return t_iq;

  --! Arithmetic right shift of the `IQ` components.
  function f_shift_right (a: t_iq; shift: integer) return t_iq;

  -- vsg_on

  --! Shift of the `IQ` components. Positive values shift to left, negative to the +
  --! right.
  function f_shift (a: t_iq; shift: integer) return t_iq;

  --! 2x2 matrix product type. stores the componenents of mixed products between
  --! two vectors. The data stored corresponds to +
  --! `(c11=aI*bI, c12=aI*bQ, c21=aQ*bI, c22=aQ*bQ)` +
  --! given `a, b` as the input vectors and `aI, aQ, bI, bQ` their `IQ` components.
  --! This type is just an intermediate type for the functions `f_dot_prod`, +
  --! `f_cross_prod` and `f_cmplx_prod`. Additional functions to resize and  +
  --! shift the components are provided as well.
  type t_prod_matrix is array (integer range <>) of std_logic_vector(3 downto 0);

  --! Returns a new `t_prod_matrix`.
  --! #Do not use. For testing use only. Use <<f_prod_matrix>> instead.#
  function f_new (c11, c12, c21, c22: signed) return t_prod_matrix;

  --! Returns the four components of the product matrix.
  procedure prd_get_comp (
    a   : in t_prod_matrix;
    c11 : out signed;
    c12 : out signed;
    c21 : out signed;
    c22 : out signed);

  --! Computes the product matrix.
  function f_prod_matrix (a, b: t_iq) return t_prod_matrix;

  --! Computes the dot product `(c11 + c22)`.
  function f_dot_prod (m: t_prod_matrix) return signed;

  --! Computes the cross product `(c12 - c21)`.
  function f_cross_prod (m: t_prod_matrix) return signed;

  --! Computes the complex product `(c11 - c22, c12 + c21)`.
  function f_cmplx_prod (m: t_prod_matrix) return t_iq;

  --! Resize the product matrix.
  function f_resize (m: t_prod_matrix; length: natural) return t_prod_matrix;

  -- vsg_off: function_017

  --! Arithmetic left shift of the product matrix components.
  function f_shift_left (m: t_prod_matrix; shift: integer) return t_prod_matrix;

  --! Arithmetic right shift of the product matrix components.
  function f_shift_right (m: t_prod_matrix; shift: integer) return t_prod_matrix;

  -- vsg_on

  --! Shift of the product matrix components.
  --! Positive values shift to left, negative to the right.
  function f_shift (a: t_prod_matrix; shift: integer) return t_prod_matrix;

  -- saturation functions

  --! Resize by changing the number of least significant bits
  function f_resize_lsb (arg : t_iq; length : natural) return t_iq;
  function f_resize_lsb (arg : t_prod_matrix; length : natural) return t_prod_matrix;


  --! Saturate *arg* to the maximum or minimum representable value depending on
  --! *saturation*
  function f_saturate (
    arg : t_iq;
    sat_i: t_saturation;
    sat_q: t_saturation) return t_iq;

  --! Resize with saturation protection
  function f_resize_sat (arg : t_iq; length : natural) return t_iq;

  --! Resize with saturation protection and saturation flag
  --! Like the <<f_resize_sat>> function but also sets an overflow signal.
  procedure prd_resize_sat (
    signal arg          : in t_iq;
    constant length     : in natural;
    signal result       : out t_iq;
    signal sat_i        : out t_saturation;
    signal sat_q        : out t_saturation;
    constant sat_result : in boolean := true
  );

  --! Extended summation. Never saturates.
  --! Return a t_iq with length equal to
  --! ----
  --! maximum(a'length, b'length) + 1
  --! ----
  function f_sum_ext (a, b : t_iq) return t_iq;

  --! Extended difference. Never saturates.
  --! Return a t_iq with length equal to
  --! ----
  --! maximum(a'length, b'length) + 1
  --! ----
  function f_diff_ext (a, b : t_iq) return t_iq;

  --! Extended negation. Never saturates.
  --! Return a t_iq with length equal to
  --! ----
  --! a'length + 1
  --! ----
  function f_neg_ext (a : t_iq) return t_iq;

  --! Extended conjugate value. Never saturates.
  --! Return a t_iq with length equal to
  --! ----
  --! a'length + 1
  --! ----
  function f_conj_ext (a : t_iq) return t_iq;

  --! Saturated summation.
  function f_sum_sat (a, b : t_iq) return t_iq;

  --! Saturated difference.
  function f_diff_sat (a, b : t_iq) return t_iq;

  --! Saturated negation.
  function f_neg_sat (a : t_iq) return t_iq;

  --! Saturated conjugate value.
  function f_conj_sat (a : t_iq) return t_iq;

  --! Saturated shift left.
  function f_shift_left_sat (a : t_iq; shift : natural) return t_iq;

  --! Saturated summation. Like <<f_sum_sat>> with the addition of
  --! a saturation signal. If sat_result = false the result is not saturated
  procedure prd_sum_sat (
    signal a, b         : in t_iq;
    signal result       : out t_iq;
    signal sat_i        : out t_saturation;
    signal sat_q        : out t_saturation;
    constant sat_result : in boolean := true);

  --! Saturated difference. Like <<f_diff_sat>> with the addition of
  --! a saturation signal. If sat_result = false the result is not saturated
  procedure prd_diff_sat (
    signal a, b         : in t_iq;
    signal result       : out t_iq;
    signal sat_i        : out t_saturation;
    signal sat_q        : out t_saturation;
    constant sat_result : in  boolean := true);

  --! Saturated negation. Like <<f_neg_sat>> with the addition of
  --! a saturation signal. If sat_result = false the result is not saturated
  procedure prd_neg_sat (
    signal a            : in t_iq;
    signal result       : out t_iq;
    signal sat_i        : out t_saturation;
    signal sat_q        : out t_saturation;
    constant sat_result : in boolean := true);

  --! Saturated conjugate value. Like <<f_conj_sat>> with the addition of
  --! a saturation signal. If sat_result = false the result is not saturated
  procedure prd_conj_sat (
    signal a            : in t_iq;
    signal result       : out t_iq;
    signal sat_q        : out t_saturation;
    constant sat_result : in boolean := true);

  --! Saturated shift left. Like <<f_shift_left>> with the addition of
  --! a saturation signal. If sat_result = false the result is not saturated
  procedure prd_shift_left_sat (
    signal a            : in t_iq;
    constant shift      : in natural;
    signal result       : out t_iq;
    signal sat_i        : out t_saturation;
    signal sat_q        : out t_saturation;
    constant sat_result : in boolean := true);

  -- vector types

  type t_1b_iq_vector is array (natural range<>) of t_iq(0 downto 0);

  type t_2b_iq_vector is array (natural range<>) of t_iq(1 downto 0);

  type t_3b_iq_vector is array (natural range<>) of t_iq(2 downto 0);

  type t_4b_iq_vector is array (natural range<>) of t_iq(3 downto 0);

  type t_5b_iq_vector is array (natural range<>) of t_iq(4 downto 0);

  type t_6b_iq_vector is array (natural range<>) of t_iq(5 downto 0);

  type t_7b_iq_vector is array (natural range<>) of t_iq(6 downto 0);

  type t_8b_iq_vector is array (natural range<>) of t_iq(7 downto 0);

  type t_9b_iq_vector is array (natural range<>) of t_iq(8 downto 0);

  type t_10b_iq_vector is array (natural range<>) of t_iq(9 downto 0);

  type t_11b_iq_vector is array (natural range<>) of t_iq(10 downto 0);

  type t_12b_iq_vector is array (natural range<>) of t_iq(11 downto 0);

  type t_13b_iq_vector is array (natural range<>) of t_iq(12 downto 0);

  type t_14b_iq_vector is array (natural range<>) of t_iq(13 downto 0);

  type t_15b_iq_vector is array (natural range<>) of t_iq(14 downto 0);

  type t_16b_iq_vector is array (natural range<>) of t_iq(15 downto 0);

  type t_17b_iq_vector is array (natural range<>) of t_iq(16 downto 0);

  type t_18b_iq_vector is array (natural range<>) of t_iq(17 downto 0);

  type t_19b_iq_vector is array (natural range<>) of t_iq(18 downto 0);

  type t_20b_iq_vector is array (natural range<>) of t_iq(19 downto 0);

  type t_21b_iq_vector is array (natural range<>) of t_iq(20 downto 0);

  type t_22b_iq_vector is array (natural range<>) of t_iq(21 downto 0);

  type t_23b_iq_vector is array (natural range<>) of t_iq(22 downto 0);

  type t_24b_iq_vector is array (natural range<>) of t_iq(23 downto 0);

  type t_25b_iq_vector is array (natural range<>) of t_iq(24 downto 0);

  type t_26b_iq_vector is array (natural range<>) of t_iq(25 downto 0);

  type t_27b_iq_vector is array (natural range<>) of t_iq(26 downto 0);

  type t_28b_iq_vector is array (natural range<>) of t_iq(27 downto 0);

  type t_29b_iq_vector is array (natural range<>) of t_iq(28 downto 0);

  type t_30b_iq_vector is array (natural range<>) of t_iq(29 downto 0);

  type t_31b_iq_vector is array (natural range<>) of t_iq(30 downto 0);

  type t_32b_iq_vector is array (natural range<>) of t_iq(31 downto 0);

  type t_33b_iq_vector is array (natural range<>) of t_iq(32 downto 0);

  type t_34b_iq_vector is array (natural range<>) of t_iq(33 downto 0);

  type t_35b_iq_vector is array (natural range<>) of t_iq(34 downto 0);

  type t_36b_iq_vector is array (natural range<>) of t_iq(35 downto 0);

  type t_37b_iq_vector is array (natural range<>) of t_iq(36 downto 0);

  type t_38b_iq_vector is array (natural range<>) of t_iq(37 downto 0);

  type t_39b_iq_vector is array (natural range<>) of t_iq(38 downto 0);

  type t_40b_iq_vector is array (natural range<>) of t_iq(39 downto 0);

  type t_48b_iq_vector is array (natural range<>) of t_iq(47 downto 0);

  type t_56b_iq_vector is array (natural range<>) of t_iq(55 downto 0);

  type t_64b_iq_vector is array (natural range<>) of t_iq(63 downto 0);

  type t_72b_iq_vector is array (natural range<>) of t_iq(71 downto 0);

  type t_80b_iq_vector is array (natural range<>) of t_iq(79 downto 0);

  type t_88b_iq_vector is array (natural range<>) of t_iq(87 downto 0);

  type t_96b_iq_vector is array (natural range<>) of t_iq(95 downto 0);

  type t_104b_iq_vector is array (natural range<>) of t_iq(103 downto 0);

  type t_112b_iq_vector is array (natural range<>) of t_iq(111 downto 0);

  type t_120b_iq_vector is array (natural range<>) of t_iq(119 downto 0);

  type t_128b_iq_vector is array (natural range<>) of t_iq(127 downto 0);

  type t_136b_iq_vector is array (natural range<>) of t_iq(135 downto 0);

  type t_144b_iq_vector is array (natural range<>) of t_iq(143 downto 0);

  type t_152b_iq_vector is array (natural range<>) of t_iq(151 downto 0);

  type t_160b_iq_vector is array (natural range<>) of t_iq(159 downto 0);

  type t_168b_iq_vector is array (natural range<>) of t_iq(167 downto 0);

  type t_176b_iq_vector is array (natural range<>) of t_iq(175 downto 0);

  type t_184b_iq_vector is array (natural range<>) of t_iq(183 downto 0);

  type t_192b_iq_vector is array (natural range<>) of t_iq(191 downto 0);

  type t_200b_iq_vector is array (natural range<>) of t_iq(199 downto 0);

  type t_208b_iq_vector is array (natural range<>) of t_iq(207 downto 0);

  type t_216b_iq_vector is array (natural range<>) of t_iq(215 downto 0);

  type t_224b_iq_vector is array (natural range<>) of t_iq(223 downto 0);

  type t_232b_iq_vector is array (natural range<>) of t_iq(231 downto 0);

  type t_240b_iq_vector is array (natural range<>) of t_iq(239 downto 0);

  type t_248b_iq_vector is array (natural range<>) of t_iq(247 downto 0);

  type t_256b_iq_vector is array (natural range<>) of t_iq(255 downto 0);

  type t_512b_iq_vector is array (natural range<>) of t_iq(511 downto 0);

  type t_1024b_iq_vector is array (natural range<>) of t_iq(1023 downto 0);

end package math_iq;

package body math_iq is

  function f_new (ivalue: integer; qvalue: signed) return t_iq is
  begin

    return f_new(to_signed(ivalue, qvalue'length), qvalue);

  end;

  function f_new (ivalue: signed; qvalue: integer) return t_iq is
  begin

    return f_new(ivalue, to_signed(qvalue, ivalue'length));

  end;

  function f_new (ivalue: signed; qvalue: signed) return t_iq is

    constant C_COMP_LENGTH : natural := f_maximum(ivalue'length, qvalue'length);
    variable v_iq        : t_iq(C_COMP_LENGTH - 1 downto 0);
    variable v_i         : signed(C_COMP_LENGTH - 1 downto 0);
    variable v_q         : signed(C_COMP_LENGTH - 1 downto 0);

  begin

    v_i := resize(ivalue, C_COMP_LENGTH);
    v_q := resize(qvalue, C_COMP_LENGTH);

    for i in 0 to C_COMP_LENGTH - 1 loop

      v_iq(i)(0) := v_i(i);
      v_iq(i)(1) := v_q(i);

    end loop;

    return v_iq;

  end;

  function f_new (
    ivalue: integer;
    qvalue: integer;
    length: natural) return t_iq is

    variable v_ivalue : signed(length - 1 downto 0);
    variable v_qvalue : signed(length - 1 downto 0);

  begin

    v_ivalue := to_signed(ivalue, length);
    v_qvalue := to_signed(qvalue, length);
    return f_new(v_ivalue, v_qvalue);

  end;

  function f_set_i (a: t_iq; ivalue: integer) return t_iq is
  begin

    return f_set_i(a, to_signed(ivalue, a'length));

  end;

  function f_set_i (a: t_iq; ivalue: signed) return t_iq is
  begin

    return f_new(ivalue, f_get_q(a));

  end;

  function f_set_q (a: t_iq; qvalue: integer) return t_iq is
  begin

    return f_set_q(a, to_signed(qvalue, a'length));

  end;

  function f_set_q (a: t_iq; qvalue: signed) return t_iq is
  begin

    return f_new(f_get_i(a), qvalue);

  end;

  procedure prd_get_comp (a: in t_iq; ivalue: out signed; qvalue: out signed) is

    constant C_COMP_LENGTH : natural := a'length;
    variable v_ivalue : signed(a'length-1 downto 0);
    variable v_qvalue : signed(a'length-1 downto 0);

  begin

    for i in 0 to C_COMP_LENGTH - 1 loop

      v_ivalue(i) := a(i + a'low)(0);
      v_qvalue(i) := a(i + a'low)(1);

    end loop;

    ivalue := v_ivalue;
    qvalue := v_qvalue;

  end;

  function f_get_i (a: in t_iq) return signed is

    constant C_COMP_LENGTH : natural := a'length;
    variable v_return      : signed(a'length - 1 downto 0);

  begin

    for i in 0 to C_COMP_LENGTH - 1 loop

      v_return(i) := a(i + a'low)(0);

    end loop;

    return v_return;

  end;

  function f_get_q (a: in t_iq) return signed is

    constant C_COMP_LENGTH : natural := a'length;
    variable v_return      : signed(a'length - 1 downto 0);

  begin

    for i in 0 to C_COMP_LENGTH - 1 loop

      v_return(i) := a(i + a'low)(1);

    end loop;

    return v_return;

  end;

  function f_resize (a: t_iq; length: natural) return t_iq is
  begin

    return f_new(resize(f_get_i(a), length),
                 resize(f_get_q(a), length));

  end;

  function f_swap (a: t_iq) return t_iq is
  begin

    return f_new(f_get_q(a), f_get_i(a));

  end;

  -- vsg_off: function_017

  function "=" (a,b: t_iq) return boolean is
  begin

    return (f_get_i(a) = f_get_i(b)) and (f_get_q(a) = f_get_q(b));

  end;

  function "/=" (a,b: t_iq) return boolean is
  begin

    return not (a = b);

  end;

  function "+" (a,b: t_iq) return t_iq is
  begin

    return f_new(f_get_i(a) + f_get_i(b), f_get_q(a) + f_get_q(b));

  end;

  function "-" (a,b: t_iq) return t_iq is
  begin

    return f_new(f_get_i(a) - f_get_i(b), f_get_q(a) - f_get_q(b));

  end;

  function "-" (a: t_iq) return t_iq is
  begin

    return f_new(-f_get_i(a), -f_get_q(a));

  end;

  function "*" (a,b: t_iq) return t_iq is
  begin

    return f_new(f_get_i(a) * f_get_i(b), f_get_q(a) * f_get_q(b));

  end;

  function "*" (a: t_iq; scalar: signed) return t_iq is
  begin

    return f_new(f_get_i(a) * scalar, f_get_q(a) * scalar);

  end;

  function "*" (scalar: signed; a : t_iq) return t_iq is
  begin

    return a * scalar;

  end;

  function "*" (a: t_iq; scalar: integer) return t_iq is
  begin

    return f_new(f_get_i(a) * scalar, f_get_q(a) * scalar);

  end;

  function "*" (scalar: integer; a: t_iq) return t_iq is
  begin

    return a * scalar;

  end;

  -- vsg_on

  function f_sum_comp (a: t_iq) return signed is
  begin

    return f_get_i(a) + f_get_q(a);

  end;

  function f_conj (a: t_iq) return t_iq is
  begin

    return f_new(f_get_i(a), -f_get_q(a));

  end;

  -- vsg_off: function_017

  function f_shift_left (a: t_iq; shift: integer) return t_iq is
  begin

    return f_new(shift_left(f_get_i(a), shift),
                 shift_left(f_get_q(a), shift));

  end;

  function f_shift_right (a: t_iq; shift: integer) return t_iq is
  begin

    return f_new(shift_right(f_get_i(a), shift),
                 shift_right(f_get_q(a), shift));

  end;

  -- vsg_on

  function f_shift (a: t_iq; shift: integer) return t_iq is
  begin

    if (shift > 0) then
      return f_shift_left(a, shift);
    else
      return f_shift_right(a, -shift);
    end if;

  end;

  function f_new (c11, c12, c21, c22: signed) return t_prod_matrix is

    constant C_COMP_LENGTH : natural := f_maximum(f_maximum(c11'length,
                                                            c12'length),
                                                  f_maximum(c21'length,
                                                             c22'length));

    variable v_prod_matrix : t_prod_matrix(C_COMP_LENGTH - 1 downto 0);
    variable v_c11         : signed(C_COMP_LENGTH - 1 downto 0);
    variable v_c12         : signed(C_COMP_LENGTH - 1 downto 0);
    variable v_c21         : signed(C_COMP_LENGTH - 1 downto 0);
    variable v_c22         : signed(C_COMP_LENGTH - 1 downto 0);

  begin

    v_c11 := resize(c11, C_COMP_LENGTH);
    v_c12 := resize(c12, C_COMP_LENGTH);
    v_c21 := resize(c21, C_COMP_LENGTH);
    v_c22 := resize(c22, C_COMP_LENGTH);

    for i in 0 to C_COMP_LENGTH - 1 loop

      v_prod_matrix(i + v_prod_matrix'low)(0) := v_c11(i);
      v_prod_matrix(i + v_prod_matrix'low)(1) := v_c12(i);
      v_prod_matrix(i + v_prod_matrix'low)(2) := v_c21(i);
      v_prod_matrix(i + v_prod_matrix'low)(3) := v_c22(i);

    end loop;

    return v_prod_matrix;

  end;

  procedure prd_get_comp (
    a   : in t_prod_matrix;
    c11 : out signed;
    c12 : out signed;
    c21 : out signed;
    c22 : out signed) is

    constant C_COMP_LENGTH : natural := a'length;
    variable v_c11 : signed(a'length-1 downto 0);
    variable v_c12 : signed(a'length-1 downto 0);
    variable v_c21 : signed(a'length-1 downto 0);
    variable v_c22 : signed(a'length-1 downto 0);

  begin

    for i in 0 to C_COMP_LENGTH - 1 loop

      v_c11(i) := a(i + a'low)(0);
      v_c12(i) := a(i + a'low)(1);
      v_c21(i) := a(i + a'low)(2);
      v_c22(i) := a(i + a'low)(3);

    end loop;

    c11 := v_c11;
    c12 := v_c12;
    c21 := v_c21;
    c22 := v_c22;

  end;

  function f_prod_matrix (a, b: t_iq) return t_prod_matrix is
  begin

    return f_new(f_get_i(a) * f_get_i(b),
                 f_get_i(a) * f_get_q(b),
                 f_get_q(a) * f_get_i(b),
                 f_get_q(a) * f_get_q(b));

  end;

  function f_dot_prod (m: t_prod_matrix) return signed is

    variable v_c11 : signed(m'length-1 downto 0);
    variable v_c12 : signed(m'length-1 downto 0);
    variable v_c21 : signed(m'length-1 downto 0);
    variable v_c22 : signed(m'length-1 downto 0);

  begin

    prd_get_comp(m, v_c11, v_c12, v_c21, v_c22);
    return v_c11 + v_c22;

  end;

  function f_cross_prod (m: t_prod_matrix) return signed is

    variable v_c11 : signed(m'length-1 downto 0);
    variable v_c12 : signed(m'length-1 downto 0);
    variable v_c21 : signed(m'length-1 downto 0);
    variable v_c22 : signed(m'length-1 downto 0);

  begin

    prd_get_comp(m, v_c11, v_c12, v_c21, v_c22);
    return v_c12 - v_c21;

  end;

  function f_cmplx_prod (m: t_prod_matrix) return t_iq is

    variable v_c11 : signed(m'length-1 downto 0);
    variable v_c12 : signed(m'length-1 downto 0);
    variable v_c21 : signed(m'length-1 downto 0);
    variable v_c22 : signed(m'length-1 downto 0);

  begin

    prd_get_comp(m, v_c11, v_c12, v_c21, v_c22);
    return f_new(v_c11 - v_c22, v_c12 + v_c21);

  end;

  function f_resize (m: t_prod_matrix; length: natural) return t_prod_matrix is

    variable v_c11 : signed(m'length-1 downto 0);
    variable v_c12 : signed(m'length-1 downto 0);
    variable v_c21 : signed(m'length-1 downto 0);
    variable v_c22 : signed(m'length-1 downto 0);

  begin

    prd_get_comp(m, v_c11, v_c12, v_c21, v_c22);
    return f_new(resize(v_c11, length),
                 resize(v_c12, length),
                 resize(v_c21, length),
                 resize(v_c22, length));

  end;

  -- vsg_off: function_017

  function f_shift_left (m: t_prod_matrix; shift: integer) return t_prod_matrix is

    variable v_c11 : signed(m'length-1 downto 0);
    variable v_c12 : signed(m'length-1 downto 0);
    variable v_c21 : signed(m'length-1 downto 0);
    variable v_c22 : signed(m'length-1 downto 0);

  begin
    prd_get_comp(m, v_c11, v_c12, v_c21, v_c22);
    return f_new(shift_left(v_c11, shift),
                 shift_left(v_c12, shift),
                 shift_left(v_c21, shift),
                 shift_left(v_c22, shift));
  end;

  function f_shift_right (m: t_prod_matrix; shift: integer) return t_prod_matrix is

    variable v_c11 : signed(m'length-1 downto 0);
    variable v_c12 : signed(m'length-1 downto 0);
    variable v_c21 : signed(m'length-1 downto 0);
    variable v_c22 : signed(m'length-1 downto 0);

  begin
    prd_get_comp(m, v_c11, v_c12, v_c21, v_c22);
    return f_new(shift_right(v_c11, shift),
                 shift_right(v_c12, shift),
                 shift_right(v_c21, shift),
                 shift_right(v_c22, shift));
  end;


  -- vsg_on

  function f_shift (a: t_prod_matrix; shift: integer) return t_prod_matrix is
  begin

    if (shift > 0) then
      return f_shift_left(a, shift);
    else
      return f_shift_right(a, (- shift));
    end if;

  end;

  function f_resize_lsb (arg : t_iq; length : natural) return t_iq is
  begin

    return f_new(f_resize_lsb(f_get_i(arg), length),
                 f_resize_lsb(f_get_q(arg), length));

  end;
  
  function f_resize_lsb (arg : t_prod_matrix; length : natural) return t_prod_matrix is

    variable v_c11 : signed(arg'length-1 downto 0);
    variable v_c12 : signed(arg'length-1 downto 0);
    variable v_c21 : signed(arg'length-1 downto 0);
    variable v_c22 : signed(arg'length-1 downto 0);

  begin

    prd_get_comp(arg, v_c11, v_c12, v_c21, v_c22);
    return f_new(f_resize_lsb(v_c11, length),
                 f_resize_lsb(v_c12, length),
					  f_resize_lsb(v_c21, length),
					  f_resize_lsb(v_c22, length));

  end;

  function f_saturate (
    arg : t_iq;
    sat_i: t_saturation;
    sat_q: t_saturation) return t_iq is
  begin

    return f_new(f_saturate(f_get_i(arg), sat_i),
                 f_saturate(f_get_q(arg), sat_q));

  end;

  function f_resize_sat (arg : t_iq; length : natural) return t_iq is
  begin

    return f_new(f_resize_sat(f_get_i(arg), length),
                 f_resize_sat(f_get_q(arg), length));

  end;

  procedure prd_resize_sat (
    signal arg          : in t_iq;
    constant length     : in natural;
    signal result       : out t_iq;
    signal sat_i        : out t_saturation;
    signal sat_q        : out t_saturation;
    constant sat_result : in boolean := true) is

    variable v_i : signed(arg'high downto arg'low);
    variable v_q : signed(arg'high downto arg'low);
    variable v_result_i : signed(length - 1 downto 0);
    variable v_result_q : signed(length - 1 downto 0);
    variable v_sat_i : t_saturation;
    variable v_sat_q : t_saturation;

  begin

    v_i := f_get_i(arg);
    v_q := f_get_q(arg);

    prd_resize_sat_var(v_i, length, v_result_i, v_sat_i, sat_result);
    prd_resize_sat_var(v_q, length, v_result_q, v_sat_q, sat_result);

    result <= f_new(v_result_i, v_result_q);
    sat_i  <= v_sat_i;
    sat_q  <= v_sat_q;

  end;

  function f_sum_ext (a, b : t_iq) return t_iq is
  begin

    return f_new(f_sum_ext(f_get_i(a), f_get_i(b)),
                 f_sum_ext(f_get_q(a), f_get_q(b)));

  end;

  function f_diff_ext (a, b : t_iq) return t_iq is
  begin

    return f_new(f_diff_ext(f_get_i(a), f_get_i(b)),
                 f_diff_ext(f_get_q(a), f_get_q(b)));

  end;

  function f_neg_ext (a : t_iq) return t_iq is
  begin

    return f_new(f_neg_ext(f_get_i(a)),
                 f_neg_ext(f_get_q(a)));

  end;

  function f_conj_ext (a : t_iq) return t_iq is
  begin

    return f_new(f_get_i(a),
                 f_neg_ext(f_get_q(a)));

  end;

  function f_sum_sat (a, b : t_iq) return t_iq is
  begin

    return f_new(f_sum_sat(f_get_i(a), f_get_i(b)),
                 f_sum_sat(f_get_q(a), f_get_q(b)));

  end;

  function f_diff_sat (a, b : t_iq) return t_iq is
  begin

    return f_new(f_diff_sat(f_get_i(a), f_get_i(b)),
                 f_diff_sat(f_get_q(a), f_get_q(b)));

  end;

  function f_neg_sat (a : t_iq) return t_iq is
  begin

    return f_new(f_neg_sat(f_get_i(a)),
                 f_neg_sat(f_get_q(a)));

  end;

  function f_conj_sat (a : t_iq) return t_iq is
  begin

    return f_new(f_get_i(a),
                 f_neg_sat(f_get_q(a)));

  end;

  function f_shift_left_sat (a : t_iq; shift : natural) return t_iq is
  begin

    return f_new(f_shift_left_sat(f_get_i(a), shift),
                 f_shift_left_sat(f_get_q(a), shift));

  end;

  procedure prd_sum_sat (
    signal a, b         : in t_iq;
    signal result       : out t_iq;
    signal sat_i        : out t_saturation;
    signal sat_q        : out t_saturation;
    constant sat_result : in boolean := true) is

    constant C_LENGTH : natural := f_maximum(a'length, b'length);
    variable v_a_i : signed(a'high downto a'low);
    variable v_a_q : signed(a'high downto a'low);
    variable v_b_i : signed(b'high downto b'low);
    variable v_b_q : signed(b'high downto b'low);
    variable v_result_i : signed(C_LENGTH - 1 downto 0);
    variable v_result_q : signed(C_LENGTH - 1 downto 0);
    variable v_sat_i : t_saturation;
    variable v_sat_q : t_saturation;

  begin

    v_a_i := f_get_i(a);
    v_a_q := f_get_q(a);
    v_b_i := f_get_i(b);
    v_b_q := f_get_q(b);

    prd_sum_sat_var(v_a_i, v_b_i, v_result_i, v_sat_i, sat_result);
    prd_sum_sat_var(v_a_q, v_b_q, v_result_q, v_sat_q, sat_result);

    result <= f_new(v_result_i, v_result_q);
    sat_i  <= v_sat_i;
    sat_q  <= v_sat_q;

  end;

  procedure prd_diff_sat (
    signal a, b         : in t_iq;
    signal result       : out t_iq;
    signal sat_i        : out t_saturation;
    signal sat_q        : out t_saturation;
    constant sat_result : in  boolean := true) is

    constant C_LENGTH : natural := f_maximum(a'length, b'length);
    variable v_a_i : signed(a'high downto a'low);
    variable v_a_q : signed(a'high downto a'low);
    variable v_b_i : signed(b'high downto b'low);
    variable v_b_q : signed(b'high downto b'low);
    variable v_result_i : signed(C_LENGTH - 1 downto 0);
    variable v_result_q : signed(C_LENGTH - 1 downto 0);
    variable v_sat_i : t_saturation;
    variable v_sat_q : t_saturation;

  begin

    v_a_i := f_get_i(a);
    v_a_q := f_get_q(a);
    v_b_i := f_get_i(b);
    v_b_q := f_get_q(b);

    prd_diff_sat_var(v_a_i, v_b_i, v_result_i, v_sat_i, sat_result);
    prd_diff_sat_var(v_a_q, v_b_q, v_result_q, v_sat_q, sat_result);

    result <= f_new(v_result_i, v_result_q);
    sat_i  <= v_sat_i;
    sat_q  <= v_sat_q;

  end;

  procedure prd_neg_sat (
    signal a            : in t_iq;
    signal result       : out t_iq;
    signal sat_i        : out t_saturation;
    signal sat_q        : out t_saturation;
    constant sat_result : in boolean := true) is

    variable v_a_i : signed(a'high downto a'low);
    variable v_a_q : signed(a'high downto a'low);
    variable v_result_i : signed(a'high downto a'low);
    variable v_result_q : signed(a'high downto a'low);
    variable v_sat_i : t_saturation;
    variable v_sat_q : t_saturation;

  begin

    v_a_i := f_get_i(a);
    v_a_q := f_get_q(a);

    prd_neg_sat_var(v_a_i, v_result_i, v_sat_i, sat_result);
    prd_neg_sat_var(v_a_q, v_result_q, v_sat_q, sat_result);

    result <= f_new(v_result_i, v_result_q);
    sat_i  <= v_sat_i;
    sat_q  <= v_sat_q;

  end;

  procedure prd_conj_sat (
    signal a            : in t_iq;
    signal result       : out t_iq;
    signal sat_q        : out t_saturation;
    constant sat_result : in boolean := true) is

    variable v_a_i : signed(a'high downto a'low);
    variable v_a_q : signed(a'high downto a'low);
    variable v_result_q : signed(a'high downto a'low);
    variable v_sat_q : t_saturation;

  begin

    v_a_i := f_get_i(a);
    v_a_q := f_get_q(a);

    prd_neg_sat_var(v_a_q, v_result_q, v_sat_q, sat_result);

    result <= f_new(v_a_i, v_result_q);
    sat_q  <= v_sat_q;

  end;

  procedure prd_shift_left_sat (
    signal a            : in t_iq;
    constant shift      : in natural;
    signal result       : out t_iq;
    signal sat_i        : out t_saturation;
    signal sat_q        : out t_saturation;
    constant sat_result : in boolean := true) is

    variable v_a_i : signed(a'high downto a'low);
    variable v_a_q : signed(a'high downto a'low);
    variable v_result_i : signed(a'high downto a'low);
    variable v_result_q : signed(a'high downto a'low);
    variable v_sat_i : t_saturation;
    variable v_sat_q : t_saturation;

  begin

    v_a_i := f_get_i(a);
    v_a_q := f_get_q(a);

    prd_shift_left_sat_var(v_a_i, shift, v_result_i, v_sat_i, sat_result);
    prd_shift_left_sat_var(v_a_q, shift, v_result_q, v_sat_q, sat_result);

    result <= f_new(v_result_i, v_result_q);
    sat_i  <= v_sat_i;
    sat_q  <= v_sat_q;

  end;

end package body math_iq;
