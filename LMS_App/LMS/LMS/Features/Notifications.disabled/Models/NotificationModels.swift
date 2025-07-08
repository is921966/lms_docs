//
//  NotificationModels.swift
//  LMS
//
//  Created on Sprint 41 Day 1 - Notifications Foundation
//

import Foundation

// MARK: - Notification Type

/// Типы уведомлений в системе
public enum NotificationType: String, Codable, CaseIterable {
    case courseAssigned = "course_assigned"
    case courseCompleted = "course_completed"
    case testAvailable = "test_available"
    case testDeadline = "test_deadline"
    case achievementUnlocked = "achievement_unlocked"
    case certificateIssued = "certificate_issued"
    case systemMessage = "system_message"
    case adminMessage = "admin_message"
    case reminderDaily = "reminder_daily"
    case reminderWeekly = "reminder_weekly"
    case feedActivity = "feed_activity"
    case feedMention = "feed_mention"
    case onboardingTask = "onboarding_task"
    case deadline = "deadline"
    case achievement = "achievement"
    case testReminder = "test_reminder"
    case certificateEarned = "certificate_earned"
    case taskAssigned = "task_assigned"
    case testCompleted = "test_completed"
    
    var displayName: String {
        switch self {
        case .courseAssigned: return "Новый курс"
        case .courseCompleted: return "Курс завершен"
        case .testAvailable: return "Доступен тест"
        case .testDeadline: return "Дедлайн теста"
        case .achievementUnlocked: return "Достижение получено"
        case .certificateIssued: return "Сертификат выдан"
        case .systemMessage: return "Системное сообщение"
        case .adminMessage: return "Сообщение от администратора"
        case .reminderDaily: return "Ежедневное напоминание"
        case .reminderWeekly: return "Еженедельное напоминание"
        case .feedActivity: return "Активность в ленте"
        case .feedMention: return "Упоминание"
        case .onboardingTask: return "Задача онбординга"
        case .deadline: return "Приближается дедлайн"
        case .achievement: return "Достижение"
        case .testReminder: return "Напоминание о тесте"
        case .certificateEarned: return "Сертификат выдан"
        case .taskAssigned: return "Задача назначена"
        case .testCompleted: return "Тест завершен"
        }
    }
    
    var icon: String {
        switch self {
        case .courseAssigned: return "book.circle"
        case .courseCompleted: return "checkmark.circle"
        case .testAvailable: return "doc.text"
        case .testDeadline: return "clock.arrow.circlepath"
        case .achievementUnlocked: return "star.circle"
        case .certificateIssued: return "rosette"
        case .systemMessage: return "gear"
        case .adminMessage: return "person.circle"
        case .reminderDaily: return "bell"
        case .reminderWeekly: return "calendar"
        case .feedActivity: return "bubble.left.and.bubble.right.fill"
        case .feedMention: return "at.circle.fill"
        case .onboardingTask: return "person.badge.clock.fill"
        case .deadline: return "exclamationmark.triangle.fill"
        case .achievement: return "star.fill"
        case .testReminder: return "clock.badge.exclamationmark.fill"
        case .certificateEarned: return "rosette"
        case .taskAssigned: return "square.and.pencil"
        case .testCompleted: return "checkmark.seal.fill"
        }
    }
    
    var defaultPriority: NotificationPriority {
        switch self {
        case .testDeadline, .systemMessage:
            return .high
        case .courseAssigned, .testAvailable, .adminMessage:
            return .medium
        default:
            return .low
        }
    }
}

// MARK: - Notification Channel

/// Каналы доставки уведомлений
public enum NotificationChannel: String, Codable, CaseIterable {
    case push = "push"
    case email = "email"
    case inApp = "in_app"
    case sms = "sms"
    
    var displayName: String {
        switch self {
        case .push: return "Push-уведомления"
        case .email: return "Email"
        case .inApp: return "В приложении"
        case .sms: return "SMS"
        }
    }
}

// MARK: - Notification Priority

/// Приоритет уведомления
public enum NotificationPriority: Int, Codable, Comparable, CaseIterable {
    case low = 0
    case medium = 1
    case high = 2
    case urgent = 3
    
    public static func < (lhs: NotificationPriority, rhs: NotificationPriority) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
}

// MARK: - Notification

/// Основная модель уведомления
public struct Notification: Identifiable, Codable, Equatable {
    public let id: UUID
    public let userId: UUID
    public let type: NotificationType
    public let title: String
    public let body: String
    public let data: [String: String]? // Дополнительные данные для обработки
    public let channels: Set<NotificationChannel>
    public let priority: NotificationPriority
    public var isRead: Bool
    public var readAt: Date?
    public let createdAt: Date
    public let expiresAt: Date?
    public let metadata: NotificationMetadata?
    
    public init(
        id: UUID = UUID(),
        userId: UUID,
        type: NotificationType,
        title: String,
        body: String,
        data: [String: String]? = nil,
        channels: Set<NotificationChannel> = [.inApp],
        priority: NotificationPriority? = nil,
        isRead: Bool = false,
        readAt: Date? = nil,
        createdAt: Date = Date(),
        expiresAt: Date? = nil,
        metadata: NotificationMetadata? = nil
    ) {
        self.id = id
        self.userId = userId
        self.type = type
        self.title = title
        self.body = body
        self.data = data
        self.channels = channels
        self.priority = priority ?? type.defaultPriority
        self.isRead = isRead
        self.readAt = readAt
        self.createdAt = createdAt
        self.expiresAt = expiresAt
        self.metadata = metadata
    }
    
    /// Помечает уведомление как прочитанное
    public mutating func markAsRead() {
        guard !isRead else { return }
        isRead = true
        readAt = Date()
    }
    
    /// Проверяет, истекло ли уведомление
    public var isExpired: Bool {
        guard let expiresAt = expiresAt else { return false }
        return Date() > expiresAt
    }
}

// MARK: - Notification Metadata

/// Дополнительные метаданные уведомления
public struct NotificationMetadata: Codable, Equatable {
    public let imageUrl: String?
    public let actionUrl: String?
    public let actionTitle: String?
    public let badge: Int?
    public let sound: String?
    public let attachments: [NotificationAttachment]?
    
    public init(
        imageUrl: String? = nil,
        actionUrl: String? = nil,
        actionTitle: String? = nil,
        badge: Int? = nil,
        sound: String? = nil,
        attachments: [NotificationAttachment]? = nil
    ) {
        self.imageUrl = imageUrl
        self.actionUrl = actionUrl
        self.actionTitle = actionTitle
        self.badge = badge
        self.sound = sound
        self.attachments = attachments
    }
}

// MARK: - Notification Attachment

/// Вложение в уведомлении
public struct NotificationAttachment: Codable, Equatable {
    public let id: String
    public let url: String
    public let type: AttachmentType
    
    public enum AttachmentType: String, Codable {
        case image = "image"
        case video = "video"
        case audio = "audio"
        case document = "document"
    }
    
    public init(id: String = UUID().uuidString, url: String, type: AttachmentType) {
        self.id = id
        self.url = url
        self.type = type
    }
}

// MARK: - Push Token

/// Токен для push-уведомлений
public struct PushToken: Identifiable, Codable, Equatable {
    public let id: UUID
    public let userId: UUID
    public let token: String
    public let deviceId: String
    public let platform: Platform
    public let environment: Environment
    public var isActive: Bool
    public let createdAt: Date
    public var lastUsedAt: Date
    
    public enum Platform: String, Codable {
        case iOS = "ios"
        case android = "android"
        case web = "web"
    }
    
    public enum Environment: String, Codable {
        case development = "development"
        case production = "production"
    }
    
    public init(
        id: UUID = UUID(),
        userId: UUID,
        token: String,
        deviceId: String,
        platform: Platform = .iOS,
        environment: Environment = .production,
        isActive: Bool = true,
        createdAt: Date = Date(),
        lastUsedAt: Date = Date()
    ) {
        self.id = id
        self.userId = userId
        self.token = token
        self.deviceId = deviceId
        self.platform = platform
        self.environment = environment
        self.isActive = isActive
        self.createdAt = createdAt
        self.lastUsedAt = lastUsedAt
    }
    
    /// Обновляет время последнего использования
    public mutating func updateLastUsed() {
        lastUsedAt = Date()
    }
    
    /// Деактивирует токен
    public mutating func deactivate() {
        isActive = false
    }
}

// MARK: - Notification Preferences

/// Настройки уведомлений пользователя
public struct NotificationPreferences: Codable, Equatable {
    public let userId: UUID
    public var channelPreferences: [NotificationType: Set<NotificationChannel>]
    public var isEnabled: Bool
    public var quietHours: QuietHours?
    public var frequencyLimits: [NotificationType: FrequencyLimit]
    public var updatedAt: Date
    
    public init(
        userId: UUID,
        channelPreferences: [NotificationType: Set<NotificationChannel>] = [:],
        isEnabled: Bool = true,
        quietHours: QuietHours? = nil,
        frequencyLimits: [NotificationType: FrequencyLimit] = [:],
        updatedAt: Date = Date()
    ) {
        self.userId = userId
        self.channelPreferences = channelPreferences
        self.isEnabled = isEnabled
        self.quietHours = quietHours
        self.frequencyLimits = frequencyLimits
        self.updatedAt = updatedAt
    }
    
    /// Получает предпочитаемые каналы для типа уведомления
    public func channels(for type: NotificationType) -> Set<NotificationChannel> {
        return channelPreferences[type] ?? [.inApp]
    }
    
    /// Проверяет, включен ли канал для типа уведомления
    public func isChannelEnabled(_ channel: NotificationChannel, for type: NotificationType) -> Bool {
        guard isEnabled else { return false }
        return channels(for: type).contains(channel)
    }
    
    /// Проверяет, находимся ли в тихих часах
    public var isInQuietHours: Bool {
        guard let quietHours = quietHours, quietHours.isEnabled else { return false }
        return quietHours.isActive(at: Date())
    }
    
    /// Обновляет настройки канала
    public mutating func updateChannel(_ channel: NotificationChannel, enabled: Bool, for type: NotificationType) {
        var channels = channelPreferences[type] ?? []
        if enabled {
            channels.insert(channel)
        } else {
            channels.remove(channel)
        }
        channelPreferences[type] = channels
        updatedAt = Date()
    }
}

// MARK: - Quiet Hours

/// Настройки тихих часов
public struct QuietHours: Codable, Equatable {
    public var isEnabled: Bool
    public var startTime: DateComponents // Часы и минуты
    public var endTime: DateComponents   // Часы и минуты
    public var allowUrgent: Bool         // Разрешать urgent уведомления
    
    public init(
        isEnabled: Bool = false,
        startTime: DateComponents = DateComponents(hour: 22, minute: 0),
        endTime: DateComponents = DateComponents(hour: 8, minute: 0),
        allowUrgent: Bool = true
    ) {
        self.isEnabled = isEnabled
        self.startTime = startTime
        self.endTime = endTime
        self.allowUrgent = allowUrgent
    }
    
    /// Проверяет, активны ли тихие часы в указанное время
    public func isActive(at date: Date = Date()) -> Bool {
        guard isEnabled else { return false }
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: date)
        
        guard let currentHour = components.hour,
              let currentMinute = components.minute,
              let startHour = startTime.hour,
              let endHour = endTime.hour else {
            return false
        }
        
        let startMinute = startTime.minute ?? 0
        let endMinute = endTime.minute ?? 0
        
        let currentMinutes = currentHour * 60 + currentMinute
        let startMinutes = startHour * 60 + startMinute
        let endMinutes = endHour * 60 + endMinute
        
        if startMinutes <= endMinutes {
            // Обычный случай (например, 22:00 - 08:00)
            return currentMinutes >= startMinutes || currentMinutes < endMinutes
        } else {
            // Переход через полночь
            return currentMinutes >= startMinutes && currentMinutes < endMinutes
        }
    }
}

// MARK: - Frequency Limit

/// Ограничение частоты уведомлений
public struct FrequencyLimit: Codable, Equatable {
    public var maxPerHour: Int?
    public var maxPerDay: Int?
    public var maxPerWeek: Int?
    
    public init(
        maxPerHour: Int? = nil,
        maxPerDay: Int? = nil,
        maxPerWeek: Int? = nil
    ) {
        self.maxPerHour = maxPerHour
        self.maxPerDay = maxPerDay
        self.maxPerWeek = maxPerWeek
    }
}



// MARK: - Notification Template

/// Шаблон уведомления для переиспользования
public struct NotificationTemplate: Identifiable, Codable {
    public let id: UUID
    public let type: NotificationType
    public let titleTemplate: String      // С плейсхолдерами {{name}}
    public let bodyTemplate: String       // С плейсхолдерами
    public let defaultChannels: Set<NotificationChannel>
    public let defaultPriority: NotificationPriority
    public let defaultExpiration: TimeInterval? // Секунды до истечения
    
    public init(
        id: UUID = UUID(),
        type: NotificationType,
        titleTemplate: String,
        bodyTemplate: String,
        defaultChannels: Set<NotificationChannel> = [.inApp, .push],
        defaultPriority: NotificationPriority? = nil,
        defaultExpiration: TimeInterval? = nil
    ) {
        self.id = id
        self.type = type
        self.titleTemplate = titleTemplate
        self.bodyTemplate = bodyTemplate
        self.defaultChannels = defaultChannels
        self.defaultPriority = defaultPriority ?? type.defaultPriority
        self.defaultExpiration = defaultExpiration
    }
    
    /// Применяет параметры к шаблону
    public func render(with parameters: [String: String]) -> (title: String, body: String) {
        var title = titleTemplate
        var body = bodyTemplate
        
        for (key, value) in parameters {
            title = title.replacingOccurrences(of: "{{\(key)}}", with: value)
            body = body.replacingOccurrences(of: "{{\(key)}}", with: value)
        }
        
        return (title, body)
    }
}

// MARK: - User Preferences

/// Пользовательские настройки
public struct UserPreferences: Codable, Equatable {
    public var language: String
    public var notifications: NotificationPreferences?
    public var theme: String
    
    public init(
        language: String = "ru",
        notifications: NotificationPreferences? = nil,
        theme: String = "light"
    ) {
        self.language = language
        self.notifications = notifications
        self.theme = theme
    }
} 

// MARK: - Notification Action Data

/// Actions available for notifications
public struct NotificationActionData: Codable, Hashable {
    public let identifier: String
    public let title: String
    public let targetView: String?
    public let parameters: [String: String]?
    public let options: NotificationActionOptions
    public let textInput: NotificationTextInputAction?
    
    public init(
        identifier: String,
        title: String,
        targetView: String? = nil,
        parameters: [String: String]? = nil,
        options: NotificationActionOptions = [],
        textInput: NotificationTextInputAction? = nil
    ) {
        self.identifier = identifier
        self.title = title
        self.targetView = targetView
        self.parameters = parameters
        self.options = options
        self.textInput = textInput
    }
}

/// Options for notification actions
public struct NotificationActionOptions: OptionSet, Codable, Hashable {
    public let rawValue: Int
    
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
    
    public static let foreground = NotificationActionOptions(rawValue: 1 << 0)
    public static let destructive = NotificationActionOptions(rawValue: 1 << 1)
    public static let authenticationRequired = NotificationActionOptions(rawValue: 1 << 2)
}

// MARK: - Notification Category

/// Categories for grouping notifications and defining actions
public enum NotificationCategory: String, CaseIterable, Codable {
    case course = "course"
    case test = "test"
    case task = "task"
    case message = "message"
    case achievement = "achievement"
    case feed = "feed"
    case reminder = "reminder"
    
    /// Actions available for this category
    var actions: [NotificationActionData] {
        switch self {
        case .course:
            return [
                NotificationActionData(
                    identifier: "view_course",
                    title: "Открыть курс",
                    options: [.foreground]
                ),
                NotificationActionData(
                    identifier: "start_learning",
                    title: "Начать обучение",
                    options: [.foreground]
                )
            ]
        case .test:
            return [
                NotificationActionData(
                    identifier: "start_test",
                    title: "Начать тест",
                    options: [.foreground]
                ),
                NotificationActionData(
                    identifier: "remind_later",
                    title: "Напомнить позже",
                    options: []
                )
            ]
        case .task:
            return [
                NotificationActionData(
                    identifier: "complete_task",
                    title: "Выполнить",
                    options: [.foreground]
                ),
                NotificationActionData(
                    identifier: "view_details",
                    title: "Подробнее",
                    options: [.foreground]
                )
            ]
        case .message:
            return [
                NotificationActionData(
                    identifier: "reply",
                    title: "Ответить",
                    options: [.foreground],
                    textInput: NotificationTextInputAction(
                        identifier: "reply_text",
                        title: "Ответить",
                        placeholder: "Введите ответ..."
                    )
                ),
                NotificationActionData(
                    identifier: "mark_read",
                    title: "Прочитано",
                    options: []
                )
            ]
        case .achievement:
            return [
                NotificationActionData(
                    identifier: "view_achievement",
                    title: "Посмотреть",
                    options: [.foreground]
                ),
                NotificationActionData(
                    identifier: "share",
                    title: "Поделиться",
                    options: [.foreground]
                )
            ]
        case .feed:
            return [
                NotificationActionData(
                    identifier: "view_post",
                    title: "Открыть",
                    options: [.foreground]
                ),
                NotificationActionData(
                    identifier: "like",
                    title: "Нравится",
                    options: []
                )
            ]
        case .reminder:
            return [
                NotificationActionData(
                    identifier: "complete",
                    title: "Выполнено",
                    options: []
                ),
                NotificationActionData(
                    identifier: "snooze",
                    title: "Отложить",
                    options: []
                )
            ]
        }
    }
}

/// Extended notification action with text input support
public struct NotificationTextInputAction: Codable, Hashable {
    public let identifier: String
    public let title: String
    public let placeholder: String
    
    public init(
        identifier: String,
        title: String,
        placeholder: String
    ) {
        self.identifier = identifier
        self.title = title
        self.placeholder = placeholder
    }
} 

// MARK: - Notification Event

/// Event related to a notification
public struct NotificationEvent: Codable, Equatable {
    public let id: UUID
    public let notificationId: UUID
    public let type: NotificationEventType
    public let timestamp: Date
    public let metadata: [String: String]?
    
    public init(
        id: UUID = UUID(),
        notificationId: UUID,
        type: NotificationEventType,
        timestamp: Date = Date(),
        metadata: [String: String]? = nil
    ) {
        self.id = id
        self.notificationId = notificationId
        self.type = type
        self.timestamp = timestamp
        self.metadata = metadata
    }
}

/// Type of notification event
public enum NotificationEventType: String, Codable, CaseIterable {
    case delivered = "delivered"
    case opened = "opened"
    case actionTaken = "action_taken"
    case dismissed = "dismissed"
    case failed = "failed"
}

// MARK: - Notification Analytics

/// Analytics data for notifications
public struct NotificationAnalytics: Codable {
    public let totalSent: Int
    public let totalDelivered: Int
    public let totalOpened: Int
    public let totalActioned: Int
    public let openRate: Double
    public let clickThroughRate: Double
    public let byType: [NotificationType: TypeAnalytics]
    public let byChannel: [NotificationChannel: ChannelAnalytics]
    public let timeline: [TimelineData]
    
    public init(
        totalSent: Int,
        totalDelivered: Int,
        totalOpened: Int,
        totalActioned: Int,
        openRate: Double,
        clickThroughRate: Double,
        byType: [NotificationType: TypeAnalytics] = [:],
        byChannel: [NotificationChannel: ChannelAnalytics] = [:],
        timeline: [TimelineData] = []
    ) {
        self.totalSent = totalSent
        self.totalDelivered = totalDelivered
        self.totalOpened = totalOpened
        self.totalActioned = totalActioned
        self.openRate = openRate
        self.clickThroughRate = clickThroughRate
        self.byType = byType
        self.byChannel = byChannel
        self.timeline = timeline
    }
}

/// Analytics for a specific notification type
public struct TypeAnalytics: Codable {
    public let sent: Int
    public let delivered: Int
    public let opened: Int
    public let actioned: Int
    public let openRate: Double
    public let clickThroughRate: Double
    
    public init(
        sent: Int,
        delivered: Int,
        opened: Int,
        actioned: Int,
        openRate: Double,
        clickThroughRate: Double
    ) {
        self.sent = sent
        self.delivered = delivered
        self.opened = opened
        self.actioned = actioned
        self.openRate = openRate
        self.clickThroughRate = clickThroughRate
    }
}

/// Analytics for a specific channel
public struct ChannelAnalytics: Codable {
    public let sent: Int
    public let delivered: Int
    public let failed: Int
    public let deliveryRate: Double
    
    public init(
        sent: Int,
        delivered: Int,
        failed: Int,
        deliveryRate: Double
    ) {
        self.sent = sent
        self.delivered = delivered
        self.failed = failed
        self.deliveryRate = deliveryRate
    }
}

/// Timeline data point
public struct TimelineData: Codable {
    public let date: Date
    public let sent: Int
    public let delivered: Int
    public let opened: Int
    public let actioned: Int
    
    public init(
        date: Date,
        sent: Int,
        delivered: Int,
        opened: Int,
        actioned: Int
    ) {
        self.date = date
        self.sent = sent
        self.delivered = delivered
        self.opened = opened
        self.actioned = actioned
    }
} 

// MARK: - Notification Filter

/// Filter for querying notifications
public struct NotificationFilter {
    public let types: [NotificationType]?
    public let channels: [NotificationChannel]?
    public let priorities: [NotificationPriority]?
    public let showRead: Bool
    public let dateFrom: Date?
    public let dateTo: Date?
    
    public init(
        types: [NotificationType]? = nil,
        channels: [NotificationChannel]? = nil,
        priorities: [NotificationPriority]? = nil,
        showRead: Bool = true,
        dateFrom: Date? = nil,
        dateTo: Date? = nil
    ) {
        self.types = types
        self.channels = channels
        self.priorities = priorities
        self.showRead = showRead
        self.dateFrom = dateFrom
        self.dateTo = dateTo
    }
}

// MARK: - Notification Stats

/// Statistics about notifications
public struct NotificationStats: Codable {
    public let totalSent: Int
    public let totalOpened: Int
    public let totalClicked: Int
    public let openRate: Double
    public let clickRate: Double
    public let byType: [NotificationType: Int]
    public let byChannel: [NotificationChannel: Int]
    
    public init(
        totalSent: Int = 0,
        totalOpened: Int = 0,
        totalClicked: Int = 0,
        openRate: Double = 0,
        clickRate: Double = 0,
        byType: [NotificationType: Int] = [:],
        byChannel: [NotificationChannel: Int] = [:]
    ) {
        self.totalSent = totalSent
        self.totalOpened = totalOpened
        self.totalClicked = totalClicked
        self.openRate = openRate
        self.clickRate = clickRate
        self.byType = byType
        self.byChannel = byChannel
    }
} 