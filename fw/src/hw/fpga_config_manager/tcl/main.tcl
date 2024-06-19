# ==============================================================================
proc init {} {
  variable AddressSpace
  variable Sources {}

}

# ==============================================================================
proc setAddressSpace {} {
  variable AddressSpace
  # addAddressSpace variable_name "module type name/module instance name" Address_space_type(IBUS or ARRAY) Address Source_file
  addAddressSpace AddressSpace "fpga_config_manager" RDL 0x00000000 ../rdl/fpga_config_manager.rdl
}

# ==============================================================================
proc setSources {} {

  variable Sources

  # library component
  lappend Sources [list "${::fwfwk::LibPath}/desy_vhdl/hdl/memory/ram/dual_port_memory.vhd" "VHDL" "desy"]

  # Module components
  lappend Sources ../hdl/fpga_spi_io_phy.vhd
  lappend Sources ../hdl/fpga_spi_programmer.vhd

  lappend Sources ../hdl/frame_ecc_wrapper.vhd
  lappend Sources ../hdl/icap_boot_fsm.vhd
  lappend Sources ../hdl/icap_handler.vhd
  lappend Sources ../hdl/icap_wrapper.vhd

  lappend Sources ../hdl/fpga_config_manager_top.vhd

}

# ==============================================================================
proc doOnCreate {} {

  addSources "Sources"
}
