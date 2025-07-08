//
//  NotificationEndpoints.swift
//  LMS
//
//  Created on Sprint 41 Day 4 - Notification API Endpoints
//

import Foundation

/// API endpoints for notifications
public enum NotificationEndpoint: APIEndpoint {
    case getNotifications(page: Int, limit: Int)
    case getNotification(id: UUID)
    case createNotification(request: CreateNotificationRequest)
    case markAsRead(id: UUID)
    case deleteNotification(id: UUID)
    case getPreferences
    case updatePreferences(NotificationPreferences)
    case registerPushToken(RegisterPushTokenRequest)
    case getNotificationStats(from: Date, to: Date)
    case getUnreadCount
    
    public var path: String {
        switch self {
        case .getNotifications:
            return "/api/notifications"
        case .getNotification(let id):
            return "/api/notifications/\(id)"
        case .createNotification:
            return "/api/notifications"
        case .markAsRead(let id):
            return "/api/notifications/\(id)/read"
        case .deleteNotification(let id):
            return "/api/notifications/\(id)"
        case .getPreferences:
            return "/api/notifications/preferences"
        case .updatePreferences:
            return "/api/notifications/preferences"
        case .registerPushToken:
            return "/api/push-tokens"
        case .getNotificationStats:
            return "/api/notifications/stats"
        case .getUnreadCount:
            return "/api/notifications/unread-count"
        }
    }
    
    public var method: HTTPMethod {
        switch self {
        case .getNotifications, .getNotification, .getPreferences, .getNotificationStats, .getUnreadCount:
            return .get
        case .createNotification, .registerPushToken:
            return .post
        case .markAsRead, .updatePreferences:
            return .put
        case .deleteNotification:
            return .delete
        }
    }
    
    public var headers: [String: String]? {
        var headers: [String: String] = [
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]
        
        switch self {
        case .registerPushToken:
            headers["X-Platform"] = "ios"
            
        case .markAsRead, .deleteNotification:
            headers["X-Mutation"] = "true"
            
        default:
            break
        }
        
        return headers
    }
    
    public var parameters: [String: Any]? {
        switch self {
        case .getNotifications(let page, let limit):
            return [
                "page": page,
                "limit": limit
            ]
        case .getNotificationStats(let from, let to):
            return [
                "from": ISO8601DateFormatter().string(from: from),
                "to": ISO8601DateFormatter().string(from: to)
            ]
        default:
            return nil
        }
    }
    
    public var body: Data? {
        switch self {
        case .createNotification(let request):
            return try? JSONEncoder().encode(request)
        case .updatePreferences(let preferences):
            return try? JSONEncoder().encode(preferences)
        case .registerPushToken(let request):
            return try? JSONEncoder().encode(request)
        default:
            return nil
        }
    }
}

// MARK: - Request Models

/// Request to create a notification
public struct CreateNotificationRequest: Codable {
    public let recipientIds: [UUID]
    public let type: NotificationType
    public let title: String
    public let body: String
    public let data: [String: String]?
    public let channels: [NotificationChannel]?
    public let priority: NotificationPriority?
    public let metadata: NotificationMetadata?
    public let scheduledAt: Date?
    
    public init(
        recipientIds: [UUID],
        type: NotificationType,
        title: String,
        body: String,
        data: [String: String]? = nil,
        channels: [NotificationChannel]? = nil,
        priority: NotificationPriority? = nil,
        metadata: NotificationMetadata? = nil,
        scheduledAt: Date? = nil
    ) {
        self.recipientIds = recipientIds
        self.type = type
        self.title = title
        self.body = body
        self.data = data
        self.channels = channels
        self.priority = priority
        self.metadata = metadata
        self.scheduledAt = scheduledAt
    }
}

/// Request to register a push token
public struct RegisterPushTokenRequest: Codable {
    public let token: String
    public let deviceId: String
    public let platform: PushToken.Platform
    public let environment: PushToken.Environment
    
    public init(
        token: String,
        deviceId: String,
        platform: PushToken.Platform = .iOS,
        environment: PushToken.Environment = .production
    ) {
        self.token = token
        self.deviceId = deviceId
        self.platform = platform
        self.environment = environment
    }
}

// MARK: - Response Models

/// Response containing unread notification count
public struct UnreadCountResponse: Codable {
    public let count: Int
    
    public init(count: Int) {
        self.count = count
    }
} 