# Example

Using the [example.jl](https://github.com/dylanxyz/Argz.jl/blob/main/example.jl) 
script and running on `bash`, we can see the results of the parsing:

```bash
$ ./example.jl sum x y z -f --precision Float64
```

```bash
  0.000065 seconds (4 allocations: 256 bytes)
command = "sum"
args = ["x", "y", "z"]
options = Dict("--precision" => "Float64")
flags = ["--fastmath"]
```

## Nested commands

Nested commands are concatenated with a `.` character.

```bash
$ ./example.jl sum mult a b c --precision Foo
```

```bash
  0.000063 seconds (5 allocations: 240 bytes)
command = "sum.mult"
args = ["a", "b", "c"]
options = Dict("--precision" => "Foo")
flags = String[]
```

## Parsing Errors

Passing non existent options will result in a error:

```bash
./example.jl sum x y z -f -q Float64
```

```bash
ERROR: LoadError: InvalidOption: unknown option/flag -q
```

Not providing a non-boolean option a value will also result in a error:

```bash
./example.jl sum x y --precision
```

```bash
ERROR: LoadError: MissingOptValue: missing value for option --precision
```

## Rest Arguments

Arguments located after `--` are treated as normal arguments.

```bash
./example.jl sum x y z -vf --precision=Float32 -- a b c --foo=bar -xyz
```

```bash
  0.000065 seconds (6 allocations: 688 bytes)
command = "sum"
args = ["x", "y", "z", "--", "a", "b", "c", "--foo=bar", "-xyz"]
options = Dict("--precision" => "Float32")
flags = ["--verbose", "--fastmath"]
```

## Help Message and Version

The `program`'s help message is automatically generated. By default,
the `program` will display its help message if the flags `--help` or
`-h` are used and its version if the flag `--version` is used.

```bash
./example.jl --version
```

```bash
calculator v0.1.0
```

```bash
./example.jl --help
```

```bash
A simple calculator

Usage: calculator <command> <args>... [options]

Commands:
    sum                Returns the sum of <numbers>...
    subtract|sub       Subtract <numbers>...
    multiply|mul       Multiply <numbers>...
    divide|div         Divide two numbers <x> and <y>
    power|pow          Raise <x> to the power of <y>
    sum mult|m         Multiply each <numbers>... and sum the result


Options:
    --help|-h          Show this help message and exit
    --version          Show version information and exit
    --verbose|-v       Show version information and exit
    --fastmath|-f      Use fastmath. (default: false)
    --precision <p>    Choose float point precision. (default: Float32)
```
