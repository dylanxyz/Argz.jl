using Argz
using Test

apply(f::Function) = f()

parseargs(str::String) = parseargs(Argz.normargs(String[split(str, " ")...]))

const program = @program begin
    name = "calculator"
    desc = "A simple calculator"
    usage = "calculator <command> <args>... [options]"
    version = v"0.1.0"

    # additional options
    show_help       = true # show help message when the flag '--help|-h' is passed
    show_version    = true # show version message when the flag '--version' is passed
    throw_error     = true # throw errors when invalid options are used
    exit_onhelp     = false # exit when the flag '--help|-h' is passed
    exit_onversion  = false # exit when the flag '--version' is passed
    
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

@testset "Program" begin
    @test program.name == "calculator"
    @test program.desc == "A simple calculator"
    @test program.usage == "calculator <command> <args>... [options]"
    @test program.version == v"0.1.0"

    @test help() isa String
end

@testset "Basic" begin
    cmd, args, opts, flags = parseargs("sum 1 2 3 4 -vh --fastmath --precision Float64")
    
    @test cmd == "sum"
    @test "--version" in flags
    @test "--help" in flags
    @test "--fastmath" in flags
    @test opts["--precision"] == "Float64"
    @test args == ["1", "2", "3", "4"]
end

@testset "Nested commands" begin
    cmd, args, opts, flags = parseargs("sum mult a b c --precision Float32")
    
    @test cmd == "sum.mult"
    @test "--help" ∉ flags
    @test "--version" ∉ flags
    @test "--fastmath" ∉ flags
    @test opts["--precision"] == "Float32"
    @test args == ["a", "b", "c"]
end

@testset "Exceptions" begin
    @test_throws Exception parseargs("pow 2 3 --non-option")
    @test_throws Exception parseargs("pow 2 3 --precision -v")
end