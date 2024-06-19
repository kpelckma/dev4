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
--! @date 2021-12-21
--! @author Cagil Gumus  <cagil.guemues@desy.de>
------------------------------------------------------------------------------
--! @brief
--! Default BSP Configuration File for SIS8300KU AMC
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

package pkg_bsp_config is
  
  constant C_FIRMWARE : std_logic_vector(31 downto 0) := X"008D0001" ;

  -----------------------------------------------------------------------------
  --! clock parameters
  constant C_APP_FREQ           : natural := 125000000; -- external frequency in Hz - sets proper setting for MMCM
  constant C_APP_FREQ_MAX_DIFF  : natural := 2000000;   -- maximal allowed difference in external clock freq
  
  --! ADC
  constant C_ADC_USE_FIFO   : natural := 0 ; -- '0'-no FIFO implementation; '1'- FIFO implementation
  -----------------------------------------------------------------------------
  --! DAC
  constant C_DAC_MODE       : std_logic := '1' ; -- mode of data: '0'-binary offset; '1'-2 complement
  -----------------------------------------------------------------------------

  -- IRQ 
  constant C_PCIE_IRQ_CNT : natural := 16;
  
  --! RTM
  constant C_RTM_INTERLOCK_NEGATE : natural := 0;  -- interlock polarity when != 0 then interlock signals from applications are negated
                                                   -- if the interlock logic on the AMC side is NAND => C_RTM_INTERLOCK_NEGATE should be 0
                                                   -- if the interlock logic on the AMC side is NOR => C_RTM_INTERLOCK_NEGATE should be 1
                                                   -- Note that this is mostly used on old L2 boards. On KU it should be always NAND.

end pkg_bsp_config;
