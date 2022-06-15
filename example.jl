#!/bin/bash

#=
exec julia -q --project=@. --startup-file=no --color=yes "${BASH_SOURCE[0]}" "$@"
exit 0
=#

using Argz

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

@time command, args, options, flags = parseargs()
@show command
@show args
@show options
@show flags