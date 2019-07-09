#!/usr/bin/env julia

using DreamCore
using Test

@test DreamCore.greet() == "Hello World!"
@test typeof(greet_alien()) == String
@test greet_alien()[1:5] == "Hello"
include("test1.jl")
