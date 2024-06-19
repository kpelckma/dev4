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
--! @file tb_and_reduce.vhd
-------------------------------------------------------------------------------
--! @brief  Testbench for the desy.common_logic_utils.and_reduce series of functions
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

entity tb_and_reduce is
end entity tb_and_reduce;

architecture tb of tb_and_reduce is

begin

  prs_checker : process is

    constant C_LENGTH    : natural := 12;
    constant C_TESTS     : natural := 2 ** 12;
    variable var_signal  : real;
    variable var_isignal : std_logic_vector(C_LENGTH - 1 downto 0);
    variable var_seed1   : positive := 12345;
    variable var_seed2   : positive := 42;

  begin

    var_isignal := (others => '1');
    assert common_logic_utils.and_reduce(var_isignal) = '1'
      report "TEST Failed: and_reduce should be '1'"
      severity error;

    assert common_logic_utils.nand_reduce(var_isignal) = '0'
      report "TEST Failed: nand_reduce should be '0'"
      severity error;

    assert common_logic_utils.f_all_ones(var_isignal) = '1'
      report "TEST Failed: f_all_ones should be '1'"
      severity error;

    for i in 0 to C_TESTS - 1 loop

      var_isignal := std_logic_vector(to_unsigned(i, C_LENGTH));

      assert common_logic_utils.and_reduce(var_isignal) = and_reduce(var_isignal)
        report "TEST Failed: and_reduce(" &
               integer'image(natural(var_signal)) &
               ") does not adhere to and_reduce"
        severity error;

      assert common_logic_utils.nand_reduce(var_isignal) = nand_reduce(var_isignal)
        report "TEST Failed: nand_reduce(" &
               integer'image(natural(var_signal)) &
               ") does not adhere to nand_reduce"
        severity error;

      assert common_logic_utils.f_all_ones(var_isignal) = and_reduce(var_isignal)
        report "TEST Failed: f_all_ones(" &
               integer'image(natural(var_signal)) &
               ") does not adhere to and_reduce"
        severity error;

    end loop;

    report "TEST Passed"
      severity note;

    wait;

  end process prs_checker;

end architecture tb;