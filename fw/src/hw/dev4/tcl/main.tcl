proc init {} {

  # Config variable is auto added by FWK.
  variable Config 

  # AppConfig variable is created here and gets filled by parseVhdlConfigFile
  variable AppConfig  
  variable AppConfigFile

  # get configuration constants for the board
  set AppConfigFile ../hdl/pkg_app_config_$::fwfwk::AppConf.vhd

  # Parse the App Config
  parseVhdlConfigFile AppConfig $AppConfigFile

  if { ![array size AppConfig] } {
    ::fwfwk::printError "AppConfig variable is empty. This project needs proper pkg_app_config.\n"
  }


  # Add Modules to FWK namespace
  addSrcModule daq $::fwfwk::SrcPath/daq/tcl/main.tcl
  addSrcModule mimo $::fwfwk::SrcPath/mimo/tcl/main.tcl
  addSrcModule timing $::fwfwk::SrcPath/timing/tcl/main.tcl

  # According to pkg_app_config we are injecting defines inside app.vh
  if { $AppConfig(C_RTM_TYPE) == 0 } {
    set Config(C_RTM_DS8VM1) 1
    addSrcModule rtm_ds8vm1 $::fwfwk::SrcPath/rtm_ds8vm1/tcl/main.tcl
  } elseif { $AppConfig(C_RTM_TYPE) == 1} {
    set Config(C_RTM_DWC8VM1) 1
    addSrcModule rtm_dwc8vm1 $::fwfwk::SrcPath/rtm_dwc8vm1/tcl/main.tcl
  }

  # FWK adds 'Config' variable automatically to each module
  # Here we are extending this Config variable of each module with stuff from pkg_app_conf
  # so that it can be seen inside verilog header files used by DesyRDL
  set Config(C_DAQ_REGIONS)         $AppConfig(C_DAQ_REGIONS)
  set Config(C_DAQ0_MAX_SAMPLES)    $AppConfig(C_DAQ0_MAX_SAMPLES)
  set Config(C_CHANNEL_WIDTH_BYTES) $AppConfig(C_CHANNEL_WIDTH_BYTES)
  set Config(C_DAQ0_BUF0_OFFSET)    $AppConfig(C_DAQ0_BUF0_OFFSET)
  set Config(C_DAQ0_BUF1_OFFSET)    $AppConfig(C_DAQ0_BUF1_OFFSET)
  set Config(C_TRG_CNT)             $AppConfig(C_TRG_CNT)
  set timing::Config(C_OUT_TRG)          $AppConfig(C_TRG_CNT)
  set timing::Config(C_EXT_TRG)          8
}

proc setSources {} { 

  variable AppConfig
  variable AppConfigFile 
  variable Vhdl
  variable Vhdl_desy
  variable Xdc


  # Libraries
  # lappend Vhdl_desy ../hdl/fixed_pkg_2008.vhd/

  lappend Vhdl_desy $::fwfwk::LibPath/desy_vhdl/hdl/common/pkg_common_types.vhd
  lappend Vhdl_desy $::fwfwk::LibPath/desy_vhdl/hdl/common/pkg_common_numarray.vhd
  lappend Vhdl_desy $::fwfwk::LibPath/desy_vhdl/hdl/memory/ram/dual_port_memory.vhd

  # TOP
  lappend Vhdl ../hdl/app_top.vhd

  # board payload
  lappend Vhdl ../hdl/sis8300ku_payload.vhd
  # App Config
  lappend Vhdl $AppConfigFile
  # contraints
  lappend Xdc ../cstr/default_sis8300ku.xdc  
}

proc setAddressSpace {} {

  variable AppConfig
  variable AddressSpace
  variable AddressSpaceDAQ

  # If the type is RDL the ' Type Name' field must be refering to the Instantiation name (name which appears on map file)
  #                               Type Name        Type    {BAR BaseAddr Range} Args
  addAddressSpace AddressSpace    "app"            RDL     {0x00000000}         ../rdl/app.rdl       AppConfig
  addAddressSpace AddressSpace    "TIMING"         INSTANCE   {}                timing::AddressSpace AppConfig
  addAddressSpace AddressSpace    "DAQ"            INSTANCE   {}                daq::AddressSpace    AppConfig
  addAddressSpace AddressSpace    "MIMO"           INSTANCE   {}                mimo::AddressSpace    AppConfig

  # According to pkg_app_config we are selecting which rtm module gets attached to Application Address Space
  if { $AppConfig(C_RTM_TYPE) == 0 } {
    addAddressSpace AddressSpace    "RTM"  INSTANCE   {} rtm_ds8vm1::AddressSpace     AppConfig
  } elseif { $AppConfig(C_RTM_TYPE) == 1} {
    addAddressSpace AddressSpace    "RTM"  INSTANCE  {} rtm_dwc8vm1::AddressSpace    AppConfig
  }

  # Attach the DAQ DDR memory address space definition.
  # This needs to be at the end since it starts a separate 'branch' from the rest of the above.
  addAddressSpace AddressSpaceDAQ "app_daq" RDL {} ../rdl/app_daq.rdl   AppConfig

}

proc doOnCreate {} {
  variable Vhdl
  variable Vhdl_desy
  variable Xdc

  addSources Vhdl
  addSources Xdc
  addSources "Vhdl_desy" -lib desy
}
