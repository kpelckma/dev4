## -------------------------------------------------------------------------- #
#           ____  _____________  __                                           #
#          / __ \/ ____/ ___/\ \/ /                 _   _   _                 #
#         / / / / __/  \__ \  \  /                 / \ / \ / \                #
#        / /_/ / /___ ___/ /  / /               = ( M | S | K )=              #
#       /_____/_____//____/  /_/                   \_/ \_/ \_/                #
#                                                                             #
# --------------------------------------------------------------------------- #
# @copyright Copyright 2021 DESY
# SPDX-License-Identifier: Apache-2.0
# --------------------------------------------------------------------------- #
# @date 2021-08-30
# @author Lukasz Butkowski  <lukasz.butkowski@desy.de>
# --------------------------------------------------------------------------- #
# @brief
# Part of DESY FPGA Firmware Framework (fwk)
# Contains procedures for vhdl_tool LSP
# -------------------------------------------------------------------------------

# do not execute tool dependent stages (setPrjProperties setProperties)
variable SetPrjProperties 0

array set SourcesArray {}
variable SourcesArray
variable LibList {}

# ==============================================================================
proc cleanProject {} {
  if { [file exists ${::fwfwk::ProjectPath}/vhdltool-config.yaml] } {
    file delete -force ${::fwfwk::ProjectPath}/vhdltool-config.yaml
  }
}

# ==============================================================================
proc createProject {} {

  # set to include all OSVVM libs
  if {[info exists ::fwfwk::OsvvmPath] } {
    set ::fwfwk::lib::osvvm::IncludeModule {osvvm Common DpRam UART Axi4 Axi4Lite Axi4Stream}
  }

}

# ==============================================================================
proc closeProject {} {}

# ==============================================================================
proc saveProject {} {
  variable SourcesArray
  set toolYamlFile [open ${::fwfwk::ProjectPath}/vhdltool-config.yaml w]

  puts $toolYamlFile "Libraries:"

  addToolLibraries

  foreach { lib sourcess } [ array get SourcesArray ] {
    puts $toolYamlFile "    - name: ${lib}"
    puts $toolYamlFile "      paths:"

    foreach src $sourcess {
      puts $toolYamlFile "       - \'$src\'"
    }
  }

  # TOOL preferences and configuration
  puts $toolYamlFile "Preferences:"
  puts $toolYamlFile "    TypeCheck: True            # Enable/disable typechecking"
  puts $toolYamlFile "    MultiLineErrors: True      # Display errors over multiple lines"
  puts $toolYamlFile "    CheckOnChange: True        # Enable/disable check-as-you-type"
  puts $toolYamlFile "    Lint: True                 # Enable/disable linting"
  puts $toolYamlFile "    FirstSyntaxErrorOnly: True # Display the first sintax error only in a file"



  puts $toolYamlFile "Lint: #Linter rule configuration."
  puts $toolYamlFile "    Threshold: Warning #Threshold, below which messages are not displayed."


  puts $toolYamlFile "    #Long form rule configuration. Both enabled/disabled status and severity can be configured this way."
  puts $toolYamlFile "    DeclaredNotAssigned: "
  puts $toolYamlFile "          enabled:  True"
  puts $toolYamlFile "          severity: Warning #Default severity Warning"

  puts $toolYamlFile "    #Short form. Only enabled/disabled status can be specified. Severity is the default for the rule."
  puts $toolYamlFile "    DeclaredNotRead:             True #Default severity Warning"
  puts $toolYamlFile "    ReadNotAssigned:             True #Default severity Critical"
  puts $toolYamlFile "    SensitivityListCheck:        True #Default severity Warning"
  puts $toolYamlFile "    ExtraSensitivityListCheck:   True #Default severity Warning"
  puts $toolYamlFile "    DuplicateSensitivity:        True #Default severity Warning"
  puts $toolYamlFile "    LatchCheck:                  True #Default severity Critical"
  puts $toolYamlFile "    VariableNotRead:             True #Default severity Warning"
  puts $toolYamlFile "    PortNotRead:                 True #Default severity Warning"
  puts $toolYamlFile "    PortNotWritten:              True #Default severity Critical"
  puts $toolYamlFile "    NoPrimaryUnit:               True #Default severity Warning"
  puts $toolYamlFile "    DuplicateLibraryImport:      True #Default severity Warning"
  puts $toolYamlFile "    DuplicatePackageUsage:       True #Default severity Warning"
  puts $toolYamlFile "    DeprecatedPackages:          True #Default severity Warning"
  puts $toolYamlFile "    ImplicitLibraries:           True #Default severity Warning"
  puts $toolYamlFile "    DisconnectedPorts:           True #Default severity Critical"
  puts $toolYamlFile "    IntNoRange:                  True #Default severity Warning"

  close $toolYamlFile
  puts "-- created vhdltool-config.yaml file in project root"
}

# ==============================================================================
# add tool libraries based on availability in the environment paths
proc addToolLibraries {} {
  variable SourcesArray
  set path ''

  # Xilinx ISE
  if { [info exists ::env(XILINX)] } {
    set path "$::env(XILINX)/vhdl/src"
    if { [file exists $path]} {
      lappend SourcesArray(unisim) $path/unisims/unisim_VCOMP.vhd
      lappend SourcesArray(unisim) $path/unisims/unisim_VPKG.vhd
      lappend SourcesArray(unimacro) $path/unimacro/unimacro_VCOMP.vhd
    }
  }

  # Xilinx Vivado
  if { [info exists ::env(XILINX_VIVADO)] } {
    set path "$::env(XILINX_VIVADO)/data/vhdl/src"
    if { [file exists $path]} {
      lappend SourcesArray(unisim) $path/unisims/unisim_VCOMP.vhd
      lappend SourcesArray(unisim) $path/unisims/unisim_VPKG.vhd
      lappend SourcesArray(unimacro) $path/unimacro/unimacro_VCOMP.vhd
    }
  }

}

# ==============================================================================
proc addSources {args srcList} {
  variable SourcesArray

  # default library work
  set defLibrary work

  # parse the library argument
  set library ""
  set args [::fwfwk::utils::parseArgValue $args "-lib" library]

  foreach src $srcList {
    # Currently Rust HDL supports VHDL only
    set srcFile [lindex $src 0]
    set srcLib  [lindex $src 2]
    set ext [file extension $srcFile]
    if { $ext == ".vhd" } {
      if { $library != ""} {    # -lib arg higher prio
        lappend SourcesArray($library) $srcFile
      } elseif { $srcLib != ""} { # if no -lib use file library
        lappend SourcesArray($srcLib) $srcFile
      } else { # use default tool library
        lappend SourcesArray($defLibrary) $srcFile
      }
    }
  }
}

# ==============================================================================
# dummy
proc addGenIPs { args sources} {}
