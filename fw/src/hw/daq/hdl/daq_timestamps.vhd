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
--! @author Radoslaw Rybaniec
--! @author Michael Buechler  <michael.buechler@desy.de>
------------------------------------------------------------------------------
--! @brief
--! Two kinds of timestamp are handled here:
--! 1) Timestamp of the first sample of a buffer
--! 2) Time offsets of each trigger inside the buffer
--!
--! The time offset counter resets on the buffer_start signal which is behind
--! the first sample of a buffer by one clock. A trigger offset time of 0 thus
--! corresponds to the third clock period of a buffer, or the buffer start time
--! plus 2 clock periods.
--! Or: T_trigger = po_start_time + CLK_PERIOD*(po_trigger_time[i]+2)
--! Trigger signals during the first three clocks of a buffer are lost.
--! 
--!                  +-----------------------+
--!                  | daq_timestamps        |
--!  data_str +------>                       +-----> start_rdy, start_time
--!                  |                       |
--! buf_start +------>                       +-----> trg_rdy, trg_time
--!                  |    +--------------+   |
--!       trg +------>    |64bit & 32bit |   +-----> trg_cnt
--!                  |    |counters      |   |
--!                  |    +--------------+   |
--!                  +-----------------------+
--!
--! TODO: allow software to independently reset the counters
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity daq_timestamps is
  generic (
            G_TIMESTAMP_WIDTH : natural := 64;
            G_OFFSET_WIDTH    : natural := 32
          );
  port (
         pi_clock : in std_logic;
         pi_reset : in std_logic;

         pi_data_str : in std_logic;
         pi_buf_start : in std_logic;
         pi_buf_num : in std_logic;
         pi_trg : in std_logic;

         po_start_time   : out std_logic_vector(G_TIMESTAMP_WIDTH-1 downto 0);
         po_start_rdy    : out std_logic;
         -- time offset values are fixed to 32 bits
         po_trigger_time : out std_logic_vector(G_OFFSET_WIDTH-1 downto 0);
         po_trigger_rdy  : out std_logic;
         po_buf_num      : out std_logic
       );
end entity daq_timestamps;

architecture arch of daq_timestamps is
  -- general timestamp counter, reset at buffer start
  signal time_cnt : unsigned(G_TIMESTAMP_WIDTH-1 downto 0);

  -- for saving timestamp at buffer start
  signal start_time : unsigned(G_TIMESTAMP_WIDTH-1 downto 0);
  signal sample_time : unsigned(G_TIMESTAMP_WIDTH-1 downto 0);
  signal start_rdy : std_logic;

  signal buf_num : std_logic;

  -- for saving timestamps at trigger events
  signal offset_time : unsigned(G_OFFSET_WIDTH-1 downto 0);
  signal trigger_time : unsigned(G_OFFSET_WIDTH-1 downto 0);
  -- signals the availability of a trigger timestamp at the output
  signal trigger_rdy : std_logic;
begin

  --! assign signals to output ports
  po_start_time <= std_logic_vector(start_time);
  po_start_rdy <= start_rdy;
  po_trigger_rdy <= trigger_rdy;
  po_trigger_time <= std_logic_vector(trigger_time);
  po_buf_num <= buf_num;

  --! For buffer start timestamps.
  --! This counter must not overflow.
  --! TODO: detect overflow, set a flag
  prs_counter: process(pi_clock)
  begin
    if rising_edge(pi_clock) then
      if pi_reset = '1' then
        time_cnt <= (others => '0');
      else
        time_cnt <= time_cnt+1;
      end if;
    end if;
  end process;

  prs_buffer_start: process (pi_clock)
  begin
    if rising_edge(pi_clock) then
      if pi_reset = '1' then
        start_rdy <= '0';
        start_time <= (others => '0');
        sample_time <= (others => '0');
        buf_num <= '0';
      else
        -- step 1: save the timestamp of each sample and keep it until the
        -- next strobe pulse.
        if pi_data_str = '1' then
          sample_time <= time_cnt;
        end if;

        -- step 2: put saved timestamp to output when the burst generator
        -- starts writing to a buffer
        if pi_buf_start = '1' then
          start_time <= sample_time;
          start_rdy <= '1';
          -- also get the current buffer on a buffer start
          buf_num <= pi_buf_num;
        else
          start_time <= start_time;
          start_rdy <= '0';
          buf_num <= buf_num;
        end if;

      end if;
    end if;
  end process;

  -- Trigger timestamps are based on another 32-bit counter and store only the
  -- offset from the buffer start timestamp.
  -- TODO:
  -- Should that counter overflow, an error counter should be incremented.
  prs_triggers: process (pi_clock)
  begin
    if rising_edge(pi_clock) then
      if pi_reset = '1' then
        offset_time  <= (others => '0');
        trigger_time <= (others => '0');
        trigger_rdy  <= '0';
      else
        -- Reset counters on each buffer start.
        if pi_buf_start = '1' then
          if pi_trg = '1' then
            trigger_rdy <= '1';
          else
            trigger_rdy <= '0';
          end if;
          -- buf_start is already 1 clock behind the first sample, so
          -- set the initial offset accordingly.
          offset_time  <= to_unsigned(2, offset_time'length);
          trigger_time <= to_unsigned(1, trigger_time'length);
        -- On each trigger, unless the max number of triggers
        -- per buffer was reached.
        elsif pi_trg = '1' then
          -- * Increase the trigger count
          -- * Transfer current offset counter value to output (po_trigger_time)
          --   and set the _rdy signal.
          offset_time  <= offset_time+1;
          trigger_time <= offset_time;
          trigger_rdy  <= '1';
        else
          -- always increment the offset counter
          offset_time  <= offset_time+1;
          trigger_time <= trigger_time;
          trigger_rdy  <= '0';
        end if;
      end if;
    end if;
  end process;

end architecture;
