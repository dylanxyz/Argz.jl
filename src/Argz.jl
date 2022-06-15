module Argz

using MacroTools

export @program
export normargs

const opt_arg_re = r" *<(.+)> *$"

let flag = raw"^-\w.*$", option = raw"^--\w.+(=.*)*$"
    @eval const flag_re = Regex($flag)
    @eval const option_re = Regex($option)
    @eval const option_or_flag_re = Regex($flag * "|" * $option)
end

const multi_flag_re = r"^-\w.+$"
const option_eq_re = r"^--(\w.+)=(.*)$"

"""
        normargs(args::Vector{String}) -> Vector{String}

Normalize `args`, i.e, transforming `-xyz` into `-x -y -z`
and `--foo=bar` into `--foo bar`. 

Normalization doesn't affect arguments located after `--`.
"""
function normargs(args::Vector{String})
    res = String[]
    for i in eachindex(args)
        arg = @inbounds args[i]
        if arg == "--"
            append!(res, @inbounds args[i:end])
            break
        end

        if occursin(multi_flag_re, arg)
            append!(res, ["-$char" for char in @inbounds arg[2:end]])
            continue
        end

        m = match(option_eq_re, arg)
        if !isnothing(m)
            append!(res, [m[1], m[2]])
            continue
        end

        push!(res, arg)
    end
    return res
end

macro normargs()
    normargs(ARGS)
end

Base.@kwdef mutable struct Program
    name    ::Any   = Expr(:string)
    desc    ::Any   = Expr(:string)
    usage   ::Any   = Expr(:string)
    version ::Any   = v"0.1.0"
    options ::Vector = []
    commands::Vector = []

    # aditional options
    show_help       ::Bool = true
    show_version    ::Bool = true
    exit_onhelp     ::Bool = true
    exit_onversion  ::Bool = true
    throw_error     ::Bool = true
end

include("utils.jl")
include("parsing.jl")
include("program.jl")
include("precompile.jl")

end # module