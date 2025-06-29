import Foundation
import SwiftUI

/// Сервис для управления фидбэками
@MainActor
class FeedbackService: ObservableObject {
    static let shared = FeedbackService()
    
    @Published var feedbacks: [FeedbackItem] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // ⚡ НОВОЕ: Offline queue для надежности
    @Published var pendingFeedbacks: [FeedbackItem] = []
    @Published var networkStatus: NetworkStatus = .unknown
    
    private let mockData = true // Для демонстрации
    
    // 📊 НОВОЕ: Метрики производительности
    struct PerformanceMetrics {
        var averageGitHubCreateTime: TimeInterval = 0
        var successRate: Double = 0
        var totalFeedbacksCreated: Int = 0
        var lastSyncTime: Date?
    }
    
    @Published var performanceMetrics = PerformanceMetrics()
    
    private init() {
        startNetworkMonitoring()
        startOfflineQueueProcessor()
    }
    
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
    
    /// Создает новый фидбэк с offline support
    func createFeedback(_ feedback: FeedbackModel) async -> Bool {
        isLoading = true
        defer { isLoading = false }
        
        // Конвертируем base64 скриншот обратно в строку для хранения
        let screenshotString = feedback.screenshot
        
        let newFeedbackItem = FeedbackItem(
            title: "\(feedback.type.capitalized) Report",
            description: feedback.text,
            type: FeedbackType(rawValue: feedback.type) ?? .question,
            author: "Текущий пользователь",
            authorId: "current_user",
            screenshot: screenshotString,  // Передаем скриншот
            isOwnFeedback: true
        )
        
        // ✅ 1. Мгновенно добавляем в UI (< 0.5 сек)
        feedbacks.insert(newFeedbackItem, at: 0)
        
        if mockData {
            // Симуляция создания
            try? await Task.sleep(nanoseconds: 500_000_000)
            
            // ✅ 2. Пытаемся отправить в GitHub (асинхронно)
            await processGitHubIntegration(newFeedbackItem)
            
            return true
        } else {
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
    
    // ⚡ НОВОЕ: Обработка GitHub интеграции через сервер с метриками
    private func processGitHubIntegration(_ feedback: FeedbackItem) async {
        let startTime = Date()
        
        if networkStatus == .connected {
            // ✅ Есть сеть - отправляем на сервер
            let success = await ServerFeedbackService.shared.sendFeedbackItem(feedback)
            let duration = Date().timeIntervalSince(startTime)
            
            await updatePerformanceMetrics(duration: duration, success: success)
            
            if success {
                print("✅ Фидбэк отправлен на сервер (\(String(format: "%.2f", duration))с)")
                print("📝 Сервер автоматически создаст GitHub Issue")
            } else {
                print("⚠️ Не удалось отправить - добавляем в offline queue")
                addToOfflineQueue(feedback)
            }
        } else {
            // ❌ Нет сети - добавляем в offline queue
            print("📴 Нет сети - фидбэк сохранен в offline queue")
            addToOfflineQueue(feedback)
        }
    }
    
    // ⚡ НОВОЕ: Offline queue management
    private func addToOfflineQueue(_ feedback: FeedbackItem) {
        if !pendingFeedbacks.contains(where: { $0.id == feedback.id }) {
            pendingFeedbacks.append(feedback)
            print("📦 Добавлен в offline queue (\(pendingFeedbacks.count) ожидают)")
        }
    }
    
    private func startOfflineQueueProcessor() {
        Task {
            while true {
                if networkStatus == .connected && !pendingFeedbacks.isEmpty {
                    await processOfflineQueue()
                }
                try? await Task.sleep(nanoseconds: 30_000_000_000) // Проверяем каждые 30 секунд
            }
        }
    }
    
    private func processOfflineQueue() async {
        print("🔄 Обрабатываем offline queue (\(pendingFeedbacks.count) элементов)")
        
        var processedItems: [UUID] = []
        
        for feedback in pendingFeedbacks {
            let success = await ServerFeedbackService.shared.sendFeedbackItem(feedback)
            if success {
                processedItems.append(feedback.id)
                print("✅ Offline фидбэк отправлен на сервер: \(feedback.title)")
            }
        }
        
        // Удаляем обработанные элементы
        pendingFeedbacks.removeAll { processedItems.contains($0.id) }
        
        if !processedItems.isEmpty {
            print("🎉 Обработано \(processedItems.count) offline фидбэков")
        }
    }
    
    // 📊 НОВОЕ: Метрики производительности
    private func updatePerformanceMetrics(duration: TimeInterval, success: Bool) async {
        let currentMetrics = performanceMetrics
        
        performanceMetrics = PerformanceMetrics(
            averageGitHubCreateTime: calculateAverageTime(current: currentMetrics.averageGitHubCreateTime, 
                                                         new: duration, 
                                                         count: currentMetrics.totalFeedbacksCreated),
            successRate: calculateSuccessRate(currentRate: currentMetrics.successRate, 
                                            newSuccess: success, 
                                            total: currentMetrics.totalFeedbacksCreated),
            totalFeedbacksCreated: currentMetrics.totalFeedbacksCreated + 1,
            lastSyncTime: Date()
        )
        
        // Логируем текущие метрики
        print("""
        📊 Feedback Performance Update:
        - Average GitHub time: \(String(format: "%.2f", performanceMetrics.averageGitHubCreateTime))s
        - Success rate: \(String(format: "%.1f", performanceMetrics.successRate * 100))%
        - Total created: \(performanceMetrics.totalFeedbacksCreated)
        - Pending: \(pendingFeedbacks.count)
        """)
    }
    
    private func calculateAverageTime(current: TimeInterval, new: TimeInterval, count: Int) -> TimeInterval {
        if count == 0 { return new }
        return (current * Double(count) + new) / Double(count + 1)
    }
    
    private func calculateSuccessRate(currentRate: Double, newSuccess: Bool, total: Int) -> Double {
        let currentSuccesses = currentRate * Double(total)
        let newSuccesses = currentSuccesses + (newSuccess ? 1 : 0)
        return newSuccesses / Double(total + 1)
    }
    
    // ⚡ НОВОЕ: Мониторинг сети
    private func startNetworkMonitoring() {
        // Упрощенная проверка сети
        Task {
            while true {
                await checkNetworkStatus()
                try? await Task.sleep(nanoseconds: 10_000_000_000) // Проверяем каждые 10 секунд
            }
        }
    }
    
    private func checkNetworkStatus() async {
        // Простая проверка доступности GitHub API
        guard let url = URL(string: "https://api.github.com") else { return }
        
        do {
            let (_, response) = try await URLSession.shared.data(from: url)
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                networkStatus = .connected
            } else {
                networkStatus = .disconnected
            }
        } catch {
            networkStatus = .disconnected
        }
    }
}

// ⚡ НОВОЕ: Network status enum
enum NetworkStatus {
    case connected
    case disconnected
    case unknown
    
    var emoji: String {
        switch self {
        case .connected: return "🟢"
        case .disconnected: return "🔴"
        case .unknown: return "🟡"
        }
    }
    
    var description: String {
        switch self {
        case .connected: return "Connected"
        case .disconnected: return "Offline"
        case .unknown: return "Unknown"
        }
    }
}
