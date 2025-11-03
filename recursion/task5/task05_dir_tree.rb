require 'json'

# Check command-line arguments
if ARGV.length < 2
  puts "Usage: ruby task05_dir_tree.rb dir_root.txt output.json"
  exit 1
end

# Read directory path from input file
dir = File.read(ARGV[0]).strip
outfile = ARGV[1]

# --- Recursive function to build directory tree ---
def build_tree(path)
  node = { name: File.basename(path), path: path }
  if File.directory?(path)
    node[:type] = 'dir'
    # Recursively build children nodes
    node[:children] = Dir.children(path).sort.map { |c| build_tree(File.join(path, c)) }
  else
    node[:type] = 'file'
  end
  node
end

# Build tree starting from root directory
tree = build_tree(dir)

# Write JSON output
File.write(outfile, JSON.pretty_generate(tree))
puts "Wrote tree to #{outfile}"
