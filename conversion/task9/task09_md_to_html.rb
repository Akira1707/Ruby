# Check command-line arguments
if ARGV.length < 2
  puts "Usage: ruby task09_md_to_html.rb input.md output.html"
  exit 1
end

infile, outfile = ARGV
text = File.read(infile)

# --- Simple Markdown to HTML transformations ---

# Headers (# -><h1>, ## -> <h2>, ... ###### -> <h6>)
text = text.gsub(/^###### (.*)$/, '<h6>\1</h6>')
text = text.gsub(/^##### (.*)$/, '<h5>\1</h5>')
text = text.gsub(/^#### (.*)$/, '<h4>\1</h4>')
text = text.gsub(/^### (.*)$/, '<h3>\1</h3>')
text = text.gsub(/^## (.*)$/, '<h2>\1</h2>')
text = text.gsub(/^# (.*)$/, '<h1>\1</h1>')

# Bold (**text**) -> <strong>text</strong>
text = text.gsub(/\*\*(.+?)\*\*/, '<strong>\1</strong>')

# Italic (*text*) -> <em>text</em>
text = text.gsub(/\*(.+?)\*/, '<em>\1</em>')

# Inline code (`code`) -> <code>code</code>
text = text.gsub(/`(.+?)`/, '<code>\1</code>')

# Links [text](url) -> <a href="url">text</a>
text = text.gsub(/\[([^\]]+)\]\(([^)]+)\)/, '<a href="\2">\1</a>')

# Wrap paragraphs (lines separated by blank lines) in <p> tags
paragraphs = text.split(/\n{2,}/).map do |p|
  # if already a block tag, keep as-is
  if p.strip =~ /\A<\/?(h[1-6]|pre|ul|ol|li|blockquote|table)/i
    p
  else
    "<p>#{p.strip.gsub("\n"," ")}</p>"
  end
end

# Assemble HTML document
html = "<!doctype html>\n<html><head><meta charset='utf-8'><title>Converted</title></head><body>\n" +
       paragraphs.join("\n") + "\n</body></html>"

# Write HTML file
File.write(outfile, html)
puts "Wrote HTML to #{outfile}"
