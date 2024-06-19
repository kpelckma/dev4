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
--! @date 2022-01-18
--! @author Lukasz Butkowski <lukasz.butkowski@desy.de>
--! @author Cagil Gumus <cagil.guemues@desy.de>
------------------------------------------------------------------------------
--! @brief
--! Package to allow connection of common AXI interfaces with desyrdl ones
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library desy;
use desy.common_axi;
use desy.common_bsp_ifs;

library desyrdl;
use desyrdl.common;

--==============================================================================
package common_to_desyrdl is

  function f_common_to_desyrdl (
    signal arg_axi4l_reg  : desy.common_bsp_ifs.t_axi4l_reg_m2s
  )
  return desyrdl.common.t_axi4l_m2s;

  function f_common_to_desyrdl (
    signal arg_axi4l_reg  : desy.common_bsp_ifs.t_axi4l_reg_s2m
  )
  return desyrdl.common.t_axi4l_s2m;

  function f_common_to_desyrdl (
    signal arg_axi4l_reg  : desyrdl.common.t_axi4l_m2s
  )
  return desy.common_bsp_ifs.t_axi4l_reg_m2s;

  function f_common_to_desyrdl (
    signal arg_axi4l_reg  : desyrdl.common.t_axi4l_s2m
  )
  return desy.common_bsp_ifs.t_axi4l_reg_s2m ;

  function f_common_to_desyrdl (
    signal arg_axi4l_reg  : desy.common_axi.t_axi4l_m2s
  )
  return desyrdl.common.t_axi4l_m2s;

  function f_common_to_desyrdl (
    signal arg_axi4l_reg  : desy.common_axi.t_axi4l_s2m
  )
  return desyrdl.common.t_axi4l_s2m;

  function f_common_to_desyrdl (
    signal arg_axi4l_reg  : desyrdl.common.t_axi4l_m2s
  )
  return desy.common_axi.t_axi4l_m2s;

  function f_common_to_desyrdl (
    signal arg_axi4l_reg  : desyrdl.common.t_axi4l_s2m
  )
  return desy.common_axi.t_axi4l_s2m;
 
end package common_to_desyrdl;

--==============================================================================
package body common_to_desyrdl is

  function f_common_to_desyrdl (
    signal arg_axi4l_reg  : desy.common_bsp_ifs.t_axi4l_reg_m2s
  ) return desyrdl.common.t_axi4l_m2s is
    variable v_result : desyrdl.common.t_axi4l_m2s;
  begin
    v_result.awaddr   := arg_axi4l_reg.awaddr;
    v_result.awprot   := arg_axi4l_reg.awprot;
    v_result.awvalid  := arg_axi4l_reg.awvalid;
    v_result.wdata    := arg_axi4l_reg.wdata;
    v_result.wstrb    := arg_axi4l_reg.wstrb;
    v_result.wvalid   := arg_axi4l_reg.wvalid;
    v_result.bready   := arg_axi4l_reg.bready;
    v_result.araddr   := arg_axi4l_reg.araddr;
    v_result.arprot   := arg_axi4l_reg.arprot;
    v_result.arvalid  := arg_axi4l_reg.arvalid;
    v_result.rready   := arg_axi4l_reg.rready;

    return v_result;
  end function f_common_to_desyrdl;

  function f_common_to_desyrdl (
    signal arg_axi4l_reg  : desy.common_bsp_ifs.t_axi4l_reg_s2m
  ) return desyrdl.common.t_axi4l_s2m is
    variable v_result : desyrdl.common.t_axi4l_s2m;
  begin
    v_result.awready := arg_axi4l_reg.awready;
    v_result.wready  := arg_axi4l_reg.wready;
    v_result.bresp   := arg_axi4l_reg.bresp;
    v_result.bvalid  := arg_axi4l_reg.bvalid;
    v_result.arready := arg_axi4l_reg.arready;
    v_result.rdata   := arg_axi4l_reg.rdata;
    v_result.rresp   := arg_axi4l_reg.rresp;
    v_result.rvalid  := arg_axi4l_reg.rvalid;

    return v_result;
  end function f_common_to_desyrdl;

  function f_common_to_desyrdl (
    signal arg_axi4l_reg  : desyrdl.common.t_axi4l_m2s
  ) return  desy.common_bsp_ifs.t_axi4l_reg_m2s is
    variable v_result :  desy.common_bsp_ifs.t_axi4l_reg_m2s;
  begin
    v_result.awaddr   := arg_axi4l_reg.awaddr;
    v_result.awprot   := arg_axi4l_reg.awprot;
    v_result.awvalid  := arg_axi4l_reg.awvalid;
    v_result.wdata    := arg_axi4l_reg.wdata;
    v_result.wstrb    := arg_axi4l_reg.wstrb;
    v_result.wvalid   := arg_axi4l_reg.wvalid;
    v_result.bready   := arg_axi4l_reg.bready;
    v_result.araddr   := arg_axi4l_reg.araddr;
    v_result.arprot   := arg_axi4l_reg.arprot;
    v_result.arvalid  := arg_axi4l_reg.arvalid;
    v_result.rready   := arg_axi4l_reg.rready;

    return v_result;
  end function f_common_to_desyrdl;

  function f_common_to_desyrdl (
    signal arg_axi4l_reg  : desyrdl.common.t_axi4l_s2m
  ) return desy.common_bsp_ifs.t_axi4l_reg_s2m  is
    variable v_result : desy.common_bsp_ifs.t_axi4l_reg_s2m;
  begin
    v_result.awready := arg_axi4l_reg.awready;
    v_result.wready  := arg_axi4l_reg.wready;
    v_result.bresp   := arg_axi4l_reg.bresp;
    v_result.bvalid  := arg_axi4l_reg.bvalid;
    v_result.arready := arg_axi4l_reg.arready;
    v_result.rdata   := arg_axi4l_reg.rdata;
    v_result.rresp   := arg_axi4l_reg.rresp;
    v_result.rvalid  := arg_axi4l_reg.rvalid;

    return v_result;
  end function f_common_to_desyrdl;

  function f_common_to_desyrdl (
    signal arg_axi4l_reg  : desy.common_axi.t_axi4l_m2s
  ) return desyrdl.common.t_axi4l_m2s is
    variable v_result : desyrdl.common.t_axi4l_m2s;
  begin
    v_result.awaddr   := arg_axi4l_reg.awaddr;
    v_result.awprot   := arg_axi4l_reg.awprot;
    v_result.awvalid  := arg_axi4l_reg.awvalid;
    v_result.wdata    := arg_axi4l_reg.wdata;
    v_result.wstrb    := arg_axi4l_reg.wstrb;
    v_result.wvalid   := arg_axi4l_reg.wvalid;
    v_result.bready   := arg_axi4l_reg.bready;
    v_result.araddr   := arg_axi4l_reg.araddr;
    v_result.arprot   := arg_axi4l_reg.arprot;
    v_result.arvalid  := arg_axi4l_reg.arvalid;
    v_result.rready   := arg_axi4l_reg.rready;

    return v_result;
  end function f_common_to_desyrdl;

  function f_common_to_desyrdl (
    signal arg_axi4l_reg  : desy.common_axi.t_axi4l_s2m
  ) return desyrdl.common.t_axi4l_s2m is
    variable v_result : desyrdl.common.t_axi4l_s2m;
  begin
    v_result.awready := arg_axi4l_reg.awready;
    v_result.wready  := arg_axi4l_reg.wready;
    v_result.bresp   := arg_axi4l_reg.bresp;
    v_result.bvalid  := arg_axi4l_reg.bvalid;
    v_result.arready := arg_axi4l_reg.arready;
    v_result.rdata   := arg_axi4l_reg.rdata;
    v_result.rresp   := arg_axi4l_reg.rresp;
    v_result.rvalid  := arg_axi4l_reg.rvalid;

    return v_result;
  end function f_common_to_desyrdl;

  function f_common_to_desyrdl (
    signal arg_axi4l_reg  : desyrdl.common.t_axi4l_m2s
  ) return  desy.common_axi.t_axi4l_m2s is
    variable v_result :  desy.common_axi.t_axi4l_m2s;
  begin
    v_result.awaddr   := arg_axi4l_reg.awaddr;
    v_result.awprot   := arg_axi4l_reg.awprot;
    v_result.awvalid  := arg_axi4l_reg.awvalid;
    v_result.wdata    := arg_axi4l_reg.wdata;
    v_result.wstrb    := arg_axi4l_reg.wstrb;
    v_result.wvalid   := arg_axi4l_reg.wvalid;
    v_result.bready   := arg_axi4l_reg.bready;
    v_result.araddr   := arg_axi4l_reg.araddr;
    v_result.arprot   := arg_axi4l_reg.arprot;
    v_result.arvalid  := arg_axi4l_reg.arvalid;
    v_result.rready   := arg_axi4l_reg.rready;

    return v_result;
  end function f_common_to_desyrdl;

  function f_common_to_desyrdl (
    signal arg_axi4l_reg  : desyrdl.common.t_axi4l_s2m
  ) return desy.common_axi.t_axi4l_s2m  is
    variable v_result : desy.common_axi.t_axi4l_s2m;
  begin
    v_result.awready := arg_axi4l_reg.awready;
    v_result.wready  := arg_axi4l_reg.wready;
    v_result.bresp   := arg_axi4l_reg.bresp;
    v_result.bvalid  := arg_axi4l_reg.bvalid;
    v_result.arready := arg_axi4l_reg.arready;
    v_result.rdata   := arg_axi4l_reg.rdata;
    v_result.rresp   := arg_axi4l_reg.rresp;
    v_result.rvalid  := arg_axi4l_reg.rvalid;

    return v_result;
  end function f_common_to_desyrdl;

end package body common_to_desyrdl;
