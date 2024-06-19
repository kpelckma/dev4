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
--! @date 2019-02-13
--! @author Lukasz Butkowski <lukasz.butkowski@desy.de>
--------------------------------------------------------------------------------
--! @brief IQ demodulation with build-in memory
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library desy;
use desy.math_basic.all;

entity iq_demodulation_mem is
  generic (
    G_INPUT_WIDTH       : natural := 16;
    G_OUTPUT_WIDTH      : natural := 18;
    G_ACCU_WIDTH        : natural := 38;
    G_SINCOS_DATA_WIDTH : natural := 18;
    G_SINCOS_ADDR_WIDTH : natural := 6
  );
  port (
    pi_clock  : in  std_logic;
    pi_reset  : in  std_logic;

    pi_data   : in std_logic_vector(G_INPUT_WIDTH-1 downto 0);
    pi_valid  : in std_logic;

    po_sin_data : out std_logic_vector(G_SINCOS_DATA_WIDTH-1 downto 0);
    pi_sin_data : in  std_logic_vector(G_SINCOS_DATA_WIDTH-1 downto 0);
    pi_sin_addr : in  std_logic_vector(G_SINCOS_ADDR_WIDTH-1 downto 0);
    pi_sin_en   : in  std_logic;
    pi_sin_we   : in  std_logic;

    po_cos_data : out std_logic_vector(G_SINCOS_DATA_WIDTH-1 downto 0);
    pi_cos_data : in  std_logic_vector(G_SINCOS_DATA_WIDTH-1 downto 0);
    pi_cos_addr : in  std_logic_vector(G_SINCOS_ADDR_WIDTH-1 downto 0);
    pi_cos_en   : in  std_logic;
    pi_cos_we   : in  std_logic;

    pi_sincos_tab_size  : in  std_logic_vector(G_SINCOS_ADDR_WIDTH-1 downto 0) ;
    pi_out_scale        : in  std_logic_vector(17 downto 0);

    po_sin  : out std_logic_vector(G_SINCOS_DATA_WIDTH-1 downto 0);
    po_cos  : out std_logic_vector(G_SINCOS_DATA_WIDTH-1 downto 0);
 
    po_i      : out std_logic_vector(G_OUTPUT_WIDTH-1 downto 0);
    po_q      : out std_logic_vector(G_OUTPUT_WIDTH-1 downto 0);
    po_valid  : out std_logic
  );
end iq_demodulation_mem ;

architecture rtl of iq_demodulation_mem is

  signal cos_tab  : std_logic_vector(G_SINCOS_DATA_WIDTH-1 downto 0);
  signal sin_tab  : std_logic_vector(G_SINCOS_DATA_WIDTH-1 downto 0);
  signal index    : std_logic_vector(G_SINCOS_ADDR_WIDTH-1 downto 0);
  signal valid    : std_logic;
  signal sample   : signed(G_OUTPUT_WIDTH-1 downto 0);
  signal q_accu   : signed(G_ACCU_WIDTH-1 downto 0);
  signal i_accu   : signed(G_ACCU_WIDTH-1 downto 0);
  signal i_temp   : std_logic_vector(G_ACCU_WIDTH-1-16 downto 0);
  signal q_temp   : std_logic_vector(G_ACCU_WIDTH-1-16 downto 0);

begin

  sample <= resize(signed(pi_data), G_OUTPUT_WIDTH);

  prs_mac: process(pi_clock)
  begin
    if rising_edge(pi_clock) then
      if pi_reset = '1' then
        index   <= (others => '0');
        i_accu  <= (others => '0');
        q_accu  <= (others => '0');
        i_temp  <= (others => '0');
        q_temp  <= (others => '0');
        valid   <= '0';
      else
        if pi_valid = '1' then
          if index = std_logic_vector(unsigned(pi_sincos_tab_size) - 1) then
            index   <= (others => '0');
            i_accu  <= resize(signed(sample) * signed(cos_tab), i_accu'length) ;
            q_accu  <= resize(signed(sample) * signed(sin_tab), q_accu'length) ;
            i_temp  <= std_logic_vector(resize(shift_right(i_accu, 16), i_temp'length));
            q_temp  <= std_logic_vector(resize(shift_right(q_accu, 16), q_temp'length));
            valid   <= '1';
          else
            index   <= std_logic_vector(unsigned(index) + 1);
            i_accu  <= i_accu + sample * signed(cos_tab);
            q_accu  <= q_accu + sample * signed(sin_tab);
            valid   <= '0';
          end if;
        else
          valid <= '0';
        end if;
      end if;
    end if;
  end process prs_mac;

  prs_scale: process(pi_clock)
  begin
    if rising_edge(pi_clock) then
      po_i <= u2vresize(u2vshift(u2vmult(i_temp, pi_out_scale, G_ACCU_WIDTH), -16), G_OUTPUT_WIDTH); 
      po_q <= u2vresize(u2vshift(u2vmult(q_temp, pi_out_scale, G_ACCU_WIDTH), -16), G_OUTPUT_WIDTH); 
      po_valid <= valid;
    end if;
  end process prs_scale;

  po_sin <= sin_tab;
  po_cos <= cos_tab;

  ins_sin_tab: entity desy.ram_tdp
    generic map(
      G_ADDR  => G_SINCOS_ADDR_WIDTH,
      G_DATA  => G_SINCOS_DATA_WIDTH
    )
    port map (
      pi_clk_a  => pi_clock,
      pi_en_a   => pi_sin_en,
      pi_wr_a   => pi_sin_we,
      pi_addr_a => pi_sin_addr,
      pi_data_a => pi_sin_data,
      po_data_a => po_sin_data,
      
      pi_clk_b  => pi_clock,
      pi_en_b   => '1',
      pi_wr_b   => '0',
      pi_addr_b => index,
      pi_data_b => (others => '0'),
      po_data_b => sin_tab
    );
    
  ins_cos_tab: entity desy.ram_tdp
    generic map(
      G_ADDR  => G_SINCOS_ADDR_WIDTH,
      G_DATA  => G_SINCOS_DATA_WIDTH
    )
    port map (
      pi_clk_a  => pi_clock,
      pi_en_a   => pi_cos_en,
      pi_wr_a   => pi_cos_we,
      pi_addr_a => pi_cos_addr,
      pi_data_a => pi_cos_data,
      po_data_a => po_cos_data,
      
      pi_clk_b  => pi_clock,
      pi_en_b   => '1',
      pi_wr_b   => '0',
      pi_addr_b => index,
      pi_data_b => (others => '0'),
      po_data_b => cos_tab
    );
    
end architecture rtl;
