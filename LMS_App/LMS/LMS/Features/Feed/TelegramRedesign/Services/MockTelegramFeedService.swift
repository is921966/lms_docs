import Foundation
import Combine
import SwiftUI

/// Mock implementation of TelegramFeedServiceProtocol for development
class MockTelegramFeedService: TelegramFeedServiceProtocol {
    static let shared = MockTelegramFeedService()
    
    private var channels: [FeedChannel] = []
    private let updateSubject = PassthroughSubject<FeedChannel, Never>()
    
    private init() {
        setupMockData()
        ComprehensiveLogger.shared.log(.data, .info, "MockTelegramFeedService initialized", details: [
            "channelsCount": channels.count
        ])
    }
    
    // Helper для создания FeedMessage
    private func createMessage(_ text: String, timestamp: Date, author: String = "System", isRead: Bool = false) -> FeedMessage {
        FeedMessage(
            id: UUID(),
            text: text,
            timestamp: timestamp,
            author: author,
            isRead: isRead
        )
    }
    
    func loadChannels() async throws -> [FeedChannel] {
        ComprehensiveLogger.shared.log(.network, .info, "Loading channels started", details: [
            "currentCount": channels.count,
            "isAsync": true
        ])
        
        // Симуляция задержки сети
        try await Task.sleep(nanoseconds: 500_000_000)
        
        ComprehensiveLogger.shared.log(.network, .info, "Channels loaded successfully", details: [
            "count": channels.count,
            "categories": Set(channels.map { $0.category.rawValue }).joined(separator: ", "),
            "pinnedCount": channels.filter { $0.isPinned }.count,
            "unreadTotal": channels.reduce(0) { $0 + $1.unreadCount }
        ])
        
        // Log each channel for debugging
        for (index, channel) in channels.enumerated() {
            ComprehensiveLogger.shared.log(.data, .debug, "Channel \(index)", details: [
                "name": channel.name,
                "category": channel.category.rawValue,
                "unreadCount": channel.unreadCount,
                "isPinned": channel.isPinned,
                "lastMessagePreview": String(channel.lastMessage.text.prefix(50))
            ])
        }
        
        return channels
    }
    
    func markAsRead(channelId: UUID) async throws {
        if let index = channels.firstIndex(where: { $0.id == channelId }) {
            channels[index].unreadCount = 0
            channels[index].lastMessage.isRead = true
        }
    }
    
    func updateNotificationSettings(channelId: UUID, enabled: Bool) async throws {
        // Simulate update
        try await Task.sleep(nanoseconds: 200_000_000)
    }
    
    func getUpdatesPublisher() -> AnyPublisher<FeedChannel, Never> {
        updateSubject.eraseToAnyPublisher()
    }
    
    private func setupMockData() {
        let now = Date()
        
        channels = [
            // Критичные каналы
            FeedChannel(
                id: UUID(),
                name: "🚨 Важные объявления",
                avatarType: .icon("exclamationmark.triangle.fill", .red),
                lastMessage: createMessage(
                    "Обновление политики безопасности: обязательно к ознакомлению",
                    timestamp: now.addingTimeInterval(-300),
                    author: "Security Team"
                ),
                unreadCount: 1,
                category: .announcement,
                priority: .critical,
                isPinned: true
            ),
            
            // Обучение
            FeedChannel(
                id: UUID(),
                name: "📚 Академия ЦУМ",
                avatarType: .icon("book.fill", .blue),
                lastMessage: createMessage(
                    "Новый курс: 'Основы проектного менеджмента' доступен для записи",
                    timestamp: now.addingTimeInterval(-3600),
                    author: "Learning Team"
                ),
                unreadCount: 3,
                category: .learning,
                priority: .high
            ),
            
            FeedChannel(
                id: UUID(), 
                name: "🎯 Обязательное обучение",
                avatarType: .icon("target", .orange),
                lastMessage: createMessage(
                    "Напоминание: осталось 5 дней до дедлайна по курсу 'Compliance 2024'",
                    timestamp: now.addingTimeInterval(-7200),
                    author: "Learning Platform"
                ),
                unreadCount: 1,
                category: .learning,
                priority: .critical
            ),
            
            // События
            FeedChannel(
                id: UUID(),
                name: "🎉 События компании",
                avatarType: .icon("party.popper.fill", .purple),
                lastMessage: createMessage(
                    "Приглашаем на летний корпоратив 15 июля! Регистрация открыта",
                    timestamp: now.addingTimeInterval(-86400),
                    author: "Event Team"
                ),
                unreadCount: 2,
                category: .event,
                priority: .normal
            ),
            
            // Достижения
            FeedChannel(
                id: UUID(),
                name: "🏆 Достижения",
                avatarType: .icon("trophy.fill", .yellow),
                lastMessage: createMessage(
                    "Иван Петров получил сертификат 'iOS Developer Professional'",
                    timestamp: now.addingTimeInterval(-10800),
                    author: "Achievement Bot"
                ),
                unreadCount: 5,
                category: .achievement,
                priority: .normal
            ),
            
            // Департаменты
            FeedChannel(
                id: UUID(),
                name: "💼 HR отдел",
                avatarType: .text("HR", .green),
                lastMessage: createMessage(
                    "График отпусков на август: пожалуйста, подтвердите свои даты",
                    timestamp: now.addingTimeInterval(-14400),
                    author: "HR Department"
                ),
                unreadCount: 0,
                category: .department,
                priority: .normal
            ),
            
            FeedChannel(
                id: UUID(),
                name: "🛠 IT поддержка",
                avatarType: .icon("wrench.and.screwdriver.fill", .gray),
                lastMessage: createMessage(
                    "Плановые работы 16.07: возможны перебои с доступом к CRM",
                    timestamp: now.addingTimeInterval(-21600),
                    author: "IT Support",
                    isRead: true
                ),
                unreadCount: 0,
                category: .department,
                priority: .normal
            ),
            
            // Специальные каналы
            ReleaseNotesChannel.createChannel(),
            SprintReportsChannel.createChannel(),
            MethodologyChannel.createChannel()
        ]
    }
    
    private func simulateUpdates() {
        // Simulate new messages arriving
        Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { [weak self] _ in
            guard let self = self,
                  !self.channels.isEmpty else { return }
            
            let randomIndex = Int.random(in: 0..<self.channels.count)
            var channel = self.channels[randomIndex]
            
            // Update channel with new message
            let newMessage = self.generateRandomMessage(for: channel.category)
            
            channel = FeedChannel(
                id: channel.id,
                name: channel.name,
                avatarType: channel.avatarType,
                lastMessage: self.createMessage(newMessage, timestamp: Date(), author: "Update System"),
                unreadCount: channel.unreadCount + 1,
                category: channel.category,
                priority: channel.priority
            )
            
            self.channels[randomIndex] = channel
            self.updateSubject.send(channel)
        }
    }
    
    private func generateRandomMessage(for category: NewsCategory) -> String {
        switch category {
        case .announcement:
            return ["Важное сообщение от руководства", "Обновление политики компании", "Изменения в расписании", "Общее собрание сотрудников"].randomElement()!
        case .learning:
            return ["Новый учебный материал доступен", "Начало курса перенесено", "Сертификаты готовы", "Вебинар сегодня в 15:00"].randomElement()!
        case .achievement:
            return ["Поздравляем с достижением!", "Новый рекорд продаж", "Лучший сотрудник месяца", "Успешное завершение проекта"].randomElement()!
        case .event:
            return ["Регистрация на мероприятие открыта", "Изменение места проведения", "Фотографии с события", "Приглашение на корпоратив"].randomElement()!
        case .department:
            return ["Обновление от департамента", "Новости отдела", "Изменения в структуре", "Встреча команды в 16:00"].randomElement()!
        }
    }
} 