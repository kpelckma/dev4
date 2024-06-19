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
--! @file tb_logic_conversion.vhd
-------------------------------------------------------------------------------
--! @brief  Testbench for the desy.common_logic_utils.f_to_std_logic and f_to_boolean functions
-------------------------------------------------------------------------------
--! @author Andrea Bellandi
--! @email andrea.bellandi@desy.de
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library desy;
use desy.common_logic_utils;

entity tb_logic_conversion is
end entity tb_logic_conversion;

architecture tb of tb_logic_conversion is

begin

  prs_checker : process is
  begin

    assert common_logic_utils.f_to_std_logic(true) = '1'
      report "Test FAILED: f_to_std_logic(true) should be '1'"
      severity error;

    assert common_logic_utils.f_to_std_logic(false) = '0'
      report "Test FAILED: f_to_std_logic(false) should be '0'"
      severity error;

    assert common_logic_utils.f_to_boolean('1') = true
      report "Test FAILED: f_to_boolean('1') should be true"
      severity error;

    assert common_logic_utils.f_to_boolean('0') = false
      report "Test FAILED: f_to_boolean('0') should be false"
      severity error;

    report "Test PASSED"
      severity note;
    wait;

  end process prs_checker;

end architecture tb;
