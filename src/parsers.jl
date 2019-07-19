module Parsers

using ..Programs

export parse_program, parse_s_expression, ParseFailure

struct ParseFailure <: Exception
    msg::String
end

struct ParseSExprFailure <: Exception
    msg::String
end

function parse_s_expression(s::String)
    s = strip(s)
    function p(n)
        while n <= length(s) + 1 && isspace(s[n])
            n += 1
        end
        if n == length(s) + 1
            throw(ParseSExprFailure("Failed to parse string: $s"))
        end
        if s[n] == '#'
            e, n = p(n + 1)
            return ['#', e], n
        end
        if s[n] == '('
            l = []
            n += 1
            while true
                x, n = p(n)
                push!(l, x)
                while n <= length(s) + 1 && isspace(s[n])
                    n += 1
                end
                if n == length(s) + 1
                    throw(ParseSExprFailure("Failed to parse string: $s"))
                end
                if s[n] == ')'
                    n += 1
                    break
                end
            end
            return l, n
        end
        name = []
        while n < length(s) + 1 && !isspace(s[n]) && s[n] != '(' && s[n] != ')'
            push!(name, s[n])
            n += 1
        end
        name = join(name, "")
        return name, n
    end
    e, n = p(1)
    if n == length(s) + 1
        return e
    end
    throw(ParseSExprFailure("Failed to parse string: $s"))
end

function parse_program(s::String, primitives::Dict{String,Primitive})
    s = parse_s_expression(s)
    function p(e)
        if isa(e, Array)
            # TODO: implement invented
            # if e[1] == "#"
            #     if length(e) != 2
            #         throw(ParseFailure("Invented program $e must have 2 parts"))
            #     end
            #     return Invented(p(e[2]))
            # end
            if e[1] == "lambda"
                if length(e) != 2
                    throw(ParseFailure("Abstraction $e must have 2 parts"))
                end
                return Abstraction(p(e[2]))
            end
            f = p(e[1])
            for x in e[2:end]
                f = Application(f, p(x))
            end
            return f
        end
        if e[1] == '$'
            return DeBruijnIndex(parse(Int, e[2:end]))
        end
        if haskey(primitives, e)
            prim = primitives[e]
            # TODO: Maybe don't convert primitives to programs?
            return Program(
                e,
                prim.func,
                prim.type
            )
        end
        throw(ParseFailure("Unable to parse Program from string ($s)."))
    end
    return p(s)
end

end
