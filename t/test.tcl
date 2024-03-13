source hoot.tcl
set expected [H/slurp output.md]
set actual [H/file input.hoot.md]
#set actual [H/prep [H/slurp input.hoot.md]]
if {$actual ne $expected} {
  set line [string repeat - 120]
  set actual [string map {"\30" {∅}} $actual]
  catch {puts [exec diff -y output.md - << $actual]} out
  puts "$line\n$out\n$line\n"
  exit 1
}
exit 0
