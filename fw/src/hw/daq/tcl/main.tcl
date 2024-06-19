proc init {} {
}

proc setSources {} {

  variable Vhdl
  variable Vhdl_desy

  genModVerFile VHDL ../hdl/pkg_version_daq.vhd

  lappend Vhdl_desy $::fwfwk::LibPath/desy_vhdl/hdl/math/pkg_math_basic.vhd
  lappend Vhdl_desy $::fwfwk::LibPath/desy_vhdl/hdl/common/pkg_common_types.vhd
  lappend Vhdl_desy $::fwfwk::LibPath/desy_vhdl/hdl/common/pkg_common_axi.vhd
  lappend Vhdl_desy $::fwfwk::LibPath/desy_vhdl/hdl/common/pkg_common_axi_cfg.vhd
  lappend Vhdl_desy $::fwfwk::LibPath/desy_vhdl/hdl/bus/axi/axi4_buf_sch.vhd
  lappend Vhdl_desy $::fwfwk::LibPath/desy_vhdl/hdl/bus/axi/axi4_buf.vhd
  lappend Vhdl_desy $::fwfwk::LibPath/desy_vhdl/hdl/bus/axi/axi4_mux.vhd
  lappend Vhdl_desy $::fwfwk::LibPath/desy_vhdl/hdl/misc/arbiter/arbiter_round_robin.vhd
  lappend Vhdl_desy $::fwfwk::LibPath/desy_vhdl/hdl/misc/trigger_divider.vhd
  lappend Vhdl_desy $::fwfwk::LibPath/desy_vhdl/hdl/misc/trigger_delay.vhd
  lappend Vhdl_desy $::fwfwk::LibPath/desy_vhdl/hdl/memory/ram/dual_port_memory.vhd
  lappend Vhdl_desy $::fwfwk::LibPath/desy_vhdl/hdl/memory/fifo/pkg_memory_fifo.vhd
  lappend Vhdl_desy $::fwfwk::LibPath/desy_vhdl/hdl/memory/fifo/fifo_input.vhd
  lappend Vhdl_desy $::fwfwk::LibPath/desy_vhdl/hdl/memory/fifo/fifo_output.vhd
  lappend Vhdl_desy $::fwfwk::LibPath/desy_vhdl/hdl/memory/fifo/fifo_dpram.vhd
  lappend Vhdl_desy $::fwfwk::LibPath/desy_vhdl/hdl/memory/fifo/fifo_generic.vhd
  lappend Vhdl_desy $::fwfwk::LibPath/desy_vhdl/hdl/memory/fifo/fifo_dualclock_macro.vhd
  lappend Vhdl_desy $::fwfwk::LibPath/desy_vhdl/hdl/memory/fifo/fifo_virtex.vhd
  lappend Vhdl_desy $::fwfwk::LibPath/desy_vhdl/hdl/memory/fifo/fifo_ultrascale.vhd
  lappend Vhdl_desy $::fwfwk::LibPath/desy_vhdl/hdl/memory/fifo/fifo.vhd

  lappend Vhdl ../hdl/daq_timestamps.vhd
  lappend Vhdl ../hdl/daq_timestamps_to_mem.vhd
  lappend Vhdl ../hdl/burst_generator.vhd
  lappend Vhdl ../hdl/daq_to_axi.vhd
  lappend Vhdl ../hdl/daq_mux.vhd
  lappend Vhdl ../hdl/daq_top.vhd

}

proc setAddressSpace {} {
  variable AddressSpace

  addAddressSpace AddressSpace "daq" RDL 0x00000000 ../rdl/daq.rdl
}

# ==============================================================================
proc doOnCreate {} {

  variable Vhdl
  variable Vhdl_desy
  # Re-generate the revision file
  genModVerFile VHDL ../hdl/pkg_version_daq.vhd

  addSources Vhdl
  addSources "Vhdl_desy" -lib desy
}
