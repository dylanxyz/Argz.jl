using Argz
using Test

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

Program.__TESTING__[] = true

@testset "calculator" begin
    @test Program.__name__ == "calculator"
    @test Program.__desc__ == "A simple calculator"
    @test Program.__usage__ == "calculator <command> <args>... [options]"
    @test Program.__version__ == v"0.1.0"
    @test Program.help isa String

    arguments = split("sum 1 2 3 4 -h -v --fastmath --precision Float64", " ")
    cmd, opts, args = Program.parseargs((arguments...,))

    @test cmd == "sum"
    @test "--help" in opts
    @test "--version" in opts
    @test "--fastmath" in opts
    @test "--precision" in opts
    @test opts["--precision"] == "Float64"
    @test args == ["1", "2", "3", "4"]

    arguments = split("sum 1 2 3 -q", " ")
    @test_throws Exception Program.parseargs((arguments...,))

    arguments = split("sum mult 1 2 3 4", " ")
    cmd, opts, args = Program.parseargs((arguments...,))

    @test cmd == "sum.mult"
    @test "--help" ∉ opts
    @test "--version" ∉ opts
    @test "--precision" ∉ opts
    @test opts["--precision"] == ""
    @test args == ["1", "2", "3", "4"]

    arguments = split("sum m 1 2 3", " ")
    cmd, opts, args = Program.parseargs((arguments...,))

    @test cmd == "sum.mult"
    @test "--help" ∉ opts
    @test "--version" ∉ opts
    @test "--precision" ∉ opts
    @test opts["--precision"] == ""
    @test args == ["1", "2", "3"]
end