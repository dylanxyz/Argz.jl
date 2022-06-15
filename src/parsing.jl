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