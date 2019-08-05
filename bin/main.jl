"""
Main entry point for ProgramSynthesis.

Usage:

    julia --project=PROJECT_DIR PROJECT_DIR/bin/main.jl enumerate msg.json

"""
module ProgramSynthesisMain

using ProgramSynthesis

command = ARGS[1]
if command == "enumerate"
    if length(ARGS) < 2
        error("Missing required path to JSON file.")
    end
    request_message_file = ARGS[2]
    response_message_file = run_enumeration(request_message_file)
    println(response_message_file)
else
    error("unknown command")
end

end
