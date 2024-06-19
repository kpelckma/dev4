-------------------------------------------------------------------------------
--          ____  _____________  __                                          --
--         / __ \/ ____/ ___/\ \/ /                 _   _   _                --
--        / / / / __/  \__ \  \  /                 / \ / \ / \               --
--       / /_/ / /___ ___/ /  / /               = ( M | S | K )=             --
--      /_____/_____//____/  /_/                   \_/ \_/ \_/               --
--                                                                           --
-------------------------------------------------------------------------------
-- $Header: https://mskllrfredminesrv.desy.de/svn/utca_firmware_framework/trunk/modules/MISC/DAQ/tb/TB_ENT_DAQ_TO_AXI.vhd 3665 2020-03-24 18:42:21Z mbuechl $
-------------------------------------------------------------------------------
--! @file    TB_daq_to_axi.vhd
--! @brief   test bench of DAQ to AXI component in DAQ module daq_to_axi.vhd
--! @author  Lukasz Butkowski  <lukasz.butkowski@desy.de>
--! @author  Cagil Guemues <cagil.guemues@desy.de>
--! @company DESY
--! @created 2019-05-24
--! @changed $Date: 2020-03-24 19:42:21 +0100 (Di, 24 Mär 2020) $
--! $Revision: 3665 $
-------------------------------------------------------------------------------
-- Copyright (c) 2019 DESY
-------------------------------------------------------------------------------
-- Date        Version  Author  Description
-- 2019-05-24  0.1      lbutkows    Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_misc.all;

-- use work.math_basic.all;
use work.PKG_AXI.all;


ENTITY TB_daq_to_axi IS
END TB_daq_to_axi;

ARCHITECTURE behavior OF TB_daq_to_axi IS

  constant G_ARCH_TYPE      : string                       := "GENERIC";
  constant G_AXI_ID         : std_logic_vector(3 downto 0) := "0001";
  constant G_AXI_DATA_WIDTH : natural                      := 256;
  constant G_AXI_ADDR_WIDTH : natural                      := 32;
  constant G_AXI_BURST_LEN  : natural                      := 16;
  constant G_FIFO_DEPTH     : natural                      := 256;

  signal pi_areset_n       : std_logic                                     := '0';
  signal pi_aclk           : std_logic                                     := '0';

  signal pi_clk            : std_logic                                     := '0';
  signal pi_reset          : std_logic                                     := '0';
  signal pi_data           : std_logic_vector(G_AXI_DATA_WIDTH-1 downto 0) := (others => '0');
  signal pi_data_str       : std_logic                                     := '0';
  signal pi_addr           : std_logic_vector(G_AXI_ADDR_WIDTH-1 downto 0) := (others => '0');
  signal pi_addr_str       : std_logic                                     := '0';
  signal pi_last           : std_logic                                     := '0';
  signal pi_axi4_s2m_m     : T_AXI4_S2M                                    := C_AXI4_S2M_DEFAULT;
  signal po_axi4_m2s_m     : T_AXI4_M2S                                    := C_AXI4_M2S_DEFAULT;
  signal po_fifo_status    : std_logic;
  signal po_aw_fifo_status : std_logic_vector(31 downto 0)                 := (others => '0');
  signal po_w_fifo_status  : std_logic_vector(31 downto 0)                 := (others => '0');
  signal po_debug          : std_logic_vector(255 downto 0);

  signal addr_cnt           : std_logic_vector(G_AXI_DATA_WIDTH-1 downto 0) := (others => '0');
  signal data_cnt           : std_logic_vector(G_AXI_DATA_WIDTH-1 downto 0) := (others => '0');

  -- Clock period definitions
  constant pi_clk_period  : time := 20 ns;  -- 100 MHz
  constant pi_aclk_period : time := 10 ns;  -- 66 MHz

  -- Simulation related signal
  signal counter    : std_logic_vector(255 downto 0) := (others => '0');

  type state is (RESET, TRANSACTION_STARTED, TRANSACTION_DONE, IDLE);
  signal slave_state : state ;

BEGIN


  DUT: entity work.daq_to_axi
    generic map (
      G_ARCH_TYPE      => G_ARCH_TYPE,
      G_AXI_ID         => G_AXI_ID,
      G_AXI_DATA_WIDTH => G_AXI_DATA_WIDTH,
      G_AXI_ADDR_WIDTH => G_AXI_ADDR_WIDTH,
      G_AXI_BURST_LEN  => G_AXI_BURST_LEN,
      G_FIFO_DEPTH     => G_FIFO_DEPTH
    )
    port map (
      pi_clk            => pi_clk,
      pi_reset          => pi_reset,
      pi_data           => pi_data,
      pi_data_str       => pi_data_str,
      pi_addr           => pi_addr,
      pi_addr_str       => pi_addr_str,
      pi_last           => pi_last,
      pi_axi4_s2m_m     => pi_axi4_s2m_m,
      po_axi4_m2s_m     => po_axi4_m2s_m,
      po_fifo_status    => po_fifo_status,
      po_aw_fifo_status => po_aw_fifo_status,
      po_w_fifo_status  => po_w_fifo_status,
      po_debug          => po_debug
    );

  pi_axi4_s2m_m.ACLK <= pi_aclk;
  pi_axi4_s2m_m.ARESET_N <= pi_areset_n;

  -- Clock process definitions
  pi_clk_process :process
  begin
    pi_clk <= '0';
    wait for pi_clk_period/2;
    pi_clk <= '1';
    wait for pi_clk_period/2;
  end process;

  pi_aclk_process :process
  begin
    wait for pi_aclk_period/2;
    pi_aclk <= '0';
    wait for pi_aclk_period/2;
    pi_aclk <= '1';
  end process;

  -- Data and addresss generation process
  -- stim_data_gen : process
  -- begin
  --   wait until rising_edge(pi_clk);
  --   addr_cnt <= std_logic_vector(unsigned(addr_cnt) + 1);
  --   data_cnt <= std_logic_vector(unsigned(data_cnt) + 1);
  --   wait until rising_edge(pi_clk);
  -- end process;


  -- DATA Aligner Stimulus process
  stim_proc: process
  begin
    wait for 10*pi_aclk_period;
    wait until rising_edge(pi_clk);
    if (pi_reset or not pi_areset_n) = '1' then
      pi_data_str  <= '0';
      pi_data      <= (others => '0');
      pi_addr_str  <= '0';
      pi_addr      <= (others => '0');
    else
      pi_data_str  <= '1';
      pi_data      <= std_logic_vector(unsigned(pi_data) + 1);
      pi_addr_str  <= '1';
      pi_addr      <= std_logic_vector(unsigned(pi_addr) + 1);

      wait until rising_edge(pi_clk); -- Wait until next clock cycle
      pi_data_str  <= '0';
      pi_addr_str  <= '0';
    end if;


  end process;

  -- Slave response stimuli
  -- stim_slave_proc: process
  -- begin
  --   wait until rising_edge(pi_aclk);
  --   if (not pi_areset_n) = '1' then
  --     pi_axi4_s2m_m.AWREADY <= '0';
  --     slave_state <= RESET;
  --   else
  --     pi_axi4_s2m_m.AWREADY <= '1';

  --     if po_axi4_m2s_m.AWVALID = '1' then
  --       slave_state <= TRANSACTION_STARTED;
  --       pi_axi4_s2m_m.AWREADY <= '0';
  --       report "Handshake occoured" severity note;
  --       wait for 45 ns;     -- Taking address
  --       pi_axi4_s2m_m.AWREADY <= '1';
  --       slave_state <= TRANSACTION_DONE;
  --       report "Transaction done" severity note;
  --     else
  --       slave_state <= IDLE;
  --     end if;
  --   end if;

  -- end process;

  proc_slave: process
  begin
--    wait until pi_areset_n = '1';
--    wait for 10*pi_aclk_period;
--    wait until rising_edge(pi_aclk);

-- ready after valid
    wait until po_axi4_m2s_m.WVALID = '1';
    wait for 10*pi_aclk_period;
    wait until rising_edge(pi_aclk);
    pi_axi4_s2m_m.AWREADY <= '1';
    -- no ready when still valid
    wait for 10*pi_aclk_period;
    wait until rising_edge(pi_aclk);
    pi_axi4_s2m_m.WREADY <= '1';
    wait for 10*pi_aclk_period;
    wait until rising_edge(pi_aclk);
    pi_axi4_s2m_m.WREADY <= '0';
    -- ready for 1 clock cycle
    wait for 10*pi_aclk_period;
    wait until rising_edge(pi_aclk);
    pi_axi4_s2m_m.WREADY <= '1';
    wait until rising_edge(pi_aclk);
    pi_axi4_s2m_m.WREADY <= '0';
    wait for 10*pi_aclk_period;
    wait until rising_edge(pi_aclk);
    pi_axi4_s2m_m.WREADY <= '1';
    wait until po_axi4_m2s_m.WVALID = '0';

 -- ready before valid
    wait for 1*pi_aclk_period;
    wait until rising_edge(pi_aclk);
    pi_axi4_s2m_m.WREADY <= '1';
    wait until po_axi4_m2s_m.WVALID = '1';
    wait for 10*pi_aclk_period;
    wait until rising_edge(pi_aclk);
    pi_axi4_s2m_m.WREADY <= '0';
    wait for 10*pi_aclk_period;
    wait until rising_edge(pi_aclk);
    pi_axi4_s2m_m.WREADY <= '1';
    wait until rising_edge(pi_aclk);
    pi_axi4_s2m_m.WREADY <= '0';
    wait for 10*pi_aclk_period;
    wait until rising_edge(pi_aclk);
    pi_axi4_s2m_m.WREADY <= '1';
    wait until po_axi4_m2s_m.WVALID = '0';
    pi_axi4_s2m_m.WREADY <= '0';

-- ready in the same time as valid
    wait until po_axi4_m2s_m.WVALID = '1';
    pi_axi4_s2m_m.WREADY <= '1';
    wait;
  end process;


  stim_main_story: process
  begin

    pi_reset    <= '1';
    pi_areset_n <= '0';
    report "Hard reseted all" severity note;
    wait for 5*pi_aclk_period;
    pi_reset    <= '0';
    pi_areset_n <= '1';
    report "deasserted all resets" severity note;
    wait;
  end process;


END;
