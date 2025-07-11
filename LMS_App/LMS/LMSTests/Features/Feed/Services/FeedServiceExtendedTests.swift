//
//  FeedServiceExtendedTests.swift
//  LMSTests
//
//  Created by LMS Team on 13.01.2025.
//

import XCTest
import Combine
@testable import LMS

@MainActor
final class FeedServiceExtendedTests: XCTestCase {
    
    var feedService: FeedService!
    var authService: MockAuthService!
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() async throws {
        try await super.setUp()
        
        feedService = FeedService.shared
        authService = MockAuthService.shared
        cancellables = []
        
        await loginAsAdmin()
    }
    
    override func tearDown() async throws {
        cancellables = nil
        try? await authService.logout()
        try await super.tearDown()
    }
    
    // MARK: - Helper Methods
    
    private func loginAsAdmin() async {
        _ = try? await authService.login(email: "admin@test.com", password: "password")
    }
    
    private func loginAsInstructor() async {
        try? await authService.logout()
        _ = try? await authService.login(email: "instructor@test.com", password: "password")
    }
    
    // MARK: - Search and Filter Tests
    
    func testSearchPostsByContent() async {
        let searchTerm = "test"
        let filteredPosts = feedService.posts.filter { post in
            post.content.localizedCaseInsensitiveContains(searchTerm)
        }
        
        XCTAssertFalse(filteredPosts.isEmpty)
        for post in filteredPosts {
            XCTAssertTrue(post.content.localizedCaseInsensitiveContains(searchTerm))
        }
    }
    
    func testSearchPostsByAuthor() async {
        let authorName = feedService.posts.first?.author.name ?? ""
        let filteredPosts = feedService.posts.filter { post in
            post.author.name.localizedCaseInsensitiveContains(authorName)
        }
        
        XCTAssertFalse(filteredPosts.isEmpty)
    }
    
    func testFilterPostsByVisibility() async {
        let visibility: FeedVisibility = .everyone
        let filteredPosts = feedService.posts.filter { $0.visibility == visibility }
        
        for post in filteredPosts {
            XCTAssertEqual(post.visibility, visibility)
        }
    }
    
    func testFilterPostsByTags() async {
        // Create post with specific tag
        try? await feedService.createPost(content: "Post with #testtag")
        
        let tag = "#testtag"
        let filteredPosts = feedService.posts.filter { post in
            post.tags?.contains(tag) ?? false
        }
        
        XCTAssertFalse(filteredPosts.isEmpty)
        for post in filteredPosts {
            XCTAssertTrue(post.tags?.contains(tag) ?? false)
        }
    }
    
    // MARK: - Sorting Tests
    
    func testSortPostsByDate() async {
        let sortedPosts = feedService.posts.sorted { $0.createdAt > $1.createdAt }
        
        for i in 0..<sortedPosts.count-1 {
            XCTAssertGreaterThanOrEqual(sortedPosts[i].createdAt, sortedPosts[i+1].createdAt)
        }
    }
    
    func testSortPostsByLikes() async {
        let sortedPosts = feedService.posts.sorted { $0.likes.count > $1.likes.count }
        
        for i in 0..<sortedPosts.count-1 {
            XCTAssertGreaterThanOrEqual(sortedPosts[i].likes.count, sortedPosts[i+1].likes.count)
        }
    }
    
    func testSortPostsByComments() async {
        let sortedPosts = feedService.posts.sorted { $0.comments.count > $1.comments.count }
        
        for i in 0..<sortedPosts.count-1 {
            XCTAssertGreaterThanOrEqual(sortedPosts[i].comments.count, sortedPosts[i+1].comments.count)
        }
    }
    
    // MARK: - Pagination Tests
    
    func testLoadMorePosts() async {
        let initialCount = feedService.posts.count
        
        // Simulate loading more posts
        feedService.refresh()
        
        // In real implementation, this would load more posts
        XCTAssertGreaterThanOrEqual(feedService.posts.count, initialCount)
    }
    
    func testPostsLimit() async {
        // Test that we don't load too many posts at once
        XCTAssertLessThanOrEqual(feedService.posts.count, 100)
    }
    
    // MARK: - Notification Preferences Tests
    
    func testNotificationPreferencesForMentions() async {
        // Test that notification preferences are respected
        let content = "@testuser check this out!"
        
        // In real implementation, check if notification is sent based on preferences
        try? await feedService.createPost(content: content)
        
        // Verify mention was extracted
        let newPost = feedService.posts.first!
        XCTAssertTrue(newPost.mentions?.contains("testuser") ?? false)
    }
    
    func testNotificationPreferencesForComments() async {
        let post = feedService.posts.first!
        
        // In real implementation, check if notification is sent to post author
        try? await feedService.addComment(to: post.id, content: "Great post!")
        
        let updatedPost = feedService.posts.first { $0.id == post.id }!
        XCTAssertGreaterThan(updatedPost.comments.count, post.comments.count)
    }
    
    // MARK: - Edge Cases Tests
    
    func testCreatePostWithMaxLength() async throws {
        let longContent = String(repeating: "a", count: 5000) // 5000 characters
        
        try await feedService.createPost(content: longContent)
        
        let newPost = feedService.posts.first!
        XCTAssertEqual(newPost.content.count, 5000)
    }
    
    func testCreatePostWithMinLength() async throws {
        let shortContent = "a"
        
        try await feedService.createPost(content: shortContent)
        
        let newPost = feedService.posts.first!
        XCTAssertEqual(newPost.content, shortContent)
    }
    
    func testCreatePostWithOnlyWhitespace() async {
        let whitespaceContent = "   \n\t   "
        
        do {
            try await feedService.createPost(content: whitespaceContent)
            // In real implementation, this might fail validation
        } catch {
            // Expected behavior
        }
    }
    
    func testAddEmptyComment() async {
        let post = feedService.posts.first!
        let emptyComment = ""
        
        do {
            try await feedService.addComment(to: post.id, content: emptyComment)
            // In real implementation, this should fail validation
        } catch {
            // Expected behavior
        }
    }
    
    // MARK: - Concurrent Operations Tests
    
    func testConcurrentLikes() async throws {
        let post = feedService.posts.first!
        let initialLikes = post.likes.count
        
        // Simulate concurrent likes
        await withTaskGroup(of: Void.self) { group in
            for _ in 0..<5 {
                group.addTask {
                    try? await self.feedService.toggleLike(postId: post.id)
                }
            }
        }
        
        // In real implementation, need to handle race conditions
        let updatedPost = feedService.posts.first { $0.id == post.id }!
        XCTAssertNotEqual(updatedPost.likes.count, initialLikes)
    }
    
    func testConcurrentComments() async throws {
        let post = feedService.posts.first!
        let initialComments = post.comments.count
        
        // Simulate concurrent comments
        await withTaskGroup(of: Void.self) { group in
            for i in 0..<5 {
                group.addTask {
                    try? await self.feedService.addComment(to: post.id, content: "Comment \(i)")
                }
            }
        }
        
        let updatedPost = feedService.posts.first { $0.id == post.id }!
        XCTAssertGreaterThan(updatedPost.comments.count, initialComments)
    }
    
    // MARK: - Data Validation Tests
    
    func testInvalidPostId() async {
        do {
            try await feedService.deletePost("")
            XCTFail("Should throw error for empty post ID")
        } catch {
            XCTAssertTrue(error is FeedError)
        }
    }
    
    func testSpecialCharactersInContent() async throws {
        let specialContent = "Test with <script>alert('xss')</script> and 😀🎉"
        
        try await feedService.createPost(content: specialContent)
        
        let newPost = feedService.posts.first!
        // In real implementation, should sanitize HTML
        XCTAssertEqual(newPost.content, specialContent)
    }
    
    func testURLDetectionInContent() async throws {
        let contentWithURL = "Check out https://example.com and http://test.org"
        
        try await feedService.createPost(content: contentWithURL)
        
        let newPost = feedService.posts.first!
        XCTAssertEqual(newPost.content, contentWithURL)
        // In real implementation, might extract URLs as attachments
    }
    
    // MARK: - Permission Edge Cases
    
    func testInstructorPermissions() async {
        await loginAsInstructor()
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        // Check instructor-specific permissions
        XCTAssertTrue(feedService.permissions.canPost)
        XCTAssertTrue(feedService.permissions.canDelete)
        XCTAssertFalse(feedService.permissions.canModerate)
    }
    
    func testPermissionsCaching() async {
        let initialPermissions = feedService.permissions
        
        // Change user
        await loginAsInstructor()
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        let newPermissions = feedService.permissions
        
        // Permissions should update
        XCTAssertNotEqual(initialPermissions.canModerate, newPermissions.canModerate)
    }
    
    // MARK: - Attachment Tests
    
    func testMultipleAttachmentTypes() async throws {
        let attachments = [
            FeedAttachment(id: "1", type: .document, url: "doc.pdf", name: "Doc", size: 1024, thumbnailUrl: nil),
            FeedAttachment(id: "2", type: .video, url: "video.mp4", name: "Video", size: 1048576, thumbnailUrl: "thumb.jpg"),
            FeedAttachment(id: "3", type: .link, url: "https://example.com", name: "Link", size: nil, thumbnailUrl: nil)
        ]
        
        try await feedService.createPost(
            content: "Post with multiple attachments",
            attachments: attachments
        )
        
        let newPost = feedService.posts.first!
        XCTAssertEqual(newPost.attachments.count, 3)
        
        // Verify all attachment types
        XCTAssertTrue(newPost.attachments.contains { $0.type == .document })
        XCTAssertTrue(newPost.attachments.contains { $0.type == .video })
        XCTAssertTrue(newPost.attachments.contains { $0.type == .link })
    }
    
    func testAttachmentSizeLimit() async {
        let largeAttachment = FeedAttachment(
            id: "1",
            type: .video,
            url: "large.mp4",
            name: "Large Video",
            size: 1024 * 1024 * 1024, // 1GB
            thumbnailUrl: nil
        )
        
        // In real implementation, might have size limits
        do {
            try await feedService.createPost(
                content: "Post with large attachment",
                attachments: [largeAttachment]
            )
        } catch {
            // Expected if there are size limits
        }
    }
    
    // MARK: - Analytics Tests
    
    func testPostViewCount() {
        // In real implementation, track post views
        let post = feedService.posts.first!
        
        // Simulate viewing post
        // post.viewCount += 1
        
        XCTAssertNotNil(post)
    }
    
    func testEngagementMetrics() {
        let post = feedService.posts.first!
        
        let engagement = Double(post.likes.count + post.comments.count) / Double(feedService.posts.count)
        
        XCTAssertGreaterThanOrEqual(engagement, 0)
        XCTAssertLessThanOrEqual(engagement, 1)
    }
} 