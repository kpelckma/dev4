------------------------------------------------------------------------------
--          ____  _____________  __                                         --
--         / __ \/ ____/ ___/\ \/ /                 _   _   _               --
--        / / / / __/  \__ \  \  /                 / \ / \ / \              --
--       / /_/ / /___ ___/ /  / /               = ( M | S | K )=            --
--      /_____/_____//____/  /_/                   \_/ \_/ \_/              --
--                                                                          --
------------------------------------------------------------------------------
--! @copyright Copyright 2022 DESY
--! SPDX-License-Identifier: CERN-OHL-W-2.0
------------------------------------------------------------------------------
--! @date 2022-01-16
--! @author Katharina Schulz <katharina.schulz@desy.de>
------------------------------------------------------------------------------
--! @brief
--! Package to allow connection of II-BUS interfaces with desyrdl ones
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library desy;
use desy.bus_ii;

library desyrdl;
use desyrdl.common;

--==============================================================================
package ii_to_desyrdl is

  function f_ii_to_desyrdl (
    signal arg_ibus_reg  : desyrdl.common.t_ibus_m2s
  )
  return desy.bus_ii.t_ibus_o;
  
  function f_ii_to_desyrdl (
    signal arg_ibus_reg  : desy.bus_ii.t_ibus_i
  ) 
  return desyrdl.common.t_ibus_s2m;

end package ii_to_desyrdl;

--==============================================================================
package body ii_to_desyrdl is

  function f_ii_to_desyrdl (
    signal arg_ibus_reg  : desyrdl.common.t_ibus_m2s
  ) return desy.bus_ii.t_ibus_o  is
    variable v_result : desy.bus_ii.t_ibus_o;
  begin
    v_result.addr := arg_ibus_reg.addr;
    v_result.data  := arg_ibus_reg.data;
    v_result.rena   := arg_ibus_reg.rena;
    v_result.wena  := arg_ibus_reg.wena;
    v_result.clk := arg_ibus_reg.clk;
    return v_result;
  end function f_ii_to_desyrdl;

  function f_ii_to_desyrdl (
    signal arg_ibus_reg  : desy.bus_ii.t_ibus_i
  ) return desyrdl.common.t_ibus_s2m  is
    variable v_result : desyrdl.common.t_ibus_s2m;
  begin
    v_result.clk := arg_ibus_reg.clk;
    v_result.data  := arg_ibus_reg.data;
    v_result.rack   := arg_ibus_reg.rack;
    v_result.wack  := arg_ibus_reg.wack;
    
    return v_result;
  end function f_ii_to_desyrdl;

end package body ii_to_desyrdl;
