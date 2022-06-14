module Argz

using MacroTools

export @program

function _help(cmds, opts)
    help = Expr(:string, 
        :__desc__, "\n\n", 
        "Usage: ", :__usage__,
    )

    padding = maximum(p -> length(first(p)) + 2, [cmds..., opts...])

    if !isempty(cmds)
        push!(help.args, "\n\nCommands:\n")
        for (cmd, desc) in cmds
            command = join(split(cmd, "|"), ", ")
            push!(help.args, "    " * rpad(command, padding) * "    $desc\n")
        end
    end

    if !isempty(opts)
        push!(help.args, "\n\nOptions:\n")
        for (opt, desc) in opts
            option = join(split(opt, "|"), ", ")
            push!(help.args, "    " * rpad(option, padding) * "    $desc\n")
        end
    end

    return help
end

const opt_arg_re = r" *<(.+)> *$"

ssplit(vec, c) = string.(strip.(split(vec, c)))

function _commands(cmds)
    res = Expr[]
    for (cmd, _) in cmds
        _cmds  = map(s -> ssplit(s, "|"), ssplit(cmd, " "))

        prev_cmd = ""
        for i in 1:length(_cmds)
            _cmd = _cmds[i]
            names = Expr(:tuple, _cmd...)
            command = first(names.args)
            
            if i == 1
                block = :(command = $(command); i += 1; continue)
                condition = length(names.args) == 1 ?
                    :( isempty(command) && arg == $command ) :
                    :( isempty(command) && arg in $names )
                push!(res, Expr(:if, condition, block))
            else
                block = :(begin
                    command *= isempty(command) ? $(command) : "." * $(command)
                    i += 1
                    continue
                end)
                condition = length(names.args) == 1 ?
                    :( command == $prev_cmd && arg == $command ) :
                    :( command == $prev_cmd && arg in $names )
                push!(res, Expr(:if, condition, block))
            end

            prev_cmd *= isempty(prev_cmd) ? command : "." * command
        end
    end
    return res
end

function _options(opts, opt_dict)
    res = Expr[]
    for (opt, _) in opts
        isflag = true
        if occursin(opt_arg_re, opt)
            opt = replace(opt, opt_arg_re => "")
            isflag = false
        end

        names = Expr(:tuple, ssplit(opt, "|")...)
        option = first(names.args)
        block = Expr(:block)
        condition = length(names.args) == 1 ?
            :( arg == $option ) :
            :( arg in $names )


        if !isflag
            push!(opt_dict, :( $option => "" ))
            push!(block.args, quote
                i += 1
                if i <= length(args)
                    options[$option] = @inbounds args[i]
                    i += 1
                else
                    quit("Missing argument for option: $arg", stderr)
                end
            end)
        else
            push!(opt_dict, :( $option => false ))
            push!(block.args, 
                :( options[$option] = true ),
                :( i += 1 ), 
            )
        end
        
        push!(block.args, :( continue ))
        push!(res, Expr(:if, condition, block))
    end
    return res
end

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

macro program(expr, args=ARGS)
    expr = expr::Expr

    params = Expr[]

    cmds = Pair{String, String}[]
    opts = Pair{String, String}[]

    for ex in expr.args
        if @capture(ex, field_ = value_)
            if field ∉ (:commands, :options)
                sym = Symbol("__$(field)__")
                push!(params, :( const $sym = $value ))
            elseif field in (:commands, :options)
                @assert isexpr(value, :bracescat)
                ctx = field == :commands ? cmds : opts
                for row in value.args
                    str, desc = isexpr(row, :row) ? row.args : (row, "")
                    push!(ctx, str => desc)
                end
            end
        end
    end

    opt_dict = Expr[]

    help    = _help(cmds, opts)
    cmds_if = _commands(cmds)
    opts_if = _options(opts, opt_dict)

    arguments = normargs(isexpr(args) ? args.args : args)

    _module = :(module Program
        $(params...)

        const __TESTING__ = Ref(false)
        const help = $(help)

        function quit(msg::String, io)
            if !__TESTING__[]
                println(io, msg)
                io === stderr ? exit(1) : exit(0)
            else
                io = stderr ? error(msg) : println(msg)
            end
        end

        struct Options
            opts::Dict{String, Union{String, Bool}}
        end

        function Base.in(str::AbstractString, self::Options)
            if str in keys(self.opts)
                res = self.opts[str]
                return res isa Bool ? res : !isempty(res)
            end

            return false
        end
        
        Base.getindex(self::Options, key::AbstractString) = self.opts[key]
        Base.setindex!(self::Options, val::AbstractString, key::AbstractString) = setindex!(self.opts, string(val), string(key))
        Base.setindex!(self::Options, val::Bool, key::AbstractString) = setindex!(self.opts, val, string(key))

        function Base.show(io::IO, self::Options)
            write(io, "Options:\n")
            for (key, value) in self.opts
                write(io, "   $key => ")
                show(io, value)
                write(io, "\n")
            end
        end

        function parseargs(args::Vector{String} = $arguments)
            command = ""
            arguments = String[]
            options = Options(Dict($(opt_dict...)))
            
            i = 1
            while i <= length(args)
                arg = args[i]
                if arg |> startswith("-")
                    $(opts_if...)
                    quit("Unknown option: $arg", stderr)
                end

                $(cmds_if...)

                push!(arguments, arg)
                i += 1
            end

            return command, options, arguments
        end

        precompile(Tuple{typeof(parseargs), Vector{String}})
        precompile(Tuple{typeof(in), String, Options})
        precompile(Tuple{typeof(getindex), Options, String})
        precompile(Tuple{typeof(setindex!), Options, String, String})
        precompile(Tuple{typeof(setindex!), Options, Bool, String})
    end)

    return esc(_module)
end

end # module