------------------------------------------------------------------------------
--          ____  _____________  __                                         --
--         / __ \/ ____/ ___/\ \/ /                 _   _   _               --
--        / / / / __/  \__ \  \  /                 / \ / \ / \              --
--       / /_/ / /___ ___/ /  / /               = ( M | S | K )=            --
--      /_____/_____//____/  /_/                   \_/ \_/ \_/              --
--                                                                          --
------------------------------------------------------------------------------
--! @copyright Copyright 2021 DESY
--! SPDX-License-Identifier: CERN-OHL-W-2.0
------------------------------------------------------------------------------
--! @date 2021-12-21
--! @author Cagil Gumus  <cagil.guemues@desy.de>
------------------------------------------------------------------------------
--! @brief
--! Wraps the MMCM IP which creates the necessary clocks for BSP and Application
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library unisim;
use unisim.vcomponents.all;

entity bsp_mmcm_wrapper is
generic (
  g_brd_clk_div  : natural := 8;
  g_app_clk_freq : natural := 125_000_000
);
port (
  pi_clk_125m : in std_logic;
  pi_reset    : in std_logic;
  po_200m_clk : out std_logic;
  po_bsp_clk  : out std_logic;
  po_app_clk  : out std_logic;
  po_locked   : out std_logic
);
end entity bsp_mmcm_wrapper;

architecture arch of bsp_mmcm_wrapper is

  function f_get_app_div( clk_freq : natural) return natural is
  begin
    return ( 125_000_000 * 8 / clk_freq );
  end function;

  constant C_APP_DIV_V : positive := f_get_app_div(g_app_clk_freq);

  signal mmcm0_clkout1 : std_logic;
  signal mmcm0_clkout2 : std_logic;
  signal mmcm0_clkfb   : std_logic;

begin

  ins_clk_board_buf : bufg port map (o => po_bsp_clk, i => mmcm0_clkout1);
  ins_clk_app_buf   : bufg port map (o => po_app_clk, i => mmcm0_clkout2);

  inst_mmcme3_base : mmcme3_base
  generic map (
    bandwidth           => "OPTIMIZED", -- jitter programming (high, low, optimized)
    clkfbout_mult_f     => 8.0,         -- multiply value for all clkout (2.000-64.000)
    clkfbout_phase      => 0.0,         -- phase offset in degrees of clkfb (-360.000-360.000)
    clkin1_period       => 8.0,         -- input clock period in ns units, ps resolution (i.e. 33.333 is 30 mhz).
    clkout0_divide_f    => 5.0,         -- divide amount for clkout0 (1.000-128.000)
    -- clkout0_duty_cycle - clkout6_duty_cycle: duty cycle for each clkout (0.001-0.999).
    clkout0_duty_cycle  => 0.5,
    clkout1_duty_cycle  => 0.5,
    clkout2_duty_cycle  => 0.5,
    clkout3_duty_cycle  => 0.5,
    clkout4_duty_cycle  => 0.5,
    clkout5_duty_cycle  => 0.5,
    clkout6_duty_cycle  => 0.5,
    -- clkout0_phase - clkout6_phase: phase offset for each clkout (-360.000-360.000).
    clkout0_phase       => 0.0,
    clkout1_phase       => 0.0,
    clkout2_phase       => 0.0,
    clkout3_phase       => 0.0,
    clkout4_phase       => 0.0,
    clkout5_phase       => 0.0,
    clkout6_phase       => 0.0,
    -- clkout1_divide - clkout6_divide: divide amount for each clkout (1-128)
    clkout1_divide      => g_brd_clk_div,
    clkout2_divide      => C_APP_DIV_V,
    clkout3_divide      => 1,
    clkout4_divide      => 1,
    clkout5_divide      => 1,
    clkout6_divide      => 1,
    clkout4_cascade     => "FALSE", -- cascade clkout4 counter with clkout6 (false, true)
    divclk_divide       => 1,       -- master division value (1-106)
    -- programmable inversion attributes: specifies built-in programmable inversion on specific pins
    is_clkfbin_inverted => '0',    -- optional inversion for clkfbin
    is_clkin1_inverted  => '0',    -- optional inversion for clkin1
    is_pwrdwn_inverted  => '0',    -- optional inversion for pwrdwn
    is_rst_inverted     => '0',    -- optional inversion for rst
    ref_jitter1         => 0.0,    -- reference input jitter in ui (0.000-0.999)
    startup_wait        => "FALSE" -- delays done until mmcm is locked (false, true)
)
port map (
    -- clock outputs outputs: user configurable clock outputs
    clkout0   => po_200m_clk,       -- 1-bit output: clkout0
    clkout0b  => open,              -- 1-bit output: inverted clkout0
    clkout1   => mmcm0_clkout1,     -- 1-bit output: clkout1
    clkout1b  => open,              -- 1-bit output: inverted clkout1
    clkout2   => mmcm0_clkout2,     -- 1-bit output: clkout2
    clkout2b  => open,              -- 1-bit output: inverted clkout2
    clkout3   => open,              -- 1-bit output: clkout3
    clkout3b  => open,              -- 1-bit output: inverted clkout3
    clkout4   => open,              -- 1-bit output: clkout4
    clkout5   => open,              -- 1-bit output: clkout5
    clkout6   => open,              -- 1-bit output: clkout6
                                    -- feedback outputs: clock feedback ports
    clkfbout  => mmcm0_clkfb,       -- 1-bit output: feedback clock
    clkfboutb => open,              -- 1-bit output: inverted clkfbout
                                    -- status ports outputs: mmcm status ports
    locked    => po_locked,         -- 1-bit output: lock
                                    -- clock inputs inputs: clock input
    clkin1    => pi_clk_125m,       -- 1-bit input: clock
                                    -- control ports inputs: mmcm control ports
    pwrdwn    => '0',               -- 1-bit input: power-down
    rst       => pi_reset,          -- 1-bit input: reset
                                    -- feedback inputs: clock feedback ports
    clkfbin   => mmcm0_clkfb        -- 1-bit input: feedback clock
  );

end architecture;
