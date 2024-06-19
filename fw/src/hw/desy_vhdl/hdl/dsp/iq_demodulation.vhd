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
--! @brief IQ demodulation
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity iq_demodulation is
  generic (
    G_INPUT_WIDTH       : natural := 16;  --! ADC input data bit width
    G_SINCOS_TAB_SIZE   : natural :=  3;  --! SIN, COS tables size, usually = 2pi/'rotation angle'
    G_SAMPLES_PER_VALUE : natural :=  9;  --! number of samples taken to calculate one IQ pair
    G_OUTPUT_WIDTH      : natural := 18;  --! output data and SIN COS values bit width
    G_OUTPUT_SHIFT      : natural := 17;  --! Determines the amount of shift_right operation
    G_ACCU_WIDTH        : natural := 36   --! Accumulator size
  );
  port (
    pi_clock  : in  std_logic;
    pi_reset  : in  std_logic;

    pi_data : in  std_logic_vector(G_INPUT_WIDTH-1 downto 0);

    pi_sin  : in  std_logic_vector(G_SINCOS_TAB_SIZE*G_OUTPUT_WIDTH-1 downto 0);
    pi_cos  : in  std_logic_vector(G_SINCOS_TAB_SIZE*G_OUTPUT_WIDTH-1 downto 0);

    po_i      : out std_logic_vector(G_OUTPUT_WIDTH-1 downto 0);
    po_q      : out std_logic_vector(G_OUTPUT_WIDTH-1 downto 0);
    po_valid  : out std_logic
  );
end entity iq_demodulation;

architecture rtl of iq_demodulation is

  type t_sincos_tab is array(G_SINCOS_TAB_SIZE-1 downto 0) of signed(G_OUTPUT_WIDTH-1 downto 0);

  signal sin_tab    : t_sincos_tab;
  signal cos_tab    : t_sincos_tab;
  signal index      : natural range 0 to G_SINCOS_TAB_SIZE-1;
  signal sample_cnt : natural range 0 to G_SAMPLES_PER_VALUE-1;
  signal sample     : signed(G_OUTPUT_WIDTH-1 downto 0);
  signal q_accu     : signed(G_ACCU_WIDTH-1 downto 0);
  signal i_accu     : signed(G_ACCU_WIDTH-1 downto 0);

begin

  gen_sincos_tab: for I in 0 to G_SINCOS_TAB_SIZE-1 generate
    cos_tab(I) <= signed(pi_cos(G_OUTPUT_WIDTH*(I+1)-1 downto G_OUTPUT_WIDTH*I));
    sin_tab(I) <= signed(pi_sin(G_OUTPUT_WIDTH*(I+1)-1 downto G_OUTPUT_WIDTH*I));
  end generate gen_sincos_tab;

  sample <= resize(signed(pi_data), G_OUTPUT_WIDTH);

  prs_mac: process(pi_clock)
  begin
    if rising_edge(pi_clock) then
      if pi_reset = '1' then
        index       <= 0;
        sample_cnt  <= 0;
        i_accu      <= (others => '0');
        q_accu      <= (others => '0');
        po_i        <= (others => '0');
        po_q        <= (others => '0');
        po_valid    <= '0';
      else
        if index = G_SINCOS_TAB_SIZE-1 then
          index <= 0;
        else
          index <= index + 1;
        end if;
        if sample_cnt = G_SAMPLES_PER_VALUE-1 then
          sample_cnt  <= 0;
          i_accu      <= resize(signed(sample) * signed(cos_tab(index)), i_accu'length);
          q_accu      <= resize(signed(sample) * signed(sin_tab(index)), q_accu'length);
          po_i        <= std_logic_vector(resize(shift_right(i_accu, G_OUTPUT_SHIFT), G_OUTPUT_WIDTH));
          po_q        <= std_logic_vector(resize(shift_right(q_accu, G_OUTPUT_SHIFT), G_OUTPUT_WIDTH));
          po_valid    <= '1';
        else
          sample_cnt  <= sample_cnt + 1 ;
          i_accu      <= sample * cos_tab(index) + i_accu;
          q_accu      <= sample * sin_tab(index) + q_accu;
          po_valid    <= '0';
        end if;
      end if;
    end if;
  end process prs_mac;

end architecture rtl;
