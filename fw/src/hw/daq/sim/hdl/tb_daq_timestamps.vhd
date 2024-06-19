-------------------------------------------------------------------------------
--          ____  _____________  __                                          --
--         / __ \/ ____/ ___/\ \/ /                 _   _   _                --
--        / / / / __/  \__ \  \  /                 / \ / \ / \               --
--       / /_/ / /___ ___/ /  / /               = ( M | S | K )=             --
--      /_____/_____//____/  /_/                   \_/ \_/ \_/               --
--                                                                           --
-------------------------------------------------------------------------------
-- $Header$
-------------------------------------------------------------------------------
--! @file   tb_daq_timestamps.vhd
--! @brief  Testbench for DAQ timestamp generation
--! @author Michael Buechler
--! @email  michael.buechler@desy.de
--! $Date$
--! $Revision$
--! $URL$
--! This testbench uses UVVM
-------------------------------------------------------------------------------

--! Use standard library
library ieee;
--! Use logic elements
use ieee.std_logic_1164.all;

--! Use unsigned arithmetic
--use ieee.std_logic_unsigned.all;

use ieee.numeric_std.all;

library work;
use work.PKG_TYPES.all;

library uvvm_util;
context uvvm_util.uvvm_util_context;

entity tb_daq_timestamps is
  -- no generics
  -- no ports
end entity;

architecture tb_arch of tb_daq_timestamps is
  constant C_CLK_PERIOD : time := 8 ns;
  constant C_DATA_WIDTH : natural := 32;
  constant C_TRG_CNT_MAX   : natural := 4;
  constant C_TRG_CNT_WIDTH : natural := 3;
  signal clock : std_logic;
  signal areset : std_logic;
  signal clock_en : std_logic;

  signal data : std_logic_vector(C_DATA_WIDTH-1 downto 0);
  signal strobe : std_logic;
  signal buffer_start : std_logic;
  signal trg : std_logic;

  signal trigger_rdy : std_logic;
  signal trigger_cnt : std_logic_vector(C_TRG_CNT_WIDTH-1 downto 0);
  signal trigger_buf : std_logic;

  signal timestamp_start : std_logic_vector(64-1 downto 0);
  signal timestamp_trigger : std_logic_vector(32-1 downto 0);

  signal start_rdy : std_logic;

  signal ibus_start_time : std_logic_vector(64-1 downto 0);
  signal ibus_trigger_times : T_32BitArray(C_TRG_CNT_MAX-1 downto 0);
begin
  --! instantiate DUT
  ins_daq_timestamps: entity work.daq_timestamps
  generic map (
                G_TIMESTAMP_WIDTH => 64
              )
  port map (
             pi_clock => clock,
             pi_reset => areset,
             pi_data_str => strobe,
             pi_buf_start => buffer_start,
             pi_buf_num => '0',
             pi_trg => trg,

             po_start_time   => timestamp_start,
             po_start_rdy    => start_rdy,
             po_trigger_time => timestamp_trigger,
             po_trigger_rdy  => trigger_rdy,
             po_buf_num      => trigger_buf
           );

  --! clock generation
  clock_generator(clock, C_CLK_PERIOD);
  --clock_generator(clock, C_CLK_PERIOD, "TB clock");

  -- generate random data
  p_data: process(clock)
  begin
    if rising_edge(clock) then
      if areset = '1' then
        data <= (others => '0');
      else
        data <= random(C_DATA_WIDTH);
      end if;
    end if;
  end process;

  --! monitor the counter inside DUT
  p_monitor: process(clock)
    variable v_time_at_strobe : unsigned(64-1 downto 0);

    -- use alias for signal inside DUT (VHDL-2008 only)
    alias counter is <<signal ins_daq_timestamps.time_cnt : unsigned(64-1 downto 0)>>;

  begin
    if rising_edge(clock) then
      -- When a buffer start timestamp is ready, check with the expected value
      -- that was saved before.
      if start_rdy = '1' then
        check_value(timestamp_start, std_logic_vector(v_time_at_strobe), FAILURE, "Timestamp for buffer start must match the data strobe.");
      end if;

      -- Save the time of the last strobe.
      -- The unnecessary use of a variable requires this statement to be below
      -- the check_value() statement.
      if strobe = '1' and buffer_start = '0' then
        v_time_at_strobe := counter;
      end if;

    end if;
  end process;

  --! read trigger times when ready
  p_trigger_times: process(clock)
    variable v_trg_cnt : natural;
  begin
    if rising_edge(clock) then
      if areset = '1' then
        ibus_trigger_times <= (others => (others => '0'));
      else
        v_trg_cnt := to_integer(unsigned(trigger_cnt));
        if trigger_rdy = '1' then
          ibus_trigger_times(v_trg_cnt-1) <= timestamp_trigger;
        end if;
        trigger_cnt <= std_logic_vector(to_unsigned(v_trg_cnt, C_TRG_CNT_WIDTH));
      end if;
    end if;
  end process;

  --! main process
  p_main: process
  begin
    log(ID_LOG_HDR, "Start of daq_timestamp simulation");
    -- set initial inputs
    areset <= '0';
    strobe <= '0';
    buffer_start <= '0';
    trg <= '0';
    log("Initial values were set to 0. Enabling the clock now.");
    wait for 2*C_CLK_PERIOD;
    clock_en <= '1';
    -- enable reset signal for some clocks
    gen_pulse(areset, clock, 3, "resetting");

    wait for 2*C_CLK_PERIOD;
    trg <= '1';
    -- check outputs
    check_value(trigger_rdy, '0', FAILURE, "Trigger must not be set at this point.");

    -- set data strobe
    gen_pulse(strobe, '1', clock, 1, "Generating data strobe for 1 clock.");
    --gen_pulse(strobe, '1', clock, 1, "Generating data strobe for 1 clock.");
    -- there is a pause of one clock cycle between these two lines
    gen_pulse(buffer_start, '1', clock, 1, "Simulating start signal from burst generator writing to a buffer.");

    -- test with a continuous strobe signal
    wait for 1*C_CLK_PERIOD;
    strobe <= '1';
    wait for 2*C_CLK_PERIOD;
    buffer_start <= '1';
    wait for 1*C_CLK_PERIOD;
    buffer_start <= '0';
    wait for 1*C_CLK_PERIOD;

    -- test trigger
    --trg <= '1';
    --wait for 1*C_CLK_PERIOD;
    --trg <= '0';

    -- wait a while, then simulate another buffer start
    wait for 4*C_CLK_PERIOD;
    gen_pulse(buffer_start, '1', clock, 1, "Simulating start signal from burst generator writing to a buffer.");
    wait for 1*C_CLK_PERIOD;
    trg <= '0';
    wait for 2*C_CLK_PERIOD;

    log("done for now");
    wait;
  end process;

end architecture;
