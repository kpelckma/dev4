------------------------------------------------------------------------------
--          ____  _____________  __                                         --
--         / __ \/ ____/ ___/\ \/ /                 _   _   _               --
--        / / / / __/  \__ \  \  /                 / \ / \ / \              --
--       / /_/ / /___ ___/ /  / /               = ( M | S | K )=            --
--      /_____/_____//____/  /_/                   \_/ \_/ \_/              --
--                                                                          --
------------------------------------------------------------------------------
--! @copyright Copyright 2022 DESY
--! SPDX-License-Identifier: CERN-OHL-W-2.0
------------------------------------------------------------------------------
--! @date 2022-04-01
--! @author Lukasz Butkowski  <lukasz.butkowski@desy.de>
------------------------------------------------------------------------------
--! @brief
--! Package with DESY library math components
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

package dsp_comp is

  component complex_multiplier is
    generic (
      G_IN0_WIDTH  : natural := 18;
      G_IN0_RADIX  : natural := 16;
      G_IN1_WIDTH  : natural := 18;
      G_IN1_RADIX  : natural := 16;
      G_OUT_WIDTH  : natural := 18;
      G_OUT_RADIX  : natural := 16
    );
    port (
      pi_clock : in  std_logic;
      pi_reset : in  std_logic;

      pi_valid  : in  std_logic;
      pi_re0    : in  std_logic_vector(G_IN0_WIDTH-1 downto 0);
      pi_im0    : in  std_logic_vector(G_IN0_WIDTH-1 downto 0);
      pi_re1    : in  std_logic_vector(G_IN1_WIDTH-1 downto 0);
      pi_im1    : in  std_logic_vector(G_IN1_WIDTH-1 downto 0);

      po_valid  : out std_logic;
      po_re     : out std_logic_vector(G_OUT_WIDTH-1 downto 0);
      po_im     : out std_logic_vector(G_OUT_WIDTH-1 downto 0);
      po_re_of  : out std_logic;
      po_im_of  : out std_logic
      -- component should be cascaded with the following saturation logic if required, consider using registers
      -- re_sat <= (re_sat'left => po_re(po_re'left), others => not(po_re(po_re'left))) when po_re_of = '1' else po_re;
      -- im_sat <= (im_sat'left => po_im(po_im'left), others => not(po_im(po_im'left))) when po_im_of = '1' else po_im;
    );
  end component complex_multiplier;

  component cordic
    generic (
      g_word_bit_size      : natural := 18;
      -- defines CORDIC iterations and bit size, real g_internal_bit_size internal bit size = +1, max 63
      g_internal_bit_size  : natural := 20;
      g_configuration      : natural := 0;    --0:circular, 1:linear, 2:hyperbolic
      g_operating_mode     : natural := 2;    --0: IQ->AP, 1:AP->IQ ; 2: pi_mode enabled,
      g_pipelined          : boolean := true;
      g_dual_clk_edge      : boolean := false;
      g_scale              : boolean := true
    );
    port (
      pi_clock : in std_logic := '0';
      pi_reset : in std_logic := '0';  --active low
      pi_mode  : in std_logic := '0';  --'0':IQ->AP, '1':AP->IQ,

      pi_valid : in std_logic;
      pi_x     : in std_logic_vector(g_word_bit_size-1 downto 0) := (others => '0');
      pi_y     : in std_logic_vector(g_word_bit_size-1 downto 0) := (others => '0');
      pi_z     : in std_logic_vector(g_word_bit_size-1 downto 0) := (others => '0');

      po_x     : out std_logic_vector(g_word_bit_size-1 downto 0);
      po_y     : out std_logic_vector(g_word_bit_size-1 downto 0);
      po_z     : out std_logic_vector(g_word_bit_size-1 downto 0);
      po_valid : out std_logic
    );
  end component cordic;

  component divider_restoring is
    generic (
      g_bit_size_n : natural := 18;     --nominator
      g_bit_size_d : natural := 18;     --denumerator
      g_bit_size_q : natural := 36
    );
    port (
      pi_clock : in std_logic;
      pi_reset : in std_logic;

      pi_nominator   : in std_logic_vector(g_bit_size_n-1 downto 0);
      pi_denumerator : in std_logic_vector(g_bit_size_d-1 downto 0);
      pi_rdy         : in std_logic;

      po_quotient : out std_logic_vector(g_bit_size_q-1 downto 0) := (others => '0');
      po_rdy      : out std_logic
    );
  end component divider_restoring;

  component mult_dsp48 is
    generic (
      g_a_data_width : natural ;
      g_b_data_width : natural
    );
    port (
      pi_clock : in std_logic;
      pi_reset : in std_logic;
      pi_data_a : in std_logic_vector(g_a_data_width - 1 downto 0);
      pi_data_b : in std_logic_vector(g_b_data_width - 1 downto 0);
      po_mult : out std_logic_vector(g_a_data_width + g_b_data_width - 1 downto 0) ---pipelined product output
    );
  end component;

end package dsp_comp;
