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
--! @date 2021-10-03
--! @author Cagil Gumus  <cagil.guemues@desy.de>
--! @author Michael Buechler  <michael.buechler.desy.de>
------------------------------------------------------------------------------
--! @brief
--! Example application
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_misc.all;
use ieee.numeric_std.all;

library unisim;
use unisim.vcomponents.all;

library desy;
use desy.common_types.all;
use desy.common_bsp_ifs.all;
use desy.common_bsp_ifs_cfg.all;
use desy.common_axi.all;

-- address space
library desyrdl;
use desyrdl.common.all;
use desyrdl.pkg_app.all;
use desyrdl.pkg_rtm.all;

use work.pkg_app_config.all;
use work.pkg_bsp_config.all;
-- use work.psi_fix_pkg.all;
-- use work.psi_common_math_pkg.all;

entity app_top is
  port(
    pi_clock : in std_logic_vector(7 downto 0); -- Application clocks and its integer multiples
    pi_reset : in std_logic_vector(7 downto 0); -- Resets synced to Application clocks and its integer multiples

    pi_bsp_clock : in std_logic_vector(7 downto 0); -- BSP clocks
    pi_bsp_reset : in std_logic_vector(7 downto 0); -- Resets that are synced to BSP clocks

    -- AXI4 Lite
    po_s_axi4l_reg : out t_app_s2m;
    pi_s_axi4l_reg : in  t_app_m2s;
    pi_s_axi4l_reg_aclk     : in std_logic;
    pi_s_axi4l_reg_areset_n : in std_logic;

    -- DAQ AXI4 interface
    pi_m_axi4_daq_aclk     : in  std_logic;
    pi_m_axi4_daq_areset_n : in  std_logic;
    pi_m_axi4_daq          : in  t_axi4_s2m;
    po_m_axi4_daq          : out t_axi4_m2s;

    -- ADC Signals
    pi_adc    : in t_16b_slv_vector(9 downto 0);
    pi_adc_ov : in std_logic_vector(9 downto 0);

    -- DAC
    po_dac_data_i : out std_logic_vector(15 downto 0);
    po_dac_data_q : out std_logic_vector(15 downto 0);
    po_dac_data_rdy : out std_logic;

    -- Interrupt
    po_irq_req : out std_logic_vector(C_PCIE_IRQ_CNT-1 downto 0); -- Request (Sync to App clock Domain)

    -- RJ45 on FP SIS8300ku
    pi_rj45 : in std_logic_vector(2 to 0);
    po_rj45 : out std_logic_vector(2 to 0);

    -- LED signals
    po_led_data   : out std_logic_vector(15 downto 0);

    -- Timing Application Interface port
    pi_mlvds    : in  std_logic_vector(7 downto 0) := (others => '0');
    po_mlvds    : out std_logic_vector(7 downto 0) := (others => '0');
    po_mlvds_oe : out std_logic_vector(7 downto 0) := (others => '0');

    pio_top_io_p : inout std_logic_vector(11 downto 0);
    pio_top_io_n : inout std_logic_vector(11 downto 0)
  );
end app_top;

architecture rtl of app_top is

  -- Global signals
  signal clock   : std_logic:='0';
  signal clock2x : std_logic:='0';
  signal reset   : std_logic:='0';

  -- register interface
  signal addrmap_i : t_addrmap_app_in;
  signal addrmap_o : t_addrmap_app_out;

  -- RTM related
  signal ext_interlock : std_logic;

  -- MLVDS port related
  signal mlvds_in_val : std_logic_vector(7 downto 0);

  -- Timing related
  signal trg_daq :       std_logic; -- Main Trigger for the DAQ module and DPM pointer start flag
  signal dac_table_str : std_logic; -- Strobe for DAC Table DPM memory pointer
  signal idx           : unsigned(31 downto 0) := X"00000000";
  signal l_pulse_pos   : unsigned(9 downto 0) := "0000000000";
  signal l_mem_val_i   : std_logic_vector(15 downto 0);
  signal l_mem_val_q   : std_logic_vector(15 downto 0);
  signal l_pulse_number: std_logic_vector(31 downto 0) := X"00000000";
  
  signal trg_pulse_start : std_logic := '0';
  signal trg_pulse_stop : std_logic := '0';    
      
  -- Application related signals
  signal irq_ack_cnt : t_32b_slv_vector(C_PCIE_IRQ_CNT-1 downto 0); -- Counter for PCIe IRQ ACK
  
  -- Controller related signals ---------------------------------------------------------
  signal internal_control   : t_16b_slv_vector(7 downto 0)  := (others => (others=>'0'));
  signal reference_control  : t_16b_slv_vector(1 downto 0)  := (others => (others=>'0'));
  signal drive_control      : t_16b_slv_vector(1 downto 0)  := (others => (others=>'0'));
  
  -- Interrupt
  signal trg_irq : std_logic;
  
  --count RJ45 triggers
  type t_cnt16 is array (integer range <>) of std_logic_vector(15 downto 0);
  signal cnt_rj45 : t_cnt16(2 downto 0) := (X"0002", X"0001", X"0000");
  signal cnt_events : t_cnt16(9 downto 0) := (others => (others => '0'));
  
begin

  -- ==========================================================================
  -- Clock Selection
  -- ==========================================================================
  clock   <= pi_clock(0);
  clock2x <= pi_clock(1);
  reset   <= pi_reset(0);
  
  -- ==========================================================================
  -- Interrupt Distribution
  -- ==========================================================================
  po_irq_req(0) <= trg_irq;  

  -- ==========================================================================
  -- Register Component
  -- ==========================================================================
  blk_desyrdl : block
  begin
    ins_registers : entity desyrdl.app
    port map (
      pi_clock    => pi_s_axi4l_reg_aclk,
      pi_reset    => '0', -- Must be synced to pi_s_axi4l_reg_aclk
      pi_s_top    => pi_s_axi4l_reg,
      po_s_top    => po_s_axi4l_reg,
      pi_addrmap  => addrmap_i,
      po_addrmap  => addrmap_o
    );

    addrmap_i.ID.data.data <= C_ID;
      
    gen_irq_ack_cnt: for i in 0 to C_PCIE_IRQ_CNT-1 generate
      addrmap_i.IRQ_ACK_CNT(i).data.data <= irq_ack_cnt(i);
     end generate;
     
    addrmap_i.MLVDS_I.data.data <= mlvds_in_val;

  end block;

   addrmap_i.SCRATCH(0).data.data(0) <= addrmap_o.FB_SWITCH.data.data(0); -- when rising_edge(clock);


  -- =============================
  -- count events on ADC channels
  -- =============================

   gen_events_cnt: for i in 0 to 9 generate
     addrmap_i.CNT_EVENTS(i).data.data <= cnt_events(i);
     process (pi_adc(i))
     begin
       if signed(pi_adc(i))>100 then
         cnt_events(i) <= std_logic_vector( signed(cnt_events(i)) + 1);
       end if;
     end process;
   end generate;




  -- ===========================
  -- count triggers on RJ45
  -- ========================

   gen_rj45_cnt: for i in 0 to 2 generate
     addrmap_i.CNT_RJ45(i).data.data <= cnt_rj45(i);
     process (pi_rj45(i))
     begin
       if rising_edge(pi_rj45(i)) then
         cnt_rj45(i) <= std_logic_vector( signed(cnt_rj45(i)) + 1);
       end if;
     end process;
   end generate;

   
    
  -- =====================================================================
  -- MIMO Controller
  -- =====================================================================
  blk_mimo: block
  
    signal active: std_logic := '0';
    signal ffd : t_16b_slv_vector(1 downto 0);
    signal K : t_16b_slv_vector(4*2-1 downto 0);

  begin
  
    -- read in FFD tables with a DPM
    ins_dpm_ffd_q : entity desy.dual_port_memory
      generic map (
        g_data_width => 16,
        g_addr_width => 10
      )
      port map (
        pi_clk_a  => clock,
        pi_ena_a  => addrmap_o.FFD_Q.en,
        pi_wr_a   => addrmap_o.FFD_Q.we,
        pi_addr_a => addrmap_o.FFD_Q.addr(9  downto 0),
        pi_data_a => addrmap_o.FFD_Q.data(15 downto 0),
        po_data_a => addrmap_i.FFD_Q.data(15 downto 0), 

        pi_clk_b  => clock,
        pi_ena_b  => '1',
        pi_wr_b   => '0',
        pi_addr_b => std_logic_vector(l_pulse_pos),
        pi_data_b => x"0000",
        po_data_b => ffd(1) 
      );
  ins_dpm_ffd_i : entity desy.dual_port_memory
      generic map (
        g_data_width => 16,
        g_addr_width => 10
      )
      port map (
        pi_clk_a  => clock,
        pi_ena_a  => addrmap_o.FFD_I.en,
        pi_wr_a   => addrmap_o.FFD_I.we,
        pi_addr_a => addrmap_o.FFD_I.addr(9  downto 0),
        pi_data_a => addrmap_o.FFD_I.data(15 downto 0),
        po_data_a => addrmap_i.FFD_I.data(15 downto 0), 

        pi_clk_b  => clock,
        pi_ena_b  => '1',
        pi_wr_b   => '0',
        pi_addr_b => std_logic_vector(l_pulse_pos),
        pi_data_b => x"0000",
        po_data_b => ffd(0) 
      );

    -- active switch, based on triggers
    ins_active: entity work.active
    generic map(
        G_len_active => 1024
      )
    port map(
      clock => clock,
      reset => reset,
      pi_pulse_start => trg_daq, 
      po_active => active
      );
  
  
    -- Simple FIR filter
    K <= ( X"0001", X"0001", X"0000", X"0000", X"0001", X"0001", X"0001", X"0000"); -- impulse response
      
    ins_mimo: entity work.mimo
      generic map(
        G_len_input     => 2,
        G_len_output    => 10,
        G_len_reference => 2,
        G_len_intern    => 8,
        G_order         => 4
      )
      port map(
        reset => reset,
        clock => clock,
        pi_base => pi_adc(7),
        pi_raw  => pi_adc(6),
        
        po_u    => drive_control,
        pi_r    => reference_control,
        pi_y    => pi_adc, 
        po_int    => internal_control,
        pi_ffd    => ffd,
        pi_active => active,
        pi_K => K, -- or (others => (others => '0')),
        pi_fb_switch => addrmap_o.FB_SWITCH.data.data(0)
      );
      
  end block;
  
  
  -- ==========================================================================
  -- RTM module
  -- ==========================================================================
  blk_rtm: block

    component rtm_ds8vm1_top is
      generic(
        G_CLK_FREQ : natural := 78_000_000); -- pi_clock frequency in Hz (used for I2C Clock divider setting)
      port(
        pi_clock : in std_logic;
        pi_reset : in std_logic;

        -- register interface
        pi_s_reg_reset : in std_logic;
        pi_s_reg : in  desyrdl.common.t_axi4l_m2s;
        po_s_reg : out desyrdl.common.t_axi4l_s2m;

        pi_interlock     : in std_logic;   -- interlock produced by application -> Will forward this to Zone3 pins
        po_ext_interlock : out std_logic;  -- external interlock monitoring coming from Zone3 Pin

        pio_rtm_io_p : inout std_logic_vector(11 downto 0); -- Zone3 Pins
        pio_rtm_io_n : inout std_logic_vector(11 downto 0)
      );
    end component;

    component rtm_dwc8vm1_top is
      generic (
        G_CLK_FREQ      : natural := 100_000_000;
        G_ADD_ILOCK_BUF : natural := 1
      );
      port (
        -- clock
        pi_clock : in std_logic;
        pi_reset : in std_logic;

        -- register interface
        pi_s_reg_reset : in std_logic;
        pi_s_reg : in  desyrdl.common.t_axi4l_m2s;
        po_s_reg : out desyrdl.common.t_axi4l_s2m;

        -- IO
        pi_interlock     : in std_logic;   -- interlock generated by application
        po_ext_interlock : out std_logic;  -- external interlock coming into rtm

        pio_rtm_io_p : inout std_logic_vector(11 downto 0);
        pio_rtm_io_n : inout std_logic_vector(11 downto 0)
      );
    end component;

  begin
    assert (C_RTM_TYPE = 0 ) or (C_RTM_TYPE = 1)
      report "RTM_DS8VM1 or RTM_DWC8VM1 should be selected for C_RTM_TYPE" severity failure;

    gen_dwc8vm1: if  C_RTM_TYPE = 1 generate

      ins_rtm_dwc8vm1_top: rtm_dwc8vm1_top
      generic map (
        G_CLK_FREQ => C_APP_FREQ
      )
      port map (
        pi_clock   => clock,
        pi_reset => reset,

        pi_interlock     => '0', -- Not used in this application
        po_ext_interlock => open, -- external interlock coming from rtm

        pi_s_reg_reset => '0',
        pi_s_reg => addrmap_o.rtm,
        po_s_reg=> addrmap_i.rtm,

        pio_rtm_io_p => pio_top_io_p,
        pio_rtm_io_n => pio_top_io_n
      );
    end generate gen_dwc8vm1;

    gen_ds8vm1: if C_RTM_TYPE = 0 generate
      ins_rtm_ds8vm1_top: rtm_ds8vm1_top
      generic map (
        G_CLK_FREQ => C_APP_FREQ
      )
      port map (
        pi_clock => clock,
        pi_reset => reset,

        pi_interlock     => '0',
        po_ext_interlock => open, -- external interlock coming from rtm

        -- register interface
        pi_s_reg_reset => '0',
        pi_s_reg => addrmap_o.rtm,
        po_s_reg => addrmap_i.rtm,

        pio_rtm_io_p => pio_top_io_p,
        pio_rtm_io_n => pio_top_io_n
      );
    end generate gen_ds8vm1;

  end block blk_rtm;


  -- ==========================================================================
  -- Trigger generation
  -- ==========================================================================
  blk_timing : block

    constant C_EXT_TRG_CNT : natural := 8;                          -- 8 trigger lanes coming into FPGA from MTCA Crate

    signal l_timing_out : std_logic_vector(C_TRG_CNT-1 downto 0);   -- Generated delayed triggers

    signal l_mlvds_q      : std_logic_vector(7 downto 0);           -- Need for 2xFF
    signal l_mlvds_qq     : std_logic_vector(7 downto 0);           -- Need for 2xFF

    signal l_adc_ov_latched : std_logic_vector(9 downto 0);

    attribute ASYNC_REG : string;
    attribute ASYNC_REG of l_mlvds_q : signal is "true";
    attribute ASYNC_REG of l_mlvds_qq: signal is "true";
  begin

    -- Synchronizing MLVDS Input signal to Application Clock domain
    process(clock)
    begin
      if rising_edge(clock) then
        l_mlvds_q  <= pi_mlvds;
        l_mlvds_qq <= l_mlvds_q;
      end if;
    end process;

    -- Latching the ADC Over Range event with the DAQ Trigger by streching until DAQ Trigger
    -- This makes sure registers 'see' the event of Over-Range
    process (clock)
    begin
      if rising_edge(clock) then
        if reset = '1' or trg_daq = '1' then
          l_adc_ov_latched <= ( others => '0' );
        else
          for i in 0 to 9 loop
            if pi_adc_ov(i) = '1' then
              if l_adc_ov_latched(i) = '0' then -- catching only the first ov event after DAQ trigger
                l_adc_ov_latched(i) <= '1';
              end if;
            end if;
          end loop;
        end if;
      end if;
    end process;

    g_ov_latch : for i in 0 to 9 generate
      addrmap_i.ADC_OV_LATCHED(i).data.data(0) <= l_adc_ov_latched(i);
    end generate;

    -- to/from registers
    addrmap_i.MLVDS_I.data.data <= l_mlvds_qq;
    po_mlvds_oe <= addrmap_o.MLVDS_OE.data.data when rising_edge(clock);
    po_mlvds    <= addrmap_o.MLVDS_O.data.data  when rising_edge(clock);

    -- Timing module
    ins_timing : entity work.timing_top
    generic map(
      G_EXT_TRG => C_EXT_TRG_CNT,  -- Total number of external triggers
      G_OUT_TRG => C_TRG_CNT       -- Total number of output trigger channels
    )
    port map(
      pi_clock    => clock,        -- Clock input
      pi_reset    => reset,        -- Global reset port
      pi_s_reg_reset => '0',
      pi_s_reg_if => addrmap_o.timing,
      po_s_reg_if => addrmap_i.timing,
      pi_ext_trg  => l_mlvds_qq,   -- Synchronized External trigger Input TODO
      po_trg      => l_timing_out  -- Trigger Channel 0 -> Main LLRF Trigger, X2timer
    );

    trg_daq       <= l_timing_out(0); -- Trigger Channel 0 -> DAQ Trigger
    dac_table_str <= l_timing_out(1); -- Trigger Channel 1 -> DAC Table DPM Memory Strobe
    trg_irq       <= l_timing_out(2); -- Trigger Channel 2 -> PCIe IRQ REQ

    process (clock)
    begin
      if rising_edge(clock) then
        if reset = '1' then
          l_pulse_number <= ( others => '0' );
        elsif trg_daq ='1' then
          l_pulse_number <= std_logic_vector(unsigned(l_pulse_number) + 1);
        end if;
      end if;
    end process;

  end block blk_timing;


  -- ==========================================================================
  -- DAC
  -- ==========================================================================
  blk_dac : block
    signal l_dpm_out_vld : std_logic;
  begin  


   ins_dpm_dac_i : entity desy.dual_port_memory
      generic map (
        g_data_width => 16,
        g_addr_width => 10
      )
      port map (
        pi_clk_a  => clock,
        pi_ena_a  => addrmap_o.REF_I.en,
        pi_wr_a   => addrmap_o.REF_I.we,
        pi_addr_a => addrmap_o.REF_I.addr(9  downto 0),
        pi_data_a => addrmap_o.REF_I.data(15 downto 0),
        po_data_a => addrmap_i.REF_I.data(15 downto 0),

        pi_clk_b  => clock,
        pi_ena_b  => '1',
        pi_wr_b   => '0',
        pi_addr_b => std_logic_vector(l_pulse_pos),
        pi_data_b => x"0000",
        po_data_b => reference_control(0) -- l_mem_val_i
      );

   ins_dpm_dac_q : entity desy.dual_port_memory
      generic map (
        g_data_width => 16,
        g_addr_width => 10
      )
      port map (
        pi_clk_a  => clock,
        pi_ena_a  => addrmap_o.REF_Q.en,
        pi_wr_a   => addrmap_o.REF_Q.we,
        pi_addr_a => addrmap_o.REF_Q.addr(9  downto 0),
        pi_data_a => addrmap_o.REF_Q.data(15 downto 0),
        po_data_a => addrmap_i.REF_Q.data(15 downto 0),

        pi_clk_b  => clock,
        pi_ena_b  => '1',
        pi_wr_b   => '0',
        pi_addr_b => std_logic_vector(l_pulse_pos),
        pi_data_b => x"0000",
        po_data_b => reference_control(1) -- l_mem_val_q
      );

    -- Giving the output of the control drive to the DAC/VM
    -- po_dac_data_i   <= l_mem_val_i; --   when rising_edge(clock); -- addrmap_o.VM_LEVEL.data.data when rising_edge(clock); -- and unsigned(test_data)<3000 else X"0000" when rising_edge(clock); -- l_mem_val(0) when rising_edge(clock);
    -- po_dac_data_q   <= l_mem_val_q; --    when rising_edge(clock);
    -- po_dac_data_rdy <= l_dpm_out_vld; -- when rising_edge(clock);
    po_dac_data_i <= drive_control(0);
    po_dac_data_q <= drive_control(1);
    po_dac_data_rdy <= '1';

   -- DPM Memory Pointer Counter
    process(clock)
    begin
      if rising_edge(clock) then
        if reset = '1' then
          idx     <= (others => '0');
          l_dpm_out_vld <= '0';
        else
          l_dpm_out_vld <= '1';
          if trg_daq = '1'  then -- Reset the table position when DAQ gets triggered
            idx   <= (others => '0');
          elsif dac_table_str = '1' then -- Table memory pointer counts with dac_table_str
            idx   <= idx + 1;
          end if;
          if idx < 1023 then
            l_pulse_pos <= idx( 9 downto 0);
          end if;
        end if;
      end if;
    end process;


  end block blk_dac;


  -- ==========================================================================
  -- DAQ data acquisition modules and assignment
  -- ==========================================================================
  blk_daq : block

      -- Determines the size of the vector. Equivalent to the number of channels
      constant C_DATA_VEC_LENGTH : natural := 12;
      constant C_DATA_ADC_LENGTH : natural := 5;

      signal l_daq_data      : t_32b_slv_vector(C_DATA_VEC_LENGTH-1 downto 0);
      signal l_daq_data_q    : t_32b_slv_vector(C_DATA_VEC_LENGTH-1 downto 0);

    begin
      -- put RAW ADC Signals on DAQ channels 0...7
      gen_daq_raw : for i in 0 to 3 generate
        l_daq_data(i) <= pi_adc(2*i+1) & pi_adc(2*i); -- RAW ADC signals of 10 channels
      end generate;


      -- !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
      -- Put the controller signals on the DAQ
      -- !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
      l_daq_data(4) <= internal_control(1) & internal_control(0);
      l_daq_data(5) <= internal_control(3) & internal_control(2);
      l_daq_data(6) <= internal_control(5) & internal_control(4);
      l_daq_data(7) <= internal_control(7) & internal_control(6);



      -- Register stage for DAQ data
      prs_daq_data: process(clock)
      begin
        if rising_edge(clock) then
          if reset = '1' then
            l_daq_data_q <= (others => (others => '0'));
          else
            l_daq_data_q <= l_daq_data;
          end if;
        end if;
      end process;

      ---------------------------------------------------------------------------
      -- DAQ module instance
      ---------------------------------------------------------------------------
      inst_daq_top : entity work.daq_top
      generic map (
        G_FIFO_ARCH                => "ULTRASCALE",
        G_INPUT_DATA_CHANNEL_COUNT => C_DATA_VEC_LENGTH,
        G_ADD_INPUT_BUF            => 1,
        G_CHANNEL_WIDTH            => 32
      )
      port map (
        pi_clock   => clock,           --! Clock input (also used to create strobes for each DAQ region)
        pi_reset   => reset,           --! Global reset port
        pi_ext_str => (others => '0'), --! External Strobing Input (Not needed)
        pi_trg     => (others => trg_daq),

        pi_data         => l_daq_data_q,    --! 2D Input Data vector from Application
        pi_pulse_number => X"44445555", -- l_pulse_number, -- X"44444444", -- (others => '0'),

        -- DesyRDL Interface
        pi_s_reg_reset => '0',
        pi_s_reg_if => addrmap_o.DAQ,
        po_s_reg_if => addrmap_i.DAQ,

        -- AXI4 Full Interface
        pi_m_axi4          => pi_m_axi4_daq,       -- Comes from DDR
        pi_m_axi4_aclk     => pi_m_axi4_daq_aclk,
        pi_m_axi4_areset_n => pi_m_axi4_daq_areset_n,

        po_m_axi4          => po_m_axi4_daq       -- Goes to DDR
      );

    end block;



end architecture rtl;
