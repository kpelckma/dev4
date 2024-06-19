--------------------------------------------------------------------------------
--          ____  _____________  __                                           --
--         / __ \/ ____/ ___/\ \/ /                 _   _   _                 --
--        / / / / __/  \__ \  \  /                 / \ / \ / \                --
--       / /_/ / /___ ___/ /  / /               = ( M | S | K )=              --
--      /_____/_____//____/  /_/                   \_/ \_/ \_/                --
--                                                                            --
--------------------------------------------------------------------------------
--! @copyright (c) 2013 DESY
--! SPDX-License-Identifier: CERN-OHL-W-2.0
--------------------------------------------------------------------------------
--! @date 2013-01-03
--! @author
--! Wojciech Fornal
--! Lukasz Butkowski <lukasz.butkowski@desy.de>
--------------------------------------------------------------------------------
--! @brief IIR filter in Transposed Direct Form I, second order
--!
--! Parallel implementation which utilize five DSP48E1 slices
--! To decrease verbosity, this source file includes an additional entity
--! which is a wrapper for the instantiation of DSP48E1 slice
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity iir_tdf1_o2 is
  port (
    pi_clock      : in  std_logic;
    pi_reset      : in  std_logic;
    pi_reset_dsp  : in  std_logic;

    pi_a1 : in  std_logic_vector(17 downto 0);
    pi_a2 : in  std_logic_vector(17 downto 0);

    pi_b0 : in  std_logic_vector(17 downto 0);
    pi_b1 : in  std_logic_vector(17 downto 0);
    pi_b2 : in  std_logic_vector(17 downto 0);

    pi_valid  : in  std_logic;
    pi_data   : in  std_logic_vector(17 downto 0);

    po_valid  : out std_logic;
    po_data   : out std_logic_vector(17 downto 0)
  );
end entity iir_tdf1_o2;

architecture mixed of iir_tdf1_o2 is

  signal reg_a1 : std_logic_vector(17 downto 0) := (others => '0');
  signal reg_a2 : std_logic_vector(17 downto 0) := (others => '0');
  signal reg_b0 : std_logic_vector(17 downto 0) := (others => '0');
  signal reg_b1 : std_logic_vector(17 downto 0) := (others => '0');
  signal reg_b2 : std_logic_vector(17 downto 0) := (others => '0');

  signal res_a1 : std_logic_vector(47 downto 0) := (others => '0');
  signal res_a2 : std_logic_vector(47 downto 0) := (others => '0');
  signal res_b0 : std_logic_vector(47 downto 0) := (others => '0');
  signal res_b1 : std_logic_vector(47 downto 0) := (others => '0');
  signal res_b2 : std_logic_vector(47 downto 0) := (others => '0');

  signal res_a1_30b : std_logic_vector(29 downto 0) := (others => '0');

  signal data_a     : std_logic_vector(24 downto 0) := (others => '0');
  signal data_b     : std_logic_vector(24 downto 0) := (others => '0');
  signal data_in    : std_logic_vector(17 downto 0) := (others => '0');
  signal data_out   : std_logic_vector(17 downto 0) := (others => '0');
  signal valid_vec  : std_logic_vector(2 downto 0)  := (others => '0');
  signal valid      : std_logic                     := '0';

  signal ovfw_a1  : std_logic := '0';
  signal ovfw_a2  : std_logic := '0';
  signal ovfw_b0  : std_logic := '0';
  signal ovfw_b1  : std_logic := '0';
  signal ovfw_b2  : std_logic := '0';

  component iir_tdf1_o2_dsp is
    port (
      pi_clock    : in  std_logic;
      pi_reset    : in  std_logic;
      pi_clock_en : in  std_logic;
      pi_data_a   : in  std_logic_vector(29 downto 0);
      pi_data_b   : in  std_logic_vector(17 downto 0);
      pi_data_c   : in  std_logic_vector(47 downto 0);
      pi_data_d   : in  std_logic_vector(24 downto 0);
      po_result   : out std_logic_vector(47 downto 0);
      po_ovfw     : out std_logic
    );
  end component iir_tdf1_o2_dsp;

begin

  prs_ioreg: process(pi_clock)
  begin
    if rising_edge(pi_clock) then
      valid     <= pi_valid;
      data_in   <= pi_data;
      po_data   <= data_out;
      po_valid  <= valid_vec(2);
      reg_a2    <= pi_a2;
      reg_a1    <= pi_a1;
      reg_b2    <= pi_b2;
      reg_b1    <= pi_b1;
      reg_b0    <= pi_b0;
    end if;
  end process prs_ioreg;

  data_out <= res_b0(33 downto 16);

  prs_valid: process(pi_clock)
  begin
    if rising_edge(pi_clock) then
      if pi_reset = '1' then
        valid_vec <= (others => '0');
      else
        valid_vec <= valid_vec(valid_vec'left-1 downto 0) & valid;
      end if;
    end if;
  end process prs_valid;

  prs_data: process(pi_clock)
  begin
    if rising_edge(pi_clock) then
      if (pi_reset = '1') then
        data_a <= (others => '0');
        data_b <= (others => '0');
      else
        if (valid = '1') then
          data_a <= std_logic_vector(resize(signed(data_in), 25));
          data_b <= std_logic_vector(resize(signed(data_in), 25));
        end if;
      end if;
    end if;
  end process prs_data;

  res_a1_30b <= std_logic_vector(resize(signed(res_a1(47 downto 16)), 30));

  ins_a2: iir_tdf1_o2_dsp
    port map(
      pi_clock    => pi_clock,
      pi_reset    => pi_reset_dsp,
      pi_clock_en => valid,
      pi_data_a   => res_a1_30b,
      pi_data_d   => data_a,
      pi_data_b   => reg_a2,
      pi_data_c   => (others => '0'),
      po_result   => res_a2,
      po_ovfw     => ovfw_a2
    );

  ins_a1: iir_tdf1_o2_dsp
    port map(
      pi_clock    => pi_clock,
      pi_reset    => pi_reset_dsp,
      pi_clock_en => valid,
      pi_data_a   => res_a1_30b,
      pi_data_d   => data_a,
      pi_data_b   => reg_a1,
      pi_data_c   => res_a2,
      po_result   => res_a1,
      po_ovfw     => ovfw_a1
    );

  ins_b2: iir_tdf1_o2_dsp
    port map(
      pi_clock    => pi_clock,
      pi_reset    => pi_reset_dsp,
      pi_clock_en => valid,
      pi_data_a   => res_a1_30b,
      pi_data_d   => data_b,
      pi_data_b   => reg_b2,
      pi_data_c   => (others => '0'),
      po_result   => res_b2,
      po_ovfw     => ovfw_b2
    );

  ins_b1: iir_tdf1_o2_dsp
    port map(
      pi_clock    => pi_clock,
      pi_reset    => pi_reset_dsp,
      pi_clock_en => valid,
      pi_data_a   => res_a1_30b,
      pi_data_d   => data_b,
      pi_data_b   => reg_b1,
      pi_data_c   => res_b2,
      po_result   => res_b1,
      po_ovfw     => ovfw_b1
    );

  ins_b0: iir_tdf1_o2_dsp
    port map(
      pi_clock    => pi_clock,
      pi_reset    => pi_reset_dsp,
      pi_clock_en => valid,
      pi_data_a   => res_a1_30b,
      pi_data_d   => data_b,
      pi_data_b   => reg_b0,
      pi_data_c   => res_b1,
      po_result   => res_b0,
      po_ovfw     => ovfw_b0
    );

end architecture mixed;

--! DSP48E1 primitive wrapper
library ieee;
use ieee.std_logic_1164.all;

library unisim;
use unisim.vcomponents.all;

entity iir_tdf1_o2_dsp is
  port (
    pi_clock    : in  std_logic;
    pi_reset    : in  std_logic;
    pi_clock_en : in  std_logic;
    pi_data_a   : in  std_logic_vector(29 downto 0);
    pi_data_b   : in  std_logic_vector(17 downto 0);
    pi_data_c   : in  std_logic_vector(47 downto 0);
    pi_data_d   : in  std_logic_vector(24 downto 0);
    po_result   : out std_logic_vector(47 downto 0);
    po_ovfw     : out std_logic
  );
end iir_tdf1_o2_dsp;

architecture structural of iir_tdf1_o2_dsp is

  signal overflow   : std_logic;
  signal underflow  : std_logic;

begin

  po_ovfw <= overflow or underflow;

  ins_dsp : dsp48e1
    generic map (
      use_mult            => "MULTIPLY",
      use_pattern_detect  => "PATDET",
      use_dport           => true,
      alumodereg          => 1,
      adreg               => 0,
      areg                => 0,
      breg                => 0,
      creg                => 0,
      dreg                => 0,
      mreg                => 0,
      preg                => 1,
      opmodereg           => 1,
      acascreg            => 0,
      bcascreg            => 0,
      mask                => x"00FFFFFFFFFF"
    )
    port map (
      clk => pi_clock,

      a     => pi_data_a,
      cea2  => pi_clock_en,
      rsta  => pi_reset,

      b     => pi_data_b,
      ceb2  => pi_clock_en,
      rstb  => pi_reset,

      c     => pi_data_c,
      cec   => pi_clock_en,
      rstc  => pi_reset,

      d     => pi_data_d,
      ced   => pi_clock_en,
      rstd  => pi_reset,

      cem   => pi_clock_en,
      rstm  => pi_reset,

      p     => po_result,
      cep   => pi_clock_en,
      rstp  => pi_reset,

      alumode     => "0000",
      cealumode   => '1',
      rstalumode  => '0',

      opmode  => "0110101",
      cectrl  => '1',
      rstctrl => '0',

      inmode    => "01100",
      ceinmode  => '1',
      rstinmode => '0',

      overflow  => overflow,
      underflow => underflow,

      acin        => "000000000000000000000000000000",
      bcin        => "000000000000000000",
      carrycascin => '0',
      carryin     => '0',
      carryinsel  => "000",
      cea1        => '0',
      ceb1        => '0',
      cead        => '1',
      cecarryin   => '0',

      multsignin    => '0',
      pcin          => x"000000000000",
      rstallcarryin => '0'
    );

end architecture structural;
