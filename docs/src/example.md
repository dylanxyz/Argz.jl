# Example

Using the [example.jl](https://github.com/dylanxyz/Argz.jl/blob/main/example.jl) 
script and running on `bash`, we can see the results of the parsing:

```@shell
./example.jl sum x y z -f --precision Float64
```

## Nested commands

Nested commands are concatenated with a `.` character.

```@shell
./example.jl sum mult a b c --precision Foo
```

## Parsing Errors

Passing non existent options will result in a error:

```@shell
./example.jl sum x y z -f -q Float64
```

Not providing a non-boolean option a value will also result in a error:

```@shell
./example.jl sum x y --precision
```

## Rest Arguments

Arguments located after `--` are treated as normal arguments.

```@shell
./example.jl sum x y z -vf --precision=Float32 -- a b c --foo=bar -xyz
```

## Help Message and Version

The `program`'s help message is automatically generated. By default,
the `program` will display its help message if the flags `--help` or
`-h` are used and its version if the flag `--version` is used.

```@shell
./example.jl --version
```

```@shell
./example.jl --help
```