module Argz

using MacroTools

export @program

function normargs(args::Vector{String})
    res = String[]
    for arg in args
        if occursin(r"^-\w{2,}$", arg)
            append!(res, "-" .* split(arg[2:end], ""))
        else
            push!(res, arg)
        end
    end
    return res
end

include("program.jl")

end # module