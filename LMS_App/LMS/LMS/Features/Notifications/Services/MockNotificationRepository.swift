//
//  MockNotificationRepository.swift
//  LMS
//
//  Created by LMS Team on 13.01.2025.
//

import Foundation

@MainActor
class MockNotificationRepository: NotificationRepositoryProtocol {
    
    private var notifications: [Notification] = []
    private var pushTokens: [PushToken] = []
    private var preferences: [UUID: NotificationPreferences] = [:]
    
    // MARK: - Notifications
    
    func createNotification(_ notification: Notification) async throws -> Notification {
        notifications.append(notification)
        return notification
    }
    
    func fetchNotifications(
        for userId: UUID,
        filter: NotificationFilter?,
        pagination: NotificationPaginationRequest?
    ) async throws -> NotificationResponse {
        var filtered = notifications.filter { $0.userId == userId }
        
        // Apply filters
        if let filter = filter {
            if let types = filter.types {
                filtered = filtered.filter { types.contains($0.type) }
            }
            if let isRead = filter.isRead {
                filtered = filtered.filter { $0.isRead == isRead }
            }
            if let startDate = filter.startDate {
                filtered = filtered.filter { $0.createdAt >= startDate }
            }
            if let endDate = filter.endDate {
                filtered = filtered.filter { $0.createdAt <= endDate }
            }
        }
        
        // Sort by date descending
        filtered.sort { $0.createdAt > $1.createdAt }
        
        // Apply pagination
        let limit = pagination?.limit ?? 20
        let offset = pagination?.offset ?? 0
        
        let paginatedItems = Array(filtered.dropFirst(offset).prefix(limit))
        
        return NotificationResponse(
            items: paginatedItems,
            totalCount: filtered.count,
            hasMore: offset + limit < filtered.count,
            nextCursor: nil
        )
    }
    
    func markAsRead(notificationId: UUID) async throws {
        if let index = notifications.firstIndex(where: { $0.id == notificationId }) {
            var notification = notifications[index]
            notification = Notification(
                id: notification.id,
                userId: notification.userId,
                type: notification.type,
                title: notification.title,
                body: notification.body,
                isRead: true,
                createdAt: notification.createdAt,
                metadata: notification.metadata
            )
            notifications[index] = notification
        }
    }
    
    func markAllAsRead(for userId: UUID) async throws {
        for (index, notification) in notifications.enumerated() {
            if notification.userId == userId && !notification.isRead {
                notifications[index] = Notification(
                    id: notification.id,
                    userId: notification.userId,
                    type: notification.type,
                    title: notification.title,
                    body: notification.body,
                    isRead: true,
                    createdAt: notification.createdAt,
                    metadata: notification.metadata
                )
            }
        }
    }
    
    func deleteNotification(_ notificationId: UUID) async throws {
        notifications.removeAll { $0.id == notificationId }
    }
    
    // MARK: - Push Tokens
    
    func savePushToken(_ token: PushToken) async throws -> PushToken {
        // Remove old tokens for the same device
        pushTokens.removeAll { $0.deviceId == token.deviceId }
        pushTokens.append(token)
        return token
    }
    
    func getPushTokens(for userId: UUID) async throws -> [PushToken] {
        return pushTokens.filter { $0.userId == userId }
    }
    
    func deletePushToken(_ tokenId: UUID) async throws {
        pushTokens.removeAll { $0.id == tokenId }
    }
    
    // MARK: - Preferences
    
    func savePreferences(_ preferences: NotificationPreferences) async throws -> NotificationPreferences {
        self.preferences[preferences.userId] = preferences
        return preferences
    }
    
    func updatePreferences(_ preferences: NotificationPreferences) async throws -> NotificationPreferences {
        self.preferences[preferences.userId] = preferences
        return preferences
    }
    
    func getPreferences(for userId: UUID) async throws -> NotificationPreferences {
        if let prefs = preferences[userId] {
            return prefs
        }
        
        // Return default preferences
        return NotificationPreferences(userId: userId)
    }
    
    // MARK: - Testing Helpers
    
    func reset() {
        notifications.removeAll()
        pushTokens.removeAll()
        preferences.removeAll()
    }
    
    func addTestNotifications(for userId: UUID, count: Int) {
        for i in 0..<count {
            let notification = Notification(
                userId: userId,
                type: NotificationType.allCases.randomElement()!,
                title: "Test Notification \(i)",
                body: "This is test notification body \(i)",
                isRead: Bool.random(),
                createdAt: Date().addingTimeInterval(Double(-i * 3600))
            )
            notifications.append(notification)
        }
    }
} 