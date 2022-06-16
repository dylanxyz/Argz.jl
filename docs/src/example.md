```@setup script
using Argz
using Markdown

root = dirname(dirname(pathof(Argz)))

macro shell(expr)
    @assert Meta.isexpr(expr, :(=))
    left, cmd = expr.args
    quote
        $expr
        Markdown.MD(Markdown.Code("bash", "\$ " * join($cmd.exec, " ")))
    end |> esc
end

function runscript(command)
    out = IOBuffer()
    err = IOBuffer()

    try
        cd(root)
        if Sys.iswindows()
            bash = joinpath(Sys.which("git") |> dirname |> dirname |> dirname, "bin", "bash.exe")
            run(pipeline(`$bash $command`, stdout=out, stderr=err))
        else
            run(pipeline(`$command $args`, stdout=out, stderr=err))
        end
    catch e
        # ignore
    end

    out = String(take!(out)) |> strip
    err = String(take!(err)) |> strip

    if !isempty(out)
        println(out)
    elseif !isempty(err)
        err = split(err, "Stacktrace:") |> first |> strip
        println(err)
    end
end
```

# Example

Using the [example.jl](https://github.com/dylanxyz/Argz.jl/blob/main/example.jl) 
script and running on `bash`, we can see the results of the parsing:

```@example script
@shell script = `./example.jl sum x y z -f --precision Float64` # hide
```

```@example script
runscript(script) # hide
```

## Nested commands

Nested commands are concatenated with a `.` character.

```@example script
@shell script = `./example.jl sum mult a b c --precision Foo` # hide
```

```@example script
runscript(script) # hide
```

## Parsing Errors

Passing non existent options will result in a error:

```@example script
@shell script = `./example.jl sum x y z -f -q Float64` # hide
```

```@example script
runscript(script) # hide
```

Not providing a non-boolean option a value will also result in a error:

```@example script
@shell script = `./example.jl sum x y --precision` # hide
```

```@example script
runscript(script) # hide
```

## Rest Arguments

Arguments located after `--` are treated as normal arguments.

```@example script
@shell script = `./example.jl sum x y z -vf --precision=Float32 -- a b c --foo=bar -xyz` # hide
```

```@example script
runscript(script) # hide
```

## Help Message and Version

The `program`'s help message is automatically generated. By default,
the `program` will display its help message if the flags `--help` or
`-h` are used and its version if the flag `--version` is used.

```@example script
@shell script = `./example.jl --version` # hide
```

```@example script
runscript(script) # hide
```

```@example script
@shell script = `./example.jl --help` # hide
```

```@example script
runscript(script) # hide
```
