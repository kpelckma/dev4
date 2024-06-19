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
--! Provides math functions/procedures with unsigned signals
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library desy;
use desy.math_utils.all;
use desy.common_logic_utils.all;

--! Provides math functions/procedures with unsigned signals.
package math_unsigned is

  --! Absolute shift. Positive values shift left and negative values shift right
  function f_shift (arg : unsigned; shift : integer) return unsigned;

  --! Resize by changing the number of least significant bits
  function f_resize_lsb (arg : unsigned; length : natural) return unsigned;

  --! Saturate *arg* to the maximum or minimum representable value depending on
  --! *saturation*
  function f_saturate (arg : unsigned; sat: t_saturation) return unsigned;

  --! Resize with saturation protection
  function f_resize_sat (arg : unsigned; length : natural) return unsigned;

  --! Resize with saturation protection and saturation flag
  --! Like the <<f_resize_sat>> function but also sets an overflow signal.
  procedure prd_resize_sat (
    signal arg          : in unsigned;
    constant length     : in natural;
    signal result       : out unsigned;
    signal sat          : out t_saturation;
    constant sat_result : in boolean := true
  );

  --! Extended summation. Never saturates.
  --! Return a unsigned with length equal to
  --! ----
  --! maximum(a'length, b'length) + 1
  --! ----
  function f_sum_ext (a, b : unsigned) return unsigned;

  --! Saturated summation.
  function f_sum_sat (a, b : unsigned) return unsigned;

  --! Saturated difference.
  function f_diff_sat (a, b : unsigned) return unsigned;

  --! Saturated shift left.
  function f_shift_left_sat (a : unsigned; shift : natural) return unsigned;

  --! Saturated summation. Like <<f_sum_sat>> with the addition of
  --! a saturation signal. If sat_result = false the result is not saturated
  procedure prd_sum_sat (
    signal a, b         : in unsigned;
    signal result       : out unsigned;
    signal sat          : out t_saturation;
    constant sat_result : in boolean := true);

  --! Saturated difference. Like <<f_diff_sat>> with the addition of
  --! a saturation signal. If sat_result = false the result is not saturated
  procedure prd_diff_sat (
    signal a, b         : in unsigned;
    signal result       : out unsigned;
    signal sat          : out t_saturation;
    constant sat_result : in  boolean := true);

  --! Saturated shift left. Like <<f_shift_left>> with the addition of
  --! a saturation signal. If sat_result = false the result is not saturated
  procedure prd_shift_left_sat (
    signal a            : in unsigned;
    constant shift      : in natural;
    signal result       : out unsigned;
    signal sat          : out t_saturation;
    constant sat_result : in boolean := true);

end package math_unsigned;

--******************************************************************************

package body math_unsigned is

  function f_shift (arg : unsigned; shift : integer) return unsigned is
  begin

    if (shift > 0) then
      return shift_left(arg, shift);
    else
      return shift_right(arg, -shift);
    end if;

  end function f_shift;

  function f_resize_lsb (arg : unsigned; length : natural) return unsigned is
  begin

    if (length > arg'length) then
      return shift_left(resize(arg, length), length - arg'length);
    else
      return resize(shift_right(arg, arg'length - length), length);
    end if;

  end function f_resize_lsb;

  function f_saturate (arg : unsigned; sat: t_saturation) return unsigned is
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
    variable arg        : in unsigned;
    constant length     : in natural;
    variable result     : out unsigned;
    variable sat        : out t_saturation;
    constant sat_result : in boolean := true
  ) is

    variable v_sat : t_saturation;

  begin

    if (length >= arg'length) then
      v_sat := ST_SAT_OK;
    else
      -- check overflow saturation
      if (f_all_zeroes(std_logic_vector(arg(arg'high downto length))) = '0') then
        v_sat := ST_SAT_OVERFLOWN;
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

  function f_resize_sat (arg : unsigned; length : natural) return unsigned is

    variable v_arg    : unsigned(arg'high downto arg'low);
    variable v_result : unsigned(length - 1 downto 0);
    variable v_sat    : t_saturation;

  begin

    v_arg := arg;
    prd_resize_sat_var(v_arg, length, v_result, v_sat);
    return v_result;

  end function;

  function f_sum_ext (a, b : unsigned) return unsigned is

    constant C_LENGTH : integer := f_maximum(a'length, b'length) + 1;

  begin

    return resize(a, C_LENGTH) + resize(b, C_LENGTH);

  end function;

  procedure prd_sum_sat_var (
    variable a, b       : in unsigned;
    variable result     : out unsigned;
    variable sat        : out t_saturation;
    constant sat_result : in boolean := true) is

    constant C_LENGTH       : integer := f_maximum(a'length, b'length);
    variable v_result_ext : unsigned(C_LENGTH downto 0);

  begin

    v_result_ext := f_sum_ext(a, b);
    prd_resize_sat_var(v_result_ext, C_LENGTH, result, sat, sat_result);

  end procedure;

  procedure prd_diff_sat_var (
    variable a, b       : in unsigned;
    variable result     : out unsigned;
    variable sat        : out t_saturation;
    constant sat_result : in boolean := true) is

    constant C_LENGTH : integer := f_maximum(a'length, b'length);
    variable v_diff_ext : unsigned(C_LENGTH downto 0);

  begin

    v_diff_ext := resize(a, C_LENGTH + 1) - resize(b, C_LENGTH + 1);
    prd_resize_sat_var(v_diff_ext,
                       C_LENGTH,
                       result,
                       sat,
                       sat_result);

  end procedure;

  function f_sum_sat (a, b : unsigned) return unsigned is

    constant C_LENGTH : integer := f_maximum(a'length, b'length);
    variable v_a      : unsigned(a'high downto a'low);
    variable v_b      : unsigned(b'high downto b'low);
    variable v_sat    : t_saturation;
    variable v_result : unsigned(C_LENGTH - 1 downto 0);

  begin

    v_a := a;
    v_b := b;
    prd_sum_sat_var(v_a, v_b, v_result, v_sat);
    return v_result;

  end function;

  function f_diff_sat (a, b : unsigned) return unsigned is

    constant C_LENGTH : integer := f_maximum(a'length, b'length);
    variable v_a      : unsigned(a'high downto a'low);
    variable v_b      : unsigned(b'high downto b'low);
    variable v_sat    : t_saturation;
    variable v_result : unsigned(C_LENGTH - 1 downto 0);

  begin

    v_a := a;
    v_b := b;
    prd_diff_sat_var(v_a, v_b, v_result, v_sat);
    return v_result;

  end function;

  procedure prd_shift_left_sat_var (
    variable a          : in unsigned;
    constant shift      : in natural;
    variable result     : out unsigned;
    variable sat        : out t_saturation;
    constant sat_result : in boolean := true) is

    constant C_SHIFT : natural := f_minimum(a'length, shift);
    variable v_ext_result : unsigned(a'length * 2 - 1 downto 0);
    variable v_result : unsigned(a'length-1 downto 0);
    variable v_shift : integer;

  begin

    v_ext_result := shift_left(resize(a, a'length * 2), C_SHIFT);
    prd_resize_sat_var(v_ext_result, a'length, result, sat, sat_result);

  end procedure;

  function f_shift_left_sat (a : unsigned; shift : natural) return unsigned is

    variable v_a      : unsigned(a'high downto a'low);
    variable v_sat    : t_saturation;
    variable v_result : unsigned(a'length-1 downto 0);

  begin

    v_a := a;
    prd_shift_left_sat_var(v_a, shift, v_result, v_sat);
    return v_result;

  end function;

  procedure prd_resize_sat (
    signal arg          : in unsigned;
    constant length     : in natural;
    signal result       : out unsigned;
    signal sat          : out t_saturation;
    constant sat_result : in boolean := true) is

    variable v_arg : unsigned(arg'high downto arg'low);
    variable v_result : unsigned(length - 1 downto 0);
    variable v_sat : t_saturation;

  begin

    v_arg  := arg;
    prd_resize_sat_var(v_arg, length, v_result, v_sat, sat_result);
    result <= v_result;
    sat    <= v_sat;

  end procedure;

  procedure prd_sum_sat (
    signal a, b         : in unsigned;
    signal result       : out unsigned;
    signal sat          : out t_saturation;
    constant sat_result : in boolean := true) is

    constant C_LENGTH : natural := f_maximum(a'length, b'length);
    variable v_a : unsigned(a'high downto a'low);
    variable v_b : unsigned(b'high downto b'low);
    variable v_result : unsigned(C_LENGTH - 1 downto 0);
    variable v_sat : t_saturation;

  begin

    v_a    := a;
    v_b    := b;
    prd_sum_sat_var(v_a, v_b, v_result, v_sat, sat_result);
    result <= v_result;
    sat    <= v_sat;

  end procedure;

  procedure prd_diff_sat (
    signal a, b         : in unsigned;
    signal result       : out unsigned;
    signal sat          : out t_saturation;
    constant sat_result : in  boolean := true) is

    constant C_LENGTH : natural := f_maximum(a'length, b'length);
    variable v_a, v_b : unsigned(a'high downto a'low);
    variable v_result : unsigned(a'high downto a'low);
    variable v_sat : t_saturation;

  begin

    v_a    := a;
    v_b    := b;
    prd_diff_sat_var(v_a, v_b, v_result, v_sat, sat_result);
    result <= v_result;
    sat    <= v_sat;

  end procedure;

  procedure prd_shift_left_sat (
    signal a            : in unsigned;
    constant shift      : in natural;
    signal result       : out unsigned;
    signal sat          : out t_saturation;
    constant sat_result : in boolean := true) is

    variable v_a : unsigned(a'high downto a'low);
    variable v_result : unsigned(a'high downto a'low);
    variable v_sat : t_saturation;

  begin

    v_a    := a;
    prd_shift_left_sat_var(v_a, shift, v_result, v_sat, sat_result);
    result <= v_result;
    sat    <= v_sat;

  end procedure;

end package body math_unsigned;
