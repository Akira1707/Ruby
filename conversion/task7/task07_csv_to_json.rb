require 'csv'
require 'json'

# Check command-line arguments
if ARGV.length < 2
  puts "Usage: ruby task07_csv_to_json.rb input.csv output.json"
  exit 1
end

infile, outfile = ARGV
rows = []

# Read CSV file with headers
CSV.foreach(infile, headers: true) do |r|
  obj = {}
  r.headers.each do |h|
    v = r[h]
    # Strip leading/trailing spaces
    v = v.strip if v.respond_to?(:strip)
    # Try to convert to integer or float
    if v =~ /\A-?\d+\z/
      v = v.to_i
    elsif v =~ /\A-?\d+\.\d+\z/
      v = v.to_f
    end
    obj[h] = v
  end
  rows << obj
end

# Write JSON output
File.write(outfile, JSON.pretty_generate(rows))
puts "Wrote #{rows.size} records to #{outfile}"
