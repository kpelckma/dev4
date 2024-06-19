-------------------------------------------------------------------------------
--          ____  _____________  __                                          --
--         / __ \/ ____/ ___/\ \/ /                 _   _   _                --
--        / / / / __/  \__ \  \  /                 / \ / \ / \               --
--       / /_/ / /___ ___/ /  / /               = ( M | S | K )=             --
--      /_____/_____//____/  /_/                   \_/ \_/ \_/               --
--                                                                           --
-------------------------------------------------------------------------------
-- $Header: https://mskllrfredminesrv.desy.de/svn/utca_firmware_framework/trunk/modules/MISC/DAQ/tb/tb_axi2daq.vhd 3665 2020-03-24 18:42:21Z mbuechl $
-------------------------------------------------------------------------------
--! @file   tb_axi2daq.vhd
--! @brief  testbench for axi2daq component used in DDR2 interfaces (FMC25)
--! @details axi2daq: converts axi4full bus to old DAQ bus
--! $Date: 2020-03-24 19:42:21 +0100 (Di, 24 Mär 2020) $
--! $Revision: 3665 $
--! $URL: https://mskllrfredminesrv.desy.de/svn/utca_firmware_framework/trunk/modules/MISC/DAQ/tb/tb_axi2daq.vhd $
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_misc.all;
use work.math_basic.all;
use ieee.math_real.all;
use work.PKG_AXI.all;
use work.PKG_DAQ.all;

-- -- text IO
-- use STD.textio.all;
-- use ieee.std_logic_textio.all;


ENTITY tb_axi2daq IS
END tb_axi2daq;

ARCHITECTURE behavior OF tb_axi2daq IS

  -- Constants for generics
  constant G_AXI_DATA_WIDTH    : natural := 128;    --! Width of the Data Bus (bits) (effects Burst Size)
  constant G_AXI_BURST_LEN     : natural := 256;     --! # of beats on each burst (Max 256 Min 1)
  constant G_AXI_ADDR_WIDTH    : natural := 32;     --! Width of the Address Bus (bits) This is fixed
  constant G_INPUT_DATA_WIDTH  : natural := 256;    --! Data size from DAQ_MUX
  constant G_MODE_IS_CONTINUOUS: natural := 0;      --! Burst generator mode: 0:= pulsed, 1:=continuous
  constant G_FIFO_DEPTH        : natural := 256;
  constant G_ARCH_TYPE         : string  := "GENERIC"; --! Allowed Values VIRTEX5, VIRTEX6, 7SERIES,GENERIC

  constant C_BUF0_START_ADDRESS : natural := 0;
  constant C_BUF1_START_ADDRESS : natural := 6969;
  --constant G_START_ADDR_0      : natural := C_BUF0_START_ADDRESS;
  --constant G_START_ADDR_1      : natural := C_BUF1_START_ADDRESS;
  constant G_BUF1_OFFSET          : natural := C_BUF1_START_ADDRESS;

  -- Constants for simulation
  constant C_STR_FREQ_DIV  : natural := 1;        --! Frequency of pi_str =  Frequency of pi_clk/C_STR_FREQ_DIV
  constant C_TRG_FREQ_DIV  : natural := 1000;     --! Frequency of pi_trg =  Frequency of pi_str/C_TRG_FREQ_DIV
  constant C_SIMULATION_TIME  : time := 1 ms;
  constant C_NUM_SAMPLES   : natural := 16384;       --! Number of samples to send
  constant C_ENABLE_FIFO_STIMULUS : boolean := FALSE ;
  constant C_FIFO_FULL_TIME : time := 100 us;       --! FIFO full flag cycling frequency
  constant C_PACKETS_IN_BEAT    : natural := natural(FLOOR(real(G_AXI_DATA_WIDTH)/real(G_INPUT_DATA_WIDTH)));

  -- Clock period definitions
  constant pi_clk_period  : time := 10 ns;  -- 100 MHz
  -- Clock period definitions
  constant pi_aclk_period  : time := 5 ns;  -- 100 MHz

  --Inputs
  signal pi_clk                : std_logic := '0';
  signal pi_aclk               : std_logic := '0';
  signal pi_areset_n           : std_logic := '0';
  signal pi_reset              : std_logic := '0';
  signal pi_data               : std_logic_vector(G_INPUT_DATA_WIDTH-1 downto 0) := (others => '0');
  signal pi_trg                : std_logic := '0';
  signal pi_str                : std_logic := '0';
  signal pi_samples            : std_logic_vector(31 downto 0) := (others => '0');
  signal pi_daq_enable         : std_logic := '0';
  signal pi_dub_buf_ena        : std_logic := '0';
  signal pi_pulse_number       : std_logic_vector(31 downto 0) := (others => '0');                 --! Pulse number for active buffer
  signal pi_start_addr_0       : natural := C_BUF0_START_ADDRESS;
  signal pi_fifo_status        : std_logic := '0';
  signal AXI4_M2S               : T_AXI4_M2S;
  signal AXI4_S2M               : T_AXI4_S2M;

  signal DAQ_OUT_PORT           : T_DAQ_O_ARRAY(2 downto 0);
  signal DAQ_IN_PORT            : T_DAQ_I_ARRAY(2 downto 0);
    
  signal slave_addr         : std_logic_vector(G_AXI_ADDR_WIDTH-1 downto 0) := (others => '0');
  signal slave_data         : std_logic_vector(G_AXI_DATA_WIDTH-1 downto 0) := (others => '0');
  signal slave_wlast        : std_logic;

  --Outputs
  signal po_buf_pulse_number   : std_logic_vector(31 downto 0) := (others => '0'); --! Pulse number for inactive buffer
  signal po_buff_in_use        : std_logic;                                        --! Shows which buffer is currently written by DAQ
  signal po_data               : std_logic_vector(G_AXI_DATA_WIDTH-1 downto 0);
  signal po_data_str           : std_logic;
  signal po_addr               : std_logic_vector(G_AXI_ADDR_WIDTH-1 downto 0);
  signal po_addr_str           : std_logic;
  signal po_wlast              : std_logic;

  signal po_buf_start          : std_logic;
  signal po_buf_done           : std_logic;

  --signal po_data_1             : std_logic_vector(G_INPUT_DATA_WIDTH-1 downto 0) := (others => '0');
  --signal po_data_2             : std_logic_vector(G_INPUT_DATA_WIDTH-1 downto 0) := (others => '0');

  signal po_axi4_m2s_m         : T_AXI4_M2S;
  signal po_debug              : std_logic_vector(63 downto 0);

  -- Simulation related signals
  signal data     : std_logic_vector(G_INPUT_DATA_WIDTH-1 downto 0)  := (others => '0');
  signal data_counter : std_logic_vector(255 downto 0)  := (others => '0');

  type  state is (NARROWBAND, WIDEBAND, EQUALBAND);
  signal transmission_type : state := EQUALBAND;

BEGIN

  -- Instantiate the Unit Under Test (UUT)
  uut_burst_gen:  entity work.burst_generator
  generic map(
    G_AXI_DATA_WIDTH    => G_AXI_DATA_WIDTH,
    G_AXI_ADDR_WIDTH    => G_AXI_ADDR_WIDTH,
    G_AXI_BURST_LEN     => G_AXI_BURST_LEN,
    G_INPUT_DATA_WIDTH  => G_INPUT_DATA_WIDTH,
    G_MODE_IS_CONTINUOUS=> G_MODE_IS_CONTINUOUS,
    --G_START_ADDR_0      => G_START_ADDR_0,
    --G_START_ADDR_1      => G_START_ADDR_1
    G_BUF1_OFFSET       => G_BUF1_OFFSET
  )
  PORT MAP (
  pi_clk               => pi_clk,
  pi_reset             => pi_reset,
  pi_data              => pi_data,
  pi_start_addr_0      => pi_start_addr_0,
  pi_trg               => pi_trg,
  pi_str               => pi_str,
  pi_samples           => pi_samples,
  pi_daq_enable        => pi_daq_enable,
  pi_dub_buf_ena       => pi_dub_buf_ena,
  pi_pulse_number      => pi_pulse_number,      --! Pulse number for active buffer
  pi_fifo_status       => pi_fifo_status,    --! FIFO Full Flag coming from Interfacor
  po_buf_pulse_number  => po_buf_pulse_number,  --! Pulse number for inactive buffer/buffer that server reads
  po_buff_in_use       => po_buff_in_use,       --! Shows which buffer is currently written by DAQ
  po_data              => po_data,
  po_data_str          => po_data_str,
  po_addr              => po_addr,
  po_addr_str          => po_addr_str,
  po_wlast             => po_wlast,
  po_buf_start         => po_buf_start,
  po_buf_done          => po_buf_done
  );

  uut2_daq_to_axi : entity work.daq_to_axi
  generic map(
    G_ARCH_TYPE           => G_ARCH_TYPE,
    G_AXI_ID              => "0000",
    G_AXI_DATA_WIDTH      => G_AXI_DATA_WIDTH,                         --! Width of the Data Bus (bits) (effects Burst Size)
    G_AXI_ADDR_WIDTH      => G_AXI_ADDR_WIDTH,                          --! Width of the Address Bus (bits)
    G_AXI_BURST_LEN       => G_AXI_BURST_LEN,  --! # of beats on each burst
    G_FIFO_DEPTH          => G_FIFO_DEPTH  --! Make sure FIFO can hold 2 bursts at a time
                                                          -- Needs to be divisable by G_AXI_BURST_LEN
  )
  port map (
    pi_clk       => pi_clk,
    pi_reset     => pi_reset,
    pi_data      => po_data,
    pi_data_str  => po_data_str,
    pi_addr      => po_addr,
    pi_addr_str  => po_addr_str,
    pi_last      => po_wlast,         --! Last data of the burst flag
    -- AXI4 Master port
    po_axi4_m2s_m      => AXI4_M2S,
    pi_axi4_s2m_m      => AXI4_S2M,
    po_fifo_status     => pi_fifo_status
  );

  uut3_axi2daq : entity work.axi2daq
  generic map(
    G_DAQ_CHANNELS => 1
  )
  port map(

    pi_clock => pi_clk,
    pi_reset => pi_reset,
    --Output
    pi_daq(0)   => DAQ_OUT_PORT(0),
    po_daq(0)   => DAQ_IN_PORT(0),
              --Input
    po_t_axi4(0) => AXI4_S2M,
    pi_t_axi4(0) => AXI4_M2S
  );


  --! Determine the type of transmission
  transmission_type: process
  begin
    wait for pi_clk_period/2;
    if C_PACKETS_IN_BEAT = 1 then
      transmission_type <= EQUALBAND;
    elsif C_PACKETS_IN_BEAT > 1 then
      transmission_type <= NARROWBAND;
    else
      transmission_type <= WIDEBAND;
    end if;
  end process;

  -- Clock process definitions
  pi_clk_process :process
  begin
    pi_clk <= '0';
    wait for pi_clk_period/2;
    pi_clk <= '1';
    wait for pi_clk_period/2;
  end process;

    -- Clock process definitions
  pi_aclk_process :process
  begin
    pi_aclk <= '0';
    wait for pi_aclk_period/2;
    pi_aclk <= '1';
    wait for pi_aclk_period/2;
  end process;

  -- Strobe and DAQ_TRG generation and data assignment
  strobe_process :process(pi_clk, pi_reset)
  variable v_counter_str : natural := 0;
  variable v_counter_trg : natural := 0;
  begin
    if pi_reset = '1' then
      pi_str <= '0';
      pi_trg <= '0';
      v_counter_str := 0;
      v_counter_trg := 0;
      pi_pulse_number <= (others=>'0');
    elsif rising_edge (pi_clk) then
      if v_counter_str = C_STR_FREQ_DIV-1 then
        pi_str   <= '1';
        v_counter_str := 0;
        --pi_data <= (others=> '1');
        pi_data <= data ;
      else
        pi_str <= '0';
        v_counter_str := v_counter_str + 1;
      end if;

      if v_counter_trg = C_TRG_FREQ_DIV*C_STR_FREQ_DIV-1 then
        pi_trg <= '1';
        v_counter_trg := 0;
        pi_pulse_number <= std_logic_vector(unsigned(pi_pulse_number) + 1);
      else
        pi_trg <= '0';
        v_counter_trg:= v_counter_trg + 1;
      end if;
    end if;
  end process;

  -- Data generation (counter going upwards)
  data_process :process(pi_clk, pi_reset)
  begin
   if pi_reset = '1' then
     data <= (others => '0');
     data_counter <= (others => '0');
   elsif rising_edge (pi_clk) then -- and pi_str = '1' then
--     data(257) <= '1';
--     data(0) <= '1';
       data_counter <= std_logic_vector(unsigned(data_counter) + 1);
       --data(255 downto 0) <= data_counter;
       --data(511 downto 256) <= data_counter;
       --data(511 downto 256) <= std_logic_vector(unsigned(data_counter)+1);
       --data(767 downto 512) <= std_logic_vector(unsigned(data_counter)+2);
       --data(1023 downto 768) <= std_logic_vector(unsigned(data_counter)+3);
       data <= data_counter(data'range);
   end if;
  end process;


  stim_main_story: process
  begin
    pi_reset     <= '1';
    pi_areset_n  <= '0';
    report "Hard reseted all" severity note;
    wait for 10*pi_clk_period;
    pi_reset     <= '0';
    pi_areset_n  <= '1';
    report "deasserted all resets" severity note;
    wait for 100*pi_clk_period;
    wait until rising_edge(pi_clk);
    pi_daq_enable  <= '1';
    pi_samples     <= std_logic_vector(to_unsigned(C_NUM_SAMPLES,32));
    DAQ_OUT_PORT(0).BUSY <= '0';
    report "Enabled DAQ Module and set # of samples to send" severity note;
    wait for 100 us;
    wait for 500 ps;
    pi_daq_enable  <= '0';
    DAQ_OUT_PORT(0).BUSY <= '1';
    wait for 10 us;
    --file_close(file_OUT);
    wait for C_SIMULATION_TIME;
    report "Simulation Ended" severity note;
    wait;
  end process;

END;