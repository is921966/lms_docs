import Foundation
import SwiftUI

// MARK: - Notification Model
struct Notification: Identifiable, Codable {
    let id = UUID()
    var title: String
    var message: String
    var type: NotificationType
    var priority: NotificationPriority
    var createdAt: Date = Date()
    var readAt: Date?
    var actionType: NotificationAction?
    var actionData: [String: String]?
    var recipientId: UUID
    var senderId: UUID?
    
    var isRead: Bool {
        readAt != nil
    }
    
    var icon: String {
        switch type {
        case .courseAssigned:
            return "book.circle.fill"
        case .testReminder:
            return "clock.badge.exclamationmark.fill"
        case .certificateEarned:
            return "rosette"
        case .onboardingTask:
            return "person.badge.clock.fill"
        case .deadline:
            return "exclamationmark.triangle.fill"
        case .achievement:
            return "star.fill"
        case .system:
            return "info.circle.fill"
        }
    }
    
    var color: Color {
        switch priority {
        case .high:
            return .red
        case .medium:
            return .orange
        case .low:
            return .blue
        }
    }
}

// MARK: - Notification Types
enum NotificationType: String, Codable, CaseIterable {
    case courseAssigned = "Назначен курс"
    case testReminder = "Напоминание о тесте"
    case certificateEarned = "Получен сертификат"
    case onboardingTask = "Задача онбординга"
    case deadline = "Приближается дедлайн"
    case achievement = "Достижение"
    case system = "Системное"
}

// MARK: - Notification Priority
enum NotificationPriority: String, Codable, CaseIterable {
    case high = "Высокий"
    case medium = "Средний"
    case low = "Низкий"
}

// MARK: - Notification Actions
enum NotificationAction: String, Codable {
    case openCourse
    case openTest
    case viewCertificate
    case openOnboardingTask
    case openProfile
    case none
}

// MARK: - Mock Data
extension Notification {
    static let mockNotifications = [
        Notification(
            title: "Новый курс назначен",
            message: "Вам назначен курс 'Основы проектного управления'. Срок прохождения: 30 дней.",
            type: .courseAssigned,
            priority: .high,
            actionType: .openCourse,
            actionData: ["courseId": "course-1"],
            recipientId: UUID()
        ),
        Notification(
            title: "Напоминание о тесте",
            message: "Не забудьте пройти тест по курсу 'Работа с клиентами' до конца недели.",
            type: .testReminder,
            priority: .medium,
            actionType: .openTest,
            actionData: ["testId": "test-1"],
            recipientId: UUID()
        ),
        Notification(
            title: "Поздравляем с сертификатом!",
            message: "Вы успешно завершили курс и получили сертификат.",
            type: .certificateEarned,
            priority: .low,
            readAt: Date().addingTimeInterval(-3600),
            actionType: .viewCertificate,
            actionData: ["certificateId": "cert-1"],
            recipientId: UUID()
        ),
        Notification(
            title: "Задача онбординга",
            message: "Пожалуйста, завершите знакомство с корпоративными политиками.",
            type: .onboardingTask,
            priority: .high,
            actionType: .openOnboardingTask,
            actionData: ["taskId": "task-1"],
            recipientId: UUID()
        )
    ]
} 