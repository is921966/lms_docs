import XCTest
@testable import LMS

class ReleaseNotesChannelTests: XCTestCase {
    
    func testReleaseNotesChannelInitialization() {
        // Given
        let channel = ReleaseNotesChannel.shared
        
        // Then
        XCTAssertNotNil(channel)
        XCTAssertEqual(channel.channel.name, "🚀 Релизы LMS")
        XCTAssertEqual(channel.channel.category, .announcement)
        XCTAssertEqual(channel.channel.priority, .critical)
        XCTAssertTrue(channel.true)
    }
    
    func testLoadReleaseNotesFromBundledData() {
        // Given
        let channel = ReleaseNotesChannel.shared
        
        // When
        let posts = channel.getReleaseNotes()
        
        // Then
        XCTAssertFalse(posts.isEmpty)
        XCTAssertTrue(posts.count >= 3) // At least 3 releases
    }
    
    func testReleaseNotePostStructure() {
        // Given
        let channel = ReleaseNotesChannel.shared
        
        // When
        let posts = channel.getReleaseNotes()
        
        // Then
        if let firstPost = posts.first {
            XCTAssertFalse(firstPost.title.isEmpty)
            XCTAssertFalse(firstPost.content.isEmpty)
            XCTAssertTrue(firstPost.content.contains("Версия"))
            XCTAssertNotNil(firstPost.version)
            XCTAssertNotNil(firstPost.buildNumber)
        }
    }
    
    func testReleaseNotesAreSortedByDateDescending() {
        // Given
        let channel = ReleaseNotesChannel.shared
        
        // When
        let posts = channel.getReleaseNotes()
        
        // Then
        for i in 0..<posts.count-1 {
            XCTAssertTrue(posts[i].date >= posts[i+1].date)
        }
    }
    
    func testConvertToFeedMessages() {
        // Given
        let channel = ReleaseNotesChannel.shared
        
        // When
        let messages = channel.getFeedMessages()
        
        // Then
        XCTAssertFalse(messages.isEmpty)
        
        if let firstMessage = messages.first {
            XCTAssertFalse(firstMessage.id.uuidString.isEmpty)
            XCTAssertFalse(firstMessage.text.isEmpty)
            XCTAssertNotNil(firstMessage.timestamp)
            XCTAssertTrue(firstMessage.isFromChannel)
        }
    }
    
    func testChannelHasCorrectAvatarType() {
        // Given
        let channel = ReleaseNotesChannel.shared.channel
        
        // Then
        if case .systemIcon(let iconName) = channel.avatarType {
            XCTAssertEqual(iconName, "app.badge")
        } else {
            XCTFail("Expected systemIcon avatar type")
        }
    }
    
    func testGetLatestReleaseInfo() {
        // Given
        let channel = ReleaseNotesChannel.shared
        
        // When
        let posts = channel.getReleaseNotes()
        
        // Then
        if let latest = posts.first {
            XCTAssertNotNil(latest.version)
            XCTAssertTrue(latest.version!.starts(with: "2."))
        }
    }
    
    func testMarkdownFormattingInContent() {
        // Given
        let channel = ReleaseNotesChannel.shared
        
        // When
        let posts = channel.getReleaseNotes()
        
        // Then
        if let post = posts.first {
            // Check for markdown elements
            XCTAssertTrue(
                post.content.contains("**") || // Bold
                post.content.contains("###") || // Headers
                post.content.contains("- ") ||  // Lists
                post.content.contains("✅") ||  // Emojis
                post.content.contains("🚀")     // Emojis
            )
        }
    }
} 