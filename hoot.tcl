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
proc str/first {s} { string index $s 0 }
proc str/last {s} { string index $s end }
proc str/rest {s} { string range $s 1 end }
proc slurp {p} { K [read [set f [open $p r]]] [close $f] }
proc iif {cond thn {els {}}} { if $cond {K $thn} {K $els} }

proc . {args} { K "\30" [uplevel 1 $args] }

proc render {txt} {
  set txt [regsub -all {([^$])\[} $txt {\1\[}]    ;#   [xxx]  → \[xxx]
  set txt [regsub -all {\\\$\[} $txt {$\[}]       ;# \$[xxx]  → $\[xxx]
  set txt [regsub -all {([^\\]?)\$\[} $txt {\1[}] ;#  $[xxx]  → [xxx]
  set txt [regsub -all {\[\.(\S)} $txt {[. \1}]   ;#   [.xxx] → [. xxx]
  regsub -all "\30\\n?" [subst $txt] {}
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
  . eval "proc $n {$ps} {subst {$txt}}"
}

set FILE {}
