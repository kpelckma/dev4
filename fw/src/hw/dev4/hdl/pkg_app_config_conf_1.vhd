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
-- @date 2022-01-04
-- @author Cagil Gumus  <cagil.guemues@desy.de>
------------------------------------------------------------------------------
-- @brief
-- Example application configuration
------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;

library desy;
use desy.common_numarray.all;

package pkg_app_config is

  constant C_ID : std_logic_vector(31 downto 0) := X"00000001" ;

  -- RTM Selection
  -- Use 0 for DS8VM1
  -- Use 1 for DWC8VM1
  constant C_RTM_TYPE : natural := 0; 

  -- Timing Parameters (Needed for Address Space adjustment)
  
  constant C_TRG_CNT : natural := 3; -- Determines the number of trigger channels generated

  -- Trigger Channel 0 -> DAQ Trigger
  -- Trigger Channel 1 -> DAC Table DPM Memory Strobe
  -- Trigger Channel 2 -> PCIe IRQ REQ

  -----------------------------------------------------------------------------
  -- DAQ Channel Descriptions -- 
  --  0 -> ADC Ch1 & ADC Ch0 (RAW)
  --  1 -> ADC Ch3 & ADC Ch2 (RAW)
  --  2 -> ADC Ch5 & ADC Ch4 (RAW)
  --  3 -> ADC Ch7 & ADC Ch6 (RAW)
  --  4 -> ADC Ch9 & ADC Ch8 (RAW) -DC Channels on SIS8300L2
  --  5 -> 16 bit Counter counting +1 each app clock edge

  -- DAQ Settings
  constant C_DAQ_REGIONS            : natural := 1;
  constant C_CHANNEL_WIDTH_BYTES    : natural := 4; -- How many bytes does 1 channel contain (applies for all daq regions)

  constant C_DAQ0_IS_CONTINUOUS     : natural := 0;
  constant C_DAQ0_MAX_SAMPLES       : natural := 16384; -- Determines the Memory region
  constant C_DAQ0_MAX_TRIGGERS      : natural := 510;   -- For timestamps in continuous mode
  constant C_DAQ0_CHANNELS_IN_TAB   : natural := 8;     -- Max 16 channels are allowed in Tab for now
  constant C_DAQ0_TAB_COUNT         : natural := 1;
  constant C_DAQ0_TAB_CONTENTS      : t_natural_vector(C_DAQ0_TAB_COUNT*C_DAQ0_CHANNELS_IN_TAB-1 downto 0)
                                      := (5, 5, 5, 4, 3, 2, 1, 0);

  -- Although DAQ regions 1 and 2 are unused, their related constants are
  -- still necessary to set up other constants in ENT_DAQ_TOP.
  constant C_DAQ1_IS_CONTINUOUS     : natural := 0;
  constant C_DAQ1_MAX_SAMPLES       : natural := 16384; -- Determines the Memory region
  constant C_DAQ1_MAX_TRIGGERS      : natural := 510;   -- for timestamps in continuous mode
  constant C_DAQ1_CHANNELS_IN_TAB   : natural := 8;
  constant C_DAQ1_TAB_COUNT         : natural := 1;
  constant C_DAQ1_TAB_CONTENTS      : t_natural_vector(C_DAQ1_TAB_COUNT*C_DAQ1_CHANNELS_IN_TAB-1 downto 0)
                                      := (0,0,0,0,0,0,0,0);
  -- DAQ2 Region is reserved for QlDet and Piezo related signals for the future.
  constant C_DAQ2_IS_CONTINUOUS     : natural := 0;
  constant C_DAQ2_MAX_SAMPLES       : natural := 16384; -- Determines the Memory region
  constant C_DAQ2_MAX_TRIGGERS      : natural := 510;   -- for timestamps in continuous mode
  constant C_DAQ2_CHANNELS_IN_TAB   : natural := 8;
  constant C_DAQ2_TAB_COUNT         : natural := 1;
  constant C_DAQ2_TAB_CONTENTS      : t_natural_vector(C_DAQ2_TAB_COUNT*C_DAQ2_CHANNELS_IN_TAB-1 downto 0)
                                      := (0,0,0,0,0,0,0,0);

  -- DDR AXI.4 Bus has starting address of 0x100_0000 = 16777216
  constant C_DAQ0_BUF0_OFFSET : natural := 0;
  constant C_DAQ0_BUF1_OFFSET : natural := 1048576;
  constant C_DAQ1_BUF0_OFFSET : natural := 4194304;
  constant C_DAQ1_BUF1_OFFSET : natural := 5242880;
  constant C_DAQ2_BUF0_OFFSET : natural := 2097152; -- Not Used
  constant C_DAQ2_BUF1_OFFSET : natural := 3145728; -- Not Used
  -----------------------------------------------------------------------------

  -- AXI Parameters
  -- AXI Burst length (How many beats inside 1 burst)      (DAQ2, DAQ1, DAQ0);
  constant C_DAQ_BURST_LEN_ARRAY : t_natural_vector(C_DAQ_REGIONS-1 downto 0):= (0 => 64); -- was: 32,128,128
  -- AXI FIFO depths for data channel (address fifo depth is fixed to 64) (DAQ2, DAQ1, DAQ0);
  constant C_DAQ_FIFO_DEPTH_ARRAY : t_natural_vector(C_DAQ_REGIONS-1 downto 0):= (0 => 512); -- was: 128,512,1024

end pkg_app_config ;
