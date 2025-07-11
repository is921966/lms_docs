//
//  FeedService.swift
//  LMS
//
//  Сервис для управления лентой новостей
//

import SwiftUI

@MainActor
class FeedService: ObservableObject {
    static let shared = FeedService()
    
    // Use MockFeedService as the actual implementation for now
    private let mockService = MockFeedService.shared
    
    // MARK: - Properties
    
    var feedItems: [FeedItem] {
        // Convert FeedPost to FeedItem
        mockService.posts.map { post in
            FeedItem(
                type: .news,
                title: String(post.content.prefix(50)) + (post.content.count > 50 ? "..." : ""),
                content: post.content,
                author: post.author.name ?? "Unknown",
                publishedAt: post.createdAt,
                imageURL: post.images.first,
                tags: post.tags ?? [],
                priority: .normal,
                metadata: [
                    "postId": post.id,
                    "authorId": post.author.id
                ]
            )
        }
    }
    
    @Published var isLoading = false
    @Published var error: Error?
    
    // MARK: - Initialization
    
    private init() {}
    
    // MARK: - Public Methods
    
    /// Загрузить ленту новостей
    func loadFeed() async {
        isLoading = true
        error = nil
        
        // Use mock service
        mockService.refresh()
        
        isLoading = false
    }
    
    /// Обновить ленту (pull to refresh)
    func refreshFeed() async {
        await loadFeed()
    }
    
    /// Добавить новость в ленту
    func addNewsItem(_ item: FeedItem) async {
        // Convert FeedItem to FeedPost for MockFeedService
        _ = UserResponse(
            id: "system",
            email: "system@lms.com",
            name: item.author,
            role: .admin,
            isActive: true,
            createdAt: Date()
        )
        
        // Create content with title and body
        let content = """
        \(item.title)
        
        \(item.content)
        """
        
        // Add tags
        let tagsString = item.tags.map { "#\($0)" }.joined(separator: " ")
        let fullContent = content + "\n\n" + tagsString
        
        // Create post through mock service
        try? await mockService.createPost(
            content: fullContent,
            images: [],
            attachments: [],
            visibility: .everyone
        )
        
        // For release news, also update permissions to allow posting
        if item.metadata["type"] == "app_release" {
            mockService.permissions = FeedPermissions(
                canPost: true,
                canComment: true,
                canLike: true,
                canShare: true,
                canDelete: false,
                canEdit: false,
                canModerate: false,
                visibilityOptions: [.everyone]
            )
        }
    }
    
    /// Удалить элемент из ленты
    func removeFeedItem(_ item: FeedItem) {
        if let postId = item.metadata["postId"] {
            Task {
                try? await mockService.deletePost(postId)
            }
        }
    }
    
    /// Отметить элемент как прочитанный
    func markAsRead(_ item: FeedItem) {
        // This would be implemented with a real backend
        // For now, just log it
        print("Marked as read: \(item.id)")
    }
}

// MARK: - Feed Item Extension

extension FeedItem {
    /// Проверка, является ли новость о релизе
    var isReleaseNews: Bool {
        return tags.contains("release") || metadata["type"] == "app_release"
    }
    
    /// Получить иконку для типа новости
    var typeIcon: String {
        return type.icon
    }
    
    /// Получить цвет для приоритета
    var priorityColor: Color {
        switch priority {
        case .low:
            return .gray
        case .normal:
            return .blue
        case .high:
            return .orange
        case .urgent:
            return .red
        }
    }
}
