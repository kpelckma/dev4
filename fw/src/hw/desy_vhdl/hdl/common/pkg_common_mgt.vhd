--------------------------------------------------------------------------------
--          ____  _____________  __                                           --
--         / __ \/ ____/ ___/\ \/ /                 _   _   _                 --
--        / / / / __/  \__ \  \  /                 / \ / \ / \                --
--       / /_/ / /___ ___/ /  / /               = ( M | S | K )=              --
--      /_____/_____//____/  /_/                   \_/ \_/ \_/                --
--                                                                            --
--------------------------------------------------------------------------------
--! @copyright (c) 2023 DESY
--! SPDX-License-Identifier: CERN-OHL-W-2.0
--------------------------------------------------------------------------------
--! @date 2023-02-22
--! @author Burak Dursun <burak.dursun@desy.de>
--------------------------------------------------------------------------------
--! @brief record of signals associated with shared MGT resources
--!
--! this is a dummy record to be used when MGT resources are not shared
--! for sharing, this package should be replaced with the one from BSP module
--! recommended file name is pkg_common_mgt_<ARCHITECTURE>
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

package common_mgt is

  type t_mgt_shared is record
    dummy         : std_logic;
    dummy_vector  : std_logic_vector(7 downto 0);
  end record t_mgt_shared;

  type t_mgt_shared_vector is array (natural range <>) of t_mgt_shared;

end package common_mgt;

