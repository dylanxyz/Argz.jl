_expr(self::Program) = :((
    name = $(self.name),
    desc = $(self.desc),
    usage = $(self.usage),
    version = $(self.version),
))

function help(program::Program)
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

macro program(expr)
    expr = expr::Expr
    program = parse_program(expr.args)

    commands = parse_commands(program)
    options  = parse_options(program)
    flags    = parse_flags(program)

    res = quote
        help() = $(help(program))

        function parseargs(args::Vector{String} = $(normargs(ARGS)))
            command   = ""
            arguments = String[]
            options   = Dict{String, String}()
            flags     = String[]
            i = 1
            while i <= length(args)
                arg = args[i]

                if arg == "--"
                    append!(arguments, args[i:end])
                    break
                end

                if occursin(Argz.option_or_flag_re, arg)
                    $(options...)
                    $(flags...)
                    if $(program.throw_error)
                        throw(Argz.InvalidOption(arg))
                    end
                end
                
                $(commands...)
                push!(arguments, arg)
                i += 1
            end
            
            if $(program.show_help)
                if "--help" in flags || "-h" in flags
                    println(help())
                    if $(program.exit_onhelp)
                        exit(0)
                    end
                end
            end

            if $(program.show_version)
                if "--version" in flags
                    println($(Expr(:string, program.name, " v", program.version)))
                    if $(program.exit_onversion)
                        exit(0)
                    end
                end
            end

            return (; command, args=arguments, options, flags)
        end
           
        precompile(Tuple{typeof(parseargs), Vector{String}})

        $(_expr(program))
    end

    res = postwalk(res) do expr
        if @capture(expr, if (true); block_; end)
            return block
        elseif @capture(expr, if (false); block_; end)
            return nothing
        else
            return expr
        end
    end

    return esc(postwalk(unblock, res))
end