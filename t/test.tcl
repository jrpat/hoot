source hoot.tcl
set actual [renderfile t/input.hoot.md]
set expected [slurp t/output.md]
if {$actual ne $expected} {
  set line [string repeat - 120]
  set actual [string map {"\30" {∅}} $actual]
  catch {puts [exec diff -y t/output.md - << $actual]} out
  puts "$line\n$out\n$line\n"
  exit 1
}
exit 0
