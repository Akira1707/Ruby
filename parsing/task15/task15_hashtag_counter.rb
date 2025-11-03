require 'json'

if ARGV.length < 2
  puts "Usage: ruby task15_hashtag_counter.rb input.txt output.json [top_n]"
  exit 1
end

infile, outfile = ARGV[0], ARGV[1]
top_n = (ARGV[2] || 10).to_i

counts = Hash.new(0)  # store hashtag frequencies
total = 0             # total number of posts

# Read each line, split by tab into user and content
File.foreach(infile) do |line|
  total += 1
  parts = line.chomp.split("\t",2)
  content = parts[1] || parts[0]
  
  # Extract hashtags using regex #\w+ and count them
  content.scan(/#\w+/) { |h| counts[h.downcase] += 1 }
end

# Get top N hashtags sorted by frequency
top = counts.sort_by { |k,v| -v }.first(top_n).map { |k,v| { tag: k, count: v } }

# Write results to JSON
File.write(outfile, JSON.pretty_generate({ total_posts: total, top_hashtags: top }))
puts "Wrote #{outfile}"
