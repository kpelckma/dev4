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
--! Iterative fractional divider for signed
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library desy;
use desy.common_logic_utils.all;
use desy.math_utils.all;
use desy.all;

--! Fractional divider for signed types. The quotient is computed in an +
--! iterative way using the pencil-paper algorithm. The assumed range for the +
--! numerator and denominator is `[-1, 1)`, the range for the quotient is +
--! `(-1,1)`.
--! The number of cycles the divider +
--! takes to complete one iteration is equal to `g_output_length+2` when +
--! `G_SEPARATE_COMPARE` is `false` or `g_output_length*2+2` otherwise.
--! `G_SEPARATE_COMPARE` adds an additional stage to improve the max design +
--! frequency.
--! If `abs(numerator) >= abs(denominator)` `po_saturated` is equal to +
--! `ST_SAT_OVERFLOWN` if +
--! the quotient overflown or `ST_SAT_UNDERFLOWN` if the quotient underflown. 
entity fractional_divider_signed is
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
    pi_numerator   : in    signed(G_INPUT_LENGTH - 1 downto 0);
    pi_denominator : in    signed(G_INPUT_LENGTH - 1 downto 0);
    po_vld         : out   std_logic;
    po_saturated   : out   t_saturation;
    po_quotient    : out   signed(G_OUTPUT_LENGTH - 1 downto 0)
  );
end entity fractional_divider_signed;

architecture arch of fractional_divider_signed is

  type t_fractional_divider_stt is (
    ST_READY,
    ST_LOAD,
    ST_RUN
  );

  signal reg_fractional_divider_stt : t_fractional_divider_stt := ST_READY;
  signal reg_saturated              : t_saturation;
  signal reg_numerator_abs_ext      : unsigned(G_INPUT_LENGTH downto 0);
  signal reg_denominator_abs_ext    : unsigned(G_INPUT_LENGTH downto 0);
  signal l_quotient_abs             : unsigned(G_OUTPUT_LENGTH - 2 downto 0);
  signal reg_quotient               : signed(G_OUTPUT_LENGTH - 1 downto 0);
  signal reg_sign                   : std_logic;
  signal reg_vld                    : std_logic;
  signal l_divider_stb              : std_logic;
  signal l_saturated                : t_saturation;
  signal l_divider_vld              : std_logic;

begin

  prs_fractional_divider_fsm : process (pi_clk) is
  begin

    if rising_edge(pi_clk) then
      reg_vld <= '0';

      case reg_fractional_divider_stt is

        when ST_READY =>
          if (pi_stb = '1') then
            reg_fractional_divider_stt <= ST_LOAD;
          end if;

        when ST_LOAD =>

          reg_fractional_divider_stt <= ST_RUN;

        when ST_RUN =>

          if (l_divider_vld = '1') then
            reg_fractional_divider_stt <= ST_READY;
            reg_vld                    <= '1';
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
            -- to be replaced with f_abs_ext
            reg_numerator_abs_ext <= unsigned(abs(resize(pi_numerator,
                                                         G_INPUT_LENGTH + 1)));

            -- to be replaced with f_abs_ext
            reg_denominator_abs_ext <= unsigned(abs(resize(pi_denominator,
                                                           G_INPUT_LENGTH + 1)));

            reg_sign <= f_to_std_logic(pi_numerator < 0 xor pi_denominator < 0);
          end if;

        when ST_RUN =>

          if (l_divider_vld = '1') then
            if (reg_sign = '0') then
              reg_quotient <= signed(resize(l_quotient_abs, G_OUTPUT_LENGTH));
            else
              reg_quotient <= - signed(resize(l_quotient_abs, G_OUTPUT_LENGTH));
            end if;

            if (l_saturated = ST_SAT_OVERFLOWN) then
              if (reg_sign = '0') then
                reg_saturated <= ST_SAT_OVERFLOWN;
              else
                reg_saturated <= ST_SAT_UNDERFLOWN;
              end if;
            else
              reg_saturated <= ST_SAT_OK;
            end if;
          end if;

        when others =>

      end case;

    end if;

  end process prs_fractional_divider_iter;

  ins_divider_unsigned : entity desy.fractional_divider_unsigned
    generic map (
      G_INPUT_LENGTH     => G_INPUT_LENGTH + 1,
      G_OUTPUT_LENGTH    => G_OUTPUT_LENGTH - 1,
      G_SEPARATE_COMPARE => G_SEPARATE_COMPARE
    )
    port map (
      pi_clk         => pi_clk,
      pi_rst         => pi_rst,
      pi_stb         => l_divider_stb,
      po_rdy         => open,
      pi_numerator   => reg_numerator_abs_ext,
      pi_denominator => reg_denominator_abs_ext,
      po_vld         => l_divider_vld,
      po_saturated   => l_saturated,
      po_quotient    => l_quotient_abs
    );

  l_divider_stb <= f_to_std_logic(reg_fractional_divider_stt = ST_LOAD);

  po_saturated <= reg_saturated;
  po_rdy       <= f_to_std_logic(reg_fractional_divider_stt = ST_READY and
                                 pi_rst = '0');
  po_quotient  <= reg_quotient;
  po_vld       <= reg_vld;

end architecture arch;
