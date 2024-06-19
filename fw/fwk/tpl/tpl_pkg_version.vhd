-------------------------------------------------------------------------------
--          ____  _____________  __                                          --
--         / __ \/ ____/ ___/\ \/ /                 _   _   _                --
--        / / / / __/  \__ \  \  /                 / \ / \ / \               --
--       / /_/ / /___ ___/ /  / /               = ( M | S | K )=             --
--      /_____/_____//____/  /_/                   \_/ \_/ \_/               --
--                                                                           --
-------------------------------------------------------------------------------
-- Copyright (c) 2020 DESY
-------------------------------------------------------------------------------
--! @brief   template for the version package for a particular module
--! @created 2020-01-30
-------------------------------------------------------------------------------
--! Description:
--! This template is used by fwk to inject Version and Timestamp information
--! in to the module's register map
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

package {PKG_NAME} is

  constant C_VERSION     : std_logic_vector(31 downto 0) := x"{VERSION}";
  constant C_TIMESTAMP   : std_logic_vector(31 downto 0) := x"{TIMESTAMP}";

end {PKG_NAME} ;

