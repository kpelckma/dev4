------------------------------------------------------------------------------
--          ____  _____________  __                                         --
--         / __ \/ ____/ ___/\ \/ /                 _   _   _               --
--        / / / / __/  \__ \  \  /                 / \ / \ / \              --
--       / /_/ / /___ ___/ /  / /               = ( m | s | k )=            --
--      /_____/_____//____/  /_/                   \_/ \_/ \_/              --
--                                                                          --
------------------------------------------------------------------------------
--! @copyright copyright 2021 desy
--! spdx-license-identifier: cern-ohl-w-2.0
------------------------------------------------------------------------------
--! @date 2021-12-21
--! @author cagil gumus  <cagil.guemues@desy.de>
------------------------------------------------------------------------------
--! @brief
--! mmcm wrapper for the application clock generation
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

library unisim;
use unisim.vcomponents.all;

entity app_mmcm_wrapper is
generic (
  g_ext_freq : natural := 125_000_000
);
port(
  -- clock in ports
  pi_clock0    : in  std_logic;
  pi_clock1    : in  std_logic;
  pi_clock_sel : in  std_logic;
  -- clock out ports
  po_clock_1x : out std_logic;
  po_clock_2x : out std_logic;
  po_clock_3x : out std_logic;
  -- phase shift interface
  pi_psclk    : in std_logic;
  pi_psen     : in std_logic;
  pi_psincdec : in std_logic;
  pi_psdone   : out std_logic;
  -- status and control signals
  pi_reset  : in  std_logic;
  po_locked : out std_logic
);
end app_mmcm_wrapper;

architecture rtl of app_mmcm_wrapper is

  -- input clock buffering / unused connectors
  signal clkin1      : std_logic;
  signal clkin2      : std_logic;
  -- output clock buffering / unused connectors
  signal clkfbout         : std_logic;
  signal clkfbout_buf     : std_logic;
  signal clkfboutb_unused : std_logic;
  signal clkout0          : std_logic;
  signal clkout0b_unused  : std_logic;
  signal clkout1          : std_logic;
  signal clkout1b_unused  : std_logic;
  signal clkout2          : std_logic;
  signal clkout2b_unused  : std_logic;
  signal clkout3_unused   : std_logic;
  signal clkout3b_unused  : std_logic;
  signal clkout4_unused   : std_logic;
  signal clkout5_unused   : std_logic;
  signal clkout6_unused   : std_logic;
  -- dynamic programming unused signals
  signal do_unused        : std_logic_vector(15 downto 0);
  signal drdy_unused      : std_logic;
  -- dynamic phase shift unused signals
  signal psdone_unused    : std_logic;
  -- unused status signals
  signal clkfbstopped_unused : std_logic;
  signal clkinstopped_unused : std_logic;

  function fun_get_clkf_mul( g_ext_freq : natural ) return real is
  begin
    if g_ext_freq >= 95 then
      report "set app clkfbout_mult_f to 6" severity note;
      return 6.00 ;
    elsif g_ext_freq < 95 and g_ext_freq > 50 then
      report "set app clkfbout_mult_f to 12" severity note;
      return 12.00 ;
    else
      report "set app clkfbout_mult_f to 18" severity note;
      return 18.00 ;
    end if;
  end function;

  function fun_get_clk0_div( g_ext_freq : natural ) return real is
  begin
    if g_ext_freq >= 95 then
      report "set app fun_get_clk0_div to 6" severity note;
      return 6.0 ;
    elsif g_ext_freq < 95 and g_ext_freq > 50 then
      report "set app fun_get_clk0_div to 12" severity note;
      return 12.0 ;
    else
      report "set app fun_get_clk0_div to 18" severity note;
      return 18.0 ;
    end if;
  end function;

  function fun_get_clk1_div( g_ext_freq : natural ) return natural is
  begin
    if g_ext_freq >= 95 then
      report "set app fun_get_clk1_div to 3" severity note;
      return 3 ;
    elsif g_ext_freq < 95 and g_ext_freq > 50 then
      report "set app fun_get_clk1_div to 6" severity note;
      return 6 ;
    else
      report "set app fun_get_clk1_div to 9" severity note;
      return 9 ;
    end if;
  end function;

  function fun_get_clk2_div( g_ext_freq : natural ) return natural is
  begin
    if g_ext_freq >= 95 then
      report "set app fun_get_clk2_div to 2" severity note;
      return 2 ;
    elsif g_ext_freq < 95 and g_ext_freq > 50 then
      report "set app fun_get_clk2_div to 4" severity note;
      return 4 ;
    else
      report "set app fun_get_clk2_div to 6" severity note;
      return 6 ;
    end if;
  end function;

  function fun_get_phase_delay( g_ext_freq : natural ) return real is
    variable ret : real;
  begin
    -- add 3 ns delay
    -- ret :=  (0.001 * 360.0 * 3.0 * real(g_ext_freq));

    -- based on measurement dumb formula: (for 80 mhz no phase change required and with 1mhz change 1 deg)
    ret := 80.0 - real(g_ext_freq) ;
    report "set app fun_get_phase_delay to " & real'image(ret) severity note;
    return ret;
  end function;


  constant clkfbout_mult_f : real    := fun_get_clkf_mul(g_ext_freq/1000000);
  constant clkout0_divide  : real    := fun_get_clk0_div(g_ext_freq/1000000);
  constant clkout1_divide  : natural := fun_get_clk1_div(g_ext_freq/1000000);
  constant clkout2_divide  : natural := fun_get_clk2_div(g_ext_freq/1000000);
  constant clkfbout_phase  : real    := fun_get_phase_delay(g_ext_freq/1000000);
  constant clkin_period    : real    := 1000000000.0 / real(g_ext_freq); -- period in ns, freq in hz

begin

  clkin1 <= pi_clock0;
  clkin2 <= pi_clock1;

  -- clocking primitive
  ----------------------------------
  -- instantiation of the mmcm primitive
  -- * unused inputs are tied off
  -- * unused outputs are labeled unused
  inst_mmcm_adv : mmcm_adv
    generic map(
      bandwidth            => "optimized",
      clkout4_cascade      => false,
      clock_hold           => false,
      compensation         => "zhold",
      startup_wait         => false,
      divclk_divide        => 1,
      clkfbout_mult_f      => clkfbout_mult_f,
      clkfbout_phase       => 0.0,
      clkfbout_use_fine_ps => true,
      clkout0_divide_f     => clkout0_divide,
      clkout0_phase        => 0.000,
      clkout0_duty_cycle   => 0.500,
      clkout0_use_fine_ps  => false,
      clkout1_divide       => clkout1_divide,
      clkout1_phase        => 0.000,
      clkout1_duty_cycle   => 0.500,
      clkout1_use_fine_ps  => false,
      clkout2_divide       => clkout2_divide,
      clkout2_phase        => 0.000,
      clkout2_duty_cycle   => 0.500,
      clkout2_use_fine_ps  => false,
      clkin1_period        => clkin_period,
      ref_jitter1          => 0.010,
      clkin2_period        => clkin_period,
      ref_jitter2          => 0.010
    )
    port map(
      clkfbout            => clkfbout,
      clkfboutb           => clkfboutb_unused,
      clkout0             => clkout0,
      clkout0b            => clkout0b_unused,
      clkout1             => clkout1,
      clkout1b            => clkout1b_unused,
      clkout2             => clkout2,
      clkout2b            => clkout2b_unused,
      clkout3             => clkout3_unused,
      clkout3b            => clkout3b_unused,
      clkout4             => clkout4_unused,
      clkout5             => clkout5_unused,
      clkout6             => clkout6_unused,
      -- input clock control
      clkfbin             => clkfbout_buf,
      clkin1              => clkin1,
      clkin2              => clkin2,
      clkinsel            => pi_clock_sel,
      -- ports for dynamic reconfiguration
      daddr               => (others => '0'),
      dclk                => '0',
      den                 => '0',
      di                  => (others => '0'),
      do                  => do_unused,
      drdy                => drdy_unused,
      dwe                 => '0',
      -- ports for dynamic phase shift
      psclk               => pi_psclk,
      psen                => pi_psen,
      psincdec            => pi_psincdec,
      psdone              => pi_psdone,
      -- other control and status signals
      locked              => po_locked,
      clkinstopped        => clkinstopped_unused,
      clkfbstopped        => clkfbstopped_unused,
      pwrdwn              => '0',
      rst                 => pi_reset
    );

  -- output buffering
  -------------------------------------
  clkfb_buf   : bufg port map ( o   => clkfbout_buf , i   => clkfbout);

  clkout1_buf : bufg port map ( o   => po_clock_1x   , i   => clkout0);
  clkout2_buf : bufg port map ( o   => po_clock_2x   , i   => clkout1);
  clkout3_buf : bufg port map ( o   => po_clock_3x   , i   => clkout2);

end rtl;
