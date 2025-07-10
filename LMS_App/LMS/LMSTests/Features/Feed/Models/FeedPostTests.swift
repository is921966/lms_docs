//
//  FeedPostTests.swift
//  LMSTests
//
//  Created by LMS Team on 13.01.2025.
//

import XCTest
@testable import LMS

final class FeedPostTests: XCTestCase {
    
    // MARK: - Test Helpers
    
    private func createTestPost(
        id: String = "test-post-1",
        content: String = "Test post content",
        visibility: FeedVisibility = .everyone,
        likes: [String] = [],
        comments: [FeedComment] = []
    ) -> FeedPost {
        return FeedPost(
            id: id,
            author: TestUserResponseFactory.createUser(
                id: "author-1",
                name: "John Doe",
                role: .instructor
            ),
            content: content,
            images: [],
            attachments: [],
            createdAt: Date(),
            visibility: visibility,
            likes: likes,
            comments: comments,
            tags: nil,
            mentions: nil
        )
    }
    
    // MARK: - Initialization Tests
    
    func testPostInitialization() {
        let postId = "post-123"
        let content = "This is a test post"
        let images = ["image1.jpg", "image2.jpg"]
        let createdAt = Date()
        let visibility = FeedVisibility.everyone
        let likes = ["user1", "user2"]
        
        let author = TestUserResponseFactory.createUser(
            id: "author-1",
            name: "Test Author",
            role: .admin
        )
        
        let post = FeedPost(
            id: postId,
            author: author,
            content: content,
            images: images,
            attachments: [],
            createdAt: createdAt,
            visibility: visibility,
            likes: likes,
            comments: [],
            tags: ["#test"],
            mentions: ["user1"]
        )
        
        XCTAssertEqual(post.id, postId)
        XCTAssertEqual(post.author.id, author.id)
        XCTAssertEqual(post.content, content)
        XCTAssertEqual(post.images, images)
        XCTAssertEqual(post.createdAt, createdAt)
        XCTAssertEqual(post.visibility, visibility)
        XCTAssertEqual(post.likes, likes)
        XCTAssertTrue(post.comments.isEmpty)
        XCTAssertEqual(post.tags, ["#test"])
        XCTAssertEqual(post.mentions, ["user1"])
    }
    
    func testPostWithAttachments() {
        let attachment = FeedAttachment(
            id: "attach-1",
            type: .document,
            url: "document.pdf",
            name: "Test Document",
            size: 1024,
            thumbnailUrl: nil
        )
        
        let author = TestUserResponseFactory.createInstructor()
        
        let post = FeedPost(
            id: "post-1",
            author: author,
            content: "Post with attachment",
            images: [],
            attachments: [attachment],
            createdAt: Date(),
            visibility: .students,
            likes: [],
            comments: [],
            tags: nil,
            mentions: nil
        )
        
        XCTAssertEqual(post.attachments.count, 1)
        XCTAssertEqual(post.attachments.first?.type, .document)
        XCTAssertEqual(post.attachments.first?.name, "Test Document")
    }
    
    // MARK: - Comment Tests
    
    func testPostWithComments() {
        let comment1 = FeedComment(
            id: "comment-1",
            postId: "post-1",
            author: TestUserResponseFactory.createStudent(name: "Student User"),
            content: "Great post!",
            createdAt: Date(),
            likes: ["user1"]
        )
        
        let comment2 = FeedComment(
            id: "comment-2",
            postId: "post-1",
            author: TestUserResponseFactory.createAdmin(name: "Admin User"),
            content: "Thanks for sharing",
            createdAt: Date(),
            likes: []
        )
        
        let post = createTestPost(comments: [comment1, comment2])
        
        XCTAssertEqual(post.comments.count, 2)
        XCTAssertEqual(post.comments[0].content, "Great post!")
        XCTAssertEqual(post.comments[1].content, "Thanks for sharing")
    }
    
    func testAddCommentToPost() {
        var post = createTestPost()
        XCTAssertTrue(post.comments.isEmpty)
        
        let newComment = FeedComment(
            id: "new-comment",
            postId: post.id,
            author: TestUserResponseFactory.createUser(
                id: "commenter-1",
                name: "New Commenter",
                role: .student
            ),
            content: "New comment",
            createdAt: Date(),
            likes: []
        )
        
        post.comments.append(newComment)
        
        XCTAssertEqual(post.comments.count, 1)
        XCTAssertEqual(post.comments.first?.content, "New comment")
    }
    
    // MARK: - Like Tests
    
    func testAddLikeToPost() {
        var post = createTestPost()
        XCTAssertTrue(post.likes.isEmpty)
        
        let userId = "user-123"
        post.likes.append(userId)
        
        XCTAssertEqual(post.likes.count, 1)
        XCTAssertTrue(post.likes.contains(userId))
    }
    
    func testRemoveLikeFromPost() {
        let userId = "user-123"
        var post = createTestPost(likes: [userId, "user-456"])
        
        XCTAssertEqual(post.likes.count, 2)
        
        post.likes.removeAll { $0 == userId }
        
        XCTAssertEqual(post.likes.count, 1)
        XCTAssertFalse(post.likes.contains(userId))
    }
    
    func testToggleLike() {
        var post = createTestPost()
        let userId = "user-123"
        
        // Add like
        if !post.likes.contains(userId) {
            post.likes.append(userId)
        }
        XCTAssertTrue(post.likes.contains(userId))
        
        // Remove like
        if let index = post.likes.firstIndex(of: userId) {
            post.likes.remove(at: index)
        }
        XCTAssertFalse(post.likes.contains(userId))
    }
    
    // MARK: - Visibility Tests
    
    func testAllVisibilityOptions() {
        for visibility in FeedVisibility.allCases {
            let post = createTestPost(visibility: visibility)
            XCTAssertEqual(post.visibility, visibility)
            XCTAssertFalse(visibility.icon.isEmpty)
            XCTAssertFalse(visibility.title.isEmpty)
        }
    }
    
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
    
    // MARK: - Tag and Mention Tests
    
    func testPostWithTags() {
        let post = FeedPost(
            id: "post-1",
            author: TestUserResponseFactory.createUser(),
            content: "Post about #swift and #ios development",
            images: [],
            attachments: [],
            createdAt: Date(),
            visibility: .everyone,
            likes: [],
            comments: [],
            tags: ["#swift", "#ios"],
            mentions: nil
        )
        
        XCTAssertEqual(post.tags?.count, 2)
        XCTAssertTrue(post.tags?.contains("#swift") ?? false)
        XCTAssertTrue(post.tags?.contains("#ios") ?? false)
    }
    
    func testPostWithMentions() {
        let post = FeedPost(
            id: "post-1",
            author: TestUserResponseFactory.createUser(),
            content: "Hey @john and @jane, check this out!",
            images: [],
            attachments: [],
            createdAt: Date(),
            visibility: .everyone,
            likes: [],
            comments: [],
            tags: nil,
            mentions: ["john", "jane"]
        )
        
        XCTAssertEqual(post.mentions?.count, 2)
        XCTAssertTrue(post.mentions?.contains("john") ?? false)
        XCTAssertTrue(post.mentions?.contains("jane") ?? false)
    }
    
    // MARK: - Codable Tests
    
    func testPostEncodingDecoding() throws {
        let originalPost = FeedPost(
            id: "post-1",
            author: TestUserResponseFactory.createAdmin(),
            content: "Test content",
            images: ["image1.jpg"],
            attachments: [],
            createdAt: Date(),
            visibility: .students,
            likes: ["user1", "user2"],
            comments: [],
            tags: ["#test"],
            mentions: ["user1"]
        )
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(originalPost)
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let decodedPost = try decoder.decode(FeedPost.self, from: data)
        
        XCTAssertEqual(originalPost.id, decodedPost.id)
        XCTAssertEqual(originalPost.author.id, decodedPost.author.id)
        XCTAssertEqual(originalPost.content, decodedPost.content)
        XCTAssertEqual(originalPost.images, decodedPost.images)
        XCTAssertEqual(originalPost.visibility, decodedPost.visibility)
        XCTAssertEqual(originalPost.likes, decodedPost.likes)
        XCTAssertEqual(originalPost.tags, decodedPost.tags)
        XCTAssertEqual(originalPost.mentions, decodedPost.mentions)
    }
    
    func testPostWithCommentsEncodingDecoding() throws {
        let comment = FeedComment(
            id: "comment-1",
            postId: "post-1",
            author: TestUserResponseFactory.createStudent(name: "Commenter"),
            content: "Nice post!",
            createdAt: Date(),
            likes: ["user1"]
        )
        
        let post = createTestPost(comments: [comment])
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(post)
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let decodedPost = try decoder.decode(FeedPost.self, from: data)
        
        XCTAssertEqual(post.comments.count, decodedPost.comments.count)
        XCTAssertEqual(post.comments.first?.content, decodedPost.comments.first?.content)
    }
    
    // MARK: - Equatable Tests
    
    func testPostEquality() {
        let author = TestUserResponseFactory.createUser(
            id: "author-1",
            name: "Author",
            role: .instructor
        )
        
        let post1 = FeedPost(
            id: "post-1",
            author: author,
            content: "Content 1",
            images: [],
            attachments: [],
            createdAt: Date(),
            visibility: .everyone,
            likes: [],
            comments: [],
            tags: nil,
            mentions: nil
        )
        
        let post2 = FeedPost(
            id: "post-1",
            author: author,
            content: "Content 2", // Different content
            images: ["image.jpg"], // Different images
            attachments: [],
            createdAt: Date().addingTimeInterval(100), // Different date
            visibility: .students, // Different visibility
            likes: ["user1"], // Different likes
            comments: [],
            tags: nil,
            mentions: nil
        )
        
        // Posts are equal if they have the same ID
        XCTAssertEqual(post1, post2)
    }
    
    func testPostInequality() {
        let post1 = createTestPost(id: "post-1")
        let post2 = createTestPost(id: "post-2")
        
        XCTAssertNotEqual(post1, post2)
    }
    
    // MARK: - Edge Cases
    
    func testEmptyPost() {
        let post = FeedPost(
            id: "empty-post",
            author: TestUserResponseFactory.createUser(),
            content: "",
            images: [],
            attachments: [],
            createdAt: Date(),
            visibility: .everyone,
            likes: [],
            comments: [],
            tags: [],
            mentions: []
        )
        
        XCTAssertTrue(post.content.isEmpty)
        XCTAssertTrue(post.images.isEmpty)
        XCTAssertTrue(post.attachments.isEmpty)
        XCTAssertTrue(post.likes.isEmpty)
        XCTAssertTrue(post.comments.isEmpty)
        XCTAssertTrue(post.tags?.isEmpty ?? true)
        XCTAssertTrue(post.mentions?.isEmpty ?? true)
    }
    
    func testPostWithLongContent() {
        let longContent = String(repeating: "Lorem ipsum ", count: 500)
        let post = createTestPost(content: longContent)
        
        XCTAssertEqual(post.content, longContent)
        XCTAssertGreaterThan(post.content.count, 5000)
    }
    
    func testPostWithManyLikes() {
        let likes = (0..<1000).map { "user-\($0)" }
        let post = createTestPost(likes: likes)
        
        XCTAssertEqual(post.likes.count, 1000)
    }
    
    func testPostWithManyComments() {
        let comments = (0..<100).map { i in
            FeedComment(
                id: "comment-\(i)",
                postId: "post-1",
                author: TestUserResponseFactory.createUser(
                    id: "user-\(i)",
                    name: "User \(i)",
                    role: .student
                ),
                content: "Comment \(i)",
                createdAt: Date(),
                likes: []
            )
        }
        
        let post = createTestPost(comments: comments)
        
        XCTAssertEqual(post.comments.count, 100)
    }
    
    // MARK: - Performance Tests
    
    func testPostCreationPerformance() {
        let author = TestUserResponseFactory.createUser(
            id: "perf-author",
            name: "Performance Author",
            role: .admin
        )
        
        measure {
            for i in 0..<1000 {
                _ = FeedPost(
                    id: "post-\(i)",
                    author: author,
                    content: "Performance test post \(i)",
                    images: [],
                    attachments: [],
                    createdAt: Date(),
                    visibility: .everyone,
                    likes: [],
                    comments: [],
                    tags: nil,
                    mentions: nil
                )
            }
        }
    }
} 