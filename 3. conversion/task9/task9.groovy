def mdToHtmlLine(String line) {
    // Headers
    if(line.startsWith("### ")) {
        return "<h3>${line[4..-1].trim()}</h3>"
    } else if(line.startsWith("## ")) {
        return "<h2>${line[3..-1].trim()}</h2>"
    } else if(line.startsWith("# ")) {
        return "<h1>${line[2..-1].trim()}</h1>"
    } else {
        // Inline formatting
        line = line.replaceAll(/\*\*(.+?)\*\*/, '<strong>$1</strong>')
        line = line.replaceAll(/\*(.+?)\*/, '<em>$1</em>')
        line = line.replaceAll(/`(.+?)`/, '<code>$1</code>')
        line = line.replaceAll(/\[(.+?)\]\((.+?)\)/, '<a href="$2">$1</a>')
        return "<p>${line}</p>"
    }
}

if(args.length < 1) {
    println "Usage: groovy task9.groovy <input_file.md>"
    System.exit(1)
}

def inputFile = args[0]
def outputFile = "output.html"

def lines = new File(inputFile).readLines()
def htmlLines = lines.collect { mdToHtmlLine(it) }

new File(outputFile).withWriter { writer ->
    htmlLines.each { writer.println it }
}

println "Conversion complete. HTML saved to ${outputFile}"
