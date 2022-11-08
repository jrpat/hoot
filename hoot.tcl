if [info exists ::pkg/bvr] {return} {set ::pkg/bvr 1}

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

proc first {lst} { lindex $lst 0 }
proc last {lst} { lindex $lst end }
proc id {{x {}}} { tailcall return -level 0 $x }
proc D {d args} { if [dict exists $d {*}$args] {dict get $d {*}$args} }
proc slurp {p} { set t [read [set f [open $p r]]]; close $f; return $t }

namespace eval bvr {
  variable macros [dict create]
  variable preps [dict create]

  variable vm [interp create -safe]

  $vm eval set __FILE "{}"
  $vm eval proc __RENDER {{txt ctx}} {{ dict with ctx { subst $txt } }}


  proc preproc {txt} {
    set txt [regsub -all {([^$])\[} $txt {\1\[}]      ;# [...] literal
    set txt [regsub -all {(^|[^\\])\$\[} $txt {\1[}]  ;# $[...] code
    set txt [regsub {(?n)^\s*!(.+)$\n?} $txt {[\1]}]  ;# %... directive
    foreach {_ p} $bvr::preps {
      set txt [regsub -all [first $p] $txt [last $p]]
    }
    return $txt
  }

  proc render {txt {ctx {}}} {
    set txt [preproc $txt]
    $bvr::vm eval __RENDER "{$txt} {$ctx}"
  }

  proc renderfile {path} {
    set prev [$bvr::vm eval set ::__FILE]
    $bvr::vm eval set ::__FILE $path
    set txt [render [slurp $path]]
    $bvr::vm eval set ::__FILE $prev
    return $txt
  }


  namespace eval preps {}

  proc +prep {name re argv body {reargv {}}} {
    namespace eval ::bvr::preps proc $name "{$argv}" "{$body}"
    $bvr::vm alias prep/$name ::bvr::preps::$name
    if {$reargv eq ""} { set reargv [lmap a $argv {id "\\[incr i]"}] }
    dict set bvr::preps $name [list $re "\[prep/$name $reargv\]"]
  }
  
  proc -prep {name} {
    rename ::bvr::preps::$name {}
    $bvr::vm alias prep/$name {}
  }

  proc ?prep {name} {
    set p [D $bvr::preps $name]
    set argv [info args ::bvr::preps::$name]
    set body [info body ::bvr::preps::$name]
    return [subst [join [lmap line {
      {Find: {[first $p]}}
      {Proc: {$argv} {$body}}
    } {string trimright $line}] "\n"]]
  }


  proc +macro {name txt} {
    dict set bvr::macros $name [string trim $txt] ; return
  }
  proc -macro {name} { dict unset bvr::macros $name }
  proc ?macro {name} { D $bvr::macros $name }


  proc +proc {name argv body} {
    namespace eval ::bvr::procs proc $name "{$argv}" "{$body}"
    $bvr::vm alias $name ::bvr::procs::$name
  }

  proc -proc {name} {
    rename ::bvr::procs::$name {}
    $bvr::vm alias $name {}
  }

  proc ?proc {name} {
    set n "::bvr::procs::$name"
    return "proc $name {[info args $n]} {[info body $n]}"
  }

  namespace eval procs {
    proc include {path} {
      # Inline a file into the template. If the path begins with "./",
      # it is relative to the file currently being processed.
      # Otherwise, it is relative to the working directory.
      if {[string equal -length 2 $path "./"]} {
        set dir [file dirname [$bvr::vm eval set ::__FILE]]
        set path "$dir/$filename"
      }
      ::if {! [file exists $path]} {
        throw {BADFILE {does not exist}} "File $path does not exist" }
      tailcall bvr::renderfile "$path"
    }

    proc > {macro args} {
      # Inline a macro into the template
      ::if {! [dict exists $bvr::macros $macro]} {
        throw {BADMACRO {does not exist}} "Macro $macro does not exist" }
      tailcall bvr::render [dict get $bvr::macros $macro] $args
    }

    proc macro {args} { bvr::+macro {*}$args }

    proc id {{x {}}} { tailcall return -level 0 $x }
    proc iif {cond thn {els {}}} { ::if $cond {id $thn} {id $els} }
    proc fmt {fmt args} { format $fmt {*}$args }

    proc first {lst} { lindex $lst 0 }
    proc last {lst} { lindex $lst end }
    proc rest {lst} { lrange $lst 1 end }

    proc strfirst {s} { string index $s 0 }
    proc strlast {s} { string index $s end }
    proc strrest {s} { string range $s 1 end }
    proc strmap {args} { string map {*}$args }
    proc strjoin {lst sep} { join $lst $sep }
    proc streq {a b} { string equal $a $b }
    proc strneq {a b} { expr {![eq $a $b]} }
    proc strlower {s} { string tolower $s }
    proc strupper {s} { string toupper $s }
  }

  foreach p [info procs ::bvr::procs::*] {
    $vm alias [namespace tail $p] $p
  }
}

