################################################################################
# Main tcl for the Project
################################################################################

proc init {} {

  # Setting the library path (Normally it defaults to /src/lib which we dont want
  set ::fwfwk::LibPath ${::fwfwk::ProjectPath}/src/hw/
  # You can also set up Source path (it defaults to src/)
  set ::fwfwk::SrcPath ${::fwfwk::ProjectPath}/src/hw/

  # Adding modules
  addSrcModule bsp $::fwfwk::SrcPath/bsp_sis8300ku/tcl/main.tcl
  addSrcModule app $::fwfwk::SrcPath/dev4/tcl/main.tcl

  set app::Config(C_IRQ_CHANNEL_CNT) 16
  set bsp::Config(C_PCIE_IRQ_CNT) 16


  set ::fwfwk::addr::TypesToGen {vhdl map}
  set ::fwfwk::addr::TypesToAdd {vhdl}

}

proc setAddressSpace {} {

  addAddressSpace ::fwfwk::AddressSpace "BSP"    ARRAY {C0 0x00000000 8M} bsp::AddressSpace
  addAddressSpace ::fwfwk::AddressSpace "APP"    ARRAY {C0 0x00800000 8M} app::AddressSpace
   
  addAddressSpace ::fwfwk::AddressSpace "BSP"    ARRAY {C13 0x00000000 8M} bsp::AddressSpace
  addAddressSpace ::fwfwk::AddressSpace "APP"    ARRAY {C13 0x00800000 8M} app::AddressSpace
  addAddressSpace ::fwfwk::AddressSpace {DAQBUF} ARRAY {C13 0x80000000}    app::AddressSpaceDAQ

}

proc doOnCreate {} {
  set ::fwfwk::src::Top app_top
}


proc setSim {} {
  set ::fwfwk::src::SimTop app_top
  set ::fwfwk::src::SimTime 1us
}

