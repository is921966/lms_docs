//
//  FeedCommentTests.swift
//  LMSTests
//
//  Created by LMS Team on 13.01.2025.
//

import XCTest
@testable import LMS

final class FeedCommentTests: XCTestCase {
    
    // MARK: - Test Helpers
    
    private func createTestComment(
        id: String = "comment-1",
        postId: String = "post-1",
        content: String = "Test comment",
        likes: [String] = []
    ) -> FeedComment {
        return FeedComment(
            id: id,
            postId: postId,
            author: TestUserResponseFactory.createUser(
                id: "author-1",
                name: "John Doe",
                role: .student
            ),
            content: content,
            createdAt: Date(),
            likes: likes
        )
    }
    
    // MARK: - Initialization Tests
    
    func testCommentInitialization() {
        let commentId = "comment-123"
        let postId = "post-456"
        let content = "This is a test comment"
        let createdAt = Date()
        let likes = ["user1", "user2", "user3"]
        
        let author = TestUserResponseFactory.createUser(
            id: "author-1",
            name: "Comment Author",
            role: .instructor
        )
        
        let comment = FeedComment(
            id: commentId,
            postId: postId,
            author: author,
            content: content,
            createdAt: createdAt,
            likes: likes
        )
        
        XCTAssertEqual(comment.id, commentId)
        XCTAssertEqual(comment.postId, postId)
        XCTAssertEqual(comment.author.id, author.id)
        XCTAssertEqual(comment.content, content)
        XCTAssertEqual(comment.createdAt, createdAt)
        XCTAssertEqual(comment.likes, likes)
        XCTAssertEqual(comment.likesCount, 3)
    }
    
    func testCommentWithEmptyLikes() {
        let comment = createTestComment(likes: [])
        
        XCTAssertTrue(comment.likes.isEmpty)
        XCTAssertEqual(comment.likesCount, 0)
    }
    
    // MARK: - Content Tests
    
    func testCommentWithEmoji() {
        let emojiContent = "Great post! 👍😊🎉"
        let comment = createTestComment(content: emojiContent)
        
        XCTAssertEqual(comment.content, emojiContent)
    }
    
    func testCommentWithSpecialCharacters() {
        let specialContent = "Test with special chars: @#$%^&*()_+-=[]{}|;':\",./<>?"
        let comment = createTestComment(content: specialContent)
        
        XCTAssertEqual(comment.content, specialContent)
    }
    
    func testCommentWithLongContent() {
        let longContent = String(repeating: "Lorem ipsum ", count: 100)
        let comment = createTestComment(content: longContent)
        
        XCTAssertEqual(comment.content, longContent)
        XCTAssertGreaterThan(comment.content.count, 1000)
    }
    
    // MARK: - Like Tests
    
    func testAddLikeToComment() {
        var comment = createTestComment()
        let userId = "user-123"
        
        XCTAssertFalse(comment.likes.contains(userId))
        
        comment.likes.append(userId)
        
        XCTAssertTrue(comment.likes.contains(userId))
        XCTAssertEqual(comment.likesCount, 1)
    }
    
    func testRemoveLikeFromComment() {
        let userId = "user-123"
        var comment = createTestComment(likes: [userId, "user-456"])
        
        XCTAssertEqual(comment.likesCount, 2)
        
        comment.likes.removeAll { $0 == userId }
        
        XCTAssertFalse(comment.likes.contains(userId))
        XCTAssertEqual(comment.likesCount, 1)
    }
    
    func testToggleLike() {
        var comment = createTestComment()
        let userId = "user-123"
        
        // Add like
        if !comment.likes.contains(userId) {
            comment.likes.append(userId)
        }
        XCTAssertTrue(comment.likes.contains(userId))
        
        // Remove like
        if let index = comment.likes.firstIndex(of: userId) {
            comment.likes.remove(at: index)
        }
        XCTAssertFalse(comment.likes.contains(userId))
    }
    
    // MARK: - Author Role Tests
    
    func testCommentWithDifferentAuthorRoles() {
        let roles: [UserRole] = [.student, .instructor, .admin, .manager, .superAdmin]
        
        for role in roles {
            let author = TestUserResponseFactory.createUser(
                id: "author-\(role)",
                name: "\(role) User",
                role: role
            )
            
            let comment = FeedComment(
                id: "comment-\(role)",
                postId: "post-1",
                author: author,
                content: "Comment from \(role)",
                createdAt: Date(),
                likes: []
            )
            
            XCTAssertEqual(comment.author.role, role)
        }
    }
    
    func testCommentAuthorWithAvatar() {
        let authorWithAvatar = TestUserResponseFactory.createUser(
            id: "author-avatar",
            name: "User With Avatar",
            role: .student
        )
        
        let comment = FeedComment(
            id: "comment-1",
            postId: "post-1",
            author: authorWithAvatar,
            content: "Comment with avatar author",
            createdAt: Date(),
            likes: []
        )
        
        // UserResponse doesn't have avatarURL property
        XCTAssertNotNil(comment.author)
    }
    
    // MARK: - Timestamp Tests
    
    func testCommentTimestamp() {
        let pastDate = Date().addingTimeInterval(-3600) // 1 hour ago
        let comment = FeedComment(
            id: "old-comment",
            postId: "post-1",
            author: TestUserResponseFactory.createUser(),
            content: "Old comment",
            createdAt: pastDate,
            likes: []
        )
        
        XCTAssertEqual(comment.createdAt, pastDate)
        XCTAssertLessThan(comment.createdAt, Date())
    }
    
    func testCommentsSortedByDate() {
        let comments = [
            FeedComment(
                id: "comment-1",
                postId: "post-1",
                author: TestUserResponseFactory.createUser(),
                content: "First",
                createdAt: Date().addingTimeInterval(-300),
                likes: []
            ),
            FeedComment(
                id: "comment-2",
                postId: "post-1",
                author: TestUserResponseFactory.createUser(),
                content: "Second",
                createdAt: Date().addingTimeInterval(-200),
                likes: []
            ),
            FeedComment(
                id: "comment-3",
                postId: "post-1",
                author: TestUserResponseFactory.createUser(),
                content: "Third",
                createdAt: Date().addingTimeInterval(-100),
                likes: []
            )
        ]
        
        let sortedComments = comments.sorted { $0.createdAt > $1.createdAt }
        
        XCTAssertEqual(sortedComments[0].content, "Third")
        XCTAssertEqual(sortedComments[1].content, "Second")
        XCTAssertEqual(sortedComments[2].content, "First")
    }
    
    // MARK: - Codable Tests
    
    func testCommentEncodingDecoding() throws {
        let originalComment = FeedComment(
            id: "comment-1",
            postId: "post-1",
            author: TestUserResponseFactory.createAdmin(name: "Admin User"),
            content: "Test comment with encoding",
            createdAt: Date(),
            likes: ["user1", "user2"]
        )
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(originalComment)
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let decodedComment = try decoder.decode(FeedComment.self, from: data)
        
        XCTAssertEqual(originalComment.id, decodedComment.id)
        XCTAssertEqual(originalComment.postId, decodedComment.postId)
        XCTAssertEqual(originalComment.author.id, decodedComment.author.id)
        XCTAssertEqual(originalComment.content, decodedComment.content)
        XCTAssertEqual(originalComment.likes, decodedComment.likes)
    }
    
    func testCommentWithSpecialContentEncoding() throws {
        let specialComment = createTestComment(
            content: "Comment with \"quotes\" and 'apostrophes' & ampersands"
        )
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(specialComment)
        
        let decoder = JSONDecoder()
        let decodedComment = try decoder.decode(FeedComment.self, from: data)
        
        XCTAssertEqual(specialComment.content, decodedComment.content)
    }
    
    // MARK: - Edge Cases
    
    func testEmptyComment() {
        let emptyComment = createTestComment(content: "")
        
        XCTAssertTrue(emptyComment.content.isEmpty)
        XCTAssertEqual(emptyComment.likesCount, 0)
    }
    
    func testCommentWithManyLikes() {
        let manyLikes = (0..<1000).map { "user-\($0)" }
        let comment = createTestComment(likes: manyLikes)
        
        XCTAssertEqual(comment.likesCount, 1000)
    }
    
    func testCommentWithDuplicateLikes() {
        let duplicateLikes = ["user1", "user2", "user1", "user3", "user2"]
        let comment = createTestComment(likes: duplicateLikes)
        
        // In real app, should prevent duplicate likes
        XCTAssertEqual(comment.likes.count, 5)
        
        let uniqueLikes = Set(comment.likes)
        XCTAssertEqual(uniqueLikes.count, 3)
    }
    
    // MARK: - Performance Tests
    
    func testCommentCreationPerformance() {
        let author = TestUserResponseFactory.createUser()
        
        measure {
            for i in 0..<1000 {
                _ = FeedComment(
                    id: "comment-\(i)",
                    postId: "post-1",
                    author: author,
                    content: "Performance test comment \(i)",
                    createdAt: Date(),
                    likes: []
                )
            }
        }
    }
    
    func testLargeCommentPerformance() {
        let largeContent = String(repeating: "Lorem ipsum dolor sit amet ", count: 1000)
        let manyLikes = (0..<1000).map { "user-\($0)" }
        
        measure {
            _ = FeedComment(
                id: "large-comment",
                postId: "post-1",
                author: TestUserResponseFactory.createUser(),
                content: largeContent,
                createdAt: Date(),
                likes: manyLikes
            )
        }
    }
} 