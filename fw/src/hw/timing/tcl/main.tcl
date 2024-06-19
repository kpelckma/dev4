proc init {} {
}

proc setSources {} {

  variable Sources

  # Library path should be set on the project tcl not here.
  lappend Sources [list $::fwfwk::LibPath/desy_vhdl/hdl/common/pkg_common_types.vhd    "VHDL" "desy"]
  lappend Sources [list $::fwfwk::LibPath/desy_vhdl/hdl/common/pkg_common_numarray.vhd "VHDL" "desy"]
  lappend Sources [list $::fwfwk::LibPath/desy_vhdl/hdl/misc/trigger_delay.vhd         "VHDL" "desy"]

  lappend Sources ../hdl/trigger_generation.vhd
  lappend Sources ../hdl/timing_top.vhd
}

proc setAddressSpace {} {
  variable AddressSpace
  addAddressSpace AddressSpace timing RDL 0x00000000 ../rdl/timing.rdl
}

# ==============================================================================
proc doOnCreate {} {

  addSources Sources

}
