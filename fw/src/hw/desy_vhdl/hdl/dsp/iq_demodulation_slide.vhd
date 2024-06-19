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
--! @brief Sliding IQ demodulation
--!
--! TODO: implement *recursive moving sum for sliding window summation
--! * y[i] = y[i-1] + x[i] - x[i-N] where N is the window size
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity iq_demodulation_slide is
  generic (
    G_INPUT_WIDTH     : natural := 16;
    G_SINCOS_TAB_SIZE : natural := 5;
    G_AVG_FACTOR      : natural := 1;
    G_PIPES_NUM       : natural := 3;
    G_OUTPUT_WIDTH    : natural := 18;
    G_OUTPUT_SHIFT    : natural := 17
  );
  port (
    pi_clock  : in  std_logic;
    pi_reset  : in  std_logic;

    pi_data : in std_logic_vector(G_INPUT_WIDTH-1 downto 0);

    pi_sin  : in std_logic_vector(G_SINCOS_TAB_SIZE*G_OUTPUT_WIDTH-1 downto 0);
    pi_cos  : in std_logic_vector(G_SINCOS_TAB_SIZE*G_OUTPUT_WIDTH-1 downto 0);

    po_i      : out std_logic_vector(G_OUTPUT_WIDTH-1 downto 0);
    po_q      : out std_logic_vector(G_OUTPUT_WIDTH-1 downto 0);
    po_valid  : out std_logic
  );
end iq_demodulation_slide;

architecture rtl of iq_demodulation_slide is

  type t_sincos_tab is array(G_SINCOS_TAB_SIZE-1 downto 0) of signed(G_OUTPUT_WIDTH-1 downto 0);
  signal sin_tab  : t_sincos_tab;
  signal cos_tab  : t_sincos_tab;

  signal index  : natural range 0 to G_SINCOS_TAB_SIZE-1;

  signal sample   : signed(G_OUTPUT_WIDTH-1 downto 0);
  signal sample_i : signed(2*G_OUTPUT_WIDTH-1 downto 0);
  signal sample_q : signed(2*G_OUTPUT_WIDTH-1 downto 0);

  type t_window is array(natural range <>) of signed(2*G_OUTPUT_WIDTH-1 downto 0);
  signal i_complete : t_window(G_SINCOS_TAB_SIZE*G_AVG_FACTOR-1 downto 0);
  signal q_complete : t_window(G_SINCOS_TAB_SIZE*G_AVG_FACTOR-1 downto 0);
  signal i_partial  : t_window(G_PIPES_NUM-1 downto 0);
  signal q_partial  : t_window(G_PIPES_NUM-1 downto 0);

  signal reset  : std_logic; 

begin

  gen_sincos_tab: for I in 0 to G_SINCOS_TAB_SIZE-1 generate
    cos_tab(I) <= signed(pi_cos(G_OUTPUT_WIDTH*(I+1)-1 downto G_OUTPUT_WIDTH*I));
    sin_tab(I) <= signed(pi_sin(G_OUTPUT_WIDTH*(I+1)-1 downto G_OUTPUT_WIDTH*I));
  end generate gen_sincos_tab;

  sample <= resize(signed(pi_data), G_OUTPUT_WIDTH);

  prs_mult: process(pi_clock)
    variable v_dry_cnt : natural := 0;
  begin
    if rising_edge(pi_clock) then
      reset <= pi_reset;  --! TODO: evaluate available delay on reset
      if pi_reset = '1' then
        index <= 0;
        sample_i <= (others => '0');
        sample_q <= (others => '0');
        i_complete <= (others => (others => '0'));
        q_complete <= (others => (others => '0'));
        v_dry_cnt := 0;
        po_valid <= '0';
      else
        sample_i <= sample * cos_tab(index);
        sample_q <= sample * sin_tab(index);
        if index = G_SINCOS_TAB_SIZE-1 then
          index <= 0;
        else
          index <= index + 1;
        end if;
        i_complete(0) <= shift_right(sample_i, G_OUTPUT_SHIFT);
        q_complete(0) <= shift_right(sample_q, G_OUTPUT_SHIFT);
        i_complete(i_complete'left downto 1) <= i_complete(i_complete'left-1 downto 0);
        q_complete(q_complete'left downto 1) <= q_complete(q_complete'left-1 downto 0);
        if v_dry_cnt = G_SINCOS_TAB_SIZE*G_AVG_FACTOR+2 then
          po_valid <= '1';
        else 
          v_dry_cnt := v_dry_cnt + 1;
          po_valid <= '0';
        end if;
      end if;
    end if;
  end process prs_mult;

  prs_sum: process(pi_clock)
    variable v_i_partial  : t_window(G_PIPES_NUM-1 downto 0)    := (others => (others => '0'));
    variable v_q_partial  : t_window(G_PIPES_NUM-1 downto 0)    := (others => (others => '0'));
    variable v_i_sum      : signed(2*G_OUTPUT_WIDTH-1 downto 0) := (others => '0');
    variable v_q_sum      : signed(2*G_OUTPUT_WIDTH-1 downto 0) := (others => '0');
  begin
    if rising_edge(pi_clock) then
      v_i_partial := (others => (others => '0'));
      v_q_partial := (others => (others => '0'));
      for I in 0 to G_SINCOS_TAB_SIZE*G_AVG_FACTOR-1 loop 
        v_i_partial(I mod G_PIPES_NUM) := v_i_partial(I mod G_PIPES_NUM) + i_complete(I);
        v_q_partial(I mod G_PIPES_NUM) := v_q_partial(I mod G_PIPES_NUM) + q_complete(I);
      end loop;
      i_partial <= v_i_partial;
      q_partial <= v_q_partial;
      v_i_sum := (others => '0');
      v_q_sum := (others => '0');
      for J in 0 to G_PIPES_NUM-1 loop 
        v_i_sum := v_i_sum + i_partial(J);
        v_q_sum := v_q_sum + q_partial(J);
      end loop;
      po_i <= std_logic_vector(resize(v_i_sum, G_OUTPUT_WIDTH));
      po_q <= std_logic_vector(resize(v_q_sum, G_OUTPUT_WIDTH));
    end if;
  end process prs_sum;

end architecture rtl;
