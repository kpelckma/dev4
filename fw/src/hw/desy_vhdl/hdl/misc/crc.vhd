--------------------------------------------------------------------------------
--          ____  _____________  __                                           --
--         / __ \/ ____/ ___/\ \/ /                 _   _   _                 --
--        / / / / __/  \__ \  \  /                 / \ / \ / \                --
--       / /_/ / /___ ___/ /  / /               = ( M | S | K )=              --
--      /_____/_____//____/  /_/                   \_/ \_/ \_/                --
--                                                                            --
--------------------------------------------------------------------------------
--! @copyright (c) 2022 DESY
--! SPDX-License-Identifier: CERN-OHL-W-2.0
--------------------------------------------------------------------------------
--! @date 2022-10-13
--! @author Burak Dursun <burak.dursun@desy.de>
--------------------------------------------------------------------------------
--! @brief CRC with generic polynomial and generic input width
--!
--! TODO: add multi-cycle calculation with backpressure
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity crc is
  generic (
    G_POLYNOMIAL    : std_logic_vector  := x"04C11DB7"; --! CRC polynomial (hidden 1 at MSB, same width with output)
    G_PARALLEL      : positive          := 32;          --! parallel processing (also input) bit width
    G_IN_BIT_ORDER  : boolean           := true;        --! true is big-endian bit order within each byte
    G_OUT_BIT_ORDER : boolean           := true;        --! false is little-endian bit order within each byte
    G_OUT_XOR       : std_logic_vector  := x"FFFFFFFF"  --! vector to be XORed with LFSR before output
  );
  port (
    pi_clock  : in  std_logic;
    pi_reset  : in  std_logic;

    pi_init   : in  std_logic_vector; --! remainder to initialize CRC on reset

    pi_valid  : in  std_logic;
    pi_data   : in  std_logic_vector;

    po_valid  : out std_logic;
    po_crc    : out std_logic_vector  --! calculated remainder
  );
end entity crc;

architecture rtl of crc is

  alias C_POLYNOMIAL  : std_logic_vector(G_POLYNOMIAL'length-1 downto 0) is G_POLYNOMIAL;
  alias C_OUT_XOR     : std_logic_vector(G_OUT_XOR'length-1 downto 0) is G_OUT_XOR;
  alias init          : std_logic_vector(pi_init'length-1 downto 0) is pi_init;
  alias data          : std_logic_vector(pi_data'length-1 downto 0) is pi_data;

  signal input    : std_logic_vector(data'range);
  signal feedback : std_logic_vector(C_POLYNOMIAL'range);
  signal output   : std_logic_vector(C_POLYNOMIAL'range);

begin

  prs_comb: process(input, output)
    variable v_feedback : std_logic_vector(feedback'range);
  begin
    v_feedback := output;
    for I in G_PARALLEL-1 downto 0 loop
      v_feedback :=
        (v_feedback(v_feedback'left-1 downto 0) & '0') xor
        (C_POLYNOMIAL and (C_POLYNOMIAL'range => (input(I) xor v_feedback(v_feedback'left))));
    end loop;
    feedback <= v_feedback;
  end process prs_comb;

  prs_sync: process(pi_clock)
  begin
    if rising_edge(pi_clock) then
      if pi_reset = '1' then
        po_valid <= '0';
        output <= init;
      else
        if pi_valid = '1' then
          po_valid <= '1';
          output <= feedback;
        else
          po_valid <= '0';
        end if;
      end if;
    end if;
  end process prs_sync;

  gen_in_bit_swap: if G_IN_BIT_ORDER generate
    gen_in_bits: for I in 0 to G_PARALLEL-1 generate
      input(7 - (I mod 8) + 8 * (I / 8)) <= data(I);
    end generate gen_in_bits;
  end generate gen_in_bit_swap;

  gen_in_bit_swap_n: if not G_IN_BIT_ORDER generate
    input <= data;
  end generate gen_in_bit_swap_n;

  gen_out_bit_swap: if G_OUT_BIT_ORDER generate
    gen_out_bits: for I in C_POLYNOMIAL'range generate
      po_crc(7 - (I mod 8) + 8 * (I / 8)) <= output(I) xor C_OUT_XOR(I);
    end generate gen_out_bits;
  end generate gen_out_bit_swap;

  gen_out_bit_swap_n: if not G_OUT_BIT_ORDER generate
    po_crc <= output xor C_OUT_XOR;
  end generate gen_out_bit_swap_n;

end architecture rtl;
