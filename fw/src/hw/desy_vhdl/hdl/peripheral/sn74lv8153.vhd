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
--! @date 2021-09-14
--! @author Jan Marjanovic <jan.marjanovic@desy.de>
------------------------------------------------------------------------------
--! @brief
--! Controller for SN74LV8153 serial-to-parallel device
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real."ceil";
use ieee.math_real."log2";

entity sn74lv8153 is
generic (
  constant G_DEV_ADDR     : std_logic_vector(2 downto 0); --! device address
  constant G_CLK_FREQ     : natural; --! pi_clock frequency in Hz
  constant G_BAUD_RATE    : natural := 10_000; --! baud rate in Hz (should be between 2 and 24 kbps)
  constant G_REFRESH_RATE : natural := 50 --! refresh rate in Hz
);
port (
  pi_clock : in std_logic;
  pi_reset : in std_logic;

  pi_data : in std_logic_vector(7 downto 0);
  po_serial : out std_logic
);
end entity;

architecture RTL of sn74lv8153 is
  --! asserted for 1 clk pulse at the end of each refresh cycle
  signal refresh_pulse : std_logic;

  --! enable running at baud rate (asserted for 1 clk cycle)
  signal clk_slow_en : std_logic;

  type t_state is (
    S_IDLE,
    S_ST0,
    S_ST1,
    S_ADDR,
    S_DATA
  );
  signal current_state, next_state : t_state;

  --! frame (or nibble) selector
  signal frame_sel : std_logic;
  signal data_offset : unsigned(2 downto 0);

  --! counter to count address and data bits (4-data bits per frame)
  signal counter : unsigned(3 downto 0);
begin

  --! trigger transmission
  PROC_REFRESH_PULSE: process (pi_clock)
    constant C_CNTR_MAX : natural := G_CLK_FREQ / G_REFRESH_RATE - 1;
    constant C_CNTR_W   : natural := integer(ceil(log2(real(C_CNTR_MAX+1))));

    variable v_cntr : unsigned(C_CNTR_W-1 downto 0);
  begin
    if rising_edge(pi_clock) then
      if pi_reset = '1' then
        v_cntr := (others => '0');
        refresh_pulse <= '0';
      else
        if v_cntr < C_CNTR_MAX then
          refresh_pulse <= '0';
          v_cntr := v_cntr + 1;
        else
          refresh_pulse <= '1';
          v_cntr := (others => '0');
        end if;
      end if;
    end if;
  end process;

  --! generate baud-rage
  PROC_CLK_SLOW_EN: process (pi_clock)
    constant C_CNTR_MAX : natural := G_CLK_FREQ / G_BAUD_RATE - 1;
    constant C_CNTR_W   : natural := integer(ceil(log2(real(C_CNTR_MAX+1))));

    variable v_cntr : unsigned(C_CNTR_W-1 downto 0);
  begin
    if rising_edge(pi_clock) then
      if pi_reset = '1' then
        v_cntr := (others => '0');
        clk_slow_en <= '0';
      else
        if v_cntr < C_CNTR_MAX then
          clk_slow_en <= '0';
          v_cntr := v_cntr + 1;
        else
          clk_slow_en <= '1';
          v_cntr := (others => '0');
        end if;
      end if;
    end if;
  end process;

  --! advance with FSM
  PROC_CUR_STATE: process (pi_clock)
  begin
    if rising_edge(pi_clock) then
      if pi_reset = '1' then
        current_state <= S_IDLE;
      elsif clk_slow_en = '1' then
        current_state <= next_state;
      end if;
    end if;
  end process;

  --! select next state
  PROC_NXT_STATE: process (counter, refresh_pulse, current_state)
  begin
    case current_state is
      when S_IDLE =>
        if refresh_pulse = '1' then
          next_state <= S_ST0;
        else
          next_state <= current_state;
        end if;
      when S_ST0 =>
        next_state <= S_ST1;
      when S_ST1 =>
        next_state <= S_ADDR;
      when S_ADDR =>
        if counter = 3-1 then
          next_state <= S_DATA;
        else
          next_state <= current_state;
        end if;
      when S_DATA =>
        if counter = 4-1 then
          next_state <= S_IDLE;
        else
          next_state <= current_state;
        end if;
    end case;
  end process;

  --! counter to count number of bits in address and data
  PROC_CNTR: process (pi_clock)
  begin
    if rising_edge(pi_clock) then
      if pi_reset = '1' then
          counter <= (others => '0');
        else
          if clk_slow_en = '1' and next_state /= current_state then
            counter <= (others => '0');
          elsif clk_slow_en = '1' then
            counter <= counter + 1;
          end if;
        end if;
    end if;
  end process;

  --! frame selector
  PROC_FRAME_SEL: process (pi_clock)
  begin
    if rising_edge(pi_clock) then
      if pi_reset = '1' then
        frame_sel <= '0';
      else
        if clk_slow_en = '1' and current_state = S_DATA and next_state /= S_DATA then
          frame_sel <= not frame_sel;
        end if;
      end if;
    end if;
  end process;

  data_offset <= frame_sel & "00";

  --! output logic
  PROC_O_SERIAL: process (current_state, counter, pi_data, data_offset)
  begin
    case current_state is
      when S_IDLE =>
        po_serial <= '1';
      when S_ST0 =>
        po_serial <= '0';
      when S_ST1 =>
        po_serial <= '1';
      when S_ADDR =>
        po_serial <= G_DEV_ADDR(to_integer(counter));
      when S_DATA =>
        po_serial <= pi_data(to_integer(counter) + to_integer(data_offset));
    end case;
  end process;
end architecture;
