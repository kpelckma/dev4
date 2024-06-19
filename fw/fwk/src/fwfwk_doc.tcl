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
# @date 2022-01-09
# @author Lukasz Butkowski <lukasz.butkowski@desy.de>
# --------------------------------------------------------------------------- #
# @brief
# Part of DESY FPGA Firmware Framework (fwk)
# FPGA firmware framework script handling documentation generation
# --------------------------------------------------------------------------- #

namespace eval ::fwfwk::doc {
}

# ==============================================================================
# ------------------------------------------------------------------------------
proc ::fwfwk::doc::main {args} {

  set docTypes [lindex $args 0]

  # check if project do is properly initialized and create initial files if needed
  ::fwfwk::doc::initPrjDoc

  foreach type $docTypes {
    puts "type: $type"
    switch $type {
      antora {
        ::fwfwk::doc::genAntoraPlaybook
        ::fwfwk::doc::genAntora
      }
      pdf {
        ::fwfwk::doc::genPdf
      }
      adoc {
        ::fwfwk::addr::main {adoc}
        ::fwfwk::doc::genAdocReg
      }
      default {
        puts "No doc type specyfied"
      }
    }

  }
}
proc ::fwfwk::doc::initPrjDoc {} {

  if {![file exists ${::fwfwk::ProjectPath}/doc/antora.yml]} {
    set fileH [open ${::fwfwk::ProjectPath}/doc/antora.yml w]
    puts $fileH "name: ${::fwfwk::ProjectName}"
    puts $fileH "title: ${::fwfwk::ProjectName}"
    puts $fileH "version: ~"
    puts $fileH "start_page: index.adoc"
    close $fileH
  }
  if {![file exists ${::fwfwk::ProjectPath}/doc/modules/ROOT/pages]} { file mkdir ${::fwfwk::ProjectPath}/doc/modules/ROOT/pages}

  if {![file exists ${::fwfwk::ProjectPath}/doc/modules/ROOT/pages/index.adoc]} {
    set fileH [open ${::fwfwk::ProjectPath}/doc/modules/ROOT/pages/index.adoc w]
    puts $fileH "= Project ${::fwfwk::ProjectName} documentation"
    close $fileH
  }
  if {![file exists ${::fwfwk::ProjectPath}/doc/main.adoc]} {
    set fileH [open ${::fwfwk::ProjectPath}/doc/main.adoc w]
    puts $fileH "include::modules/ROOT/pages/index.adoc[]"
    close $fileH
  }

}

# ------------------------------------------------------------------------------
proc ::fwfwk::doc::genPdf {args} {
  puts "\n----------------------------------------"
  ::fwfwk::printInfo "Generating PDF using asciidoctor-pdf:"
  set mainAdocFile ${::fwfwk::ProjectPath}/doc/main.adoc
  set cmdToRun \
    [list \
       asciidoctor-pdf \
       -r asciidoctor-diagram \
       -r asciidoctor-mathematical \
       -a mathematical-format=svg \
       -a pdf-themesdir=${::fwfwk::ProjectPath}/fwk/tpl/doc \
       -a pdf-theme=fwk \
       -o ${::fwfwk::ProjectPath}/out/${::fwfwk::ProjectName}_${::fwfwk::ProjectConf}.pdf \
       $mainAdocFile \
       -a toc \
       -a stem \
       -a toclevels=4 \
       -a sectnums \
       -a text-align=justify \
       -a icons=font \
       -a title-page \
       -a source-highlighter=rouge \
       -a rouge-style=base26.dark \
       -a ProjectName=${::fwfwk::ProjectName} \
       -a ProjectConf=${::fwfwk::ProjectConf} \
       -a ProjectVersion=${::fwfwk::VerString} \
       ]
  puts $cmdToRun
  puts ">>> "

  set dockerImageName "fwfwk/doc-asciidoctor"

  set user [exec id -u]
  set cmdToRunDocker \
    [list \
       docker run -u $user \
       -v ${::fwfwk::ProjectPath}:/${::fwfwk::ProjectPath} -w ${::fwfwk::ProjectPath} --rm \
       -t $dockerImageName ]

  set cmdToRunDocker [concat $cmdToRunDocker $cmdToRun]
  if { [::fwfwk::utils::existsDockerName $dockerImageName]} {
    ::fwfwk::printInfo "Found Docker image, generating pdf using $dockerImageName image:"
    if { [catch { eval exec $cmdToRunDocker >@stdout } resulttext] } { puts $resulttext }
  } else {
    if { [catch { eval exec $cmdToRun >@stdout } resulttext] } { puts $resulttext }
  }
  puts ">>>"
  puts "file://${::fwfwk::ProjectPath}/out/${::fwfwk::ProjectName}_${::fwfwk::ProjectConf}.pdf\n"
}

# ------------------------------------------------------------------------------
proc ::fwfwk::doc::genAntora {args} {
  puts "\n----------------------------------------"
  ::fwfwk::printInfo "Generating static HTML using Antora:"
  puts ">>> "
  set AntoraPlaybookFile ${::fwfwk::PrjBuildPath}/antora_playbook.yml

  set dockerImageName "fwfwk/doc-antora"
  set user [exec id -u]
  set cmdToRun \
    [list \
       antora --stacktrace  $AntoraPlaybookFile
      ]

  set cmdToRunDocker \
    [list \
       docker run -u $user \
       -v ${::fwfwk::ProjectPath}:/${::fwfwk::ProjectPath} -w ${::fwfwk::ProjectPath} --rm \
       -t $dockerImageName ]
  set cmdToRunDocker [concat $cmdToRunDocker $cmdToRun]

  if { [::fwfwk::utils::existsDockerName $dockerImageName]} {
    ::fwfwk::printInfo "Found Docker image, generating antora using $dockerImageName image:"
    if { [catch { eval exec $cmdToRunDocker >@stdout } resulttext] } { puts $resulttext }
  } else {
    if { [catch { eval exec $cmdToRun >@stdout } resulttext] } { puts $resulttext }
  }

}


# ------------------------------------------------------------------------------
proc ::fwfwk::doc::genAntoraPlaybook {} {

  set AntoraPlaybookFile ${::fwfwk::PrjBuildPath}/antora_playbook.yml
  set antoraPlaybook [open $AntoraPlaybookFile w]

  puts $antoraPlaybook "runtime:"
  puts $antoraPlaybook "  cache_dir: ${::fwfwk::PrjBuildPath}/.antoracache"
  puts $antoraPlaybook "site:"
  puts $antoraPlaybook "  title: ${::fwfwk::ProjectName}_${::fwfwk::ProjectConf} ${::fwfwk::VerString}"
  puts $antoraPlaybook "  url: /"
  puts $antoraPlaybook "  start_page: ${::fwfwk::ProjectName}::index.adoc"
  puts $antoraPlaybook "asciidoc:"
  puts $antoraPlaybook "  attributes:"
  puts $antoraPlaybook "    idprefix: ''"
  puts $antoraPlaybook "    idseparator: '-'"
  puts $antoraPlaybook "    linkattrs: ''"
  puts $antoraPlaybook "    toc: ~"
  puts $antoraPlaybook "    page-toclevels: 3@"
  puts $antoraPlaybook "    source-highlighter: ~" ;# enabled with supplemental UI, default has no VHDL, Tcl, etc.
  puts $antoraPlaybook "    kroki-fetch-diagram: true"
  puts $antoraPlaybook "    steam: '@'"
  puts $antoraPlaybook "    page-pagination: ''"
  puts $antoraPlaybook "    hide-uri-scheme: '@'"
  puts $antoraPlaybook "    icons: font"
  puts $antoraPlaybook "    xrefstyle: short"
  puts $antoraPlaybook "    ProjectName: ${::fwfwk::ProjectName}"
  puts $antoraPlaybook "    ProjectConf: ${::fwfwk::ProjectConf}"
  puts $antoraPlaybook "    ProjectVersion: ${::fwfwk::VerString}"
  puts $antoraPlaybook "  extensions:"
  puts $antoraPlaybook "    - asciidoctor-kroki"
  puts $antoraPlaybook "    - '@djencks/asciidoctor-mathjax'"
  puts $antoraPlaybook "antora:"
  puts $antoraPlaybook "  extensions:"
  puts $antoraPlaybook "    - '@antora/lunr-extension'"
  puts $antoraPlaybook "ui:"
  puts $antoraPlaybook "  bundle:"
  puts $antoraPlaybook "    url: https://gitlab.com/antora/antora-ui-default/-/jobs/artifacts/HEAD/raw/build/ui-bundle.zip?job=bundle-stable"
  puts $antoraPlaybook "    snapshot: true"
  puts $antoraPlaybook "  supplemental_files: ${::fwfwk::ProjectPath}/fwk/tpl/doc/antora_ui"
  puts $antoraPlaybook "output:"
  puts $antoraPlaybook "  dir: ${::fwfwk::ProjectPath}/out/${::fwfwk::ProjectName}_${::fwfwk::ProjectConf}/doc/html"
  puts $antoraPlaybook "content:"
  puts $antoraPlaybook "  sources:"
  puts $antoraPlaybook "    - url: ${::fwfwk::ProjectPath}"
  puts $antoraPlaybook "      start_path: doc"

  #set nl [::fwfwk::createNamespacesList ::fwfwk::src]
  set nl [::fwfwk::utils::listns ::fwfwk::src]
  set snl [lsort $nl]

  foreach module $snl {
    puts "Adding repo of $module"
    set modPath [subst $${module}::Path ]
    # if { [catch { set repoPath [eval exec "git -C $modPath rev-parse --show-toplevel"] } resulttext] } { puts $resulttext}
    # set repoPathLen [string length $repoPath]
    # set modPathLen [string length $modPath]
    # if { $modPathLen == $repoPathLen } { # module is a separate repo
    #   set start_path "doc"
    # } else {
    #   set start_path "[string range $modPath $repoPathLen+1 end]/doc"
    # }
    set repoPathLen [string length ${::fwfwk::ProjectPath}]
    set start_path "[string range $modPath [expr {$repoPathLen+1}] end]/doc"
    if {[file exists $modPath/doc/antora.yml]} {
      puts $antoraPlaybook "    - url: ${::fwfwk::ProjectPath}"
      puts $antoraPlaybook "      start_path: $start_path"
    }

  }

  close $antoraPlaybook

}


proc ::fwfwk::doc::genAdocReg {} {

  #
  set topFile [open $::fwfwk::addr::ArtifactsPath/adoc/addressmap.adoc w]
  puts $topFile "= Address Space"
  puts $topFile ":toc:"
  puts $topFile ":page-toclevels: 4"
  puts $topFile "\n\n"
  puts $topFile "== Tree"
  dict for {accessChannel nodes} $::fwfwk::AddressSpaceChDict {
    puts $topFile ".Address Tree $accessChannel "
    puts $topFile "\[plantuml, format=svg\]"
    puts $topFile "...."
    puts $topFile "@startmindmap"
    puts $topFile "skinparam monochrome true"
    puts $topFile "skinparam ranksep 20"
    puts $topFile "skinparam arrowThickness 0.7"
    puts $topFile "skinparam packageTitleAlignment left"
    puts $topFile "skinparam usecaseBorderThickness 0.4"
    puts $topFile "skinparam defaultFontSize 12"
    puts $topFile "skinparam rectangleBorderThickness 1"
    puts $topFile "* Access channel $accessChannel"
    foreach nodeId [dict keys $nodes] {
      set instanceName [dict get $nodes $nodeId Id]
      set name [dict get $nodes $nodeId Name]
      set depth [expr [dict get $nodes $nodeId Depth] + 0 ]
      if { $instanceName != "" } {
        puts $topFile "[string repeat * $depth] ${instanceName} ($name)"
      }
    }
    puts $topFile "@endmindmap"
    puts $topFile "...."
  }
  dict for {accessChannel nodes} $::fwfwk::AddressSpaceChDict {
    # puts $topFile "\nxref:ch_${accessChannel}_address_map.adoc\[Access channel $accessChannel\]\n"
    puts $topFile "\ninclude::ch_${accessChannel}_address_map.adoc\[Access channel $accessChannel,leveloffset=1\]\n"
    foreach nodeId [dict keys $nodes] {
    }
  }

  close $topFile

  dict for {accessChannel nodes} $::fwfwk::AddressSpaceChDict {
    set chFile [open $::fwfwk::addr::ArtifactsPath/adoc/ch_${accessChannel}_address_map.adoc w]
    puts $chFile "= Access channel $accessChannel\n"
    foreach nodeId [dict keys $nodes] {
      set instanceName [dict get $nodes $nodeId Id]
      set depth [expr [dict get $nodes $nodeId Depth] - 1 ]
      # set depth [dict get $nodes $nodeId Depth]
      # if virtual top do not palce in doc
      if { $instanceName != "" } {
        puts $chFile "include::addrmap_${instanceName}.adoc\[leveloffset=\+$depth]\n"
      }

    }
    close $chFile
  }
  if {![file exists $::fwfwk::ProjectPath/doc/modules/addressmap_$::fwfwk::ProjectConf/pages ]} {
    file mkdir $::fwfwk::ProjectPath/doc/modules/addressmap_$::fwfwk::ProjectConf/pages}
  file delete -force $::fwfwk::ProjectPath/doc/modules/addressmap_$::fwfwk::ProjectConf/pages
  file copy -force $::fwfwk::addr::ArtifactsPath/adoc/ $::fwfwk::ProjectPath/doc/modules/addressmap_$::fwfwk::ProjectConf/pages
}

