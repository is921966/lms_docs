//
//  MockPushNotificationService.swift
//  LMS
//
//  Created on Sprint 41 Day 3 - Mock Push Notification Service
//

import Foundation
import UIKit
import UserNotifications

/// Mock implementation of PushNotificationServiceProtocol for testing
final class MockPushNotificationService: PushNotificationServiceProtocol {
    
    // MARK: - Properties
    
    private var isAuthorized = false
    private var currentToken: String?
    private var scheduledNotifications: [String: UNNotificationRequest] = [:]
    private var registeredCategories: Set<String> = []
    private var badgeCount = 0
    
    private let repository: NotificationRepositoryProtocol
    
    // MARK: - Initialization
    
    init(repository: NotificationRepositoryProtocol? = nil) {
        self.repository = repository ?? MockNotificationRepository()
        setupMockToken()
    }
    
    // MARK: - Permission Management
    
    func requestAuthorization() async throws -> Bool {
        // Simulate permission request
        try await Task.sleep(nanoseconds: 100_000_000) // 0.1 second
        isAuthorized = true
        return isAuthorized
    }
    
    func getAuthorizationStatus() async -> UNAuthorizationStatus {
        return isAuthorized ? .authorized : .notDetermined
    }
    
    func isEnabled() async -> Bool {
        return isAuthorized
    }
    
    // MARK: - Token Management
    
    func registerDeviceToken(_ token: Data) async throws {
        let tokenString = token.map { String(format: "%02.2hhx", $0) }.joined()
        currentToken = tokenString
        
        // Save to repository
        let pushToken = PushToken(
            userId: getCurrentUserId(),
            token: tokenString,
            deviceId: getDeviceId()
        )
        
        _ = try await repository.savePushToken(pushToken)
        print("Mock: Device token registered: \(tokenString)")
    }
    
    func handleRegistrationError(_ error: Error) {
        print("Mock: Registration error: \(error.localizedDescription)")
        currentToken = nil
    }
    
    func getCurrentToken() -> String? {
        return currentToken
    }
    
    // MARK: - Local Notifications
    
    func scheduleLocalNotification(
        _ notification: Notification,
        triggerDate: Date?
    ) async throws -> String {
        let content = try await createRichContent(from: notification)
        
        // Create trigger
        let trigger: UNNotificationTrigger?
        if let triggerDate = triggerDate {
            let dateComponents = Calendar.current.dateComponents(
                [.year, .month, .day, .hour, .minute],
                from: triggerDate
            )
            trigger = UNCalendarNotificationTrigger(
                dateMatching: dateComponents,
                repeats: false
            )
        } else {
            trigger = nil
        }
        
        // Create request
        let identifier = notification.id.uuidString
        let request = UNNotificationRequest(
            identifier: identifier,
            content: content,
            trigger: trigger
        )
        
        // Store in mock storage
        scheduledNotifications[identifier] = request
        
        print("Mock: Scheduled notification \(identifier)")
        return identifier
    }
    
    func cancelScheduledNotification(identifier: String) async throws {
        scheduledNotifications.removeValue(forKey: identifier)
        print("Mock: Cancelled notification \(identifier)")
    }
    
    func cancelAllScheduledNotifications() async throws {
        scheduledNotifications.removeAll()
        print("Mock: Cancelled all notifications")
    }
    
    func getPendingNotifications() async -> [UNNotificationRequest] {
        return Array(scheduledNotifications.values)
    }
    
    // MARK: - Remote Notifications
    
    func handleRemoteNotification(
        _ userInfo: [AnyHashable: Any],
        completionHandler: @escaping (UIBackgroundFetchResult) -> Void
    ) {
        print("Mock: Handling remote notification: \(userInfo)")
        
        // Simulate processing
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.5) {
            // Check if there's new data
            if userInfo["hasNewData"] as? Bool == true {
                completionHandler(.newData)
            } else {
                completionHandler(.noData)
            }
        }
    }
    
    func handleNotificationResponse(
        _ response: UNNotificationResponse,
        completionHandler: @escaping () -> Void
    ) {
        print("Mock: Handling notification response")
        print("  - Action: \(response.actionIdentifier)")
        print("  - Notification: \(response.notification.request.identifier)")
        
        // Handle different actions
        switch response.actionIdentifier {
        case UNNotificationDefaultActionIdentifier:
            print("  - User tapped notification")
        case UNNotificationDismissActionIdentifier:
            print("  - User dismissed notification")
        default:
            print("  - Custom action: \(response.actionIdentifier)")
        }
        
        completionHandler()
    }
    
    // MARK: - Rich Notifications
    
    func createRichContent(
        from notification: Notification
    ) async throws -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        
        // Basic content
        content.title = notification.title
        content.body = notification.body
        content.sound = .default
        
        // Badge
        if let badge = notification.metadata?.badge {
            content.badge = NSNumber(value: badge)
        }
        
        // Category based on type
        content.categoryIdentifier = getCategoryIdentifier(for: notification.type)
        
        // User info
        var userInfo: [String: Any] = [
            "notificationId": notification.id.uuidString,
            "type": notification.type.rawValue
        ]
        
        if let data = notification.data {
            userInfo.merge(data) { _, new in new }
        }
        
        content.userInfo = userInfo
        
        // Thread identifier for grouping
        content.threadIdentifier = notification.type.rawValue
        
        return content
    }
    
    func attachMedia(
        to content: UNMutableNotificationContent,
        from url: URL
    ) async throws {
        print("Mock: Would attach media from \(url)")
        // In real implementation, would download and attach media
    }
    
    // MARK: - Categories & Actions
    
    func registerCategories() {
        print("Mock: Registering notification categories")
        
        for category in NotificationCategory.allCases {
            registeredCategories.insert(category.rawValue)
            print("  - Registered: \(category.rawValue)")
        }
    }
    
    func handleAction(
        _ actionIdentifier: String,
        for notificationId: String,
        withResponseInfo responseInfo: [String: Any]?
    ) async throws {
        print("Mock: Handling action")
        print("  - Action: \(actionIdentifier)")
        print("  - Notification: \(notificationId)")
        
        if let responseInfo = responseInfo {
            print("  - Response info: \(responseInfo)")
        }
        
        // Simulate action handling
        try await Task.sleep(nanoseconds: 100_000_000) // 0.1 second
    }
    
    // MARK: - Badge Management
    
    func updateBadge(count: Int) async {
        badgeCount = count
        print("Mock: Updated badge to \(count)")
        
        // In real implementation:
        // await UIApplication.shared.setBadgeCount(count)
    }
    
    func clearBadge() async {
        badgeCount = 0
        print("Mock: Cleared badge")
    }
    
    // MARK: - Quiet Hours
    
    func shouldDeliverNotification(
        _ notification: Notification,
        preferences: NotificationPreferences
    ) -> Bool {
        // Check if notifications are enabled
        guard preferences.isEnabled else { return false }
        
        // Check quiet hours
        if preferences.isInQuietHours {
            // Allow urgent notifications during quiet hours if permitted
            if notification.priority == .urgent && (preferences.quietHours?.allowUrgent ?? false) {
                return true
            }
            return false
        }
        
        return true
    }
    
    func scheduleRespectingQuietHours(
        _ notification: Notification,
        preferences: NotificationPreferences
    ) async throws -> String? {
        // Check if should deliver now
        if shouldDeliverNotification(notification, preferences: preferences) {
            return try await scheduleLocalNotification(notification, triggerDate: nil)
        }
        
        // Schedule for after quiet hours
        if let quietHours = preferences.quietHours, quietHours.isEnabled {
            let calendar = Calendar.current
            let now = Date()
            
            // Calculate next available time after quiet hours
            if let endHour = quietHours.endTime.hour,
               let endMinute = quietHours.endTime.minute {
                
                var dateComponents = calendar.dateComponents([.year, .month, .day], from: now)
                dateComponents.hour = endHour
                dateComponents.minute = endMinute
                
                if let scheduledDate = calendar.date(from: dateComponents) {
                    var finalDate = scheduledDate
                    
                    // If the end time has already passed today, schedule for tomorrow
                    if scheduledDate <= now {
                        finalDate = calendar.date(byAdding: .day, value: 1, to: scheduledDate) ?? scheduledDate
                    }
                    
                    return try await scheduleLocalNotification(notification, triggerDate: finalDate)
                }
            }
        }
        
        return nil
    }
    
    // MARK: - Helper Methods
    
    private func setupMockToken() {
        // Generate a mock device token
        let mockToken = UUID().uuidString.replacingOccurrences(of: "-", with: "").lowercased()
        currentToken = mockToken
    }
    
    private func getCurrentUserId() -> UUID {
        // In real app, get from auth service
        return UUID() // Mock user ID
    }
    
    private func getDeviceId() -> String {
        // In real app, get from device
        return UIDevice.current.identifierForVendor?.uuidString ?? "mock-device-id"
    }
    
    private func getCategoryIdentifier(for type: NotificationType) -> String {
        switch type {
        case .courseAssigned, .courseCompleted:
            return NotificationCategory.course.rawValue
        case .testAvailable, .testDeadline, .testReminder:
            return NotificationCategory.test.rawValue
        case .onboardingTask:
            return NotificationCategory.task.rawValue
        case .adminMessage, .systemMessage:
            return NotificationCategory.message.rawValue
        case .achievementUnlocked, .certificateIssued, .certificateEarned:
            return NotificationCategory.achievement.rawValue
        default:
            return ""
        }
    }
} 