//
//  MockFeedService.swift
//  LMS
//
//  Created by LMS Team on 13.01.2025.
//

import Foundation
import Combine

@MainActor
class MockFeedService: ObservableObject {
    
    @Published var posts: [FeedPost] = []
    @Published var isLoading = false
    @Published var error: FeedError?
    @Published var permissions = FeedPermissions(
        canPost: false,
        canComment: true,
        canLike: true,
        canShare: true,
        canDelete: false,
        canEdit: false,
        canModerate: false,
        visibilityOptions: []
    )
    
    private let authService = MockAuthService.shared
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupAuthObserver()
        loadMockData()
    }
    
    private func setupAuthObserver() {
        authService.$currentUser
            .sink { [weak self] user in
                self?.updatePermissions(for: user)
            }
            .store(in: &cancellables)
    }
    
    private func updatePermissions(for user: UserResponse?) {
        guard let user = user else {
            permissions = FeedPermissions(
                canPost: false,
                canComment: true,
                canLike: true,
                canShare: true,
                canDelete: false,
                canEdit: false,
                canModerate: false,
                visibilityOptions: []
            )
            return
        }
        
        switch user.role {
        case .student:
            permissions = FeedPermissions.studentDefault
        case .instructor:
            permissions = FeedPermissions.instructorDefault
        case .admin, .superAdmin:
            permissions = FeedPermissions.adminDefault
        case .manager:
            permissions = FeedPermissions.managerDefault
        }
    }
    
    private func loadMockData() {
        posts = [
            FeedPost(
                id: "1",
                author: UserResponse(
                    id: "admin-1",
                    email: "admin@test.com",
                    name: "Admin User",
                    role: .admin,
                    isActive: true,
                    createdAt: Date()
                ),
                content: "Welcome to our new LMS feed! #announcement",
                images: [],
                attachments: [],
                createdAt: Date().addingTimeInterval(-86400),
                visibility: .everyone,
                likes: ["user1", "user2", "user3"],
                comments: [
                    FeedComment(
                        id: "c1",
                        postId: "1",
                        author: UserResponse(
                            id: "student-1",
                            email: "student@test.com",
                            name: "Student User",
                            role: .student,
                            isActive: true,
                            createdAt: Date()
                        ),
                        content: "Great news!",
                        createdAt: Date().addingTimeInterval(-3600),
                        likes: ["user1"]
                    )
                ],
                tags: ["#announcement"],
                mentions: []
            ),
            FeedPost(
                id: "2",
                author: UserResponse(
                    id: "instructor-1",
                    email: "instructor@test.com",
                    name: "Instructor User",
                    role: .instructor,
                    isActive: true,
                    createdAt: Date()
                ),
                content: "New course materials available for iOS Development! Check them out @students",
                images: ["course_preview.jpg"],
                attachments: [
                    FeedAttachment(
                        id: "a1",
                        type: .course,
                        url: "course://ios-development",
                        name: "iOS Development Course",
                        size: nil,
                        thumbnailUrl: "ios_thumb.jpg"
                    )
                ],
                createdAt: Date().addingTimeInterval(-7200),
                visibility: .students,
                likes: ["user2", "user4"],
                comments: [],
                tags: ["#course", "#ios"],
                mentions: ["students"]
            )
        ]
    }
    
    // MARK: - Public Methods
    
    func createPost(
        content: String,
        images: [String] = [],
        attachments: [FeedAttachment] = [],
        visibility: FeedVisibility = .everyone
    ) async throws {
        guard let currentUser = authService.currentUser else {
            throw FeedError.noPermission
        }
        
        guard permissions.canPost else {
            throw FeedError.noPermission
        }
        
        let newPost = FeedPost(
            id: UUID().uuidString,
            author: currentUser,
            content: content,
            images: images,
            attachments: attachments,
            createdAt: Date(),
            visibility: visibility,
            likes: [],
            comments: [],
            tags: extractTags(from: content),
            mentions: extractMentions(from: content)
        )
        
        posts.insert(newPost, at: 0)
    }
    
    func deletePost(_ postId: String) async throws {
        guard let post = posts.first(where: { $0.id == postId }) else {
            throw FeedError.postNotFound
        }
        
        let canDelete = post.author.id == authService.currentUser?.id || permissions.canModerate
        
        guard canDelete else {
            throw FeedError.noPermission
        }
        
        posts.removeAll { $0.id == postId }
    }
    
    func toggleLike(postId: String) async throws {
        guard let currentUser = authService.currentUser else {
            throw FeedError.noPermission
        }
        
        guard permissions.canLike else {
            throw FeedError.noPermission
        }
        
        guard let index = posts.firstIndex(where: { $0.id == postId }) else {
            throw FeedError.postNotFound
        }
        
        var post = posts[index]
        
        if post.likes.contains(currentUser.id) {
            post.likes.removeAll { $0 == currentUser.id }
        } else {
            post.likes.append(currentUser.id)
        }
        
        posts[index] = post
    }
    
    func addComment(to postId: String, content: String) async throws {
        guard let currentUser = authService.currentUser else {
            throw FeedError.noPermission
        }
        
        guard permissions.canComment else {
            throw FeedError.noPermission
        }
        
        guard let index = posts.firstIndex(where: { $0.id == postId }) else {
            throw FeedError.postNotFound
        }
        
        let newComment = FeedComment(
            id: UUID().uuidString,
            postId: postId,
            author: currentUser,
            content: content,
            createdAt: Date(),
            likes: []
        )
        
        var post = posts[index]
        post.comments.append(newComment)
        posts[index] = post
    }
    
    func refresh() {
        loadMockData()
    }
    
    // MARK: - Helper Methods
    
    private func extractTags(from content: String) -> [String] {
        let pattern = "#[\\w\\u0400-\\u04FF]+"
        let regex = try? NSRegularExpression(pattern: pattern)
        let matches = regex?.matches(in: content, range: NSRange(content.startIndex..., in: content)) ?? []
        
        return matches.compactMap { match in
            guard let range = Range(match.range, in: content) else { return nil }
            return String(content[range])
        }
    }
    
    private func extractMentions(from content: String) -> [String] {
        let pattern = "@[\\w\\u0400-\\u04FF]+"
        let regex = try? NSRegularExpression(pattern: pattern)
        let matches = regex?.matches(in: content, range: NSRange(content.startIndex..., in: content)) ?? []
        
        return matches.compactMap { match in
            guard let range = Range(match.range, in: content) else { return nil }
            let mention = String(content[range])
            return String(mention.dropFirst()) // Remove @
        }
    }
    
    // MARK: - Test Helpers
    
    func reset() {
        posts.removeAll()
        error = nil
        isLoading = false
        loadMockData()
    }
    
    func setError(_ error: FeedError) {
        self.error = error
    }
    
    func setLoading(_ loading: Bool) {
        self.isLoading = loading
    }
} 