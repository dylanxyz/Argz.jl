spaces(n::Integer) = repeat(" ", n)
ssplit(vec, c) = string.(strip.(split(vec, c)))
isoption(s::String) = occursin(opt_arg_re, s)

struct InvalidOption <: Exception
    option::String
end

struct MissingOptValue <: Exception
    option::String
end

function Base.showerror(io::IO, e::InvalidOption)
    print(io, "InvalidOption: unknown option/flag")
    print(io, e.option)
end

function Base.showerror(io::IO, e::MissingOptValue)
    print(io, "MissingOptValue: ")
    print(io, "missing value for option ")
    print(io, e.option)
end