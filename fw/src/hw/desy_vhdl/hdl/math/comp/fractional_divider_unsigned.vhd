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
--! @date 2022-07-28
--! @author Andrea Bellandi <andrea.bellandi@desy.de>
------------------------------------------------------------------------------
--! @brief
--! Iterative fractional divider for unsigned
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library desy;
use desy.common_logic_utils.all;
use desy.math_utils.all;
use desy.math_unsigned.all;

--! Fractional divider for unsigned types. The quotient is computed in an +
--! iterative way using the pencil-paper algorithm. The assumed range for the +
--! numerator, denominator and quotient is `[0, 1)`.
--! The number of cycles the divider +
--! takes to complete one iteration is equal to `g_output_length+1` when +
--! `G_SEPARATE_COMPARE` is `false` or `g_output_length*2+1` otherwise.
--! `G_SEPARATE_COMPARE` adds an additional stage to improve the max design +
--! frequency.
--! If `numerator >= denominator` po_saturated is equal to `ST_SAT_OVERFLOWN` and the output is +
--! invalid.
entity fractional_divider_unsigned is
  generic (
    G_INPUT_LENGTH     : natural;
    G_OUTPUT_LENGTH    : natural;
    G_SEPARATE_COMPARE : boolean := false
  );
  port (
    pi_clk         : in    std_logic;
    pi_rst         : in    std_logic;
    pi_stb         : in    std_logic;
    po_rdy         : out   std_logic;
    pi_numerator   : in    unsigned(G_INPUT_LENGTH - 1 downto 0);
    pi_denominator : in    unsigned(G_INPUT_LENGTH - 1 downto 0);
    po_vld         : out   std_logic;
    po_saturated   : out   t_saturation;
    po_quotient    : out   unsigned(G_OUTPUT_LENGTH - 1 downto 0)
  );
end entity fractional_divider_unsigned;

architecture arch of fractional_divider_unsigned is

  type t_fractional_divider_stt is (ST_READY, ST_COMPARE, ST_CALCULATE);

  signal reg_fractional_divider_stt : t_fractional_divider_stt := ST_READY;
  signal reg_bit_cnt                : unsigned(f_unsigned_length(G_OUTPUT_LENGTH) - 1 downto 0);
  signal reg_saturated              : std_logic := '0';
  signal reg_numerator              : unsigned(G_INPUT_LENGTH downto 0) := (others => '0');
  signal reg_denominator            : unsigned(G_INPUT_LENGTH downto 0) := (others => '0');
  signal reg_remainder              : unsigned(G_INPUT_LENGTH downto 0) := (others => '0');
  signal reg_diff                   : unsigned(G_INPUT_LENGTH downto 0) := (others => '0');
  signal sig_diff                   : unsigned(G_INPUT_LENGTH downto 0);
  signal reg_comparison             : t_saturation := ST_SAT_OK;
  signal sig_comparison             : t_saturation;
  signal reg_quotient               : unsigned(G_OUTPUT_LENGTH - 1 downto 0) := (others => '0');
  signal reg_vld                    : std_logic := '0';

begin

  prs_fractional_divider_fsm : process (pi_clk) is
  begin

    if rising_edge(pi_clk) then
      reg_vld <= '0';

      case reg_fractional_divider_stt is

        when ST_READY =>
          if (pi_stb = '1') then
            reg_bit_cnt <= (others => '0');
            if (G_SEPARATE_COMPARE) then
              reg_fractional_divider_stt <= ST_COMPARE;
            else
              reg_fractional_divider_stt <= ST_CALCULATE;
            end if;
          end if;

        when ST_COMPARE =>
          reg_fractional_divider_stt <= ST_CALCULATE;

        when ST_CALCULATE =>
          if (reg_bit_cnt = (G_OUTPUT_LENGTH - 1)) then
            reg_fractional_divider_stt <= ST_READY;
            reg_vld                    <= '1';
          else
            reg_bit_cnt <= reg_bit_cnt + 1;

            if (G_SEPARATE_COMPARE) then
              reg_fractional_divider_stt <= ST_COMPARE;
            end if;
          end if;

      end case;

      if (pi_rst = '1') then
        reg_fractional_divider_stt <= ST_READY;
      end if;
    end if;

  end process prs_fractional_divider_fsm;

  prs_fractional_divider_iter : process (pi_clk) is
  begin

    if rising_edge(pi_clk) then

      case reg_fractional_divider_stt is

        when ST_READY =>
          if (pi_stb = '1') then
            reg_numerator   <= resize(pi_numerator, G_INPUT_LENGTH + 1);
            reg_denominator <= resize(pi_denominator, G_INPUT_LENGTH + 1);
            reg_remainder   <= shift_left(resize(pi_numerator,
                                                 G_INPUT_LENGTH + 1), 1);
          end if;

        when ST_COMPARE =>
          reg_diff       <= sig_diff;
          reg_comparison <= sig_comparison;

        when ST_CALCULATE =>
          if (reg_bit_cnt = 0) then
            reg_saturated <= f_to_std_logic(reg_numerator >= reg_denominator);
          end if;

          reg_quotient <= shift_left(reg_quotient, 1);

          if (G_SEPARATE_COMPARE) then
            if (reg_comparison = ST_SAT_OK) then
              reg_quotient(0) <= '1';
              reg_remainder   <= shift_left(reg_diff, 1);
            else
              reg_quotient(0) <= '0';
              reg_remainder   <= shift_left(reg_remainder, 1);
            end if;
          else
            if (sig_comparison = ST_SAT_OK) then
              reg_quotient(0) <= '1';
              reg_remainder   <= shift_left(sig_diff, 1);
            else
              reg_quotient(0) <= '0';
              reg_remainder   <= shift_left(reg_remainder, 1);
            end if;
          end if;

      end case;

    end if;

  end process prs_fractional_divider_iter;

  prd_diff_sat(reg_remainder,
               reg_denominator,
               sig_diff,
               sig_comparison,
               false);

  po_saturated <= ST_SAT_OK when reg_saturated = '0' else ST_SAT_OVERFLOWN;
  po_rdy       <= f_to_std_logic(reg_fractional_divider_stt = ST_READY and
                                 pi_rst = '0');
  po_quotient  <= reg_quotient;
  po_vld       <= reg_vld;

end architecture arch;
