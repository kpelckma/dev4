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
--! @dir  sim/tb
--! @file tb_complex_multiplier.vhd   
-------------------------------------------------------------------------------
--! @brief  Testbench for complex multiplier with cascaded saturation block
-------------------------------------------------------------------------------
--! @author Burak Dursun
--! @email  burak.dursun@desy.de
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

library desy;
use desy.common_types.all;

entity tb_complex_multiplier is
  generic (
    --! Test Settings
    G_TEST_PERIOD     : time            := 10 us;
    G_RESET_RELEASE   : time            := 100 ns;
    G_RESET_PULSE     : time            := 8.5 us;
    G_SEQUENCE_START  : time            := 200 ns;
    G_CLOCK_PERIOD    : time            := 10 ns;
    G_SAMPLE_PERIOD   : time            := 90 ns;
    G_SCALE           : t_natural_array := (1, 4, 0);
    G_ROTATE          : t_integer_array := (0, 1, -1);
    G_AMP_MIN         : real            := 0.79;
    G_AMP_MAX         : real            := 0.8;
    G_PHA_MIN         : real            := 0.19;
    G_PHA_MAX         : real            := 0.2;
    G_SEED1           : positive        := 1;
    G_SEED2           : positive        := 1;
    G_AMP_THRESHOLD   : real            := 7.8E-5;
    G_PHA_THRESHOLD   : real            := 7.8E-5;
    G_I_THRESHOLD     : real            := 7.8E-5;
    G_Q_THRESHOLD     : real            := 7.8E-5;
    --! DUT Generics
    G_IN0_WIDTH : natural := 18;
    G_IN0_RADIX : natural := 14;
    G_IN1_WIDTH : natural := 18;
    G_IN1_RADIX : natural := 16;
    G_OUT_WIDTH : natural := 18;
    G_OUT_RADIX : natural := 16
  );
end entity tb_complex_multiplier;

architecture tb of tb_complex_multiplier is

  alias C_SCALE   : t_natural_array(0 to G_SCALE'length-1) is G_SCALE;
  alias C_ROTATE  : t_integer_array(0 to G_ROTATE'length-1) is G_ROTATE;

  constant C_TEST_PERIOD  : real  := real(G_TEST_PERIOD / 1 ns);
  constant C_SFRAME       : real  := real(G_SCALE'length-1) / C_TEST_PERIOD; 
  constant C_RFRAME       : real  := real(G_ROTATE'length-1) / C_TEST_PERIOD; 

  signal clock    : std_logic := '0';
  signal reset    : std_logic := '0';
  signal i_valid  : std_logic := '0';
  signal i_re0    : std_logic_vector(G_IN0_WIDTH-1 downto 0)  := (others => '0');
  signal i_im0    : std_logic_vector(G_IN0_WIDTH-1 downto 0)  := (others => '0');
  signal i_re1    : std_logic_vector(G_IN1_WIDTH-1 downto 0)  := (others => '0');
  signal i_im1    : std_logic_vector(G_IN1_WIDTH-1 downto 0)  := (others => '0');
  signal o_valid  : std_logic := '0';
  signal o_re     : std_logic_vector(G_OUT_WIDTH-1 downto 0)  := (others => '0');
  signal o_im     : std_logic_vector(G_OUT_WIDTH-1 downto 0)  := (others => '0');
  signal o_re_of  : std_logic := '0';
  signal o_im_of  : std_logic := '0';

  signal valid    : std_logic := '0';
  signal out_i    : std_logic_vector(G_OUT_WIDTH-1 downto 0)  := (others => '0');
  signal out_q    : std_logic_vector(G_OUT_WIDTH-1 downto 0)  := (others => '0');

  signal scaling  : real  := 0.0;
  signal rotation : real  := 0.0;
  signal in_amp   : real  := 0.0;
  signal in_pha   : real  := 0.0;
  signal out_amp  : real  := 0.0;
  signal out_pha  : real  := 0.0;
  signal exp_amp  : real  := 0.0;
  signal exp_pha  : real  := 0.0;
  signal err_amp  : real  := 0.0;
  signal err_pha  : real  := 0.0;
  signal exp_i    : real  := 0.0;
  signal exp_q    : real  := 0.0;
  signal err_i    : real  := 0.0;
  signal err_q    : real  := 0.0;

  type t_test_result is (fail, pass, idle);
  signal test_res : t_test_result := idle;
  signal test_cnt : natural       := 0;
  signal test_err : natural       := 0;
  signal test_end : boolean       := false;

begin

  ins_dut1: entity work.complex_multiplier
    generic map (
      G_IN0_WIDTH => G_IN0_WIDTH,
      G_IN0_RADIX => G_IN0_RADIX,
      G_IN1_WIDTH => G_IN1_WIDTH,
      G_IN1_RADIX => G_IN1_RADIX,
      G_OUT_WIDTH => G_OUT_WIDTH,
      G_OUT_RADIX => G_OUT_RADIX
    )
    port map (
      pi_clock  => clock,
      pi_reset  => reset,

      pi_valid  => i_valid,
      pi_re0    => i_re0,
      pi_im0    => i_im0,
      pi_re1    => i_re1,
      pi_im1    => i_im1,

      po_valid  => o_valid,
      po_re     => o_re,
      po_im     => o_im,
      po_re_of  => o_re_of,
      po_im_of  => o_im_of
    );

  blk_dut2: block
  begin
    prs_sat: process(clock)
    begin
      if rising_edge(clock) then
        valid <= o_valid and not(reset);
        if reset = '1' then
          out_i <= (others => '0');
          out_q <= (others => '0');
        elsif o_valid = '1' then
          if o_re_of = '1' then
            out_i <= (out_i'left => o_re(o_re'left), others => not(o_re(o_re'left)));
          else
            out_i <= o_re;
          end if;
          if o_im_of = '1' then
            out_q <= (out_q'left => o_im(o_im'left), others => not(o_im(o_im'left)));
          else
            out_q <= o_im;
          end if;
        end if;
      end if;
    end process prs_sat;
  end block blk_dut2;

  prs_clock: process
  begin
    if not test_end then
      clock <= '1';
      wait for G_CLOCK_PERIOD/2;
      clock <= '0';
      wait for G_CLOCK_PERIOD/2;
    else
      --! stop the clock at the end of test
      assert test_err = 0                                                       
      report integer'image(test_err) & "/" & integer'image(test_cnt) & " Test Failed!"
      severity error;
      wait;
    end if;
  end process prs_clock;

  prs_reset: process
  begin
    reset <= '1';
    wait for G_RESET_RELEASE-G_CLOCK_PERIOD;
    wait until rising_edge(clock);
    reset <= '0';
    wait for G_RESET_PULSE-G_CLOCK_PERIOD;
    wait until rising_edge(clock);
    reset <= '1';
    wait until rising_edge(clock);
    reset <= '0';
    wait;
  end process prs_reset;

  prs_sequencer: process
    variable v_seed1    : positive  := G_SEED1;
    variable v_seed2    : positive  := G_SEED2;
    variable v_rand     : real;
    variable v_time     : real;
    variable v_scale    : integer;
    variable v_rotate   : integer;
    variable v_scaling  : real;
    variable v_rotation : real;
    variable v_in_amp   : real;
    variable v_in_pha   : real;
  begin
    wait until rising_edge(clock);
    if now >= G_TEST_PERIOD then
      report "End of Test!";
      test_end <= true;
      wait;
    end if;
    if now >= G_SEQUENCE_START then
      test_cnt <= test_cnt + 1;
      v_time      := real(now / 1 ns);
      v_scale     := integer(floor(v_time * C_SFRAME));
      v_scaling   := real(C_SCALE(v_scale)) + real(C_SCALE(v_scale+1) - C_SCALE(v_scale)) * ((v_time * C_SFRAME) - real(v_scale));
      v_rotate    := integer(floor(v_time * C_RFRAME));
      v_rotation  := real(C_ROTATE(v_rotate)) + real(C_ROTATE(v_rotate+1) - C_ROTATE(v_rotate)) * ((v_time * C_RFRAME) - real(v_rotate));
      scaling     <= v_scaling;
      rotation    <= v_rotation;
      i_re0       <= std_logic_vector(to_unsigned(integer(v_scaling*cos(v_rotation*MATH_PI) * 2**G_IN0_RADIX), G_IN0_WIDTH));
      i_im0       <= std_logic_vector(to_unsigned(integer(v_scaling*sin(v_rotation*MATH_PI) * 2**G_IN0_RADIX), G_IN0_WIDTH));
      uniform(v_seed1, v_seed2, v_rand);
      v_in_amp    := G_AMP_MIN + (G_AMP_MAX - G_AMP_MIN) * v_rand;
      uniform(v_seed1, v_seed2, v_rand);
      v_in_pha    := G_PHA_MIN + (G_PHA_MAX - G_PHA_MIN) * v_rand;
      in_amp      <= v_in_amp;
      in_pha      <= v_in_pha;
      i_re1       <= std_logic_vector(to_unsigned(integer(v_in_amp*cos(v_in_pha*MATH_PI) * 2**G_IN1_RADIX), G_IN1_WIDTH));
      i_im1       <= std_logic_vector(to_unsigned(integer(v_in_amp*sin(v_in_pha*MATH_PI) * 2**G_IN1_RADIX), G_IN1_WIDTH));
      i_valid     <= '1';
      if G_SAMPLE_PERIOD > G_CLOCK_PERIOD then
        wait until rising_edge(clock);
        i_valid <= '0';
        wait for G_SAMPLE_PERIOD-G_CLOCK_PERIOD;
      end if;
    end if;
  end process prs_sequencer;

  prs_model: process(clock)
    constant C_MAX  : real  := real(to_integer(signed(std_logic_vector'('0' & (G_OUT_WIDTH-2 downto 0 => '1'))))) / real(2**G_OUT_RADIX);
    constant C_MIN  : real  := real(to_integer(signed(std_logic_vector'('1' & (G_OUT_WIDTH-2 downto 0 => '0'))))) / real(2**G_OUT_RADIX);
    constant C_DUT1_LATENCY : natural := 2;
    type t_real_array is array (natural range <>) of real;
    variable v_exp_amp  : t_real_array(C_DUT1_LATENCY-1 downto 0);
    variable v_exp_pha  : t_real_array(C_DUT1_LATENCY-1 downto 0);
    variable v_exp_i    : real;
    variable v_exp_q    : real;
  begin
    if rising_edge(clock) then
      if reset = '1' then
        v_exp_amp := (others => 0.0);
        v_exp_pha := (others => 0.0);
        exp_i     <= 0.0;
        exp_q     <= 0.0;
        exp_amp   <= 0.0;
        exp_pha   <= 0.0;
      else
        v_exp_amp(C_DUT1_LATENCY-1 downto 1) := v_exp_amp(C_DUT1_LATENCY-2 downto 0);
        v_exp_pha(C_DUT1_LATENCY-1 downto 1) := v_exp_pha(C_DUT1_LATENCY-2 downto 0);
        if i_valid = '1' then
          v_exp_amp(0) := scaling * in_amp;
          v_exp_pha(0) := rotation + in_pha;
        end if;
        if o_valid = '1' then
          v_exp_i := v_exp_amp(C_DUT1_LATENCY-1)*cos(v_exp_pha(C_DUT1_LATENCY-1)*MATH_PI);
          if v_exp_i > C_MAX then
            v_exp_i := C_MAX;
          elsif v_exp_i < C_MIN then
            v_exp_i := C_MIN;
          end if;
          v_exp_q := v_exp_amp(C_DUT1_LATENCY-1)*sin(v_exp_pha(C_DUT1_LATENCY-1)*MATH_PI);
          if v_exp_q > C_MAX then
            v_exp_q := C_MAX;
          elsif v_exp_q < C_MIN then
            v_exp_q := C_MIN;
          end if;
          exp_i   <= v_exp_i;
          exp_q   <= v_exp_q;
          exp_amp <= sqrt(v_exp_i*v_exp_i + v_exp_q*v_exp_q);
          exp_pha <= arctan(v_exp_q/v_exp_i)/MATH_PI;
        end if;
      end if;
    end if;
  end process prs_model;

  blk_checker: block
    signal l_out_i    : real;
    signal l_out_q    : real;
    signal l_out_amp  : real;
    signal l_out_pha  : real;
    signal l_error    : std_logic_vector(3 downto 0)  := (others => '0');
  begin

    l_out_i     <= real(to_integer(signed(out_i))) / real(2**G_OUT_RADIX);
    l_out_q     <= real(to_integer(signed(out_q))) / real(2**G_OUT_RADIX);
    err_i       <= exp_i - l_out_i;
    err_q       <= exp_q - l_out_q;
    l_out_amp   <= sqrt(l_out_i*l_out_i + l_out_q*l_out_q);
    l_out_pha   <= arctan(l_out_q/l_out_i)/MATH_PI;
    out_amp     <= l_out_amp;
    out_pha     <= l_out_pha;
    err_amp     <= exp_amp - l_out_amp;
    err_pha     <= exp_pha - l_out_pha;
    l_error(0)  <= '1' when abs(err_i) > G_I_THRESHOLD else '0';
    l_error(1)  <= '1' when abs(err_q) > G_Q_THRESHOLD else '0';
    l_error(2)  <= '1' when abs(err_amp) > G_AMP_THRESHOLD else '0';
    l_error(3)  <= '1' when abs(err_pha) > G_PHA_THRESHOLD else '0';

    prs_checker: process(clock)
    begin
      if rising_edge(clock) then
        if valid = '1' then
          if l_error /= "0000" then
            test_res <= fail;
            test_err <= test_err + 1;
            report "Test " & integer'image(test_cnt) & " FAILED" severity error;
          else
            test_res <= pass;
            report "Test " & integer'image(test_cnt) & " PASSED";
          end if;
        end if;
      end if;
    end process prs_checker;

  end block blk_checker;

end architecture tb;
