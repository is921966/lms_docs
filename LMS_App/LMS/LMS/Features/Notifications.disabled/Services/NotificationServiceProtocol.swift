//
//  NotificationServiceProtocol.swift
//  LMS
//
//  Main notification service protocol - Sprint 41 Day 1
//

import Foundation
import Combine

/// Main protocol for notification service
public protocol NotificationServiceProtocol {
    
    // MARK: - Properties
    
    /// Current notifications for the user
    var notifications: AnyPublisher<[Notification], Never> { get }
    
    /// Unread notifications count
    var unreadCount: AnyPublisher<Int, Never> { get }
    
    /// Current user preferences
    var preferences: AnyPublisher<NotificationPreferences?, Never> { get }
    
    // MARK: - Notification Management
    
    /// Load notifications from backend
    func loadNotifications(limit: Int?, offset: Int?) async throws
    
    /// Refresh notifications
    func refreshNotifications() async throws
    
    /// Send notification to user(s)
    func sendNotification(
        to recipients: [UUID],
        type: NotificationType,
        title: String,
        body: String,
        data: [String: Any]?,
        channels: [NotificationChannel]?,
        priority: NotificationPriority?,
        metadata: NotificationMetadata?
    ) async throws
    
    /// Send notification using template
    func sendTemplatedNotification(
        to recipients: [UUID],
        type: NotificationType,
        parameters: [String: String],
        data: [String: Any]?
    ) async throws
    
    /// Mark notification as read
    func markAsRead(_ notificationId: UUID) async throws
    
    /// Mark all notifications as read
    func markAllAsRead() async throws
    
    /// Delete notification
    func deleteNotification(_ notificationId: UUID) async throws
    
    /// Delete all notifications
    func deleteAllNotifications() async throws
    
    // MARK: - Preferences Management
    
    /// Load user preferences
    func loadPreferences() async throws
    
    /// Update preferences
    func updatePreferences(_ preferences: NotificationPreferences) async throws
    
    /// Update channel preference
    func updateChannelPreference(
        type: NotificationType,
        channels: [NotificationChannel]
    ) async throws
    
    /// Update quiet hours
    func updateQuietHours(_ quietHours: QuietHours?) async throws
    
    /// Update frequency limit
    func updateFrequencyLimit(
        type: NotificationType,
        limit: FrequencyLimit?
    ) async throws
    
    // MARK: - Push Token Management
    
    /// Register push token
    func registerPushToken(_ tokenData: Data) async throws
    
    /// Unregister current device
    func unregisterDevice() async throws
    
    /// Check if push notifications are enabled
    func isPushEnabled() async -> Bool
    
    // MARK: - Analytics
    
    /// Track notification opened
    func trackNotificationOpened(_ notificationId: UUID) async throws
    
    /// Track notification action
    func trackNotificationAction(
        _ notificationId: UUID,
        action: String
    ) async throws
    
    /// Get notification statistics
    func getNotificationStats(
        from startDate: Date,
        to endDate: Date
    ) async throws -> NotificationStats
    
    // MARK: - Specialized Notifications
    
    /// Send course assigned notification
    func notifyCourseAssigned(
        courseId: String,
        courseName: String,
        recipientIds: [UUID],
        deadline: Date?
    ) async throws
    
    /// Send test reminder
    func notifyTestReminder(
        testId: String,
        testName: String,
        recipientIds: [UUID],
        daysLeft: Int
    ) async throws
    
    /// Send certificate earned notification
    func notifyCertificateEarned(
        certificateId: String,
        courseName: String,
        recipientId: UUID
    ) async throws
    
    /// Send achievement unlocked notification
    func notifyAchievementUnlocked(
        achievementName: String,
        description: String,
        recipientId: UUID
    ) async throws
    
    /// Send onboarding task notification
    func notifyOnboardingTask(
        taskId: String,
        taskName: String,
        recipientId: UUID,
        isOverdue: Bool
    ) async throws
}

// MARK: - Supporting Types

// NotificationStats is now defined in NotificationModels.swift

// MARK: - Errors

/// Notification service errors
public enum NotificationServiceError: LocalizedError {
    case notificationNotFound
    case invalidRecipient
    case templateNotFound
    case pushNotEnabled
    case quotaExceeded
    case invalidToken
    case networkError(Error)
    
    public var errorDescription: String? {
        switch self {
        case .notificationNotFound:
            return "Уведомление не найдено"
        case .invalidRecipient:
            return "Недействительный получатель"
        case .templateNotFound:
            return "Шаблон уведомления не найден"
        case .pushNotEnabled:
            return "Push-уведомления отключены"
        case .quotaExceeded:
            return "Превышен лимит уведомлений"
        case .invalidToken:
            return "Недействительный токен устройства"
        case .networkError(let error):
            return "Ошибка сети: \(error.localizedDescription)"
        }
    }
} 