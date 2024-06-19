------------------------------------------------------------------------------
--          ____  _____________  __                                         --
--         / __ \/ ____/ ___/\ \/ /                 _   _   _               --
--        / / / / __/  \__ \  \  /                 / \ / \ / \              --
--       / /_/ / /___ ___/ /  / /               = ( M | S | K )=            --
--      /_____/_____//____/  /_/                   \_/ \_/ \_/              --
--                                                                          --
------------------------------------------------------------------------------
--! @copyright Copyright 2021-2022 DESY
--! SPDX-License-Identifier: CERN-OHL-W-2.0
------------------------------------------------------------------------------
--! @date 2021-08-13/2022-01-05
--! @author Lukasz Butkowski  <lukasz.butkowski@desy.de>
------------------------------------------------------------------------------
--! @brief
--! CORDIC algorihtm
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

------------------------------------------------------------------------------------------------------------------------
entity tb_cordic is
end entity tb_cordic;

------------------------------------------------------------------------------------------------------------------------

architecture sim of tb_cordic is

  constant C_THOLD: time := 1 ns;
  -- component generics
  constant g_word_bit_size      : natural := 18;
  constant g_internal_bit_size  : natural := 20;
  constant g_configuration      : natural := 0;
  constant g_operating_mode     : natural := 0;

  constant g_pipelined      : boolean := true;
  constant g_dual_clk_edge  : boolean := true;
  constant g_scale          : boolean := true;

  -- component ports
  signal pi_clock : std_logic                                    := '1';
  signal pi_reset : std_logic                                    := '0';
  signal pi_mode  : std_logic                                    := '0';
  signal pi_valid : std_logic                                    := '0';
  signal pi_x     : std_logic_vector(g_word_bit_size-1 downto 0) := (others => '0');
  signal pi_y     : std_logic_vector(g_word_bit_size-1 downto 0) := (others => '0');
  signal pi_z     : std_logic_vector(g_word_bit_size-1 downto 0) := (others => '0');
  signal po_x     : std_logic_vector(g_word_bit_size-1 downto 0);
  signal po_y     : std_logic_vector(g_word_bit_size-1 downto 0);
  signal po_z     : std_logic_vector(g_word_bit_size-1 downto 0);
  signal po_valid : std_logic;

  signal int_x : integer := 0;
  signal int_y : integer := 0;
  signal int_z : integer := 0;

  signal out_x : integer := 0;
  signal out_y : integer := 0;
  signal out_z : integer := 0;

  signal ver_x : integer := 0;
  signal ver_y : integer := 0;
  signal ver_z : integer := 0;

begin  -- architecture arch

  -- component instantiation
  DUT: entity work.cordic
    generic map (
      g_word_bit_size      => g_word_bit_size,
      g_internal_bit_size  => g_internal_bit_size,
      g_configuration      => g_configuration,
      g_operating_mode     => g_operating_mode,
      g_pipelined          => g_pipelined,
      g_dual_clk_edge      => g_dual_clk_edge,
      g_scale              => g_scale
    )
    port map (
      pi_clock => pi_clock,
      pi_reset => pi_reset,
      pi_mode  => pi_mode,
      pi_valid => pi_valid,
      pi_x     => pi_x,
      pi_y     => pi_y,
      pi_z     => pi_z,
      po_x     => po_x,
      po_y     => po_y,
      po_z     => po_z,
      po_valid => po_valid
    );

  -- clock generation
  pi_clock <= not pi_clock after 5 ns;

  pi_x   <= std_logic_vector(to_signed(int_x,g_word_bit_size));
  pi_y   <= std_logic_vector(to_signed(int_y,g_word_bit_size));
  pi_z   <= std_logic_vector(to_signed(int_z,g_word_bit_size));

  out_x  <= integer(0.60725229 * real(to_integer(signed(po_x))));
  out_y  <= to_integer(signed(po_y));
  out_z  <= to_integer(signed(po_z));

  -- waveform generation
  gen_cir_vect_wave: if g_configuration = 0 and g_operating_mode = 0 generate
    signal loop_i : natural:=2**17;
  begin
    prs_wave: process
    begin
      -- insert signal assignments here
      pi_reset <= '1';
      wait for 100 ns;
      wait until rising_edge(pi_clock);
      wait for C_THOLD;
      pi_reset <= '0';

      wait for 100 ns;
      wait until rising_edge(pi_clock);
      wait for C_THOLD;
      pi_valid <= '1';
      pi_mode  <= '0';
      -- 0 deg - single sample
      int_x <= integer(2**15);
      int_y <= 0;
      wait until rising_edge(pi_clock);
      wait for C_THOLD;

      pi_valid <= '0';
      wait for 200 ns;
      wait until rising_edge(pi_clock);
      wait for C_THOLD;

      -- steam of samples
      pi_mode  <= '0';
      pi_valid <= '1';
      int_x <= 0;--2**15;
      int_y <= 0;--2**15;
      wait until rising_edge(pi_clock);
      wait for C_THOLD;
      -- 0 deg
      int_x <= integer(2**15);
      int_y <= 0;
      wait until rising_edge(pi_clock);
      wait for C_THOLD;
      -- 90 deg
      int_x <= 0;
      int_y <= integer(2**15);
      wait until rising_edge(pi_clock);
      wait for C_THOLD;
      -- 180 deg
      int_x <= -integer(2**15);
      int_y <= 0;
      wait until rising_edge(pi_clock);
      wait for C_THOLD;
      -- 270 deg
      int_x <= 0;
      int_y <= -integer(2**15);
      wait until rising_edge(pi_clock);
      wait for C_THOLD;
      -- 45 deg
      int_x <= integer(2**14);
      int_y <= integer(2**14);
      wait until rising_edge(pi_clock);
      wait for C_THOLD;
      -- 45 deg overflow check
      int_x <= integer(2**17-1);
      int_y <= integer(2**17-1);
      wait until rising_edge(pi_clock);
      wait for C_THOLD;
      -- 0 deg crossing
      int_x <= integer(2**15);
      int_y <= integer(-100);
      loop_i<=0;
      l1: loop
        wait until rising_edge(pi_clock);
        wait for C_THOLD;
        exit l1 when loop_i >= 200;
        int_x <= integer(2**15);
        int_y <= integer(int_y+loop_i);
        loop_i<=loop_i+1;
      end loop;
      -- rotating vector, constant phase change
      loop_i <= 2**16;
      l2:loop
        wait until rising_edge(pi_clock);
        wait for C_THOLD;
        exit l2 when loop_i >= 2**24;
        int_x <= integer(real(2**15) * cos(real(loop_i) * 2.0 * MATH_1_OVER_PI / real(2**18)) )+100;
        int_y <= integer(real(2**15) * sin(real(loop_i) * 2.0 * MATH_1_OVER_PI / real(2**18)) );
        loop_i<=loop_i+10;
      end loop;
      wait;
    end process prs_wave;

  end generate;

      -- waveform generation
  gen_cir_rot_wave: if (g_configuration = 0 and g_operating_mode = 1) generate
    signal loop_i : natural:=0;
  begin
    prs_wave: process
    begin
      -- insert signal assignments here
      pi_reset <= '1';
      wait for 100 ns;
      wait until pi_clock = '1';
      pi_reset <= '0';
      wait for 100 ns;
      wait until rising_edge(pi_clock);
      -----------------------------------------------
      -- rotating
      wait until rising_edge(pi_clock);
      pi_mode  <= '1';
      pi_valid <= '1';
      int_x <= 0;--2**15;
      int_z <= 0;--2**15;
      wait until rising_edge(pi_clock);
      -- 0 deg
      int_x <= integer(2**15);
      int_z <= 0;
      wait until rising_edge(pi_clock);
      -- 90 deg
      int_x <= integer(2**15);
      int_z <= integer(2**(g_word_bit_size-1)/2);
      wait until rising_edge(pi_clock);

      -- around 180 deg, from 180 to -180, phase overflow
      loop_i <= 0;
      l0:  loop
        exit l0 when loop_i >= 40;
        int_x <= integer(2**15);
        int_z <= integer(2**(g_word_bit_size-1)-20) + loop_i;
        loop_i<=loop_i+1;
        wait until rising_edge(pi_clock);
      end loop;

      wait until rising_edge(pi_clock);
      -- 270 deg
      int_x <= integer(2**15);
      int_z <= integer(3*2**(g_word_bit_size-1)/2);
      wait until rising_edge(pi_clock);
      -- 0 deg
      int_x <= integer(2**15);
      int_z <= 0;
      loop_i <= 0;
      l1: loop
        wait until rising_edge(pi_clock);
        exit l1 when loop_i >= 2**g_word_bit_size;
        int_x <= integer(2**15);
        int_z <= loop_i;
        loop_i<=loop_i+1;
      end loop;

      wait;
    end process prs_wave;

  end generate;

end architecture sim;

------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
