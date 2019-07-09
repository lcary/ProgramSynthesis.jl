"""
Main entry point for DreamCore.

Usage:

    julia --project=PROJECT_DIR PROJECT_DIR/bin/main.jl enumerate msg.json

"""
module DreamCoreMain

using DreamCore

command = ARGS[1]
if command == "enumerate"
    request_message_file = ARGS[2]
    response_message_file = DreamCore.run_enumeration(request_message_file)
end
println(response_message_file)

end
