"""
Executable entry point for PackageCompiler:
https://github.com/JuliaLang/PackageCompiler.jl#building-an-executable

To compile, clone the repo, cd into, add its deps via julia CLI and then run:

    julia --project ./juliac.jl -aeq ../DreamCore.jl/bin/executable.jl --outname dreamcore
    ./builddir/dreamcore

Tested with PackageCompiler@602f2b093308ac6cb6385d2dc5f4bf9f6a8e514e
"""
module DreamCoreExecutable

using DreamCore

Base.@ccallable function julia_main(ARGS::Vector{String})::Cint
    #hello_main(ARGS)  # call your program's logic.
    println(greet_alien())
    return 0
end
end
