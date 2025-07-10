import Combine
import Foundation

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
        Task { @MainActor in
            MockAuthService.shared.$currentUser
                .sink { [weak self] user in
                    guard let user = user else {
                        self?.permissions = .studentDefault
                        return
                    }
                    self?.updatePermissions(for: user)
                }
                .store(in: &cancellables)
        }
    }

    private func updatePermissions(for user: UserResponse) {
        if user.role == .admin || user.role == .superAdmin {
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

        guard let currentUser = await MockAuthService.shared.currentUser else {
            throw FeedError.notAuthenticated
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

        await MainActor.run {
            self.posts.insert(newPost, at: 0)
        }
        
        // Mentions are not implemented yet in this mock service
    }

    func deletePost(_ postId: String) async throws {
        guard let currentUser = await MockAuthService.shared.currentUser else {
            throw FeedError.notAuthenticated
        }

        guard let postIndex = posts.firstIndex(where: { $0.id == postId }) else {
            throw FeedError.postNotFound
        }

        let post = posts[postIndex]

        guard permissions.canDelete || post.author.id == currentUser.id else {
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

        guard let currentUser = await MockAuthService.shared.currentUser else {
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

        guard let currentUser = await MockAuthService.shared.currentUser else {
            throw FeedError.notAuthenticated
        }

        guard let postIndex = posts.firstIndex(where: { $0.id == postId }) else {
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

        await MainActor.run {
            self.posts[postIndex].comments.append(newComment)
        }

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
        let pattern = "@\\w+"
        let regex = try? NSRegularExpression(pattern: pattern)
        let matches = regex?.matches(in: content, range: NSRange(content.startIndex..., in: content)) ?? []

        return matches.compactMap { match in
            guard let range = Range(match.range, in: content) else { return nil }
            let mention = String(content[range])
            // Remove @ symbol and return just the username
            return String(mention.dropFirst())
        }
    }

    private func sendMentionNotification(to userId: String, post: FeedPost) async {
        print("Mention notification would be sent to user \(userId) for post by \(post.author.name)")
    }

    private func sendLikeNotification(post: FeedPost) async {
        guard let currentUser = await MockAuthService.shared.currentUser,
              currentUser.id != post.author.id else { return }
        print("Like notification would be sent for post by \(post.author.name)")
    }

    private func sendCommentNotification(post: FeedPost, comment: FeedComment) async {
        guard comment.author.id != post.author.id else { return }
        print("Comment notification would be sent for post by \(post.author.name)")
    }

    // MARK: - Mock Data

    private func loadMockData() {
        let adminUser = UserResponse(id: "admin1", email: "admin@tsum.ru", name: "Администратор", role: .admin)
        let hrUser = UserResponse(id: "hr1", email: "hr@tsum.ru", name: "HR Отдел", role: .manager)
        let user1 = UserResponse(id: "user1", email: "ivanov@tsum.ru", name: "Иван Иванов", role: .student)
        let user2 = UserResponse(id: "user2", email: "petrova@tsum.ru", name: "Мария Петрова", role: .student)

        self.posts = [
            FeedPost(
                id: "1",
                author: adminUser,
                content: "🎉 Добро пожаловать в корпоративный университет ЦУМ! Здесь вы найдете все необходимые курсы для вашего профессионального развития. #обучение #развитие",
                images: [],
                attachments: [],
                createdAt: Date().addingTimeInterval(-86_400),
                visibility: .everyone,
                likes: [user1.id, user2.id],
                comments: [
                    FeedComment(
                        id: "c1",
                        postId: "1",
                        author: user1,
                        content: "Отличная платформа! Уже начал проходить курсы.",
                        createdAt: Date().addingTimeInterval(-3_600),
                        likes: [adminUser.id]
                    )
                ],
                tags: ["#обучение", "#развитие"]
            ),
            FeedPost(
                id: "2",
                author: hrUser,
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
                createdAt: Date().addingTimeInterval(-7_200),
                visibility: .everyone,
                likes: [user1.id, user2.id, adminUser.id],
                comments: [],
                tags: []
            ),
            FeedPost(
                id: "3",
                author: user2,
                content: "Только что завершила курс по работе с клиентами! Получила сертификат с отличием 🏆 Спасибо преподавателям за отличный материал!",
                images: [],
                attachments: [],
                createdAt: Date().addingTimeInterval(-10_800),
                visibility: .everyone,
                likes: [adminUser.id, hrUser.id, user1.id],
                comments: [
                    FeedComment(
                        id: "c2",
                        postId: "3",
                        author: hrUser,
                        content: "Поздравляем! Так держать! 👏",
                        createdAt: Date().addingTimeInterval(-9_000),
                        likes: [user2.id]
                    )
                ],
                tags: []
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
