import Foundation
import Combine

class FeedService: ObservableObject {
    static let shared = FeedService()
    
    @Published var posts: [FeedPost] = []
    @Published var permissions: FeedPermissions = .studentDefault
    @Published var isLoading = false
    @Published var error: String?
    
    private var cancellables = Set<AnyCancellable>()
    
    private init() {
        setupPermissions()
        loadMockData()
    }
    
    private func setupPermissions() {
        // Listen to auth changes and update permissions
        MockAuthService.shared.$currentUser
            .sink { [weak self] user in
                guard let user = user else { return }
                self?.updatePermissions(for: user)
            }
            .store(in: &cancellables)
    }
    
    private func updatePermissions(for user: UserResponse) {
        // Check user roles
        if user.roles.contains("admin") || user.roles.contains("superAdmin") {
            permissions = .adminDefault
        } else {
            permissions = .studentDefault
        }
    }
    
    // MARK: - Feed Operations
    
    func refresh() {
        loadMockData()
    }
    
    func createPost(content: String, images: [String] = [], attachments: [FeedAttachment] = [], visibility: FeedVisibility = .everyone) async throws {
        guard permissions.canPost else {
            throw FeedError.noPermission
        }
        
        guard let currentUser = MockAuthService.shared.currentUser else {
            throw FeedError.notAuthenticated
        }
        
        // Determine role from user roles array
        let userRole: UserRole = currentUser.roles.contains("admin") ? .admin : .student
        
        let newPost = FeedPost(
            id: UUID().uuidString,
            authorId: currentUser.id,
            authorName: "\(currentUser.firstName) \(currentUser.lastName)",
            authorRole: userRole,
            authorAvatar: currentUser.avatar,
            content: content,
            images: images,
            attachments: attachments,
            createdAt: Date(),
            updatedAt: Date(),
            likes: [],
            comments: [],
            visibility: visibility,
            tags: extractTags(from: content),
            mentions: extractMentions(from: content)
        )
        
        await MainActor.run {
            self.posts.insert(newPost, at: 0)
        }
        
        // Send notifications for mentions
        for userId in newPost.mentions {
            await sendMentionNotification(to: userId, post: newPost)
        }
    }
    
    func deletePost(_ postId: String) async throws {
        guard let currentUser = MockAuthService.shared.currentUser else {
            throw FeedError.notAuthenticated
        }
        
        guard let postIndex = posts.firstIndex(where: { $0.id == postId }) else {
            throw FeedError.postNotFound
        }
        
        let post = posts[postIndex]
        
        // Check permissions
        guard permissions.canDelete || post.authorId == currentUser.id else {
            throw FeedError.noPermission
        }
        
        await MainActor.run {
            self.posts.remove(at: postIndex)
        }
    }
    
    func toggleLike(postId: String) async throws {
        guard permissions.canLike else {
            throw FeedError.noPermission
        }
        
        guard let currentUser = MockAuthService.shared.currentUser else {
            throw FeedError.notAuthenticated
        }
        
        guard let postIndex = posts.firstIndex(where: { $0.id == postId }) else {
            throw FeedError.postNotFound
        }
        
        await MainActor.run {
            if self.posts[postIndex].likes.contains(currentUser.id) {
                self.posts[postIndex].likes.removeAll { $0 == currentUser.id }
            } else {
                self.posts[postIndex].likes.append(currentUser.id)
                // Send notification
                Task {
                    await self.sendLikeNotification(post: self.posts[postIndex])
                }
            }
        }
    }
    
    func addComment(to postId: String, content: String) async throws {
        guard permissions.canComment else {
            throw FeedError.noPermission
        }
        
        guard let currentUser = MockAuthService.shared.currentUser else {
            throw FeedError.notAuthenticated
        }
        
        guard let postIndex = posts.firstIndex(where: { $0.id == postId }) else {
            throw FeedError.postNotFound
        }
        
        let newComment = FeedComment(
            id: UUID().uuidString,
            postId: postId,
            authorId: currentUser.id,
            authorName: "\(currentUser.firstName) \(currentUser.lastName)",
            authorAvatar: currentUser.avatar,
            content: content,
            createdAt: Date(),
            likes: []
        )
        
        await MainActor.run {
            self.posts[postIndex].comments.append(newComment)
        }
        
        // Send notification
        await sendCommentNotification(post: posts[postIndex], comment: newComment)
    }
    
    // MARK: - Helper Methods
    
    private func extractTags(from content: String) -> [String] {
        let pattern = "#\\w+"
        let regex = try? NSRegularExpression(pattern: pattern)
        let matches = regex?.matches(in: content, range: NSRange(content.startIndex..., in: content)) ?? []
        
        return matches.compactMap { match in
            guard let range = Range(match.range, in: content) else { return nil }
            return String(content[range])
        }
    }
    
    private func extractMentions(from content: String) -> [String] {
        // In real app, would parse @mentions and convert to user IDs
        []
    }
    
    private func sendMentionNotification(to userId: String, post: FeedPost) async {
        let notification = Notification(
            id: UUID().uuidString,
            type: .feedMention,
            title: "\(post.authorName) упомянул вас",
            message: String(post.content.prefix(100)),
            createdAt: Date(),
            isRead: false,
            priority: .medium,
            actionUrl: "feed://post/\(post.id)",
            metadata: ["postId": post.id]
        )
        
        // Add notification to the service
        await NotificationService.shared.add(notification)
    }
    
    private func sendLikeNotification(post: FeedPost) async {
        guard let currentUser = MockAuthService.shared.currentUser,
              currentUser.id != post.authorId else { return }
        
        let userName = "\(currentUser.firstName) \(currentUser.lastName)"
        let notification = Notification(
            id: UUID().uuidString,
            type: .feedActivity,
            title: "\(userName) понравилась ваша запись",
            message: String(post.content.prefix(100)),
            createdAt: Date(),
            isRead: false,
            priority: .low,
            actionUrl: "feed://post/\(post.id)",
            metadata: ["postId": post.id]
        )
        
        await NotificationService.shared.add(notification)
    }
    
    private func sendCommentNotification(post: FeedPost, comment: FeedComment) async {
        guard comment.authorId != post.authorId else { return }
        
        let notification = Notification(
            id: UUID().uuidString,
            type: .feedActivity,
            title: "\(comment.authorName) прокомментировал вашу запись",
            message: comment.content,
            createdAt: Date(),
            isRead: false,
            priority: .medium,
            actionUrl: "feed://post/\(post.id)",
            metadata: ["postId": post.id, "commentId": comment.id]
        )
        
        await NotificationService.shared.add(notification)
    }
    
    // MARK: - Mock Data
    
    private func loadMockData() {
        posts = [
            FeedPost(
                id: "1",
                authorId: "admin1",
                authorName: "Администратор системы",
                authorRole: .admin,
                authorAvatar: nil,
                content: "🎉 Добро пожаловать в корпоративный университет ЦУМ! Здесь вы найдете все необходимые курсы для вашего профессионального развития. #обучение #развитие",
                images: [],
                attachments: [],
                createdAt: Date().addingTimeInterval(-86400),
                updatedAt: Date().addingTimeInterval(-86400),
                likes: ["user1", "user2", "user3"],
                comments: [
                    FeedComment(
                        id: "c1",
                        postId: "1",
                        authorId: "user1",
                        authorName: "Иван Иванов",
                        authorAvatar: nil,
                        content: "Отличная платформа! Уже начал проходить курсы.",
                        createdAt: Date().addingTimeInterval(-3600),
                        likes: ["admin1"]
                    )
                ],
                visibility: .everyone,
                tags: ["#обучение", "#развитие"],
                mentions: []
            ),
            FeedPost(
                id: "2",
                authorId: "hr1",
                authorName: "HR отдел",
                authorRole: .admin,
                authorAvatar: nil,
                content: "📚 Новый курс 'Эффективная коммуникация' уже доступен! Курс поможет улучшить навыки общения с клиентами и коллегами. Записывайтесь!",
                images: [],
                attachments: [
                    FeedAttachment(
                        id: "a1",
                        type: .course,
                        url: "course://1",
                        name: "Эффективная коммуникация",
                        size: nil,
                        thumbnailUrl: nil
                    )
                ],
                createdAt: Date().addingTimeInterval(-7200),
                updatedAt: Date().addingTimeInterval(-7200),
                likes: ["user1", "user2", "user3", "user4", "user5"],
                comments: [],
                visibility: .everyone,
                tags: [],
                mentions: []
            ),
            FeedPost(
                id: "3",
                authorId: "user2",
                authorName: "Мария Петрова",
                authorRole: .student,
                authorAvatar: nil,
                content: "Только что завершила курс по работе с клиентами! Получила сертификат с отличием 🏆 Спасибо преподавателям за отличный материал!",
                images: [],
                attachments: [],
                createdAt: Date().addingTimeInterval(-10800),
                updatedAt: Date().addingTimeInterval(-10800),
                likes: ["admin1", "hr1", "user1", "user3"],
                comments: [
                    FeedComment(
                        id: "c2",
                        postId: "3",
                        authorId: "hr1",
                        authorName: "HR отдел",
                        authorAvatar: nil,
                        content: "Поздравляем! Так держать! 👏",
                        createdAt: Date().addingTimeInterval(-9000),
                        likes: ["user2"]
                    )
                ],
                visibility: .everyone,
                tags: [],
                mentions: []
            )
        ]
    }
}

// MARK: - Feed Errors
enum FeedError: LocalizedError {
    case noPermission
    case notAuthenticated
    case postNotFound
    case invalidContent
    
    var errorDescription: String? {
        switch self {
        case .noPermission:
            return "У вас нет прав для выполнения этого действия"
        case .notAuthenticated:
            return "Необходима авторизация"
        case .postNotFound:
            return "Запись не найдена"
        case .invalidContent:
            return "Недопустимое содержимое"
        }
    }
} 