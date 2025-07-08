//
//  PushNotificationServiceProtocol.swift
//  LMS
//
//  Created on Sprint 41 Day 1 - Push Notification Service Interface
//

import Foundation
import UIKit
import UserNotifications

/// Protocol for handling push notifications
public protocol PushNotificationServiceProtocol {
    
    // MARK: - Permission Management
    
    /// Request push notification permissions
    func requestAuthorization() async throws -> Bool
    
    /// Check current authorization status
    func getAuthorizationStatus() async -> UNAuthorizationStatus
    
    /// Check if push notifications are enabled
    func isEnabled() async -> Bool
    
    // MARK: - Token Management
    
    /// Register device token with backend
    func registerDeviceToken(_ token: Data) async throws
    
    /// Handle failed registration
    func handleRegistrationError(_ error: Error)
    
    /// Get current device token
    func getCurrentToken() -> String?
    
    // MARK: - Local Notifications
    
    /// Schedule local notification
    func scheduleLocalNotification(
        _ notification: Notification,
        triggerDate: Date?
    ) async throws -> String
    
    /// Cancel scheduled notification
    func cancelScheduledNotification(identifier: String) async throws
    
    /// Cancel all scheduled notifications
    func cancelAllScheduledNotifications() async throws
    
    /// Get pending notifications
    func getPendingNotifications() async -> [UNNotificationRequest]
    
    // MARK: - Remote Notifications
    
    /// Handle received remote notification
    func handleRemoteNotification(
        _ userInfo: [AnyHashable: Any],
        completionHandler: @escaping (UIBackgroundFetchResult) -> Void
    )
    
    /// Handle notification response (user action)
    func handleNotificationResponse(
        _ response: UNNotificationResponse,
        completionHandler: @escaping () -> Void
    )
    
    // MARK: - Rich Notifications
    
    /// Create notification content with attachments
    func createRichContent(
        from notification: Notification
    ) async throws -> UNMutableNotificationContent
    
    /// Download and attach media
    func attachMedia(
        to content: UNMutableNotificationContent,
        from url: URL
    ) async throws
    
    // MARK: - Categories & Actions
    
    /// Register notification categories and actions
    func registerCategories()
    
    /// Handle custom action
    func handleAction(
        _ actionIdentifier: String,
        for notificationId: String,
        withResponseInfo responseInfo: [String: Any]?
    ) async throws
    
    // MARK: - Badge Management
    
    /// Update app badge
    func updateBadge(count: Int) async
    
    /// Clear badge
    func clearBadge() async
    
    // MARK: - Quiet Hours
    
    /// Check if notification should be delivered based on quiet hours
    func shouldDeliverNotification(
        _ notification: Notification,
        preferences: NotificationPreferences
    ) -> Bool
    
    /// Schedule notification respecting quiet hours
    func scheduleRespectingQuietHours(
        _ notification: Notification,
        preferences: NotificationPreferences
    ) async throws -> String?
}

// MARK: - Notification Actions

/// Predefined notification actions
public enum NotificationAction: String, CaseIterable {
    case open = "OPEN_ACTION"
    case dismiss = "DISMISS_ACTION"
    case reply = "REPLY_ACTION"
    case complete = "COMPLETE_ACTION"
    case remind = "REMIND_ACTION"
    
    var title: String {
        switch self {
        case .open: return "Открыть"
        case .dismiss: return "Отклонить"
        case .reply: return "Ответить"
        case .complete: return "Выполнено"
        case .remind: return "Напомнить позже"
        }
    }
    
    var options: UNNotificationActionOptions {
        switch self {
        case .open: return [.foreground]
        case .dismiss: return [.destructive]
        case .reply: return [.authenticationRequired]
        case .complete: return []
        case .remind: return []
        }
    }
} 