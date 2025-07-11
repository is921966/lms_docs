//
//  ReleaseNewsServiceTests.swift
//  LMSTests
//
//  Тесты для сервиса управления новостями о релизах
//

import XCTest
@testable import LMS

@MainActor
class ReleaseNewsServiceTests: XCTestCase {
    
    var sut: ReleaseNewsService!
    let userDefaults = UserDefaults.standard
    
    // Keys
    let lastVersionKey = "lastAnnouncedAppVersion"
    let lastBuildKey = "lastAnnouncedBuildNumber"
    let releaseNotesKey = "currentReleaseNotes"
    
    override func setUp() async throws {
        try await super.setUp()
        
        // Clear UserDefaults
        userDefaults.removeObject(forKey: lastVersionKey)
        userDefaults.removeObject(forKey: lastBuildKey)
        userDefaults.removeObject(forKey: releaseNotesKey)
        
        // Create service
        sut = ReleaseNewsService.shared
    }
    
    override func tearDown() async throws {
        // Clean up
        userDefaults.removeObject(forKey: lastVersionKey)
        userDefaults.removeObject(forKey: lastBuildKey)
        userDefaults.removeObject(forKey: releaseNotesKey)
        
        try await super.tearDown()
    }
    
    // MARK: - Tests
    
    func testNewReleaseDetection() {
        // Given - no saved version
        
        // When
        sut.checkForNewRelease()
        
        // Then
        XCTAssertTrue(sut.hasNewRelease, "Should detect new release when no previous version saved")
    }
    
    func testNoNewReleaseWhenVersionSame() {
        // Given
        userDefaults.set(sut.currentAppVersion, forKey: lastVersionKey)
        userDefaults.set(sut.currentBuildNumber, forKey: lastBuildKey)
        
        // When
        sut.checkForNewRelease()
        
        // Then
        XCTAssertFalse(sut.hasNewRelease, "Should not detect new release when version is same")
    }
    
    func testNewReleaseWhenBuildChanges() {
        // Given
        userDefaults.set(sut.currentAppVersion, forKey: lastVersionKey)
        userDefaults.set("100", forKey: lastBuildKey) // Different build
        
        // When
        sut.checkForNewRelease()
        
        // Then
        XCTAssertTrue(sut.hasNewRelease, "Should detect new release when build number changes")
    }
    
    func testPublishReleaseNews() async {
        // Given
        let testNotes = """
        # Test Release v1.0.0
        
        ## Changes
        - Test change
        """
        
        // When
        await sut.publishReleaseNews(releaseNotes: testNotes)
        
        // Then
        XCTAssertFalse(sut.hasNewRelease, "hasNewRelease should be false after publishing")
        XCTAssertEqual(userDefaults.string(forKey: lastVersionKey), sut.currentAppVersion)
        XCTAssertEqual(userDefaults.string(forKey: lastBuildKey), sut.currentBuildNumber)
        XCTAssertEqual(userDefaults.string(forKey: releaseNotesKey), testNotes)
    }
    
    func testGetCurrentReleaseNotes() {
        // Given
        let testNotes = "Test release notes"
        userDefaults.set(testNotes, forKey: releaseNotesKey)
        
        // When
        let notes = sut.getCurrentReleaseNotes()
        
        // Then
        XCTAssertEqual(notes, testNotes)
    }
    
    func testGetDefaultReleaseNotesWhenNoneStored() {
        // Given - no stored notes
        
        // When
        let notes = sut.getCurrentReleaseNotes()
        
        // Then
        XCTAssertTrue(notes.contains("TestFlight Release"))
        XCTAssertTrue(notes.contains(sut.currentAppVersion))
        XCTAssertTrue(notes.contains(sut.currentBuildNumber))
    }
    
    func testLoadReleaseNotesFromFile() async {
        // Given
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("test_notes.md")
        let testContent = "# Test Release Notes"
        try? testContent.write(to: tempURL, atomically: true, encoding: .utf8)
        
        // When
        let loadedNotes = await sut.loadReleaseNotesFromFile(path: tempURL.path)
        
        // Then
        XCTAssertEqual(loadedNotes, testContent)
        
        // Cleanup
        try? FileManager.default.removeItem(at: tempURL)
    }
    
    func testCheckAndPublishOnAppLaunch() async {
        // Given
        sut.checkForNewRelease() // Ensure hasNewRelease is true
        XCTAssertTrue(sut.hasNewRelease)
        
        // When
        let expectation = XCTestExpectation(description: "Release news published")
        
        sut.checkAndPublishOnAppLaunch()
        
        // Wait for async operation
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            expectation.fulfill()
        }
        
        await fulfillment(of: [expectation], timeout: 5)
        
        // Then
        XCTAssertFalse(sut.hasNewRelease, "Should publish news and reset flag")
    }
}

// MARK: - FeedService Tests Extension

extension ReleaseNewsServiceTests {
    
    func testFeedServiceIntegration() async {
        // Given
        let feedService = FeedService.shared
        let initialCount = feedService.feedItems.count
        
        let testItem = FeedItem(
            type: .announcement,
            title: "Test Release",
            content: "Test content",
            author: "Test",
            priority: .high
        )
        
        // When
        await feedService.addNewsItem(testItem)
        
        // Then
        XCTAssertEqual(feedService.feedItems.count, initialCount + 1)
        XCTAssertEqual(feedService.feedItems.first?.id, testItem.id)
        XCTAssertEqual(feedService.feedItems.first?.priority, .high)
    }
} 