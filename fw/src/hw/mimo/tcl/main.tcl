# ==============================================================================
proc init {} {
}

# ==============================================================================
proc setSources {} {

  variable Vhdl

  genModVerFile VHDL ../hdl/pkg_version_mimo.vhd

  lappend Vhdl ../hdl/pkg_b32.vhd
  lappend Vhdl ../hdl/active.vhd
  lappend Vhdl ../hdl/iq.vhd
  lappend Vhdl ../hdl/pid16.vhd
  lappend Vhdl ../hdl/ilc16.vhd
  lappend Vhdl ../hdl/delayline.vhd
  lappend Vhdl ../hdl/mimo.vhd
}

# ==============================================================================
proc setAddressSpace {} {
  variable AddressSpace

  addAddressSpace AddressSpace "mimo" RDL 0x00000000 ../rdl/mimo.rdl

}

# ==============================================================================
proc doOnCreate {} {
  variable Vhdl
  addSources Vhdl
  genModVerFile VHDL ../hdl/pkg_version_mimo.vhd
}
