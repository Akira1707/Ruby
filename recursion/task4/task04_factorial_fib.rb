require 'json'

# Check if correct number of arguments provided
if ARGV.length < 2
  puts "Usage: ruby task04_factorial_fib.rb input.json output.json"
  exit 1
end

# Read input and output file paths
infile, outfile = ARGV
data = JSON.parse(File.read(infile))

# --- Factorial function (recursive) ---
def factorial(n)
  return 1 if n <= 1
  n * factorial(n - 1)
end

# --- Fibonacci function (recursive with memoization) ---
$memo = {0 => 0, 1 => 1}
def fib(n)
  return $memo[n] if $memo.key?(n)
  $memo[n] = fib(n - 1) + fib(n - 2)
  $memo[n]
end

# Prepare result structure
res = { factorials: [], fibs: [] }

# Calculate factorials
(data["factorials"] || []).each do |n|
  res[:factorials] << { n: n, fact: factorial(n) }
end

# Calculate Fibonacci numbers
(data["fibs"] || []).each do |n|
  res[:fibs] << { n: n, fib: fib(n) }
end

# Write results to output JSON file
File.write(outfile, JSON.pretty_generate(res))
puts "Wrote #{outfile}"
