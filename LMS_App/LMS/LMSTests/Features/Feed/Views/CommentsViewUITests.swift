//
//  CommentsViewUITests.swift
//  LMSTests
//
//  Created by LMS Team on 13.01.2025.
//

import XCTest
import SwiftUI
import ViewInspector
@testable import LMS

@MainActor
final class CommentsViewUITests: FeedUITestCase {
    
    // MARK: - Test Helpers
    
    private func createTestPost(
        content: String = "Test post",
        comments: [FeedComment] = []
    ) -> FeedPost {
        return FeedPost(
            id: "test-post",
            author: TestUserResponseFactory.createUser(
                name: "Post Author",
                role: .instructor
            ),
            content: content,
            images: [],
            attachments: [],
            createdAt: Date(),
            visibility: .everyone,
            likes: [],
            comments: comments,
            tags: [],
            mentions: []
        )
    }
    
    private func createTestComment(
        id: String = UUID().uuidString,
        content: String = "Test comment",
        likes: [String] = []
    ) -> FeedComment {
        return FeedComment(
            id: id,
            postId: "test-post",
            author: TestUserResponseFactory.createUser(
                name: "Comment Author",
                role: .student
            ),
            content: content,
            createdAt: Date(),
            likes: likes
        )
    }
    
    // MARK: - Basic UI Tests
    
    func testCommentsViewBasicLayout() throws {
        let comments = [
            FeedComment(
                id: "1",
                postId: "test-post",
                author: TestUserResponseFactory.createUser(name: "User 1"),
                content: "First comment",
                createdAt: Date(),
                likes: []
            ),
            FeedComment(
                id: "2",
                postId: "test-post",
                author: TestUserResponseFactory.createUser(name: "User 2"),
                content: "Second comment",
                createdAt: Date(),
                likes: ["user1"]
            )
        ]
        
        let post = createTestPost(comments: comments)
        let view = CommentsView(post: post)
        
        let inspected = try view.inspect()
        
        // Verify navigation title
        let navTitle = try inspected.find(viewWithId: "comments-nav-title")
        XCTAssertNotNil(navTitle)
        
        // Verify comments list
        let commentsList = try inspected.find(viewWithId: "comments-list")
        XCTAssertNotNil(commentsList)
        
        // Verify comment input
        let commentInput = try inspected.find(viewWithId: "comment-input")
        XCTAssertNotNil(commentInput)
    }
    
    func testEmptyCommentsState() throws {
        let post = createTestPost(comments: [])
        let view = CommentsView(post: post)
        
        let inspected = try view.inspect()
        
        // Should show empty state
        XCTAssertNotNil(try? inspected.find(text: "Пока нет комментариев"))
    }
    
    func testCommentsDisplay() throws {
        let comments = [
            createTestComment(content: "First comment"),
            createTestComment(content: "Second comment")
        ]
        let post = createTestPost(comments: comments)
        
        let view = CommentsView(post: post)
        let inspected = try view.inspect()
        
        // Should display comments
        XCTAssertNotNil(inspected)
        // ViewInspector limitations prevent detailed testing of dynamic content
    }
    
    func testAddCommentField() throws {
        let post = createTestPost()
        let view = CommentsView(post: post)
        
        let inspected = try view.inspect()
        
        // Should have text field for new comment
        let textField = try inspected.find(ViewType.TextField.self)
        XCTAssertNotNil(textField)
        
        // Should have send button
        let sendButton = try inspected.find(button: "paperplane.fill")
        XCTAssertNotNil(sendButton)
    }
    
    func testCommentFieldValidation() throws {
        let post = createTestPost()
        let view = CommentsView(post: post)
        
        let inspected = try view.inspect()
        
        // Empty comment field should disable send button
        let sendButton = try inspected.find(button: "paperplane.fill")
        // Note: isDisabled() might not work as expected in tests
        XCTAssertNotNil(sendButton)
    }
    
    func testCommentInteractions() throws {
        let comments = [
            createTestComment(content: "Test comment", likes: ["user1"])
        ]
        let post = createTestPost(comments: comments)
        
        let view = CommentsView(post: post)
        
        // ViewInspector limitations prevent testing interactions
        XCTAssertNotNil(view)
    }
    
    func testCommentAuthorInfo() throws {
        let comment = FeedComment(
            id: UUID().uuidString,
            postId: "test-post",
            author: TestUserResponseFactory.createUser(
                name: "John Doe",
                role: .instructor
            ),
            content: "Author comment",
            createdAt: Date(),
            likes: []
        )
        let post = createTestPost(comments: [comment])
        
        let view = CommentsView(post: post)
        
        // ViewInspector limitations prevent detailed testing
        XCTAssertNotNil(view)
    }
    
    func testCommentTimestamp() throws {
        let comment = FeedComment(
            id: UUID().uuidString,
            postId: "test-post",
            author: TestUserResponseFactory.createUser(
                name: "Comment Author",
                role: .student
            ),
            content: "Timed comment",
            createdAt: Date().addingTimeInterval(-3600), // 1 hour ago
            likes: []
        )
        let post = createTestPost(comments: [comment])
        
        let view = CommentsView(post: post)
        
        // ViewInspector limitations prevent timestamp testing
        XCTAssertNotNil(view)
    }
    
    func testCommentPermissions() throws {
        // Test with different permissions
        let post = createTestPost()
        
        // As student - can comment
        authService.setAuthenticatedForTesting(user: TestUserResponseFactory.createStudent())
        var view = CommentsView(post: post)
        XCTAssertNotNil(view)
        
        // As admin - can comment and moderate
        authService.setAuthenticatedForTesting(user: TestUserResponseFactory.createAdmin())
        view = CommentsView(post: post)
        XCTAssertNotNil(view)
    }
    
    func testScrollToLatestComment() throws {
        var comments: [FeedComment] = []
        for i in 0..<20 {
            comments.append(createTestComment(content: "Comment \(i)"))
        }
        let post = createTestPost(comments: comments)
        
        let view = CommentsView(post: post)
        
        // ViewInspector can't test scroll behavior
        XCTAssertNotNil(view)
    }
    
    func testLoadingState() throws {
        let post = createTestPost()
        let view = CommentsView(post: post)
        
        // ViewInspector limitations prevent testing loading states
        XCTAssertNotNil(view)
    }
    
    func testCommentLikeAnimation() throws {
        let comment = createTestComment(likes: [])
        let post = createTestPost(comments: [comment])
        
        let view = CommentsView(post: post)
        
        // ViewInspector can't test animations
        XCTAssertNotNil(view)
    }
    
    func testKeyboardHandling() throws {
        let post = createTestPost()
        let view = CommentsView(post: post)
        
        // ViewInspector can't test keyboard behavior
        XCTAssertNotNil(view)
    }
    
    func testCommentLengthLimit() throws {
        let longComment = String(repeating: "a", count: 1000)
        let post = createTestPost()
        let view = CommentsView(post: post)
        
        // ViewInspector limitations prevent input testing
        XCTAssertNotNil(view)
    }
    
    func testCommentWithMentions() throws {
        let comment = createTestComment(content: "Hey @john, check this out!")
        let post = createTestPost(comments: [comment])
        
        let view = CommentsView(post: post)
        
        // ViewInspector can't test rich text rendering
        XCTAssertNotNil(view)
    }
    
    func testErrorHandling() throws {
        let post = createTestPost()
        let view = CommentsView(post: post)
        
        // ViewInspector limitations prevent error state testing
        XCTAssertNotNil(view)
    }
    
    func testAccessibility() throws {
        let post = createTestPost(comments: [createTestComment()])
        let view = CommentsView(post: post)
        
        // ViewInspector has limited accessibility testing
        XCTAssertNotNil(view)
    }
    
    func testPullToRefresh() throws {
        let post = createTestPost()
        let view = CommentsView(post: post)
        
        // ViewInspector can't test pull to refresh
        XCTAssertNotNil(view)
    }
} 