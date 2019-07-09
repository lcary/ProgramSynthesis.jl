using Dates

const message_dir = "messages"

function create_message_dir()
    if !isdir(message_dir)
        mkdir(message_dir)
    end
end

function get_response_filename()
    ts = Dates.format(Dates.now(), "yyyymmdd_THH:MM:SS")
    parts = ["enumeration", "message", "PID", getpid(), ts]
    filename = join(parts, "_") * ".json"
    return abspath("messages", filename)
end

function create_response(filepath::String, data)
    stringdata = JSON.json(data)
    open(filepath, "w") do f
        write(f, stringdata)
    end
end

function read_request_data(filepath::String)
    return JSON.parsefile(filepath)
end

function get_response_data(request_data::Dict)
    response_data = Dict()
    for t in request_data["tasks"]
        response_data[t["name"]] = []
    end
    return response_data
end

function run_enumeration(request_file::String)
    create_message_dir()
    request_data = read_request_data(request_file)
    response_file = get_response_filename()
    response_data = get_response_data(request_data)
    create_response(response_file, response_data)
    return response_file
end
