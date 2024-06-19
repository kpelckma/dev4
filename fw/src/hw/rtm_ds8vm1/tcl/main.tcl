proc init {} {

}

proc setSources {} {

  variable Vhdl
  variable Vhdl_desy

  lappend Vhdl ../hdl/rtm_ds8vm1_top.vhd
  lappend Vhdl ../hdl/i2c_subsys.vhd

  genModVerFile VHDL ../hdl/pkg_version_rtm_ds8vm1.vhd
  lappend Vhdl ../hdl/pkg_version_rtm_ds8vm1.vhd

  lappend Vhdl_desy   $::fwfwk::LibPath/desy_vhdl/hdl/misc/arbiter/arbiter_priority_synced.vhd
  lappend Vhdl_desy   $::fwfwk::LibPath/desy_vhdl/hdl/peripheral/i2c/i2c_controller.vhd
  lappend Vhdl_desy   $::fwfwk::LibPath/desy_vhdl/hdl/peripheral/i2c/i2c_control_arbiter.vhd
  lappend Vhdl_desy   $::fwfwk::LibPath/desy_vhdl/hdl/peripheral/i2c/ltc2607.vhd
  lappend Vhdl_desy   $::fwfwk::LibPath/desy_vhdl/hdl/peripheral/i2c/lmk04906_over_pca9535.vhd
  lappend Vhdl_desy   $::fwfwk::LibPath/desy_vhdl/hdl/peripheral/i2c/hmc624_over_pca9535.vhd
  lappend Vhdl_desy   $::fwfwk::LibPath/desy_vhdl/hdl/peripheral/i2c/pca9535.vhd
  lappend Vhdl_desy   $::fwfwk::LibPath/desy_vhdl/hdl/peripheral/i2c/ltc2493.vhd
  lappend Vhdl_desy   $::fwfwk::LibPath/desy_vhdl/hdl/peripheral/i2c/max662x.vhd
}


proc setAddressSpace {} {
  variable AddressSpace
  addAddressSpace AddressSpace "rtm" RDL 0x00000000 ../rdl/rtm.rdl
}

proc doOnCreate {} {

  variable Vhdl
  variable Vhdl_desy

  # Creating the Version Package to display it on address space
  genModVerFile VHDL ../hdl/pkg_version_rtm_ds8vm1.vhd

  addSources Vhdl
  addSources "Vhdl_desy" -lib desy
}