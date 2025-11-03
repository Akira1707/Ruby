require 'json'
require 'thread'
require 'time'

# Check command-line arguments
if ARGV.length < 2
  puts "Usage: ruby task02_file_counter.rb input_files.txt output.json [workers]"
  exit 1
end

input_list, output_file = ARGV[0], ARGV[1]
workers = (ARGV[2] || 4).to_i

# Read list of files to process
files = File.readlines(input_list, chomp: true).reject(&:empty?)
queue = Queue.new
files.each { |f| queue << f }

# Shared results array and mutex for thread safety
results = []
mutex = Mutex.new

# Create worker threads
threads = workers.times.map do |id|
  Thread.new do
    while true
      file = nil
      begin
        file = queue.pop(true)
      rescue ThreadError
        break
      end

      start = Time.now
      line_count = 0

      # Safely count lines in file
      begin
        File.foreach(file) { line_count += 1 }
      rescue => e
        line_count = -1
      end

      duration = ((Time.now - start) * 1000).to_i

      result = {
        worker: id,
        file: file,
        lines: line_count,
        duration_ms: duration,
        finished_at: Time.now.iso8601
      }

      mutex.synchronize { results << result }
      puts "[Thread #{id}] Processed #{file} (#{line_count} lines)"
    end
  end
end

# Wait for all threads to finish
threads.each(&:join)

# Write JSON output
File.write(output_file, JSON.pretty_generate(results))
puts "\n Wrote #{results.size} records to #{output_file}"
