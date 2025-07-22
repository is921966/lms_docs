import XCTest
@testable import LMS

class MethodologyChannelTests: XCTestCase {
    
    func testMethodologyChannelInitialization() {
        // Given
        let channel = MethodologyChannel.shared
        
        // Then
        XCTAssertNotNil(channel)
        XCTAssertEqual(channel.channel.name, "📚 Методология TDD")
        XCTAssertEqual(channel.channel.category, .learning)
        XCTAssertEqual(channel.channel.priority, .normal)
    }
    
    func testLoadMethodologyVersions() {
        // Given
        let channel = MethodologyChannel.shared
        
        // When
        let versions = channel.getMethodologyVersions()
        
        // Then
        XCTAssertFalse(versions.isEmpty)
        XCTAssertTrue(versions.count >= 1)
    }
    
    func testMethodologyVersionStructure() {
        // Given
        let channel = MethodologyChannel.shared
        
        // When
        let versions = channel.getMethodologyVersions()
        
        // Then
        if let firstVersion = versions.first {
            XCTAssertFalse(firstVersion.version.isEmpty)
            XCTAssertNotNil(firstVersion.date)
            XCTAssertFalse(firstVersion.title.isEmpty)
            XCTAssertFalse(firstVersion.changes.isEmpty)
        }
    }
    
    func testGenerateFeedMessages() {
        // Given
        let channel = MethodologyChannel.shared
        
        // When
        let messages = channel.generateFeedMessages()
        
        // Then
        XCTAssertFalse(messages.isEmpty)
        
        for message in messages {
            XCTAssertFalse(message.text.isEmpty)
            XCTAssertNotNil(message.timestamp)
            XCTAssertFalse(message.isFromUser)
            XCTAssertTrue(message.isFromChannel)
        }
    }
    
    func testMethodologyVersionsSortedByVersion() {
        // Given
        let channel = MethodologyChannel.shared
        
        // When
        let versions = channel.getMethodologyVersions()
        
        // Then
        // Should be sorted by version number (descending)
        for i in 0..<versions.count-1 {
            let v1 = versions[i].version.replacingOccurrences(of: "v", with: "")
            let v2 = versions[i+1].version.replacingOccurrences(of: "v", with: "")
            
            // Compare version strings
            let result = v1.compare(v2, options: .numeric)
            XCTAssertTrue(result == .orderedDescending || result == .orderedSame)
        }
    }
} 