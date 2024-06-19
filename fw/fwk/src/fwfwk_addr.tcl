## -------------------------------------------------------------------------- #
#           ____  _____________  __                                           #
#          / __ \/ ____/ ___/\ \/ /                 _   _   _                 #
#         / / / / __/  \__ \  \  /                 / \ / \ / \                #
#        / /_/ / /___ ___/ /  / /               = ( M | S | K )=              #
#       /_____/_____//____/  /_/                   \_/ \_/ \_/                #
#                                                                             #
# --------------------------------------------------------------------------- #
# @copyright Copyright 2019-2021 DESY
# SPDX-License-Identifier: Apache-2.0
# --------------------------------------------------------------------------- #
# @date 2019-12-22
# @author Lukasz Butkowski <lukasz.butkowski@desy.de>
# @author Michael Buechler <michael.buechler@desy.de>
# --------------------------------------------------------------------------- #
# @brief
# Part of DESY FPGA Firmware Framework (fwk)
# FPGA firmware framework script handling address generation
# --------------------------------------------------------------------------- #

namespace eval ::fwfwk::addr {
  variable ArtifactsPath
  variable TypesToGen {vhdl map}; # by default generate all
  variable TypesToAdd {}
  variable MapMergeThr 256
  variable MapMergeChs {0 1 2 3 4 5 13 14 15 16}; # Default
}

proc ::fwfwk::addr::generate { {types {} } } {
  if { $types == {} } {
    ::fwfwk::printInfo "::fwfwk::addr::generate No argument provided, using TypesToGen variable"
    ::fwfwk::printInfo "TypesToGen: $::fwfwk::addr::TypesToGen"
    ::fwfwk::addr::main $::fwfwk::addr::TypesToGen
  } else {
    ::fwfwk::printInfo "::fwfwk::addr::generate Generating: $types"
    ::fwfwk::addr::main $types
  }

}
# ==============================================================================
# ------------------------------------------------------------------------------
proc ::fwfwk::addr::main {args} {
  variable ArtifactsPath
  variable TypesToGen
  variable TypesToAdd

  # decode argument list
  set AddrType  [lindex $args 0]

  # clear address space before recreating it
  array unset ::fwfwk::AddressSpace *
  set ::fwfwk::AddressSpaceDict   {}
  set ::fwfwk::AddressSpaceChDict {}
  set ::fwfwk::RdlFiles {}


  # set Artifacts Path
  set ArtifactsPath $::fwfwk::PrjBuildPath/${::fwfwk::PrjBuildName}.desyrdl
  # initialize ::fwfwk::AddressSpace by adding PROJECT node
  ::fwfwk::addAddressSpace ::fwfwk ::fwfwk::AddressSpace $::fwfwk::ProjectName PROJECT 0 ""

  # iterate over tree
  ::fwfwk::setAddressSpace

  # foreach {key value} [array get ::fwfwk::AddressSpace] {
  #   puts "$key:$value"
  # }
  # gen and print address tree
  ::fwfwk::addr::genAddrTree

  # generate address dictionaries
  ::fwfwk::addr::genAddrDict

  # --------------------------------------------------------
  # Artifacts
  if {![file exists $ArtifactsPath]} { file mkdir $ArtifactsPath }
  # generate RDL files - address space database
  ::fwfwk::addr::genRdlFiles

  variable ::fwfwk::src::DesyRdlSrc {}

  # generate output if an argument provided
  if { $AddrType != "" } {
    set TypesToGen $AddrType
    ::fwfwk::addr::genAddrSrc
  }

  return 0
}
# ==============================================================================
# ------------------------------------------------------------------------------
proc ::fwfwk::addr::genAddrSrc {} {
  variable ArtifactsPath
  variable TypesToGen
  variable MapMergeThr
  variable MapMergeChs

  ::fwfwk::addr::runDesyRdl $TypesToGen

  # select output file, next use in-out converter
  foreach type $TypesToGen {
    switch $type {
      map {
        # ::fwfwk::addr::runDesyRdl map
        puts "mmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmm"
        foreach maptype {mapp mapt} {
          set mapList {}
          set mergedFileName [file join $::fwfwk::ProjectPath/out/${::fwfwk::PrjBuildName} ${::fwfwk::PrjBuildName}_${::fwfwk::VerString}.$maptype]
          set mergedMapfile  [open $mergedFileName w]
          puts $mergedMapfile "@MAPFILE_REVISION ${::fwfwk::VerString}"
          puts "Creating $maptype file: $mergedFileName"
          # copy mapfiles per access channel
          foreach accessChannel [dict keys $::fwfwk::RdlFiles] {
            set tmpMapPath [file join $ArtifactsPath map]
            set fileName [file join $::fwfwk::ProjectPath/out/${::fwfwk::PrjBuildName} ${::fwfwk::PrjBuildName}_${::fwfwk::VerString}_ch${accessChannel}.$maptype]
            puts "Creating $maptype file: $fileName"
            set mapfile [open $fileName w]
            puts $mapfile "@MAPFILE_REVISION ${::fwfwk::VerString}"
            set infile [file join $tmpMapPath ch${accessChannel}.$maptype]
            set inchannel [open $infile]
            while {[gets $inchannel line] >= 0} {
              if { $line != "" } {
                puts $mapfile $line
                if { [lsearch $MapMergeChs $accessChannel] >= 0 } { # add to merge map list if channel on the list
                  lappend mapList $line
                }
              }
            };
            close $inchannel
            close $mapfile
          }
          puts "mmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmm"
          # ----------------------------
          # remove duplicates from common list with condition, remove from sorted list using indexes
          set newMapList {}
          set mapListSort [lsort $mapList]
          set idx 0
          while { $idx < [llength $mapListSort] } {
            set currR     [lindex $mapListSort $idx]
            set currRName [lindex $currR 0]
            set currRSize [lindex $currR 3]
            set currRCh   [lindex $currR 4]
            set nextIdx   [expr $idx+1]
            set nextR     [lindex $mapListSort $nextIdx]
            set nextRName [lindex $nextR 0]
            set nextRSize [lindex $nextR 3]
            set nextRCh   [lindex $nextR 4]

            if { $currRName == $nextRName } { # duplicate
              # higher channel has prio if size > 512 - arbitrary number - make configurable if needed
              if { ($currRCh < $nextRCh && $currRSize > $MapMergeThr) || ($currRCh > $nextRCh && $currRSize < $MapMergeThr) } {
                # remove current
                set mapListSort [lreplace $mapListSort $idx $idx]
              } else {
                # remove next
                set mapListSort [lreplace $mapListSort $nextIdx $nextIdx]
              }
            } else {            # no more duplicates
              incr idx
            }
          }
          # after duplicates removal sort back based on address
          set mapListSort [lsort -index 4 -integer [lsort -index 2 -integer $mapListSort]]
          foreach line $mapListSort {
            puts $mergedMapfile $line
          }
          close $mergedMapfile
        }
      }
      vhdl {
        # ::fwfwk::addr::runDesyRdl vhdl
      }
      h {
        # ::fwfwk::addr::runDesyRdl h
        # copy h per access channel
        foreach accessChannel [dict keys $::fwfwk::RdlFiles] {
          set tmpHPath [file join $ArtifactsPath h]
          set fileName [file join $::fwfwk::ProjectPath/out/${::fwfwk::PrjBuildName} ${::fwfwk::PrjBuildName}_${::fwfwk::VerString}_ch${accessChannel}.h]
          set hfile [open $fileName w]
          set infile [file join $tmpHPath desyrdl_ch${accessChannel}.h]
          set inchannel [open $infile]
          while {[gets $inchannel line] >= 0} {
            puts $hfile $line
            if { $line == "#define __desyrdl_ch${accessChannel}__H__" } {
              puts $hfile "#define DESYRDL_CH${accessChannel}_VERSION_STRING \"${::fwfwk::VerString}\""
              puts $hfile "#define DESYRDL_CH${accessChannel}_VERSION [format 0x%08x ${::fwfwk::Ver}]"
              puts $hfile "#define DESYRDL_CH${accessChannel}_SHASUM  [format 0x%08x ${::fwfwk::VerShasum}]"
            }
          }
          close $inchannel
          close $hfile
        }
      }
      adoc {
        # ::fwfwk::addr::runDesyRdl adoc
      }
      default {
        puts  "Generate only RDL files"
        # puts "# WARNING: Not supported option ::fwfwk::addr::main $args"
        # ::fwfwk::exit -7
      }
    }
  }
}

# ==============================================================================
# ------------------------------------------------------------------------------
proc ::fwfwk::addr::addAddrSrc {} {
  variable ArtifactsPath
  variable TypesToAdd

  dict for {accessChannel nodes} $::fwfwk::AddressSpaceChDict {
    switch $TypesToAdd {
      vhdl {
        puts "Adding address space $TypesToAdd files to project"
        if { $::fwfwk::ModuleOwnLib == 1 } {
          ::fwfwk::addSrcModule ::fwfwk::src desyrdlch${accessChannel} $ArtifactsPath/tcl/fwk_desyrdl_multi_lib_ch${accessChannel}.tcl
        } else {
          ::fwfwk::addSrcModule ::fwfwk::src desyrdlch${accessChannel} $ArtifactsPath/tcl/fwk_desyrdl_one_lib_ch${accessChannel}.tcl
        }
      }
    }
  }

}

# ==============================================================================
# ------------------------------------------------------------------------------
proc ::fwfwk::addr::getParentName {idx Separator} {

  set ParentID   $::fwfwk::AddressSpace($idx,Parent)
  if { $ParentID > 0} {
    set NewParentName [::fwfwk::addr::getParentName $ParentID $Separator]
    set ParentName $::fwfwk::AddressSpace($ParentID,Name)
    if {$::fwfwk::AddressSpace($ParentID,Type) != "PROJECT"} {
      if { $NewParentName == "" } {
        set ParentName "$ParentName"
      } else {
        set ParentName "$NewParentName$Separator$ParentName"
      }
      return $ParentName
    } else {
      return ""
    }
  } else {
    return ""
  }

}

# ==============================================================================
# ------------------------------------------------------------------------------
proc ::fwfwk::addr::genAddrTree {} {
  puts "----------------------------------------------------"
  puts "Address Space Tree:"
  # create Depth key
  set ::fwfwk::AddressSpace(0,Depth) 0
  for {set idx 1} {$idx <= $::fwfwk::AddressSpace(0,ID)} {incr idx} {
    set ::fwfwk::AddressSpace($idx,Depth) 0
  }
  # sort array
  foreach {key value} [array get ::fwfwk::AddressSpace] {
    set curId  [lindex [split $key ,] 0]
    set curKey [lindex [split $key ,] 1]
    lappend la [list  $curId $curKey $value]
  }
  set las [lsort -integer -index 0  $la]
  # calculate depth for each node
  foreach ele $las {
    set curId  [lindex  $ele 0]
    set curKey [lindex  $ele 1]
    # puts "$curId,$curKey: $::fwfwk::AddressSpace($curId,$curKey)"
    if { $curKey == "Parent" } {
      set parentId $::fwfwk::AddressSpace($curId,Parent)
      set parentDepth $::fwfwk::AddressSpace($parentId,Depth)
      set curDepth [expr {$parentDepth +1}]
      set ::fwfwk::AddressSpace($curId,Depth) $curDepth
    }
  }
  # make sure each node has an access channel
  set ::fwfwk::AddressSpace(0,AccessChannel) 0
  set ::fwfwk::AddressSpace(1,AccessChannel) 0
  # print tree
  foreach ele $las {
    set curId  [lindex  $ele 0]; # 
    set curKey [lindex  $ele 1]
    #puts "$curId,$curKey: $::fwfwk::AddressSpace($curId,$curKey)"
    if { $curKey == "Name" } {
      set curDepth [ expr {$::fwfwk::AddressSpace($curId,Depth) *2}]
      set curName $::fwfwk::AddressSpace($curId,Name)
      set curIdentifier $::fwfwk::AddressSpace($curId,Id)
      set curAddr [format "0x%08x" $::fwfwk::AddressSpace($curId,BaseAddress)]
      set curRange [format "0x%08x" $::fwfwk::AddressSpace($curId,AddressRange)]
      set curCH $::fwfwk::AddressSpace($curId,AccessChannel)
      set curNum $::fwfwk::AddressSpace($curId,Num)
      set curAddrDepth [expr {20-$curDepth}]
      set name "${curIdentifier}\[$curNum\] (${curName})"
      #puts "$::fwfwk::AddressSpace($curId,Parent) -> $::fwfwk::AddressSpace($curId,Depth) -> $curId [lindex $ele 1]"
      puts [format "%*s- %-*s %*s %*s %s" ${curDepth} "+-"  46 ${name} ${curAddrDepth} ${curAddr} 18 ${curRange} ${curCH}]
    }
  }
}

# ==============================================================================
# ------------------------------------------------------------------------------
proc ::fwfwk::addr::genAddrDict {} {

  if {$::fwfwk::AddressSpace(0,ID) < 2} {return}; # empty list, just top node and project

  # puts "----------------------------------------------------"
  # puts " Converting AddressSpace array to a dict and splitting it by AccessChannel"
  # puts "----------------------------------------------------"

  # sort array
  foreach {key value} [array get ::fwfwk::AddressSpace] {
    set curId  [lindex [split $key ,] 0]
    set curKey [lindex [split $key ,] 1]
    lappend la [list  $curId $curKey $value]
  }
  set las [lsort -integer -index 0  $la]

  # make this a nested dict without INIT (curId==0) and PROJECT (curId==1):
  foreach ele $las {
    set curId  [lindex  $ele 0]
    set curKey [lindex  $ele 1]
    set curVal [lindex  $ele 2]
    # create a nested dict
    # the key-value pair is curId and [dict create $curKey $curVal]
    if { $curId > 1 } {
      # puts "$curId $curKey $curVal"
      dict set ::fwfwk::AddressSpaceDict $curId $curKey $curVal
    }
  }

  dict for {id content} $::fwfwk::AddressSpaceDict {
    set curParent           [dict get $content Parent]
    set curAccessChannel    [decodeAccessChannel [dict get $content AccessChannel]]
    set AccessChannelExists [dict exists $::fwfwk::AddressSpaceChDict $curAccessChannel]

    # puts "$id $content"
    # If the parent was PROJECT then we shouldn't compare the access channels,
    # the node is at the top now and will get a new parent later on.
    if {$curParent == 1} {
      set AccessChannelsEqual 0
    } else {
      set parentAccessChannel [decodeAccessChannel [dict get $::fwfwk::AddressSpaceDict $curParent AccessChannel]]
      set AccessChannelsEqual [expr {$curAccessChannel eq $parentAccessChannel}]
    }

    # add this node to the corresponding access channel
    dict set AccessChannels $curAccessChannel $id $content

    # if the direct parent had a different access channel, move it directly under top
    if [expr {!$AccessChannelsEqual}] {
     dict set AccessChannels $curAccessChannel $id Parent 1
    }
  }

  # give each access channel a new top
  foreach ch [dict keys $AccessChannels] {
    # set NodesInChannel [dict size [dict get $AccessChannels $ch]]
    dict set AccessChannels $ch 1 Name ch${ch}_top
    dict set AccessChannels $ch 1 AccessChannel ${ch}
    dict set AccessChannels $ch 1 Type TOP
    dict set AccessChannels $ch 1 BaseAddress 0
    dict set AccessChannels $ch 1 Num ""
    dict set AccessChannels $ch 1 Parent 0 ; # make it easier to iterate over the dict
    dict set AccessChannels $ch 1 Arg ""
    dict set AccessChannels $ch 1 Depth ""
    dict set AccessChannels $ch 1 Id ""
    dict set AccessChannels $ch 1 Config ""
  }

  # the top is at the end now, so sort each channel by ID again
  dict for {ch nodes} $AccessChannels {
    foreach node [lsort -integer [dict keys $nodes]] {
      dict set ::fwfwk::AddressSpaceChDict $ch $node [dict get $nodes $node]
    }
  }
}

# ==============================================================================
# ------------------------------------------------------------------------------
proc ::fwfwk::addr::genRdlFiles {} {
  variable ArtifactsPath
  puts "----------------------------------------------------"
  puts "Generating Rdl files:"

  if {![file exists $::fwfwk::PrjBuildPath/${::fwfwk::PrjBuildName}.desyrdl/rdl]} { file mkdir $::fwfwk::PrjBuildPath/${::fwfwk::PrjBuildName}.desyrdl/rdl }

  ::fwfwk::utils::cleanDir $::fwfwk::PrjBuildPath/${::fwfwk::PrjBuildName}.desyrdl/rdl; # clean out type

  dict for {accessChannel nodes} $::fwfwk::AddressSpaceChDict {
    foreach nodeId [dict keys $nodes] {

      puts "Parsing $nodeId: [dict get $nodes $nodeId Name] :\
                \[[dict get $nodes $nodeId Num]\] \
                [dict get $nodes $nodeId Type]:\
                @[dict get $nodes $nodeId BaseAddress]"

      set fileNameRdl [file join $::fwfwk::PrjBuildPath ${::fwfwk::PrjBuildName}.desyrdl rdl \
                         ch${accessChannel}_[dict get $nodes $nodeId Name].rdl]
      #                           ${::fwfwk::PrjBuildName}_$::fwfwk::AddressSpace($idx,AccessChannel).rdl]
      set fileNameVH  [file join $::fwfwk::PrjBuildPath ${::fwfwk::PrjBuildName}.desyrdl rdl \
                         [dict get $nodes $nodeId Name].vh]

      set cfgVariables [dict get $nodes $nodeId Config]
      if {[llength $cfgVariables] > 0} {
        genVHFromConfig $cfgVariables $fileNameVH
      } else { # create dummy file if no configuration provided
        set tmpFile [open $fileNameVH w]
        close $tmpFile
      }

      switch [dict get $nodes $nodeId Type] {
        RDL {
          file copy -force [file normalize [dict get $nodes $nodeId Arg]] $fileNameRdl
        }
        IBUS {
          set rdlFileHandle [open $fileNameRdl w]
          ::fwfwk::addr::genRdlFromIIFile \
            $accessChannel \
            $nodes \
            $nodeId \
            $rdlFileHandle
          close $rdlFileHandle
        }
        TOP {
          set rdlFileHandle [open $fileNameRdl w]
          ::fwfwk::addr::genRdlFromParent \
            $accessChannel \
            $nodes \
            $nodeId \
            $rdlFileHandle \
            false
          close $rdlFileHandle
        }
        NODE {
          set rdlFileHandle [open $fileNameRdl w]
          ::fwfwk::addr::genRdlNode \
            $accessChannel \
            $nodes \
            $nodeId \
            $rdlFileHandle \
            false
          close $rdlFileHandle
        }
        IPX {
          set rdlFileHandle [open $fileNameRdl w]
          ::fwfwk::addr::genRdlFromIPX \
            $accessChannel \
            $nodes \
            $nodeId \
            $rdlFileHandle \
            false
          close $rdlFileHandle
        }
        INTERCONNECT {
          set rdlFileHandle [open $fileNameRdl w]
          ::fwfwk::addr::genRdlFromParent \
            $accessChannel \
            $nodes \
            $nodeId \
            $rdlFileHandle \
            true
          close $rdlFileHandle
        }
        default {::fwfwk::printError "Node $nodeId not handled by DesyRDL"; ::fwfwk::exit -2;}
      }

      # add .rdl file to a dict, one dict per access channel.
      # key: nodeId, value: filename
      dict set ::fwfwk::RdlFiles $accessChannel $nodeId $fileNameRdl
    }
  }
  puts "\nList of .rdl files in project:"
  dict for {accessChannel files} $::fwfwk::RdlFiles {
    puts "  access channel $accessChannel:"
    dict for {nodeId filename} $files {
      set filename [string replace $filename 0 [expr {[string length ${::fwfwk::ProjectPath}/]-1}]]
      puts "    nodeId = $nodeId, parent = [dict get $::fwfwk::AddressSpaceChDict $accessChannel $nodeId Parent], filename = $filename"
    }
  }
  puts "----------------------------------------------------"
}
# ==============================================================================
# ------------------------------------------------------------------------------
proc ::fwfwk::addr::genRdlNode {AccessChannel Nodes Idx RdlFile GenHdl} {
  # generates empty node with just a memory entry
  set ModuleName [dict get $Nodes $Idx Name]

  set words [expr {([dict get $Nodes $Idx AddressRange] + 1) / 4}]
  puts $RdlFile "\naddrmap $ModuleName \{"
  puts $RdlFile "  desyrdl_generate_hdl = false ;"
  puts $RdlFile "  desyrdl_access_channel = $AccessChannel ;"

  puts $RdlFile  "  external mem \{"
  puts $RdlFile  "    mementries        = $words ;"
  puts $RdlFile  "    memwidth          = 32 ;"
  puts $RdlFile  "  \} $ModuleName;"

  puts $RdlFile "\} ;"

}
# ==============================================================================
# ------------------------------------------------------------------------------
proc ::fwfwk::addr::genRdlFromParent {AccessChannel Nodes Idx RdlFile GenHdl} {

  set ModuleName [dict get $Nodes $Idx Name]
  # count items under root parent channel,
  # use bridge only if > 1
  set NodesUnderParent 0
  dict for {id content} $Nodes {
    if {[dict get $content Parent] == $Idx} {
      set NodesUnderParent [expr {$NodesUnderParent+1}]
    }
  }

  puts $RdlFile "\naddrmap $ModuleName \{"
  puts $RdlFile "  desyrdl_generate_hdl = $GenHdl ;"
  puts $RdlFile "  desyrdl_access_channel = $AccessChannel ;"
  puts $RdlFile "  desyrdl_interface = \"AXI4L\" ;"
  if {$NodesUnderParent > 1 && $Idx == 1 } {
    puts $RdlFile "  bridge;"
  }
  # TODO add a configuration value or so for the interface

  dict for {id content} $Nodes {
    if {[dict get $content Parent] == $Idx} {
      set properties ""
      # set Config [dict get $content Config]
      # if { $Config != ""} {
      #   foreach {prop val} $Config {
      #     if { ![string is double -strict $val]} { set val "\"$val\""}; # put non numbers in double quote
      #     if { $properties == ""} { set properties ".${prop}($val)"
      #     } else { set properties "$properties,.${prop}($val)" }
      #   }
      #   set properties "#($properties)"
      # }

      set num [dict get $content Num]
      set identifier [dict get $content Id]

      # Instances within the generated RDL must be relative to the parent.
      set ParentAddress [dict get $::fwfwk::AddressSpaceChDict $AccessChannel $Idx BaseAddress]
      set RelAddress [expr {[dict get $content BaseAddress] - $ParentAddress}]
      set stride [expr {[dict get $content AddressRange] + 1}]

      if { $num == "" } {
        puts $RdlFile "  [dict get $content Name] $properties $identifier @$RelAddress;"
        # puts $RdlFile "  external mem {} channel_high_address @$stride;"

      } else {
        puts $RdlFile "  [dict get $content Name] $properties $identifier \[$num\] @$RelAddress += $stride;"
      }
      #if { $NodesUnderParent > 1 && $Idx == 1 } {

      #}
    }
  }

  puts $RdlFile "\} ;"

}

# ==============================================================================
# ------------------------------------------------------------------------------
proc ::fwfwk::addr::genRdlFromIIFile {AccessChannel Nodes Idx RdlFile} {
  set ModuleName  [dict get $Nodes $Idx Name]
  set BaseAddress [dict get $Nodes $Idx BaseAddress]
  set AddressFile [dict get $Nodes $Idx Arg]
  set Config   [dict get $Nodes $Idx Config]

  set regs [parseIIFile $BaseAddress $AddressFile $Config $AccessChannel]

  puts $RdlFile "addrmap $ModuleName \{"
  puts $RdlFile "  desyrdl_generate_hdl = false ;"
  puts $RdlFile "  desyrdl_access_channel = $AccessChannel ;"
  puts $RdlFile "  desyrdl_interface  = \"IBUS\" ;"

  # find nodes with this node as parent, instantiate them
  dict for {id content} $Nodes {
    # Instances within the generated RDL must be relative to the parent.
    set ParentAddress [dict get $::fwfwk::AddressSpaceChDict $AccessChannel $Idx BaseAddress]
    set RelAddress [expr {[dict get $content BaseAddress] - $ParentAddress}]

    if {[dict get $content Parent] == $Idx} {
      set num [dict get $content Num]
      set identifier [dict get $content Id]
      if { $num == "" } {
        puts $RdlFile "  [dict get $content Name] $identifier @${RelAddress};"
      } else {
        set stride [expr {[dict get $content AddressRange] + 1}]
        puts $RdlFile "  [dict get $content Name] $identifier \[$num\] @${RelAddress} += $stride;"
      }
    }
  }

  foreach reg  $regs {
    set type       [lindex $reg 0]
    set name       [lindex $reg 1]
    set size       [lindex $reg 2]
    set address    [lindex $reg 3]
    set realsize   [lindex $reg 4]
    set width      [lindex $reg 5]
    set fracbits   [lindex $reg 6]
    set signed     [lindex $reg 7]
    set swAccess   [lindex $reg 8]
    set hwAccess   [lindex $reg 9]

    # decode access mode
    if { $swAccess == "ro" } { set swAccess "r"}
    if { $swAccess == "wo" } { set swAccess "w"}
    if { $hwAccess == "ro" } { set hwAccess "r"}
    if { $hwAccess == "wo" } { set hwAccess "w"}

    if { ($hwAccess == "w" || $hwAccess == "rw") && ($swAccess == "w" || $swAccess == "rw")} {
      set we "true"
    } else { set we "false" }
    # decode data type to [u]<int|(fixed<N>)>
    # not covered by II files: char, float, double, half
    if { $fracbits > 0 } {
      set data_type "fixed$fracbits"
    } else {
      set data_type "int"
    }
    # pretend "u" if unsigned
    if { $signed  == 0 } { set data_type "u$data_type" }


    if { $type == "mem" } {
      puts $RdlFile  "  external mem \{"
      puts $RdlFile  "    mementries         = $size ;"
      puts $RdlFile  "    memwidth           = 32 ;"
      puts $RdlFile  "    sw                 = $swAccess ;"
      puts $RdlFile  "    desyrdl_data_type  = \"$data_type\" ;"
      puts $RdlFile  "    default desyrdl_data_type = \"$data_type\" ;"
      puts $RdlFile  "    default regwidth   = 32 ;"
      puts $RdlFile  "    default fieldwidth = $width ;"
      puts $RdlFile  "    reg \{"
      puts $RdlFile  "      desc = \"IBUS memory element\";"
      puts $RdlFile  "      field \{\} data ;"
      puts $RdlFile  "    \} VALUES\[$size\] ;"
      puts $RdlFile  "  \} $name @$address ;"
    } elseif { $type == "reg" } {
      puts $RdlFile  "  reg \{"
      puts $RdlFile  "    default sw        = $swAccess ;"
      puts $RdlFile  "    default hw        = $hwAccess ;"
      puts $RdlFile  "    default we        = $we ;"
      puts $RdlFile  "    desyrdl_data_type = \"$data_type\" ;"
      puts $RdlFile  "    field \{"
      puts $RdlFile  "    \} data\[$width\] ;"
      puts $RdlFile  "  \} $name\[$size\] @$address ;\n"
    } else {
      puts $RdlFile  " // external placed over tcl \"$name\[$size\] @$address \""
    }

  }

  puts $RdlFile "\} ;"

}

# ==============================================================================
# ------------------------------------------------------------------------------
proc ::fwfwk::addr::runDesyRdl {outType} {
  variable ArtifactsPath
  variable TypesToAdd

  set outPath [file join $ArtifactsPath]
  file mkdir $outPath
  ::fwfwk::utils::cleanDir $outPath/$outType; # clean out type
  puts "----------------------------------------------------"
  ::fwfwk::printInfo "DesyRdl generating $outType files in out path: "
  # variable ::fwfwk::src::DesyRdlSrc {}

  # run DesyRDL separately for each access channel
  dict for {accessChannel files} $::fwfwk::RdlFiles {
    puts "$outPath\n--DesyRdl--ch${accessChannel}>"

    set RdlFilenamesPerCh {}
    foreach nodeId [lsort -integer -decreasing [dict keys $files]] {
      set rdlFile [dict get $files $nodeId]
      # append to the list only if file does not exist
      if { [lsearch $RdlFilenamesPerCh $rdlFile] == -1 } {
        lappend RdlFilenamesPerCh $rdlFile
      }
    }

    # The Tcl interpreter might set these environment variables, causing
    # problems when running our own Python program below. A specific example is
    # Vivado <2020.2 which bundles Python 2.7 while Vivado 2020.2 bundles
    # Python 3.8.
    array set orig_env [array get ::env "PYTHON*"]
    array unset ::env "PYTHON*"

    set cmdToRun "desyrdl -o $outPath -i $RdlFilenamesPerCh -f $outType tcl"
    # puts [exec bash -c $cmdToRun]
    # -----------------------------------------------------------------------------
    if { [catch { eval exec >&@stdout "$cmdToRun" } resulttext] } {
      ::fwfwk::printError "DesyRdl failed:"
      ::fwfwk::exit -2
    }

    set fp [open $ArtifactsPath/desyrdl.log "w"]
    puts $fp $resulttext
    close $fp

    array set ::env [array get orig_env]
  }
  puts "----------------------------------------------------"
}

# ==============================================================================
# ------------------------------------------------------------------------------
# parses II  file, calculates items addresses and eval variables
proc ::fwfwk::addr::parseIIFile {BaseAddress AddressFile Config AccessChannel} {

  set regs {}

  # variables passed as a list key value, convert to array for easier search
  array set ConfVars $Config

  set addrFile [ open [file normalize $AddressFile] r]

  # pars line by line
  while { [gets $addrFile line] >= 0 } {
    # set proper bar based on variable name
    # set match [regexp {VIIItemDeclList.*Bar(\d+)} $line match bar]
    # address for DMA description is in bytes: set bytes 1
    set bytes 4

    # search for II items
    set match [regexp {^\s*VII_(AREA|EXTB|WORD|BITS)} $line]
    if {1 == $match} {
      set reg     [split $line ","]
      set type    [string trim [lindex $reg 0]]
      set name    [string trim [lindex $reg 1]]
      set width   [string trim [lindex $reg 2]]
      set size    [string trim [lindex $reg 3]]
      set address [string trim [lindex $reg 6]]
      set signed  [string trim [lindex $reg 7]]
      set swAccess  [string trim [lindex $reg 4]]
      set hwAccess  [string trim [lindex $reg 5]]
      if {1 == [string match "VII_UNSIGNED*" $signed]} {
        set signed 0
      } else {
        set signed 1
      }

      if {1 == [string match "VII_WACCESS*" $swAccess]} {
        set swAccess "rw"
      } elseif {1 == [string match "VII_WNOACCESS*" $swAccess]} {
        set swAccess "ro"
      } elseif {1 == [string match "VII_RNOACCESS*" $swAccess]} {
        set swAccess "wo"
      } else {
        set swAccess "rw"
      }

      if {1 == [string match "VII_REXTERNAL*" $hwAccess] &&  $swAccess == "ro" } {
        set hwAccess "wo"
      } elseif {1 == [string match "VII_RINTERNAL*" $hwAccess]} {
        set hwAccess "ro"
      } elseif {1 == [string match "VII_REXTERNAL*" $hwAccess]} {
        set hwAccess "rw"
      } else {
        set hwAccess "rw"
      }

      if { $type == "VII_WORD" } {
        set type "reg"
      } elseif { $type == "VII_EXTB" } {
        set type "ext"
      } else { set type "mem" }

      set fracmatch [regexp {[-]{4}fracbits([-]*[a-zA-Z0-9_\*/\+]+)} $line -> fracbits]
      if {0 == $fracmatch} {
        set fracbits 0
      } else {
        set fraclist [split $fracbits "*/+"]
        foreach fracel $fraclist {
          if {0 == [regexp {^[-]*\d+$} $fracel]} {
            if {![info exists ConfVars($fracel)]} { puts "\n#ERROR: Cannot find $fracbits fracbits: $fracel variable for $name. Check config provided." ; ::fwfwk::exit -2;}
            regsub $fracel $fracbits $ConfVars($fracel) fracbits
          }
        }
        set fracbits [expr ($fracbits)]
      }

      # set width
      set widthlist [split $width "*/+-"]
      foreach widthel $widthlist {
        if {0 == [regexp {^\d+$} $widthel]} {
          if {![info exists ConfVars($widthel)]} { puts "\n#ERROR: Cannot find width: $widthel variable for $name. Check config provided." ; ::fwfwk::exit -2;}
          regsub $widthel $width $ConfVars($widthel) width
        }
      }
      set width [expr ($width)]

      # recalculate address
      set addlist [split $address "*/+-"]
      foreach addel $addlist {
        if {0 == [regexp {^\d+$} $addel]} {
          if {![info exists ConfVars($addel)]} { puts "\n#ERROR: Cannot find address: $addel variable for $name. Check config provided." ; ::fwfwk::exit -2;}
          regsub $addel $address $ConfVars($addel) address
        }
      }
      set address [expr  ($address) * $bytes]

      # recalculate realsize
      set sizelist [split $size "*/+-"]
      foreach sizeel $sizelist {
        if {0 == [regexp {^\d+$} $sizeel]} {
          if {![info exists ConfVars($sizeel)]} { puts "\n#ERROR: Cannot find $widthel variable for $name. Check config provided." ; ::fwfwk::exit -2;}
          regsub $sizeel $size $ConfVars($sizeel) size
        }
      }
      set realsize [expr ($size)*$bytes]
      # workaround for DMA constants
      # set size [expr $size / $sizediv]
      if { $size == 0 } { set size 1}
      set spaces [expr {50-[string length $name]}]
      #set cnt $modulecount($prefix)
      set reg [concat ${type} ${name} ${size} ${address} ${realsize} ${width} ${fracbits} ${signed} ${swAccess} ${hwAccess}]
      lappend regs $reg
    }
  }
  close $addrFile

  return $regs
}
# ==============================================================================
# ------------------------------------------------------------------------------
proc ::fwfwk::addr::genRdlFromIPX {AccessChannel Nodes Idx RdlFile GenHdl} {
    # generates empty node with just a memory entry
    set ModuleName  [dict get $Nodes $Idx Name]
    set BaseAddress [dict get $Nodes $Idx BaseAddress]
    set IPComponent [dict get $Nodes $Idx Arg]
    set Config   [dict get $Nodes $Idx Config]
    set AddressRange [dict get $Nodes $Idx AddressRange]

    puts $RdlFile "\naddrmap $ModuleName \{"
    puts $RdlFile "  desyrdl_generate_hdl = false ;"
    puts $RdlFile "  desyrdl_access_channel = $AccessChannel ;"
    puts $RdlFile "  desyrdl_interface = \"AXI4L\" ;"

     if {![namespace exists ::ipx] } {
       ::fwfwk::printWarning "Not in Vivado: cannot generate address space for $IPComponent. Placing generig MEM regin in $IPComponent."
       puts $RdlFile  "  external mem \{"
       puts $RdlFile  "    mementries        = [expr {($AddressRange + 1) / 4}] ;"
       puts $RdlFile  "    memwidth          = 32 ;"
       puts $RdlFile  "  \} MEM ;"
       puts $RdlFile "\} ;"
       return -1
     }

    if { [file exists $IPComponent] } {
      puts "Found IP ${IPComponent} file, using as IPX file"
      ipx::open_ipxact_file $IPComponent
    } else {
      set componentXml [::fwfwk::utils::findFiles $::fwfwk::PrjBuildPath ${IPComponent}.xml]
      if { [llength $componentXml] > 1 } { # pick fist on list if found multiple xmls
        ::fwfwk::printWarning "Found multiple IP xml files. $componentXml. Using first from the list."
        set componentXml [lindex $componentXml 0]
      }
      if { [file exists $componentXml] } {
        ::fwfwk::printInfo "IP: found ${IPComponent}.xml, using as IPX file: ${componentXml}"
        ipx::open_ipxact_file $componentXml
      } else {
        ::fwfwk::printWarning "Cannot find IP xml file: $IPComponent. Placing generig MEM region in $IPComponent."
        puts $RdlFile  "  external mem \{"
        puts $RdlFile  "    mementries        = [expr {($AddressRange + 1) / 4}] ;"
        puts $RdlFile  "    memwidth          = 32 ;"
        puts $RdlFile  "  \} MEM ;"
        puts $RdlFile "\} ;"
        return
      }
    }

    set regs [ipx::get_registers -of_object [ipx::get_address_blocks * -of_objects [ipx::get_memory_maps * -of_objects [ipx::current_core]]]]
    set regsNum [llength $regs]
    if { $regsNum == 0 } {
      ::fwfwk::printWarning "IP $IPComponent has no registers. Placing generig MEM region based on Tcl entry."
      puts $RdlFile  "  external mem \{"
      puts $RdlFile  "    mementries        = [expr {($AddressRange + 1) / 4}] ;"
      puts $RdlFile  "    memwidth          = 32 ;"
      puts $RdlFile  "  \} MEM ;"
      puts $RdlFile "\} ;"
      return
    } else {
      ::fwfwk::printInfo "Found $regsNum registers in ${IPComponent}.xml"
    }

    foreach reg $regs {
      #report_property -all $reg
      set regName [get_property NAME $reg]
      set regDesc [get_property DESCRIPTION $reg]
      set regDispName [get_property DISPLAY_NAME $reg]
      set regAddr [get_property ADDRESS_OFFSET $reg]
      set regAcc  [get_property ACCESS $reg]
      set regSize [get_property SIZE $reg]
      set name [string toupper $regName]
      # replace all strange chars to _
      regsub -all {\s+|[-+,.;%$#@!()\[\]]+} $name "_" name

      switch $regAcc {
        "read-only" {
          set rwAccess r
        }
        "read-write" {
          set rwAccess rw
        }
        "write-only" {
          set rwAccess w
        }
        default {
          set rwAccess rw
        }
      }

      puts $RdlFile  "  reg \{"
      puts $RdlFile  "    name = \"$regDispName\" ;"
      puts $RdlFile  "    desc = \"$regDesc\" ;"
      puts $RdlFile  "    default sw = $rwAccess ;"
      puts $RdlFile  "    default hw = r ;"
      puts $RdlFile  "    field \{"
      puts $RdlFile  "    \} data\[$regSize\] ;"
      puts $RdlFile  "  \} $name @$regAddr ;\n"
  }

  #  ipx::open_ipxact_file [get_property XML_FILE_NAME [get_ipdefs $ipDef]]
  #  puts [ipx::get_registers -of_object [ipx::get_address_blocks * -of_objects [ipx::get_memory_maps * -of_objects [ipx::open_core $componentXml]]]]
  ipx::unload_core
  # pars line by line
  puts $RdlFile "\} ;"

}
# ==============================================================================
# ------------------------------------------------------------------------------
proc ::fwfwk::addr::genMapFromIPX {ParentName ModuleName BaseAddress IPComponent Config AccessChannel MapFile args} {

  set UseParent [lindex $args 0]
  set Separator [lindex $args 1]

  # variables passed as a list key value, convert to array for easier search
  array set ConfVars $Config

  set fracbits 0
  set signed 0
  set width 32

  if {![namespace exists ::ipx] } {
    ::fwfwk::printWarning "Not in Vivado: cannot generate address space for $IPComponent "
    return -1
  }

  if { [file exists $IPComponent] } {
    puts "Found IP ${IPComponent} file, using as IPX file"
    ipx::open_ipxact_file $IPComponent
  } else {
    set componentXml [::fwfwk::utils::findFiles $::fwfwk::PrjPath ${IPComponent}.xml]
    if { [file exists $componentXml] } {
      puts "Found IP ${IPComponent}.xml file, using as IPX file"
      ipx::open_ipxact_file $componentXml
    } else {
      ::fwfwk::printError "Cannot find IP xml file: $IPComponent "
      return -1
    }
  }

  set regs [ipx::get_registers -of_object [ipx::get_address_blocks * -of_objects [ipx::get_memory_maps * -of_objects [ipx::current_core]]]]

  foreach reg $regs {
    #report_property -all $reg
    set name [get_property NAME $reg]
    set regAddr [get_property ADDRESS_OFFSET $reg]
    set regAcc  [get_property ACCESS $reg]
    set regSize [get_property SIZE $reg]

    set address [expr {$regAddr + $BaseAddress}]
    set size    $regSize
    set realsize  [expr  {4 * $regSize}]

    switch $regAcc {
      "read-only" {
        set rwAccess RO
      }
      "read-write" {
        set rwAccess RW
      }
      "write-only" {
        set rwAccess WO
      }
      default {
        set rwAccess RW
      }
    }

    if { $UseParent == 0  } {
      set putline "${ModuleName}${Separator}${name}"
    } else {
      set putline "${ParentName}${Separator}${ModuleName}${Separator}${name}"
    }

    set  putline [format "%-*s %*s %*s %*s %*s %*s %*s %*s %*s" 60 ${putline} 10 ${size} 12 ${address} 12 ${realsize} 6 ${AccessChannel} 6 ${width} 6 ${fracbits} 4 ${signed} 4 ${rwAccess}]
    puts $MapFile $putline

  }
  #  ipx::open_ipxact_file [get_property XML_FILE_NAME [get_ipdefs $ipDef]]
  #  puts [ipx::get_registers -of_object [ipx::get_address_blocks * -of_objects [ipx::get_memory_maps * -of_objects [ipx::open_core $componentXml]]]]
  ipx::unload_core
  # pars line by line

}
# ==============================================================================
# ------------------------------------------------------------------------------
proc ::fwfwk::addr::genVHFromConfig {Config fileName} {
  # we want to align variables in the config file below, so first
  # obtain the maximum length of a config variable name
  set maxlen 0
  dict for {key value} $Config {
    set len [string length $key]
    if {$len > $maxlen} {
      set maxlen $len
    }
  }

  set fileHandle [open [file normalize $fileName] w]
  puts "Writing configuration constants to $fileName"
  dict for {key value} $Config {
    # - for left-justified
    # * to take the width from an arg (here: $maxlen)
    # s for no conversion, just a string
    set match [regexp {^D_.*} $key totalmatch]
    if {![string is double -strict $value] && $match==0} { set value "\"$value\""}; # put stings in double quote
    set line [format "`define %-*s %s" $maxlen $key $value]
    puts $fileHandle $line
  }
  close $fileHandle
}

# ==============================================================================
# ------------------------------------------------------------------------------
proc ::fwfwk::addr::decodeAccessChannel {channelname} {
  set mode ""
  set match [regexp {([A-D]*)([0-9]+)} $channelname val mode ch]
#  set match [regexp {([A-D]*)([0-9]+)} $::fwfwk::AddressSpace($idx,AccessChannel) val mode ch]
  if { $mode == "D" } {
    set accessChannel [expr {13 + $ch}]
  } elseif { $mode != "" } {
    set accessChannel $ch
  } else {
    set accessChannel 0
  }

  return $accessChannel
}
