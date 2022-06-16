var documenterSearchIndex = {"docs":
[{"location":"usage/","page":"Usage","title":"Usage","text":"using Argz","category":"page"},{"location":"usage/#Usage","page":"Usage","title":"Usage","text":"","category":"section"},{"location":"usage/","page":"Usage","title":"Usage","text":"Argz exports a single macro @program, and you can use as following:","category":"page"},{"location":"usage/","page":"Usage","title":"Usage","text":"const program = @program begin\n    name = \"calculator\"\n    desc = \"A simple calculator\"\n    usage = \"calculator <command> <args>... [options]\"\n    version = v\"0.1.0\"\n\n    # additional options\n    show_help       = true # show help message when the flag '--help|-h' is passed\n    show_version    = true # show version message when the flag '--version' is passed\n    throw_error     = true # throw errors when invalid options are used\n    exit_onhelp     = true # exit when the flag '--help|-h' is passed\n    exit_onversion  = true # exit when the flag '--version' is passed\n    \n    commands = {\n        \"sum\"                       \"Returns the sum of <numbers>...\"\n        \"subtract|sub\"              \"Subtract <numbers>...\"\n        \"multiply|mul\"              \"Multiply <numbers>...\"\n        \"divide|div\"                \"Divide two numbers <x> and <y>\"\n        \"power|pow\"                 \"Raise <x> to the power of <y>\"\n        \"sum mult|m\"                \"Multiply each <numbers>... and sum the result\"\n    }\n\n    options = {\n        \"--help|-h\"                 \"Show this help message and exit\"\n        \"--version|-v\"              \"Show version information and exit\"\n        \"--fastmath|-f\"             \"Use fastmath. (default: false)\"\n        \"--precision <p>\"           \"Choose float point precision. (default: Float32)\"\n    }\nend","category":"page"},{"location":"usage/","page":"Usage","title":"Usage","text":"The input of the @program macro is a block expression.  Each expression within the block must be an assignment  expression =. Names of the defined variables within the block are properties in the resulting program.","category":"page"},{"location":"usage/#Program-Properties","page":"Usage","title":"Program Properties","text":"","category":"section"},{"location":"usage/","page":"Usage","title":"Usage","text":"The properties that the program may have are:","category":"page"},{"location":"usage/","page":"Usage","title":"Usage","text":"Property Type Description\nname* String The name of the program\ndesc String The description of the program (default: \"\")\nusage String The text that should be displayed in the Usage section of the program's help message (default: \"\")\nversion VersionNumber The program's version to be displayed when the flag --version is used (default: v\"0.1.0\")\nshow_help Bool Whether or not to display the program's help message when the flag --help or -h is used (default: true)\nshow_version Bool Whether or not to display the program's version when the flag --version is used (default: true)\nthrow_error Bool Raise a Exception when a parsing error occurs, for example when a invalid option is used (default: true)\nexit_onhelp Bool Whether or not to exit the current process when the flag --help or -h is used. (default: true)\nexit_onversion Bool Whether or not to exit the current process when the flag --version is used. (default: true)","category":"page"},{"location":"usage/","page":"Usage","title":"Usage","text":"Properties marked with a * are required.","category":"page"},{"location":"usage/","page":"Usage","title":"Usage","text":"The properties commands and options are special and are parsed differently from the above properties (explained more below).","category":"page"},{"location":"usage/#Commands","page":"Usage","title":"Commands","text":"","category":"section"},{"location":"usage/","page":"Usage","title":"Usage","text":"The syntax for the commands expression is {\"cmd\" \"description\"; ...},  where can be used exactly as a julia matrix literal, where each row  defines a different command with its optional description. The synax  for the command string itself is name[|alias] where name  is the  command's identifier in the parsing result. Commands can be nested  by separating then with spaces. For example, a  command of ship should  be valid when used as ship x.., a command of ship|sh should be valid  when used as ship x... or sh x..., and a command ship|sh id should  be valid when used as ship id x... or sh id x....","category":"page"},{"location":"usage/#Options","page":"Usage","title":"Options","text":"","category":"section"},{"location":"usage/","page":"Usage","title":"Usage","text":"The syntax of options is very similar to commands, except that the name of a option may start with a - or --, followed by its aliases. By default, every option is considered a flag (ie, a boolean option that does not take any arguments), but you can point out that a particular option should accept an argument, using the syntax --option[|-o] <arg>, the option string should start with its long form (--option, for example) and may be optionally followed  its shorter form (-o, for example) and also <arg> if the option should accept any arguments. Notice that the name of the argument between < and > does not matter, as the value should be identified by the option's long (or short) form in the parsing result.","category":"page"},{"location":"usage/#Parsing","page":"Usage","title":"Parsing","text":"","category":"section"},{"location":"usage/","page":"Usage","title":"Usage","text":"The @program macro defines two functions: help(), that should be used to retrieve the program's help message, and parseargs that should be used to actually parse the provided arguments. The resulting expression of the macro itself is a NamedTuple where each field is a property of the program.","category":"page"},{"location":"usage/","page":"Usage","title":"Usage","text":"command, args, options, flags = parseargs()","category":"page"},{"location":"usage/","page":"Usage","title":"Usage","text":"command is the command passed or a empty string if no command was detected. Nested commands are joined with a . character.\nargs is the remaining arguments (not command nor option nor flag).\noptions is a Dict that stores each (non-boolean) option with its associated value.\nflags is a Vector that stores each flag used.","category":"page"},{"location":"usage/","page":"Usage","title":"Usage","text":"By default, parseargs will use the normalized version of ARGS, but you can pass custom arguments as a Vector{String}.","category":"page"},{"location":"usage/#Rest-Arguments-and-Normalization","page":"Usage","title":"Rest Arguments & Normalization","text":"","category":"section"},{"location":"usage/","page":"Usage","title":"Usage","text":"Sometimes is useful for a program to parse an argument starting with a - followed by multiple characters as multiple flags joined together. For example, -abc should be equivalent to -a -b -c. Is also useful to accept options initialized with a = character followed by their value. For example, --foo=bar should be equivalent to --foo bar. Argz exports a helper function called normargs that accomplish this task.","category":"page"},{"location":"usage/","page":"Usage","title":"Usage","text":"join(normargs([\"-f\", \"-xyz\", \"--foo\", \"--precision=value\"]), \" \")","category":"page"},{"location":"usage/","page":"Usage","title":"Usage","text":"Arguments located after -- are ignored:","category":"page"},{"location":"usage/","page":"Usage","title":"Usage","text":"join(Argz.normargs([\"-f\", \"-xyz\", \"--\", \"-abc\", \"--foo\", \"--precision=value\"]), \" \")","category":"page"},{"location":"usage/","page":"Usage","title":"Usage","text":"Sometimes a program may accept additional arguments and options and then pass it to another program, generally these arguments and  options are placed after a special argument --. Argz treats options and flags placed after -- as normal arguments.","category":"page"},{"location":"usage/","page":"Usage","title":"Usage","text":"Note that the special argument -- is not excluded  from the resulting args array.","category":"page"},{"location":"#Argz.jl","page":"Home","title":"Argz.jl","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"Argz is a simple command-line argument parser for julia.","category":"page"},{"location":"#Installation","page":"Home","title":"Installation","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"Argz is not yet in the julia public registry, but you can  install directly from this repo:","category":"page"},{"location":"","page":"Home","title":"Home","text":"From the command line","category":"page"},{"location":"","page":"Home","title":"Home","text":"julia -e 'import Pkg; Pkg.pkg\"add https://github.com/dylanxyz/Argz.jl\"'","category":"page"},{"location":"","page":"Home","title":"Home","text":"From the julia REPL","category":"page"},{"location":"","page":"Home","title":"Home","text":"julia> ]\npkg> add https://github.com/dylanxyz/Argz.jl","category":"page"},{"location":"example/#Example","page":"Example","title":"Example","text":"","category":"section"},{"location":"example/","page":"Example","title":"Example","text":"Using the example.jl  script and running on bash, we can see the results of the parsing:","category":"page"},{"location":"example/","page":"Example","title":"Example","text":"$ ./example.jl sum x y z -f --precision Float64","category":"page"},{"location":"example/","page":"Example","title":"Example","text":"println(\"./example.jl sum x y z -f --precision Float64 | bash\") # hide","category":"page"},{"location":"example/#Nested-commands","page":"Example","title":"Nested commands","text":"","category":"section"},{"location":"example/","page":"Example","title":"Example","text":"Nested commands are concatenated with a . character.","category":"page"},{"location":"example/","page":"Example","title":"Example","text":"$ ./example.jl sum mult a b c --precision Foo","category":"page"},{"location":"example/","page":"Example","title":"Example","text":"println(\"./example.jl sum mult a b c --precision Foo | bash\") # hide","category":"page"},{"location":"example/#Parsing-Errors","page":"Example","title":"Parsing Errors","text":"","category":"section"},{"location":"example/","page":"Example","title":"Example","text":"Passing non existent options will result in a error:","category":"page"},{"location":"example/","page":"Example","title":"Example","text":"$ ./example.jl sum x y z -f -q Float64","category":"page"},{"location":"example/","page":"Example","title":"Example","text":"println(\"./example.jl sum x y z -f -q Float64 | bash\") # hide","category":"page"},{"location":"example/","page":"Example","title":"Example","text":"Not providing a non-boolean option a value will also result in a error:","category":"page"},{"location":"example/","page":"Example","title":"Example","text":"$ ./example.jl sum x y --precision","category":"page"},{"location":"example/","page":"Example","title":"Example","text":"println(\"./example.jl sum x y --precision | bash\") # hide","category":"page"},{"location":"example/#Rest-Arguments","page":"Example","title":"Rest Arguments","text":"","category":"section"},{"location":"example/","page":"Example","title":"Example","text":"Arguments located after -- are treated as normal arguments.","category":"page"},{"location":"example/","page":"Example","title":"Example","text":"$ ./example.jl sum x y z -vf --precision=Float32 -- a b c --foo=bar -xyz","category":"page"},{"location":"example/","page":"Example","title":"Example","text":"println(\"./example.jl sum x y z -vf --precision=Float32 -- a b c --foo=bar -xyz | bash\") # hide","category":"page"},{"location":"example/#Help-Message-and-Version","page":"Example","title":"Help Message and Version","text":"","category":"section"},{"location":"example/","page":"Example","title":"Example","text":"The program's help message is automatically generated. By default, the program will display its help message if the flags --help or -h are used and its version if the flag --version is used.","category":"page"},{"location":"example/","page":"Example","title":"Example","text":"$ ./example.jl --version","category":"page"},{"location":"example/","page":"Example","title":"Example","text":"println(\"./example.jl --version | bash\") # hide","category":"page"},{"location":"example/","page":"Example","title":"Example","text":"$ ./example.jl --help","category":"page"},{"location":"example/","page":"Example","title":"Example","text":"println(\"./example.jl --help | bash\") # hide","category":"page"}]
}
