#!/bin/bash

#=
exec julia -q --project=@. --startup-file=no --color=yes "${BASH_SOURCE[0]}" "$@"
exit 0
=#

using Argz

@program begin
    name = "calculator"
    desc = "A simple calculator"
    usage = "calculator <command> <args>... [options]"
    version = v"0.1.0"

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

@time command, options, args = Program.parseargs()

if "--help" in options
    println(Program.help)
else
    @show command
    @show args
    @show options
end