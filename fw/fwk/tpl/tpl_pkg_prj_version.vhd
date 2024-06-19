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
--! @brief   template for the project version package
--! @created 2020-01-30
-------------------------------------------------------------------------------
--! Description:
--!
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

package {PKG_NAME} is

  constant C_PRJ_VERSION     : std_logic_vector(31 downto 0) := x"{PRJ_VERSION}" ;
  constant C_PRJ_SHASUM      : std_logic_vector(31 downto 0) := x"{PRJ_SHASUM}" ;
  constant C_PRJ_TIMESTAMP   : std_logic_vector(31 downto 0) := x"{PRJ_TIMESTAMP}" ;

end {PKG_NAME} ;

