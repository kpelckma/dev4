--------------------------------------------------------------------------------
--          ____  _____________  __                                           --
--         / __ \/ ____/ ___/\ \/ /                 _   _   _                 --
--        / / / / __/  \__ \  \  /                 / \ / \ / \                --
--       / /_/ / /___ ___/ /  / /               = ( M | S | K )=              --
--      /_____/_____//____/  /_/                   \_/ \_/ \_/                --
--                                                                            --
--------------------------------------------------------------------------------
--! @copyright (c) 2013-2022 DESY
--! SPDX-License-Identifier: CERN-OHL-W-2.0
--------------------------------------------------------------------------------
--! @date 2013-01-03/2022-11-17
--! @author Wojciech Jalmuzna
--! @author Burak Bursun
--------------------------------------------------------------------------------
--! @brief IIR filter in Direct Form I, second order
--!
--! Serial implementation which utilize single DSP48E (no pre-adder) slice
--! TODO: add backpressure i.e. po_ready
--! TODO: merge processes into single fsm to utilize less registers
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library unisim;
use unisim.vcomponents.all;

entity iir_df1_o2 is
  port (
    pi_clock  : in std_logic;
    pi_reset  : in std_logic;

    pi_a1 : in std_logic_vector(17 downto 0);
    pi_a2 : in std_logic_vector(17 downto 0);

    pi_b0 : in std_logic_vector(17 downto 0);
    pi_b1 : in std_logic_vector(17 downto 0);
    pi_b2 : in std_logic_vector(17 downto 0);

    pi_data   : in  std_logic_vector(17 downto 0);
    pi_valid  : in  std_logic;

    po_data   : out std_logic_vector(17 downto 0);
    po_valid  : out std_logic
  );
end iir_df1_o2;

architecture rtl of iir_df1_o2 is

  signal state      : natural;
  signal valid      : std_logic_vector(7 downto 0);
  signal sig_mode   : std_logic_vector(1 downto 0);
  signal mux_mode   : std_logic_vector(7 downto 0);
  signal dsp_mode   : std_logic_vector(6 downto 0);
  signal presub     : std_logic_vector(47 downto 0);
  signal prepresub  : std_logic_vector(47 downto 0);
  signal feedback   : std_logic_vector(47 downto 0);
  signal dsp_a      : std_logic_vector(29 downto 0);
  signal dsp_b      : std_logic_vector(17 downto 0);
  signal dsp_p      : std_logic_vector(47 downto 0) := (others => '0');
  signal dsp_ce     : std_logic;

begin

  prs_mux: process(mux_mode, pi_a2, pi_a1, pi_b2, pi_b1, pi_b0, presub, prepresub)
  begin
    case mux_mode is
      when "00000000" =>
        dsp_b <= pi_a2;
        dsp_a <= prepresub(29 downto 0);
        dsp_ce <= '1';
      when "00000001" =>
        dsp_b <= pi_a1;
        dsp_a <= presub(29 downto 0);
        dsp_ce <= '1';
      when "00000010" =>
        dsp_b <= pi_b0;
        dsp_a <= presub(29 downto 0);
        dsp_ce <= '1';
      when "00000011" =>
        dsp_b <= pi_b1;
        dsp_a <= presub(29 downto 0);
        dsp_ce <= '1';
      when "00000100" =>
        dsp_b <= pi_b2;
        dsp_a <= prepresub(29 downto 0);
        dsp_ce <= '1';
      when others =>
        dsp_b <= (others => '0');
        dsp_a <= (others => '0');
        dsp_ce <= '0';
    end case;
  end process prs_mux;

  prs_in: process(pi_clock)
  begin
    if rising_edge(pi_clock) then
      if pi_reset = '1' then
        valid  <= (others => '0');
        presub <= (others => '0');
      else
        if pi_valid = '1' then
          presub <= std_logic_vector(resize(signed(pi_data), 48) - signed(feedback));
        end if;
        valid <= valid(valid'left-1 downto 0) & pi_valid;
      end if ;
    end if;
  end process prs_in;

  prs_dsp_mode: process(pi_clock)
  begin
    if rising_edge(pi_clock) then
      if sig_mode = "01" then
        dsp_mode <= "0100101";
      elsif sig_mode = "10" then
        dsp_mode <= "0110101";
      else
        dsp_mode <= "0000101";
      end if;
    end if;
  end process prs_dsp_mode;

  prs_out: process(pi_clock)
  begin
    if rising_edge(pi_clock) then
      if pi_reset = '1' then
        po_valid  <= '0';
        po_data   <= (others => '0');
        feedback  <= (others => '0');
        prepresub <= (others => '0');
      else
        if valid(4) = '1' then
          feedback  <= std_logic_vector(shift_right(signed(dsp_p), 16));
          prepresub <= presub;
        end if;
        if valid(5) = '1' then
          po_data   <= dsp_p(33 downto 16);
        end if;
        po_valid <= valid(5) ;
      end if;
    end if;
  end process prs_out;

  prs_fsm: process(pi_clock)
  begin
    if rising_edge(pi_clock) then
      if pi_reset = '1' then
        state     <= 0;
        sig_mode  <= "00";
        mux_mode  <= "11111111";
      else
        case state is
          when 1 =>
            state     <= 2;
            sig_mode  <= "01";
            mux_mode  <= "00000001";
          when 2 =>
            state     <= 3;
            sig_mode  <= "10";
            mux_mode  <= "00000010";
          when 3 =>
            state     <= 4 ;
            sig_mode  <= "00";
            mux_mode  <= "00000011";
          when 4 =>
            state     <= 0 ;
            sig_mode  <= "01";
            mux_mode  <= "00000100";
          when others =>
            sig_mode  <= "00";
            mux_mode  <= "11111111";
            if pi_valid = '1' then
              state     <= 1 ;
              mux_mode  <= "00000000";
            end if ;
        end case;
      end if;
    end if;
  end process prs_fsm;

  ins_dsp: dsp48e
    generic map (
      alumodereg  => 1,
      areg        => 1,
      breg        => 1,
      creg        => 1,
      mreg        => 1,
      preg        => 1,
      opmodereg   => 1
    )
    port map (
      clk => pi_clock,

      a     => dsp_a,
      cea2  => dsp_ce,
      rsta  => pi_reset,

      b     => dsp_b,
      ceb2  => dsp_ce,
      rstb  => pi_reset,

      c     => dsp_p,
      cec   => valid(7),
      rstc  => pi_reset,

      cem   => '1',
      rstm  => pi_reset,

      p     => dsp_p,
      cep   => '1',
      rstp  => pi_reset,

      alumode     => "0000",
      cealumode   => '1',
      rstalumode  => pi_reset,

      opmode  => dsp_mode,
      cectrl  => '1',
      rstctrl => pi_reset,

      acin          => "000000000000000000000000000000",
      bcin          => "000000000000000000",
      carrycascin   => '0',
      carryin       => '0',
      carryinsel    => "000",
      cea1          => '0',
      ceb1          => '0',
      cecarryin     => '0',
      cemultcarryin => '0',
      multsignin    => '0',
      pcin          => x"000000000000",
      rstallcarryin => '0'
    );

end rtl;
