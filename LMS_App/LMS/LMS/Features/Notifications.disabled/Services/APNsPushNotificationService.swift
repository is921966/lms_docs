//
//  APNsPushNotificationService.swift
//  LMS
//
//  Created on Sprint 41 Day 4 - Real Push Notification Service
//

import Foundation
import UIKit
import UserNotifications

/// Real implementation of push notification service using Apple Push Notification service
@MainActor
public final class APNsPushNotificationService: NSObject, PushNotificationServiceProtocol {
    
    // MARK: - Properties
    
    private var currentToken: String?
    private let notificationCenter = UNUserNotificationCenter.current()
    private let logger: Logger
    private var authorizationStatus: UNAuthorizationStatus = .notDetermined
    
    // MARK: - Singleton
    
    public static let shared = APNsPushNotificationService()
    
    // MARK: - Initialization
    
    private override init() {
        self.logger = Logger.shared
        super.init()
        
        // Set delegate
        notificationCenter.delegate = self
        
        // Check initial authorization status
        Task {
            await updateAuthorizationStatus()
        }
    }
    
    // MARK: - Permission Management
    
    public func requestAuthorization() async throws -> Bool {
        let options: UNAuthorizationOptions = [.alert, .badge, .sound, .providesAppNotificationSettings]
        
        do {
            let granted = try await notificationCenter.requestAuthorization(options: options)
            await updateAuthorizationStatus()
            
            if granted {
                // Register for remote notifications
                await registerForRemoteNotifications()
            }
            
            logger.info("Push notification authorization: \(granted ? "granted" : "denied")")
            return granted
            
        } catch {
            logger.error("Failed to request push notification authorization", error: error)
            throw error
        }
    }
    
    public func getAuthorizationStatus() async -> UNAuthorizationStatus {
        await updateAuthorizationStatus()
        return authorizationStatus
    }
    
    public func isEnabled() async -> Bool {
        let status = await getAuthorizationStatus()
        return status == .authorized || status == .provisional
    }
    
    // MARK: - Token Management
    
    public func registerDeviceToken(_ token: Data) async throws {
        let tokenString = token.map { String(format: "%02.2hhx", $0) }.joined()
        currentToken = tokenString
        
        logger.info("Device token registered: \(tokenString)")
        
        // Send to backend
        let deviceId = UIDevice.current.identifierForVendor?.uuidString ?? UUID().uuidString
        let request = RegisterPushTokenRequest(
            token: tokenString,
            deviceId: deviceId,
            platform: .iOS,
            environment: isProduction() ? .production : .development
        )
        
        do {
            let apiService = NotificationAPIService()
            _ = try await apiService.registerPushToken(request)
            logger.info("Push token sent to backend successfully")
        } catch {
            logger.error("Failed to send push token to backend", error: error)
            throw error
        }
    }
    
    public func handleRegistrationError(_ error: Error) {
        logger.error("Push notification registration failed", error: error)
        currentToken = nil
    }
    
    public func getCurrentToken() -> String? {
        return currentToken
    }
    
    // MARK: - Local Notifications
    
    public func scheduleLocalNotification(
        _ notification: Notification,
        triggerDate: Date?
    ) async throws -> String {
        let content = try await createRichContent(from: notification)
        
        // Create trigger
        let trigger: UNNotificationTrigger?
        if let triggerDate = triggerDate {
            let timeInterval = triggerDate.timeIntervalSinceNow
            if timeInterval > 0 {
                trigger = UNTimeIntervalNotificationTrigger(
                    timeInterval: timeInterval,
                    repeats: false
                )
            } else {
                // If date is in the past, trigger immediately
                trigger = nil
            }
        } else {
            // Immediate delivery
            trigger = nil
        }
        
        // Create request
        let identifier = notification.id.uuidString
        let request = UNNotificationRequest(
            identifier: identifier,
            content: content,
            trigger: trigger
        )
        
        // Schedule
        try await notificationCenter.add(request)
        
        logger.info("Scheduled local notification: \(identifier)")
        return identifier
    }
    
    public func cancelScheduledNotification(identifier: String) async throws {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [identifier])
        logger.info("Cancelled scheduled notification: \(identifier)")
    }
    
    public func cancelAllScheduledNotifications() async throws {
        notificationCenter.removeAllPendingNotificationRequests()
        logger.info("Cancelled all scheduled notifications")
    }
    
    public func getPendingNotifications() async -> [UNNotificationRequest] {
        return await notificationCenter.pendingNotificationRequests()
    }
    
    // MARK: - Remote Notifications
    
    public func handleRemoteNotification(
        _ userInfo: [AnyHashable: Any],
        completionHandler: @escaping (UIBackgroundFetchResult) -> Void
    ) {
        logger.info("Handling remote notification")
        
        // Process notification data
        Task {
            do {
                // Parse notification from userInfo
                if let notification = parseNotification(from: userInfo) {
                    // Save to local storage
                    await NotificationService.shared.add(notification)
                    
                    // Track delivery event
                    try await trackEvent(
                        notificationId: notification.id,
                        type: .delivered
                    )
                    
                    completionHandler(.newData)
                } else {
                    completionHandler(.noData)
                }
            } catch {
                logger.error("Failed to handle remote notification", error: error)
                completionHandler(.failed)
            }
        }
    }
    
    public func handleNotificationResponse(
        _ response: UNNotificationResponse,
        completionHandler: @escaping () -> Void
    ) {
        logger.info("Handling notification response: \(response.actionIdentifier)")
        
        Task {
            // Extract notification ID
            let notificationId = response.notification.request.identifier
            
            // Handle action
            switch response.actionIdentifier {
            case UNNotificationDefaultActionIdentifier:
                // User tapped notification
                await handleNotificationTap(notificationId: notificationId)
                
            case UNNotificationDismissActionIdentifier:
                // User dismissed notification
                try? await trackEvent(
                    notificationId: UUID(uuidString: notificationId) ?? UUID(),
                    type: .dismissed
                )
                
            default:
                // Custom action
                await handleCustomAction(
                    actionIdentifier: response.actionIdentifier,
                    notificationId: notificationId,
                    responseInfo: (response as? UNTextInputNotificationResponse)?.userText
                )
            }
            
            completionHandler()
        }
    }
    
    // MARK: - Rich Notifications
    
    public func createRichContent(
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
        
        // Category
        content.categoryIdentifier = getCategoryIdentifier(for: notification.type)
        
        // User info
        var userInfo: [String: Any] = [
            "notificationId": notification.id.uuidString,
            "type": notification.type.rawValue,
            "userId": notification.userId.uuidString
        ]
        
        if let data = notification.data {
            userInfo.merge(data) { _, new in new }
        }
        
        content.userInfo = userInfo
        
        // Thread identifier for grouping
        content.threadIdentifier = notification.type.rawValue
        
        // Attachments
        if let imageUrl = notification.metadata?.imageUrl,
           let url = URL(string: imageUrl) {
            try await attachMedia(to: content, from: url)
        }
        
        return content
    }
    
    public func attachMedia(
        to content: UNMutableNotificationContent,
        from url: URL
    ) async throws {
        // Download media
        let (data, _) = try await URLSession.shared.data(from: url)
        
        // Save to temporary file
        let tempURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension(url.pathExtension)
        
        try data.write(to: tempURL)
        
        // Create attachment
        let attachment = try UNNotificationAttachment(
            identifier: UUID().uuidString,
            url: tempURL,
            options: nil
        )
        
        content.attachments = [attachment]
    }
    
    // MARK: - Categories & Actions
    
    public func registerCategories() {
        var categories = Set<UNNotificationCategory>()
        
        for category in NotificationCategory.allCases {
            let actions = category.actions.map { actionData -> UNNotificationAction in
                if let textInput = actionData.textInput {
                    return UNTextInputNotificationAction(
                        identifier: actionData.identifier,
                        title: actionData.title,
                        options: convertOptions(actionData.options),
                        textInputButtonTitle: textInput.title,
                        textInputPlaceholder: textInput.placeholder
                    )
                } else {
                    return UNNotificationAction(
                        identifier: actionData.identifier,
                        title: actionData.title,
                        options: convertOptions(actionData.options)
                    )
                }
            }
            
            let notificationCategory = UNNotificationCategory(
                identifier: category.rawValue,
                actions: actions,
                intentIdentifiers: [],
                options: []
            )
            
            categories.insert(notificationCategory)
        }
        
        notificationCenter.setNotificationCategories(categories)
        logger.info("Registered \(categories.count) notification categories")
    }
    
    public func handleAction(
        _ actionIdentifier: String,
        for notificationId: String,
        withResponseInfo responseInfo: [String: Any]?
    ) async throws {
        logger.info("Handling action: \(actionIdentifier) for notification: \(notificationId)")
        
        // Track action
        if let uuid = UUID(uuidString: notificationId) {
            try await trackEvent(
                notificationId: uuid,
                type: .actionTaken,
                metadata: ["action": actionIdentifier]
            )
        }
        
        // Route to appropriate handler based on action
        switch actionIdentifier {
        case "view_course", "start_learning":
            await navigateToCourse(notificationId: notificationId)
            
        case "start_test":
            await navigateToTest(notificationId: notificationId)
            
        case "complete_task":
            await completeTask(notificationId: notificationId)
            
        case "reply":
            if let text = responseInfo?["reply_text"] as? String {
                await sendReply(text: text, notificationId: notificationId)
            }
            
        default:
            logger.warning("Unknown action: \(actionIdentifier)")
        }
    }
    
    // MARK: - Badge Management
    
    public func updateBadge(count: Int) async {
        await UIApplication.shared.setBadgeCount(count)
        logger.debug("Updated badge count to: \(count)")
    }
    
    public func clearBadge() async {
        await UIApplication.shared.setBadgeCount(0)
        logger.debug("Cleared badge")
    }
    
    // MARK: - Quiet Hours
    
    public func shouldDeliverNotification(
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
    
    public func scheduleRespectingQuietHours(
        _ notification: Notification,
        preferences: NotificationPreferences
    ) async throws -> String? {
        // Check if should deliver now
        if shouldDeliverNotification(notification, preferences: preferences) {
            return try await scheduleLocalNotification(notification, triggerDate: nil)
        }
        
        // Schedule for after quiet hours
        if let quietHours = preferences.quietHours, quietHours.isEnabled {
            let nextAvailableTime = calculateNextAvailableTime(quietHours: quietHours)
            return try await scheduleLocalNotification(notification, triggerDate: nextAvailableTime)
        }
        
        return nil
    }
    
    // MARK: - Private Methods
    
    private func updateAuthorizationStatus() async {
        let settings = await notificationCenter.notificationSettings()
        authorizationStatus = settings.authorizationStatus
    }
    
    private func registerForRemoteNotifications() async {
        await UIApplication.shared.registerForRemoteNotifications()
    }
    
    private func isProduction() -> Bool {
        #if DEBUG
        return false
        #else
        return true
        #endif
    }
    
    private func parseNotification(from userInfo: [AnyHashable: Any]) -> Notification? {
        guard let aps = userInfo["aps"] as? [String: Any],
              let alert = aps["alert"] as? [String: Any],
              let title = alert["title"] as? String,
              let body = alert["body"] as? String,
              let typeString = userInfo["type"] as? String,
              let type = NotificationType(rawValue: typeString),
              let userIdString = userInfo["userId"] as? String,
              let userId = UUID(uuidString: userIdString) else {
            return nil
        }
        
        let notificationId = (userInfo["notificationId"] as? String)
            .flatMap { UUID(uuidString: $0) } ?? UUID()
        
        return Notification(
            id: notificationId,
            userId: userId,
            type: type,
            title: title,
            body: body,
            data: userInfo["data"] as? [String: String],
            channels: [.push]
        )
    }
    
    private func getCategoryIdentifier(for type: NotificationType) -> String {
        switch type {
        case .courseAssigned, .courseCompleted:
            return NotificationCategory.course.rawValue
        case .testAvailable, .testDeadline, .testReminder, .testCompleted:
            return NotificationCategory.test.rawValue
        case .taskAssigned, .onboardingTask:
            return NotificationCategory.task.rawValue
        case .adminMessage, .systemMessage:
            return NotificationCategory.message.rawValue
        case .achievementUnlocked, .certificateIssued, .certificateEarned:
            return NotificationCategory.achievement.rawValue
        case .feedActivity, .feedMention:
            return NotificationCategory.feed.rawValue
        case .reminderDaily, .reminderWeekly:
            return NotificationCategory.reminder.rawValue
        default:
            return ""
        }
    }
    
    private func convertOptions(_ options: NotificationActionOptions) -> UNNotificationActionOptions {
        var actionOptions: UNNotificationActionOptions = []
        
        if options.contains(.foreground) {
            actionOptions.insert(.foreground)
        }
        if options.contains(.destructive) {
            actionOptions.insert(.destructive)
        }
        if options.contains(.authenticationRequired) {
            actionOptions.insert(.authenticationRequired)
        }
        
        return actionOptions
    }
    
    private func calculateNextAvailableTime(quietHours: QuietHours) -> Date? {
        let calendar = Calendar.current
        let now = Date()
        
        guard let endHour = quietHours.endTime.hour,
              let endMinute = quietHours.endTime.minute else {
            return nil
        }
        
        var dateComponents = calendar.dateComponents([.year, .month, .day], from: now)
        dateComponents.hour = endHour
        dateComponents.minute = endMinute
        
        if let scheduledDate = calendar.date(from: dateComponents) {
            // If the end time has already passed today, schedule for tomorrow
            if scheduledDate <= now {
                return calendar.date(byAdding: .day, value: 1, to: scheduledDate)
            }
            return scheduledDate
        }
        
        return nil
    }
    
    // MARK: - Action Handlers
    
    private func handleNotificationTap(notificationId: String) async {
        // Mark as read
        if let uuid = UUID(uuidString: notificationId) {
            try? await NotificationService.shared.markAsRead(uuid)
            try? await trackEvent(notificationId: uuid, type: .opened)
        }
        
        // Navigate to appropriate screen
        // This would be handled by the app's navigation system
        logger.info("User tapped notification: \(notificationId)")
    }
    
    private func handleCustomAction(
        actionIdentifier: String,
        notificationId: String,
        responseInfo: String?
    ) async {
        var info: [String: Any] = [:]
        if let responseInfo = responseInfo {
            info["response"] = responseInfo
        }
        
        try? await handleAction(
            actionIdentifier,
            for: notificationId,
            withResponseInfo: info
        )
    }
    
    private func navigateToCourse(notificationId: String) async {
        logger.info("Navigate to course from notification: \(notificationId)")
        // Implementation would navigate to course screen
    }
    
    private func navigateToTest(notificationId: String) async {
        logger.info("Navigate to test from notification: \(notificationId)")
        // Implementation would navigate to test screen
    }
    
    private func completeTask(notificationId: String) async {
        logger.info("Complete task from notification: \(notificationId)")
        // Implementation would mark task as complete
    }
    
    private func sendReply(text: String, notificationId: String) async {
        logger.info("Send reply '\(text)' from notification: \(notificationId)")
        // Implementation would send reply
    }
    
    private func trackEvent(
        notificationId: UUID,
        type: NotificationEventType,
        metadata: [String: String]? = nil
    ) async throws {
        let event = NotificationEvent(
            notificationId: notificationId,
            type: type,
            metadata: metadata
        )
        
        let apiService = NotificationAPIService()
        try await apiService.trackNotificationEvent(
            notificationId: notificationId,
            event: event
        )
    }
}

// MARK: - UNUserNotificationCenterDelegate

extension APNsPushNotificationService: UNUserNotificationCenterDelegate {
    
    public func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        // Show notification even when app is in foreground
        let options: UNNotificationPresentationOptions = [.banner, .sound, .badge]
        completionHandler(options)
    }
    
    public func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        handleNotificationResponse(response, completionHandler: completionHandler)
    }
    
    public func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        openSettingsFor notification: UNNotification?
    ) {
        logger.info("User requested notification settings")
        // Open app's notification settings screen
    }
} 