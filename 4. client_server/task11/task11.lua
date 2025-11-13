local socket = require("socket")

-- Server configuration
local host = "127.0.0.1"
local port = 3000

-- Read commands from input file
local input_file = "client_input.txt"
local output_file = "client_output.txt"

local commands = {}
for line in io.lines(input_file) do
    table.insert(commands, line)
end

-- Connect to server
local client = assert(socket.tcp())
assert(client:connect(host, port))
client:settimeout(5)  -- 5 seconds timeout

local results = {}

-- Send commands and receive responses
for _, cmd in ipairs(commands) do
    assert(client:send(cmd .. "\n"))  -- send command with newline
    local response, err = client:receive("*l")  -- read line
    if response then
        table.insert(results, response)
    else
        table.insert(results, "Error: " .. tostring(err))
    end
end

client:close()

-- Write results to output file
local f = assert(io.open(output_file, "w"))
for _, res in ipairs(results) do
    f:write(res, "\n")
end
f:close()

print("Client finished. Results saved to " .. output_file)
