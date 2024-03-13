$[include ~/subdir/other-templates.hoot.md]
   $[set dogname \
Charlie]
$[set multiline $[string trim {
This is a multiline declaration
}]]
# A Visit from $dogname

Here comes my dog, $dogname.
$[set foo bar]

$[greet $dogname]
$[! this is a comment]

$dogname sniffs around, wandering here and there.
Then he comes over for some pats on the head
and a chin scratch. Then it's time to go.
$[+ block myblock +]
Here is myblock
It is multiple lines
$[greet "Person"]
$[- myblock -]
$[+ block otherblock +]
This is otherblock
$[- otherblock -]
$[+ block silentdefblock +]
This is silentdefblock
$[- silentdefblock -]

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

$[? {$a == 1} {A is 1} {A is not 1}]
$[? {$b == 1} {B is 1} {B is not 1}]

$[set onechar "x"]
$[or $[str/rest $onechar] "not-blank"]

\$[this is code]
$\[this is also code]
The price is $123
\$(this is an expr)
$\(this is also an expr)

$multiline

$myblock
$[+ defblock otherblock +]
This should not render
$[--]
$[+ . defblock silentdefblock +]
This should not render
$[--]

$[set X/abc 123]
$[defaults {
    X/abc 456
    X/xyz 789
    X/foo {}
}]
${X/abc} ${X/xyz}${X/foo}

12 + 34 = $(12 + 34)

$silentdefblock

--

$[set D $[dict create a 1 b 2]]
$[do {
    dict set D c {x 88 y 99}
}]
b is $[@ $D b]
c is $[@ $D {c x}],$[@ $D {c y}]
d is $[@ $D d {not present}]

--

$[+ each number {1 2 3 4} +]
The number is $number. $onechar
$[- end -]

--

$[set foo bar]
$[+ if {$foo eq "foo"} +]
Foo is "foo"
$[~ elseif {$foo eq "bar"} ~]
Foo is "bar"
$[~ else ~]
Foo is not "foo"
$[--]

--

$[set cat "Whiskers"]
$[+ block catblock +]
$[+ if {$cat eq "Mr. Phooey"} +]
Cat is named Mr. Phooey
$[~ elseif {$cat eq "Whiskers"} ~]
Cat is named Whiskers
$[~ else ~]
Not sure what cat is named
$[- endif -]
$[- end block -]
${catblock}
