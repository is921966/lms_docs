import Foundation
import SwiftUI

// MARK: - Notification Model
struct Notification: Identifiable, Codable {
    let id: String
    let type: NotificationType
    let title: String
    let message: String
    let createdAt: Date
    var isRead: Bool
    let priority: NotificationPriority
    let actionUrl: String?
    let metadata: [String: String]?

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
        case .feedActivity:
            return "bubble.left.and.bubble.right.fill"
        case .feedMention:
            return "at.circle.fill"
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
    case courseAssigned = "course_assigned"
    case testReminder = "test_reminder"
    case certificateEarned = "certificate_earned"
    case onboardingTask = "onboarding_task"
    case deadline = "deadline"
    case achievement = "achievement"
    case system = "system"
    case feedActivity = "feed_activity"
    case feedMention = "feed_mention"

    var displayName: String {
        switch self {
        case .courseAssigned: return "Назначен курс"
        case .testReminder: return "Напоминание о тесте"
        case .certificateEarned: return "Получен сертификат"
        case .onboardingTask: return "Задача онбординга"
        case .deadline: return "Приближается дедлайн"
        case .achievement: return "Достижение"
        case .system: return "Системное"
        case .feedActivity: return "Активность в ленте"
        case .feedMention: return "Упоминание"
        }
    }
}

// MARK: - Notification Priority
enum NotificationPriority: String, Codable, CaseIterable {
    case high = "high"
    case medium = "medium"
    case low = "low"

    var displayName: String {
        switch self {
        case .high: return "Высокий"
        case .medium: return "Средний"
        case .low: return "Низкий"
        }
    }
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
            id: "1",
            type: .courseAssigned,
            title: "Новый курс назначен",
            message: "Вам назначен курс 'Основы проектного управления'. Срок прохождения: 30 дней.",
            createdAt: Date().addingTimeInterval(-3_600),
            isRead: false,
            priority: .high,
            actionUrl: "course://1",
            metadata: ["courseId": "1"]
        ),
        Notification(
            id: "2",
            type: .testReminder,
            title: "Напоминание о тесте",
            message: "Не забудьте пройти тест по курсу 'Работа с клиентами' до конца недели.",
            createdAt: Date().addingTimeInterval(-7_200),
            isRead: false,
            priority: .medium,
            actionUrl: "test://1",
            metadata: ["testId": "1"]
        ),
        Notification(
            id: "3",
            type: .certificateEarned,
            title: "Поздравляем с сертификатом!",
            message: "Вы успешно завершили курс и получили сертификат.",
            createdAt: Date().addingTimeInterval(-86_400),
            isRead: true,
            priority: .low,
            actionUrl: "certificate://1",
            metadata: ["certificateId": "1"]
        ),
        Notification(
            id: "4",
            type: .onboardingTask,
            title: "Задача онбординга",
            message: "Пожалуйста, завершите знакомство с корпоративными политиками.",
            createdAt: Date().addingTimeInterval(-10_800),
            isRead: false,
            priority: .high,
            actionUrl: "onboarding://task/1",
            metadata: ["taskId": "1"]
        )
    ]
}
