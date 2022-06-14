# Argz.jl

**Argz** is a simple command-line argument parser for julia.

## Installation

Argz is not yet in the julia public registry, but you can 
install directly from this repo:

- From the command line

```shell
julia -e 'import Pkg; Pkg.pkg"add https://github.com/dylanxyz/Argz.jl"'
```

- From the julia REPL

```julia
julia> ]
pkg> add https://github.com/dylanxyz/Argz.jl
```

## Usage

**Argz** exports a single macro `@program`, and you can use
as following:

```julia
@program begin
    name = "calculator"
    desc = "A simple calculator"
    usage = "calculator <command> <args>... [options]"
    version = v"0.1.0"

    commands = {
        # cmd[|alias] [sub-cmd]    # description
        "sum"                       "Returns the sum of <numbers>..."
        "subtract|sub"              "Subtract <numbers>..."
        "multiply|mul"              "Multiply <numbers>..."
        "divide|div"                "Divide two numbers <x> and <y>"
        "power|pow"                 "Raise <x> to the power of <y>"
        "sum mult|m"                "Multiply each <numbers>... and sum the result"
    }

    options = {
        # --long[|-short] [<arg>]   # description
        "--help|-h"                 "Show this help message and exit"
        "--version|-v"              "Show version information and exit"
        "--fastmath|-f"             "Use fastmath. (default: false)"
        "--precision|-p <p>"        "Choose float point precision. (default: Float32)"
    }
end
```

The `@program` macro accepts a `block` expression with a 
series of `=` expressions. The first few expressions defines properties 
that the resulting `program` must have, so they must be defined. The last 
two, `commands` and `options`, defines what `commands` can be used and what 
`options` the program can accept.

## Commands

The syntax for the `commands` expression is `{"cmd" "description"; ...}`, 
where can be used exactly as a julia `matrix` literal, where each row 
defines a different command with its optional `description`. The synax 
for the `command` string itself is `name[|alias]` where name  is the 
`command`'s identifier in the parsing result. Commands can be nested 
by separating then with spaces. For example, a  command of `ship` should 
be valid when used as `ship x..`, a command of `ship|sh` should be valid 
when used as `ship x...` or `sh x...`, and a command `ship|sh id` should 
be valid when used as `ship id x...` or `sh id x...`.

## Options

The syntax of `options` is very similar to `commands`, except that
the name of a option may start with a `-` or `--`, followed by its
aliases. By default, every option is considered a flag (ie, a boolean
option that does not take any arguments), but you can point out that
a particular option should accept an argument, using the syntax
`--option[|-o] <arg>`, the option string should start with its
*long* form (`--option`, for example) and may be optionally followed 
its shorter form (`-o`, for example) and also `<arg>` if the option
should accept any arguments. Notice that the name of the argument
between `<` and `>` does not matter, as the value should be identified
by the `option`'s *long* (or *short*) form in the parsing result.

## Parsing

The result code of the `@program` macro is a `module` named `Program`
that defines a few functions, but the most important is the `parseargs`
function that can be used to parse the command line arguments. By
default, `parseargs` will use `ARGS`, but you can pass custom arguments
if you want.

```julia
command, options, args = Program.parseargs()
```

- `command` is the command passed or a empty string if no command was
detected. Nested commands are joined with a `.` character.

- `options` is a `Dict`-like object that stores each `option` with
its associated `value`.

- `args` is the remaining arguments (not command nor option).

## Help message

`Program` also defines a constant `help` variable that
you can use to show the help message of your program.

## Example

Using the [example.jl](./example.jl) script and running on `bash`, we can
see the results of the parsing:

```
> ./example.jl sum x y z -f --precision Float64
0.000027 seconds (25 allocations: 2.375 KiB)
command = "sum"
args = ["x", "y", "z"]
options = Options:
   --version => false
   --fastmath => true
   --help => false
   --precision => "Float64"
```

With nested commands:

```
./example.jl sum mult a b c --precision Foo
0.000028 seconds (27 allocations: 2.438 KiB)
command = "sum.mult"
args = ["a", "b", "c"]
options = Options:
   --version => false
   --fastmath => false
   --help => false
   --precision => "Foo"
```

Passing non existent options will result in a error:

```
> ./example.jl sum x y z -f -q Float64
Unknown option: -q
```

Not providing a non-boolean option a value will also result in a error:

```
> ./example.jl sum x y --precision
Missing argument for option: --precision
```

The program help message is automatically generated:

```
> ./example.jl --help
  0.000030 seconds (24 allocations: 2.297 KiB)
A simple calculator

Usage: calculator <command> <args>... [options]

Commands:
    sum                  Returns the sum of <numbers>...
    subtract, sub        Subtract <numbers>...
    multiply, mul        Multiply <numbers>...
    divide, div          Divide two numbers <x> and <y>
    power, pow           Raise <x> to the power of <y>
    sum mult, m          Multiply each <numbers>... and sum the result


Options:
    --help, -h           Show this help message and exit
    --version, -v        Show version information and exit
    --fastmath, -f       Use fastmath. (default: false)
    --precision <p>      Choose float point precision. (default: Float32)
```

> Ignore the `time` and `allocation` information at the beginning 
> of the help message as is only displayed in this case because 
> of the use of `@time` at [example.lj:33](./example.jl#L33).