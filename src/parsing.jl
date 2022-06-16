function parse_command(i; command, names, prev_cmd)
    if i == 1
        quote
            if isempty(command) && arg in $names
                command = $(command)
                i += 1
                continue
            end
        end
    else
        quote
            if command == $prev_cmd && arg in $names
                if isempty(command)
                    command = $(command)
                else
                    command *= "." * $(command)
                end
                i += 1
                continue
            end
        end
    end
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
            push!(res, parse_command(i; command, names, prev_cmd))
            prev_cmd *= isempty(prev_cmd) ? command : "." * command
        end
    end
    return res
end

parse_option(program; option, aliases) = quote
    if arg in $(aliases...,)
        i += 1
        if i <= length(args) && !startswith(args[i], "-")
            options[$option] = @inbounds args[i]
            i += 1
            continue
        else
            if $(program.throw_error)
                throw(Argz.MissingOptValue(arg))
            end
        end
    end
end

function parse_options(program::Program)
    options = filter(isoption, first.(program.options))
    return map(options) do option
        option = replace(option, opt_arg_re => "")
        aliases = ssplit(option, "|")
        option = first(aliases)
        parse_option(program; aliases, option)
    end
end

parse_flag(; flag, aliases) = quote
    if arg in $(aliases...,)
        push!(flags, $flag)
        i += 1
        continue
    end
end

function parse_flags(program::Program)
    flags = filter(!isoption, first.(program.options))
    return map(flags) do flag
        aliases = ssplit(flag, "|")
        flag = first(aliases)
        parse_flag(; aliases, flag)
    end
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