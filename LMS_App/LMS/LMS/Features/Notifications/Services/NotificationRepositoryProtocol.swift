//
//  NotificationRepositoryProtocol.swift
//  LMS
//
//  Created by LMS Team on 13.01.2025.
//

import Foundation

protocol NotificationRepositoryProtocol {
    // Notifications
    func createNotification(_ notification: Notification) async throws -> Notification
    func fetchNotifications(for userId: UUID, filter: NotificationFilter?, pagination: NotificationPaginationRequest?) async throws -> NotificationResponse
    func markAsRead(notificationId: UUID) async throws
    func markAllAsRead(for userId: UUID) async throws
    func deleteNotification(_ notificationId: UUID) async throws
    
    // Push Tokens
    func savePushToken(_ token: PushToken) async throws -> PushToken
    func getPushTokens(for userId: UUID) async throws -> [PushToken]
    func deletePushToken(_ tokenId: UUID) async throws
    
    // Preferences
    func updatePreferences(_ preferences: NotificationPreferences) async throws -> NotificationPreferences
    func getPreferences(for userId: UUID) async throws -> NotificationPreferences
}

// MARK: - Notification Pagination Request

struct NotificationPaginationRequest: Codable {
    let limit: Int
    let offset: Int
    let cursor: String?
    
    init(limit: Int = 20, offset: Int = 0, cursor: String? = nil) {
        self.limit = limit
        self.offset = offset
        self.cursor = cursor
    }
} 