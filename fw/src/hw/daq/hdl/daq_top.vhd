------------------------------------------------------------------------------
--          ____  _____________  __                                         --
--         / __ \/ ____/ ___/\ \/ /                 _   _   _               --
--        / / / / __/  \__ \  \  /                 / \ / \ / \              --
--       / /_/ / /___ ___/ /  / /               = ( M | S | K )=            --
--      /_____/_____//____/  /_/                   \_/ \_/ \_/              --
--                                                                          --
------------------------------------------------------------------------------
-- @copyright Copyright 2021 DESY
-- SPDX-License-Identifier: CERN-OHL-W-2.0
------------------------------------------------------------------------------
-- @date 2021-09-14
-- @author Cagil Gumus  <cagil.guemues@desy.de>
-- @author Michael Buechler  <michael.buechler@desy.de>
------------------------------------------------------------------------------
-- @brief
-- Data Acquisition Model:
-- Samples signals from the application, creates AXI.4 Full Bursts + Handles CDC
------------------------------------------------------------------------------

library ieee;
library desy;
library desyrdl;

use desyrdl.pkg_DAQ.all;

use ieee.std_logic_1164.ALL;
use ieee.numeric_std.all;
use ieee.math_real.all;

use work.pkg_app_config.all;

use desy.common_types.all;
use desy.common_axi.all;
use desy.common_numarray.all;

entity daq_top is
  generic (
    G_FIFO_ARCH                : string  := "GENERIC";  -- select FIFO architecture that should be used in buffers
    G_FIFO_FWFT                : natural := 1;          -- DAQ to AXI FIFOs First Word Fall Through
    G_INPUT_DATA_CHANNEL_COUNT : natural := 55;         -- Total number of channels on input data
    G_CHANNEL_WIDTH            : natural := 32;         -- Each channel is 32 bits long
    G_ADD_INPUT_BUF            : natural := 1;          -- Add buffers after DAQ_TO_AXI to relax the timing
    G_AXI_DATA_WIDTH           : natural := 256;        -- Width of the axi data
    G_EXT_STR_ENA              : std_logic_vector(C_DAQ_REGIONS-1 downto 0) := (others => '0')
  );
  port(
    pi_clock           : in  std_logic; -- Clock input (also can be used to create strobes for each DAQ region)
    pi_reset           : in  std_logic; -- Global reset port

    pi_trg             : in  std_logic_vector(C_DAQ_REGIONS-1 downto 0);  -- DAQ Trigger Input for each DAQ region
    pi_ext_str         : in  std_logic_vector(C_DAQ_REGIONS-1 downto 0) := (others=>'0');
    pi_transaction_end : in  std_logic_vector(C_DAQ_REGIONS-1 downto 0) := (others=>'0');  -- User initiated transaction end

    -- Register access bus
    pi_s_reg_reset  : in  std_logic;
    pi_s_reg_if     : in  t_daq_m2s;
    po_s_reg_if     : out t_daq_s2m;

    -- axi4 full
    pi_m_axi4_aclk     : in  std_logic;
    pi_m_axi4_areset_n : in  std_logic;
    pi_m_axi4          : in  t_axi4_s2m;
    po_m_axi4          : out t_AXI4_M2S;

    -- DAQ data port
    pi_data            : in  t_32b_slv_vector(G_INPUT_DATA_CHANNEL_COUNT-1 downto 0);  -- 2D Input Data vector from Application
    pi_pulse_number    : in  std_logic_vector(31 downto 0) -- Pulse number for each data set
  );
end daq_top;

architecture Behavioral of daq_top is

  -- DAQ Configuration shows on ID register
  signal C_DAQ_CONF : std_logic_vector(31 downto 0);

  -- DAQ Related Constants being grouped into arrays for looping through them easily
  constant C_COMBINED_TAB_SIZE      : t_natural_vector(2 downto 0)                  := (C_DAQ2_TAB_CONTENTS'length, C_DAQ1_TAB_CONTENTS'length, C_DAQ0_TAB_CONTENTS'length);
  constant C_INDEXER                : t_natural_vector(2 downto 0)                  := (C_DAQ1_TAB_CONTENTS'length + C_DAQ0_TAB_CONTENTS'length, C_DAQ0_TAB_CONTENTS'length, 0);
  constant C_TAB_SIZE_SUM           : natural                                       := (C_DAQ2_TAB_CONTENTS'length + C_DAQ1_TAB_CONTENTS'length + C_DAQ0_TAB_CONTENTS'length);
  constant C_COMBINED_TAB_CONTENTS  : t_natural_vector(C_TAB_SIZE_SUM-1 downto 0)   := (C_DAQ2_TAB_CONTENTS & C_DAQ1_TAB_CONTENTS & C_DAQ0_TAB_CONTENTS);
  constant C_TAB_COUNT_ARRAY        : t_natural_vector(2 downto 0)                  := (C_DAQ2_TAB_COUNT, C_DAQ1_TAB_COUNT, C_DAQ0_TAB_COUNT);
  constant C_CHANNELS_IN_TAB_ARRAY  : t_natural_vector(2 downto 0)                  := (C_DAQ2_CHANNELS_IN_TAB, C_DAQ1_CHANNELS_IN_TAB, C_DAQ0_CHANNELS_IN_TAB);
  constant C_DAQ_BUF_0_OFFSET_ARRAY : t_natural_vector(2 downto 0)                  := (C_DAQ2_BUF0_OFFSET, C_DAQ1_BUF0_OFFSET, C_DAQ0_BUF0_OFFSET);
  constant C_DAQ_IS_CONTINUOUS      : t_natural_vector(2 downto 0)                  := (C_DAQ2_IS_CONTINUOUS, C_DAQ1_IS_CONTINUOUS, C_DAQ0_IS_CONTINUOUS);
  --constant C_DAQ_MAX_TRIGGERS       : t_natural_vector(2 downto 0)                  := (C_DAQ2_MAX_TRIGGERS, C_DAQ1_MAX_TRIGGERS, C_DAQ0_MAX_TRIGGERS);
  constant C_DAQ_BUF_1_OFFSET_ARRAY : t_natural_vector(2 downto 0)                  := (C_DAQ2_BUF1_OFFSET, C_DAQ1_BUF1_OFFSET, C_DAQ0_BUF1_OFFSET);

  -- DesyRDL related signals---------------------------------------------------------
  signal addrmap_i : t_addrmap_daq_in;
  signal addrmap_o : t_addrmap_daq_out;


  -- General DAQ Signals--------------------------------------------------------------
  signal reset          : std_logic;                                  -- Deassertion synced reset from DDR
  signal areset_v       : std_logic_vector(2 downto 0);               -- Reset synchronizer
  signal daq_str_cnt    : t_32b_slv_vector(C_DAQ_REGIONS-1 downto 0); -- Strobe counter for each DAQ region
  signal daq_start      : std_logic_vector(C_DAQ_REGIONS-1 downto 0); -- Start Trigger propagation between MUX and Burst Generator
  signal daq_mux_str    : std_logic_vector(C_DAQ_REGIONS-1 downto 0); -- Local DAQ strobe propagating from DAQ MUX to Burst Generator
  signal w_status       : t_32b_slv_vector(C_DAQ_REGIONS-1 downto 0); -- Data FIFO Almost Full Counter (Gives info about Bandwidth)
  signal sent_burst_cnt : t_32b_slv_vector(C_DAQ_REGIONS-1 downto 0); -- Address FIFO Full Counter (Gives info about Bandwidth)
  signal buff_in_use    : std_logic_vector(C_DAQ_REGIONS-1 downto 0);
  signal buf_start      : std_logic_vector(C_DAQ_REGIONS-1 downto 0);
  signal daq_enable     : std_logic_vector(C_DAQ_REGIONS-1 downto 0); -- Enable/Disable individual DAQ regions
  signal samples        : t_32b_slv_vector(C_DAQ_REGIONS-1 downto 0); -- Determines how many samples will be send for each DAQ region
  signal daq_str_div    : t_32b_slv_vector(C_DAQ_REGIONS-1 downto 0); -- Divider value for strobes on each DAQ region
  signal daq_str        : std_logic_vector(C_DAQ_REGIONS-1 downto 0); -- Main Strobe clock propagation between MUX and Burst Generator
  signal daq_tab_sel    : t_32b_slv_vector(C_DAQ_REGIONS-1 downto 0);  -- User can only have max of 64 tabs
  signal trg_delay_val  : t_32b_slv_vector(C_DAQ_REGIONS-1 downto 0); -- Trigger Delay value for each region
  signal trg_delay_ena  : std_logic_vector(C_DAQ_REGIONS-1 downto 0);  -- Enable delaying trigger for each daq region
  signal dbuf_ena       : std_logic_vector(C_DAQ_REGIONS-1 downto 0);
  signal daq_buff_pulse_num : t_32b_slv_vector(C_DAQ_REGIONS-1 downto 0);

  -- Timestamp related signals ------------------------------------------
  signal trg_cnt_buf0 : t_16b_slv_vector(2 downto 0); -- trigger index within buffer
  signal trg_cnt_buf1 : t_16b_slv_vector(2 downto 0); -- trigger index within buffer
  signal timestmp_mem_data : t_32b_slv_vector(2 downto 0);

  -- AXI.4 signals-------------------------------------------------
  signal r_axi_daq_port_m2s        : t_axi4_m2s_vector(C_DAQ_REGIONS-1 downto 0) := (others => C_AXI4_M2S_DEFAULT);
  signal r_axi_daq_port_s2m        : t_axi4_s2m_vector(C_DAQ_REGIONS-1 downto 0);
  signal axi_daq_port_m2s_aclk     : std_logic_vector(C_DAQ_REGIONS-1 downto 0);
  signal axi_daq_port_m2s_areset_n : std_logic_vector(C_DAQ_REGIONS-1 downto 0);

  attribute ASYNC_REG : string ;
  attribute ASYNC_REG of areset_v : signal is "TRUE";

begin

  --========================--
  -- Synchronizing deassertion of Async reset from AXI.4 Bus
  -- to the DAQ clock
  --========================--
  process(pi_clock,pi_m_axi4_areset_n)
  begin
    if pi_m_axi4_areset_n = '0' then
      areset_v <= (others =>'1');  -- Switching to Active High Reset
    elsif rising_edge(pi_clock) then
      areset_v <= areset_v(1 downto 0) & '0';
    end if;
  end process;
  -- Main Reset source is from DDRs only
  -- Application should NOT reset DAQ module. Since it might disturb ongoing transaction
  reset <= areset_v(areset_v'left);

  --========================--
  -- DesyRDL Instance
  -- (Register Access)
  --========================--
  ins_daq_desyrdl : entity desyrdl.daq
  port map (
    pi_clock     => pi_clock,
    pi_reset     => pi_s_reg_reset,
    pi_s_top     => pi_s_reg_if,
    po_s_top     => po_s_reg_if,
    pi_addrmap   => addrmap_i,
    po_addrmap   => addrmap_o
  );

  -- DAQ Configuration exposed through ID register
  with G_FIFO_ARCH(G_FIFO_ARCH'right-2 to G_FIFO_ARCH'right) select C_DAQ_CONF(3 downto 0) <=
    "0000" when "RIC", --"GENERIC",
    "0001" when "EX5", --"VIRTEX5",
    "0010" when "EX6", --"VIRTEX6",
    "0011" when "IES", --"7SERIES",
    "0100" when "XPM",
    "0101" when "ALE", --"ULTRASCALE",
    "0000" when others;

  C_DAQ_CONF(4 downto 4) <= std_logic_vector(to_unsigned(G_FIFO_FWFT,1));
  C_DAQ_CONF(9 downto 5) <= std_logic_vector(to_unsigned(C_DAQ_REGIONS, 5));

  addrmap_i.ID.data.data         <= C_DAQ_CONF;
  addrmap_i.DAQ_TIMES_0.data <= timestmp_mem_data(0);
  addrmap_i.DAQ_TIMES_1.data <= timestmp_mem_data(1);
  addrmap_i.DAQ_TIMES_2.data <= timestmp_mem_data(2);

  daq_enable    <= addrmap_o.ENABLE.data.data;
  dbuf_ena      <= addrmap_o.DOUBLE_BUF_ENA.data.data;
  trg_delay_ena <= addrmap_o.TRG_DELAY_ENA.data.data;

  -- Registers that scale with number of DAQ Regions
  gen_reg: for i in 0 to C_DAQ_REGIONS-1 generate
    addrmap_i.INACTIVE_BUF_ID(i).data.data <= daq_buff_pulse_num(i);
    addrmap_i.ACTIVE_BUF.data.data         <= buff_in_use;
    addrmap_i.STROBE_CNT(i).data.data      <= daq_str_cnt(i);
    addrmap_i.FIFO_STATUS(i).data.data     <= w_status(i);
    addrmap_i.SENT_BURST_CNT(i).data.data  <= sent_burst_cnt(i);
    addrmap_i.TRG_CNT_BUF0(i).data.data    <= trg_cnt_buf0(i);
    addrmap_i.TRG_CNT_BUF1(i).data.data    <= trg_cnt_buf1(i);

    daq_tab_sel(i)   <= addrmap_o.TAB_SEL(i).data.data;
    daq_str_div(i)   <= addrmap_o.STROBE_DIV(i).data.data;
    trg_delay_val(i) <= addrmap_o.TRG_DELAY_VAL(i).data.data;
    samples(i)       <= addrmap_o.SAMPLES(i).data.data when rising_edge(pi_clock); -- Relax timing

  end generate;

  -- ===========================================================================
  -- AXI interface
  -- ===========================================================================
  BLK_DAQ_TO_AXI : block
    type tl_mux_daq_data is array (natural range<>) of std_logic_vector(G_INPUT_DATA_CHANNEL_COUNT*G_CHANNEL_WIDTH-1 downto 0);

    signal l_input_data      : std_logic_vector(G_INPUT_DATA_CHANNEL_COUNT*G_CHANNEL_WIDTH-1 downto 0);
    signal l_strobe_reset    : std_logic_vector(C_DAQ_REGIONS-1 downto 0);
    signal l_daq_enable      : std_logic_vector(C_DAQ_REGIONS-1 downto 0);
    signal l_daq_trg         : std_logic_vector(C_DAQ_REGIONS-1 downto 0);
    signal l_trg_delayed     : std_logic_vector(C_DAQ_REGIONS-1 downto 0);
    signal l_transaction_end : std_logic_vector(C_DAQ_REGIONS-1 downto 0);

    signal l_data     : t_512b_slv_vector(C_DAQ_REGIONS-1 downto 0); -- Output Data from the Burst Generator WARNING! This is currently fixed to 512 bits. Can we make this dynamic??
    signal l_data_str : std_logic_vector(C_DAQ_REGIONS-1 downto 0); -- Output Data strobe from Burst generator
    signal l_addr     : t_32b_slv_vector(C_DAQ_REGIONS-1 downto 0); -- Output Address from the Burst Generator
    signal l_addr_str : std_logic_vector(C_DAQ_REGIONS-1 downto 0); -- Output Address Strobe from the Burst Generator
    signal l_wlast    : std_logic_vector(C_DAQ_REGIONS-1 downto 0); -- Last of the burst indicator for Interfacor
    signal l_int_daq_str    : std_logic_vector(C_DAQ_REGIONS-1 downto 0); -- Internally generated strobe output pi_clk

    signal l_fifo_status    : std_logic_vector(C_DAQ_REGIONS-1 downto 0); -- FIFO status from Interfacor (used in Burst Generator)
    signal l_daq_muxed_data : tl_mux_daq_data(C_DAQ_REGIONS-1 downto 0); -- Output of the MUX goes into Burst generator (Will be trimmed heavily)

  begin

    GEN_DAQ_MUX_BURST : for I in 0 to C_DAQ_REGIONS-1 generate  -- Loops on all regions

      l_input_data <= f_32b_slv_vector_to_slv(pi_data);

      ins_trg_dly : entity desy.trigger_delay
      generic map (
        G_COUNT_DELAYED_TRG => 1        -- Because we are looping through each region
      )
      port map (
        pi_clock               => pi_clock,
        pi_main_trigger       => pi_trg(I),
        pi_delay_val(0)       => trg_delay_val(I),
        po_delayed_trigger(0) => l_trg_delayed(I)
      );

      l_daq_trg(I) <= l_trg_delayed(I) when trg_delay_ena(I) = '1' else pi_trg(I);

      GEN_STROBE_RESET_CONT : if C_DAQ_IS_CONTINUOUS(I) = 1 generate
        l_strobe_reset(I) <= pi_reset;
      end generate;
      GEN_STROBE_RESET_PULSED : if C_DAQ_IS_CONTINUOUS(I) = 0 generate
        l_strobe_reset(I) <= pi_trg(I);
      end generate;

      -- Regions can be strobed either from outside or can be derived using pi_clock
      ins_strobe_divider : entity desy.trigger_divider
      generic map(
        G_CHANNELS => 1)
      port map(
        pi_clock              => pi_clock,
        pi_reset              => l_strobe_reset(I),
        pi_ext_rst            => (others => '0'),
        pi_ext_trigger_ena(0) => G_EXT_STR_ENA(I),
        pi_ext_trigger(0)     => pi_ext_str(I),   -- Used only for counting not for diving ext str
        pi_div(0)             => daq_str_div(I),
        po_trigger_cnt(0)     => daq_str_cnt(I),
        po_trigger(0)         => l_int_daq_str(I) -- Goes into MUX and later propagates with daq_mux_str
      );

      daq_str(I) <= l_int_daq_str(I) when G_EXT_STR_ENA(I) = '0' else pi_ext_str(I);

      ins_daq_mux : entity work.daq_mux
      generic map (
        G_CHANNEL_WIDTH     => 8*C_CHANNEL_WIDTH_BYTES,  -- This is fixed.(THIS MUST BE MULTIPLES OF 8)
        G_IN_CHANNEL_COUNT  => G_INPUT_DATA_CHANNEL_COUNT,
        G_OUT_CHANNEL_COUNT => C_CHANNELS_IN_TAB_ARRAY(I),
        G_TAB_COUNT         => C_TAB_COUNT_ARRAY(I),
        G_SEL_SIZE          => 32
      )
      port map (
        pi_clock       => pi_clock,
        pi_channel_tab => C_COMBINED_TAB_CONTENTS(C_INDEXER(I)+C_COMBINED_TAB_SIZE(I)-1 downto C_INDEXER(I)),
        pi_sel         => daq_tab_sel(I),
        pi_data        => l_input_data,
        po_data        => l_daq_muxed_data(I)(C_CHANNELS_IN_TAB_ARRAY(I)*32-1 downto 0),
        pi_daq_enable  => daq_enable(I),
        pi_daq_trg     => l_daq_trg(I),
        pi_daq_dry     => daq_str(I),
        pi_transaction_end => pi_transaction_end(I), -- user transaction reset
        po_daq_enable  => l_daq_enable(I),           -- Enable flag needs to be propagated from MUX
        po_daq_trg     => daq_start(I),              -- Start flag for burst generator (DAQ Trigger)
        po_daq_dry     => daq_mux_str(I),
        po_transaction_end => l_transaction_end(I)
      );

      ins_burst_generator : entity work.burst_generator
      generic map(
        G_AXI_DATA_WIDTH     => G_AXI_DATA_WIDTH,
        G_AXI_ADDR_WIDTH     => 32,
        G_AXI_BURST_LEN      => C_DAQ_BURST_LEN_ARRAY(I),
        G_INPUT_DATA_WIDTH   => C_CHANNELS_IN_TAB_ARRAY(I)*32,
        G_MODE_IS_CONTINUOUS => C_DAQ_IS_CONTINUOUS(I),
        G_BUF_SIZE           => C_CHANNEL_WIDTH_BYTES * C_DAQ0_MAX_SAMPLES * C_DAQ0_CHANNELS_IN_TAB -- must be in bytes1
      )
      port map(
        pi_clock            => pi_clock, -- DAQ Clock
        pi_reset            => reset, -- Synchronized Reset (Active High)
        pi_data             => l_daq_muxed_data(I)(C_CHANNELS_IN_TAB_ARRAY(I)*32-1 downto 0),  -- Multiplex data from daq_mux
        pi_buf0_addr        => C_DAQ_BUF_0_OFFSET_ARRAY(I),  -- Buffer 0 starting address
        pi_buf1_addr        => C_DAQ_BUF_1_OFFSET_ARRAY(I),  -- Buffer 1 starting address
        pi_trg              => daq_start(I), -- DAQ Trigger Input ( It should make the address go to base)
        pi_str              => daq_mux_str(I), -- Strobe Input coming from MUX
        pi_samples          => samples(I), -- Length of each DAQ Channel
        pi_transaction_end  => l_transaction_end(I),  -- User transaction reset
        pi_daq_enable       => l_daq_enable(I), -- 1 => Enable 0 => Disable
        pi_dub_buf_ena      => dbuf_ena(I), -- 1 => Double Buffering is enabled
        pi_pulse_number     => pi_pulse_number, -- Pulse number for active buffer
        pi_fifo_status      => l_fifo_status(I), -- Interfacor tells burst generator to stop if FIFOs are full
        po_buf_pulse_number => daq_buff_pulse_num(I),  -- Pulse number for inactive buffer
        po_buff_in_use      => buff_in_use(I), -- Shows which buffer is currently written by DAQ
        po_buf_start        => buf_start(I), -- Indicates start of writing to a buffer
        po_data             => l_data(I)(G_AXI_DATA_WIDTH-1 downto 0), -- Data to Interfacor
        po_data_str         => l_data_str(I), -- Data Strobe to Interfacor
        po_addr             => l_addr(I), -- Address to Interfacor
        po_addr_str         => l_addr_str(I), -- Address Strobe to Interfacor
        po_wlast            => l_wlast(I) -- Last of Burst indication for Interfacor
      );

      ins_daq_to_axi : entity work.daq_to_axi
      generic map (
        G_ARCH_TYPE      => G_FIFO_ARCH,
        G_AXI_ID         => "0000",
        G_AXI_DATA_WIDTH => G_AXI_DATA_WIDTH, -- Width of the Data Bus (bits) (effects Burst Size)
        G_AXI_ADDR_WIDTH => 32, -- Width of the Address Bus (bits)
        G_AXI_BURST_LEN  => C_DAQ_BURST_LEN_ARRAY(I), -- # of beats on each burst
        G_FIFO_DEPTH     => C_DAQ_FIFO_DEPTH_ARRAY(I), -- Make sure FIFO can hold 2 bursts at a time
        G_FIFO_FWFT      => G_FIFO_FWFT
      )
      port map (
        pi_clock      => pi_clock,
        pi_reset      => reset,
        pi_data       => l_data(I)(G_AXI_DATA_WIDTH-1 downto 0),
        pi_data_str   => l_data_str(I),
        pi_addr       => l_addr(I),
        pi_addr_str   => l_addr_str(I),
        pi_last       => l_wlast(I), -- Last data of the burst flag

        -- manager interface
        pi_m_axi4_aclk     => pi_m_axi4_aclk,
        pi_m_axi4_areset_n => pi_m_axi4_areset_n,
        pi_m_axi4          => r_axi_daq_port_s2m(I),  --AXI4 Subordinate port Inputs (From DDR)
        po_m_axi4          => r_axi_daq_port_m2s(I), -- AXI4 Manager port Outputs

        -- status
        po_fifo_status    => l_fifo_status(I),
        po_sent_burst_cnt => sent_burst_cnt(I),
        po_w_fifo_status  => w_status(I)
      );
    end generate;
  end block;

  -- If user selects 1 DAQ region we dont need interconnect
  gen_no_interconnect: if C_DAQ_REGIONS = 1 generate
    po_m_axi4             <= r_axi_daq_port_m2s(0);
    r_axi_daq_port_s2m(0) <= pi_m_axi4;
  end generate;

  gen_interconnect: if C_DAQ_REGIONS > 1 generate
    -- Interconnect to provide DDR memory access from different AXI channels
    ins_axi4_mux : entity desy.axi4_mux
    generic map(
      G_DATA_WIDTH        => G_AXI_DATA_WIDTH,
      G_S_PORT_NUM        => C_DAQ_REGIONS,
      G_S_PORT_ID_WIDTH   => 0,
      G_M_PORT_ADD_BUF    => G_ADD_INPUT_BUF
    )
    port map(
      pi_areset_n => pi_m_axi4_areset_n,
      pi_aclk     => pi_m_axi4_aclk,

      -- Subordinate Ports (Comes from daq_to_axi)
      pi_s_axi4(C_DAQ_REGIONS-1 downto 0) => r_axi_daq_port_m2s,
      po_s_axi4(C_DAQ_REGIONS-1 downto 0) => r_axi_daq_port_s2m,

      -- Manager AXI 4 Port (goes to DDR)
      pi_m_axi4          => pi_m_axi4,
      po_m_axi4          => po_m_axi4,
      po_m_axi4_aclk     => open,
      po_m_axi4_areset_n => open
    );
  end generate;


  -- ===========================================================================
  -- trigger timestamps handling
  -- ===========================================================================
  BLK_DAQ_TIMESTAMPS : block

    signal l_start_time : t_64b_slv_vector(2 downto 0);  -- To IBUS: timestamp at first sample in a buffer
    signal l_start_rdy  : std_logic_vector(2 downto 0);
    signal l_trg_rdy    : std_logic_vector(2 downto 0);
    signal l_trg_buf    : std_logic_vector(2 downto 0);
    signal l_trg_time   : t_32b_slv_vector(2 downto 0);  -- single timestamp offset, accompanied by trg_time

    signal l_times_wr   : std_logic_vector(2 downto 0);
    signal l_times_rd   : std_logic_vector(2 downto 0);
    signal l_times_ena  : std_logic_vector(2 downto 0);
    signal l_times_data : t_32b_slv_vector(2 downto 0);

    signal l_timestamp_rst : std_logic_vector(2 downto 0);  -- Allows CPU to reset the timestamp module

    signal l_mem_wen    : std_logic_vector(2 downto 0);
    signal l_mem_rdata  : t_32b_slv_vector(2 downto 0);
    signal l_mem_wdata  : t_32b_slv_vector(2 downto 0);
    signal l_times_addr : t_32b_slv_vector(2 downto 0);
    signal l_mem_pos    : t_10b_slv_vector(2 downto 0);
  begin

    gen_daq_timestamp_regions : for i in 0 to C_DAQ_REGIONS-1 generate  -- Loops on all regions

      gen_daq_timestamps : if C_DAQ_IS_CONTINUOUS(i) = 1 generate

        -- Make sure the configured maximum number of triggers per buffer
        -- doesn't exceed the maximum given by the address space. (TODO)
        -- assert

        -- Put Read Data to external memory and fetch the timestamp reset
        prs_timestamps_ii : process(pi_clock)
        begin
          if rising_edge(pi_clock) then
            if reset = '1' then
              timestmp_mem_data(i) <= (others => '0');
              l_timestamp_rst(i) <= '1';
            else
              timestmp_mem_data(i) <= l_mem_rdata(I);
              l_timestamp_rst(i) <= addrmap_o.TIMESTAMP_RST.data.data(i);
            end if;
          end if;
        end process;

        -- Generate timestamps for buffer_start and trigger events,
        -- in parallel to ins_burst_generator
        ins_timestamps : entity work.daq_timestamps
        generic map (
          G_TIMESTAMP_WIDTH => 64)
        port map (
          pi_clock     => pi_clock,
          pi_reset     => l_timestamp_rst(I),
          pi_data_str  => daq_mux_str(I),
          pi_buf_start => buf_start(I),
          pi_buf_num   => buff_in_use(I),
          pi_trg       => daq_start(I),

          po_start_time   => l_start_time(I),
          po_start_rdy    => l_start_rdy(I),
          po_trigger_time => l_trg_time(I),
          po_trigger_rdy  => l_trg_rdy(I),
          po_buf_num      => l_trg_buf(I)
        );

        -- catch output of daq_timestamps and put it to defined regions of a
        -- memory
        ins_timestamps_to_mem : entity work.daq_timestamps_to_mem
        generic map (
          G_TIMESTAMP_WIDTH => 64,
          G_TRG_CNT_MAX     => 510,
          G_ADDR_WIDTH      => 10
        )
        port map (
          pi_clock => pi_clock,
          pi_reset => reset,

          pi_buf_start => buf_start(I),

          pi_start_time   => l_start_time(I),
          pi_start_rdy    => l_start_rdy(I),
          pi_trigger_time => l_trg_time(I),
          pi_trigger_rdy  => l_trg_rdy(I),
          pi_buf_in_use   => l_trg_buf(I),

          po_en           => l_mem_wen(I),
          po_data         => l_mem_wdata(I),
          po_addr         => l_mem_pos(I),
          po_trg_cnt_buf0 => trg_cnt_buf0(I),
          po_trg_cnt_buf1 => trg_cnt_buf1(I)
        );

        l_times_ena(0) <= addrmap_o.DAQ_TIMES_0.en;
        l_times_ena(1) <= addrmap_o.DAQ_TIMES_1.en;
        l_times_ena(2) <= addrmap_o.DAQ_TIMES_2.en;

        l_times_wr(0) <= addrmap_o.DAQ_TIMES_0.we;
        l_times_wr(1) <= addrmap_o.DAQ_TIMES_1.we;
        l_times_wr(2) <= addrmap_o.DAQ_TIMES_2.we;

        l_times_rd(0) <= '1' when addrmap_o.DAQ_TIMES_0.we = '0' and l_times_ena(0) = '1' else '0';
        l_times_rd(1) <= '1' when addrmap_o.DAQ_TIMES_1.we = '0' and l_times_ena(1) = '1' else '0';
        l_times_rd(2) <= '1' when addrmap_o.DAQ_TIMES_2.we = '0' and l_times_ena(2) = '1' else '0';

        l_times_addr(0)(9 downto 0) <= addrmap_o.DAQ_TIMES_0.addr(11 downto 2); -- Cut LSB 2 bits for Word Addressing
        l_times_addr(1)(9 downto 0) <= addrmap_o.DAQ_TIMES_1.addr(11 downto 2);
        l_times_addr(2)(9 downto 0) <= addrmap_o.DAQ_TIMES_2.addr(11 downto 2);

        l_times_data(0) <= addrmap_o.DAQ_TIMES_0.data;
        l_times_data(1) <= addrmap_o.DAQ_TIMES_1.data;
        l_times_data(2) <= addrmap_o.DAQ_TIMES_2.data;

        -- Port A is accessed from DesyRDL through DAQ_TIMES
        -- Port B is written to by the DAQ timestamp component
        ins_timestamp_ram : entity desy.dual_port_memory
        generic map(
          G_DATA_WIDTH => 32,
          -- External memory (DAQ_TIMES_x) length is fixed to 1024 addresses,
          -- so this should stay at 10.
          G_ADDR_WIDTH => 10
        )
        port map (
          pi_clk_a  => pi_clock,
          pi_ena_a  => l_times_ena(i),
          pi_wr_a   => l_times_wr(i),
          pi_addr_a => l_times_addr(i)(9 downto 0),
          pi_data_a => l_times_data(i),
          po_data_a => l_mem_rdata(i),

          pi_clk_b  => pi_clock,
          pi_ena_b  => '1',
          pi_wr_b   => l_mem_wen(i),
          pi_addr_b => l_mem_pos(i),
          pi_data_b => l_mem_wdata(i),
          po_data_b => open
        );

      end generate GEN_DAQ_TIMESTAMPS;
    end generate GEN_DAQ_TIMESTAMP_REGIONS;
  end block BLK_DAQ_TIMESTAMPS;


end Behavioral;
