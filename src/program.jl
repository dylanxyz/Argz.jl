const opt_arg_re = r" *<(.+)> *$"

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

_expr(self::Program) = :((
    name = $(self.name),
    desc = $(self.desc),
    usage = $(self.usage),
    version = $(self.version),
))

spaces(n::Integer) = repeat(" ", n)
ssplit(vec, c) = string.(strip.(split(vec, c)))

function _help(program::Program)
    cmds = program.commands
    opts = program.options

    help = [
        program.desc, "\n\n",
        "Usage: ", program.usage,
    ]

    padding = maximum(length ∘ first, [cmds..., opts...])

    if !isempty(cmds)
        push!(help, "\n\nCommands:\n")
        for (cmd, desc) in cmds
            push!(help, 
                spaces(4), rpad(cmd, padding),
                spaces(4), "$desc\n"
            )
        end
    end

    if !isempty(opts)
        push!(help, "\n\nOptions:\n")
        for (opt, desc) in opts
            push!(help, 
                spaces(4), rpad(opt, padding),
                spaces(4), "$desc\n"
            )
        end
    end

    return Expr(:string, help...)
end

function parse_commands(program::Program)
    res = Expr[]
    cmds = program.commands
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

function parse_options(program::Program)
    res = Expr[]
    opts = program.options
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
            push!(block.args, quote
                i += 1
                if i <= length(args) && !startswith(args[i], "-")
                    options[$option] = @inbounds args[i]
                    i += 1
                else
                    if $(program.throw_error)
                        error("Missing argument for option: $arg")
                    end
                end
            end)
        else
            push!(block.args, 
                :( push!(flags, $option) ),
                :( i += 1 ), 
            )
        end
        
        push!(block.args, :( continue ))
        push!(res, Expr(:if, condition, block))
    end
    return res
end

function parse_program(exprs)
    program = Program()

    for ex in exprs
        if @capture(ex, field_ = value_)
            if field in (:commands, :options)
                @assert isexpr(value, :bracescat)
                array = getproperty(program, field)
                for row in value.args
                    str, desc = isexpr(row, :row) ? row.args : (row, "")
                    push!(array, str => desc)
                end
            elseif field in fieldnames(Program)
                setproperty!(program, field, value)
            else
                error("Unknown program property: `$field`")
            end
        end
    end

    return program
end

macro program(expr)
    expr = expr::Expr
    program = parse_program(expr.args)

    help = _help(program)
    cmds_block = parse_commands(program)
    opts_block = parse_options(program)

    return quote
        help() = $help

        function parseargs(args::Vector{String} = $(normargs(ARGS)))
            command   = ""
            arguments = String[]
            options   = Dict{String, String}()
            flags     = String[]
            i = 1
            while i <= length(args)
                arg = args[i]
                if arg |> startswith("-")
                    $(opts_block...)
                    if $(program.throw_error)
                        error("Unknown option: $arg")
                    end
                end
                $(cmds_block...)
                push!(arguments, arg)
                i += 1
            end
            
            if $(program.show_help)
                if "--help" in flags || "-h" in flags
                    println(help())
                    $(program.exit_onhelp) && exit(0)
                end
            end

            if $(program.show_version)
                if "--version" in flags
                    println($(Expr(:string, program.name, " v", program.version)))
                    $(program.exit_onversion) && exit(0)
                end
            end

            return (; command, args=arguments, options, flags)
        end
           
        precompile(Tuple{typeof(parseargs), Vector{String}})

        $(_expr(program))
    end |> esc
end