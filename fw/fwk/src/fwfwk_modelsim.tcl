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
# @date 2022-07-01
# @author Lukasz Butkowski <lukasz.butkowski@desy.de>
# @author Victor Andrei <victor.andrei@desy.de>
# --------------------------------------------------------------------------- #
# @brief
# Part of DESY FPGA Firmware Framework (fwk)
# ModelSim tool common functions
# --------------------------------------------------------------------------- #

# do not execute tool dependent stages (setPrjProperties setProperties)
variable SetPrjProperties 0

# variable MsimDo_Build       "modelsim.do"
# variable MsimProjConfTcl    "modelsim_proj_config.tcl"

variable last_compile_time 0

variable ColorScheme
variable UseFwkColors  true

# ==============================================================================
proc cleanProject {} {
}

# ==============================================================================
proc createProject {} {
  variable SourcesList
  set SourcessArray {}

  addToolLibraries
}

# ==============================================================================
proc buildProject {args} {
}

# ==============================================================================
proc compileSources {} {
  variable SourcesList
  variable last_compile_time

  foreach element $SourcesList {
    # set curId    [lindex $element 0]
    set srcFile  [lindex $element 0]
    set srcType  [lindex $element 1]
    set srcLib   [lindex $element 2]

    ::fwfwk::printInfo "Compiling ${srcFile} Into ${srcLib} library"

    vlib $srcLib
    vmap work $srcLib

    if { [catch { set file_mod_time [file mtime $srcFile] } resulttext] } {
      ::fwfwk::printError $resulttext; ::fwfwk::exit -2 }
    if { $last_compile_time < $file_mod_time } {
      if { $srcType == "VHDL"} {
        if { [catch { vcom -reportprogress 300 +acc $srcFile} resulttext] } { ::fwfwk::exit -2 } ; # VHDL design source
      } elseif { $srcType == "VHDL 2008"} {
        if { [catch { vcom -2008 -reportprogress 300 +acc $srcFile} resulttext] } { ::fwfwk::exit -2 } ; # VHDL 2008 design source
      } else {
        if { [catch { vlog -reportprogress 300 +acc $srcFile } resulttext] } { ::fwfwk::exit -2 } ; # Verilog/System Verilog design source
      }
    }
  }

  set last_compile_time [clock seconds]
}

# ==============================================================================
proc openProject {} {}

# ==============================================================================
proc closeProject {} {
}

# ==============================================================================
proc saveProject {} {
  compileSources
}

# ==============================================================================
proc addToolLibraries {} {
  variable SourcesList

  # Xilinx Vivado
  if { [info exists ::env(XILINX_VIVADO)] } {
    set path "$::env(XILINX_VIVADO)/data/verilog/src"
    if { [file exists $path]} {
      lappend SourcesList [list $path/glbl.v "Verilog" work]
    }
  }
}

# ==============================================================================
proc addSources {args srcList} {
  variable SourcesList

  # default library work
  set defLibrary work

  # parse the library argument
  set library ""
  set args [::fwfwk::utils::parseArgValue $args "-lib" library]

  foreach src $srcList {
    set srcFile [lindex $src 0]
    set srcType [lindex $src 1]
    set srcLib  [lindex $src 2]
    set ext [file extension $srcFile]
    # assign type based on extention if missing
    if {$srcType==""} {
      if { $ext == ".vhd"} {set srcType "VHDL"}; # Default is VHDL - 93
      if { $ext == ".v"}   {set srcType "Verilog"}
      if { $ext == ".sv"}  {set srcType "System Verilog"}
    }
    # append sourceFwkFile to the list
    if { $ext == ".vhd" | $ext == ".v" | $ext == ".sv"} {
      if { $srcLib != ""} { #  use file library
        lappend SourcesList [list $srcFile $srcType $srcLib]
      } elseif { $library != ""} {    # -lib if no file library
        lappend SourcesList [list $srcFile $srcType $library]
      } else { # use default tool library
        lappend SourcesList [list $srcFile $srcType $defLibrary]
      }
    }
  }
}

# ==============================================================================
proc simProject {} {
  variable ColorScheme
  variable UseFwkColors

  set varg {}
  lappend varg -t
  lappend varg 1ps

  foreach lib $::fwfwk::src::SimLibs {
    lappend varg -L
    lappend varg $lib
  }
  lappend varg -lib
  lappend varg work

  foreach top ${::fwfwk::src::SimTop} {
    lappend varg $top
  }

  eval vsim $varg

  view structure
  view signals
  view wave

  set customWaveTcl 0
  if { [info exists ::fwfwk::src::SimWaveTcl]} {
    if { [file exists $::fwfwk::src::SimWaveTcl] } {
      set customWaveTcl 1
      sourceFwkFile $::fwfwk::src::SimWaveTcl
    }
  }

  if { $customWaveTcl == 0 } {
    ::fwfwk::printWarning "No ::fwfwk::src::SimWaveTcl variable defined or file does not exist"
    ::fwfwk::printWarning "Using default Wave loging: all recursive."

    log -r *

    ## Set color scheme.
    #  Use ModelSim's color scheme if ::fwfwk::src::SimColorsMsim is set to true
    if { [info exists ::fwfwk::src::SimColorsMsim] && $::fwfwk::src::SimColorsMsim } {
      set UseFwkColors false
      ::fwfwk::printInfo "Variable ::fwfwk::src::SimColorsMsim is set. Will use ModelSim's color scheme."
    } else {
      set UseFwkColors true
      ::fwfwk::printInfo "Variable ::fwfwk::src::SimColorsMsim is not set."

      # Load fwk's default color scheme
      # (this also initialises the global variable ColorScheme)
      loadDefaultColorScheme

      # Set user colors, if they have been specified
      # (this will overwrite the default colors that have been previously set in variable ColorScheme)
      if {[info exists ::fwfwk::src::SimColorsUsr]} {
        ::fwfwk::printInfo "Variable ::fwfwk::src::SimColorsUsr is set. Will apply the user's color scheme."
        setUsrColors
      } else {
        ::fwfwk::printInfo "Variable ::fwfwk::src::SimColorsUsr is not set. Will use the fwk's default color scheme."
      }
    }

    foreach top ${::fwfwk::src::SimTop} {
      if {[string compare -nocase $top "glbl"] != 0} {
        addWaveGroupRecursive $top
      }
    }

    wave refresh

    quietly wave cursor active 1
    configure wave -namecolwidth 200
    configure wave -valuecolwidth 100
    configure wave -justifyvalue left
    configure wave -signalnamewidth 1
    configure wave -snapdistance 10
    configure wave -datasetprefix 0
    configure wave -rowmargin 4
    configure wave -childrowmargin 2
    configure wave -gridoffset 0
    configure wave -gridperiod 1
    configure wave -griddelta 40
    configure wave -timeline 0
    configure wave -timelineunits ns
    update

  }

  ::fwfwk::printCBM "== RUN SIMULATION =="
  if {[info exists ::fwfwk::src::SimTime]} {
    run $::fwfwk::src::SimTime
  } else {
    run 1000ns
  }

  WaveRestoreZoom {0 ps} [eval simtime]

  # Get performance-related statistics about elaboration and simulation
  ::fwfwk::printCBM "\n== SIMULATION STATS =="
  echo "------------------------------------------------------------"
  echo [simstats]
  echo "------------------------------------------------------------\n"

  ::fwfwk::printInfo "Simulation transcript : [transcript path]\n"
}

# ==============================================================================
# Find instances and signals in the design and add them to wave
proc addWaveGroupRecursive { top_instance_path } {
  variable UseFwkColors

  # Get the list of all instances at the current hierarchical design level.
  # Each item of the list is in the format "/top/instance (entity)".
  # E.g. "tb_01_fpga_top/UUT/ins_SYS_MGMT (sys_mgmt)".
  set child_instances [find instances -recursive ${top_instance_path}/*]
  set child_blocks  [find blocks -recursive ${top_instance_path}/*]

  # Initialise list
  set instances {}

  ## Create a listy of instances to include to wave
  # Include child instances to the main instance
  foreach inst $child_instances {
    lappend instances $inst
  }

  # Include child blocks to the instances list
  foreach block $child_blocks {
    lappend instances $block
  }

  # Sort instances, decreasing to have instances on top and next signals
  set instances [lsort -decreasing -ascii $instances]
  # foreach inst $instances {
  #   puts $inst
  # }

  # Include top instance signals as the last one
  lappend instances $top_instance_path

  # Iterate through the instances
  foreach inst $instances {
    set inst_path   [lindex $inst 0]
    set entity_name [lindex $inst 1]

    # Create groups with the hierarchy level
    set group_option {}
    set instance_levels [lrange [split $inst_path "/"] 1 end]
    foreach level $instance_levels {
      lappend group_option "-group"
      lappend group_option "$level"
    }
    #puts $group_option

    # Extract all the signals of the instance
    set signal_list [find signals $inst_path/*]

    # Group signals in:
    #   * "input_signals"    (labelled with the prefix "pi_"  or "p_i_"),
    #   * "output_signals"   (labelled with the prefix "po_"  or "p_o_"),
    #   * "inout_signals"    (labelled with the prefix "pio_" or "p_io_"),
    #   * "local_signals"    (labelled with the prefix "l_", "ls_", "s_" or "sig_"),
    #   * "macro_signals"    (with no particular naming convention; typically signals of instantiated primitives/macros/IPs)
    set input_signals    {}
    set output_signals   {}
    set inout_signals    {}
    set local_signals    {}
    set macro_signals    {}

    # REGEXP for signal grouping. Can be set by user. If not set, use default ones.
    if {![info exists ::fwfwk::src::SimWaveRegexPin] } {set ::fwfwk::src::SimWaveRegexPin  "(?i)(^pi_|^p_i_)" }
    if {![info exists ::fwfwk::src::SimWaveRegexPout]} {set ::fwfwk::src::SimWaveRegexPout "(?i)(^po_|^p_o_)" }
    if {![info exists ::fwfwk::src::SimWaveRegexPio] } {set ::fwfwk::src::SimWaveRegexPio  "(?i)(^pio_|^p_io_)" }
    if {![info exists ::fwfwk::src::SimWaveRegexSig] } {set ::fwfwk::src::SimWaveRegexSig  "(?i)(^l+_|^ls_|^s_|^sig_)" }

    foreach signal $signal_list {
      # Get signal name (with no path)
      set signal_name     [lrange [split $signal "/"] end end]

      # Group signals based on signal name style
      if {[regexp $::fwfwk::src::SimWaveRegexPin $signal_name]} {
        lappend input_signals $signal
      } elseif {[regexp $::fwfwk::src::SimWaveRegexPout $signal_name]} {
        lappend output_signals $signal;
      } elseif {[regexp $::fwfwk::src::SimWaveRegexPio $signal_name]} {
        lappend inout_signals $signal
      } elseif {[regexp $::fwfwk::src::SimWaveRegexSig $signal_name]} {
        lappend local_signals $signal
      } else {                                                                  ;# macro signals
        lappend macro_signals $signal
      }
    }

    # Add signals to the Waveform under their corresponding group.
    # Set separate coulours for each category of signals
    # Default radix to keep different color for X, Z, U states and hex format
    if { $UseFwkColors } {
      set color_x [getColor "rsrv_x" true]
      set color_z [getColor "rsrv_z" true]
      set color_u [getColor "rsrv_u" true]
      set rdx_define_body { X "X" -color $color_x, Z "Z" -color $color_z, U "U" -color $color_u, -default hex }
      set rdx_define_body [subst -nobackslashes -nocommands $rdx_define_body]
      radix define default_radix $rdx_define_body
    }

    if { [llength $input_signals] != 0 } {
      set input_signals [sortSignals $input_signals]
      if { $UseFwkColors } {
        eval add wave -noupdate -radix default_radix -color [getColor "input" 1] -itemcolor [getColor "input" 0] $group_option $input_signals
      } else {
        eval add wave -noupdate $group_option $input_signals
      }
    }

    if { [llength $output_signals] != 0 } {
      set output_signals [sortSignals $output_signals]
      if { $UseFwkColors } {
        eval add wave -noupdate -radix default_radix -color [getColor "output" 1] -itemcolor [getColor "output" 0] $group_option $output_signals
      } else {
        eval add wave -noupdate $group_option $output_signals
      }
    }

    if { [llength $inout_signals] != 0 } {
      set inout_signals [sortSignals $inout_signals]
      if { $UseFwkColors } {
        eval add wave -noupdate -radix default_radix -color [getColor "inout" 1] -itemcolor [getColor "inout" 0] $group_option $inout_signals
      } else {
        eval add wave -noupdate $group_option $inout_signals
      }
    }

    if { [llength $local_signals] != 0 } {
      set local_signals [sortSignals $local_signals]
      if { $UseFwkColors } {
        eval add wave -noupdate -radix default_radix -color [getColor "local" 1] -itemcolor [getColor "local" 0] $group_option $local_signals
      } else {
        eval add wave -noupdate $group_option $local_signals
      }
    }

    if { [llength $macro_signals] != 0 } {
      set macro_signals [sortSignals $macro_signals]
      if { $UseFwkColors } {
        eval add wave -noupdate -radix default_radix -color [getColor "macro" 1] -itemcolor [getColor "macro" 0] $group_option $macro_signals
      } else {
        eval add wave -noupdate $group_option $macro_signals
      }
    }
  }

  wave refresh

  return
}

# ==============================================================================
# Sort signals alphabetically and place reset and clock on top
proc sortSignals { signal_list } {
  # First sort the signals alphabetically
  set signal_list [lsort -ascii $signal_list]

  # Then move all the 'reset' signals to start of the list
  set idx 0
  foreach signal $signal_list {
    set signal_name [lrange [split $signal "/"] end end]
    if { ([string last "rst"   [string tolower $signal_name]] !=-1) ||
         ([string last "reset" [string tolower $signal_name]] !=-1) } {
      set rstsig $signal
      set signal_list [lreplace $signal_list $idx $idx]
      set signal_list [linsert $signal_list 0 $rstsig]
    }
    incr idx
  }
  # Finally, move all the 'clock' signals to start of the list
  set idx 0
  foreach signal $signal_list {
    set signal_name [lrange [split $signal "/"] end end]
    if { ([string last "clk"   [string tolower $signal_name]] !=-1) ||
         ([string last "clock" [string tolower $signal_name]] !=-1) } {
      set rstsig $signal
      set signal_list [lreplace $signal_list $idx $idx]
      set signal_list [linsert $signal_list 0 $rstsig]
    }
    incr idx
  }
  return $signal_list
}

# ==============================================================================
# Set default colors for signal waves and signal names.
proc loadDefaultColorScheme {} {
  variable ColorScheme

  # Format of dictionary values: 
  #    User I/O signals       : {WaveColor NameColor}
  #    Reserved signal states : {WaveColor}
  set ColorScheme [dict create input  {MediumSpringGreen MediumSpringGreen} \
                               output {Cyan              Cyan             } \
                               inout  {SteelBlue         SteelBlue        } \
                               local  {Khaki             Khaki            } \
                               macro  {White             White            } \
                               rsrv_x  Red                                  \
                               rsrv_z  Blue                                 \
                               rsrv_u  Salmon                               ]

}

# ==============================================================================
# Update the color scheme with user's preferences.
# Users can configure only the colors of input, output, inout, local and macro 
# signals. The colors for the signals states 'X', 'Z' and 'U' are reserved 
# (i.e. cannot be changed).
# Format of the input user color data:
#   - a list of nested lists, where each nested list should contain the following 
#     three parameters:   { <signal type> <wave color> <name color> }
proc setUsrColors {} {
  variable ColorScheme

  if { [llength $::fwfwk::src::SimColorsUsr] != 0 } {
    # Loop the nested lists
    foreach item $::fwfwk::src::SimColorsUsr {
      # Check format of the received nested list
      if {[llength $item] == 3} {
        set signalType  [string tolower [lindex $item 0]]
        set wave_color  [lindex $item 1]
        set name_color  [lindex $item 2]
        # Check if signalType is a valid dict key
        if {[lsearch [dict keys $ColorScheme] $signalType] != -1 } {
          # Change only the colors of I/O, local and macro signals
          if {[string first "rsrv_" $signalType] == -1} {
            dict set ColorScheme $signalType [list $wave_color $name_color]
            ::fwfwk::printInfo "Applied the following user colors for $signalType signals : $wave_color (wave color) and $name_color (name color)."
          } else {
            ::fwfwk::printWarning "Changing the default color scheme for signal states 'X', 'Z' and 'U' is not permitted. Will ignore the input request ($item)."
          }
        } else {
          ::fwfwk::printWarning "Found invalid signal type: $signalType in input list <$item>. Will ignore these user settings."
        }
      } else {
        ::fwfwk::printWarning "Found wrong format of input color list ($item). Will ignore these user settings."
      }
    }
  } else {
    ::fwfwk::printWarning "Variable ::fwfwk::src::SimColorsUsr is empty! Will use the fwk's default color scheme."
  }

  ### puts "\n-- ColorScheme : [llength $ColorScheme] : $ColorScheme"
}

# ==============================================================================
# Get wave/name color for the given signal type
proc getColor { signalType isWaveColor } {
  variable ColorScheme
  set idx 0

  if { !$isWaveColor } { set idx 1 } ;# name color

  if { [string first "rsrv_" [string tolower $signalType]] == 0 } { 
    return [dict get $ColorScheme $signalType]
  } else {
    return [lindex [dict get $ColorScheme $signalType] $idx]
  }
}
