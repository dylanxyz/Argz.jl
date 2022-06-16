```@setup normargs
using Argz
```

## Usage

**Argz** exports a single macro `@program`, and you can use
as following:

```julia
const program = @program begin
    name = "calculator"
    desc = "A simple calculator"
    usage = "calculator <command> <args>... [options]"
    version = v"0.1.0"

    # additional options
    show_help       = true # show help message when the flag '--help|-h' is passed
    show_version    = true # show version message when the flag '--version' is passed
    throw_error     = true # throw errors when invalid options are used
    exit_onhelp     = true # exit when the flag '--help|-h' is passed
    exit_onversion  = true # exit when the flag '--version' is passed
    
    commands = {
        "sum"                       "Returns the sum of <numbers>..."
        "subtract|sub"              "Subtract <numbers>..."
        "multiply|mul"              "Multiply <numbers>..."
        "divide|div"                "Divide two numbers <x> and <y>"
        "power|pow"                 "Raise <x> to the power of <y>"
        "sum mult|m"                "Multiply each <numbers>... and sum the result"
    }

    options = {
        "--help|-h"                 "Show this help message and exit"
        "--version|-v"              "Show version information and exit"
        "--fastmath|-f"             "Use fastmath. (default: false)"
        "--precision <p>"           "Choose float point precision. (default: Float32)"
    }
end
```

The input of the `@program` macro is a `block` expression. 
Each expression within the `block` must be an assignment 
expression `=`. Names of the defined variables within the
`block` are properties in the resulting `program`.

## Program Properties

The properties that the program may have are:

| Property         | Type            | Description                                                                                                     |
|:-----------------|:---------------:|:----------------------------------------------------------------------------------------------------------------|
| name*            | `String`        | The name of the program                                                                                         |
| desc             | `String`        | The description of the program (default: `""`)                                                                  |
| usage            | `String`        | The text that should be displayed in the *Usage* section of the program's help message (default: `""`)          |
| version          | `VersionNumber` | The program's version to be displayed when the flag `--version` is used (default: `v"0.1.0"`)                   |
| show_help        | `Bool`          | Whether or not to display the program's help message when the flag `--help` or `-h` is used (default: `true`)   |
| show_version     | `Bool`          | Whether or not to display the program's version when the flag `--version` is used (default: `true`)             |
| throw_error      | `Bool`          | Raise a `Exception` when a parsing error occurs, for example when a invalid option is used (default: `true`)    |
| exit_onhelp      | `Bool`          | Whether or not to `exit` the current process when the flag `--help` or `-h` is used. (default: `true`)          |
| exit_onversion   | `Bool`          | Whether or not to `exit` the current process when the flag `--version` is used. (default: `true`)               |

> Properties marked with a `*` are required.

The properties `commands` and `options` are *special* and are parsed
differently from the above properties (explained more below).

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

The `@program` macro defines two functions: `help()`, that should be
used to retrieve the `program`'s **help** message, and `parseargs`
that should be used to actually *parse* the provided arguments. The
resulting expression of the macro itself is a `NamedTuple` where
each field is a [property](#Program-Properties) of the `program`.

```julia
command, args, options, flags = parseargs()
```

- `command` is the command passed or a empty string if no command was detected. Nested commands are joined with a `.` character.

- `args` is the remaining arguments (not command nor option nor flag).

- `options` is a `Dict` that stores each (non-boolean) `option` with its associated `value`.

- `flags` is a `Vector` that stores each flag used.

By default, `parseargs` will use the normalized version of `ARGS`, but
you can pass custom arguments as a `Vector{String}`.

## Rest Arguments & Normalization

Sometimes is useful for a `program` to parse an `argument` starting
with a `-` followed by multiple characters as multiple flags joined
together. For example, `-abc` should be equivalent to `-a -b -c`.
Is also useful to accept options initialized with a `=` character
followed by their value. For example, `--foo=bar` should be equivalent
to `--foo bar`. Argz exports a helper function called `normargs` that
accomplish this task.

```@repl normargs
join(normargs(["-f", "-xyz", "--foo", "--precision=value"]), " ")
```

Arguments located after `--` are ignored:

```@repl normargs
join(Argz.normargs(["-f", "-xyz", "--", "-abc", "--foo", "--precision=value"]), " ")
```

Sometimes a `program` may accept additional arguments and options
and then pass it to another program, generally these arguments and 
options are placed after a special argument `--`. Argz treats
options and flags placed after `--` as normal arguments.

> Note that the special argument `--` is not excluded 
> from the resulting `args` array.