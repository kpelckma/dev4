------------------------------------------------------------------------------
--          `__`  `___________`  ``                                         --
--         / `` \/ `___/ `__/\ \/ /                 `   `   `               --
--        / / / / `_/  \_` \  \  /                 / \ / \ / \              --
--       / /_/ / /__` `__/ /  / /               = ( M | S | K )=            --
--      /_____/_____//____/  /_/                   \_/ \_/ \_/              --
--                                                                          --
------------------------------------------------------------------------------
--! @copyright Copyright 2022 DESY
--! SPDX-License-Identifier: CERN-OHL-W-2.0
------------------------------------------------------------------------------
--! @date 2022-06-07
--! @author Andrea Bellandi <andrea.bellandi@desy.de>
------------------------------------------------------------------------------
--! @brief
--! Common logic utilities
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

--! Miscellaneous logic functions. All ported functions from
--! IEEE.std_logic_misc belongs here.
package common_logic_utils is

  --! Converts std_logic to boolean.
  function f_to_std_logic (arg: boolean) return std_logic;

  --! Converts std_logic to boolean
  function f_to_boolean (arg: std_logic) return boolean;

  --! Checks whether all bits of `arg` are equal to `1`.
  --! Equivalent to <<and_reduce>>
  function f_all_ones (arg: std_logic_vector) return std_logic;

  --! Checks wheter all bits of `arg` are equal to `0`.
  --! Equivalent to <<nor_reduce>>
  function f_all_zeroes (arg: std_logic_vector) return std_logic;

  --! Return `1` if an odd number of bits in `arg` are `1`.
  --! Equivalent to <<xor_reduce>>
  function f_odd_ones (arg: std_logic_vector) return std_logic;

  --! Return `1` if an even number of bits in `arg` are `1`.
  --! Return `1` if zero bits in `arg` are `1`.
  --! Equivalent to <<xnor_reduce>>
  function f_even_ones (arg: std_logic_vector) return std_logic;

  --! Return `1` if an odd number of bits in `arg` are `0`.
  --! Equivalent to <<xor_reduce>>
  function f_odd_zeroes (arg: std_logic_vector) return std_logic;

  --! Return `1` if an even number of bits in `arg` are `0`.
  --! Return `1` if zero bits in `arg` are `0`.
  --! Equivalent to <<xnor_reduce>>
  function f_even_zeroes (arg: std_logic_vector) return std_logic;

  -- vsg_off function_101

  --! Reduction of bits in `arg` with the `or` logical operator.
  --! Port of nonstandard `ieee.std_logic_misc.or_reduce`
  function or_reduce (arg: std_logic_vector) return std_logic;

  --! Reduction of bits in `arg` with the `and` logical operator.
  --! Port of nonstandard `ieee.std_logic_misc.and_reduce`
  function and_reduce (arg: std_logic_vector) return std_logic;

  --! Reduction of bits in `arg` with the `xor` logical operator.
  --! Port of nonstandard `ieee.std_logic_misc.xor_reduce`
  function xor_reduce (arg: std_logic_vector) return std_logic;

  --! Negated reduction of bits in `arg` with the `or` logical operator.
  --! Port of nonstandard `ieee.std_logic_misc.nor_reduce`
  function nor_reduce (arg: std_logic_vector) return std_logic;

  --! Negated reduction of bits in `arg` with the `and` logical operator.
  --! Port of nonstandard `ieee.std_logic_misc.nand_reduce`
  function nand_reduce (arg: std_logic_vector) return std_logic;

  --! Negated reduction of bits in `arg` with the `xor` logical operator.
  --! Port of nonstandard `ieee.std_logic_misc.xnor_reduce`
  function xnor_reduce (arg: std_logic_vector) return std_logic;

-- vsg_on

end package common_logic_utils;

-- ``````````````````````````````````````
package body common_logic_utils is

  ----------------------------------------------------------
  function f_to_std_logic (arg: boolean) return std_logic is
  begin
    if (arg) then
      return '1';
    else
      return '0';
    end if;
  end function;

  ----------------------------------------------------------
  function f_to_boolean (arg: std_logic) return boolean is
  begin
    return arg = '1';
  end function;

  ----------------------------------------------------------
  function f_all_ones (arg : std_logic_vector) return std_logic is
    constant C_ONES : std_logic_vector(arg'length - 1 downto 0) := (others => '1' );
  begin
    return f_to_std_logic(arg = C_ONES);
  end function;

  ----------------------------------------------------------
  function f_all_zeroes (arg : std_logic_vector) return std_logic is
    constant C_ZEROES : std_logic_vector(arg'length - 1 downto 0) := (others => '0');
  begin
    return f_to_std_logic(arg = C_ZEROES);
  end function;

  ----------------------------------------------------------
  function f_odd_ones (arg : std_logic_vector) return std_logic is
    variable v_result : std_logic := '0';
  begin
    for i in arg'low to arg'high loop
      v_result := v_result xor arg(i);
    end loop;

    return v_result;
  end function;

  ----------------------------------------------------------
  function f_even_ones (arg: std_logic_vector) return std_logic is
  begin
    return not f_odd_ones(arg);
  end function;

  ----------------------------------------------------------
  function f_odd_zeroes (arg: std_logic_vector) return std_logic is
  begin
    return f_odd_ones(not arg);
  end function;

  ----------------------------------------------------------
  function f_even_zeroes (arg: std_logic_vector) return std_logic is
  begin
    return not f_odd_zeroes(arg);
  end function;

  ----------------------------------------------------------
  function or_reduce (arg: std_logic_vector) return std_logic is
  begin
    return not f_all_zeroes(arg);
  end function;

  ----------------------------------------------------------
  function and_reduce (arg: std_logic_vector) return std_logic is
  begin
    return f_all_ones(arg);
  end function;

  ----------------------------------------------------------
  function xor_reduce (arg: std_logic_vector) return std_logic is
  begin
    return f_odd_ones(arg);
  end function;

  ----------------------------------------------------------
  function nor_reduce (arg: std_logic_vector) return std_logic is
  begin
    return f_all_zeroes(arg);
  end function;

  ----------------------------------------------------------
  function nand_reduce (arg: std_logic_vector) return std_logic is
  begin
    return not f_all_ones(arg);
  end function;

  ----------------------------------------------------------
  function xnor_reduce (arg: std_logic_vector) return std_logic is
  begin
    return f_even_ones(arg);
  end function;

end package body common_logic_utils;
