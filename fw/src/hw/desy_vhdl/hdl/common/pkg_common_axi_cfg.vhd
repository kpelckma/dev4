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
--! @author Lukasz Butkowski  <lukasz.butkowski@desy.de>
------------------------------------------------------------------------------
--! @brief
--! package with the configuration constants for common AXI interfaces
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

package common_axi_cfg is

  constant C_AXI4_ID_WIDTH     : natural := 4;
  constant C_AXI4_ADDR_WIDTH   : natural := 32;
  constant C_AXI4_DATA_WIDTH   : natural := 1024;
  constant C_AXI4_ARUSER_WIDTH : natural := 1;
  constant C_AXI4_AWUSER_WIDTH : natural := 1;
  constant C_AXI4_RUSER_WIDTH  : natural := 1;
  constant C_AXI4_WUSER_WIDTH  : natural := 1;
  constant C_AXI4_BUSER_WIDTH  : natural := 1;

  constant C_AXI4L_ADDR_WIDTH : natural := 32;
  constant C_AXI4L_DATA_WIDTH : natural := 32;

  constant C_AXI4S_ID_WIDTH   : natural := 8;
  constant C_AXI4S_DATA_WIDTH : natural := 128;
  constant C_AXI4S_DEST_WIDTH : natural := 4;
  constant C_AXI4S_USER_WIDTH : natural := 128;

end package common_axi_cfg;

