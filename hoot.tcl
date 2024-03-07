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
proc ? {c a b} { uplevel 1 "if {$c} {K {$a}} {K {$b}}" }
proc = {x {_ _} {c 1}} { uplevel 1 "if {$c} {K {$x}} {K \"\30\"}" }
proc @ {d k {v {}}} { dict getdef $d {*}$k $v }
proc or {x y} { if {$x eq ""} {K $y} {K $x} }
proc do {args} { . uplevel 1 {*}$args }

proc ! {args} { K "\30" }
proc . {args} { K "\30" [uplevel 1 $args] }

proc include {path {vars {}}} {
  string cat [H/file [H/path $path] [string trim $vars]] "\30"
}

proc each {{var it} list body} {
  uplevel 1 "join \[lmap {$var} {$list} {$body}] \"\n\""
}

rename source tcl/source
proc source {path} {
  . tcl/source [H/path $path]
}

proc defaults {vars} {
  . foreach {k v} $vars {
    if [uplevel 1 info exists $k] {} {uplevel 1 set $k "{$v}"}
  }
}

proc contentsOf {path} {
  H/slurp [H/path $path]
}

proc block {name value} {
  K "\30" [uplevel 1 set $name "\[$value\]"]
}

proc template {name params body} {
  K "\30" [uplevel 1 "proc $name {$params} {$body}"]
}

set H/prepmap {
  {\$[}   {$\[}
  {\$(}   {$\(}
  {$\[}   {$\[}
  {$\(}   {$\(}
  {$[>}   {[include }
  {$[set} {[. set}
  {$[.}   {[. }
  {$[+}   {[}
  {$[~}   "\}\]\} "
  {+]}    " \{subst \[string trim \{"
  {~]}    " \{subst \[string trim \{"
  {$[-}   "\}\]\}\]\[! "
  {-]}    "\]"
  {$[}    {[}
  {[}     {\[}
  {$0} {\$0}  {$1} {\$1}  {$2} {\$2}  {$3} {\$3}  {$4} {\$4}
  {$5} {\$5}  {$6} {\$6}  {$7} {\$7}  {$8} {\$8}  {$9} {\$9}
}

proc H/prep {txt} {
  return [string map ${::H/prepmap} $txt]
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
  if {${::H/PREPONLY}} {
    K [H/prep [H/slurp $path]]  [set ::FILE $f]
  } else {
    K [H/render [H/slurp $path] $vars] [set ::FILE $f]
  }
}

proc H/path {path} {
  set path [string trim $path]
  if {[regexp {^\.\.?/} $path]} {
    return "[file dirname $::FILE]/$path"
  } elseif {[regexp {^~/} $path]} {
    return "$::ROOT[str/rest $path]"
  }
  return $path
}

proc H/slurp {p} {
  K [read [set f [open $p r]]] [close $f]
}

set FILE {}
set ROOT [file normalize [dict getdef $::env PWD [pwd]]]
cd $ROOT
set H/PREPONLY [dict getdef $::env PREP 0]
if {[dict getdef $::env BS 0]} {lappend H/prepmap "\\" "\\\\"}
