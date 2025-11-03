require 'json'

if ARGV.length < 2
  puts "Usage: ruby task13_log_parser.rb input.log output.json"
  exit 1
end

infile, outfile = ARGV

# Pattern to match log lines:
# [timestamp] IP METHOD PATH STATUS
pattern = /^\[([^\]]+)\]\s+(\d+\.\d+\.\d+\.\d+)\s+(\w+)\s+(\S+)\s+(\d{3})/

entries = []            # Array to hold parsed log entries
ip_counts = Hash.new(0) # Hash to count requests per IP

File.foreach(infile) do |line|
  if m = line.match(pattern)
    ts, ip, method, path, status = m.captures
    entries << { time: ts, ip: ip, method: method, path: path, status: status.to_i }
    ip_counts[ip] += 1
  end
end

# Get top 5 IPs by request count
top_ips = ip_counts.sort_by { |ip, c| -c }.first(5).map { |ip, c| { ip: ip, count: c } }

res = { entries: entries, top_ips: top_ips }

File.write(outfile, JSON.pretty_generate(res))
puts "Parsed #{entries.size} entries; top #{top_ips.size} ips in #{outfile}"
