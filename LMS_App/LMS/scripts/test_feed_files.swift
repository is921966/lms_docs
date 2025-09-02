#!/usr/bin/swift

import Foundation

// Test script for checking file loading

print("📊 Feed Files Test")
print("==================")
print("")

// File paths
let paths = [
    ("Releases", "/Users/ishirokov/lms_docs/docs/releases"),
    ("Sprints", "/Users/ishirokov/lms_docs/reports/sprints"),
    ("Methodology", "/Users/ishirokov/lms_docs/reports/methodology")
]

let fileManager = FileManager.default
var totalFiles = 0

for (name, path) in paths {
    print("📁 \(name) (\(path)):")
    
    if fileManager.fileExists(atPath: path) {
        do {
            let files = try fileManager.contentsOfDirectory(atPath: path)
            let mdFiles = files.filter { $0.hasSuffix(".md") }
            
            print("   ✅ Found \(mdFiles.count) .md files")
            totalFiles += mdFiles.count
            
            // Show first 5 files
            for file in mdFiles.prefix(5) {
                print("      - \(file)")
            }
            
            if mdFiles.count > 5 {
                print("      ... and \(mdFiles.count - 5) more")
            }
            
        } catch {
            print("   ❌ Error reading directory: \(error)")
        }
    } else {
        print("   ❌ Directory does not exist")
    }
    
    print("")
}

print("================")
print("📊 Total: \(totalFiles) markdown files")
print("")

// Test markdown to HTML conversion
print("🔄 Testing Markdown to HTML conversion...")

let sampleMarkdown = """
# Test Header

This is a **bold** text and *italic* text.

## Features
- Item 1
- Item 2
- Item 3

### Code Example
```swift
let example = "test"
print(example)
```

[Link to docs](https://example.com)
"""

func convertMarkdownToHTML(_ markdown: String) -> String {
    var html = markdown
    
    // Convert headers
    let lines = html.components(separatedBy: "\n")
    html = lines.map { line in
        if line.hasPrefix("### ") {
            return "<h3>" + line.dropFirst(4) + "</h3>"
        } else if line.hasPrefix("## ") {
            return "<h2>" + line.dropFirst(3) + "</h2>"
        } else if line.hasPrefix("# ") {
            return "<h1>" + line.dropFirst(2) + "</h1>"
        }
        return line
    }.joined(separator: "\n")
    
    // Convert bold
    html = html.replacingOccurrences(of: #"\*\*(.+?)\*\*"#, with: "<strong>$1</strong>", options: .regularExpression)
    
    // Convert italic
    html = html.replacingOccurrences(of: #"(?<!\*)\*([^\*]+?)\*(?!\*)"#, with: "<em>$1</em>", options: .regularExpression)
    
    // Convert lists
    let listLines = html.components(separatedBy: "\n")
    html = listLines.map { line in
        if line.hasPrefix("- ") {
            return "<li>" + line.dropFirst(2) + "</li>"
        }
        return line
    }.joined(separator: "\n")
    
    // Convert code blocks
    html = html.replacingOccurrences(of: #"```(\w*)\n([\s\S]*?)```"#, with: "<pre><code>$2</code></pre>", options: .regularExpression)
    
    // Convert links
    html = html.replacingOccurrences(of: #"\[(.+?)\]\((.+?)\)"#, with: "<a href=\"$2\">$1</a>", options: .regularExpression)
    
    return html
}

let htmlResult = convertMarkdownToHTML(sampleMarkdown)
print("✅ Conversion successful")
print("   Original length: \(sampleMarkdown.count) chars")
print("   HTML length: \(htmlResult.count) chars")
print("")

// Test file reading
print("📖 Testing file reading...")

if let firstReleasePath = try? FileManager.default.contentsOfDirectory(atPath: paths[0].1)
    .filter({ $0.contains("RELEASE") && $0.hasSuffix(".md") })
    .first {
    
    let fullPath = paths[0].1 + "/" + firstReleasePath
    print("   Reading: \(firstReleasePath)")
    
    if let content = try? String(contentsOfFile: fullPath, encoding: .utf8) {
        print("   ✅ File read successfully")
        print("   File size: \(content.count) characters")
        print("   Lines: \(content.components(separatedBy: .newlines).count)")
        
        // Check if content would be truncated
        let preview = String(content.prefix(200))
        if preview.contains("...") {
            print("   ⚠️ Content appears to be truncated")
        } else {
            print("   ✅ Content appears complete")
        }
    } else {
        print("   ❌ Failed to read file")
    }
} else {
    print("   ❌ No release files found to test")
}

print("")
print("✅ Test completed!") 