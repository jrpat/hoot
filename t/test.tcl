source hoot.tcl
set actual [renderfile t/input.hoot.md]
set expected [slurp t/output.md]
if {$actual ne $expected} {
  exec diff -y t/output.md - << $actual
  exit 0
}
