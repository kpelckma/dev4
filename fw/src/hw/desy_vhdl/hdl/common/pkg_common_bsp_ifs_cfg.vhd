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
--! @author
--! Lukasz Butkowski <lukasz.butkowski@desy.de>
--! Cagil Gumus <cagil.guemues@desy.de>
--! Burak Dursun <burak.dursun@desy.de>
------------------------------------------------------------------------------
--! @brief
--! package with the configuration constants for bsp interfaces
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

package common_bsp_ifs_cfg is

  constant C_AXI4_REG_ID_WIDTH     : natural := 4;
  constant C_AXI4_REG_ADDR_WIDTH   : natural := 64;
  constant C_AXI4_REG_DATA_WIDTH   : natural := 1024;
  constant C_AXI4_REG_ARUSER_WIDTH : natural := 1;
  constant C_AXI4_REG_AWUSER_WIDTH : natural := 1;
  constant C_AXI4_REG_RUSER_WIDTH  : natural := 1;
  constant C_AXI4_REG_WUSER_WIDTH  : natural := 1;
  constant C_AXI4_REG_BUSER_WIDTH  : natural := 0;

  constant C_AXI4L_REG_ADDR_WIDTH  : natural := 32;
  constant C_AXI4L_REG_DATA_WIDTH  : natural := 32;

  constant C_AXI4_DAQ_ID_WIDTH     : natural := 4;
  constant C_AXI4_DAQ_ADDR_WIDTH   : natural := 32;
  constant C_AXI4_DAQ_DATA_WIDTH   : natural := 1024;
  constant C_AXI4_DAQ_ARUSER_WIDTH : natural := 1;
  constant C_AXI4_DAQ_AWUSER_WIDTH : natural := 1;
  constant C_AXI4_DAQ_RUSER_WIDTH  : natural := 1;
  constant C_AXI4_DAQ_WUSER_WIDTH  : natural := 1;
  constant C_AXI4_DAQ_BUSER_WIDTH  : natural := 0;

  constant C_AXI4_PSHP_ID_WIDTH     : natural := 4;
  constant C_AXI4_PSHP_ADDR_WIDTH   : natural := 64;
  constant C_AXI4_PSHP_DATA_WIDTH   : natural := 1024;
  constant C_AXI4_PSHP_ARUSER_WIDTH : natural := 1;
  constant C_AXI4_PSHP_AWUSER_WIDTH : natural := 1;
  constant C_AXI4_PSHP_RUSER_WIDTH  : natural := 1;
  constant C_AXI4_PSHP_WUSER_WIDTH  : natural := 1;
  constant C_AXI4_PSHP_BUSER_WIDTH  : natural := 0;

  constant C_AXI4_PSHPM_ID_WIDTH     : natural := 4;
  constant C_AXI4_PSHPM_ADDR_WIDTH   : natural := 64;
  constant C_AXI4_PSHPM_DATA_WIDTH   : natural := 1024;
  constant C_AXI4_PSHPM_ARUSER_WIDTH : natural := 1;
  constant C_AXI4_PSHPM_AWUSER_WIDTH : natural := 1;
  constant C_AXI4_PSHPM_RUSER_WIDTH  : natural := 1;
  constant C_AXI4_PSHPM_WUSER_WIDTH  : natural := 1;
  constant C_AXI4_PSHPM_BUSER_WIDTH  : natural := 0;

  constant C_AXI4S_P2P_ID_WIDTH   : natural := 8;
  constant C_AXI4S_P2P_DATA_WIDTH : natural := 128;
  constant C_AXI4S_P2P_DEST_WIDTH : natural := 4;
  constant C_AXI4S_P2P_USER_WIDTH : natural := 128;

  constant C_AXI4_C2C_ID_WIDTH      : natural := 0;
  constant C_AXI4_C2C_ADDR_WIDTH    : natural := 32;
  constant C_AXI4_C2C_DATA_WIDTH    : natural := 32;
  constant C_AXI4_C2C_ARUSER_WIDTH  : natural := 0;
  constant C_AXI4_C2C_AWUSER_WIDTH  : natural := 0;
  constant C_AXI4_C2C_RUSER_WIDTH   : natural := 0;
  constant C_AXI4_C2C_WUSER_WIDTH   : natural := 0;
  constant C_AXI4_C2C_BUSER_WIDTH   : natural := 0;

end package common_bsp_ifs_cfg;

