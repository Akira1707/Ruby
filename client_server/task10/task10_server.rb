require 'socket'
require 'thread'

# Check command-line arguments
if ARGV.length < 1
  puts "Usage: ruby task10_server.rb input.txt [port]"
  exit 1
end

quotes_file = ARGV[0]
port = (ARGV[1] || 4000).to_i

# Read quotes from file
quotes = File.exist?(quotes_file) ? File.readlines(quotes_file, chomp: true) : []

# Create TCP server
server = TCPServer.new('0.0.0.0', port)
puts "Server listening on #{port}"

log_mutex = Mutex.new

# Accept clients in an infinite loop
while client = server.accept
  # Handle each client in a separate thread
  Thread.new(client) do |c|
    begin
      while line = c.gets
        line = line.strip
        if line.upcase == 'QUOTE'
          # Return random quote
          c.puts(quotes.sample || "No quotes available")
        elsif line.start_with?('ECHO:')
          # Return message after ECHO:
          c.puts(line.sub(/^ECHO:/,''))
        else
          c.puts("UNKNOWN COMMAND")
        end

        # Optional logging to file
        log_mutex.synchronize do
          File.open('ouput.txt','a') do |f|
            f.puts("#{Time.now.iso8601} #{c.peeraddr[3]} #{line}")
          end
        end
      end
    rescue => e
      # ignore errors
    ensure
      c.close
    end
  end
end
