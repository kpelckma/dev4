library ieee;
use ieee.std_logic_1164.all;

use work.PKG_TYPES.all ;

package PKG_APP_CONFIG is

  --! DAQ Settings
  constant C_DAQ_REGIONS            : natural := 2;
  constant C_CHANNEL_WIDTH_BYTES    : natural := 4; --! How many bytes does 1 channel contain (applies for all daq regions)

  constant C_DAQ0_IS_CONTINUOUS     : natural := 0;
  constant C_DAQ0_MAX_SAMPLES       : natural := 16384; --! Determines the Memory region
  constant C_DAQ0_CHANNELS_IN_TAB   : natural := 8;     --! Max 16 channels are allowed in Tab for now
  constant C_DAQ0_TAB_COUNT         : natural := 1;
  constant C_DAQ0_TAB_CONTENTS      : T_NaturalArray(C_DAQ0_TAB_COUNT*C_DAQ0_CHANNELS_IN_TAB-1 downto 0) 
                                      := (7, 6, 5, 4, 3, 2, 1, 0);

  -- Although DAQ regions 1 and 2 are unused, their related constants are
  -- still necessary to set up other constants in daq_top.
  constant C_DAQ1_IS_CONTINUOUS     : natural := 0;
  constant C_DAQ1_MAX_SAMPLES       : natural := 16384; --! Determines the Memory region                                                                  
  constant C_DAQ1_CHANNELS_IN_TAB   : natural := 8;
  constant C_DAQ1_TAB_COUNT         : natural := 1;
  constant C_DAQ1_TAB_CONTENTS      : T_NaturalArray(C_DAQ1_TAB_COUNT*C_DAQ1_CHANNELS_IN_TAB-1 downto 0) 
                                      := (0,0,0,0,0,0,0,0);
  --! DAQ2 Region is reserved for QlDet and Piezo related signals for the future. 
  --constant C_DAQ2_MAX_SAMPLES       : natural := 16384; --! Determines the Memory region
  constant C_DAQ2_IS_CONTINUOUS     : natural := 0;
  constant C_DAQ2_CHANNELS_IN_TAB   : natural := 8;
  constant C_DAQ2_TAB_COUNT         : natural := 1;
  constant C_DAQ2_TAB_CONTENTS      : T_NaturalArray(C_DAQ2_TAB_COUNT*C_DAQ2_CHANNELS_IN_TAB-1 downto 0) 
                                      := (0,0,0,0,0,0,0,0);
                                      
  constant C_DAQ0_BUF0_OFFSET       : natural := 0;
  constant C_DAQ0_BUF1_OFFSET       : natural := 1048576;
  constant C_DAQ1_BUF0_OFFSET       : natural := 4194304;
  constant C_DAQ1_BUF1_OFFSET       : natural := 5242880;
  constant C_DAQ2_BUF0_OFFSET       : natural := 2097152;
  constant C_DAQ2_BUF1_OFFSET       : natural := 3145728;
  -----------------------------------------------------------------------------

  -- AXI Parameters
  -- AXI Burst length (How many beats inside 1 burst)      (DAQ2, DAQ1, DAQ0);
  constant C_DAQ_BURST_LEN_ARRAY : T_NaturalArray(C_DAQ_REGIONS-1 downto 0):= (0 => 16, 1 => 32); -- was: 32,128,128
  -- AXI FIFO depths for data channel (address fifo depth is fixed to 64) (DAQ2, DAQ1, DAQ0);
  constant C_DAQ_FIFO_DEPTH_ARRAY : T_NaturalArray(C_DAQ_REGIONS-1 downto 0):= (0 => 1536, 1 => 1536); -- was: 128,512,1024

end PKG_APP_CONFIG ;
