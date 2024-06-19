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
--! @dir  sim/misc/common_logic_utils/tb
--! @file tb_xor_reduce.vhd
-------------------------------------------------------------------------------
--! @brief  Testbench for the desy.common_logic_utils.xor_reduce series of functions
-------------------------------------------------------------------------------
--! @author Andrea Bellandi
--! @email andrea.bellandi@desy.de
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_misc.all;
use ieee.numeric_std.all;

library desy;
use desy.common_logic_utils;

entity tb_xor_reduce is
end entity tb_xor_reduce;

architecture tb of tb_xor_reduce is

begin

  prs_checker : process is

    constant C_LENGTH    : natural := 12;
    constant C_TESTS     : natural := 2 ** C_LENGTH - 1;
    variable var_isignal : std_logic_vector(C_LENGTH - 1 downto 0);

  begin

    for i in 0 to C_TESTS - 1 loop

      var_isignal := std_logic_vector(to_unsigned(i, C_LENGTH));

      assert common_logic_utils.xor_reduce(var_isignal) = xor_reduce(var_isignal)
        report "TEST Failed: xor_reduce(" &
               integer'image(i) &
               ") does not adhere to xor_reduce"
        severity error;

      assert common_logic_utils.xnor_reduce(var_isignal) = xnor_reduce(var_isignal)
        report "TEST Failed: nxor_reduce(" &
               integer'image(i) &
               ") does not adhere to xnor_reduce"
        severity error;

      assert common_logic_utils.f_odd_ones(var_isignal) = xor_reduce(var_isignal)
        report "TEST Failed: f_odd_ones(" &
               integer'image(i) &
               ") does not adhere to xor_reduce"
        severity error;

      assert common_logic_utils.f_even_ones(var_isignal) = xnor_reduce(var_isignal)
        report "TEST Failed: f_even_ones(" &
               integer'image(i) &
               ") does not adhere to xnor_reduce"
        severity error;

      assert common_logic_utils.f_odd_zeroes(var_isignal) = xor_reduce(not var_isignal)
        report "TEST Failed: f_odd_zeroes(" &
               integer'image(i) &
               ") does not adhere to xor_reduce"
        severity error;

      assert common_logic_utils.f_even_zeroes(var_isignal) = xnor_reduce(not var_isignal)
        report "TEST Failed: f_even_zeroes(" &
               integer'image(i) &
               ") does not adhere to xnor_reduce"
        severity error;

    end loop;

    report "TEST Passed"
      severity note;

    wait;

  end process prs_checker;

end architecture tb;
