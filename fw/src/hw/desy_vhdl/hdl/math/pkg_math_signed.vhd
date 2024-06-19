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
--! @date 2020-10-02/2022-04-01
--! @author Lukasz Butkowski <lukasz.butkowski@desy.de>
--! @author Michael Buechler <michael.buechler@desy.de>
------------------------------------------------------------------------------
--! @brief
--! Provides math functions/procedures with signed signals
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library desy;
use desy.math_utils.all;
use desy.common_logic_utils.all;

--! Provides math functions/procedures with signed signals.
package math_signed is

  --! Absolute shift. Positive values shift left and negative values shift right
  function f_shift (arg : signed; shift : integer) return signed;

  --! Resize by changing the number of least significant bits
  function f_resize_lsb (arg : signed; length : natural) return signed;

  --! Saturate *arg* to the maximum or minimum representable value depending on
  --! *saturation*
  function f_saturate (arg : signed; sat: t_saturation) return signed;

  --! Resize with saturation protection
  function f_resize_sat (arg : signed; length : natural) return signed;

  --! Resize with saturation protection and saturation flag
  --! Like the <<f_resize_sat>> function but also sets an overflow signal.
  procedure prd_resize_sat (
    signal arg          : in signed;
    constant length     : in natural;
    signal result       : out signed;
    signal sat          : out t_saturation;
    constant sat_result : in boolean := true
  );

  procedure prd_resize_sat_var (
    variable arg        : in signed;
    constant length     : in natural;
    variable result     : out signed;
    variable sat        : out t_saturation;
    constant sat_result : in boolean := true
  );

  --! Extended summation. Never saturates.
  --! Return a signed with length equal to
  --! ----
  --! maximum(a'length, b'length) + 1
  --! ----
  function f_sum_ext (a, b : signed) return signed;

  --! Extended difference. Never saturates.
  --! Return a signed with length equal to
  --! ----
  --! maximum(a'length, b'length) + 1
  --! ----
  function f_diff_ext (a, b : signed) return signed;

  --! Extended negation. Never saturates.
  --! Return a signed with length equal to
  --! ----
  --! a'length + 1
  --! ----
  function f_neg_ext (a : signed) return signed;

  --! Extended absolute value. Never saturates.
  --! Return a signed with length equal to
  --! ----
  --! a'length + 1
  --! ----
  function f_abs_ext (a : signed) return signed;

  --! Saturated summation.
  function f_sum_sat (a, b : signed) return signed;

  --! Saturated difference.
  function f_diff_sat (a, b : signed) return signed;

  --! Saturated negation.
  function f_neg_sat (a : signed) return signed;

  --! Saturated absolute value.
  function f_abs_sat (a : signed) return signed;

  --! Saturated shift left.
  function f_shift_left_sat (a : signed; shift : natural) return signed;

  --! Saturated summation. Like <<f_sum_sat>> with the addition of
  --! a saturation signal. If sat_result = false the result is not saturated
  procedure prd_sum_sat (
    signal a, b         : in signed;
    signal result       : out signed;
    signal sat          : out t_saturation;
    constant sat_result : in boolean := true);

  procedure prd_sum_sat_var (
    variable a, b       : in signed;
    variable result     : out signed;
    variable sat        : out t_saturation;
    constant sat_result : in boolean := true);

  --! Saturated difference. Like <<f_diff_sat>> with the addition of
  --! a saturation signal. If sat_result = false the result is not saturated
  procedure prd_diff_sat (
    signal a, b         : in signed;
    signal result       : out signed;
    signal sat          : out t_saturation;
    constant sat_result : in  boolean := true);

  procedure prd_diff_sat_var (
    variable a, b       : in signed;
    variable result     : out signed;
    variable sat        : out t_saturation;
    constant sat_result : in  boolean := true);

  --! Saturated negation. Like <<f_neg_sat>> with the addition of
  --! a saturation signal. If sat_result = false the result is not saturated
  procedure prd_neg_sat (
    signal a            : in signed;
    signal result       : out signed;
    signal sat          : out t_saturation;
    constant sat_result : in boolean := true);

  procedure prd_neg_sat_var (
    variable a          : in signed;
    variable result     : out signed;
    variable sat        : out t_saturation;
    constant sat_result : in boolean := true);

  --! Saturated absolute value. Like <<f_abs_sat>> with the addition of
  --! a saturation signal. If sat_result = false the result is not saturated
  procedure prd_abs_sat (
    signal a            : in signed;
    signal result       : out signed;
    signal sat          : out t_saturation;
    constant sat_result : in boolean := true);

  --! Saturated shift left. Like <<f_shift_left>> with the addition of
  --! a saturation signal. If sat_result = false the result is not saturated
  procedure prd_shift_left_sat (
    signal a            : in signed;
    constant shift      : in natural;
    signal result       : out signed;
    signal sat          : out t_saturation;
    constant sat_result : in boolean := true);

  procedure prd_shift_left_sat_var (
    variable a          : in signed;
    constant shift      : in natural;
    variable result     : out signed;
    variable sat        : out t_saturation;
    constant sat_result : in boolean := true);

end package math_signed;

--******************************************************************************

package body math_signed is

  function f_shift (arg : signed; shift : integer) return signed is
  begin

    if (shift > 0) then
      return shift_left(arg, shift);
    else
      return shift_right(arg, -shift);
    end if;

  end function f_shift;

  function f_resize_lsb (arg : signed; length : natural) return signed is
  begin

    if (length > arg'length) then
      return shift_left(resize(arg, length), length - arg'length);
    else
      return resize(shift_right(arg, arg'length - length), length);
    end if;

  end function f_resize_lsb;

  function f_saturate (arg : signed; sat: t_saturation) return signed is
  begin

    if (sat = ST_SAT_OVERFLOWN) then
      return f_max_val_of(arg);
    elsif (sat = ST_SAT_UNDERFLOWN) then
      return f_min_val_of(arg);
    else
      return arg;
    end if;

  end function f_saturate;

  procedure prd_resize_sat_var (
    variable arg        : in signed;
    constant length     : in natural;
    variable result     : out signed;
    variable sat        : out t_saturation;
    constant sat_result : in boolean := true
  ) is

    variable v_sat : t_saturation;

  begin

    if (length >= arg'length) then
      v_sat := ST_SAT_OK;
    else
      -- check overflow saturation
      if (arg(arg'high) = '0' and
          f_all_zeroes(std_logic_vector(arg(arg'high-1 downto length - 1))) = '0') then
        v_sat := ST_SAT_OVERFLOWN;
      -- check underflow saturation
      elsif (arg(arg'high) = '1' and
             f_all_ones(std_logic_vector(arg(arg'high-1 downto length - 1))) = '0') then
        v_sat := ST_SAT_UNDERFLOWN;
      else
        v_sat := ST_SAT_OK;
      end if;
    end if;

    if (sat_result) then
      result := f_saturate(resize(arg, length), v_sat);
    else
      result := resize(arg, length);
    end if;

    sat := v_sat;

  end procedure;

  function f_resize_sat (arg : signed; length : natural) return signed is

    variable v_arg    : signed(arg'high downto arg'low);
    variable v_result : signed(length - 1 downto 0);
    variable v_sat    : t_saturation;

  begin

    v_arg := arg;
    prd_resize_sat_var(v_arg, length, v_result, v_sat);
    return v_result;

  end function;

  function f_sum_ext (a, b : signed) return signed is

    constant C_LENGTH : integer := f_maximum(a'length, b'length) + 1;

  begin

    return resize(a, C_LENGTH) + resize(b, C_LENGTH);

  end function;

  function f_diff_ext (a, b : signed) return signed is

    constant C_LENGTH : integer := f_maximum(a'length, b'length) + 1;

  begin

    return resize(a, C_LENGTH) - resize(b, C_LENGTH);

  end function;

  function f_neg_ext (a : signed) return signed is
  begin

    return f_diff_ext(to_signed(0, a'length), a);

  end function;

  function f_abs_ext (a : signed) return signed is
  begin

    return abs(resize(a, a'length + 1));

  end function;

  procedure prd_sum_sat_var (
    variable a, b       : in signed;
    variable result     : out signed;
    variable sat        : out t_saturation;
    constant sat_result : in boolean := true) is

    constant C_LENGTH : integer := f_maximum(a'length, b'length);
    variable v_result_ext : signed(C_LENGTH downto 0);

  begin

    v_result_ext := f_sum_ext(a, b);
    prd_resize_sat_var(v_result_ext, C_LENGTH, result, sat, sat_result);

  end procedure;

  procedure prd_diff_sat_var (
    variable a, b       : in signed;
    variable result     : out signed;
    variable sat        : out t_saturation;
    constant sat_result : in boolean := true) is

    constant C_LENGTH : integer := f_maximum(a'length, b'length);
    variable v_result_ext : signed(C_LENGTH downto 0);

  begin

    v_result_ext := f_diff_ext(a, b);
    prd_resize_sat_var(v_result_ext, C_LENGTH, result, sat, sat_result);

  end procedure;

  procedure prd_neg_sat_var (
    variable a          : in signed;
    variable result     : out signed;
    variable sat        : out t_saturation;
    constant sat_result : in boolean := true) is

    variable v_result_ext : signed(a'length downto 0);

  begin

    v_result_ext := f_neg_ext(a);
    prd_resize_sat_var(v_result_ext, a'length, result, sat, sat_result);

  end procedure;

  procedure prd_abs_sat_var (
    variable a          : in signed;
    variable result     : out signed;
    variable sat        : out t_saturation;
    constant sat_result : in boolean := true) is

    variable v_result_ext : signed(a'length downto 0);

  begin

    v_result_ext := f_abs_ext(a);
    prd_resize_sat_var(v_result_ext, a'length, result, sat, sat_result);

  end procedure;

  procedure prd_shift_left_sat_var (
    variable a          : in signed;
    constant shift      : in natural;
    variable result     : out signed;
    variable sat        : out t_saturation;
    constant sat_result : in boolean := true) is

    constant C_SHIFT        : natural := f_minimum(a'length, shift);
    variable v_ext_result : signed(a'length * 2 - 1 downto 0);
    variable v_result     : signed(a'length-1 downto 0);
    variable v_shift      : integer;

  begin

    v_ext_result := shift_left(resize(a, a'length * 2), C_SHIFT);
    prd_resize_sat_var(v_ext_result, a'length, result, sat, sat_result);

  end procedure;

  function f_sum_sat (a, b : signed) return signed is

    constant C_LENGTH   : integer := f_maximum(a'length, b'length);
    variable v_a      : signed(a'high downto a'low);
    variable v_b      : signed(b'high downto b'low);
    variable v_sat    : t_saturation;
    variable v_result : signed(C_LENGTH - 1 downto 0);

  begin

    v_a := a;
    v_b := b;
    prd_sum_sat_var(v_a, v_b, v_result, v_sat);
    return v_result;

  end function;

  function f_diff_sat (a, b : signed) return signed is

    constant C_LENGTH   : integer := f_maximum(a'length, b'length);
    variable v_a      : signed(a'high downto a'low);
    variable v_b      : signed(b'high downto b'low);
    variable v_sat    : t_saturation;
    variable v_result : signed(C_LENGTH - 1 downto 0);

  begin

    v_a := a;
    v_b := b;
    prd_diff_sat_var(v_a, v_b, v_result, v_sat);
    return v_result;

  end function;

  function f_neg_sat (a : signed) return signed is

    variable v_a      : signed(a'high downto a'low);
    variable v_sat    : t_saturation;
    variable v_result : signed(a'length-1 downto 0);

  begin

    v_a := a;
    prd_neg_sat_var(v_a, v_result, v_sat);
    return v_result;

  end function;

  function f_abs_sat (a : signed) return signed is

    variable v_a      : signed(a'high downto a'low);
    variable v_sat    : t_saturation;
    variable v_result : signed(a'length-1 downto 0);

  begin

    v_a := a;
    prd_abs_sat_var(v_a, v_result, v_sat);
    return v_result;

  end function;

  function f_shift_left_sat (a : signed; shift : natural) return signed is

    variable v_a      : signed(a'high downto a'low);
    variable v_sat    : t_saturation;
    variable v_result : signed(a'length-1 downto 0);

  begin

    v_a := a;
    prd_shift_left_sat_var(v_a, shift, v_result, v_sat);
    return v_result;

  end function;

  procedure prd_resize_sat (
    signal arg          : in signed;
    constant length     : in natural;
    signal result       : out signed;
    signal sat          : out t_saturation;
    constant sat_result : in boolean := true) is

    variable v_arg : signed(arg'high downto arg'low);
    variable v_result : signed(length - 1 downto 0);
    variable v_sat : t_saturation;

  begin

    v_arg  := arg;
    prd_resize_sat_var(v_arg, length, v_result, v_sat, sat_result);
    result <= v_result;
    sat    <= v_sat;

  end procedure;

  procedure prd_sum_sat (
    signal a, b         : in signed;
    signal result       : out signed;
    signal sat          : out t_saturation;
    constant sat_result : in boolean := true) is

    variable v_a, v_b : signed(a'high downto a'low);
    variable v_result : signed(a'high downto a'low);
    variable v_sat : t_saturation;

  begin

    v_a    := a;
    v_b    := b;
    prd_sum_sat_var(v_a, v_b, v_result, v_sat, sat_result);
    result <= v_result;
    sat    <= v_sat;

  end procedure;

  procedure prd_diff_sat (
    signal a, b         : in signed;
    signal result       : out signed;
    signal sat          : out t_saturation;
    constant sat_result : in  boolean := true) is

    variable v_a, v_b : signed(a'high downto a'low);
    variable v_result : signed(a'high downto a'low);
    variable v_sat : t_saturation;

  begin

    v_a    := a;
    v_b    := b;
    prd_diff_sat_var(v_a, v_b, v_result, v_sat, sat_result);
    result <= v_result;
    sat    <= v_sat;

  end procedure;

  procedure prd_neg_sat (
    signal a            : in signed;
    signal result       : out signed;
    signal sat          : out t_saturation;
    constant sat_result : in boolean := true) is

    variable v_a : signed(a'high downto a'low);
    variable v_result : signed(a'high downto a'low);
    variable v_sat : t_saturation;

  begin

    v_a    := a;
    prd_neg_sat_var(v_a, v_result, v_sat, sat_result);
    result <= v_result;
    sat    <= v_sat;

  end procedure;

  procedure prd_abs_sat (
    signal a            : in signed;
    signal result       : out signed;
    signal sat          : out t_saturation;
    constant sat_result : in boolean := true) is

    variable v_a : signed(a'high downto a'low);
    variable v_result : signed(a'high downto a'low);
    variable v_sat : t_saturation;

  begin

    v_a    := a;
    prd_abs_sat_var(v_a, v_result, v_sat, sat_result);
    result <= v_result;
    sat    <= v_sat;

  end procedure;

  procedure prd_shift_left_sat (
    signal a            : in signed;
    constant shift      : in natural;
    signal result       : out signed;
    signal sat          : out t_saturation;
    constant sat_result : in boolean := true) is

    variable v_a : signed(a'high downto a'low);
    variable v_result : signed(a'high downto a'low);
    variable v_sat : t_saturation;

  begin

    v_a    := a;
    prd_shift_left_sat_var(v_a, shift, v_result, v_sat, sat_result);
    result <= v_result;
    sat    <= v_sat;

  end procedure;

end package body math_signed;
