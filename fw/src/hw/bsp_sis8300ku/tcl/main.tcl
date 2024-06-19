################################################################################
# Main tcl for the module in fwk framework
################################################################################

proc init {} {
  variable Config
  variable ConfigFile
  variable BspConfig
  variable bspPcieGen 2
  variable bspPcieIrqCnt 16

  # Add FCM module
  addSrcModule fpga_config_manager $::fwfwk::SrcPath/fpga_config_manager/tcl/main.tcl

  # get configuration constants for the board
  if {[info exist ::fwfwk::BspConf]} {
    set ConfigFile ../hdl/pkg_bsp_config_$::fwfwk::BspConf.vhd
  }
  parseVhdlConfigFile BspConfig $ConfigFile

  # Propagating IRQ CNT info to be used by DesyRDL
  set Config(C_PCIE_IRQ_CNT) $bspPcieIrqCnt
}

proc setSources {} {
  variable ConfigFile
  variable BspConfig

  variable Vhdl
  variable Vhdl_desy
  variable Xdc

  lappend Vhdl ../hdl/pkg_sis8300ku_payload.vhd
  lappend Vhdl ../hdl/bsp_mmcm_wrapper.vhd
  lappend Vhdl ../hdl/app_mmcm_wrapper.vhd

  # BSP Configuration
  lappend Vhdl $ConfigFile

  # Interface definition configuration
  # configuration Tip: You can have different configuration for interfaces depending on the application
  # In that case axi configuration should NOT come from desy_common library but from BSP
  lappend Vhdl_desy $::fwfwk::LibPath/desy_vhdl/hdl/common/pkg_common_bsp_ifs.vhd
  lappend Vhdl_desy $::fwfwk::LibPath/desy_vhdl/hdl/common/pkg_common_axi.vhd
  lappend Vhdl_desy $::fwfwk::LibPath/desy_vhdl/hdl/common/pkg_common_axi_cfg.vhd
  lappend Vhdl_desy $::fwfwk::LibPath/desy_vhdl/hdl/common/pkg_common_types.vhd
  lappend Vhdl_desy $::fwfwk::LibPath/desy_vhdl/hdl/common/pkg_common_numarray.vhd
  lappend Vhdl_desy $::fwfwk::LibPath/desy_vhdl/hdl/common/pkg_common_to_desyrdl.vhd
  lappend Vhdl_desy $::fwfwk::LibPath/desy_vhdl/hdl/misc/clock/clock_freq.vhd
  lappend Vhdl_desy $::fwfwk::LibPath/desy_vhdl/hdl/misc/xdma_irq_handler.vhd
  lappend Vhdl_desy $::fwfwk::LibPath/desy_vhdl/hdl/misc/clock/app_clk_ctrl.vhd
  lappend Vhdl_desy $::fwfwk::LibPath/desy_vhdl/hdl/peripheral/sn74lv8153.vhd
  lappend Vhdl_desy $::fwfwk::LibPath/desy_vhdl/hdl/peripheral/spi/axi4_spi_3w.vhd
  lappend Vhdl_desy $::fwfwk::LibPath/desy_vhdl/hdl/peripheral/adc/ad9628.vhd
  lappend Vhdl_desy $::fwfwk::LibPath/desy_vhdl/hdl/peripheral/dac/max5878.vhd

  # Interface Definition's Configuration
  lappend Vhdl_desy ../hdl/pkg_bsp_ifs_cfg.vhd

  # Add the major hdl files for BSP
  lappend Vhdl ../hdl/sis8300ku_bsp_logic_top.vhd
  lappend Vhdl ../hdl/bsp_sis8300ku_top.vhd

  # Constraints Sources

  # Pin Assignments
  lappend Xdc ../cstr/pin_assignments_clocks.xdc
  lappend Xdc ../cstr/pin_assignments_adc.xdc
  lappend Xdc ../cstr/pin_assignments_dac.xdc
  lappend Xdc ../cstr/pin_assignments_rtm.xdc
  lappend Xdc ../cstr/pin_assignments_misc.xdc
  lappend Xdc ../cstr/pin_assignments_pcie.xdc
  lappend Xdc ../cstr/pin_assignments_ddr4.xdc

  # clock constraints for ADC depends on BSP Configuration
  puts "C_APP_FREQ = $BspConfig(C_APP_FREQ) (Hz)"
  if  { $BspConfig(C_APP_FREQ) == 81250000 } {
      lappend Xdc ../cstr/timing_adc_81.xdc
  } elseif {$BspConfig(C_APP_FREQ) == 121875000 } {
      lappend Xdc ../cstr/timing_adc_121.xdc
  } else {
      # By default we are going with 125MHz settings
      lappend Xdc ../cstr/timing_adc_default.xdc
  }

  lappend Xdc ../cstr/timing_clocks.xdc
  lappend Xdc ../cstr/timing_dac.xdc
  lappend Xdc ../cstr/false_paths.xdc

  # Bitstream Generation Constraints
  lappend Xdc ../cstr/bitstream_config.xdc

}


proc setAddressSpace {} {

  variable AddressSpace
  variable AddressSpaceBsp

  addAddressSpace AddressSpaceBsp "sis8300ku_bsp_logic" RDL         {C0 0x00000000}    ../rdl/sis8300ku_bsp_logic.rdl
  addAddressSpace AddressSpaceBsp "FCM"                 INSTANCE    {C0 0x00010000}    fpga_config_manager::AddressSpace

  addAddressSpace AddressSpace    "TOP"                 TOP         {C0 0x00000000}    {}
  addAddressSpace AddressSpace    "BSP"                 INSTANCE    {C0 0x00000000}    AddressSpaceBsp

}


proc doOnCreate { } {

  variable Vhdl
  variable Vhdl_desy
  variable Xdc
  variable TclPath
  variable bspPcieGen
  variable BspConfig

  ::fwfwk::printInfo "Setting FPGA Ordering Code: xcku040-ffva1156-1-c"
  ::fwfwk::printInfo "FPGA Family: Kintex Ultrascale"
  ::fwfwk::printInfo "Number of logic cells: 40k"
  ::fwfwk::printInfo "Package: ffva1156"
  ::fwfwk::printInfo "Speed Grade: -1"
  ::fwfwk::printInfo "Temperature Grade: -C (Commercial)"

  switch $::fwfwk::ToolType {
    vivado {

      set_property part xcku040-ffva1156-1-c [current_project]
      set_property target_language VHDL [current_project]

      # Making sure Vivado doesn't create 'work' library.
      # Since work means current library. Which can make things break in our libraries
      set_property default_lib xil_defaultlib [current_project]

      # add source files
      addSources "Vhdl_desy" -lib desy
      addSources "Vhdl"
      addSources -fileset constrs_1 "Xdc"

      ::fwfwk::printInfo "Creating the block desing that carries the PCIe and MIG"

      # Source the Block design that contains xDMA and MIG
      source ../tcl/bd_bsp.tcl

      # set all to 2008 except DPM, DPM file cannot be used on VHDL2008, exclude BD system
      set_property file_type {VHDL 2008} [get_files -filter {FILE_TYPE == VHDL && NAME !~ "*sis8300ku_bsp_bd*"}]

      # set TOP
      set_property top bsp_sis8300ku_top [current_fileset]

    }
    default {
      addSources "Vhdl_desy" -lib desy
      addSources "Vhdl"
    }
  }
}

proc setSim {} {

  # TODO

}
