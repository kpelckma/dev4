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
--! @author Lukasz Butkowski <lukasz.butkowski@desy.de>
--------------------------------------------------------------------------------
--! @brief detects if amplitude exceeds the limit value
--!
--! compares Amplitude with limit value for each channel
--! G_MODE = 0, all channels share same resources to calculate Amplitude from IQ
--! G_MODE = 1, Amplitude is available as input per channel
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library desy;
use desy.common_types.all;

entity amp_limit_detect is
  generic (
    G_CHANNEL : natural := 8;
    G_MODE    : natural := 1
  );
  port (
    pi_clock  : in  std_logic;

    --! lsb is effective for all channels when G_MODE = 0
    pi_reset  : in  std_logic_vector(G_CHANNEL-1 downto 0);
    pi_enable : in  std_logic_vector(G_CHANNEL-1 downto 0);

    pi_limit  : in  t_18b_slv_vector(G_CHANNEL-1 downto 0);

    pi_i      : in  t_18b_slv_vector(G_CHANNEL-1 downto 0) := (others => (others => '0'));
    pi_q      : in  t_18b_slv_vector(G_CHANNEL-1 downto 0) := (others => (others => '0'));
    pi_amp    : in  t_18b_slv_vector(G_CHANNEL-1 downto 0) := (others => (others => '0'));
    pi_valid  : in  std_logic_vector(G_CHANNEL-1 downto 0);

    po_limit  : out std_logic_vector(G_CHANNEL-1 downto 0)
  );
end entity amp_limit_detect;

architecture rtl of amp_limit_detect is

begin

  --! TODO: add backpressure for G_MODE = 0
  gen_mode_0: if G_MODE = 0 generate

    type t_dsp is array (2 downto 0) of signed(35 downto 0);

    signal dsp_p  : t_dsp;
    signal limit  : std_logic_vector(G_CHANNEL-1 downto 0);
    signal valid  : std_logic := '0';

  begin

    prs_mode_0: process(pi_clock)
      variable v_channel  : natural;
      variable v_power    : signed(35 downto 0);
    begin
      if rising_edge(pi_clock) then

        if pi_valid(0) = '1' and pi_enable(0) = '1' then
          v_channel := 0;
          valid <= '1';
        end if;

        dsp_p(0) <= signed(pi_i(v_channel)) * signed(pi_i(v_channel));
        dsp_p(1) <= signed(pi_q(v_channel)) * signed(pi_q(v_channel));
        dsp_p(2) <= signed(pi_limit(v_channel)) * signed(pi_limit(v_channel));

        if pi_reset(0) = '1' then
          limit <= (others => '0');
        elsif valid = '1' then
          v_power := dsp_p(0) + dsp_p(1);
          if v_power > dsp_p(2) then
            limit(v_channel-1) <= '1';
          end if;
        end if;

        if v_channel < G_CHANNEL then
          v_channel := v_channel + 1;
        else
          valid <= '0';
          po_limit <= limit and pi_enable ;
        end if;

      end if;
    end process prs_mode_0;

  end generate gen_mode_0;

  gen_mode_1: if G_MODE = 1 generate 
    gen_channel: for I in 0 to G_CHANNEL-1 generate
      prs_limit: process(pi_clock)
      begin
        if rising_edge(pi_clock) then
          if pi_reset(I) = '1' then
            po_limit(I) <= '0' ;
          elsif pi_valid(I) = '1' and pi_enable(I) = '1' then
            if pi_amp(I) > pi_limit(I) then
              po_limit(I) <= '1';
            end if;
          end if;
        end if;
      end process prs_limit;
    end generate gen_channel;
  end generate gen_mode_1;

end architecture rtl;
