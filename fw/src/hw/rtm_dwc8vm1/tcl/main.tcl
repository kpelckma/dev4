
proc init {} {
}

proc setSources {} {

  variable Vhdl
  variable Vhdl_desy

  lappend Vhdl ../hdl/i2c_subsys.vhd
  lappend Vhdl ../hdl/rtm_dwc8vm1_top.vhd

  lappend Vhdl_desy $::fwfwk::LibPath/desy_vhdl/hdl/common/pkg_common_types.vhd
  lappend Vhdl_desy $::fwfwk::LibPath/desy_vhdl/hdl/common/pkg_common_numarray.vhd
  lappend Vhdl_desy $::fwfwk::LibPath/desy_vhdl/hdl/misc/arbiter/arbiter_priority_synced.vhd
  lappend Vhdl_desy $::fwfwk::LibPath/desy_vhdl/hdl/peripheral/i2c/i2c_controller.vhd
  lappend Vhdl_desy $::fwfwk::LibPath/desy_vhdl/hdl/peripheral/i2c/i2c_control_arbiter.vhd
  lappend Vhdl_desy $::fwfwk::LibPath/desy_vhdl/hdl/peripheral/i2c/ad5624_over_pca9535.vhd
  lappend Vhdl_desy $::fwfwk::LibPath/desy_vhdl/hdl/peripheral/i2c/hmc624_over_pca9535.vhd
  lappend Vhdl_desy $::fwfwk::LibPath/desy_vhdl/hdl/peripheral/i2c/pca9535.vhd
  lappend Vhdl_desy $::fwfwk::LibPath/desy_vhdl/hdl/peripheral/i2c/ltc2493.vhd
  lappend Vhdl_desy $::fwfwk::LibPath/desy_vhdl/hdl/peripheral/i2c/hyt271.vhd
}

proc setAddressSpace {} {
  variable AddressSpace
  addAddressSpace AddressSpace "rtm" RDL 0x00000000 ../rdl/rtm.rdl
}

proc doOnCreate {} {

  variable Vhdl
  variable Vhdl_desy

  addSources Vhdl
  addSources "Vhdl_desy" -lib desy
}
