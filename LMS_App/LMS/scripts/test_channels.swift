#!/usr/bin/swift

import Foundation

// Simulate RealDataFeedService logic
let fileManager = FileManager.default

// Test Release Notes
print("📢 Testing Release Notes Channel:")
let releasePath = "/Users/ishirokov/lms_docs/docs/releases"
if let files = try? fileManager.contentsOfDirectory(atPath: releasePath) {
    let releaseFiles = files.filter { $0.contains("RELEASE") && $0.hasSuffix(".md") }
    print("Found \(releaseFiles.count) release files:")
    releaseFiles.prefix(5).forEach { print("  - \($0)") }
    if releaseFiles.count > 5 {
        print("  ... and \(releaseFiles.count - 5) more")
    }
} else {
    print("❌ Failed to read release directory")
}

// Test Sprint Reports
print("\n📊 Testing Sprint Reports Channel:")
let sprintPath = "/Users/ishirokov/lms_docs/reports/sprints"
if let files = try? fileManager.contentsOfDirectory(atPath: sprintPath) {
    let sprintFiles = files.filter { 
        ($0.contains("COMPLETION_REPORT") || $0.contains("PROGRESS")) && 
        $0.hasSuffix(".md")
    }
    print("Found \(sprintFiles.count) sprint files:")
    sprintFiles.prefix(5).forEach { print("  - \($0)") }
    if sprintFiles.count > 5 {
        print("  ... and \(sprintFiles.count - 5) more")
    }
} else {
    print("❌ Failed to read sprint directory")
}

// Test Methodology
print("\n📚 Testing Methodology Channel:")
let methodologyPath = "/Users/ishirokov/lms_docs/reports/methodology"
if let files = try? fileManager.contentsOfDirectory(atPath: methodologyPath) {
    let methodologyFiles = files.filter { $0.hasSuffix(".md") }
    print("Found \(methodologyFiles.count) methodology files:")
    methodologyFiles.prefix(5).forEach { print("  - \($0)") }
    if methodologyFiles.count > 5 {
        print("  ... and \(methodologyFiles.count - 5) more")
    }
} else {
    print("❌ Failed to read methodology directory")
}

// Test loading content from a file
print("\n📄 Testing file content loading:")
let testFile = releasePath + "/TESTFLIGHT_RELEASE_v2.1.1_build215.md"
if let content = try? String(contentsOfFile: testFile, encoding: .utf8) {
    print("✅ Successfully loaded file content (\(content.count) characters)")
    let lines = content.components(separatedBy: "\n")
    print("File has \(lines.count) lines")
} else {
    print("❌ Failed to load file content")
}

print("\n✅ Test completed!") 