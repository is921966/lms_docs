//
//  NotificationModels.swift
//  LMS
//
//  Created by LMS Team on 13.01.2025.
//

import Foundation

// MARK: - Notification Types

enum NotificationType: String, Codable, CaseIterable {
    case courseAssigned = "course_assigned"
    case courseCompleted = "course_completed"
    case testDeadline = "test_deadline"
    case testResult = "test_result"
    case competencyAchieved = "competency_achieved"
    case feedMention = "feed_mention"
    case feedComment = "feed_comment"
    case feedLike = "feed_like"
    case systemAnnouncement = "system_announcement"
}

// MARK: - Notification Model

struct Notification: Identifiable, Codable {
    let id: UUID
    let userId: UUID
    let type: NotificationType
    let title: String
    let body: String
    let isRead: Bool
    let createdAt: Date
    let metadata: [String: String]?
    
    init(
        id: UUID = UUID(),
        userId: UUID,
        type: NotificationType,
        title: String,
        body: String,
        isRead: Bool = false,
        createdAt: Date = Date(),
        metadata: [String: String]? = nil
    ) {
        self.id = id
        self.userId = userId
        self.type = type
        self.title = title
        self.body = body
        self.isRead = isRead
        self.createdAt = createdAt
        self.metadata = metadata
    }
}

// MARK: - Push Token

struct PushToken: Identifiable, Codable {
    let id: UUID
    let userId: UUID
    let token: String
    let deviceId: String
    let platform: Platform
    let createdAt: Date
    let updatedAt: Date
    
    enum Platform: String, Codable {
        case ios
        case android
    }
    
    init(
        id: UUID = UUID(),
        userId: UUID,
        token: String,
        deviceId: String,
        platform: Platform = .ios,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.userId = userId
        self.token = token
        self.deviceId = deviceId
        self.platform = platform
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

// MARK: - Notification Preferences

struct NotificationPreferences: Codable {
    let userId: UUID
    let channelPreferences: [NotificationType: [NotificationChannel]]
    let isEnabled: Bool
    let quietHoursStart: Date?
    let quietHoursEnd: Date?
    
    init(
        userId: UUID,
        channelPreferences: [NotificationType: [NotificationChannel]] = [:],
        isEnabled: Bool = true,
        quietHoursStart: Date? = nil,
        quietHoursEnd: Date? = nil
    ) {
        self.userId = userId
        self.channelPreferences = channelPreferences
        self.isEnabled = isEnabled
        self.quietHoursStart = quietHoursStart
        self.quietHoursEnd = quietHoursEnd
    }
}

// MARK: - Notification Channel

enum NotificationChannel: String, Codable, CaseIterable {
    case push
    case email
    case sms
    case inApp
}

// MARK: - Notification Response

struct NotificationResponse: Codable {
    let items: [Notification]
    let totalCount: Int
    let hasMore: Bool
    let nextCursor: String?
}

// MARK: - Notification Filter

struct NotificationFilter: Codable {
    let types: [NotificationType]?
    let isRead: Bool?
    let startDate: Date?
    let endDate: Date?
} 