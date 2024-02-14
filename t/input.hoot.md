$[include t/subdir/other-templates.hoot.md]
   $[set dogname \
Charlie]
$[set multiline $[string trim {
This is a multiline declaration
}]]
# A Visit from $dogname

Here comes my dog, $dogname.
$[set foo bar]

$[greet $dogname]
$[~ this is a comment]

$dogname sniffs around, wandering here and there.
Then he comes over for some pats on the head
and a chin scratch. Then it's time to go.
$[+myblock+]
Here is myblock
It is multiple lines
$[-myblock-]

$[solong \
$dogname]
$[set a 1]    $[set b 2]

...$[set place building]
*Charlie has left the $place*

---

$[= "What a string!"]
$[= "What a conditional string!" if {$place eq "building"}]
$[= "This will not render" if {$place eq "foobar"}]
$[= "Also will not render" if {$place eq "foobar"}]xx

\$[this is code]
$\[this is also code]
The price is $123

$multiline

$myblock
