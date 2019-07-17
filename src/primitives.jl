module Primitives

export base_primitives

using ..Types
using ..Programs

const PRIMES = [
    2,
    3,
    5,
    7,
    11,
    13,
    17,
    19,
    23,
    29,
    31,
    37,
    41,
    43,
    47,
    53,
    59,
    61,
    67,
    71,
    73,
    79,
    83,
    89,
    97,
    101,
    103,
    107,
    109,
    113,
    127,
    131,
    137,
    139,
    149,
    151,
    157,
    163,
    167,
    173,
    179,
    181,
    191,
    193,
    197,
    199]

struct NotImplementedError <: Exception end

function base_primitives()::Dict{String,Primitive}

    index_type = arrow(tint, tlist(t0), t0)
    length_type =  arrow(tlist(t0), tint)
    map_type = arrow(arrow(t0, t1), tlist(t0), tlist(t1))
    unfold_type = arrow(
        t0, arrow(t0,tbool), arrow(t0,t1), arrow(t0,t0), tlist(t1))
    fold_type = arrow(tlist(t0), t1, arrow(t0, t1, t1), t1)
    math_type = arrow(tint, tint, tint)
    comparison_type = arrow(tint, tint, tbool)

    _unfold = (n) -> throw(NotImplementedError)
    _range = (n) -> Array(range(1, length=n))
    _fold = (n) -> throw(NotImplementedError)
    _if = (c) -> (x) -> (y) -> c ? x : y
    _cons = (x) -> (y) -> prepend!(y, x)
    _is_empty = (x) -> x == []
    _is_prime = (n) -> n in PRIMES
    _is_square = (n) -> round(sqrt(n)) ^ 2 == n

    return Dict(
        "0" => Primitive("0", tint, 0),
        "1" => Primitive("1", tint, 1),
        "2" => Primitive("2", tint, 2),
        "3" => Primitive("3", tint, 3),
        "4" => Primitive("4", tint, 4),
        "5" => Primitive("5", tint, 5),
        "6" => Primitive("6", tint, 6),
        "7" => Primitive("7", tint, 7),
        "8" => Primitive("8", tint, 8),
        "9" => Primitive("9", tint, 9),
        "index" => Primitive("index", index_type, (x) -> (y) -> y[x]),
        "length" => Primitive("length", length_type, (x) -> length(x)),
        "map" => Primitive("map", map_type, (x) -> (y) -> map(x, y)),
        "unfold" => Primitive("unfold", unfold_type, _unfold),
        "range" => Primitive("range", arrow(tint, tlist(tint)), _range),
        "fold" => Primitive("fold", fold_type, _fold),
        "if" => Primitive("if", arrow(tbool, t0, t0, t0), _if),
        "+" => Primitive("+", math_type, (x) -> (y) -> (x + y)),
        "-" => Primitive("-", math_type, (x) -> (y) -> (x - y)),
        "empty" => Primitive("empty", tlist(t0), () -> []),
        "cons" => Primitive("cons", arrow(t0, tlist(t0), tlist(t0)), _cons),
        "car" => Primitive("car", arrow(tlist(t0), t0), (x) -> x[1]),
        "cdr" => Primitive("cdr", arrow(tlist(t0), tlist(t0)), (x) -> x[2:end]),
        "empty?" => Primitive("empty?", arrow(tlist(t0), tbool), _is_empty),
        "*" => Primitive("*", math_type, (x) -> (y) -> (x * y)),
        "mod" => Primitive("mod", math_type, (x) -> (y) -> (x % y)),
        "gt?" => Primitive("gt?", comparison_type, (x) -> (y) -> (x > y)),
        "eq?" => Primitive("eq?", comparison_type, (x) -> (y) -> (x == y)),
        "is-prime" => Primitive("is-prime", arrow(tint, tbool), _is_prime),
        "is-square" => Primitive("is-square", arrow(tint, tbool), _is_square),
    )
end

end
