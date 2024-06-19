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
--! @author Cagil Gumus  <cagil.guemues@desy.de>
--! @author Michael Buechler  <michael.buechler@desy.de>
------------------------------------------------------------------------------
--! @brief
--! Burst are generated here while keeping eye on the fifo status from the 
--! axi_to_daq component.
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_misc.all;
use ieee.math_real.all;

library desy;
use desy.math_basic.all;

entity burst_generator is
generic (
  G_AXI_DATA_WIDTH      : natural := 256;   --! Width of the Data Bus (bits)
  G_AXI_ADDR_WIDTH      : natural := 32;    --! Width of the Address Bus (bits) This is 'kinda' fixed
  G_AXI_BURST_LEN       : natural := 64;    --! # of beats on each burst
  G_INPUT_DATA_WIDTH    : natural := 256;   --! Input data width
  G_MODE_IS_CONTINUOUS  : natural := 0;     --! 0:= pulsed mode, 1:=continuous sampling
  G_BUF_SIZE            : natural := 1048576 -- Size of Buffer when using continous mode (DAQ0 is used for setting both
                                             -- buffers
);
port (
  pi_clock               : in std_logic:='0';                                                    --! DAQ Clock
  pi_reset             : in std_logic:='0';                                                    --! Synchronized Reset (Active High)
  pi_data              : in std_logic_vector(G_INPUT_DATA_WIDTH-1 downto 0):= (others => '0'); --! Multiplex data from daq_mux
  pi_buf0_addr         : in natural;                                                           --! Buffer 0 starting address
  pi_buf1_addr         : in natural;                                                           --! Buffer 1 starting address  
  pi_trg               : in std_logic:='0';                                                    --! DAQ Trigger Input ( It should make the address go to base)
  pi_str               : in std_logic:='0';                                                    --! Strobe Input
  pi_samples           : in std_logic_vector(31 downto 0) := (others => '0');                  --! Length of each DAQ Channel
  pi_transaction_end   : in std_logic:='0';                                                    --! User transaction reset
  pi_daq_enable        : in std_logic:='0';                                                    --! 1 => Enable 0 => Disable
  pi_dub_buf_ena       : in std_logic:='0';
  pi_pulse_number      : in std_logic_vector(31 downto 0) := (others => '0');                  --! Pulse number for active buffer
  pi_fifo_status       : in std_logic:= '0';
  po_buf_pulse_number  : out std_logic_vector(31 downto 0) := (others => '0');                 --! Pulse number for inactive buffer
  po_buff_in_use       : out std_logic;                                                        --! Shows which buffer is currently written by DAQ
  po_buf_start         : out std_logic;                                                        --! Indicates start of writing to a buffer
  po_data              : out std_logic_vector(G_AXI_DATA_WIDTH-1 downto 0);                    --! Output ports to interfacor
  po_data_str          : out std_logic;
  po_addr              : out std_logic_vector(G_AXI_ADDR_WIDTH-1 downto 0);
  po_addr_str          : out std_logic;
  po_wlast             : out std_logic
);
end entity;

architecture ARCH of burst_generator is

  --! C_PACKETS_IN_BEAT tells how many packets needed to create a full beat
  --! We convert it to real since we need to ceil the division result to make sure we have enough packets
  constant C_PACKETS_IN_BEAT    : natural := natural(FLOOR(real(G_AXI_DATA_WIDTH)/real(G_INPUT_DATA_WIDTH)));
  --! C_BEATS_FOR_PACKETS determines how many beats needed to transmit 1 packet
  constant C_BEATS_FOR_PACKETS  : natural := natural(CEIL(real(G_INPUT_DATA_WIDTH)/real(G_AXI_DATA_WIDTH)));
  constant C_RESET_HOLD_CNT     : natural := 7; --! Determines how many clock cycle daq_reset will be kept high after pi_reset arrives
                                              --! Suggested number is above 5? Because of some FIFO stuff???

  --! Obtain burst size in bytes and the buffer capacity
  constant C_BYTES_IN_BURST  : natural := G_AXI_DATA_WIDTH*G_AXI_BURST_LEN/8;

  -- Main FSM related signals
  type t_state is (RESET,IDLE,TRANSACTION);
  signal ST_state       : t_state := IDLE;
  signal reset_hold_cnt : natural := 0;
  signal daq_reset      : std_logic := '1'; --! Not sure about the INIT value here. 1 or 0 ???

  signal temp_data    : std_logic_vector(((C_PACKETS_IN_BEAT-1)*G_INPUT_DATA_WIDTH)-1 downto 0) := (others => '0');   --! Signal where we temporary store packets from daq_mux
  signal data         : std_logic_vector(G_AXI_DATA_WIDTH-1 downto 0) := (others => '0');   --! Data that goes to Interfacor
  signal wlast        : std_logic := '0';                                                   --! Last of burst indicator
  signal wlast_cnt    : natural := 0;                                                       --! Counter for End of Burst Indicator
  signal packet_cnt   : natural := 0;                                                       --! Number of packets inside burst size
  signal addr         : std_logic_vector(G_AXI_ADDR_WIDTH-1 downto 0) := (others => '0');   --! Address of the burst
  signal data_str     : std_logic := '0';                                                   --! Data Write Strobe
  signal addr_str     : std_logic := '0';                                                   --! Address Write Strobe
  signal sample_cnt   : unsigned(pi_samples'range) := (others=>'0');                       --! Counting the number of samples send to interfacor
  signal sample_length: unsigned(pi_samples'range) := (others=>'0');                       --! Counting the number of samples send to interfacor
  signal temp_data_v2 : std_logic_vector((C_BEATS_FOR_PACKETS-1)*G_AXI_DATA_WIDTH-1 downto 0) := (others => '0'); --! Signal where we temporary store packets from daq_mux
  signal beat_cnt     : natural := 0;                                                       --! Number of beats from a 1xP_I_DATA
  signal burst_cnt    : natural := 0;                                                       --! Number of bursts
  signal data_in_buffer : std_logic := '0';                                                 --! Shows if there is data in buffer in case
  signal burst_active : std_logic := '0';                                                   --! This is used in wideband transmission
  signal transaction_begin  : std_logic := '1';
  signal transaction_end    : std_logic := '0';
  signal block_next_burst   : std_logic :='0';
  signal user_transaction_end     : std_logic := '0';
  signal user_transaction_end_buf : std_logic := '0';

  --! auxiliary signals for use by interrupt controller and timestamps
  signal buf_start              : std_logic;

  --! Double buffering related signals
  signal buf_in_use             : std_logic;  --! Shows which buffer is currently being written to. Only 2 buffers can exist (hence DOUBLE buffering)
  signal first_sample_done      : std_logic;
  signal buffer_full            : std_logic;
  signal start_addr             : std_logic_vector(G_AXI_ADDR_WIDTH-1 downto 0) := (others => '0');
  --! Offsets not as generics to allow dynamic changes to the addresses
  signal buf0_offset            : std_logic_vector(G_AXI_ADDR_WIDTH-1 downto 0) := (others => '0');
  signal buf1_offset            : std_logic_vector(G_AXI_ADDR_WIDTH-1 downto 0) := (others => '0');
  signal prev_pulse_num         : std_logic_vector(31 downto 0) := (others => '0');   --! Previous pulse number
  signal pulse_num_inactive_buf : std_logic_vector(31 downto 0) := (others => '0');   --! Pulse number for the Inactive buffer

begin

--! Output port connections
  po_buff_in_use <= buf_in_use;
  po_buf_start   <= buf_start;
  po_wlast       <= wlast;
  po_data_str    <= data_str;
  po_data        <= data;
  po_addr        <= addr;
  po_addr_str    <= addr_str;
  
  -- Pulsed mode: get sample_length samples and wait for next trigger.
  -- All samples must fit into a single buffer.
  GEN_MAIN_FSM_0: if G_MODE_IS_CONTINUOUS = 0 generate
    --! user initiated transaction end
    --! keep end signal buffered until active burst completes
    process( pi_clock )
    begin
      if rising_edge( pi_clock ) then
        if pi_transaction_end = '1' and burst_active = '1' then
          user_transaction_end_buf <= '1';
        elsif burst_active = '0' then
          user_transaction_end_buf <= '0';
        end if;
      end if;
    end process;
    
    --! user end allowed when burst not active
    user_transaction_end <= ( user_transaction_end_buf or pi_transaction_end ) when burst_active = '0' else '0';
    -- The combinational logic to detect the end of a transaction is also
    -- used in PROC_SEND_BEATS
    gen_sample_count0: if G_AXI_BURST_LEN < C_BEATS_FOR_PACKETS generate
      transaction_end <= '1' when (( shift_right(sample_cnt,log2(C_BEATS_FOR_PACKETS)) >= sample_length ) 
                                 or user_transaction_end = '1' ) else '0';
    end generate;
    
    gen_sample_count1: if G_AXI_BURST_LEN >= C_BEATS_FOR_PACKETS generate
      transaction_end <= '1' when (( sample_cnt >= sample_length ) or user_transaction_end = '1' ) else '0';
    end generate;

    -- Unused in pulsed mode
    buffer_full     <= '0';

    PROC_MAIN_FSM : process(pi_clock)
    begin
      if rising_edge(pi_clock) then
        if pi_reset = '1' then
          ST_state          <= RESET;
          reset_hold_cnt <= 0;
          daq_reset      <= '1';  --! Reset the DAQ processes immediately however only deassart after C_RESET_HOLD_CNT amount of clk cycles passed
          sample_length  <= (others => '0');
          buf_in_use     <= '0';
          transaction_begin <= '1'; --! Indicate that transaction started (used for Address handling)
        else
          case ST_state is
            when RESET =>                 --! This the reset state
              if reset_hold_cnt >= C_RESET_HOLD_CNT-1 then
                reset_hold_cnt <= 0;
                ST_state          <= IDLE;
              else
                reset_hold_cnt <= reset_hold_cnt + 1;
              end if;
              daq_reset  <= '1';      --! Reset the DAQ processes
              buf_in_use <= '0';
              transaction_begin <= '1';

            when IDLE =>  --! State where all samples have been send. Now we wait until trigger comes and user is enabled the DAQ with nonzero amount of samples
              if pi_daq_enable = '1' and unsigned(pi_samples) /= 0 and pi_trg = '1' then
                daq_reset     <= '0';
                ST_state         <= TRANSACTION;
                sample_length <= unsigned(pi_samples);  --! Get how many samples to ship
              end if;

              buf_in_use <= buf_in_use;
              transaction_begin <= '1';

            when TRANSACTION =>           --! State where burst transaction is ongoing.
              --! If trigger comes at this state we simply ignore it
              if transaction_end = '1' then --! We wont leave this state until all samples are send
                daq_reset  <= '1';      --! Reset the DAQ processes
                ST_state      <= IDLE;

                -- Handle double buffering at transaction end
                if pi_dub_buf_ena = '1' then
                  buf_in_use <= not buf_in_use;
                else
                  buf_in_use <= buf_in_use;
                end if;
              else
                daq_reset  <= '0';
                ST_state      <= ST_state;
                buf_in_use <= buf_in_use;
              end if;
              transaction_begin <= '0';

            when others => ST_state <= IDLE;
          end case;
        end if;
      end if;
    end process;
  end generate;

  -- Continuous mode
  GEN_MAIN_FSM_1: if G_MODE_IS_CONTINUOUS = 1 generate
    -- The combinational logic to detect the end of a transaction is also
    -- used in PROC_SEND_BEATS
    transaction_end <= '1' when pi_daq_enable = '0' and burst_active = '0' else
                           '0';
    -- For switching buffers
    buffer_full     <= '1' when burst_cnt >= G_BUF_SIZE/C_BYTES_IN_BURST else '0';

    PROC_MAIN_FSM: process(pi_clock)
    begin
      if rising_edge(pi_clock) then
        if pi_reset = '1' then
          ST_state          <= RESET;
          reset_hold_cnt <= 0;
          daq_reset      <= '1';  --! Reset the DAQ processes immediately however only deassart after C_RESET_HOLD_CNT amount of clk cycles passed
          sample_length  <= (others => '0');
          buf_in_use     <= '0';
          transaction_begin <= '1'; --! Indicate that transaction started (used for Address handling)
        else
          case ST_state is
            when RESET =>                 --! This the reset state
                if reset_hold_cnt >= C_RESET_HOLD_CNT-1 then
                  reset_hold_cnt <= 0;
                  ST_state          <= IDLE;
                else
                  reset_hold_cnt <= reset_hold_cnt + 1;
                end if;
                daq_reset      <= '1';                 --! Reset the DAQ processes
                sample_length <= (others => '0');
                transaction_begin <= '1';
                buf_in_use     <= '0';

            when IDLE =>
              if pi_daq_enable = '1' and pi_trg = '1' then
                ST_state         <= TRANSACTION;
                sample_length <= unsigned(pi_samples);
                daq_reset     <= '0';
              else
                daq_reset     <= '1';
              end if;
              transaction_begin <= '1';
              buf_in_use     <= '0';

            when TRANSACTION =>
              --! Stay in TRANSACTION until the current burst is finished.
              if transaction_end = '1' then
                ST_state <= IDLE;
                daq_reset <= '1'; --! Reset the DAQ processes
              else
                ST_state <= ST_state;
                daq_reset <= '0';
              end if;

              --! The buffer end is detected from the number of bursts.
              if buffer_full = '1' then
                if pi_dub_buf_ena = '1' then
                  buf_in_use <= not buf_in_use;
                else
                  buf_in_use <= buf_in_use;
                end if;
                transaction_begin <= '1';
              else
                buf_in_use <= buf_in_use;
                transaction_begin <= '0';
              end if;

              sample_length <= unsigned(pi_samples);

            when others => ST_state <= IDLE;
          end case;
        end if;
      end if;
    end process;
  end generate;

  --! Common logic for transactions in either configuration (equalband,
  --! narrowband or wideband)
  PROC_SEND_COMMON: process(pi_clock)
  begin
    if rising_edge(pi_clock) then
      if daq_reset = '1' then
        addr              <= start_addr;
        first_sample_done <= '0';
        buf_start         <= '0';
      else

        --! At the beginning of a transaction, set address to the start address.
        --! At the end of each burst, increment the address accordingly.
        if transaction_begin = '1' then
          addr <= start_addr;
        elsif addr_str = '1' then
          addr <= std_logic_vector(unsigned(addr)
                      + to_unsigned(
                        G_AXI_BURST_LEN*G_AXI_DATA_WIDTH/8,
                        addr'length)); -- Give the next address
        end if;

        -- Issue a buf_start signal only on the data strobe that corresponds
        -- to the first sample in a buffer.
        if first_sample_done = '0' then
          if pi_str = '1' then
            first_sample_done <= '1';
            buf_start <= '1';
            --synthesis translate_off
            -- catch the first sample in the buffer
            report "first sample of buffer at time = " & time'image(now)
            severity note;
            --synthesis translate_on
          else
            first_sample_done <= '0';
            buf_start <= '0';
          end if;
        else
          if buffer_full = '1' then
            first_sample_done <= '0';
          else
            first_sample_done <= first_sample_done;
          end if;
          buf_start <= '0';

        end if;
      end if;
    end if;
  end process;

GEN_EQUALBAND_TRANSMISSION: if C_PACKETS_IN_BEAT = 1 generate
--! @brief Equalband tranmission means exactly 1 input data packet can fit inside one beat. Everytime strobe comes we take the data and give it to output.
--! In the meantime we are counting for WLAST flag as well as number of beats send. Address are incremented at the end of burst. If FIFOs at interfacor gets full
--! during the transaction, we complete the on going transaction and wait until FIFOs go back to normal state. During this time however address is still incrementing.
--! Which means we are simply skipping in the memory space.
  PROC_SEND_BEATS: process(pi_clock)
  begin
    if rising_edge(pi_clock) then
      if daq_reset = '1' then --! Reset is controlled by FSM
        temp_data         <= (others => '0');
        data              <= (others => '0');
        data_str          <= '0';
        addr_str          <= '0';
        wlast             <= '0';
        sample_cnt        <= (others => '0');
        packet_cnt        <= 0;
        beat_cnt          <= 0;
        burst_cnt         <= 0;
        block_next_burst  <= pi_fifo_status;
        burst_active      <= '0';

      --! daq_reset is only cleared for the TRANSACTION state, so if it's
      --! not set then we must be in TRANSACTION.
      else

        if pi_str = '1' then
          data(pi_data'range) <= pi_data ;
          --! Don't transmit after the end of a transaction
          if transaction_end = '1' then  
            data_str <= '0';
          else
            data_str <= not block_next_burst;
          end if;

          if beat_cnt = G_AXI_BURST_LEN -1 then --! If we reach the end of burst
            beat_cnt          <= 0;
            sample_cnt        <= sample_cnt + G_AXI_BURST_LEN;
            wlast             <= '1';
            addr_str          <= not block_next_burst;
            block_next_burst  <= pi_fifo_status; --! Update the next burst transaction allowance
            burst_cnt         <= burst_cnt+1;
            burst_active      <= '0';
          elsif beat_cnt = 0 then --! Begining of burst
            beat_cnt     <= beat_cnt + 1;
            wlast        <= '0';
            addr_str     <= '0';
            burst_active <= '1';
          else
            beat_cnt     <= beat_cnt + 1;
            addr_str     <= '0';
            burst_active <= '1';
          end if;
        else --! If there is no strobe on transaction state
          data_str     <= '0';
          addr_str     <= '0';
          wlast        <= '0';
          burst_active <= burst_active;
        end if;

        -- Reset burst count when buffer is full.
        -- Takes precedence over the previous assignment.
        if G_MODE_IS_CONTINUOUS = 1 then
          if buffer_full = '1' then
            burst_cnt <= 0;
          end if;
        end if;

      end if;
    end if;
  end process;
end generate;


--! Example: when combined packets are smaller than Burst size
--! G_INPUT_DATA_WIDTH = n*32 (where n= 4) and  G_AXI_DATA_WIDTH = 256 then
--! where n=number of channels that pi_data has
--! In this case we need two strobes to fill the burst.
--!
--!  MSB         Packet Layout      LSB
--! <----------- 128 bits ---------->
--! |=======|=======|=======|=======|
--! |  D[0] | C[0]  | B[0]  | A[0]  |
--! | 32bit | 32bit | 32bit | 32bit |
--! |=======|=======|=======|=======|
--!
--!
--! MSB                        Beat Layout (data)            LSB
--! <--------------------------- 256 bits -------------------------->
--! |=======|=======|=======|=======|=======|=======|=======|=======|
--! |  D[0] | C[0]  | B[0]  | A[0]  | D[1]  | C[1]  | B[1]  | A[1]  |
--! | 32bit | 32bit | 32bit | 32bit | 32bit | 32bit | 32bit | 32bit |
--! |=======|=======|=======|=======|=======|=======|=======|=======|
--!
--! Where A[0] is channel 0 when strobe is high at t=0.
--! Where A[1] is channel 0 when strobe is high at t=1.
--! Where B[0] is channel 1 when strobe is high at t=0.
--! Where A[1] is channel 1 when strobe is high at t=1.


GEN_NARROWBAND_TRANSMISSION: if C_PACKETS_IN_BEAT > 1 generate
--! @brief In this process we are taking chunks of packets (which is n* 32 bits wide) and putting them
--! inside the burst. Once the burst is filled we are giving the DATA_STR 1
--! During this time generated bursts are counted. If this number reaches G_AXI_BURST_LEN
--! po_wlast is driven to high to indicate the burst has been finished.
  PROC_SEND_BEATS: process(pi_clock)
  begin
    if rising_edge(pi_clock) then

      if daq_reset = '1' then --! Reset is controlled by FSM
        temp_data   <= (others => '0');
        data        <= (others => '0');
        data_str    <= '0';
        addr_str    <= '0';
        wlast       <= '0';
        sample_cnt  <= (others => '0');
        packet_cnt  <= 0;
        beat_cnt    <= 0;
        burst_cnt         <= 0;
        block_next_burst  <= pi_fifo_status;
        burst_active      <= '0';

      --! daq_reset is only cleared for the TRANSACTION state, so if it's
      --! not set then we must be in TRANSACTION.
      else

        if pi_str = '1' then
          if packet_cnt =  C_PACKETS_IN_BEAT-1 then
            data_str <= not block_next_burst;
            packet_cnt <= 0;
            data(pi_data'left + G_INPUT_DATA_WIDTH*(C_PACKETS_IN_BEAT-1) downto 0) <= pi_data & temp_data((G_INPUT_DATA_WIDTH*(C_PACKETS_IN_BEAT-1))-1 downto 0);
            if beat_cnt = G_AXI_BURST_LEN -1 then --! If we reach the end of burst
              beat_cnt          <= 0;
              sample_cnt        <= sample_cnt + G_AXI_BURST_LEN*C_PACKETS_IN_BEAT;
              wlast             <= '1';
              addr_str          <= not block_next_burst;
              block_next_burst  <= pi_fifo_status;
              burst_cnt         <= burst_cnt+1;
              burst_active      <= '0';
            else
              beat_cnt     <= beat_cnt + 1;
              wlast        <= '0';
              burst_active <= '1';
            end if;
          else --! @TODO Beautify this line
            temp_data(G_INPUT_DATA_WIDTH*(packet_cnt+1)-1 downto G_INPUT_DATA_WIDTH*packet_cnt) <= pi_data;
            packet_cnt   <= packet_cnt + 1;
            data_str     <= '0';
            addr_str     <= '0';
            wlast        <= '0';
            burst_active <= '1';
          end if;
        else --! If there is no strobe on transaction state
          data_str    <= '0';
          addr_str    <= '0';
          wlast       <= '0';
        end if;

        -- Reset burst count when buffer is full.
        -- Takes precedence over the previous assignment.
        if G_MODE_IS_CONTINUOUS = 1 then
          if buffer_full = '1' then
            burst_cnt <= 0;
          end if;
        end if;

      end if;
    end if;
  end process;
end generate;


--! Example: when combined packets are bigger than Burst size
--! G_INPUT_DATA_WIDTH = n*32 and (where n= 14) G_AXI_DATA_WIDTH = 256 then
--! where n=number of channels that pi_data has
--! In this case we need two bursts to send the entire packet.
--!
--!  MSB                                         Packet Layout                                                   LSB
--! <----------- ----------------------------------512 bits -------------------------------------------------------->
--! |=======|=======|=======|=======|=======|=======|=======|=======|=======|=======|=======|=======|=======|=======|
--! |  N[0] | M[0]  | L[0]  | K[0]  | J[0]  | I[0]  | H[0]  | G[0]  | F[0]  | E[0]  | D[0]  | C[0]  | B[0]  | A[0]  |
--! | 32bit | 32bit | 32bit | 32bit | 32bit | 32bit | 32bit | 32bit | 32bit | 32bit | 32bit | 32bit | 32bit | 32bit |
--! |=======|=======|=======|=======|=======|=======|=======|=======|=======|=======|=======|=======|=======|=======|
--!
--! First Beat:
--!
--! MSB                        Beat Layout (po_data)            LSB
--! <--------------------------- 256 bits -------------------------->
--! |=======|=======|=======|=======|=======|=======|=======|=======|
--! |  N[0] | M[0]  | L[0]  | K[0]  | J[0]  | I[0]  | H[0]  | G[0]  |
--! | 32bit | 32bit | 32bit | 32bit | 32bit | 32bit | 32bit | 32bit |
--! |=======|=======|=======|=======|=======|=======|=======|=======|

--! Second Beat:
--!
--! MSB                        Beat Layout (po_data)            LSB
--! <--------------------------- 256 bits -------------------------->
--! |=======|=======|=======|=======|=======|=======|=======|=======|
--! |  F[0] | E[0]  | D[0]  | C[0]  | B[0]  | A[0]  | xxxxxxxxxxxx  |
--! | 32bit | 32bit | 32bit | 32bit | 32bit | 32bit | xxxxxxxxxxxx  |
--! |=======|=======|=======|=======|=======|=======|=======|=======|
--!

--!
--! Where A[0] is channel 0 when strobe is high at t=0.
--! Where A[1] is channel 0 when strobe is high at t=1.
--! Where B[0] is channel 1 when strobe is high at t=0.
--! Where A[1] is channel 1 when strobe is high at t=1.


GEN_WIDEBAND_TRANSMISSION: if C_PACKETS_IN_BEAT < 1 generate
--! @brief In this process we are cutting input data (which is n* 32 bits wide) to AXI_DATA_WIDTH chunks and send it as burst.
--! When strobe comes we immedately take the first packet and give it to output. The rest is send on each clock cycle. Once we send those
--! other packets we wait for the next strobe. This means if strobe comes during our intermediate transition we simply ignore those strobes.
--! Which means we will decimate the data. We have no other option.
  PROC_SEND_BEATS: process(pi_clock)
  begin
    if rising_edge(pi_clock) then
      if daq_reset = '1' then  --! Reseting is controlled by FSM
        temp_data_v2      <= (others => '0');
        data              <= (others => '0');
        data_str          <= '0';
        addr_str          <= '0';
        wlast             <= '0';
        sample_cnt        <= (others => '0');
        packet_cnt        <= C_BEATS_FOR_PACKETS-1;
        data_in_buffer    <= '0';
        beat_cnt          <= 0;
        burst_cnt         <= 0;
        block_next_burst  <= pi_fifo_status;
        burst_active      <= '0';

      --! daq_reset is only cleared for the TRANSACTION state, so if it's
      --! not set then we must be in TRANSACTION.
      else

        --! assigns:
        --! burst_active: set to '1' during transaction, but set to '0'
        --!                   on the last beat/packet of an input data set.
        if pi_str = '1' and data_in_buffer  = '0' then --! Fetch the data and give one beat immedately
          data <= pi_data(G_AXI_DATA_WIDTH-1 downto 0); -- Give it immediately
          temp_data_v2(pi_data'left-G_AXI_DATA_WIDTH downto 0) <= pi_data(pi_data'left downto G_AXI_DATA_WIDTH); -- This one will be sent 1 clk cycle later
          packet_cnt <= 0;
          data_in_buffer <= '1'; --! Indicate that there are still packets to send  (intermediate packets is waiting to be sent)
          --! Don't transmit after the end of a transaction,
          --! or when the next burst is blocked
          if block_next_burst = '1' or transaction_end = '1' then
            data_str     <= '0';
            burst_active <= '0';
          else
            data_str <= not block_next_burst;
            burst_active <= '1';
          end if;
        elsif data_in_buffer  = '1' then    --! Send intermediate packets one after another
          if packet_cnt = C_BEATS_FOR_PACKETS-1 then
            data_str <= '0';
            packet_cnt <= 0;
            burst_active <= '1';
          elsif packet_cnt = C_BEATS_FOR_PACKETS-2 then --! This indication comes 1 strobe early so we can catch the next strobe
            data_in_buffer <= '0';
            packet_cnt <= packet_cnt + 1;
            temp_data_v2 <= std_logic_vector(shift_right(unsigned(temp_data_v2), G_AXI_DATA_WIDTH)); --! Shift buffer by axi width
            data <= temp_data_v2(data'range);
            data_str <= not block_next_burst;
            burst_active <= '0';
          else
            packet_cnt <= packet_cnt + 1;
            temp_data_v2 <= std_logic_vector(shift_right(unsigned(temp_data_v2), G_AXI_DATA_WIDTH)); --! Shift buffer by axi width
            data <= temp_data_v2(data'range);
            data_str <= not block_next_burst;
            burst_active <= '1';
          end if;
        else --! If no strobe AND no data in buffer
          data_str <= '0';
          burst_active <= '0';
        end if;

        if pi_str = '1' or data_in_buffer = '1' then
          if beat_cnt = G_AXI_BURST_LEN -1 then --! If we reach the end of burst
            beat_cnt    <= 0;
            wlast       <= '1';
            addr_str    <= not block_next_burst;
            if shift_right(sample_cnt,log2(C_BEATS_FOR_PACKETS)) >= sample_length then
              addr_str  <= '0';
              wlast     <= '0';
            else 
              sample_cnt  <= sample_cnt + natural(ceil(real(G_AXI_BURST_LEN)/real(C_BEATS_FOR_PACKETS)));
              block_next_burst <= pi_fifo_status;
              burst_cnt        <= burst_cnt+1;
            end if;
          else
            beat_cnt  <= beat_cnt + 1;
            addr_str  <= '0';
            wlast     <= '0';
          end if;
        else
          addr_str  <= '0';
          wlast     <= '0';
        end if;

        -- Reset burst count when buffer is full.
        -- Takes precedence over the previous assignment.
        if G_MODE_IS_CONTINUOUS = 1 then
          if buffer_full = '1' then
            burst_cnt <= 0;
          end if;
        end if;

      end if;
    end if;
  end process;
end generate;

--! @brief This process handles the double buffering. It saves the data on 1 buffer while other buffer is read by server
--! During the readout process by server, pi_dub_buf_ena stays low. When server finishes the read process it enables the pi_dub_buf_ena. When DAQ_TRG arrives active buffer will be switched to
--! other one. Before we switch buffer we also attach the pulse number to the buffer which will be used by reading from server
--! Buffer in use means buffer which is used to write
--! Inactive buffer is the one which server reads from
start_addr <= std_logic_vector(to_unsigned(pi_buf0_addr,G_AXI_ADDR_WIDTH)) when buf_in_use = '0' else
              std_logic_vector(to_unsigned(pi_buf1_addr,G_AXI_ADDR_WIDTH)) when buf_in_use = '1' else
              std_logic_vector(to_unsigned(pi_buf0_addr,G_AXI_ADDR_WIDTH));

PROC_DOUBLE_BUF_HANDLER: process(pi_clock)
begin
  if rising_edge(pi_clock) then
    if daq_reset = '1' then
      prev_pulse_num    <= (others=>'0');
      po_buf_pulse_number  <= (others=>'0');
    else
      if pi_trg = '1' and ST_state = IDLE then
        if pi_dub_buf_ena = '1' then --! When its enabled we switch with each DAQ_TRG
          prev_pulse_num    <= pi_pulse_number;    --! Save the pulse number for the next buffer until next TRG arrives
          po_buf_pulse_number  <= prev_pulse_num;  --! Use the last saved pulse number for the buffer which will be read from server
        else
          po_buf_pulse_number <= pi_pulse_number;
        end if;
      end if;
    end if;
  end if;
end process;

end ARCH;
