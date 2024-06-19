# -------------------------------------------------------------------------------
# --          ____  _____________  __                                          --
# --         / __ \/ ____/ ___/\ \/ /                 _   _   _                --
# --        / / / / __/  \__ \  \  /                 / \ / \ / \               --
# --       / /_/ / /___ ___/ /  / /               = ( M | S | K )=             --
# --      /_____/_____//____/  /_/                   \_/ \_/ \_/               --
# --                                                                           --
# -------------------------------------------------------------------------------
## @copyright Copyright 2022 DESY
# SPDX-License-Identifier: Apache-2.0
# --------------------------------------------------------------------------- #
# @date 2022-06-9
# @author Andrea Bellandi <andrea.bellandi@desy.de>
# --------------------------------------------------------------------------- #
# @brief
# Part of DESY FPGA Firmware Framework (fwk)
# contains utilities for Xilinx XPS
# --------------------------------------------------------------------------- #

# ==============================================================================
# Utility functions to interact with the XILINX XPS system generator.
# These functions are used to generate HDL files and C BSPs out of the
# XPS XMP/MHS file format to describe processor systems.
namespace eval ::fwfwk::utils::xps {

  # ==============================================================================
  # Generate HDL sources from an XMP file that describes a processor system.
  # The target FPGA (partName) and the instance of the IP inside the project
  # (instanceName) needs to be passed as well
  proc generateCpuHdl {XMPFile outDir partName instanceName} {

    set CurDir [pwd]
    set outDir [file normalize $outDir]
    set XMPFile [file normalize $XMPFile]

    file mkdir $outDir
    cd $outDir

    set basename [file rootname [file tail $XMPFile]]
    set MHSFile [file rootname $XMPFile].mhs
    file mkdir $outDir/platgen_generated
    file copy -force $XMPFile $outDir/${basename}.xmp
    file copy -force $MHSFile $outDir/${basename}.mhs

    set XMPFile $outDir/[file tail $XMPFile]
    set MHSFile $outDir/[file tail $MHSFile]

    set platgenCmd {}
    lappend platgenCmd -lang vhdl
    lappend platgenCmd -od $outDir/platgen_generated
    lappend platgenCmd -p $partName
    lappend platgenCmd -ti $instanceName
    lappend platgenCmd -toplevel no
    lappend platgenCmd -log $outDir/platgen.log
    lappend platgenCmd $MHSFile

    puts "---------------------------------------------------------------------"
    ::fwfwk::printInfo "Executing platgen"
    puts "---------------------------------------------------------------------"

    eval exec 2> $outDir/stderr_platgen "platgen $platgenCmd"

    cd $CurDir

    file copy -force -- $outDir/platgen_generated/implementation/${basename}_stub.bmm $outDir/
    set Bmm $outDir/${basename}_stub.bmm
    set Ngc [glob -nocomplain -path $outDir/platgen_generated/implementation/ *.ngc]
    set Vhdl $outDir/platgen_generated/hdl/${basename}.vhd

    set result "Ngc \{$Ngc\}"
    set result "$result Vhdl \{$Vhdl\}"
    set result "$result Bmm $Bmm"

    return $result
  }

  proc generateHwFile {MHSFile HwFile} {

    set MHSFile [file normalize $MHSFile]

    set CurDir [pwd]
    cd $::fwfwk::PrjBuildPath

    set basename [file rootname [file tail $MHSFile]]

    set psf2EdwardCmd {}
    lappend psf2EdwardCmd -inp $MHSFile
    lappend psf2EdwardCmd -dont_add_loginfo -make_inst_lower
    lappend psf2EdwardCmd -edwver 1.2
    lappend psf2EdwardCmd -xml $HwFile

    puts "---------------------------------------------------------------------"
    ::fwfwk::printInfo "Executing psf2Edward to generate the HwFile $HwFile"
    puts "---------------------------------------------------------------------"

    set fp [open "psf2EdwardCmd.tcl" w]
    puts $fp "exec 2>stderr_psf2Edward psf2Edward $psf2EdwardCmd"
    puts $fp "exit"
    close $fp

    eval exec "xps -nw -scr psf2EdwardCmd.tcl"

    cd $CurDir
  }

  proc generateCpuSwBsp {HwFile outDir {appguruFlags ""}} {
    set CurDir [pwd]
    set outDir [file normalize $outDir]

    set appguruCmd {}
    lappend appguruCmd -hw $HwFile
    lappend appguruCmd -app empty_application
    lappend appguruCmd -od $outDir
    set appguruCmd [concat $appguruCmd $appguruFlags]

    puts $appguruCmd

    puts "---------------------------------------------------------------------"
    ::fwfwk::printInfo "Executing appguru"
    puts "---------------------------------------------------------------------"

    file mkdir $outDir

    eval exec 2> $outDir/stderr_appguru "appguru $appguruCmd"

    return $outDir
  }
}
