require 'json'
require 'thread'
require 'csv'
require 'time'

# Check arguments
if ARGV.length < 2
  puts "Usage: ruby task03_sensor_reader.rb input_csv.txt output.json [workers]"
  exit 1
end

input_list, output_file = ARGV[0], ARGV[1]
workers = (ARGV[2] || 4).to_i

# Read list of sensor data files
files = File.readlines(input_list, chomp: true).reject(&:empty?)

# Shared structures
queue = Queue.new
files.each { |f| queue << f }

results = []
mutex = Mutex.new

# Worker threads
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

      # Each file contains: timestamp, temperature, humidity
      begin
        data = CSV.read(file, headers: true)
        temps = data['temperature'].map(&:to_f)
        hums  = data['humidity'].map(&:to_f)

        summary = {
          file: file,
          worker: id,
          records: data.size,
          temp_avg: temps.sum / temps.size,
          temp_min: temps.min,
          temp_max: temps.max,
          hum_avg: hums.sum / hums.size,
          hum_min: hums.min,
          hum_max: hums.max,
          duration_ms: ((Time.now - start) * 1000).to_i,
          finished_at: Time.now.iso8601
        }

        mutex.synchronize { results << summary }
        puts "[Thread #{id}] Processed #{file} (#{data.size} records)"
      rescue => e
        mutex.synchronize do
          results << { file: file, worker: id, error: e.message }
        end
      end
    end
  end
end

threads.each(&:join)

# Combine and write final results
File.write(output_file, JSON.pretty_generate(results))
puts "\n Processed #{results.size} files. Results saved to #{output_file}"
