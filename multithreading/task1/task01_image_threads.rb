require 'thread'
require 'json'
require 'time'

# Check command-line arguments
if ARGV.length < 2
  puts "Usage: ruby task01_image_threads.rb input_urls.txt output.json [workers]"
  exit 1
end

infile, outfile = ARGV[0], ARGV[1]
workers = (ARGV[2] || 4).to_i  # Number of worker threads (default = 4)

# Read all URLs from input file (remove empty lines)
urls = File.readlines(infile, chomp: true).reject(&:empty?)

# Create a queue to distribute tasks among threads
queue = Queue.new
urls.each { |u| queue << u }

# Shared array for results
results = []
# Mutex to synchronize writing to results array
results_mutex = Mutex.new

# Create worker threads
worker_threads = workers.times.map do |i|
  Thread.new(i) do |id|
    while true
      url = nil
      # Try to get next URL from queue
      begin
        url = queue.pop(true)
      rescue ThreadError
        # Queue is empty -> stop thread
        break
      end

      # Simulate download time (0.1-0.5 seconds)
      start = Time.now
      sleep(rand(0.1..0.5))
      dur = ((Time.now - start) * 1000).to_i  # Duration in milliseconds

      # Create record for the finished task
      record = {
        url: url,
        worker: id,
        duration_ms: dur,
        finished_at: Time.now.iso8601
      }

      # Synchronize access to shared results array
      results_mutex.synchronize { results << record }
    end
  end
end

# Wait for all threads to finish
worker_threads.each(&:join)

# Write results to JSON file
File.write(outfile, JSON.pretty_generate(results))
puts "Wrote #{results.size} records to #{outfile}"
