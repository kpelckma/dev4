## -------------------------------------------------------------------------- #
#           ____  _____________  __                                           #
#          / __ \/ ____/ ___/\ \/ /                 _   _   _                 #
#         / / / / __/  \__ \  \  /                 / \ / \ / \                #
#        / /_/ / /___ ___/ /  / /               = ( M | S | K )=              #
#       /_____/_____//____/  /_/                   \_/ \_/ \_/                #
#                                                                             #
# --------------------------------------------------------------------------- #
# @copyright Copyright 2021-2022 DESY
# SPDX-License-Identifier: Apache-2.0
# --------------------------------------------------------------------------- #
# @date 2022-07-28
# @author Andrea Bellandi <andrea.bellandi@desy.de>
# --------------------------------------------------------------------------- #
# @brief
# Part of DESY FPGA Firmware Framework (fwk)
# cocotb simulation backend
# --------------------------------------------------------------------------- #

# ==============================================================================
proc createProject {} {

  ::fwfwk::printInfo "Creating library: work"
  variable Libraries
  lappend Libraries work
  variable Vhdl_work ""
  variable Verilog ""
}

# ==============================================================================
proc buildProject {args} {
}

# ==============================================================================
proc openProject {} {}

# ==============================================================================
proc closeProject {} {}

# ==============================================================================
proc saveProject {} {

  variable Libraries
  variable Verilog

  if {[info exists ::fwfwk::TopLanguage] == 0} {
    set ::fwfwk::TopLanguage vhdl
  }

  if {[info exists ::fwfwk::Simulator] == 0} {
    set ::fwfwk::Simulator ghdl
  }

  foreach library $Libraries {
    variable Vhdl_$library
  }

  set idx [lsearch $Libraries "work"]
  set Libraries [lreplace $Libraries $idx $idx]

  puts "----------------------------------------------------"
  ::fwfwk::printInfo "Saving project information"
  puts "----------------------------------------------------"

  set fp_tests [open [file join $::fwfwk::WorkspacePath test_list.txt] "w"]

  foreach test $::fwfwk::src::SimTop {


    set test_filename [file tail [lindex $test 0]]
    set test_module [file rootname $test_filename]
    set makefile_name Makefile_$test_module

    file delete -force [file join $::fwfwk::WorkspacePath $test_filename]
    file link -symbolic [file join $::fwfwk::WorkspacePath $test_filename] [lindex $test 0]

    ::fwfwk::printInfo "Generating $makefile_name"

    puts $fp_tests "$makefile_name [lindex $test]"

    set fp [open [file join $::fwfwk::WorkspacePath $makefile_name] "w"]
    puts $fp "TOPLEVEL_LANG = $::fwfwk::TopLanguage"
    puts $fp "MODULE = $test_module"
    puts $fp "TOPLEVEL = $::fwfwk::src::Top"
    puts $fp "SIM = $::fwfwk::Simulator"
    puts $fp "VERILOG_SOURCES += $Verilog"
    puts $fp "VHDL_SOURCES += $Vhdl_work"

    foreach library $Libraries {
      set library_variable Vhdl_$library
      puts $fp "VHDL_SOURCES_$library += [set $library_variable]"
    }

    puts $fp "VHDL_LIB_ORDER = $Libraries"
    puts $fp "WAVES = 1"
    puts $fp "RANDOM_SEED = 1234567890"
    if {[llength $test] > 1} {
      puts $fp [genericParamGenerator [lrange $test 1 end]]
    }

    if {$::fwfwk::TopLanguage == "vhdl"} {
      puts $fp ""
      puts $fp "ifeq (\$(SIM),ghdl)"
      puts $fp "  EXTRA_ARGS += --std=93"
      puts $fp "  SIM_ARGS += --wave=dump.ghw --vcd=dump.vcd"
      puts $fp "else ifneq (\$(filter \$(SIM),questa modelsim riviera activehdl),)"
      puts $fp "  COMPILE_ARGS += -93"
      puts $fp "endif"
      puts $fp ""
    }

    if {$::fwfwk::TopLanguage == "verilog"} {
      puts $fp "ifneq (\$(filter \$(SIM),riviera activehdl),)"
      puts $fp "    COMPILE_ARGS += -sv2k12"
      puts $fp "endif"
    }

    puts $fp "include \$(shell cocotb-config --makefiles)/Makefile.sim"
    close $fp
  }

  close $fp_tests
}

# ==============================================================================
proc genericParamGenerator {genericParams} {

  set makefile_var ""
  set makefile_flag ""
  set makefile_sep ""
  set makefile_end ""

  if {$::fwfwk::TopLanguage == "verilog"} {
    if {[lsearch -exact {icarus} $::fwfwk::Simulator] >= 0} {
      set makefile_var "COMPILE_ARGS"
      set makefile_flag "-P${::fwfwk::src::Top}."
      set makefile_sep "="
      set makefile_end ""
    } elseif {[lsearch -exact {questa modelsim riviera activehdl} $::fwfwk::Simulator] >= 0} {
      set makefile_var "SIM_ARGS"
      set makefile_flag "-g"
      set makefile_sep "="
      set makefile_end ""
    } elseif {[lsearch -exact {vcs} $::fwfwk::Simulator] >= 0} {
      set makefile_var "COMPILE_ARGS"
      set makefile_flag "-pvalue+${::fwfwk::src::Top}/"
      set makefile_sep "="
      set makefile_end ""
    } elseif {[lsearch -exact {verilator} $::fwfwk::Simulator] >= 0} {
      set makefile_var "COMPILE_ARGS"
      set makefile_flag "-G"
      set makefile_sep "="
      set makefile_end ""
    } elseif {[lsearch -exact {ius xcelium} $::fwfwk::Simulator] >= 0} {
      set makefile_var "EXTRA_ARGS"
      set makefile_flag "-defparam \"${::fwfwk::src::Top}."
      set makefile_sep "="
      set makefile_end "\""
    }
  }

  if {$::fwfwk::TopLanguage == "vhdl"} {
    if {[lsearch -exact {ghdl questa modelsim riviera activehdl} $::fwfwk::Simulator] >= 0} {
      set makefile_var "SIM_ARGS"
      set makefile_flag "-g"
      set makefile_sep "="
      set makefile_end ""
    } elseif {[lsearch -exact {ius xcelium} $::fwfwk::Simulator] >= 0} {
      set makefile_var "SIM_ARGS"
      set makefile_flag "-generic \"${::fwfwk::src::Top}:"
      set makefile_sep "=>"
      set makefile_end "\""
    }
  }

  set params_line "$makefile_var +="
  foreach {param_name param_value} $genericParams {
    append params_line " ${makefile_flag}${param_name}"
    append params_line "${makefile_sep}${param_value}${makefile_end}"
  }

  return $params_line
}

# ==============================================================================
proc addSources {args srcList} {

  variable Libraries
  variable Verilog

  # default library work
  set libraryArg "work"

  # parse the library argument
  set args [::fwfwk::utils::parseArgValue $args "-lib" libraryArg]

  if { "" != $libraryArg } {
    if {[lsearch -exact $Libraries $libraryArg] < 0} {
      ::fwfwk::printInfo "Creating library: $libraryArg"
      lappend Libraries $libraryArg
    }

    variable Vhdl_$libraryArg

  } else {
    set libraryArg work
  }

  foreach src $srcList  {
    set filename [lindex $src 0]
    if {[file extension $filename] == ".vhd"} {
      if {[llength $src] == 1 || [llength [lindex $src 2]] == 0} {
        lappend Vhdl_$libraryArg [file normalize $filename]
      } else {
        set library [lindex $src 2]

        if {[lsearch -exact $Libraries $library] < 0} {
          ::fwfwk::printInfo "Creating library: $library"
          lappend Libraries $library
        }

        variable Vhdl_$library
        lappend Vhdl_$library [file normalize $filename]
      }
    } elseif {[file extension $filename] == ".sv"} {
      lappend Verilog [file normalize $filename]
    } elseif {[file extension $filename] == ".v"} {
      lappend Verilog [file normalize $filename]
    } else {
      ::fwfwk::printError "Not recognized file extension of [file normalize $filename]"
      ::fwfwk::exit -1
    }
  }
}

# ==============================================================================
proc simProject {} {

  set curDir [pwd]
  cd $::fwfwk::WorkspacePath

  set fp_tests [open test_list.txt "r"]
  foreach makefile [split [read $fp_tests] "\n"] {

    if {[file exists [lindex $makefile 0]]} {

      ::fwfwk::printCBM "\n> Running [lindex $makefile 0]\n"
      ::fwfwk::printInfo "FILE: [lindex $makefile 1]"

      set test_name [string map {Makefile_ ""} [lindex $makefile 0]]

      exec make -f [lindex $makefile 0] >&@stdout

      if {[file exists results.xml]} {
        ::fwfwk::releaseFile results.xml $test_name
        file copy -force results.xml $test_name.xml
      }

      if {[file exists dump.vcd]} {
        ::fwfwk::releaseFile dump.vcd $test_name
        file copy -force dump.vcd $test_name.vcd
      }

      if {[file exists dump.ghw]} {
        ::fwfwk::releaseFile dump.ghw $test_name
        file copy -force dump.ghw $test_name.ghw
      }
    }
  }

  close $fp_tests
}

# ==============================================================================
proc cleanProject {} {}
