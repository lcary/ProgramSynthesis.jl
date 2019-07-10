"""
Main entry point for DreamCore.

Usage:

    julia --project=PROJECT_DIR PROJECT_DIR/bin/main.jl enumerate msg.json

"""
module DreamCoreMain

using DreamCore

struct MissingRequiredArg <: Exception
    msg::AbstractString
end

command = ARGS[1]
if command == "enumerate"
    if length(ARGS) < 2
        throw(MissingRequiredArg("Missing required path to JSON file."))
    end
    request_message_file = ARGS[2]
    response_message_file = run_enumeration(request_message_file)
end
println(response_message_file)

end
