require 'json'

if ARGV.length < 2
  puts "Usage: ruby task14_email_extractor.rb input.txt output.json"
  exit 1
end

infile, outfile = ARGV
text = File.read(infile)

# Extract email addresses using regex and remove duplicates
emails = text.scan(/[A-Za-z0-9._%+\-]+@[A-Za-z0-9.\-]+\.[A-Za-z]{2,}/).uniq

# Extract phone numbers (general/international format, permissive)
phones = text.scan(/(?:\+?\d{1,3}[-.\s]?)?(?:\(?\d{2,4}\)?[-.\s]?)?\d{3,4}[-.\s]?\d{3,4}/).uniq

# Write results to JSON
File.write(outfile, JSON.pretty_generate({ emails: emails, phones: phones }))
puts "Found #{emails.size} emails and #{phones.size} phones. Wrote to #{outfile}"
