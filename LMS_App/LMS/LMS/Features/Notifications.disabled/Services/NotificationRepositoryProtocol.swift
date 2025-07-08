//
//  NotificationRepositoryProtocol.swift
//  LMS
//
//  Repository protocol for notifications - Sprint 41 Day 1
//

import Foundation
import Combine

/// Protocol defining notification repository operations
public protocol NotificationRepositoryProtocol {
    
    // MARK: - Notification Operations
    
    /// Fetch notifications for a user
    func fetchNotifications(
        for userId: UUID,
        limit: Int?,
        offset: Int?,
        includeRead: Bool
    ) async throws -> [Notification]
    
    /// Get single notification by ID
    func getNotification(id: UUID) async throws -> Notification?
    
    /// Create new notification
    func createNotification(_ notification: Notification) async throws -> Notification
    
    /// Update notification (mark as read, etc)
    func updateNotification(_ notification: Notification) async throws -> Notification
    
    /// Delete notification
    func deleteNotification(id: UUID) async throws
    
    /// Mark notification as read
    func markAsRead(notificationId: UUID, at date: Date) async throws
    
    /// Mark all notifications as read for user
    func markAllAsRead(for userId: UUID) async throws
    
    /// Get unread count
    func getUnreadCount(for userId: UUID) async throws -> Int
    
    /// Delete expired notifications
    func deleteExpiredNotifications() async throws -> Int
    
    // MARK: - Preferences Operations
    
    /// Get notification preferences
    func getPreferences(for userId: UUID) async throws -> NotificationPreferences?
    
    /// Save notification preferences
    func savePreferences(_ preferences: NotificationPreferences) async throws -> NotificationPreferences
    
    /// Update preferences
    func updatePreferences(_ preferences: NotificationPreferences) async throws -> NotificationPreferences
    
    // MARK: - Template Operations
    
    /// Get notification template by type
    func getTemplate(type: NotificationType) async throws -> NotificationTemplate?
    
    /// Get all templates
    func getAllTemplates() async throws -> [NotificationTemplate]
    
    /// Save template
    func saveTemplate(_ template: NotificationTemplate) async throws -> NotificationTemplate
    
    // MARK: - Analytics
    
    /// Track notification event
    func trackNotificationEvent(
        notificationId: UUID,
        event: NotificationEvent
    ) async throws
    
    /// Get notification analytics
    func getNotificationAnalytics(
        userId: UUID?,
        from startDate: Date,
        to endDate: Date
    ) async throws -> NotificationAnalytics
    
    // MARK: - Push Token Management
    
    /// Save push token
    func savePushToken(_ token: PushToken) async throws -> PushToken
    
    /// Get push tokens for user
    func getUserPushTokens(userId: UUID) async throws -> [PushToken]
    
    /// Update push token
    func updatePushToken(_ token: PushToken) async throws -> PushToken
    
    /// Delete push token
    func deletePushToken(id: UUID) async throws
    
    /// Get all push tokens (for admin)
    func getAllPushTokens() async throws -> [PushToken]
    
    /// Register push token (alias for savePushToken)
    func registerPushToken(_ token: PushToken) async throws -> PushToken
    
    /// Get push tokens for user (alias for getUserPushTokens)
    func getPushTokens(for userId: UUID) async throws -> [PushToken]
    
    /// Deactivate push token
    func deactivatePushToken(tokenId: UUID) async throws
    
    /// Deactivate all tokens for device
    func deactivateTokensForDevice(deviceId: String) async throws
}

// Note: NotificationEvent, NotificationEventType, and NotificationAnalytics 
// are now defined in NotificationModels.swift 