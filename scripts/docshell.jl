#!/bin/bash

#=
exec julia -q --project=@. --startup-file=no --color=yes "${BASH_SOURCE[0]}" -- "$@"
exit 0
=#

using Argz
using Markdown

@static if Sys.iswindows()
    function shell(command)
        git = Sys.which("git")
        isnothing(git) && error("git must be installed on windows")
        bash = dirname(git) |> dirname
        bash = joinpath(dirname(bash), "bin", "bash.exe")
        return `$bash -c "eval \"$command\""`
    end
else
    shell(command) = `echo "$command" | bash`
end

function main(file::String, out::String; raw=false)
    content = read(file, String)
    markdown = Markdown.parse(content)

    io = IOBuffer()
    err = false

    blocks = []

    for block in markdown.content
        if block isa Markdown.Code && block.language == "@shell"
            command = shell(strip(block.code))
            @info "Running command: $(block.code)"

            try
                run(pipeline(command, stdout=io, stderr=io))
            catch
                err = true
            end

            output = strip(String(take!(io)))
            if err && occursin("ERROR", output) && occursin("LoadError: ", output)
                output = first(split(output, "Stacktrace:"))
                output = strip(output)
            end

            println(output)

            block.code = "\$ " * block.code
            block.language = "shell"

            push!(blocks, block)
            
            if raw
                push!(blocks, Markdown.Code("shell", output))
            else
                code_io = IOBuffer()
                print(code_io, "println(")
                show(code_io, output)
                print(code_io, ") # hide")
                push!(blocks, Markdown.Code("@example", String(take!(code_io))))
            end

            println()
        else
            push!(blocks, block)
        end
    end

    markdown.content = blocks
    write(out, string(markdown))

    @info "Done! Output written to $(out)"
end

const program = @program begin
    name = "docshell"
    desc = "Run a shell commands in markdown files and write their output as code blocks"
    usage = "docshell.jl [--out|-o <output>] [--raw] <file>"

    options = {
        "--help|-h"                 "Show this help message and exit"
        "--version"                 "Show version information and exit"
        "--out|-o <output>"         "The path for the output file (default: <file>)"
        "--raw"                     "Write the raw output as a code block"
    }
end

command, args, options, flags = parseargs()

if isempty(args)
    println("Usage: " * program.usage)
    exit(1)
else
    file = first(args)
    out = isempty(options["--out"]) ? file : options["--out"]
    main(file, out; raw = "--raw" in flags)
end