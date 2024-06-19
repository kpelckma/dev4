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
--! @date 2013-11-11
--! @author
--! Lukasz Butkowski <lukasz.butkowski@desy.de>
--! Radoslaw Rybaniec
--------------------------------------------------------------------------------
--! @brief Linear Interpolation
--!
--! Supported functions for interpolation:
--! 0: "sqrt"
--! 1: "1/sqrt"
--! 2: "1/x"
--! 3: custom function defined by the nodes in memory
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

library desy;

entity interpolator is
  generic (
    G_TYPE            : integer := 0;
    G_FUNC_NODES      : natural := 512;
    G_DATA_BASE       : natural := 0;
    G_DATA_OUT_WIDTH  : natural := 18;
    G_DATA_IN_WIDTH   : natural := 18
  );
  port (
    pi_clock  : in  std_logic;
    
    pi_valid  : in  std_logic := '0';
    pi_x      : in  std_logic_vector(G_DATA_IN_WIDTH-1 downto 0);  

    po_valid  : out std_logic;
    po_y      : out std_logic_vector(G_DATA_OUT_WIDTH-1 downto 0);

    --! memory interface for custom function (G_TYPE = -1)
    pi_mem_data       : in  std_logic_vector(G_DATA_OUT_WIDTH-1 downto 0) := (others => '0');
    pi_mem_addr       : in  std_logic_vector(natural(ceil(log2(real(G_FUNC_NODES))))-1 downto 0) := (others => '0');
    pi_mem_wr         : in  std_logic := '0';
    po_mem_base_data  : out std_logic_vector(G_DATA_OUT_WIDTH-1 downto 0);
    po_mem_delta_data : out std_logic_vector(G_DATA_OUT_WIDTH-1 downto 0);
    pi_mem_base_ena   : in  std_logic := '0';
    pi_mem_delta_ena  : in  std_logic := '0'
  );
end entity interpolator;

architecture rtl of interpolator is

  type t_ram is array (natural range<>) of std_logic_vector(G_DATA_OUT_WIDTH-1 downto 0) ;

  function f_gen_base_values(C_FUNC : integer; C_NODE, C_BASE, C_WIDTH : natural) return t_ram is

    constant C_DATA_BASE_VAL  : real  := real(2**C_BASE);
    constant C_INT_RANGE      : real  := real(C_NODE) / real(2**(real(C_WIDTH - C_BASE)));
    constant C_INT32_RANGE    : real  := real(2147483647);  --! 2^31-1 = 2147483647

    variable v_result : t_ram(C_NODE-1 downto 0);
    variable v_tmp    : real;

  begin
    case C_FUNC is
      when 0 =>
        for I in 0 to C_NODE-1 loop
          v_result(I) := std_logic_vector(to_signed(integer(C_DATA_BASE_VAL * sqrt(real(I) / real(C_INT_RANGE))), C_WIDTH));
        end loop;
      when 1 =>
        for I in 1 to C_NODE-1 loop
          v_result(I) := std_logic_vector(to_signed(integer(C_DATA_BASE_VAL / sqrt(real(I) / real(C_INT_RANGE))), C_WIDTH));
        end loop;
        v_result(0) := std_logic_vector(to_signed(integer(2.0 * C_DATA_BASE_VAL / sqrt(real(1) / real(C_INT_RANGE))), C_WIDTH));
      when 2 =>
        for I in 1 to C_NODE-1 loop
          v_tmp :=  C_DATA_BASE_VAL / (real(I) / real(C_INT_RANGE));
          if v_tmp > C_INT32_RANGE then
            v_result(I) := std_logic_vector(to_signed(integer(2147483647), C_WIDTH));
          else
            v_result(I) := std_logic_vector(to_signed(integer(v_tmp), C_WIDTH));
          end if;
        end loop;
        v_tmp := (2.0 * C_DATA_BASE_VAL / (real(1) / real(C_INT_RANGE)));
        if v_tmp > C_INT32_RANGE then
          v_result(0) := std_logic_vector(to_signed(integer(2147483647), C_WIDTH));
        else
          v_result(0) := std_logic_vector(to_signed(integer(v_tmp), C_WIDTH));
        end if;
      when others =>
        null;
    end case;
    return v_result;
  end function;

  constant C_RAM_BASE_VALUE : t_ram(G_FUNC_NODES-1 downto 0) := f_gen_base_values(G_TYPE, G_FUNC_NODES, G_DATA_BASE, G_DATA_OUT_WIDTH);

  function f_gen_delta_values(C_NODE : natural; C_BASE_VAL : t_ram) return t_ram is
    variable v_result : t_ram(C_NODE-1 downto 0) ;
  begin
    for I in 0 to C_NODE-2 loop
      v_result(I) := std_logic_vector(signed(C_BASE_VAL(I+1)) - signed(C_BASE_VAL(I)));
    end loop;
    v_result(C_NODE - 1) := v_result(C_NODE - 2);
    return v_result;
  end function;

  constant C_RAM_DELTA_VALUE  : t_ram(G_FUNC_NODES-1 downto 0)  := f_gen_delta_values(G_FUNC_NODES, C_RAM_BASE_VALUE );

  constant C_FUNC_NODES : natural := natural(ceil(log2(real(G_FUNC_NODES))));
  constant C_DELTA_BASE : natural := G_DATA_IN_WIDTH - C_FUNC_NODES;

  signal delta_arg      : std_logic_vector(G_DATA_OUT_WIDTH-1 downto 0) := (others => '0'); 
  signal delta_value_0  : std_logic_vector(G_DATA_OUT_WIDTH-1 downto 0) := (others => '0'); 
  signal delta_value_1  : std_logic_vector(G_DATA_OUT_WIDTH-1 downto 0) := (others => '0'); 
  signal base_arg       : std_logic_vector(C_FUNC_NODES-1 downto 0);
  signal base_value_0   : std_logic_vector(G_DATA_OUT_WIDTH-1 downto 0) := (others => '0'); 
  signal base_value_1   : std_logic_vector(G_DATA_OUT_WIDTH-1 downto 0) := (others => '0');
  signal valid          : std_logic_vector(1 downto 0)                  := (others => '0');
 
begin

  base_arg <= pi_x(G_DATA_IN_WIDTH-1 downto G_DATA_IN_WIDTH - C_FUNC_NODES);
  
  gen_mem: if G_TYPE = -1 generate

    ins_base_mem: entity desy.ram_tdp
      generic map (
        G_DATA  => G_DATA_OUT_WIDTH,
        G_ADDR  => C_FUNC_NODES)
      port map (
        pi_clk_a  => pi_clock,
        pi_en_a   => pi_mem_base_ena,
        pi_we_a   => pi_mem_wr,
        pi_addr_a => pi_mem_addr,
        pi_data_a => pi_mem_data,
        po_data_a => po_mem_base_data,

        pi_clk_b  => pi_clock,
        pi_en_b   => '1',
        pi_we_b   => '0',
        pi_addr_b => base_arg,
        pi_data_b => (others => '0'),
        po_data_b => base_value_0);

    ins_delta_mem: entity desy.ram_tdp
      generic map (
        G_DATA  => G_DATA_OUT_WIDTH,
        G_ADDR  => C_FUNC_NODES)
      port map (
        pi_clk_a  => pi_clock,
        pi_en_a   => pi_mem_delta_ena,
        pi_we_a   => pi_mem_wr,
        pi_addr_a => pi_mem_addr,
        pi_data_a => pi_mem_data,
        po_data_a => po_mem_delta_data,

        pi_clk_b  => pi_clock,
        pi_en_b   => '1',
        pi_we_b   => '0',
        pi_addr_b => base_arg,
        pi_data_b => (others => '0'),
        po_data_b => delta_value_0);

  end generate gen_mem;

  --! LUT for predefined functions
  gen_lut: if G_TYPE /= -1 generate

    prs_lut: process(pi_clock)
    begin  
      if rising_edge(pi_clock) then  
        base_value_0  <= C_RAM_BASE_VALUE(to_integer(unsigned(base_arg)));
        delta_value_0 <= C_RAM_DELTA_VALUE(to_integer(unsigned(base_arg)));
      end if;
    end process prs_lut;

    po_mem_delta_data <= (others => '0');
    po_mem_base_data  <= (others => '0');

  end generate gen_lut;

  --! y = base + delta * argument
  prs_interpolate: process(pi_clock)   
  begin
    if rising_edge(pi_clock) then
      valid         <= valid(0) & pi_valid;
      po_valid      <= valid(1);
      delta_arg     <= std_logic_vector(resize(signed('0' & pi_x(G_DATA_IN_WIDTH - C_FUNC_NODES-1 downto 0)), G_DATA_OUT_WIDTH));
      base_value_1  <= base_value_0;
      delta_value_1 <= std_logic_vector(resize(shift_right(signed(delta_value_0) * signed(delta_arg), C_DELTA_BASE), G_DATA_OUT_WIDTH));
      po_y          <= std_logic_vector(signed(base_value_1) + signed(delta_value_1));
    end if;
  end process prs_interpolate;

end architecture rtl;
