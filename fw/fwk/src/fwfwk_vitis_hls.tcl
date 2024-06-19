## -------------------------------------------------------------------------- #
#           ____  _____________  __                                           #
#          / __ \/ ____/ ___/\ \/ /                 _   _   _                 #
#         / / / / __/  \__ \  \  /                 / \ / \ / \                #
#        / /_/ / /___ ___/ /  / /               = ( M | S | K )=              #
#       /_____/_____//____/  /_/                   \_/ \_/ \_/                #
#                                                                             #
# --------------------------------------------------------------------------- #
# @copyright Copyright 2023 DESY
# SPDX-License-Identifier: Apache-2.0
# --------------------------------------------------------------------------- #
# @date 2023-01-26
# @author Seyed Nima Omidsajedi <nima.sajedi@desy.de>
# --------------------------------------------------------------------------- #
# @brief#
# Part of DESY FPGA Firmware Framework (fwk)
# contains procedures for Xilinx Vitis HLS creation and build
# --------------------------------------------------------------------------- #

# no address to be generated, disable globally
set ::fwfwk::addr::TypesToGen {}

proc cleanProject {} {

  ::fwfwk::printCBM "Clean project"
  # delete existing project files if existing
  set curFile "${::fwfwk::PrjBuildPath}/$::fwfwk::ProjectName"
  if { [ file exists $curFile ] } {
    file delete -force $curFile
  }

}

# ==============================================================================
proc createProject {} {
  variable SourcesList
#  cd $::fwfwk::PrjPath
  # open or craete project
  # Open an existing project, or create one if project does not exist.
  ::fwfwk::printInfo "Create Project from fwfwk_vitis_hls.tcl, createProject proc"
  open_project $::fwfwk::ProjectName

  ::fwfwk::printInfo "Set Top Function"
  set_top $::fwfwk::Top

  ::fwfwk::printInfo "Create Solution"
  open_solution $::fwfwk::ProjectConf

  ::fwfwk::printInfo "Set FPGA Part"
  set_part $::fwfwk::Part

  ::fwfwk::printInfo "Set Clock period (ns)"
  create_clock -period $::fwfwk::ClockPeriod -name default

  ::fwfwk::printInfo "Set Clock uncertainty"
  set_clock_uncertainty $::fwfwk::ClockUncertainty

}


# ==============================================================================
proc openProject {} {

  ::fwfwk::printInfo "Openning HLS Project $::fwfwk::PrjBuildName ..."
  open_project $::fwfwk::ProjectName

  ::fwfwk::printInfo "Openning HLS Solution $::fwfwk::PrjBuildName ..."
  open_solution $::fwfwk::ProjectConf

}

# ==============================================================================
proc closeProject {} {
  close_solution
  close_project
}

# ==============================================================================
proc saveProject {} {
  variable SourcesList
  # crate makefiles for csimulation
  set CMakeListFile [open ${::fwfwk::PrjBuildPath}/CMakeLists.txt w]

  puts $CMakeListFile "cmake_minimum_required(VERSION 3.3)"
  puts $CMakeListFile "project (${::fwfwk::PrjBuildName})"
  puts $CMakeListFile "set(CMAKE_CXX_STANDARD 14)"
  puts $CMakeListFile "include_directories($::env(XILINX_HLS)/include)"
  puts $CMakeListFile "enable_testing()"
  puts $CMakeListFile "add_compile_options(-fPIC -O3  -lm  -Wno-unused-result \
    -D__SIM_FPO__ -D__SIM_OPENCV__ -D__SIM_FFT__ -D__SIM_FIR__ -D__SIM_DDS__ -D__DSP48E1__ -g)"

  foreach src $SourcesList {
    set path [lindex $src 0]
    set type [lindex $src 1]
    if { $type == "source"} {
      puts $CMakeListFile "list (APPEND SRC_LIST \"$path\")"
      puts $CMakeListFile "message(\"-- Adding Source $path\")"
    }
  }
  puts $CMakeListFile "add_library(hlsip STATIC \$\{SRC_LIST\})"
  puts $CMakeListFile ""

  foreach src $SourcesList {
    set path [lindex $src 0]
    set type [lindex $src 1]
    set name  [file rootname [file tail $path]]
    if { $type == "testbench"} {
      puts $CMakeListFile "add_executable(${name} ${path})"
      puts $CMakeListFile "target_link_libraries(${name} PRIVATE hlsip)"
      puts $CMakeListFile "add_test(NAME ${name} COMMAND \$<TARGET_FILE:${name}>)"
    }
  }

  close $CMakeListFile
  puts "-- created CMakeList.txt file in project build $::fwfwk::PrjBuildPath"

}

# ==============================================================================
proc addSources {args srcList} {
  variable SourcesList

  foreach src $srcList {
    set path [lindex $src 0]
    set type [lindex $src 1]
    if { $type == "source"} {
      ::fwfwk::printInfo "Add Top Module (HLS code for IP)"
      add_files $path
    }
    if { $type == "testbench"} {
      ::fwfwk::printInfo "Add related Testbench"
      add_files -tb $path
    }
    # append to general sources list to be used later e.g. in csim
    lappend SourcesList $src
  }

}

# ==============================================================================
proc simProject {} {
  # simulation with gcc over makefile
  # here place sim using vitis_hls
}

# ==============================================================================
proc synthProject {} {

  ::fwfwk::printInfo "Synthesizes Vitis HLS project for the active solution"
  if { [catch { csynth_design } resulttext ] } { puts $resulttext; ::fwfwk::exit -1 }

}

# ==============================================================================
proc startProjectGui {} {
}
# ==============================================================================
proc buildProject {args} {
  synthProject
}

# ==============================================================================
proc exportOut {} {

  set nsTop ::fwfwk::src::${::fwfwk::Top}
  set VerMajor [subst $${nsTop}::VerMajor]
  set VerMinor [subst $${nsTop}::VerMinor]
  set VerPatch [subst $${nsTop}::VerPatch]

  set Vendor   [subst $${nsTop}::Vendor]
  set Name     [subst $${nsTop}::Name]

  ::fwfwk::printInfo "Export and packages the generated RTL code as a packaged IP"
  if {[catch \
         {export_design -format ip_catalog \
            -ipname ${Name} \
            -version "${VerMajor}.${VerMinor}.${VerPatch}" \
            -vendor ${Vendor} \
            -rtl VHDL \
            -output $::fwfwk::ProjectPath/out/$::fwfwk::PrjBuildName \
           } resulttext ] } { puts $resulttext; ::fwfwk::exit -1 }

  file copy -force $::fwfwk::ProjectPath/out/$::fwfwk::PrjBuildName/export.zip \
    $::fwfwk::ProjectPath/out/$::fwfwk::PrjBuildName/${Name}_v${VerMajor}.${VerMinor}.zip

  ::fwfwk::printCBM "Exported HLS IP located at: $::fwfwk::ProjectPath/out/$::fwfwk::PrjBuildName"
}
