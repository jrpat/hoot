#
#   ,,,,  ,,,,                   .;;      
#    ;;    ;;   ,:::,    ,:::,  ::::::    
#    ;;::::;;  ;: . ::  ;: . ::   ::      
#    ;;    ;;  ::   :;  ::   :;   :: .    
#   ,;;,  ,;;,  ',,,'    ',,,'    ;;:'    
#                                         
#               .:'        `:.            
#                :          :             
#                `:.      .:'             
#                  ``::::''               
#

set FILE {}

proc K {x {y {}}} { set x }
proc first {lst} { lindex $lst 0 }
proc last {lst} { lindex $lst end }
proc rest {lst} { lrange $lst 1 end }
proc = {args} {uplevel 1 expr {*}$args}
proc str/first {s} { string index $s 0 }
proc str/last {s} { string index $s end }
proc str/rest {s} { string range $s 1 end }
proc slurp {p} { K [read [set f [open $p r]]] [close $f] }
proc iif {cond thn {els {}}} { if $cond {K $thn} {K $els} }

proc render {txt} {
  set txt [regsub -all {([^$])\[} $txt {\1\[}]    ;#   [...]  →  literal
  set txt [regsub -all {\\\$\[} $txt {$\[}]       ;# \$[...]  → literal
  set txt [regsub -all {([^\\])\$\[} $txt {\1[}]  ;#  $[...]  →  code
  regsub -all {\\\n} [subst $txt] {}
}

proc renderfile {path} {
  if {![file exists $path]} {throw ENOENT "File $path does not exist"}
  set prev $::FILE
  set ::FILE $path
  K [render [slurp $path]] [set ::FILE $prev]
}

proc .include {path} {
  switch -glob $path {
    ./*  {set path "[file dirname $::FILE]/$path"}
    ../* {set path "[file dirname [file dirname $::FILE]]/$path"}
  }
  string cat [renderfile "$path"] "\\"
}

proc .template {n ps txt} {
  K "\\" [eval "proc $n {$ps} {render \"$txt\"}"]
}

proc . {args} { K "\\" [eval "$args"] }

