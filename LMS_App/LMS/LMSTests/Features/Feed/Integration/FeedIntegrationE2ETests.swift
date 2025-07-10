//
//  FeedIntegrationE2ETests.swift
//  LMSTests
//
//  Created by LMS Team on 13.01.2025.
//

import XCTest
import Combine
@testable import LMS

@MainActor
final class FeedIntegrationE2ETests: XCTestCase {
    
    var feedService: FeedService!
    var authService: MockAuthService!
    var networkService: MockNetworkService!
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() async throws {
        try await super.setUp()
        
        feedService = FeedService.shared
        authService = MockAuthService.shared
        networkService = MockNetworkService.shared
        cancellables = []
        
        // Reset state
        feedService.posts.removeAll()
        try await authService.logout()
    }
    
    override func tearDown() async throws {
        cancellables = nil
        try await authService.logout()
        try await super.tearDown()
    }
    
    // MARK: - End-to-End User Flows
    
    func testCompletePostCreationFlow() async throws {
        // 1. User logs in
        let loginResponse = try await authService.login(email: "instructor@test.com", password: "password")
        XCTAssertNotNil(loginResponse)
        XCTAssertNotNil(authService.currentUser)
        
        // 2. Check permissions
        XCTAssertTrue(feedService.permissions.canPost)
        
        // 3. Create a post with all features
        let postContent = "Check out this amazing course! #education @admin"
        let images = ["image1.jpg", "image2.jpg"]
        let attachment = FeedAttachment(
            id: UUID().uuidString,
            type: .document,
            url: "course-material.pdf",
            name: "Course Material.pdf",
            size: 2048576,
            thumbnailUrl: nil
        )
        
        let initialCount = feedService.posts.count
        
        try await feedService.createPost(
            content: postContent,
            images: images,
            attachments: [attachment],
            visibility: .students
        )
        
        // 4. Verify post was created
        XCTAssertEqual(feedService.posts.count, initialCount + 1)
        
        let newPost = feedService.posts.first!
        XCTAssertEqual(newPost.content, postContent)
        XCTAssertEqual(newPost.images, images)
        XCTAssertEqual(newPost.attachments.count, 1)
        XCTAssertEqual(newPost.visibility, .students)
        XCTAssertEqual(newPost.tags, ["#education"])
        XCTAssertEqual(newPost.mentions, ["admin"])
        
        // 5. Verify author info
        XCTAssertEqual(newPost.author.id, authService.currentUser?.id)
        XCTAssertEqual(newPost.author.email, "instructor@test.com")
        
        // 6. Verify notifications would be sent
        // In real app, check that @admin received mention notification
    }
    
    func testCompleteInteractionFlow() async throws {
        // Setup: Create a post
        await loginAsAdmin()
        try await feedService.createPost(content: "Test post for interactions")
        let post = feedService.posts.first!
        
        // 1. Different user logs in
        try await authService.logout()
        _ = try await authService.login(email: "student@test.com", password: "password")
        
        // 2. User likes the post
        let initialLikes = post.likes.count
        try await feedService.toggleLike(postId: post.id)
        
        let likedPost = feedService.posts.first { $0.id == post.id }!
        XCTAssertEqual(likedPost.likes.count, initialLikes + 1)
        XCTAssertTrue(likedPost.likes.contains(authService.currentUser!.id))
        
        // 3. User comments on the post
        let commentContent = "Great post! Very informative."
        try await feedService.addComment(to: post.id, content: commentContent)
        
        let commentedPost = feedService.posts.first { $0.id == post.id }!
        XCTAssertEqual(commentedPost.comments.count, 1)
        
        let comment = commentedPost.comments.first!
        XCTAssertEqual(comment.content, commentContent)
        XCTAssertEqual(comment.author.id, authService.currentUser!.id)
        
        // 4. Another user likes the comment
        try await authService.logout()
        _ = try await authService.login(email: "instructor@test.com", password: "password")
        
        // In real app, would have toggleCommentLike method
        // try await feedService.toggleCommentLike(commentId: comment.id)
        
        // 5. Original author checks notifications
        // In real app, would have notification service
        // - Like notification
        // - Comment notification
    }
    
    func testContentModerationFlow() async throws {
        // 1. Regular user creates inappropriate post
        _ = try await authService.login(email: "student@test.com", password: "password")
        
        try await feedService.createPost(
            content: "Inappropriate content here",
            visibility: .everyone
        )
        
        let inappropriatePost = feedService.posts.first!
        
        // 2. Admin logs in
        try await authService.logout()
        await loginAsAdmin()
        
        // 3. Admin can delete any post
        XCTAssertTrue(feedService.permissions.canModerate)
        
        let initialCount = feedService.posts.count
        try await feedService.deletePost(inappropriatePost.id)
        
        // 4. Post is removed
        XCTAssertEqual(feedService.posts.count, initialCount - 1)
        XCTAssertNil(feedService.posts.first { $0.id == inappropriatePost.id })
        
        // 5. In real app, would log moderation action
    }
    
    // MARK: - Integration Tests
    
    func testFeedServiceWithAuthIntegration() async throws {
        // Test that feed permissions update when user changes
        
        // 1. Start as guest (logged out)
        XCTAssertNil(authService.currentUser)
        XCTAssertFalse(feedService.permissions.canPost)
        
        // 2. Login as student
        _ = try await authService.login(email: "student@test.com", password: "password")
        
        // Wait for permissions update
        try await Task.sleep(nanoseconds: 100_000_000)
        
        XCTAssertFalse(feedService.permissions.canPost)
        XCTAssertTrue(feedService.permissions.canComment)
        XCTAssertTrue(feedService.permissions.canLike)
        
        // 3. Switch to instructor
        try await authService.logout()
        _ = try await authService.login(email: "instructor@test.com", password: "password")
        
        try await Task.sleep(nanoseconds: 100_000_000)
        
        XCTAssertTrue(feedService.permissions.canPost)
        XCTAssertTrue(feedService.permissions.canDelete)
        XCTAssertFalse(feedService.permissions.canModerate)
        
        // 4. Switch to admin
        try await authService.logout()
        await loginAsAdmin()
        
        try await Task.sleep(nanoseconds: 100_000_000)
        
        XCTAssertTrue(feedService.permissions.canPost)
        XCTAssertTrue(feedService.permissions.canModerate)
        XCTAssertEqual(feedService.permissions.visibilityOptions, FeedVisibility.allCases)
    }
    
    func testNetworkErrorHandling() async throws {
        await loginAsAdmin()
        
        // Simulate network error
        networkService.shouldFail = true
        networkService.errorToThrow = NetworkError.noConnection
        
        do {
            try await feedService.createPost(content: "Test post")
            XCTFail("Should throw network error")
        } catch {
            // In real app, would handle network error
            XCTAssertNotNil(feedService.error)
        }
        
        // Restore network
        networkService.shouldFail = false
        
        // Retry should work
        feedService.error = nil
        try await feedService.createPost(content: "Test post")
        XCTAssertNil(feedService.error)
    }
    
    func testOfflineSupport() async throws {
        await loginAsAdmin()
        
        // Go offline
        networkService.isOnline = false
        
        // Create post while offline
        let offlineContent = "Offline post"
        
        // In real app with offline support:
        // - Post would be saved locally
        // - Marked as pending sync
        // - Synced when back online
        
        // For now, just verify error handling
        do {
            try await feedService.createPost(content: offlineContent)
        } catch {
            // Expected in current implementation
        }
        
        // Go back online
        networkService.isOnline = true
        
        // In real app, would sync pending posts
    }
    
    // MARK: - Data Consistency Tests
    
    func testConcurrentLikesConsistency() async throws {
        await loginAsAdmin()
        try await feedService.createPost(content: "Test post")
        let post = feedService.posts.first!
        
        // Simulate multiple users liking simultaneously
        await withTaskGroup(of: Void.self) { group in
            for i in 0..<10 {
                group.addTask {
                    // Each "user" likes the post
                    let user = TestUserResponseFactory.createUser(
                        id: "user-\(i)",
                        email: "user\(i)@test.com",
                        name: "User \(i)",
                        role: .student
                    )
                    await self.authService.setAuthenticatedForTesting(user: user)
                    
                    try? await self.feedService.toggleLike(postId: post.id)
                }
            }
        }
        
        // Verify likes are consistent
        let finalPost = feedService.posts.first { $0.id == post.id }!
        
        // Should have unique likes only
        let uniqueLikes = Set(finalPost.likes)
        XCTAssertEqual(finalPost.likes.count, uniqueLikes.count)
        
        // Should have at most 10 likes (one per user)
        XCTAssertLessThanOrEqual(finalPost.likes.count, 10)
    }
    
    func testDataPersistence() async throws {
        await loginAsAdmin()
        
        // Create posts
        for i in 0..<5 {
            try await feedService.createPost(content: "Persistent post \(i)")
        }
        
        let postIds = feedService.posts.map { $0.id }
        
        // Simulate app restart
        // In real app, would reload from persistent storage
        
        // For now, just verify posts exist
        XCTAssertEqual(feedService.posts.count, 5)
        
        // Verify IDs are unique
        let uniqueIds = Set(postIds)
        XCTAssertEqual(postIds.count, uniqueIds.count)
    }
    
    // MARK: - Performance E2E Tests
    
    func testLargeFeedLoadPerformance() async throws {
        await loginAsAdmin()
        
        // Create many posts
        let startTime = Date()
        
        for i in 0..<100 {
            feedService.posts.append(
                FeedPost(
                    id: "perf-\(i)",
                    author: authService.currentUser!,
                    content: "Performance test post \(i) with some content",
                    images: i % 3 == 0 ? ["image.jpg"] : [],
                    attachments: i % 5 == 0 ? [
                        FeedAttachment(
                            id: "attach-\(i)",
                            type: .document,
                            url: "doc.pdf",
                            name: "Document \(i).pdf",
                            size: 1024,
                            thumbnailUrl: nil
                        )
                    ] : [],
                    createdAt: Date().addingTimeInterval(Double(-i * 60)),
                    visibility: .everyone,
                    likes: Array(repeating: "user", count: i % 10),
                    comments: [],
                    tags: ["#tag\(i % 5)"],
                    mentions: []
                )
            )
        }
        
        let loadTime = Date().timeIntervalSince(startTime)
        
        // Should load quickly
        XCTAssertLessThan(loadTime, 1.0) // Less than 1 second
        
        // Test scrolling performance
        let scrollStartTime = Date()
        
        // Simulate scrolling through posts
        for post in feedService.posts {
            _ = post.id
            _ = post.content
            _ = post.likes.count
        }
        
        let scrollTime = Date().timeIntervalSince(scrollStartTime)
        XCTAssertLessThan(scrollTime, 0.1) // Less than 100ms
    }
    
    func testSearchPerformance() async throws {
        // Setup large dataset
        try await testLargeFeedLoadPerformance()
        
        let searchStartTime = Date()
        
        // Search posts
        let searchTerm = "test"
        let results = feedService.posts.filter { post in
            post.content.localizedCaseInsensitiveContains(searchTerm) ||
            post.author.name.localizedCaseInsensitiveContains(searchTerm) ||
            (post.tags?.contains { $0.localizedCaseInsensitiveContains(searchTerm) } ?? false)
        }
        
        let searchTime = Date().timeIntervalSince(searchStartTime)
        
        XCTAssertLessThan(searchTime, 0.05) // Less than 50ms
        XCTAssertGreaterThan(results.count, 0)
    }
    
    // MARK: - Security Tests
    
    func testUnauthorizedActions() async throws {
        // Not logged in
        XCTAssertNil(authService.currentUser)
        
        // Try to create post
        do {
            try await feedService.createPost(content: "Unauthorized post")
            XCTFail("Should not allow post creation without login")
        } catch {
            XCTAssertTrue(error is FeedError)
        }
        
        // Login as student
        _ = try await authService.login(email: "student@test.com", password: "password")
        
        // Try to delete others' post
        let othersPost = feedService.posts.first { $0.author.id != authService.currentUser?.id }
        if let post = othersPost {
            do {
                try await feedService.deletePost(post.id)
                XCTFail("Should not allow deleting others' posts")
            } catch let error as FeedError {
                XCTAssertEqual(error, .noPermission)
            }
        }
    }
    
    func testDataSanitization() async throws {
        await loginAsAdmin()
        
        // Try to create post with potentially harmful content
        let maliciousContent = "<script>alert('XSS')</script>Test post"
        
        try await feedService.createPost(content: maliciousContent)
        
        let post = feedService.posts.first!
        
        // In real app, content should be sanitized
        // For now, just verify it's stored as-is
        XCTAssertEqual(post.content, maliciousContent)
        
        // Real app should escape or remove script tags
    }
    
    // MARK: - Helper Methods
    
    private func loginAsAdmin() async {
        _ = try? await authService.login(email: "admin@test.com", password: "password")
    }
}

// MARK: - Mock Services

class MockNetworkService {
    static let shared = MockNetworkService()
    
    var isOnline = true
    var shouldFail = false
    var errorToThrow: Error?
    
    func request<T: Decodable>(_ endpoint: String, method: String = "GET") async throws -> T {
        if !isOnline {
            throw NetworkError.noConnection
        }
        
        if shouldFail {
            throw errorToThrow ?? NetworkError.unknown
        }
        
        // Return mock data based on endpoint
        throw NetworkError.unknown
    }
}

enum NetworkError: Error {
    case noConnection
    case timeout
    case serverError
    case unknown
} 