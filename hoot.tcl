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
proc = {args} { uplevel 1 expr {*}$args }
proc str/len {s} { string length $s }
proc str/first {s} { string index $s 0 }
proc str/last {s} { string index $s end }
proc str/rest {s} { string range $s 1 end }
proc slurp {p} { K [read [set f [open $p r]]] [close $f] }
proc = {val _ cond} { uplevel 1 "if {$cond} {K {$val}}" }

proc . {args} { K "\30" [uplevel 1 $args] }

proc render {txt} {
  set txt [string map {
    {\$[}   {$\[}
    {$\[}   {$\[}
    {$[set} {[. set}
    {$[.}   {[. }
    {$[}    {[}
    {[}     {\[}
    {$0} {\$0}  {$1} {\$1}  {$2} {\$2}  {$3} {\$3}  {$4} {\$4}
    {$5} {\$5}  {$6} {\$6}  {$7} {\$7}  {$8} {\$8}  {$9} {\$9}
  } $txt]
  set txt [uplevel #0 "subst {$txt}"]
  regsub -all -line "^\\s*\30\[ \t]*\r?\n?|\30\[ \t]*" $txt {}
}

proc renderfile {path} {
  if {![file exists $path]} {throw 2 "File $path does not exist\n"}
  set f $::FILE
  set ::FILE $path
  K [render [slurp $path]] [set ::FILE $f]
}

proc include {path} {
  if {[regexp {^\.\.?/.+} $path]} {
    set path "[file dirname $::FILE]/$path"
  }
  string cat [renderfile "$path"] "\30"
}

proc template {n ps txt} {
  set trim [string match "\[\r\n\]" [str/first $txt]]
  if $trim {set txt [string trim $txt]}
  . eval "proc $n {$ps} {subst {$txt}}"
}

set FILE {}
