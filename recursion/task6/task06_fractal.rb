# Check command-line arguments
if ARGV.length < 2
  puts "Usage: ruby task06_fractal.rb input.txt output.txt"
  exit 1
end

# Read recursion depth n from input file
n = File.read(ARGV[0]).strip.to_i
outfile = ARGV[1]

# Generate Sierpinski triangle using 2^n width
size = 2**n
canvas = Array.new(size) { Array.new(2 * size, ' ') }

# --- Recursive function to draw Sierpinski triangle ---
def draw_triangle(canvas, top_x, top_y, size)
  if size == 1
    canvas[top_y][top_x] = '*'
    return
  end
  half = size / 2
  # Top triangle
  draw_triangle(canvas, top_x, top_y, half)
  # Bottom-left triangle
  draw_triangle(canvas, top_x - half, top_y + half, half)
  # Bottom-right triangle
  draw_triangle(canvas, top_x + half, top_y + half, half)
end

# Draw the triangle on canvas
draw_triangle(canvas, size - 1, 0, size)

# Convert canvas to lines and write to output file
lines = canvas.map { |row| row.join.rstrip }
File.write(outfile, lines.join("\n"))
puts "Wrote pattern to #{outfile}"
