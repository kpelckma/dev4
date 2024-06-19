## -------------------------------------------------------------------------- #
#           ____  _____________  __                                           #
#          / __ \/ ____/ ___/\ \/ /                 _   _   _                 #
#         / / / / __/  \__ \  \  /                 / \ / \ / \                #
#        / /_/ / /___ ___/ /  / /               = ( M | S | K )=              #
#       /_____/_____//____/  /_/                   \_/ \_/ \_/                #
#                                                                             #
# --------------------------------------------------------------------------- #
# @copyright Copyright 2022 DESY
# SPDX-License-Identifier: Apache-2.0
# --------------------------------------------------------------------------- #
# @date 2022-04-27
# @author Seyed Nima Omidsajedi <nima.sajedi@desy.de>
# @author Lukasz Butkowski <lukasz.butkowski@desy.de>
# --------------------------------------------------------------------------- #
# @brief#
# Part of DESY FPGA Firmware Framework (fwk)
# contains procedures for Xilinx Vitis creation and build
# --------------------------------------------------------------------------- #

# ==============================================================================
proc testProject {} {
}

# ==============================================================================
proc cleanProject {} {
  # delete existing project files if existing
  set curFile "${::fwfwk::PrjBuildPath}"
  if { [ file exists $curFile ] } {
    file delete -force $curFile
  }
}

# ==============================================================================
proc createProject {} {
  variable ::fwfwk::HwFile
  #variable AppName
  ::fwfwk::printInfo "Create Project from fwfwk_vitis.tcl, createProject proc"
  ::fwfwk::printInfo "Create Vitis Platform"

  # check variables HW file
  if { ![info exists ::fwfwk::HwFile] } {
    ::fwfwk::printError "No ::fwfwk::HwFile defined. Please set env variable FWK_HW_FILE. e.g. export FWK_HW_FILE=top.xsa"; ::fwfwk::exit -2;}
  if { ![info exists ::fwfwk::CpuType] } {
    ::fwfwk::printError "No ::fwfwk::CpuType defined. Please set CpuType in cfg/config.cfg e.g. CpuType=psu_cortexa53_0";  ::fwfwk::exit -2; }
  if { ![info exists ::fwfwk::Arch] } {
    ::fwfwk::printError "No ::fwfwk::Arch defined. Please set Arch in cfg/config.cfg e.g. Arch=64-bit";  ::fwfwk::exit -2; }
  if { ![info exists ::fwfwk::OsType] } {
    ::fwfwk::printError "No ::fwfwk::OsType defined. Please set Arch in cfg/config.cfg e.g. OsType=standalone";  ::fwfwk::exit -2; }

  if { ![info exists ::fwfwk::AppName] } {
    ::fwfwk::printWarning "No ::fwfwk::AppName defined. Please set AppName in cfg/config.cfg e.g. AppName=AppName. Using project name"
    set ::fwfwk::AppName $::fwfwk::ProjectName
  }

  setws -switch ${::fwfwk::WorkspacePath}
  puts "----------------------------------------------------"
  ::fwfwk::printInfo "Workspace path : ${::fwfwk::WorkspacePath}"
  ::fwfwk::printInfo "Platform name  : ${::fwfwk::PlatformName}"
  ::fwfwk::printInfo "HW file: ${::fwfwk::HwFile}"
  puts "----------------------------------------------------"

  # get Vitis version
  set xsctVersion [lindex [version] 1]

  ::fwfwk::printInfo "Xilinx Vitis Version $xsctVersion is used"
  # --------------------------------------------------------
  # create platform
  ::fwfwk::printInfo "Creating Plarform..."
  if {[set result [catch {eval \
                            platform create \
                            -name ${::fwfwk::PlatformName} \
                            -hw   ${::fwfwk::HwFile} \
                            -proc ${::fwfwk::CpuType} \
                            -arch ${::fwfwk::Arch} \
                            -fsbl-target ${::fwfwk::CpuType}
  } resulttext]]} {
    puts ""
    ::fwfwk::printError "$resulttext"
    ::fwfwk::exit -2
  }

  platform write

  ::fwfwk::printInfo "Creating Domain..."
  domain create -name {app_domain} -os ${::fwfwk::OsType} -proc ${::fwfwk::CpuType}

  platform generate -domains
  platform active ${::fwfwk::PlatformName}

  domain active {app_domain}

  platform generate -quick

  # --------------------------------------------------------
  # creating application on a platform domain
  ::fwfwk::printCBM "\nCreate Vitis Aapplication"

  set targetDir "${::fwfwk::WorkspacePath}/${::fwfwk::AppName}/src"
  file mkdir ${::fwfwk::WorkspacePath}/${::fwfwk::AppName}

  if { [ file exists $targetDir ] } {
    file delete -force $targetDir
    ::fwfwk::printWarning "Vitis application: Overwrite to existing target directory"
  }

  file link -symbolic $targetDir ${::fwfwk::SrcPath}

  if { $xsctVersion < 2021.1 } {
    app create -name ${::fwfwk::AppName} -domain "app_domain" -template "Empty Application" -proc ${::fwfwk::CpuType}
  } else {
    app create -name ${::fwfwk::AppName} -domain "app_domain" -template "Empty Application(C)" -proc ${::fwfwk::CpuType}
  }

  # foreach header_path $::fwfwk::sw_src_dir {
  #   app config -name ${::fwfwk::AppName} include-path $header_path
  #   ::fwfwk::printInfo "Header dir: $header_path"
  # }
}


# ==============================================================================
proc openProject {} {
  setws -switch $::fwfwk::WorkspacePath

  if { ! [ file exists $::fwfwk::WorkspacePath ] } {
    ## project file isn't there, rebuild it.
    ::fwfwk::printError "Project ${::fwfwk::PrjBuildName} not found. Use create command to recreate it."
    ::fwfwk::exit -1
  }

  if { ![info exists ::fwfwk::AppName] } {
    ::fwfwk::printWarning "No ::fwfwk::AppName defined. Please set AppName in cfg/config.cfg e.g. AppName=AppName. Using project name"
    set ::fwfwk::AppName $::fwfwk::ProjectName
  }

}

# ==============================================================================
proc closeProject {} {
}

# ==============================================================================
proc saveProject {} {}

# ==============================================================================
proc addSources {args srcList} {
  foreach src $srcList {
    set path [lindex $src 0]
    set type [lindex $src 1]
    if { $type == "includes"} {
      app config -name ${::fwfwk::AppName} include-path $path
      ::fwfwk::printInfo "Includes dir added: $path"
    }
  }
}

# ==============================================================================
proc buildProject {args} {

  setws -switch ${::fwfwk::WorkspacePath}

  platform active ${::fwfwk::PlatformName}
  domain active {app_domain}

  if {[set result [catch {eval \
                            app build -name ${::fwfwk::AppName}
  } resulttext]]} {
    puts ""
    ::fwfwk::printError "$resulttext"
    ::fwfwk::exit -2
  }
  puts ""
  ::fwfwk::printCBM "== Report Application and its Domain =="

  set app_report [app report -name ${::fwfwk::AppName}]
  set domain_report [domain report -name app_domain]
  puts $app_report
  puts $domain_report
}

# ==============================================================================
proc exportOut {} {
  ::fwfwk::printInfo "Copy elf file of the project to artifacts out"
  puts "from:  ${::fwfwk::WorkspacePath}/${::fwfwk::AppName}/Debug/${::fwfwk::AppName}.elf"
  puts "to  :  $::fwfwk::ProjectPath/out/${::fwfwk::PrjBuildName}/${::fwfwk::AppName}.elf"

  if { [catch {file copy -force \
                 ${::fwfwk::WorkspacePath}/${::fwfwk::AppName}/Debug/${::fwfwk::AppName}.elf \
                 $::fwfwk::ProjectPath/out/${::fwfwk::PrjBuildName}/${::fwfwk::AppName}.elf} resulttext ] } {
    puts ""
    ::fwfwk::printError "$resulttext"
    ::fwfwk::printInfo "For more information check the project build log !"

    ::fwfwk::exit -2
  }
}
