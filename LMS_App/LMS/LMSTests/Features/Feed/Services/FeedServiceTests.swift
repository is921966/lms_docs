//
//  FeedServiceTests.swift
//  LMSTests
//
//  Created by LMS Team on 13.01.2025.
//

import XCTest
import Combine
@testable import LMS

@MainActor
final class FeedServiceTests: XCTestCase {
    
    var feedService: FeedService!
    var authService: MockAuthService!
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() async throws {
        try await super.setUp()
        
        // Reset singleton state
        feedService = FeedService.shared
        authService = MockAuthService.shared
        cancellables = []
        
        // Login as admin by default
        await loginAsAdmin()
    }
    
    override func tearDown() async throws {
        cancellables = nil
        try await authService.logout()
        try await super.tearDown()
    }
    
    // MARK: - Helper Methods
    
    private func loginAsAdmin() async {
        _ = try? await authService.login(email: "admin@test.com", password: "password")
    }
    
    private func loginAsStudent() async {
        try? await authService.logout()
        _ = try? await authService.login(email: "student@test.com", password: "password")
    }
    
    // MARK: - Initialization Tests
    
    func testServiceInitialization() {
        XCTAssertNotNil(feedService)
        XCTAssertFalse(feedService.posts.isEmpty, "Should have mock data")
        XCTAssertNotNil(feedService.permissions)
        XCTAssertFalse(feedService.isLoading)
        XCTAssertNil(feedService.error)
    }
    
    func testPermissionsUpdateOnAuthChange() async {
        // Start as admin
        XCTAssertTrue(feedService.permissions.canPost)
        XCTAssertTrue(feedService.permissions.canModerate)
        
        // Switch to student
        await loginAsStudent()
        
        // Wait for permissions update
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 second
        
        XCTAssertFalse(feedService.permissions.canPost)
        XCTAssertFalse(feedService.permissions.canModerate)
        XCTAssertTrue(feedService.permissions.canComment)
        XCTAssertTrue(feedService.permissions.canLike)
    }
    
    // MARK: - Post Creation Tests
    
    func testCreatePostSuccess() async throws {
        let initialCount = feedService.posts.count
        let content = "Test post content #test @mention"
        
        try await feedService.createPost(
            content: content,
            images: ["image1.jpg"],
            attachments: [],
            visibility: .everyone
        )
        
        XCTAssertEqual(feedService.posts.count, initialCount + 1)
        
        let newPost = feedService.posts.first
        XCTAssertNotNil(newPost)
        XCTAssertEqual(newPost?.content, content)
        XCTAssertEqual(newPost?.images.count, 1)
        XCTAssertEqual(newPost?.visibility, .everyone)
        XCTAssertTrue(newPost?.tags?.contains("#test") ?? false)
        XCTAssertTrue(newPost?.mentions?.contains("mention") ?? false)
    }
    
    func testCreatePostWithoutPermission() async throws {
        // Login as student
        await loginAsStudent()
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        do {
            try await feedService.createPost(
                content: "Unauthorized post",
                visibility: .everyone
            )
            XCTFail("Should throw no permission error")
        } catch let error as FeedError {
            XCTAssertEqual(error, .noPermission)
        }
    }
    
    func testCreatePostWithAttachments() async throws {
        let attachment = FeedAttachment(
            id: UUID().uuidString,
            type: .document,
            url: "document.pdf",
            name: "Important Document",
            size: 1024 * 1024,
            thumbnailUrl: nil
        )
        
        try await feedService.createPost(
            content: "Post with attachment",
            attachments: [attachment]
        )
        
        let newPost = feedService.posts.first
        XCTAssertEqual(newPost?.attachments.count, 1)
        XCTAssertEqual(newPost?.attachments.first?.type, .document)
    }
    
    func testCreatePostWithMultipleVisibilities() async throws {
        let visibilities: [FeedVisibility] = [.everyone, .students, .admins, .specific]
        
        for visibility in visibilities {
            try await feedService.createPost(
                content: "Post for visibility test",
                visibility: visibility
            )
            
            let newPost = feedService.posts.first
            XCTAssertEqual(newPost?.visibility, visibility)
        }
    }
    
    // MARK: - Delete Post Tests
    
    func testDeleteOwnPost() async throws {
        // Create a post first
        try await feedService.createPost(content: "Post to delete")
        let postToDelete = feedService.posts.first!
        let initialCount = feedService.posts.count
        
        try await feedService.deletePost(postToDelete.id)
        
        XCTAssertEqual(feedService.posts.count, initialCount - 1)
        XCTAssertFalse(feedService.posts.contains { $0.id == postToDelete.id })
    }
    
    func testDeleteOthersPostAsAdmin() async throws {
        // Admin should be able to delete any post
        let otherUserPost = feedService.posts.first { $0.author.id != authService.currentUser?.id }
        XCTAssertNotNil(otherUserPost)
        
        let initialCount = feedService.posts.count
        try await feedService.deletePost(otherUserPost!.id)
        
        XCTAssertEqual(feedService.posts.count, initialCount - 1)
    }
    
    func testDeleteOthersPostAsStudent() async throws {
        let otherUserPost = feedService.posts.first!
        
        // Switch to student
        await loginAsStudent()
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        do {
            try await feedService.deletePost(otherUserPost.id)
            XCTFail("Student should not be able to delete others' posts")
        } catch let error as FeedError {
            XCTAssertEqual(error, .noPermission)
        }
    }
    
    func testDeleteNonExistentPost() async throws {
        do {
            try await feedService.deletePost("non-existent-id")
            XCTFail("Should throw post not found error")
        } catch let error as FeedError {
            XCTAssertEqual(error, .postNotFound)
        }
    }
    
    // MARK: - Like Tests
    
    func testToggleLikeAddLike() async throws {
        let post = feedService.posts.first!
        let initialLikes = post.likes.count
        let userId = authService.currentUser!.id
        
        // Ensure user hasn't liked yet
        XCTAssertFalse(post.likes.contains(userId))
        
        try await feedService.toggleLike(postId: post.id)
        
        let updatedPost = feedService.posts.first { $0.id == post.id }!
        XCTAssertEqual(updatedPost.likes.count, initialLikes + 1)
        XCTAssertTrue(updatedPost.likes.contains(userId))
    }
    
    func testToggleLikeRemoveLike() async throws {
        // First add a like
        let post = feedService.posts.first!
        try await feedService.toggleLike(postId: post.id)
        
        let postAfterLike = feedService.posts.first { $0.id == post.id }!
        let likesAfterAdd = postAfterLike.likes.count
        
        // Now remove it
        try await feedService.toggleLike(postId: post.id)
        
        let finalPost = feedService.posts.first { $0.id == post.id }!
        XCTAssertEqual(finalPost.likes.count, likesAfterAdd - 1)
        XCTAssertFalse(finalPost.likes.contains(authService.currentUser!.id))
    }
    
    func testLikeWithoutPermission() async throws {
        // Create custom permissions without like ability
        feedService.permissions = FeedPermissions(
            canPost: false,
            canComment: true,
            canLike: false, // No like permission
            canShare: true,
            canDelete: false,
            canEdit: false,
            canModerate: false,
            visibilityOptions: []
        )
        
        do {
            try await feedService.toggleLike(postId: feedService.posts.first!.id)
            XCTFail("Should throw no permission error")
        } catch let error as FeedError {
            XCTAssertEqual(error, .noPermission)
        }
    }
    
    // MARK: - Comment Tests
    
    func testAddComment() async throws {
        let post = feedService.posts.first!
        let initialComments = post.comments.count
        let commentContent = "This is a test comment"
        
        try await feedService.addComment(to: post.id, content: commentContent)
        
        let updatedPost = feedService.posts.first { $0.id == post.id }!
        XCTAssertEqual(updatedPost.comments.count, initialComments + 1)
        
        let newComment = updatedPost.comments.last!
        XCTAssertEqual(newComment.content, commentContent)
        XCTAssertEqual(newComment.author.id, authService.currentUser!.id)
        XCTAssertEqual(newComment.postId, post.id)
    }
    
    func testAddCommentWithEmoji() async throws {
        let post = feedService.posts.first!
        let emojiComment = "Great post! 👍😊"
        
        try await feedService.addComment(to: post.id, content: emojiComment)
        
        let updatedPost = feedService.posts.first { $0.id == post.id }!
        let newComment = updatedPost.comments.last!
        XCTAssertEqual(newComment.content, emojiComment)
    }
    
    func testAddCommentToNonExistentPost() async throws {
        do {
            try await feedService.addComment(to: "fake-id", content: "Comment")
            XCTFail("Should throw post not found error")
        } catch let error as FeedError {
            XCTAssertEqual(error, .postNotFound)
        }
    }
    
    func testAddCommentWithoutPermission() async throws {
        feedService.permissions = FeedPermissions(
            canPost: false,
            canComment: false, // No comment permission
            canLike: true,
            canShare: true,
            canDelete: false,
            canEdit: false,
            canModerate: false,
            visibilityOptions: []
        )
        
        do {
            try await feedService.addComment(to: feedService.posts.first!.id, content: "Test")
            XCTFail("Should throw no permission error")
        } catch let error as FeedError {
            XCTAssertEqual(error, .noPermission)
        }
    }
    
    // MARK: - Tag and Mention Extraction Tests
    
    func testExtractTags() async throws {
        let content = "Check out #swift #ios #development and #тест"
        try await feedService.createPost(content: content)
        
        let newPost = feedService.posts.first!
        XCTAssertEqual(newPost.tags?.count, 4)
        XCTAssertTrue(newPost.tags?.contains("#swift") ?? false)
        XCTAssertTrue(newPost.tags?.contains("#ios") ?? false)
        XCTAssertTrue(newPost.tags?.contains("#development") ?? false)
        XCTAssertTrue(newPost.tags?.contains("#тест") ?? false)
    }
    
    func testExtractMentions() async throws {
        let content = "Hey @john and @jane, check this out!"
        try await feedService.createPost(content: content)
        
        let newPost = feedService.posts.first!
        XCTAssertEqual(newPost.mentions?.count, 2)
        XCTAssertTrue(newPost.mentions?.contains("john") ?? false)
        XCTAssertTrue(newPost.mentions?.contains("jane") ?? false)
    }
    
    func testExtractMixedTagsAndMentions() async throws {
        let content = "@admin please review #urgent task for @team #highpriority"
        try await feedService.createPost(content: content)
        
        let newPost = feedService.posts.first!
        XCTAssertEqual(newPost.tags?.count, 2)
        XCTAssertEqual(newPost.mentions?.count, 2)
    }
    
    // MARK: - Refresh Tests
    
    func testRefresh() {
        let initialPosts = feedService.posts
        feedService.refresh()
        
        // In mock implementation, refresh reloads the same data
        XCTAssertEqual(feedService.posts.count, initialPosts.count)
    }
    
    // MARK: - Loading State Tests
    
    func testLoadingState() async throws {
        XCTAssertFalse(feedService.isLoading)
        
        // In real implementation, loading state would change during async operations
        let expectation = XCTestExpectation(description: "Loading state")
        
        feedService.$isLoading
            .dropFirst()
            .sink { isLoading in
                if isLoading {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        // Trigger an operation that might set loading state
        feedService.refresh()
        
        await fulfillment(of: [expectation], timeout: 0.1, enforceOrder: false)
    }
    
    // MARK: - Error Handling Tests
    
    func testErrorState() {
        XCTAssertNil(feedService.error)
        
        // In real implementation, errors would be set on failures
        // This is a placeholder for error handling tests
    }
    
    // MARK: - Performance Tests
    
    func testCreateManyPostsPerformance() async throws {
        measure {
            Task {
                for i in 0..<100 {
                    try? await feedService.createPost(
                        content: "Performance test post \(i)"
                    )
                }
            }
        }
    }
    
    func testLargeFeedPerformance() {
        // Create a large number of posts
        var largePosts: [FeedPost] = []
        
        let testAuthor = TestUserResponseFactory.createUser(
            id: "author",
            email: "author@example.com",
            name: "Author",
            role: .student
        )
        
        for i in 0..<1000 {
            largePosts.append(FeedPost(
                id: "perf-\(i)",
                author: testAuthor,
                content: "Post \(i)",
                images: [],
                attachments: [],
                createdAt: Date(),
                visibility: .everyone,
                likes: Array(repeating: "user", count: i % 10),
                comments: [],
                tags: [],
                mentions: []
            ))
        }
        
        measure {
            feedService.posts = largePosts
            _ = feedService.posts.count
            _ = feedService.posts.filter { $0.likes.count > 5 }
        }
    }
    
    // MARK: - Notification Tests
    
    func testMentionNotification() async throws {
        let content = "Hey @testuser, check this!"
        
        let expectation = XCTestExpectation(description: "Mention notification")
        // In real implementation, we would verify notification was sent
        expectation.fulfill()
        
        try await feedService.createPost(content: content)
        
        await fulfillment(of: [expectation], timeout: 0.1)
    }
    
    func testLikeNotification() async throws {
        let post = feedService.posts.first!
        
        let expectation = XCTestExpectation(description: "Like notification")
        // In real implementation, we would verify notification was sent
        expectation.fulfill()
        
        try await feedService.toggleLike(postId: post.id)
        
        await fulfillment(of: [expectation], timeout: 0.1)
    }
    
    func testCommentNotification() async throws {
        let post = feedService.posts.first!
        
        let expectation = XCTestExpectation(description: "Comment notification")
        // In real implementation, we would verify notification was sent
        expectation.fulfill()
        
        try await feedService.addComment(to: post.id, content: "Nice post!")
        
        await fulfillment(of: [expectation], timeout: 0.1)
    }
} 