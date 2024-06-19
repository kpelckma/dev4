------------------------------------------------------------------------------
--          ____  _____________  __                                         --
--         / __ \/ ____/ ___/\ \/ /                 _   _   _               --
--        / / / / __/  \__ \  \  /                 / \ / \ / \              --
--       / /_/ / /___ ___/ /  / /               = ( M | S | K )=            --
--      /_____/_____//____/  /_/                   \_/ \_/ \_/              --
--                                                                          --
------------------------------------------------------------------------------
--! @copyright Copyright 2021 DESY
--! SPDX-License-Identifier: CERN-OHL-W-2.0
------------------------------------------------------------------------------
--! @date 2021-12-21
--! @author DESY-MSK-FW Team
------------------------------------------------------------------------------
--! @brief
--! Provides frequency of input clocks based on the reference clock
--!
--! Refactored from desy_lib_svn.ent_clk_status
--! Requires false paths definitions for timing closure
-- Vivado example:
-- # time ignore for Clock Frequency counters
-- set_false_path -from [get_pins -hierarchical -filter {NAME=~INST_BOARD/BLK_CLOCK.INST_CLK_STATUS/gen_clk_counters[*]._reg*/C}] \
-- -to [get_pins -hierarchical -filter {NAME=~INST_BOARD/BLK_CLOCK.INST_CLK_STATUS/SIG_FREQ_reg[*][*]/D}]
--
-- set_property ASYNC_REG true [get_cells {path}ins_clock_freq/counter*]
--
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library desy;
use desy.common_types.all;

-- ****************************************************************************
entity clock_freq is
  generic (
    G_CLOCK_FREQ  : natural := 125000000; --! reference clock frequency in Hz
    G_CLOCK_COUNT : natural := 1          --! number of clocks to measure
  );
  port (
    pi_clock  : in std_logic; --! reference clock
    pi_reset  : in std_logic; --! sync reset
    --! vector of clocks to be measured
    pi_clock_vect  : in  std_logic_vector(G_CLOCK_COUNT-1 downto 0);
    --! clock frequencies in Hz
    po_clock_freq  : out t_32b_slv_vector(G_CLOCK_COUNT-1 downto 0)
  );
end clock_freq;

-- ****************************************************************************
architecture rtl of clock_freq is

  signal clk_en       : std_logic;
  signal data_rdy     : std_logic;
  signal clk_counter  : natural;
  signal counter      : t_32b_slv_vector(G_CLOCK_COUNT-1 downto 0);
  signal clock_freq   : t_32b_slv_vector(G_CLOCK_COUNT-1 downto 0);

  attribute ASYNC_REG : string;
  attribute ASYNC_REG of clock_freq : signal is "true";
begin

  ----------------------------------------------------------
  -- register counters
  prs_cdc: process(pi_clock)
  begin
    if rising_edge(pi_clock) then
      if clk_en = '1' then
        clock_freq <= counter;
      end if;
    end if;
  end process;

  po_clock_freq <= clock_freq ;

  ----------------------------------------------------------
  -- generate reference sync signal for clock counters and register
  prs_ref: process(pi_clock)
  begin
    if rising_edge(pi_clock) then
      if pi_reset = '1' then
        clk_en        <= '0';
        data_rdy      <= '0';
        clk_counter   <= 0;
      else
        clk_en        <= '0';
        clk_counter   <= clk_counter + 1;
        if clk_counter < G_CLOCK_FREQ/2 then
          data_rdy    <= '1';
        elsif clk_counter < G_CLOCK_FREQ then
          data_rdy    <= '0';
        else
          clk_en      <= '1';
          clk_counter <= 0;
        end if;
      end if;
    end if;
  end process prs_ref;

  ----------------------------------------------------------
  -- clock counters
  gen_clk_counters : for I in 0 to G_CLOCK_COUNT-1 generate
    signal l_data_rdy_q : std_logic_vector(2 downto 0);
    signal l_counter    : natural;

    attribute ASYNC_REG of l_data_rdy_q : signal is "true"; -- l_data_rdy_q(2) can be excluded
  begin

    prs_freq: process(pi_clock_vect(I))
    begin
      if rising_edge(pi_clock_vect(I)) then
        l_data_rdy_q <= l_data_rdy_q(1 downto 0) & data_rdy;
        if l_data_rdy_q(1) = '1' and l_data_rdy_q(2) = '0' then
          counter(I)  <= std_logic_vector(to_unsigned(l_counter,32));
          l_counter <= 0;
        else
          l_counter <= l_counter + 1;
        end if;
      end if;
    end process prs_freq;

  end generate gen_clk_counters;

end rtl;
