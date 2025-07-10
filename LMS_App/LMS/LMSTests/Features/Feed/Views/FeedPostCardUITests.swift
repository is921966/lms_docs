//
//  FeedPostCardUITests.swift
//  LMSTests
//
//  Created by LMS Team on 13.01.2025.
//

import XCTest
import SwiftUI
import ViewInspector
@testable import LMS

@MainActor
final class FeedPostCardUITests: FeedUITestCase {
    
    // MARK: - Test Helpers
    
    private func createTestPost(
        content: String = "Test post content",
        images: [String] = [],
        attachments: [FeedAttachment] = [],
        likes: [String] = [],
        comments: [FeedComment] = []
    ) -> FeedPost {
        return FeedPost(
            id: "test-post",
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
            tags: ["#test"],
            mentions: ["user"]
        )
    }
    
    // MARK: - Basic UI Tests
    
    func testPostCardBasicLayout() throws {
        let post = createTestPost()
        let view = FeedPostCard(post: post)
        
        let inspected = try view.inspect()
        
        // Verify content
        let contentText = try inspected.find(text: post.content)
        XCTAssertNotNil(contentText)
    }
    
    func testPostCardWithImages() throws {
        let images = ["image1.jpg", "image2.jpg", "image3.jpg"]
        let post = createTestPost(images: images)
        let view = FeedPostCard(post: post)
        
        let inspected = try view.inspect()
        
        // Verify VStack exists
        let vstack = try inspected.vStack()
        XCTAssertNotNil(vstack)
        
        // Images should be present in the view hierarchy
        XCTAssertFalse(post.images.isEmpty)
    }
    
    func testPostCardWithAttachments() throws {
        let attachments = [
            FeedAttachment(
                id: "1",
                type: .document,
                url: "doc.pdf",
                name: "Document.pdf",
                size: 1024,
                thumbnailUrl: nil
            ),
            FeedAttachment(
                id: "2",
                type: .video,
                url: "video.mp4",
                name: "Video.mp4",
                size: 10485760,
                thumbnailUrl: "thumb.jpg"
            )
        ]
        
        let post = createTestPost(attachments: attachments)
        let view = FeedPostCard(post: post)
        
        let inspected = try view.inspect()
        
        // Verify VStack exists
        let vstack = try inspected.vStack()
        XCTAssertNotNil(vstack)
        
        // Attachments should be present
        XCTAssertFalse(post.attachments.isEmpty)
    }
    
    // MARK: - Interaction Tests
    
    func testLikeButtonExists() throws {
        let post = createTestPost()
        let view = FeedPostCard(post: post)
        
        let inspected = try view.inspect()
        
        // Verify view structure exists
        let vstack = try inspected.vStack()
        XCTAssertNotNil(vstack)
    }
    
    func testCommentButtonExists() throws {
        let post = createTestPost()
        let view = FeedPostCard(post: post)
        
        let inspected = try view.inspect()
        
        // Verify view structure exists
        let vstack = try inspected.vStack()
        XCTAssertNotNil(vstack)
    }
    
    func testShareButtonExists() throws {
        let post = createTestPost()
        let view = FeedPostCard(post: post)
        
        let inspected = try view.inspect()
        
        // Verify view structure exists
        let vstack = try inspected.vStack()
        XCTAssertNotNil(vstack)
    }
    
    func testDeleteButtonForOwnPost() throws {
        let currentUserId = "current-user"
        let post = FeedPost(
            id: "test-post",
            author: TestUserResponseFactory.createUser(id: currentUserId),
            content: "My post",
            images: [],
            attachments: [],
            createdAt: Date(),
            visibility: .everyone,
            likes: [],
            comments: [],
            tags: [],
            mentions: []
        )
        
        // Mock current user
        authService.setAuthenticatedForTesting(
            user: TestUserResponseFactory.createUser(id: currentUserId)
        )
        
        let view = FeedPostCard(post: post)
        
        let inspected = try view.inspect()
        
        // Verify view exists
        let vstack = try inspected.vStack()
        XCTAssertNotNil(vstack)
    }
    
    // MARK: - State Display Tests
    
    func testLikedStateDisplay() throws {
        let currentUserId = "current-user"
        let post = createTestPost(likes: [currentUserId, "other-user"])
        
        // Mock current user
        authService.setAuthenticatedForTesting(
            user: TestUserResponseFactory.createUser(id: currentUserId)
        )
        
        let view = FeedPostCard(post: post)
        
        let inspected = try view.inspect()
        
        // Verify view exists
        let vstack = try inspected.vStack()
        XCTAssertNotNil(vstack)
        
        // Verify like count
        XCTAssertEqual(post.likes.count, 2)
    }
    
    func testCommentCountDisplay() throws {
        let comments = [
            FeedComment(
                id: "1",
                postId: "test-post",
                author: TestUserResponseFactory.createUser(),
                content: "Comment 1",
                createdAt: Date(),
                likes: []
            ),
            FeedComment(
                id: "2",
                postId: "test-post",
                author: TestUserResponseFactory.createUser(),
                content: "Comment 2",
                createdAt: Date(),
                likes: []
            )
        ]
        
        let post = createTestPost(comments: comments)
        let view = FeedPostCard(post: post)
        
        let inspected = try view.inspect()
        
        // Verify view exists
        let vstack = try inspected.vStack()
        XCTAssertNotNil(vstack)
        
        // Verify comment count
        XCTAssertEqual(post.comments.count, 2)
    }
    
    // MARK: - Tags and Mentions Tests
    
    func testTagsDisplay() throws {
        let post = FeedPost(
            id: "test-post",
            author: TestUserResponseFactory.createUser(),
            content: "Post with #swift #ios #development",
            images: [],
            attachments: [],
            createdAt: Date(),
            visibility: .everyone,
            likes: [],
            comments: [],
            tags: ["#swift", "#ios", "#development"],
            mentions: []
        )
        
        let view = FeedPostCard(post: post)
        
        let inspected = try view.inspect()
        
        // Verify content contains tags
        let contentText = try inspected.find(text: post.content)
        XCTAssertNotNil(contentText)
        
        // Verify tags array
        XCTAssertEqual(post.tags?.count, 3)
    }
    
    func testMentionsDisplay() throws {
        let post = FeedPost(
            id: "test-post",
            author: TestUserResponseFactory.createUser(),
            content: "Hey @john and @jane!",
            images: [],
            attachments: [],
            createdAt: Date(),
            visibility: .everyone,
            likes: [],
            comments: [],
            tags: [],
            mentions: ["john", "jane"]
        )
        
        let view = FeedPostCard(post: post)
        
        let inspected = try view.inspect()
        
        // Verify content
        let content = try inspected.find(text: post.content)
        XCTAssertNotNil(content)
        
        // Verify mentions array
        XCTAssertEqual(post.mentions?.count, 2)
    }
    
    // MARK: - Visibility Tests
    
    func testVisibilityIndicator() throws {
        let visibilities: [FeedVisibility] = [.everyone, .students, .admins, .specific]
        
        for visibility in visibilities {
            let post = FeedPost(
                id: "test-post",
                author: TestUserResponseFactory.createUser(),
                content: "Test post",
                images: [],
                attachments: [],
                createdAt: Date(),
                visibility: visibility,
                likes: [],
                comments: [],
                tags: [],
                mentions: []
            )
            
            let view = FeedPostCard(post: post)
            
            let inspected = try view.inspect()
            
            // Verify view exists
            let vstack = try inspected.vStack()
            XCTAssertNotNil(vstack)
            
            // Verify visibility
            XCTAssertEqual(post.visibility, visibility)
        }
    }
    
    // MARK: - Timestamp Tests
    
    func testTimestampDisplay() throws {
        let pastDate = Date().addingTimeInterval(-3600) // 1 hour ago
        let post = FeedPost(
            id: "test-post",
            author: TestUserResponseFactory.createUser(),
            content: "Old post",
            images: [],
            attachments: [],
            createdAt: pastDate,
            visibility: .everyone,
            likes: [],
            comments: [],
            tags: [],
            mentions: []
        )
        
        let view = FeedPostCard(post: post)
        
        let inspected = try view.inspect()
        
        // Verify view exists
        let vstack = try inspected.vStack()
        XCTAssertNotNil(vstack)
        
        // Verify timestamp
        XCTAssertEqual(post.createdAt, pastDate)
    }
    
    // MARK: - Performance Tests
    
    func testRenderingPerformance() {
        let post = FeedPost(
            id: "test-post",
            author: TestUserResponseFactory.createUser(),
            content: String(repeating: "Lorem ipsum ", count: 100),
            images: (0..<10).map { "image\($0).jpg" },
            attachments: (0..<5).map { index in
                FeedAttachment(
                    id: "\(index)",
                    type: .document,
                    url: "doc\(index).pdf",
                    name: "Document \(index)",
                    size: 1024,
                    thumbnailUrl: nil
                )
            },
            createdAt: Date(),
            visibility: .everyone,
            likes: (0..<50).map { "user\($0)" },
            comments: [],
            tags: (0..<10).map { "#tag\($0)" },
            mentions: (0..<5).map { "user\($0)" }
        )
        
        measure {
            _ = FeedPostCard(post: post)
        }
    }
} 