--------------------------------------------------------------------------------
--          ____  _____________  __                                           --
--         / __ \/ ____/ ___/\ \/ /                 _   _   _                 --
--        / / / / __/  \__ \  \  /                 / \ / \ / \                --
--       / /_/ / /___ ___/ /  / /               = ( M | S | K )=              --
--      /_____/_____//____/  /_/                   \_/ \_/ \_/                --
--                                                                            --
--------------------------------------------------------------------------------
--! @copyright (c) 2017 DESY
--! SPDX-License-Identifier: CERN-OHL-W-2.0
--------------------------------------------------------------------------------
--! @date 2017-11-28
--! @author
--! Cagil Gumus <cagil.guemues@desy.de>
--! Lukasz Butkowski <lukasz.butkowski@desy.de>
--------------------------------------------------------------------------------
--! @brief Decimator capable of downsampling or averaging data
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

library desy;
use desy.common_types.all;
use desy.math_basic.all;

entity decimator is
  generic (
    G_WORD_WIDTH      : natural := 18;
    G_INPUT_NUM       : natural := 2;
    G_MAX_DECIMATION  : natural := 128;
    G_TABLE_WIDTH     : natural := 25
  );
  port(
    pi_clock  : in  std_logic;
    pi_reset  : in  std_logic;

    pi_dec_factor : in  std_logic_vector(15 downto 0);
    pi_dec_mode   : in  std_logic;

    pi_valid  : in  std_logic;
    pi_data   : in  t_18b_slv_vector(G_INPUT_NUM-1 downto 0);

    po_valid  : out std_logic;
    po_data   : out t_18b_slv_vector(G_INPUT_NUM-1 downto 0)
  );
end decimator;

architecture rtl of decimator is

  constant C_ACU_WIDTH  : natural := G_WORD_WIDTH+ natural(log2(real(G_MAX_DECIMATION)));

  type t_scaletable is array (natural range <>) of std_logic_vector(G_TABLE_WIDTH-1 downto 0);
  type t_accu is array (natural range <>) of std_logic_vector(C_ACU_WIDTH-1 downto 0);

  function f_set_scale_table(C_MAX_AVERAGE : natural) return t_scaletable is
    variable v_result : t_scaletable(C_MAX_AVERAGE-1 downto 0);
  begin
    v_result(0) := (others => '0');
    for I in 1 to C_MAX_AVERAGE-1 loop
      v_result(I) := std_logic_vector(to_signed(integer(ceil(real(2**(G_TABLE_WIDTH-1)) * 1.0 / real(I + 1))), G_TABLE_WIDTH));
    end loop;
    return v_result ;
  end function f_set_scale_table;

  constant C_AVG_SCALE  : t_scaletable(G_MAX_DECIMATION-1 downto 0) := f_set_scale_table(G_MAX_DECIMATION);

  signal accu       : t_accu(G_INPUT_NUM-1 downto 0)              := (others => (others => '0'));
  signal data       : t_accu(G_INPUT_NUM-1 downto 0)              := (others => (others => '0'));
  signal valid      : std_logic                                   := '0';
  signal down_data  : t_18b_slv_vector(G_INPUT_NUM-1 downto 0)    := (others => (others => '0'));
  signal down_valid : std_logic                                   := '0';
  signal avg_data   : t_18b_slv_vector(G_INPUT_NUM-1 downto 0)    := (others => (others => '0'));
  signal avg_valid  : std_logic                                   := '0';
  signal scale      : std_logic_vector(G_TABLE_WIDTH-1 downto 0)  := (others => '0');
  signal avg_cnt    : natural                                     := 0;
  signal avg_end    : std_logic                                   := '0';

begin

  --! Mode selection determines which data gets linked to outside
  --! Choosing whether downsampling or averaging will be used for outside
  --! TODO: output registers (evaluate register relocation to keep latency same)
  po_data   <= down_data when pi_dec_mode = '0' else avg_data;
  po_valid  <= down_valid when pi_dec_mode = '0' else avg_valid;

  --! Taking every nth sample and giving in to output
  prs_downsample: process(pi_clock)
    variable v_counter : integer := 0;
  begin
    if rising_edge(pi_clock) then
      if pi_reset = '1' then
        v_counter := 0;
        down_data <= (others => (others => '0'));
        down_valid  <= '0';
      elsif pi_valid = '1' then
        if v_counter = unsigned(pi_dec_factor) then
          down_data <= pi_data;
          down_valid  <= '1';
          v_counter := 0;
        else
          v_counter := v_counter + 1;
        end if;
      else
        down_valid  <= '0';
      end if;
    end if;
  end process prs_downsample;

  --! Taking n samples, averaging them, and giving it to output
  prs_avg: process(pi_clock)
  begin
    if rising_edge(pi_clock) then
      if pi_reset = '1' then
        valid   <= '0';
        avg_cnt <= 0;
        for I in 0 to G_INPUT_NUM-1 loop
          accu(I) <= (others => '0');
          data(I) <= (others => '0');
        end loop;
      else
        valid <= '0';
        if pi_valid = '1' then
          if avg_end = '1' then
            avg_cnt <= 0;
            valid   <= '1';
            for I in 0 to G_INPUT_NUM-1 loop
              accu(I) <= (others => '0');
              data(I) <= U2VSum(accu(I), pi_data(I), C_ACU_WIDTH);
            end loop;
          else
            avg_cnt <= avg_cnt + 1;
            for I in 0 to G_INPUT_NUM-1 loop
              accu(I) <= U2VSum(accu(I), pi_data(I), C_ACU_WIDTH);
            end loop;
          end if;
        end if;
      end if;
    end if;
  end process prs_avg;

  avg_end <= '1' when avg_cnt >= to_integer(unsigned(pi_dec_factor)) else '0';

  scale <= C_AVG_SCALE(to_integer(unsigned(pi_dec_factor))) when rising_edge(pi_clock);

  prs_scale: process(pi_clock)
  begin
    if rising_edge(pi_clock) then
      if pi_reset = '1' then
        avg_valid <= '0';
        avg_data  <= (others => (others => '0'));
      else
        avg_valid <= '0';
        if to_integer(unsigned(pi_dec_factor)) = 0 then
          avg_valid <= pi_valid;
          for I in 0 to G_INPUT_NUM-1 loop
            avg_data(I) <= pi_data(I);
          end loop;
        elsif valid = '1' then
          avg_valid <= '1';
          for I in 0 to G_INPUT_NUM-1 loop
            avg_data(I) <= U2VResize(U2Vshift(U2VMult(data(I), scale, G_TABLE_WIDTH+C_ACU_WIDTH), -G_TABLE_WIDTH+1), G_WORD_WIDTH);
          end loop;
        end if;
      end if;
    end if;
  end process prs_scale;

end architecture rtl;
