# This file is part of Hoot: A Tcl-powered text preprocessor.
# Copyright (C) 2022 Juan Patten. MIT License (see LICENSE).

#    ,_,
#   (o,o)   Hoot: A Tcl-powered
#   {`"'}     text preprocessor
#   -"-"-

proc K {x {y {}}} { set x }
proc first {lst} { lindex $lst 0 }
proc last {lst} { lindex $lst end }
proc rest {lst} { lrange $lst 1 end }
proc str/len {s} { string length $s }
proc str/first {s} { string index $s 0 }
proc str/last {s} { string index $s end }
proc str/rest {s} { string range $s 1 end }
proc slurp {p} { K [read [set f [open $p r]]] [close $f] }
proc = {x {_ _} {c 1}} { uplevel 1 "if {$c} {K {$x}} {K \"\30\"}" }
proc or {x y} { if {$x eq ""} {K $y} {K $x} }

proc ~ {args} { K "\30" }
proc . {args} { K "\30" [uplevel 1 $args] }

proc include {path {vars {}}} {
  set path [string trim $path]
  if {[regexp {^\.\.?/.+} $path]} {
    set path "[file dirname $::FILE]/$path"
  }
  string cat [H/file "$path" [string trim $vars]] "\30"
}

proc template {n ps txt} {
  set trim [string match "\[\r\n\]" [str/first $txt]]
  if $trim {set txt [string trim $txt]}
  . eval "proc $n {$ps} {subst {$txt}}"
}

proc defaults {vars} {
  . foreach {k v} $vars {
    if [uplevel 1 info exists $k] {} {uplevel 1 set $k "{$v}"}
  }
}

proc H/prep {txt} {
  return [string map {
    {\$[}   {$\[}
    {$\[}   {$\[}
    {$[>}   {[include }
    {$[set} {[. set}
    {$[.}   {[. }
    {$[+} "\[. set "  {+]} " \[H/subst \[string trim {"
    {$[-} "}]]]\[~ " {-]} "]"
    {$[}    {[}
    {[}     {\[}
    {$0} {\$0}  {$1} {\$1}  {$2} {\$2}  {$3} {\$3}  {$4} {\$4}
    {$5} {\$5}  {$6} {\$6}  {$7} {\$7}  {$8} {\$8}  {$9} {\$9}
  } $txt]
}

proc H/subst {txt} {
  set txt [uplevel #0 "subst {$txt}"]
  set txt [regsub -all -line "^\\s*\30\[ \t\30]*$\r?\n?" $txt {}]
  string map {"\30" {}} $txt
}

proc H/render {txt {vars {}}} {
  set v [join [lmap {a b} $vars { K "\$\[set $a {$b}]" }] "\n"]
  H/subst [H/prep "${v}\30\n$txt"]
}

proc H/file {path {vars {}}} {
  if {![file exists $path]} {throw 2 "File $path does not exist\n"}
  set f $::FILE
  set ::FILE $path
  K [H/render [slurp $path] $vars] [set ::FILE $f]
}

set FILE {}
cd [dict getdef $::env PWD [pwd]]
