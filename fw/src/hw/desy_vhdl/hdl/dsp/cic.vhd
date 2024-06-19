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
--! @date 2022-08-05
--! @author Andrea Bellandi
------------------------------------------------------------------------------
--! @brief
--! Cascasded Comb Integrator filter (CIC) to decimate/interpolate a continuous
--! stream of values.
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

library desy;
use desy.common_logic_utils.all;
use desy.math_utils.all;
use desy.math_signed.all;

-- vsg_off : port_012

--! Cascaded Comb Integrator filter (CIC) to decimate/interpolate a +
--! continuous stream of values. `G_DATA_LENGTH` is the length of input_output_data
--! The filter is characterized by the parameters +
--! `G_R`, `G_N` and `G_M`. `G_R` is the sample rate change for the signal, +
--! `G_N` is the filter order that determines the stopband rejection, and `G_M` +
--! is the differential delay.
--! `G_MODE` defines either if the cic is used as a `"decimator"` or `"interpolator"`.
--! An internal counter is used to activate the decimating/interpolating +
--! sampling if `G_EXT_TRIGGER` is `false`.
--! When `G_EXT_TRIGGER` is `true` the CIC sampler is driven by `pi_sampler_trg` +
--! (ignored otherwise). In this mode if `G_SYNCH_TRIGGER`, the propagation of +
--! `pi_sampler_trg` is synchronized with `pi_stb`.
entity cic is
  generic(
    G_DATA_LENGTH   : positive;
    G_R             : positive;
    G_N             : positive;
    G_M             : positive := 1;
    G_MODE          : string   := "decimator";
    G_EXT_TRIGGER   : boolean  := false;
    G_SYNCH_TRIGGER : boolean  := true);
  port(
    pi_clk         : in  std_logic;
    pi_rst         : in  std_logic;
    pi_stb         : in  std_logic;
    pi_data        : in  std_logic_vector(G_DATA_LENGTH-1 downto 0);
    po_vld         : out std_logic;
    po_data        : out std_logic_vector(G_DATA_LENGTH-1 downto 0);
    pi_sampler_trg : in  std_logic := '0'
  );
end entity cic;

-- vsg_on

architecture arch of cic is

  constant C_R_REAL            : real := real(G_R);
  constant C_N_REAL            : real := real(G_N);
  constant C_M_REAL            : real := real(G_M);

  -- due to CIC gain
  constant C_BIT_INCREASE      : natural := natural(ceil(C_N_REAL *
                                                         log(C_R_REAL * C_M_REAL) /
                                                         log(2.0)));
  constant C_STAGE_LENGTH      : natural := G_DATA_LENGTH + C_BIT_INCREASE;
  constant C_COUNTER_LENGTH    : natural := f_unsigned_length(G_R);

  type t_stages is array (G_N - 1 downto 0) of signed(C_STAGE_LENGTH - 1 downto 0);

  type t_comb_z is array (G_M - 1 downto 0) of t_stages;

  signal reg_sampler_cnt       : unsigned(C_COUNTER_LENGTH - 1 downto 0);
  signal sig_sampler_next_cnt  : unsigned(C_COUNTER_LENGTH - 1 downto 0);
  signal sig_integrator_stages : t_stages;
  signal reg_integrator_stages : t_stages;
  signal sig_integrator_ena    : std_logic_vector(G_N - 1 downto 0);
  signal reg_integrator_ena    : std_logic_vector(G_N - 1 downto 0);
  signal sig_comb_stages       : t_stages;
  signal reg_comb_stages       : t_stages;
  signal reg_comb_z            : t_comb_z;
  signal sig_comb_ena          : std_logic_vector(G_N - 1 downto 0);
  signal reg_comb_ena          : std_logic_vector(G_N - 1 downto 0);
  signal reg_sampler_ext_trg   : std_logic_vector(G_N - 1 downto 0);
  signal reg_sampler_int_trg   : std_logic;
  signal sig_sampler_trg       : std_logic;

  signal data_out   : signed(G_DATA_LENGTH - 1 downto 0);

begin

  -- Integrator section
  prs_integrator : process (pi_clk) is
  begin

    if rising_edge(pi_clk) then

      for i in 0 to G_N - 1 loop

        if (sig_integrator_ena(i) = '1') then
          reg_integrator_stages(i) <= reg_integrator_stages(i) + sig_integrator_stages(i);
        end if;

      end loop;

      reg_integrator_ena <= sig_integrator_ena;

      if (pi_rst = '1') then
        reg_integrator_ena    <= (others => '0');
        reg_integrator_stages <= (others => (others => '0'));
      end if;
    end if;

  end process prs_integrator;

  gen_integrator_sig : for i in 1 to G_N - 1 generate
    sig_integrator_ena(i)    <= reg_integrator_ena(i - 1);
    sig_integrator_stages(i) <= reg_integrator_stages(i - 1);
  end generate gen_integrator_sig;

  -- Comb section
  prs_comb : process (pi_clk) is
  begin

    if rising_edge(pi_clk) then

      for i in 0 to G_N - 1 loop

        if (sig_comb_ena(i) = '1') then
          reg_comb_stages(i) <= sig_comb_stages(i) - reg_comb_z(G_M - 1)(i);
          reg_comb_z(0)(i)   <= sig_comb_stages(i);

          for j in 1 to G_M - 1 loop

            reg_comb_z(j)(i) <= reg_comb_z(j - 1)(i);

          end loop;

        end if;

      end loop;

      reg_comb_ena <= sig_comb_ena;

      if (pi_rst = '1') then
        reg_comb_ena    <= (others => '0');
        reg_comb_stages <= (others => (others => '0'));
        reg_comb_z      <= (others => (others => (others => '0')));
      end if;
    end if;

  end process prs_comb;

  gen_comb_sig : for i in 1 to G_N - 1 generate
    sig_comb_ena(i)    <= reg_comb_ena(i - 1);
    sig_comb_stages(i) <= reg_comb_stages(i - 1);
  end generate gen_comb_sig;

  prs_sampler : process (pi_clk) is
  begin

    if rising_edge(pi_clk) then
      reg_sampler_ext_trg(0) <= pi_sampler_trg;

      for i in 1 to G_N - 1 loop

        reg_sampler_ext_trg(i) <= reg_sampler_ext_trg(i - 1);

      end loop;

      if (G_MODE = "decimator") then
        -- in decimator mode, increase the counter every time a new sample
        -- arrives from the integrator section

        reg_sampler_int_trg <= '0';

        if (sig_integrator_ena(G_N - 1) = '1') then
          reg_sampler_cnt <= sig_sampler_next_cnt;

          if (reg_sampler_cnt = G_R - 1) then
            reg_sampler_int_trg <= '1';
          end if;
        end if;
      else
        -- in interpolator mode, burst the counter when a new sample arrives
        -- from the comb

        reg_sampler_int_trg <= '0';

        if (sig_comb_ena(G_N - 1) = '1' or reg_sampler_cnt /= 0) then
          reg_sampler_cnt     <= sig_sampler_next_cnt;
          reg_sampler_int_trg <= '1';
        end if;
      end if;

      if (pi_rst = '1') then
        reg_sampler_cnt     <= to_unsigned(0, C_COUNTER_LENGTH);
        reg_sampler_ext_trg <= (others => '0');
        reg_sampler_int_trg <= '0';
      end if;
    end if;

  end process prs_sampler;

  -- Next value for the counter
  sig_sampler_next_cnt <= to_unsigned(0, C_COUNTER_LENGTH) when
                                                                reg_sampler_cnt = G_R - 1 else
                          reg_sampler_cnt + 1;

  -- External triggering
  gen_ext_trg : if G_EXT_TRIGGER generate

    gen_synch_trg : if G_SYNCH_TRIGGER generate
      sig_sampler_trg <= reg_sampler_ext_trg(G_N - 1);
    end generate gen_synch_trg;

    gen_not_synch_trg : if not G_SYNCH_TRIGGER generate
      sig_sampler_trg <= pi_sampler_trg;
    end generate gen_not_synch_trg;

  end generate gen_ext_trg;

  -- Internal triggering
  gen_int_trg : if not G_EXT_TRIGGER generate
    sig_sampler_trg <= reg_sampler_int_trg;
  end generate gen_int_trg;

  gen_decimator_trg : if G_MODE = "decimator" generate
    sig_integrator_ena(0)    <= pi_stb;
    sig_integrator_stages(0) <= resize(signed(pi_data), C_STAGE_LENGTH);
    sig_comb_ena(0)          <= sig_sampler_trg;
    sig_comb_stages(0)       <= reg_integrator_stages(G_N - 1);
    po_vld                   <= reg_comb_ena(G_N - 1);
    data_out                 <= f_resize_lsb(reg_comb_stages(G_N - 1),
                                             G_DATA_LENGTH);
  end generate gen_decimator_trg;

  gen_interpolator_trg : if G_MODE /= "decimator" generate
    sig_comb_ena(0)          <= pi_stb;
    sig_comb_stages(0)       <= resize(signed(pi_data), C_STAGE_LENGTH);
    sig_integrator_ena(0)    <= sig_sampler_trg;
    sig_integrator_stages(0) <= reg_comb_stages(G_N - 1);
    po_vld                   <= reg_integrator_ena(G_N - 1);
    data_out                 <= f_resize_lsb(reg_integrator_stages(G_N - 1),
                                             G_DATA_LENGTH);
  end generate gen_interpolator_trg;

  po_data <= std_logic_vector(data_out);

end architecture arch;
