source hoot.tcl
set expected [slurp test/output.md]
set actual [renderfile test/input.hoot.md]
if {$actual eq $expected} { error "Test failed" }
