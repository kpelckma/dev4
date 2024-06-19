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
use desy.math_utils;

entity tb_bit_length is
end entity tb_bit_length;

architecture tb of tb_bit_length is

  signal y0   : integer;
  signal y11  : integer;
  signal y12  : integer;
  signal y21  : integer;
  signal y22  : integer;
  signal y31  : integer;
  signal y32  : integer;
  signal yn11 : integer;
  signal yn12 : integer;
  signal yn21 : integer;
  signal yn22 : integer;
  signal yn31 : integer;
  signal yn32 : integer;

begin

  prs_checker : process is
  begin

    for i in 0 to 29 loop

      -- test zero
      y0 <= math_utils.f_bit_length(0);
      -- test for 2**i
      y11 <= math_utils.f_bit_length(2 ** i);
      y12 <= integer(math_real.ceil(math_real.log2(real(2 ** i + 1))));
      -- test for 2**i-1 (result should be 1 less than for 2**i)
      y21 <= math_utils.f_bit_length(2 ** i - 1);
      y22 <= integer(math_real.ceil(math_real.log2(real(2 ** i + 1 - 1))));
      -- test for 2**i+1 (same as 2**i)
      y31 <= math_utils.f_bit_length(2 ** i + 1);
      y32 <= integer(math_real.ceil(math_real.log2(real(2 ** i + 1 + 1))));
      -- test for -2**i
      yn11 <= math_utils.f_bit_length(-2 ** i);
      yn12 <= integer(math_real.ceil(math_real.log2(real(2 ** i)))) + 1;
      -- test for -2**i+1 (same as -2**i)
      -- YN21 <= math_utils.f_bit_length(-2**i+1);
      -- YN22 <= integer(math_real.ceil(math_real.log2(real(2**i - 1)))) + 1;
      -- test for -2**i-1 (result should be one more than for -2**i)
      yn31 <= math_utils.f_bit_length(-2 ** i - 1);
      yn32 <= integer(math_real.ceil(math_real.log2(real(2 ** i + 1)))) + 1;
      wait for 10 ns;
      assert y0  = 0
        report "Test FAILED"
        severity error;
      assert y11 = y12
        report "Test FAILED"
        severity error;
      assert y21 = y22
        report "Test FAILED"
        severity error;
      assert y31 = y32
        report "Test FAILED"
        severity error;

      assert yn11 = yn12
        report "Test FAILED"
        severity error;
      -- assert YN21 = YN22 report "Test FAILED" severity error;
      assert yn31 = yn32
        report "Test FAILED"
        severity error;

    end loop;

    report "Test PASSED"
      severity note;
    wait;

  end process prs_checker;

end architecture tb;
