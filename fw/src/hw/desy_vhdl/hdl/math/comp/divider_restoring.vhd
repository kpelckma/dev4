--------------------------------------------------------------------------------
--          ____  _____________  __                                           --
--         / __ \/ ____/ ___/\ \/ /                 _   _   _                 --
--        / / / / __/  \__ \  \  /                 / \ / \ / \                --
--       / /_/ / /___ ___/ /  / /               = ( M | S | K )=              --
--      /_____/_____//____/  /_/                   \_/ \_/ \_/                --
--                                                                            --
--------------------------------------------------------------------------------
--! @copyright (c) 2021 DESY
--! SPDX-License-Identifier: CERN-OHL-W-2.0
--------------------------------------------------------------------------------
--! @date 2022-11-07
--! @author
--! Burak Dursun <burak.dursun@desy.de>
--! Katharina Schulz <katharina.schulz@desy.de>
--------------------------------------------------------------------------------
--! @brief Restoring Divider
--!
--! unsigned divider with backpressure
--! numerator = denominator * quotient + remainder
--! latency = 2 + 2 * G_N_WIDTH
--! throughput = 1 / latency
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity divider_restoring is
  generic (
    G_N_WIDTH : natural := 36;
    G_D_WIDTH : natural := 18
  );
  port (
    pi_clock  : in  std_logic;
    pi_reset  : in  std_logic;

    po_ready        : out std_logic;
    pi_valid        : in  std_logic;
    pi_numerator    : in  std_logic_vector(G_N_WIDTH-1 downto 0);
    pi_denominator  : in  std_logic_vector(G_D_WIDTH-1 downto 0);

    pi_ready      : in  std_logic;
    po_valid      : out std_logic;
    po_quotient   : out std_logic_vector(G_N_WIDTH-1 downto 0);
    po_remainder  : out std_logic_vector(G_D_WIDTH-1 downto 0)
  );
end entity divider_restoring;

architecture rtl of divider_restoring is

  signal state        : std_logic_vector(1 downto 0);
  signal count        : signed(natural(ceil(log2(real(G_N_WIDTH-2)))) downto 0);
  signal ready        : std_logic;
  signal valid        : std_logic;
  signal denominator  : signed(G_N_WIDTH+G_D_WIDTH-1 downto 0);
  signal temp         : signed(G_N_WIDTH+G_D_WIDTH-1 downto 0);
  signal remainder    : signed(G_N_WIDTH+G_D_WIDTH-1 downto 0);
  signal quotient     : std_logic_vector(G_N_WIDTH-1 downto 0);

begin

  prs_div: process(pi_clock)
  begin
    if rising_edge(pi_clock) then
      if pi_reset = '1' then
        ready         <= '0';
        valid         <= '0';
        po_remainder  <= (others => '0');
        po_quotient   <= (others => '0');
        state         <= "00";
      else
        case state is
          when "00" =>  --! input
            if pi_ready = '0' and valid = '1' then
              ready <= '0';
              valid <= '1';
            else
              ready <= '1';
              valid <= '0';
            end if;
            if pi_valid = '1' and ready = '1' then
              ready       <= '0';
              denominator <= shift_left(resize(signed('0' & pi_denominator), G_N_WIDTH+G_D_WIDTH), G_N_WIDTH-1);
              remainder   <= resize(signed('0' & pi_numerator), G_N_WIDTH+G_D_WIDTH);
              quotient    <= (others => '0');
              count       <= to_signed(G_N_WIDTH-2, count'length);
              state       <= "01";
            end if;
          when "01" =>  --! subtract
            temp  <= remainder - denominator;
            state <= "11";
          when "11" =>  --! restore
            denominator <= '0' & denominator(denominator'left downto 1);
            if temp(temp'left) = '1' then
              quotient  <= quotient(quotient'left-1 downto 0) & '0';
            else
              remainder <= temp;
              quotient  <= quotient(quotient'left-1 downto 0) & '1';
            end if;
            if count(count'left) = '1' then
              state <= "10";
            else
              state <= "01";
            end if;
            count <= count - 1;
          when others =>  --! "10" output
            valid         <= '1';
            po_remainder  <= std_logic_vector(resize(remainder, G_D_WIDTH));
            po_quotient   <= quotient;
            state         <= "00";
        end case;
      end if;
    end if;
  end process prs_div;

  po_ready <= ready;
  po_valid <= valid;

end architecture rtl;
