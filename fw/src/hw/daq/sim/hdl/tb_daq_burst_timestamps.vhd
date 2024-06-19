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
--! @file   tb_daq_burst_timestamps.vhd
--! @brief  Testbench for DAQ burst and timestamp generation
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

--library uvvm_util;
--context uvvm_util.uvvm_util_context;

entity tb_daq_burst_timestamps is
  -- no generics
  -- no ports
end entity;

architecture tb_arch of tb_daq_burst_timestamps is
  constant C_CLK_PERIOD : time := 8 ns;
  --! use one channel of 256 bits
  constant C_DATA_WIDTH : natural := 256;
  constant C_CHANNEL_COUNT : natural := 1;
  constant C_DAQ_TAB_COUNT : natural := 1;
  constant C_DAQ_TAB_CONTENTS : T_NaturalArray(C_DAQ_TAB_COUNT*C_CHANNEL_COUNT-1 downto 0) := (0 => 0);
  constant C_BUF1_OFFSET : natural := (1024)*256/8; -- in bytes. Must be > AXI_width*burst_len/8
  constant C_DAQ_BURST_LEN : natural := 1;
  constant C_DAQ_IS_CONTINUOUS : natural := 1;

  constant C_READ_TIME_MAX : natural := C_BUF1_OFFSET * 5;

  constant C_TRG_DIV : natural := 0;
  constant C_DUB_BUF : natural := 1;

  constant C_EXT_STROBE_DIV : natural := 1;

  signal clock : std_logic;
  signal areset : std_logic;
  signal clock_en : std_logic;

  signal daq_enable : std_logic;
  signal daq_enable_q : std_logic;

  signal dub_buf_ena : std_logic := '0';

  signal data : std_logic_vector(C_DATA_WIDTH-1 downto 0);
  signal data_q : std_logic_vector(C_CHANNEL_COUNT*C_DATA_WIDTH-1 downto 0);
  signal strobe : std_logic;
  signal strobe_q : std_logic;
  signal buffer_start : std_logic;
  signal buffer_done : std_logic;
  signal trg, trg_q : std_logic;
  signal trg_divcnt : natural;

  signal ext_strobe : std_logic;
  signal ext_strobe_divcnt : natural;

  signal trigger_rdy : std_logic;
  signal trigger_buf : std_logic;

  signal start_time : std_logic_vector(64-1 downto 0);
  signal trigger_time : std_logic_vector(32-1 downto 0);

  signal start_rdy : std_logic;

  -- for additional modules
  signal strobe_reset : std_logic := '0';
  signal strobe_div : std_logic_vector(32-1 downto 0) := (others => '0');
  signal strobe_trigger_cnt : std_logic_vector(32-1 downto 0);

  signal fifo_status : std_logic;
  signal data_out : std_logic_vector(C_CHANNEL_COUNT*C_DATA_WIDTH-1 downto 0);
  signal strobe_out : std_logic;
  signal addr_out : std_logic_vector(32-1 downto 0);
  signal addr_strobe_out : std_logic;
  signal buff_in_use : std_logic;
  signal wlast : std_logic;

  --! for checking timestamps
  signal time_tb : natural;
  signal trigger_time_tb : natural;

  --! for simulating reads
  signal read_active : std_logic;
  signal read_buffer : std_logic;
  signal read_time : natural;
  signal read_duration : natural range 0 to C_READ_TIME_MAX := C_BUF1_OFFSET/(C_DATA_WIDTH/8)*2-2;

  --! for putting timestamps to an IBUS AREA
  signal l_times_wr    : std_logic;
  signal l_times_rd    : std_logic;
  signal l_times_ena   : std_logic;

  signal daq_mem_ii_data : std_logic_vector(32-1 downto 0);

  signal l_mem_wen    : std_logic;
  signal l_mem_wdata  : std_logic_vector(32-1 downto 0);
  signal l_mem_pos    : std_logic_vector(10-1 downto 0);
begin
  ----------------------------------------------------------------
  --
  -- Instantiate design under test (DUT)
  -- * strobe divider
  -- * channel multiplexer
  -- * burst generator
  -- * timestamp handling + transfer to IBUS
  --
  ----------------------------------------------------------------

  --! generate an external strobe signal
  p_ext_strobe: process(clock)
  begin
    if rising_edge(clock) then
      if areset = '1' then
        ext_strobe <= '0';
        ext_strobe_divcnt <= 0;
      else
        if ext_strobe_divcnt = C_EXT_STROBE_DIV then
          ext_strobe <= '1';
          ext_strobe_divcnt <= 0;
        else
          ext_strobe <= '0';
          ext_strobe_divcnt <= ext_strobe_divcnt+1;
        end if;
      end if;
    end if;
  end process;

  gen_strobe_reset_cont: if C_DAQ_IS_CONTINUOUS = 1 generate
    strobe_reset <= areset;
  end generate;
  gen_strobe_reset_pulsed: if C_DAQ_IS_CONTINUOUS = 0 generate
    strobe_reset <= trg;
  end generate;


  INST_STROBE_DIVIDER: entity work.timing_ext_div
  generic map(
               G_CHANNELS => 1
             )
  port map(
            pi_clk         => clock,
            pi_reset       => strobe_reset,
            pi_ext_rst     => (others => '0'),
            pi_ext_ena(0)  => '1',
            pi_ext_trg(0)  => ext_strobe,
            pi_div(0)      => strobe_div,
            po_trg_cnt(0)  => strobe_trigger_cnt,
            po_trg(0)      => strobe     --! Goes into MUX and later propagates with l_daq_str
          );


  INST_DAQ_MUX : entity work.daq_mux
  generic map (
                G_CHANNEL_WIDTH     => 8*4*8, -- This is fixed.(THIS MUST BE MULTIPLES OF 8)
                G_IN_CHANNEL_COUNT  => 1,
                G_OUT_CHANNEL_COUNT => 1,
                G_TAB_COUNT         => 1,
                G_SEL_SIZE          => 8 -- This is determined by WORD_DAQ_MUX size
              )
  port map (
             pi_clk         => clock,
             --pi_channel_tab => (7, 6, 5, 4, 3, 2, 1, 0);
             pi_channel_tab => C_DAQ_TAB_CONTENTS,
             pi_sel         => (others => '0'),
             pi_data        => data,
             po_data        => data_q,
             pi_daq_enable  => daq_enable,
             pi_daq_trg     => trg,
             pi_daq_dry     => strobe,
             po_daq_enable  => daq_enable_q, --! Enable flag needs to be propagated from MUX
             po_daq_trg     => trg_q,      --! Start flag for burst generator (DAQ Trigger)
             po_daq_dry     => strobe_q
           );

  INST_BURST_GENERATOR: entity work.burst_generator
  generic map(
               G_AXI_DATA_WIDTH    => 256,
               G_AXI_ADDR_WIDTH    => 32,
               G_AXI_BURST_LEN     => C_DAQ_BURST_LEN,
               G_INPUT_DATA_WIDTH  => C_DATA_WIDTH,
               G_MODE_IS_CONTINUOUS=> C_DAQ_IS_CONTINUOUS,
               G_BUF1_OFFSET       => C_BUF1_OFFSET --! offset of buffer 1 start from buffer 0 start
             )
  port map(
            pi_clk                => clock,                         --! DAQ Clock
            pi_reset              => areset,                       --! Synchronized Reset (Active High)
            pi_data               => data_q,                          --! Multiplex data from daq_mux
            pi_start_addr_0       => 0,                               --! Buffer 0 starting address
            pi_trg                => trg_q,                           --! DAQ Trigger Input ( It should make the address go to base)
            pi_str                => strobe_q,              --! Strobe Input coming from MUX
            pi_samples            => std_logic_vector(to_unsigned(129, 32)),
            --pi_samples            => std_logic_vector(to_unsigned(C_BUF1_OFFSET/(C_DATA_WIDTH/8), 32)), --! Length of each DAQ Channel
            pi_daq_enable         => daq_enable_q,           --! 1 => Enable 0 => Disable
            pi_dub_buf_ena        => dub_buf_ena,              --! 1 => Double Buffering is enabled
            pi_pulse_number       => (others => '0'),                --! Pulse number for active buffer
            pi_fifo_status        => fifo_status,              --! Interfacor tells burst generator to stop if FIFOs are full
            po_buf_pulse_number   => open,       --! Pulse number for inactive buffer
            po_buff_in_use        => buff_in_use,           --! Shows which buffer is currently written by DAQ
            po_buf_start          => buffer_start,                --! Indicates start of writing to a buffer
            po_data               => data_out,                     --! Data to Interfacor
            po_data_str           => strobe_out,                 --! Data Strobe to Interfacor
            po_addr               => addr_out,                     --! Address to Interfacor
            po_addr_str           => addr_strobe_out,                 --! Address Strobe to Interfacor
            po_wlast              => wlast                     --! Last of Burst indication for Interfacor
          );

  ins_daq_timestamps: entity work.daq_timestamps
  generic map (
                G_TIMESTAMP_WIDTH => 64
              )
  port map (
             pi_clock => clock,
             pi_reset => areset,
             pi_data_str => strobe_q,
             pi_buf_start => buffer_start,
             pi_buf_num   => buff_in_use,
             pi_trg => trg_q,

             po_start_time   => start_time,
             po_start_rdy    => start_rdy,
             po_trigger_time => trigger_time,
             po_trigger_rdy  => trigger_rdy,
             po_buf_num      => trigger_buf
           );

      ins_timestamps_to_mem : entity work.daq_timestamps_to_mem
      generic map (
                    G_TIMESTAMP_WIDTH => 64,
                    G_TRG_CNT_MAX     => 510,
                    G_ADDR_WIDTH      => 10
                  )
      port map (
                 pi_clock => clock,
                 pi_reset => areset,

                 pi_buf_start    => buffer_start,

                 pi_start_time   => start_time,
                 pi_start_rdy    => start_rdy,
                 pi_trigger_time => trigger_time,
                 pi_trigger_rdy  => trigger_rdy,
                 pi_buf_in_use   => trigger_buf,

                 po_en           => l_mem_wen,
                 po_data         => l_mem_wdata,
                 po_addr         => l_mem_pos,
                 po_trg_cnt_buf0 => open,
                 po_trg_cnt_buf1 => open
               );

      l_times_wr  <= '0';
      l_times_rd  <= '0';
      l_times_ena <= l_times_rd or l_times_wr;

      --! Port A is accessed from IBUS through AREA_DAQ_TIMES
      --! Port B is written to by the DAQ timestamp component
      INST_TIMESTAMP_RAM : entity work.ENT_DPM
      generic map(
                   GEN_WORD_WIDTH => 32,
                   GEN_ADDR_WIDTH => 10
                 )
      port map (
                 P_I_CLK_A  => clock,
                 P_I_ENA_A  => l_times_ena,
                 P_I_WR_A   => l_times_wr,
                 P_I_ADDR_A => (others => '0'),
                 P_I_DATA_A => (others => '0'),
                 P_O_DATA_A => daq_mem_ii_data(32-1 downto 0),

                 P_I_CLK_B  => clock,
                 P_I_ENA_B  => '1',
                 P_I_WR_B   => l_mem_wen,
                 P_I_ADDR_B => l_mem_pos,
                 P_I_DATA_B => l_mem_wdata,
                 P_O_DATA_B => open
               );

  ----------------------------------------------------------------
  --
  -- Start of testbench processes
  --
  ----------------------------------------------------------------

  --! clock generation
  --clock_generator(clock, C_CLK_PERIOD);
  --clock_generator(clock, C_CLK_PERIOD, "TB clock");
  p_clock: process
  begin
    clock <= '1';
    wait for C_CLK_PERIOD/2;
    clock <= '0';
    wait for C_CLK_PERIOD/2;
  end process;

  -- generate random data
  p_data: process(clock)
  begin
    if rising_edge(clock) then
      if areset = '1' then
        --data <= (others => '0');
      else
        --data <= random(C_DATA_WIDTH);
        --data <= (others => '0');
        --data <= std_logic_vector(to_unsigned(time_tb, data'length));
      end if;
    end if;
  end process;

  data <= std_logic_vector(to_unsigned(trg_divcnt, data'length));

  --! count each clock to compare with
  p_count_clocks: process(clock)
    variable v_buffer_time : natural; -- range 0 to 2**15+2**15-1;
    variable v_trg_time : natural; -- range 0 to 2**15+2**15-1;
    --variable v_trg_time_tb : natural range 0 to 2**15+2**15-1;
  begin
    if rising_edge(clock) then
      if areset = '1' then
        time_tb <= 0;
        trigger_time_tb <= 0;
      else

        -- TB-local time
        if trg_q = '1' then
          trigger_time_tb <= time_tb;
        end if;

        -- time from daq_timestamps, available one clock after trg_q
        if trigger_rdy = '1' then
          v_buffer_time := to_integer(unsigned(start_time));
          v_trg_time := to_integer(unsigned(trigger_time)) + v_buffer_time;

          assert v_trg_time = trigger_time_tb
          report "trigger time mismatch: tb=" & natural'image(trigger_time_tb)
          & ", module=" & natural'image(v_trg_time)
          severity failure;
        end if;

        time_tb <= time_tb+1;

      end if;
    end if;
  end process;

  --! generate a periodic trigger signal
  p_trigger: process(clock)
  begin
    if rising_edge(clock) then
      if areset = '1' then
        trg <= '0';
        trg_divcnt <= 0;
      else
        if trg_divcnt = C_TRG_DIV then
          trg <= '1';
          trg_divcnt <= 0;
        else
          trg <= '0';
          trg_divcnt <= trg_divcnt+1;
        end if;
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
        assert start_time = std_logic_vector(v_time_at_strobe)
        report "Timestamp for buffer start must match the data strobe."
        severity failure;
        --! UVVM code disabled
        --check_value(start_time, std_logic_vector(v_time_at_strobe),
        --FAILURE, "Timestamp for buffer start must match the data strobe.");
      end if;

      -- Save the time of the last strobe.
      -- The unnecessary use of a variable requires this statement to be below
      -- the check_value() statement.
      if strobe_q = '1' and buffer_start = '0' then
        v_time_at_strobe := counter;
      end if;

    end if;
  end process;

  --! Simulate reads:
  --! * clear dub_buf_ena during reads
  --! * check buffer_done to initiate a read
  p_read_buffer: process(clock)
  begin
    if rising_edge(clock) then
      if areset = '1' then
        -- dub_buf_ena to default
        dub_buf_ena <= '1';
        read_active <= '0';
        read_buffer <= '0';
      else

        -- simulate double buffering?
        if C_DUB_BUF = 1 then
          if read_active = '0' then
            if buffer_done = '1' then
              read_active <= '1';
            end if;
          else
            if read_time = read_duration then
              read_active <= '0';
            end if;
          end if;

          if read_active = '1' then
            dub_buf_ena <= '0';

            --! delay first simulated read by one clock.
            --! Likewise, software would check the buff_in_use _after_ inhibiting
            --! buffer switches.
            if dub_buf_ena = '0' then
              read_time <= read_time + 1;
              read_buffer <= not buff_in_use;
            end if;
          else
            dub_buf_ena <= '1';
            read_time <= 0;
          end if;

        -- no double buffering simulation
        else
          dub_buf_ena <= '0';
          read_active <= '0';
          read_buffer <= '1';
        end if;
      end if;
    end if;
  end process;

  --! checks
  p_checks: process
    variable v_check : std_logic;
  begin
    wait until rising_edge(clock);

    --! Verify that no writes happen on the buffer that is being read by
    --! software.
    v_check := '0';
    if dub_buf_ena = '0' and addr_strobe_out = '1' then
      if buff_in_use = read_buffer then
        v_check := '1';
      end if;
    end if;
    assert v_check = '0'
    report "Illegal write to buffer being read"
    severity failure;
    v_check := '0';

    --! notify when a buffer switch is prevented
    assert not (read_active = '1' and buffer_done = '1')
    report "Buffer switch prevented due to active read"
    severity note;

    --! sanity: buffer_start and buffer_done shouldn't both be '1'
    assert not (buffer_start = '1' and buffer_done = '1')
    report "buffer_start and buffer_done both '1'"
    severity failure;

    --! sanity: trigger times should be within the expected length of the
    --! transaction
    if trigger_rdy = '1' then
      if to_integer(unsigned(trigger_time)) >= C_BUF1_OFFSET * (1+to_integer(unsigned(strobe_div))) then
        v_check := '1';
      end if;
    end if;
    assert v_check = '0'
    report "Trigger time offset exceeds timespan covered by one buffer"
    severity failure;
    v_check := '0';

  end process;

  --! one option for testing triggers: trigger with each active sample
  --trg <= strobe;

  --! main process
  p_main: process
  begin
    --log(ID_LOG_HDR, "Start of daq_timestamp simulation");
    -- set initial inputs
    areset <= '1';
    strobe_div <= std_logic_vector(to_unsigned(0, 32));
    -- test with a continuous strobe signal
    --strobe_div <= (others => '0');
    --trg <= '0';
    daq_enable <= '0';
    fifo_status <= '0'; -- FIFO never full
    --log("Initial values were set to 0. Enabling the clock now.");
    wait for 1*C_CLK_PERIOD;
    clock_en <= '1';
    -- keep reset signal high for some clocks
    wait for 3*C_CLK_PERIOD;
    areset <= '0';

    -- DAQ burst generator is still in reset for a while
    wait for 5*C_CLK_PERIOD;
    daq_enable <= '1';
    --check_value(trigger_rdy, '0', FAILURE, "Trigger must not be set at this point.");

    wait for 1*C_CLK_PERIOD;
    --trg <= '1';
    --check_value(trigger_rdy, '0', FAILURE, "Trigger must not be set at this point.");
    wait for 1*C_CLK_PERIOD;
    --trg <= '1';
    wait for 1*C_CLK_PERIOD;
    --check_value(trigger_rdy, '1', FAILURE, "Trigger must not be set at this point.");
    -- check outputs

    -- test trigger
    --trg <= '1';
    --wait for 1*C_CLK_PERIOD;
    --trg <= '0';

    --log("done for now");
    wait;
  end process;

end architecture;
