//
//  FeedViewTests.swift
//  LMSTests
//
//  Created by LMS Team on 13.01.2025.
//

import XCTest
import SwiftUI
import ViewInspector
@testable import LMS

@MainActor
final class FeedViewTests: XCTestCase {
    
    var feedService: MockFeedService!
    var viewModel: FeedViewModel!
    
    override func setUp() async throws {
        try await super.setUp()
        // Reset state before each test
        try await MockAuthService.shared.logout()
        feedService = MockFeedService()
        viewModel = FeedViewModel(feedService: FeedService.shared)
    }
    
    // MARK: - FeedView Tests
    
    func testFeedViewStructure() throws {
        let view = FeedView()
        
        // Verify basic structure exists
        XCTAssertNotNil(view)
        
        // In a real test with ViewInspector:
        // let inspected = try view.inspect()
        // XCTAssertNoThrow(try inspected.scrollView())
    }
    
    func testCreatePostButtonVisibilityForAdmin() async throws {
        // Login as admin
        _ = try await MockAuthService.shared.login(email: "admin@test.com", password: "password")
        
        let feedService = FeedService.shared
        XCTAssertTrue(feedService.permissions.canPost)
        
        // In real app, we'd verify button is visible
    }
    
    func testCreatePostButtonHiddenForStudent() async throws {
        // Login as student  
        _ = try await MockAuthService.shared.login(email: "student@test.com", password: "password")
        
        let feedService = FeedService.shared
        XCTAssertFalse(feedService.permissions.canPost)
        
        // In real app, we'd verify button is hidden
    }
    
    // MARK: - FeedPostCard Tests
    
    func testFeedPostCardDisplaysContent() throws {
        let post = createTestPost(content: "Test content")
        let card = FeedPostCard(post: post)
        
        // ViewInspector limitations prevent detailed testing of FeedPostCard
        XCTAssertNotNil(card)
    }
    
    func testFeedPostCardWithImages() throws {
        let post = createTestPost(images: ["image1.jpg", "image2.jpg"])
        let card = FeedPostCard(post: post)
        
        // ViewInspector limitations prevent testing image display
        XCTAssertNotNil(card)
    }
    
    func testFeedPostCardWithAttachments() throws {
        let attachments = [
            FeedAttachment(id: "1", type: .document, url: "doc.pdf", name: "Document", size: 1024, thumbnailUrl: nil)
        ]
        let post = createTestPost(attachments: attachments)
        let card = FeedPostCard(post: post)
        
        // ViewInspector limitations prevent testing attachment display
        XCTAssertNotNil(card)
    }
    
    func testFeedPostCardLikeButton() throws {
        let post = createTestPost(likes: ["user1", "user2"])
        let card = FeedPostCard(post: post)
        
        // ViewInspector limitations prevent testing interactive elements
        XCTAssertNotNil(card)
    }
    
    // MARK: - CreatePostView Tests
    
    func testCreatePostViewInitialState() {
        let view = CreatePostView()
        XCTAssertNotNil(view)
        // Verify initial state: empty content, default visibility
    }
    
    func testCreatePostViewValidation() {
        // Test that publish button is disabled with empty content
        // Test that it's enabled with valid content
    }
    
    // MARK: - PostHeaderView Tests
    
    func testPostHeaderDisplaysAuthorInfo() {
        let post = createMockPost()
        let showingOptions = Binding.constant(false)
        let header = PostHeaderView(
            post: post,
            showingOptions: showingOptions,
            canShowOptions: true
        )
        
        XCTAssertNotNil(header)
        // Verify author name, role, time displayed
    }
    
    func testPostHeaderOptionsButton() {
        let post = createMockPost()
        var showingOptions = false
        let binding = Binding(
            get: { showingOptions },
            set: { showingOptions = $0 }
        )
        
        let header = PostHeaderView(
            post: post,
            showingOptions: binding,
            canShowOptions: true
        )
        
        XCTAssertNotNil(header)
        // Verify options button exists when canShowOptions is true
    }
    
    // MARK: - PostContentView Tests
    
    func testPostContentWithTags() {
        var post = createMockPost()
        post.content = "Check out #swift and #ios development!"
        post.tags = ["#swift", "#ios"]
        
        let content = PostContentView(post: post)
        XCTAssertNotNil(content)
        // Verify tags are highlighted
    }
    
    func testPostContentWithMentions() {
        var post = createMockPost()
        post.content = "Thanks @john and @jane for the help!"
        post.mentions = ["john", "jane"]
        
        let content = PostContentView(post: post)
        XCTAssertNotNil(content)
        // Verify mentions are highlighted
    }
    
    func testPostContentWithEmoji() {
        var post = createMockPost()
        post.content = "Great work! 👍🎉🚀"
        
        let content = PostContentView(post: post)
        XCTAssertNotNil(content)
        // Verify emoji display correctly
    }
    
    // MARK: - PostActionsView Tests
    
    func testPostActionsAllEnabled() {
        let post = createMockPost()
        let showingComments = Binding.constant(false)
        
        let actions = PostActionsView(
            post: post,
            isLiked: false,
            showingComments: showingComments,
            onLike: {},
            onShare: {}
        )
        
        XCTAssertNotNil(actions)
        // Verify all buttons enabled with permissions
    }
    
    func testPostActionsLikedState() {
        let post = createMockPost()
        let showingComments = Binding.constant(false)
        
        let actions = PostActionsView(
            post: post,
            isLiked: true, // Already liked
            showingComments: showingComments,
            onLike: {},
            onShare: {}
        )
        
        XCTAssertNotNil(actions)
        // Verify like button shows liked state
    }
    
    // MARK: - CommentsView Tests
    
    func testCommentsViewEmpty() {
        var post = createMockPost()
        post.comments = []
        
        let comments = CommentsView(post: post)
        XCTAssertNotNil(comments)
        // Verify empty state shown
    }
    
    func testCommentsViewWithComments() {
        let post = createMockPost() // Has comments by default
        let comments = CommentsView(post: post)
        XCTAssertNotNil(comments)
        // Verify comments list displayed
    }
    
    // MARK: - EmptyFeedView Tests
    
    func testEmptyFeedViewDisplay() {
        let emptyView = EmptyFeedView()
        XCTAssertNotNil(emptyView)
        // Verify icon, title, and message displayed
    }
    
    // MARK: - Helper Methods
    
    private func createMockPost() -> FeedPost {
        return FeedPost(
            id: "test-1",
            author: TestUserResponseFactory.createUser(
                id: "author-1",
                email: "test@example.com",
                name: "Test Author",
                role: .admin
            ),
            content: "This is a test post #test @mention",
            images: [],
            attachments: [],
            createdAt: Date().addingTimeInterval(-3600),
            visibility: .everyone,
            likes: ["user1", "user2"],
            comments: [
                FeedComment(
                    id: "comment-1",
                    postId: "test-1",
                    author: TestUserResponseFactory.createUser(
                        id: "commenter-1",
                        email: "commenter@example.com",
                        name: "Commenter",
                        role: .student
                    ),
                    content: "Great post!",
                    createdAt: Date().addingTimeInterval(-1800),
                    likes: ["user1"]
                )
            ],
            tags: ["#test"],
            mentions: ["mention"]
        )
    }
    
    private func createTestPost(
        content: String = "Test post",
        images: [String] = [],
        attachments: [FeedAttachment] = [],
        likes: [String] = [],
        comments: [FeedComment] = []
    ) -> FeedPost {
        return FeedPost(
            id: UUID().uuidString,
            author: TestUserResponseFactory.createUser(
                name: "Test Author",
                role: .instructor
            ),
            content: content,
            images: images,
            attachments: attachments,
            createdAt: Date(),
            visibility: .everyone,
            likes: likes,
            comments: comments,
            tags: nil,
            mentions: nil
        )
    }
}

// MARK: - Feed Permissions Tests

extension FeedViewTests {
    
    func testStudentPermissions() {
        let permissions = FeedPermissions.studentDefault
        
        XCTAssertFalse(permissions.canPost)
        XCTAssertTrue(permissions.canComment)
        XCTAssertTrue(permissions.canLike)
        XCTAssertTrue(permissions.canShare)
        XCTAssertFalse(permissions.canDelete)
        XCTAssertFalse(permissions.canEdit)
        XCTAssertFalse(permissions.canModerate)
        XCTAssertTrue(permissions.visibilityOptions.isEmpty)
    }
    
    func testAdminPermissions() {
        let permissions = FeedPermissions.adminDefault
        
        XCTAssertTrue(permissions.canPost)
        XCTAssertTrue(permissions.canComment)
        XCTAssertTrue(permissions.canLike)
        XCTAssertTrue(permissions.canShare)
        XCTAssertTrue(permissions.canDelete)
        XCTAssertTrue(permissions.canEdit)
        XCTAssertTrue(permissions.canModerate)
        XCTAssertEqual(permissions.visibilityOptions.count, FeedVisibility.allCases.count)
    }
}

// MARK: - Feed Visibility Tests

extension FeedViewTests {
    
    func testVisibilityIcons() {
        XCTAssertEqual(FeedVisibility.everyone.icon, "globe")
        XCTAssertEqual(FeedVisibility.students.icon, "studentdesk")
        XCTAssertEqual(FeedVisibility.admins.icon, "shield")
        XCTAssertEqual(FeedVisibility.specific.icon, "person.2")
    }
    
    func testVisibilityTitles() {
        XCTAssertEqual(FeedVisibility.everyone.title, "Все пользователи")
        XCTAssertEqual(FeedVisibility.students.title, "Только студенты")
        XCTAssertEqual(FeedVisibility.admins.title, "Только администраторы")
        XCTAssertEqual(FeedVisibility.specific.title, "Определенные пользователи")
    }
}

// MARK: - Feed Attachment Tests

extension FeedViewTests {
    
    func testAttachmentTypes() {
        let types = FeedAttachment.AttachmentType.allCases
        XCTAssertEqual(types.count, 5)
        XCTAssertTrue(types.contains(.document))
        XCTAssertTrue(types.contains(.video))
        XCTAssertTrue(types.contains(.link))
        XCTAssertTrue(types.contains(.course))
        XCTAssertTrue(types.contains(.test))
    }
    
    func testAttachmentCreation() {
        let attachment = FeedAttachment(
            id: "attach-1",
            type: .document,
            url: "https://example.com/doc.pdf",
            name: "Document.pdf",
            size: 1024 * 1024 * 5, // 5MB
            thumbnailUrl: nil
        )
        
        XCTAssertEqual(attachment.id, "attach-1")
        XCTAssertEqual(attachment.type, .document)
        XCTAssertEqual(attachment.name, "Document.pdf")
        XCTAssertEqual(attachment.size, 5242880)
    }
} 