#!/usr/bin/swift

import Foundation

// Mock channel post data structure
struct ChannelPostData {
    let channelId: String
    let postsCount: Int
}

// Test data
let testData = [
    ChannelPostData(channelId: "channel-releases", postsCount: 5),
    ChannelPostData(channelId: "channel-sprints", postsCount: 10),
    ChannelPostData(channelId: "channel-methodology", postsCount: 3),
    ChannelPostData(channelId: "channel-courses", postsCount: 4),
]

print("🔍 Feed Channel Data Check")
print("==========================")
print("")

for data in testData {
    print("Channel: \(data.channelId)")
    print("  Expected posts: \(data.postsCount)")
    print("  Status: \(data.postsCount > 0 ? "✅ OK" : "❌ EMPTY")")
    print("")
}

// Check file system for release notes
let fileManager = FileManager.default
let releasePath = "/Users/ishirokov/lms_docs/docs/releases"

print("📂 Checking release files:")
print("Path: \(releasePath)")

if fileManager.fileExists(atPath: releasePath) {
    do {
        let files = try fileManager.contentsOfDirectory(atPath: releasePath)
        let releaseFiles = files.filter { $0.contains("RELEASE") && $0.hasSuffix(".md") }
        print("Found \(releaseFiles.count) release files:")
        for file in releaseFiles.prefix(5) {
            print("  - \(file)")
        }
    } catch {
        print("Error reading directory: \(error)")
    }
} else {
    print("❌ Release directory not found!")
}

print("\n✅ Check complete!") 