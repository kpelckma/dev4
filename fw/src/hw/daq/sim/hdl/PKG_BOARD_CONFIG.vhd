-------------------------------------------------------------------------------
--          ____  _____________  __                                          --
--         / __ \/ ____/ ___/\ \/ /                 _   _   _                --
--        / / / / __/  \__ \  \  /                 / \ / \ / \               --
--       / /_/ / /___ ___/ /  / /               = ( M | S | K )=             --
--      /_____/_____//____/  /_/                   \_/ \_/ \_/               --
--                                                                           --
-------------------------------------------------------------------------------
-- $Header: https://mskllrfredminesrv.desy.de/svn/utca_firmware_framework/branch/DAQ_timestamps/boards/SIS8300KU/hdl/PKG_BOARD_CONFIG_NICA.vhd 3163 2019-07-18 11:36:24Z guemues $
-------------------------------------------------------------------------------
--! @file   PKG_BOARD_CONFIG_NICA.vhd
--! @brief  SIS8300KU board config file for NICA project
--! $Date: 2019-07-18 13:36:24 +0200 (Do, 18 Jul 2019) $
--! $Revision: 3163 $
--! $URL: https://mskllrfredminesrv.desy.de/svn/utca_firmware_framework/branch/DAQ_timestamps/boards/SIS8300KU/hdl/PKG_BOARD_CONFIG_NICA.vhd $
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.PKG_TYPES.all ;

package PKG_BOARD_CONFIG is
  constant C_FIRMWARE    : std_logic_vector(31 downto 0) := X"008D000B" ;
  -----------------------------------------------------------------------------
  --! clock parameters
  constant C_EXT_FREQ           : natural := 121875000;  -- external frequency in Hz - sets proper setting for MMCM
  constant C_EXT_FREQ_MAX_DIFF  : natural := 2000000;   -- maximal allowed difference in external clock freq

  -----------------------------------------------------------------------------
  --! LLL settings
    --! Low Latency Links on SIS8300KU 6x (6 downto 0)
    --! (0) PPT 12 (LLRF to slot 4)
    --! (1) PPT 13 (LLRF to slot 3)
    --! (2) PPT 14 (depended on slot)
    --! (3) PPT 15 (depended on slot)
    --! (4) SFP 0 (front top)
    --! (5) SFP 1 (front bottom)
  constant C_EXT_CLK_COUNT  : natural := 3;  -- number of external clocks to use by GTX
  constant C_LLL_ENA        : natural := 0;
  constant C_GTX_ENA        : std_logic_vector(11 downto 0) := x"03F" ; -- enable selected GTX
  constant C_GTX_CLK        : T_NaturalArray(2 downto 0)    := (0,0,0) ; -- which clock will be used by GTX, values: 0-2
  constant C_USR_CLK        : T_NaturalArray(2 downto 0)    := (0,0,0) ; -- which MMCM will be used to drive user clock, values: 0-2
  constant C_GTX_TXCLKOUT   : T_NaturalArray(2 downto 0)    := (0,0,1) ; -- whether the external clock will be used to drive MMCM, values: 0,1
  constant C_LLL_RATE       : T_NaturalArray(2 downto 0) := (3125,3125,3125) ; -- link reate : 3125, 3125, 3125
  constant C_DATA_BYTE      : T_NaturalArray(2 downto 0) := (2,2,2) ; -- data byte for link : 2, 4

  -----------------------------------------------------------------------------
  --! ADC
  constant C_ADC_USE_FIFO   : natural := 0 ; -- '0'-no FIFO implementation; '1'- FIFO implementation
  -----------------------------------------------------------------------------
  --! DAC
  constant C_DAC_MODE       : std_logic := '1' ; -- mode of data: '0'-binary offset; '1'-2 complement
  -----------------------------------------------------------------------------
  --! RTM
  constant C_RTM_INTERLOCK_NEGATE : natural := 0;  -- interlock polarity when != 0 then interlock signals from applications are negated

  --! DMA Parameter
  constant C_DAQ_DMA_BURST_LEN : natural := 32  ; --! Burst Length of DMA Transactions
  
end PKG_BOARD_CONFIG ;
