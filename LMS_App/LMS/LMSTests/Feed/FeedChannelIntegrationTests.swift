//
//  FeedChannelIntegrationTests.swift
//  LMSTests
//
//  Integration tests for Feed channels
//

import XCTest
@testable import LMS

final class FeedChannelIntegrationTests: XCTestCase {
    
    var realDataService: RealDataFeedService!
    var mockFeedService: MockFeedService!
    
    override func setUp() {
        super.setUp()
        realDataService = RealDataFeedService.shared
        mockFeedService = MockFeedService.shared
    }
    
    override func tearDown() {
        realDataService = nil
        mockFeedService = nil
        super.tearDown()
    }
    
    // MARK: - Release Notes Tests
    
    func test_loadReleaseNotes_loadsAllFiles_notJustLast10() {
        // Given
        let expectedMinimumReleases = 11 // Based on project documentation
        
        // When
        let releaseNotes = realDataService.loadReleaseNotes()
        
        // Then
        XCTAssertGreaterThanOrEqual(releaseNotes.count, expectedMinimumReleases,
                                    "Should load all release notes, not just last 10. Found: \(releaseNotes.count)")
        
        // Log for debugging
        print("✅ Loaded \(releaseNotes.count) release notes")
        releaseNotes.prefix(3).forEach { post in
            print("  - \(post.title): \(post.createdAt)")
        }
    }
    
    // MARK: - Sprint Reports Tests
    
    func test_loadSprintReports_loadsAllFiles_notJustLast10() {
        // Given
        let expectedMinimumSprints = 50 // Conservative estimate
        
        // When
        let sprintReports = realDataService.loadSprintReports()
        
        // Then
        XCTAssertGreaterThanOrEqual(sprintReports.count, expectedMinimumSprints,
                                    "Should load all sprint reports. Found: \(sprintReports.count)")
        
        // Log for debugging
        print("✅ Loaded \(sprintReports.count) sprint reports")
        sprintReports.prefix(3).forEach { post in
            print("  - \(post.title): \(post.createdAt)")
        }
    }
    
    // MARK: - Methodology Tests
    
    func test_loadMethodologyUpdates_loadsAllFiles_notJustLast10() {
        // Given
        let expectedMinimumMethodology = 30 // Based on project documentation
        
        // When
        let methodologyUpdates = realDataService.loadMethodologyUpdates()
        
        // Then
        XCTAssertGreaterThanOrEqual(methodologyUpdates.count, expectedMinimumMethodology,
                                    "Should load all methodology updates. Found: \(methodologyUpdates.count)")
        
        // Log for debugging
        print("✅ Loaded \(methodologyUpdates.count) methodology updates")
        methodologyUpdates.prefix(3).forEach { post in
            print("  - \(post.title): \(post.createdAt)")
        }
    }
    
    // MARK: - Content Tests
    
    func test_markdownToHTMLConversion_preservesFullContent() {
        // Given
        let releaseNotes = realDataService.loadReleaseNotes()
        
        // When
        guard let firstPost = releaseNotes.first else {
            XCTFail("No release notes loaded")
            return
        }
        
        // Then
        XCTAssertTrue(firstPost.content.contains("<"), "Content should be HTML")
        XCTAssertTrue(firstPost.content.contains("</"), "Content should have closing HTML tags")
        XCTAssertFalse(firstPost.content.contains("..."), "Content should not be truncated")
        
        // Check content length
        XCTAssertGreaterThan(firstPost.content.count, 100, 
                             "Content should be substantial, not just a summary")
    }
    
    // MARK: - Integration with MockFeedService
    
    func test_mockFeedService_loadsRealData() {
        // Given
        let expectation = XCTestExpectation(description: "Channels loaded")
        
        // When
        mockFeedService.refresh()
        
        // Wait a bit for async operations
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            // Then
            let channels = self.mockFeedService.channels
            XCTAssertFalse(channels.isEmpty, "Should have channels")
            
            // Check specific channels
            let releaseChannel = channels.first { $0.type == .releases }
            let sprintChannel = channels.first { $0.type == .sprints }
            let methodologyChannel = channels.first { $0.type == .methodology }
            
            XCTAssertNotNil(releaseChannel, "Should have releases channel")
            XCTAssertNotNil(sprintChannel, "Should have sprints channel")
            XCTAssertNotNil(methodologyChannel, "Should have methodology channel")
            
            // Check posts count
            if let releaseChannelId = releaseChannel?.id,
               let posts = self.mockFeedService.channelPosts[releaseChannelId] {
                XCTAssertGreaterThanOrEqual(posts.count, 11, 
                                            "Release channel should have all posts")
            }
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 2.0)
    }
    
    // MARK: - File System Tests
    
    func test_fileSystemAccess_canReadDocumentationFiles() {
        // Given
        let fileManager = FileManager.default
        let paths = [
            "/Users/ishirokov/lms_docs/docs/releases",
            "/Users/ishirokov/lms_docs/reports/sprints",
            "/Users/ishirokov/lms_docs/reports/methodology"
        ]
        
        // When & Then
        for path in paths {
            XCTAssertTrue(fileManager.fileExists(atPath: path),
                          "Path should exist: \(path)")
            
            do {
                let files = try fileManager.contentsOfDirectory(atPath: path)
                let mdFiles = files.filter { $0.hasSuffix(".md") }
                XCTAssertFalse(mdFiles.isEmpty, 
                               "Should have .md files in: \(path)")
                print("✅ Found \(mdFiles.count) .md files in \(path)")
            } catch {
                XCTFail("Failed to read directory \(path): \(error)")
            }
        }
    }
} 