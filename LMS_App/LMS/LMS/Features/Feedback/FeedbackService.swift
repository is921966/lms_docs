import Foundation
import SwiftUI

/// Сервис для управления фидбэками
@MainActor
class FeedbackService: ObservableObject {
    static let shared = FeedbackService()
    
    @Published var feedbacks: [FeedbackItem] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let mockData = true // Для демонстрации
    
    private init() {}
    
    // MARK: - Public Methods
    
    /// Загружает все фидбэки
    func loadFeedbacks() async {
        isLoading = true
        defer { isLoading = false }
        
        if mockData {
            // Симуляция загрузки
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            feedbacks = createMockFeedbacks()
        } else {
            // TODO: Загрузка с сервера
            await loadFeedbacksFromServer()
        }
    }
    
    /// Обновляет ленту фидбэков
    func refreshFeedbacks() async {
        await loadFeedbacks()
    }
    
    /// Создает новый фидбэк
    func createFeedback(_ feedback: FeedbackModel) async -> Bool {
        isLoading = true
        defer { isLoading = false }
        
        if mockData {
            // Симуляция создания
            try? await Task.sleep(nanoseconds: 500_000_000)
            
            let newFeedbackItem = FeedbackItem(
                title: "\(feedback.type.capitalized) Report",
                description: feedback.text,
                type: FeedbackType(rawValue: feedback.type) ?? .question,
                author: "Текущий пользователь",
                authorId: "current_user",
                isOwnFeedback: true
            )
            
            feedbacks.insert(newFeedbackItem, at: 0)
            
            // 🚀 НОВОЕ: Автоматически создаем GitHub Issue
            Task.detached {
                let success = await GitHubFeedbackService.shared.createIssueFromFeedback(newFeedbackItem)
                if success {
                    print("✅ Фидбэк успешно залогирован в GitHub Issues")
                } else {
                    print("⚠️ Не удалось создать GitHub Issue (возможно, не настроен токен)")
                }
            }
            
            return true
        } else {
            // TODO: Отправка на сервер
            return await createFeedbackOnServer(feedback)
        }
    }
    
    /// Добавляет реакцию к фидбэку
    func addReaction(to feedbackId: UUID, reaction: ReactionType) {
        guard let index = feedbacks.firstIndex(where: { $0.id == feedbackId }) else { return }
        
        var feedback = feedbacks[index]
        var reactions = feedback.reactions
        
        // Убираем предыдущую реакцию пользователя
        if let currentReaction = feedback.userReaction {
            switch currentReaction {
            case .like: reactions.like = max(0, reactions.like - 1)
            case .dislike: reactions.dislike = max(0, reactions.dislike - 1)
            case .heart: reactions.heart = max(0, reactions.heart - 1)
            case .fire: reactions.fire = max(0, reactions.fire - 1)
            }
        }
        
        // Добавляем новую реакцию или убираем, если повторно нажали
        let newUserReaction: ReactionType?
        if feedback.userReaction == reaction {
            newUserReaction = nil
        } else {
            newUserReaction = reaction
            switch reaction {
            case .like: reactions.like += 1
            case .dislike: reactions.dislike += 1
            case .heart: reactions.heart += 1
            case .fire: reactions.fire += 1
            }
        }
        
        // Обновляем фидбэк
        feedbacks[index] = FeedbackItem(
            id: feedback.id,
            title: feedback.title,
            description: feedback.description,
            type: feedback.type,
            status: feedback.status,
            author: feedback.author,
            authorId: feedback.authorId,
            createdAt: feedback.createdAt,
            updatedAt: Date(),
            screenshot: feedback.screenshot,
            reactions: reactions,
            comments: feedback.comments,
            userReaction: newUserReaction,
            isOwnFeedback: feedback.isOwnFeedback
        )
        
        // TODO: Отправить изменение на сервер
        Task {
            await updateReactionOnServer(feedbackId: feedbackId, reaction: newUserReaction)
        }
    }
    
    /// Добавляет комментарий к фидбэку
    func addComment(to feedbackId: UUID, comment: String) {
        guard let index = feedbacks.firstIndex(where: { $0.id == feedbackId }) else { return }
        guard !comment.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        var feedback = feedbacks[index]
        let newComment = FeedbackComment(
            text: comment.trimmingCharacters(in: .whitespacesAndNewlines),
            author: "Текущий пользователь",
            authorId: "current_user"
        )
        
        var updatedComments = feedback.comments
        updatedComments.append(newComment)
        
        // Обновляем фидбэк
        feedbacks[index] = FeedbackItem(
            id: feedback.id,
            title: feedback.title,
            description: feedback.description,
            type: feedback.type,
            status: feedback.status,
            author: feedback.author,
            authorId: feedback.authorId,
            createdAt: feedback.createdAt,
            updatedAt: Date(),
            screenshot: feedback.screenshot,
            reactions: feedback.reactions,
            comments: updatedComments,
            userReaction: feedback.userReaction,
            isOwnFeedback: feedback.isOwnFeedback
        )
        
        // TODO: Отправить комментарий на сервер
        Task {
            await addCommentOnServer(feedbackId: feedbackId, comment: newComment)
        }
    }
    
    // MARK: - Private Methods
    
    private func createMockFeedbacks() -> [FeedbackItem] {
        return [
            FeedbackItem(
                title: "Ошибка при загрузке курсов",
                description: "При попытке открыть раздел Курсы приложение зависает на экране загрузки более 30 секунд.",
                type: .bug,
                status: .inProgress,
                author: "Иван Петров",
                authorId: "user1",
                createdAt: Date().addingTimeInterval(-3600),
                reactions: FeedbackReactions(like: 5, dislike: 1, heart: 2, fire: 0),
                comments: [
                    FeedbackComment(
                        text: "Та же проблема! Очень неудобно.",
                        author: "Мария Сидорова",
                        authorId: "user2",
                        createdAt: Date().addingTimeInterval(-1800)
                    ),
                    FeedbackComment(
                        text: "Мы работаем над исправлением. Ожидайте обновления в ближайшие дни.",
                        author: "Техподдержка",
                        authorId: "admin1",
                        createdAt: Date().addingTimeInterval(-900),
                        isAdmin: true
                    )
                ],
                userReaction: .like
            ),
            FeedbackItem(
                title: "Добавить темную тему",
                description: "Было бы здорово иметь возможность переключиться на темную тему, особенно для работы в вечернее время.",
                type: .feature,
                status: .open,
                author: "Анна Козлова",
                authorId: "user3",
                createdAt: Date().addingTimeInterval(-7200),
                reactions: FeedbackReactions(like: 12, dislike: 0, heart: 8, fire: 3),
                comments: [
                    FeedbackComment(
                        text: "Полностью поддерживаю! Глаза устают от белого фона.",
                        author: "Дмитрий Волков",
                        authorId: "user4",
                        createdAt: Date().addingTimeInterval(-3600)
                    )
                ],
                userReaction: .heart
            )
        ]
    }
    
    private func loadFeedbacksFromServer() async {
        // TODO: Реализовать загрузку с сервера
    }
    
    private func createFeedbackOnServer(_ feedback: FeedbackModel) async -> Bool {
        // TODO: Реализовать отправку на сервер
        return false
    }
    
    private func updateReactionOnServer(feedbackId: UUID, reaction: ReactionType?) async {
        // TODO: Реализовать обновление реакции на сервере
    }
    
    private func addCommentOnServer(feedbackId: UUID, comment: FeedbackComment) async {
        // TODO: Реализовать добавление комментария на сервере
    }
}
