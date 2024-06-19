------------------------------------------------------------------------------
--          ____  _____________  __                                         --
--         / __ \/ ____/ ___/\ \/ /                 _   _   _               --
--        / / / / __/  \__ \  \  /                 / \ / \ / \              --
--       / /_/ / /___ ___/ /  / /               = ( M | S | K )=            --
--      /_____/_____//____/  /_/                   \_/ \_/ \_/              --
--                                                                          --
------------------------------------------------------------------------------
-- @copyright Copyright 2021 DESY
-- SPDX-License-Identifier: CERN-OHL-W-2.0
------------------------------------------------------------------------------
-- @date 2022-02-08
-- @author Holger Kay <holger.kay@desy.de>
-- @author Lukasz Butkowski <lukasz.butkowski@desy.de>
------------------------------------------------------------------------------
-- @brief
-- If external clock is missing, switch to the internal clock automatically.
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.all;

entity app_clk_ctrl is
generic (
  GEN_CTRL_CLK_FREQ   : natural := 125000000; -- frequency of the control clock in Hz
  GEN_MIN_CLK_FREQ    : natural :=  81240000; -- min. frequency of the external clock in Hz
  GEN_MAX_CLK_FREQ    : natural :=  81260000  -- max. frequency of the external clock in Hz
);
port(
  pi_clock : in  std_logic;
  pi_reset : in  std_logic;

  pi_mmcm_locked : in  std_logic;    -- MMCM locked (asynchronous)
  pi_clk_freq    : in  std_logic_vector(31 downto 0);-- frequency of the external clock
  po_clk_error   : out std_logic;    -- error if external clock is not available
  po_clk_sel     : out std_logic     -- input clock select
);
end app_clk_ctrl;

architecture Behavioral of app_clk_ctrl is

  signal freq_ok     : std_logic;
  signal clk_error   : std_logic;
  signal clk_sel     : std_logic;
  signal sync_mmcm_locked : std_logic_vector(1 downto 0)  := (others => '0');

  attribute async_reg : string;
  attribute async_reg of sync_mmcm_locked : signal is "true";

begin

    sync_mmcm_locked <= sync_mmcm_locked(0) & pi_mmcm_locked when rising_edge(pi_clock);

    -- check if the frequency is in an acceptable range
    freq_ok <= '1' when (GEN_MAX_CLK_FREQ > unsigned(pi_clk_freq) and unsigned(pi_clk_freq) > GEN_MIN_CLK_FREQ) else '0';

    po_clk_error <= clk_error ; --or not freq_ok;

    -- clock select, 0 -> internal, 1 -> external clock
    po_clk_sel <= clk_sel;

    process(pi_clock,pi_reset)
    begin
      if (pi_reset = '1') then
        clk_error <= '0';
        clk_sel   <= '0'; -- switch to internal clock when reset

      elsif rising_edge(pi_clock) then
        if (sync_mmcm_locked(1) = '1' and freq_ok = '1') then
          clk_error <= '0';
          clk_sel   <= '1';
        else
          clk_error <= '1';
          clk_sel   <= '0'; -- switch to internal clock
        end if;
      end if;
    end process;

end behavioral;
