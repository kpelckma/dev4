#!/usr/bin/env tclsh

# code based on Tcler's Wiki.
proc ESC {} {return \033}

proc ANSI {args} {
  # Support list and args conventions:
  if {[llength $args] == 1 && [llength [lindex $args 0]] > 1} {
    set args [lindex $args 0]
  }
  set ret "\033\["
  foreach {op val} $args {
    switch -- $op {
      -style {}
      -bg {append ret 4}
      -fg {append ret 3}
    }
    switch -- $val {
      black     {append ret "0;"}
      red       {append ret "1;"}
      green     {append ret "2;"}
      yellow    {append ret "3;"}
      blue      {append ret "4;"}
      magenta   {append ret "5;"}
      cyan      {append ret "6;"}
      white     {append ret "7;"}
      none      {append ret "0;"}
      bright    {append ret "1;"}
      dim       {append ret "2;"}
      underline {append ret "4;"}
      blink     {append ret "5;"}
      reverse   {append ret "7;"}
    }
  }
  set ret [string trim $ret ";"]
  return ${ret}m
}

fconfigure stdin  -buffering none
fconfigure stdout -buffering none -translation binary

# if {$argv == ""} {
# set title "cgrep:"
# append title "[ANSI -fg green -bg black] C"
# append title "[ANSI -fg red]o"
# append title "[ANSI -fg yellow]l"
# append title "[ANSI -fg cyan]o"
# append title "[ANSI -fg white]r "
# append title "[ANSI -style none]your text!"
# puts $title
# puts {usage: cgrep regexp option option ...

# Where regexp is a regular expression to match and option describes
# how to color the matched text. The options are one or more of:
#   -fg color    foreground color.
#   -bg color    background color.
#   -style effect  text style.
  
# where "color" is one of:
# black, red, green, yellow, blue, magenta, cyan or white

# and "effect" is one of:
# none, bright, dim, underline, blink or reverse

# More than one match may be specified.

# Example, color the line containing "foo" red and underline the
# word "bar":

#   cgrep '^.*foo.*$' -fg red 'bar' -style underline
# }
# exit
# }

# # Support named patterns:
# if {([llength $argv] == 1) && [file exists ~/.cgrep]} {
#   set f [open ~/.cgrep]
#   set data [read $f]
#   close $f
  
#   foreach {name patterns} $data {
#     if {$name == [lindex $argv 0]} {
#       set argv $patterns
#       break
#     }
#   }
# }

proc shift {ls} {
  upvar 1 $ls LIST
  if {[llength $LIST]} {
    set ret [lindex $LIST 0]
    set LIST [lreplace $LIST 0 0]
    return $ret
  } else {
    error "Ran out of list elements."
  }
}

proc unshift {ls val} {
  upvar 1 $ls LIST
  set LIST [concat [list $val] $LIST]
}

proc process_args {argv} {
  set ret [list]
  while {[llength $argv]} {
    set re [shift argv]
    set format [list]
    while {[llength $argv]} {
      set op [shift argv]
      switch -exact -- $op {
        -fg - -bg - -style {
          set x [shift argv]
          if {[string match -* $x]} {
            unshift argv $x
            unshift argv $op
            break
          }
          lappend format $op $x
        }
        default {
          unshift argv $op
          break
        }
      }
    }
    lappend ret $re $format
  }
  return $ret
}

proc merge_color {current new} {
  array set c {-bg {} -fg {} -style {}}
  array set n {-bg {} -fg {} -style {}}
  foreach {style arr} {current c new n} {
    array set $arr [set $style]
  }
  foreach x {-bg -fg -style} {
    if {$n($x) == ""} {
      if {$c($x) != ""} {
        set n($x) $c($x)
      } else {
        unset n($x)
      }
    }
  }
  return [array get n]
}

proc get_matches {line formatting} {
  set ret [list]
  foreach {re color} $formatting {
    set matches [regexp -inline -all -indices -- $re $line]
    foreach m $matches {
      foreach {start end} $m {incr end; break}
      lappend ret [list $start start $color]
      lappend ret [list $end end $color]
    }
  }
  return $ret
}

proc resequence {formatting} {
  set ret [list]
  set cstack [list]
  foreach x [lsort -dictionary $formatting] {
    foreach {mark type color} $x break
    switch -- $type {
      start {
        unshift cstack $color
        set color [merge_color [lindex $cstack 0] $color]
        # unshift cstack $color
        set clist [list $color]
      }
      end {
        shift cstack
        set clist {{-style none}}
        lappend clist [lindex $cstack 0]
      }
    }
    lappend ret $mark $clist
  }
  return $ret
}

proc render_line {line formatting} {
  set n 0
  set ret ""
  foreach {mark colors} $formatting {
    append ret [string range $line $n [expr {$mark-1}]]
    foreach color $colors {
      append ret [ANSI $color]
      #append ret "{$color}"
    }
    set n $mark
  }
  append ret [string range $line $n end]
  append ret [ANSI {-style none}]
  #append ret "{-none}"
  return $ret
}

proc main {lines argv} {
  set args [process_args $argv]
  foreach line $lines {
    puts [render_line $line [resequence [get_matches $line $args]]]
  }
}
