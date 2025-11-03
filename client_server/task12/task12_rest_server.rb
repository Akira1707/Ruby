require 'webrick'
require 'json'

# Get port from arguments or use default 4567
port = (ARGV[0] || 4567).to_i

# Create a simple HTTP server using WEBrick
server = WEBrick::HTTPServer.new(Port: port)

# Define the REST endpoint /convert
server.mount_proc '/convert' do |req, res|
  if req.request_method == 'POST'
    begin
      # Parse incoming JSON body
      payload = JSON.parse(req.body)
      text = payload['text'].to_s

      # Compute metrics: text length and number of words
      words = text.scan(/\S+/).size

      # Return JSON response
      res['Content-Type'] = 'application/json'
      res.body = { length: text.length, words: words }.to_json

    rescue => e
      # Invalid JSON
      res.status = 400
      res.body = { error: 'invalid json' }.to_json
    end
  else
    # Only POST method is allowed
    res.status = 405
    res.body = { error: 'use POST' }.to_json
  end
end

# Graceful shutdown on Ctrl+C
trap 'INT' do server.shutdown end

puts "REST server running on port #{port}"
server.start
