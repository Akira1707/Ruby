require 'rexml/document'
require 'yaml'

# Check command-line arguments
if ARGV.length < 2
  puts "Usage: ruby task08_xml_to_yaml.rb input.xml output.yaml"
  exit 1
end

infile, outfile = ARGV

# Read XML file
xml = File.read(infile)
doc = REXML::Document.new(xml)

# --- Recursive function to convert XML element to Hash ---
def element_to_hash(el)
  if el.has_elements?
    h = {}
    el.elements.each do |child|
      name = child.name
      val = element_to_hash(child)
      # Handle multiple elements with the same name
      if h.key?(name)
        h[name] = [h[name]] unless h[name].is_a?(Array)
        h[name] << val
      else
        h[name] = val
      end
    end
    return h
  else
    return el.text
  end
end

# Convert root element
root = doc.root
result = { root.name => element_to_hash(root) }

# Write YAML output
File.write(outfile, result.to_yaml)
puts "Wrote YAML to #{outfile}"
