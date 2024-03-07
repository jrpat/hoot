# Hoot

Hoot is a Tcl-powered text preprocessor. That is, it's is a tool for
dynamically generating any kind of textual content -- especially where the
textual content far outweighs the program.

By way of rough analogy:

- [Hoot](https://github.com/jrpat/hoot) : [Tcl](https://jim.tcl.tk/fossil/doc/trunk/Tcl_shipped.html)
:: [Scribble](https://docs.racket-lang.org/scribble/index.html) : [Racket](https://racket-lang.org)
- [Hoot](https://github.com/jrpat/hoot) : [Tcl](https://jim.tcl.tk/fossil/doc/trunk/Tcl_shipped.html)
:: [Jinja](https://jinja.palletsprojects.com/en/3.1.x/) : [Python](https://www.python.org)
- [Hoot](https://github.com/jrpat/hoot) : [Tcl](https://jim.tcl.tk/fossil/doc/trunk/Tcl_shipped.html)
:: [ERB](https://www.puppet.com/docs/puppet/5.5/lang_template_erb.html) : [Ruby](https://www.ruby-lang.org/en/)

But unlike Scribble or Jinja, which introduce their own (complicated) syntax on top of their host language, Hoot embraces Tcl and modifies its syntax as little as possible. In fact, Hoot makes **only one change** to [Jim](https://jim.tcl.tk/index.html/doc/www/www/index.html), its host Tcl dialect.

And it's a 375k statically-linked binary that can be built on virtually any system with a C compiler (or you can `[source hoot.tcl]` from a Tcl program).


#### Quick Example

The input

```text
$[template greet {name} {"Hello, $name!"}]
$[template solong {name} {"So long, $name!"}]
$[set dogName "Charlie"]
$[set place "building"]

# A Visit from $dogName

Here comes my dog, $dogName.

$[greet $dogName]

$dogName sniffs around, wandering here and there.
Then he comes over for some pats on the head
and a chin scratch. Then it's time to go.

$[solong $dogName]

*$dogName has left the $place*
```

produces the output

```text
# A Visit from Charlie

Here comes my dog, Charlie.

"Hello, Charlie!"

Charlie sniffs around, wandering here and there.
Then he comes over for some pats on the head
and a chin scratch. Then it's time to go.

"So long, Charlie!"

*Charlie has left the building*
```

#### Basic Usage

Hoot can be run from the command line. You can pass in a filename:

```bash
hoot myfile.hoot.md
```

or you can pass `-` as the filename to read from stdin:

```bash
mycmd | hoot -
```

Hoot outputs to stdout, so you can redirect its output to a file or pipe it to another command:

```bash
hoot myfile.hoot.md > myfile.md
hoot myfile.hoot.md | another-command
```

Hoot can also be used directly from a Tcl program. More details in the [Usage](#usage) section below.


#### Why Tcl?

Tcl is a simple, yet [surprisingly powerful language](http://antirez.com/articoli/tclmisunderstood.html). Hoot was inspired by Tcl's [`subst`](https://jim.tcl.tk/fossil/doc/trunk/Tcl_shipped.html#_subst) command, which is already tantalizingly close to being a proper templating language in its own right.

The main thing that is holding it back is that the Tcl syntax for commands (`[...]`) is pretty common in normal prose. Plus, in a templating environment, we'd rather that some commands (such as `set`) don't produce any output.

#### Why The Name?

Tcl is commonly pronounced like "tickle", and a tickle makes you laugh, or... "hoot". Plus I like owls. What can I say?


-----


## Syntax Reference

##### tl;dr:

If you already know Tcl, then all you need to know about Hoot syntax is that you use `$[command ...]` instead of `[command ...]`. Note the `$` at the beginning. Everything else is the same.

<h3 id=the-big-3>The Big Three</h3>

Very succinctly, Hoot's syntax can be described as consisting of three forms:

- `${…}` inserts a variable
- `$[…]` inserts the output of a command
- `$(…)` inserts the result of an [expression](https://jim.tcl.tk/fossil/doc/trunk/Tcl_shipped.html#_expressions)

Let's discuss each one in more detail…

### Variables — `${…}`

The most basic and most common thing to do with Hoot is set and use variables. You set variables like this:

```text
$[set myVariable "some really long text I'd rather not type"]
```

and you use them in text like this:

```text
The rest of this line is ${myVariable}
And this line is also ${myVariable}
```

which results in:

```text
The rest of this line is some really long text I'd rather not type
And this line is also some really long text I'd rather not type
```

##### Variable Names

One neat thing about Tcl is that variables can use almost any characters in their names. The only exception is whitespace. You can name a variable `foo/bar` or even `this.is/my#variable-name`.

If the variable name consists of only letters and numbers, you can omit the curly braces when using them. For instance:

```text
$[set myVar "some really long text..."]
The rest of this line is $myVar
```

### Commands — `$[…]`

Insert the output of any Tcl commands inside our text by using `$[…]`.

For example:

```text
$[set foo "Hello"]
$[string reverse $foo]
```

will produce

```text
olleH
```

This is a big part of what makes hoot so powerful. Unlike say, Jinja, which requires writing custom filters or extensions, you can write Tcl code directly inside your text.

#### Silencing Commands

Sometimes we want to run a command, but we don't want its output included in our text. For these situations, you can prepend the command's name with a `.`. For example:

```text
$[set name "Sam"]
$[set greeting "Hello"]
$[.append greeting " there"]
$[.append greeting ", $name"]
A common greeting goes like this: "$greeting".
```

will produce

```text
A common greeting goes like this: "Hello there, Sam".
```

> If you know Tcl, you may have been thinking "Hey, `set` returns a value. Why isn't it included in the text?". In Hoot, some commands are implicitly silent, since they are very common and we almost never want their output. `set` is one such command.

### Expressions — `$(…)`

Sometimes we want to insert the result of some math in our text. In standard Tcl, we do this using the `expr` command, but Jim introduces a convenient shorthand: `$(…)`.

For example:

```text
$[set x 123]
$[set y 456]
The result of $x + $y is $($x + $y).
The result of $x squared is $($x ** 2).
```

will produce

```text
The result of 123 + 456 is 579.
The result of 123 squared is 15129.
```

A [wide range of mathematical and logical operators](https://jim.tcl.tk/fossil/doc/trunk/Tcl_shipped.html#_expressions) are supported.

### Backslash Escapes

Hoot supports all of the [standard Tcl backslash escape sequences](https://jim.tcl.tk/fossil/doc/trunk/Tcl_shipped.html#BackslashSequences).

Additionally, you can backslash-escape the dollar sign in any of the [the big 3](#the-big-3) syntax forms. For example:

```text
\${myVariable}
\$[myCommand]
\$(1 + 2)
```

will produce

```text
${myVariable}
$[myCommand]
$(1 + 2)
```

#### Disabling Backslash Escapes

Sometimes we may want to produce text that uses a lot of backslashes as part of its syntax (*cough* [LaTeX](https://www.latex-project.org) *cough*). In those situations, backslash escapes can be surprising and annoying. 

For instance, you would not expect

```latex
\textbf{My bold text}
```

to produce

```
	extbf{My bold text}
```

That happens because Hoot interprets `\t` as a tab character. In these settings, we can disable Hoot's backslash escape processing by setting the `BS` [environment variable](https://jim.tcl.tk/fossil/doc/trunk/Tcl_shipped.html#_env). We'll discuss how to do that a little later on.


### Comments

In Hoot, the `!` command ignores anything passed into it and produces no output. Thus it works effectively as a way to add comments to text.

For example:

```text
$[! This is a comment]
And this is text
```

will produce

```text
And this is text
```

## Control Structures

Control structures are all those things that control the flow of a program. In Hoot, there are 2: `each` and `if`.

In general, Hoot control structures begin with an "opening tag" of the form `$[+ command …arguments… +]`.

They end with a "closing tag" of the form `$[--]`. The closing tag may have any text in between the hyphens. That is, the following are all identical:

```text
$[--]
$[-end-]
$[- end -]
$[- I love Hoot -]
```

### Each

Loops over the items in a list, and outputs the text between the open and close tag separated by newlines. For example:

```text
$[+ each number {1 2 3} +]
$number squared is $($number ** 2)
$[- end each -]
```

will produce

```text
1 squared is 1
2 squared is 4
3 squared is 9
```

The syntax of `each` is the same as Tcl's [`foreach`](https://jim.tcl.tk/fossil/doc/trunk/Tcl_shipped.html#_foreach), so you can for instance loop over the keys and values of a dictionary:

```text
$[+ each {k v} {a 1 b 2 c 3} +]
The key $k has the value $v
$[--]
```

will produce

```text
The key a has the value 1
The key b has the value 2
The key c has the value 3
```

Additionally, the variable name can be omitted, in which case it will default to `it`. For example:

```text
$[+ each {a b c} +]
It is $it
$[--]
```

will produce

```text
It is a
It is b
It is c
```


### If / Else / Elseif

`if` is comparable with [Tcl's `if`](https://jim.tcl.tk/fossil/doc/trunk/Tcl_shipped.html#_if). For example:

```text
$[set x abc]
$[+ if {$x eq "abc"} +]
x is abc
$[--]
$[+ if {$x eq "xyz"} +]
$[--]
```

will produce

```text
x is abc
```

As in Tcl, we can also use `else` and `elseif`, by using the syntax `$[~ else ~]` or `$[~ elseif … ~]`. For example:

```text
$[set x "foo"]
$[+ if {$x eq "abc"} +]
x is "abc"
$[~ elseif {$x eq "foo"} ~]
x is "foo"
$[~ else ~]
x is neither "abc" or "foo"
$[- end if -]
```

will produce

```text
x is "foo"
```


## Blocks and Includes

A core part of most templating systems is the ability to define and name large chunks of text, and the ability to include other files which may use these large chunks of text.

### Blocks

Hoot introduces a convenient way of assigning a large amount of textual content to a variable without using `$[set …]`. It's analogous to [Jinja's `{% block %}`](https://jinja.palletsprojects.com/en/3.1.x/templates/#template-inheritance).

For instance, an HTML template might be

```text
<html>
    <head>
        <title>${title}</title>
    </head>
    <body>
        ${content}
    </body>
</html>
```

While `$[set title "Some Title"]` feels fine, it would be annoying to have to define the entirety of the HTML content using `$[set content ...]` - if for no other reason than that our editor won't syntax-highlight it properly. In these cases, we can use a syntax similar to control structures to define variables:

```text
$[+ block content +]
<div>
    This is some content
    …
</div>
$[--]
```

This sets the value of `content` to everything between `$[+ block content +]` and `$[--]`, *excluding any whitespace at the beginning and end*. So in this case, `$content` will begin with `<div>` and end with `</div>`, *without* newlines before and after.

As with control structures, you can put text between `$[-` and `-]`. For example, you could write `$[- end block -]` or `$[- end content -]`.

### Including Other Files

**`$[include path]`** or **`$[> path]`**

Reads the content of a file, processes it with Hoot, and inserts the result. 

Analogous to [Jinja's `{% include %}`](https://jinja.palletsprojects.com/en/3.1.x/templates/#include) or [Sass's `@import`](https://sass-lang.com/documentation/at-rules/import/).

<h4 id=path-syntax>Path Syntax</h4>

`path` is interpreted in a few ways, depending on its first few characters:
- **`./`** or **`../`** -- means "relative to the path of the file being processed". That is, if `/the/path/to/my/file.md` is being processed, and it contains `$[> ../other/file.md]`, the contents of `/the/path/to/other/file.md` is inserted.
- **`~/`** -- means "relative to the directory from which the `hoot` command was run".
- **`/`** -- means it is an absolute path to a file.
- Otherwise, `path` is considered relative to the current working directory. This *usually* behaves the same as `~/`, but can be different in some edge-cases (ie. if `$[cd /some/other/path]` is at the top of the file)


### Combining Blocks and Includes

Blocks and includes can be combined for an effect similar to [Jinja's template inheritance](https://jinja.palletsprojects.com/en/3.1.x/templates/#template-inheritance). For instance:

<sub>base.hoot.html:</sub>
```text
<html>
    <head>
        <title>MegaCorp - ${title}</title>
    </head>
    <body>
        ${content}
        <script src="${pageScript}"></script>
    </body>
</html>
```

<sub>index.hoot.html:</sub>
```text
$[set title "Home"]
$[set pageScript "/home.js"]
\
$[+ block content +]
<h1>This is the home page of MegaCorp</h1>
<div>More content here</div>
$[- end content -]
\
$[> base.hoot.html]
```

Running `hoot index.hoot.html` will output:

```text
<html>
    <head>
        <title>MegaCorp - Home</title>
    </head>
    <body>
        <h1>This is the home page of MegaCorp</h1>
        <div>More content here</div>
    </body>
</html>
```

#### Setting Variables for Includes

Optionally, a dictionary can be passed as a second argument to `include`, and it will be used to set variables in that file's context.

In the example above, we could remove the first two lines and replace the last line with:

```text
$[> base.hoot.html {
    title "Home"
    pageScript "/home.js"
}]
```

which would generate identical output.

## Templates

Templates are comparable with functions in regular programming languages, and are defined using the same syntax as control structures and blocks.

They also share syntax with [Tcl's `proc`](https://jim.tcl.tk/fossil/doc/trunk/Tcl_shipped.html#_proc), which means arguments can have default values, and templates can take variadic arguments.

Here's a template that renders an HTML `<input>` element:

```text
$[+ template input {name {type text} {value ""}} +]
<input name="${name}" type="${type}" value="${value}">
$[- end template -]
```

To use them, we call them like commands. For example:

```text
<form>
    $[input userEmail]
    $[input userPass password]
</form>
```

will output

```text
<form>
    <input name="userEmail" type="text" value="">
    <input name="userPass" type="password" value="">
</form>
```

#### Named Arguments

A common pattern for simulating named arguments is to define a template with variadic arguments, and then use the `@` command (discussed below) to treat them like a dictionary. Here's the same template from above, rewritten to use named optional arguments:

```text
$[+ template input {name args} +]
$[set type $[@ $args type "text"]]
$[set value $[@ $args value ""]]
<input name="${name}" type="${type}" value="${value}">
$[--]
```

To use this template:

```text
<form>
    $[input userEmail]
    $[input userPass {type password}]
</form>
```

which will have the same output as above.

-----

## Command Reference

In addition to [all the standard Tcl commands](https://jim.tcl.tk/fossil/doc/trunk/Tcl_shipped.html#CommandIndex), Hoot includes a number of commands that are particularly useful in a templating environment.


##### Utility Commands

**`$[or $x $y]`**

Inserts the value of `$x`, unless it is an empty string, in which case it inserts the value of `$y`.

**`$[= $x if {expression}]`**

Inserts the value of `$x` if the result of `expression` is [truthy](https://jim.tcl.tk/fossil/doc/trunk/Tcl_shipped.html#_if). The `if {expression}` portion may be omitted, in which case it inserts the value of `$x` directly.

**`$[? {expression} $x $y]`**

Inserts the value of `$x` if the result of `expression` is [truthy](https://jim.tcl.tk/fossil/doc/trunk/Tcl_shipped.html#_if), otherwise inserts the value of `$y`.

**`$[@ $dict key defaultValue]`**

A synonym for [`dict getwithdefault`](https://jim.tcl.tk/fossil/doc/trunk/Tcl_shipped.html#_dict). If the dictionary contains a value for `key`, that value is output. Otherwise, `defaultValue` is output. `defaultValue` may be omitted, in which case it is an empty string.

**`$[source path]`**

Analogous to [Tcl's `source`](https://jim.tcl.tk/fossil/doc/trunk/Tcl_shipped.html#_source). Loads and evaluates the contents of `path`, but outputs nothing. `path` is interpreted in the same was as with [`include`](#path-syntax).

**`$[do code]`**

Analogous to [Tcl's `eval`](https://jim.tcl.tk/fossil/doc/trunk/Tcl_shipped.html#_eval). Executes `code`, but outputs nothing.

**`$[contentsOf path]`**

Outputs the contents of the file at `path` without processing them in any way. `path` is interpreted in the same was as with [`include`](#path-syntax).


##### Aliases

- **`$[first $list]`** - an alias for [`$[lindex $list 0]`](https://jim.tcl.tk/fossil/doc/trunk/Tcl_shipped.html#_lindex)
- **`$[last $list]`** - an alias for [`$[lindex $list end]`](https://jim.tcl.tk/fossil/doc/trunk/Tcl_shipped.html#_lindex)
- **`$[rest $list]`** - an alias for [`$[lrange $list 1 end]`](https://jim.tcl.tk/fossil/doc/trunk/Tcl_shipped.html#_lrange)
- **`$[str/len $x]`** - an alias for [`$[string length $x]`](https://jim.tcl.tk/fossil/doc/trunk/Tcl_shipped.html#_string)
- **`$[str/first $x]`** - an alias for [`$[string index $x 0]`](https://jim.tcl.tk/fossil/doc/trunk/Tcl_shipped.html#_string)
- **`$[str/last $x]`** - an alias for [`$[string index $x end]`](https://jim.tcl.tk/fossil/doc/trunk/Tcl_shipped.html#_string)
- **`$[str/rest $x]`** - an alias for [`$[string range $x 1 end]`](https://jim.tcl.tk/fossil/doc/trunk/Tcl_shipped.html#_string)


-----

## Usage

Hoot can be run from the command line, or from a Tcl program.

### Command Line

```text
Usage:
  hoot -           Process input from stdin
  hoot <path>      Process file at <path>
  hoot -t/--tcl    Output Hoot Tcl code
  hoot -h/--help   Print this message
```

#### Environment Variables

There are a few environment variables that can be used to affect Hoot's execution. They are:

- `PWD=path` causes Hoot to consider `path` to be the "root" directory, from which it interprets other paths.
- `BS=1` causes Hoot to ignore backslash escapes. This is helpful when processing backslash-heavy content such as LaTeX.
- `PREP=1` is used for debugging. This causes Hoot to skip rendering the input and instead output the intermediate raw Tcl that would be passed to `subst`.

Here is an example of using all 3:

```bash
PWD=/path/to/files BS=1 PREP=1 hoot myfile.md
```


### From a Tcl Program

The core functionality of Hoot is implemented entirely in around a hundred lines of Tcl.

To use it directly from a Tcl program, first create a file called `hoot.tcl` with the Hoot Tcl code. You can do this in one of two ways:

```bash
hoot -t > hoot.tcl
# or
cp /path/to/hoot/code/hoot.tcl hoot.tcl
```

Once you have that file, simply `source hoot.tcl`.

The procs beginning with `H/` can be used to do everything the `hoot` command line program does. In fact, when you run `hoot myfile` from the command line, it simply executes the Tcl code `H/file myfile`.

These procs are short and easy to read, and their source in your `hoot.tcl` file should be considered their canonical documentation. However, here is a brief description:

- `H/prep text` Converts `text` from Hoot syntax into raw Tcl.
- `H/subst text` Runs the raw Tcl from `H/prep`.
- `H/render text` Essentially returns `H/subst [H/prep text]`
- `H/path` Interprets a path as per [`include`](#path-syntax)
- `H/file path` Essentially returns `H/render [H/path path]`

-----


## Building & Installing

Hoot can be built on almost any system that has a C compiler, including many embedded systems. The only required library is [libm](https://sourceware.org/newlib/libm.html).

Building Hoot is simple. After cloning the repository and `cd`ing into the directory, simply run:

```bash
make
```

This will build the statically-linked `hoot` executable.

If you want to install Hoot, run:

```bash
make install
# or
prefix=/installation/path make install
```

By default, `prefix=/usr/local`.


-----


## Tests

Right now Hoot's test suite is one pathological input file.

To run the tests:

```text
make test
```

The tests have passed if the output is 

```text
PASS
```

If an error occurred, it is displayed. If no error occurred, but the actual output doesn't match the expected output, a side-by-side diff is displayed.

A better testing setup is planned, and contributions are welcome.
