//
//  NotificationModelsTests.swift
//  LMSTests
//
//  Tests for Notification models - Sprint 41 Day 1
//

import XCTest
@testable import LMS

final class NotificationModelsTests: XCTestCase {
    
    // MARK: - NotificationType Tests
    
    func testNotificationTypeDisplayNames() {
        XCTAssertEqual(NotificationType.courseAssigned.displayName, "Новый курс")
        XCTAssertEqual(NotificationType.testDeadline.displayName, "Дедлайн теста")
        XCTAssertEqual(NotificationType.achievementUnlocked.displayName, "Достижение получено")
    }
    
    func testNotificationTypeIcons() {
        XCTAssertEqual(NotificationType.courseAssigned.icon, "book.circle")
        XCTAssertEqual(NotificationType.testAvailable.icon, "doc.text")
        XCTAssertEqual(NotificationType.certificateIssued.icon, "rosette")
    }
    
    func testNotificationTypeDefaultPriorities() {
        XCTAssertEqual(NotificationType.testDeadline.defaultPriority, .high)
        XCTAssertEqual(NotificationType.courseAssigned.defaultPriority, .medium)
        XCTAssertEqual(NotificationType.achievementUnlocked.defaultPriority, .low)
    }
    
    // MARK: - NotificationChannel Tests
    
    func testNotificationChannelDisplayNames() {
        XCTAssertEqual(NotificationChannel.push.displayName, "Push-уведомления")
        XCTAssertEqual(NotificationChannel.email.displayName, "Email")
        XCTAssertEqual(NotificationChannel.inApp.displayName, "В приложении")
    }
    
    // MARK: - NotificationPriority Tests
    
    func testNotificationPriorityComparison() {
        XCTAssertTrue(NotificationPriority.low < NotificationPriority.medium)
        XCTAssertTrue(NotificationPriority.medium < NotificationPriority.high)
        XCTAssertTrue(NotificationPriority.high < NotificationPriority.urgent)
    }
    
    // MARK: - Notification Tests
    
    func testNotificationInitialization() {
        let userId = UUID()
        let notification = Notification(
            userId: userId,
            type: .courseAssigned,
            title: "Новый курс доступен",
            body: "Вам назначен курс 'Swift Programming'"
        )
        
        XCTAssertNotNil(notification.id)
        XCTAssertEqual(notification.userId, userId)
        XCTAssertEqual(notification.type, .courseAssigned)
        XCTAssertEqual(notification.title, "Новый курс доступен")
        XCTAssertEqual(notification.body, "Вам назначен курс 'Swift Programming'")
        XCTAssertEqual(notification.channels, [.inApp])
        XCTAssertEqual(notification.priority, .medium)
        XCTAssertFalse(notification.isRead)
        XCTAssertNil(notification.readAt)
        XCTAssertNotNil(notification.createdAt)
        XCTAssertNil(notification.expiresAt)
    }
    
    func testNotificationMarkAsRead() {
        var notification = Notification(
            userId: UUID(),
            type: .courseAssigned,
            title: "Test",
            body: "Test body"
        )
        
        XCTAssertFalse(notification.isRead)
        XCTAssertNil(notification.readAt)
        
        notification.markAsRead()
        
        XCTAssertTrue(notification.isRead)
        XCTAssertNotNil(notification.readAt)
        
        // Mark as read again should not change readAt
        let firstReadAt = notification.readAt
        notification.markAsRead()
        XCTAssertEqual(notification.readAt, firstReadAt)
    }
    
    func testNotificationExpiration() {
        let expiredNotification = Notification(
            userId: UUID(),
            type: .testDeadline,
            title: "Test",
            body: "Test",
            expiresAt: Date().addingTimeInterval(-3600) // 1 hour ago
        )
        
        let activeNotification = Notification(
            userId: UUID(),
            type: .testDeadline,
            title: "Test",
            body: "Test",
            expiresAt: Date().addingTimeInterval(3600) // 1 hour from now
        )
        
        let neverExpiresNotification = Notification(
            userId: UUID(),
            type: .systemMessage,
            title: "Test",
            body: "Test",
            expiresAt: nil
        )
        
        XCTAssertTrue(expiredNotification.isExpired)
        XCTAssertFalse(activeNotification.isExpired)
        XCTAssertFalse(neverExpiresNotification.isExpired)
    }
    
    func testNotificationWithMetadata() {
        let metadata = NotificationMetadata(
            imageUrl: "https://example.com/image.jpg",
            actionUrl: "lms://course/123",
            actionTitle: "Открыть курс",
            badge: 5,
            sound: "notification.wav"
        )
        
        let notification = Notification(
            userId: UUID(),
            type: .courseAssigned,
            title: "Test",
            body: "Test",
            metadata: metadata
        )
        
        XCTAssertNotNil(notification.metadata)
        XCTAssertEqual(notification.metadata?.imageUrl, "https://example.com/image.jpg")
        XCTAssertEqual(notification.metadata?.actionUrl, "lms://course/123")
        XCTAssertEqual(notification.metadata?.badge, 5)
    }
    
    // MARK: - PushToken Tests
    
    func testPushTokenInitialization() {
        let userId = UUID()
        let token = PushToken(
            userId: userId,
            token: "test-token-123",
            deviceId: "device-123"
        )
        
        XCTAssertNotNil(token.id)
        XCTAssertEqual(token.userId, userId)
        XCTAssertEqual(token.token, "test-token-123")
        XCTAssertEqual(token.deviceId, "device-123")
        XCTAssertEqual(token.platform, .iOS)
        XCTAssertEqual(token.environment, .production)
        XCTAssertTrue(token.isActive)
        XCTAssertNotNil(token.createdAt)
        XCTAssertNotNil(token.lastUsedAt)
    }
    
    func testPushTokenUpdateLastUsed() {
        var token = PushToken(
            userId: UUID(),
            token: "test-token",
            deviceId: "device-123",
            lastUsedAt: Date().addingTimeInterval(-3600)
        )
        
        let originalLastUsed = token.lastUsedAt
        Thread.sleep(forTimeInterval: 0.1)
        token.updateLastUsed()
        
        XCTAssertGreaterThan(token.lastUsedAt, originalLastUsed)
    }
    
    func testPushTokenDeactivate() {
        var token = PushToken(
            userId: UUID(),
            token: "test-token",
            deviceId: "device-123"
        )
        
        XCTAssertTrue(token.isActive)
        token.deactivate()
        XCTAssertFalse(token.isActive)
    }
    
    // MARK: - NotificationPreferences Tests
    
    func testNotificationPreferencesInitialization() {
        let userId = UUID()
        let preferences = NotificationPreferences(userId: userId)
        
        XCTAssertEqual(preferences.userId, userId)
        XCTAssertTrue(preferences.isEnabled)
        XCTAssertTrue(preferences.channelPreferences.isEmpty)
        XCTAssertNil(preferences.quietHours)
        XCTAssertTrue(preferences.frequencyLimits.isEmpty)
        XCTAssertNotNil(preferences.updatedAt)
    }
    
    func testNotificationPreferencesChannels() {
        let preferences = NotificationPreferences(
            userId: UUID(),
            channelPreferences: [
                .courseAssigned: [.push, .email],
                .testDeadline: [.push, .inApp, .email]
            ]
        )
        
        XCTAssertEqual(preferences.channels(for: .courseAssigned), [.push, .email])
        XCTAssertEqual(preferences.channels(for: .testDeadline), [.push, .inApp, .email])
        XCTAssertEqual(preferences.channels(for: .achievementUnlocked), [.inApp]) // Default
    }
    
    func testNotificationPreferencesIsChannelEnabled() {
        let preferences = NotificationPreferences(
            userId: UUID(),
            channelPreferences: [
                .courseAssigned: [.push, .email]
            ]
        )
        
        XCTAssertTrue(preferences.isChannelEnabled(.push, for: .courseAssigned))
        XCTAssertTrue(preferences.isChannelEnabled(.email, for: .courseAssigned))
        XCTAssertFalse(preferences.isChannelEnabled(.sms, for: .courseAssigned))
        
        // Test with disabled preferences
        var disabledPreferences = preferences
        disabledPreferences.isEnabled = false
        XCTAssertFalse(disabledPreferences.isChannelEnabled(.push, for: .courseAssigned))
    }
    
    func testNotificationPreferencesUpdateChannel() {
        var preferences = NotificationPreferences(userId: UUID())
        
        // Enable push for course assigned
        preferences.updateChannel(.push, enabled: true, for: .courseAssigned)
        XCTAssertTrue(preferences.isChannelEnabled(.push, for: .courseAssigned))
        
        // Enable email for course assigned
        preferences.updateChannel(.email, enabled: true, for: .courseAssigned)
        XCTAssertTrue(preferences.isChannelEnabled(.email, for: .courseAssigned))
        XCTAssertTrue(preferences.isChannelEnabled(.push, for: .courseAssigned))
        
        // Disable push for course assigned
        preferences.updateChannel(.push, enabled: false, for: .courseAssigned)
        XCTAssertFalse(preferences.isChannelEnabled(.push, for: .courseAssigned))
        XCTAssertTrue(preferences.isChannelEnabled(.email, for: .courseAssigned))
    }
    
    // MARK: - QuietHours Tests
    
    func testQuietHoursIsActive() {
        let quietHours = QuietHours(
            isEnabled: true,
            startTime: DateComponents(hour: 22, minute: 0),
            endTime: DateComponents(hour: 8, minute: 0)
        )
        
        // Test during quiet hours (23:00)
        let calendar = Calendar.current
        let nightTime = calendar.date(from: DateComponents(year: 2025, month: 1, day: 1, hour: 23, minute: 0))!
        XCTAssertTrue(quietHours.isActive(at: nightTime))
        
        // Test during quiet hours (7:00)
        let earlyMorning = calendar.date(from: DateComponents(year: 2025, month: 1, day: 1, hour: 7, minute: 0))!
        XCTAssertTrue(quietHours.isActive(at: earlyMorning))
        
        // Test outside quiet hours (12:00)
        let noon = calendar.date(from: DateComponents(year: 2025, month: 1, day: 1, hour: 12, minute: 0))!
        XCTAssertFalse(quietHours.isActive(at: noon))
        
        // Test with disabled quiet hours
        var disabledQuietHours = quietHours
        disabledQuietHours.isEnabled = false
        XCTAssertFalse(disabledQuietHours.isActive(at: nightTime))
    }
    
    func testQuietHoursWithinSameDay() {
        let quietHours = QuietHours(
            isEnabled: true,
            startTime: DateComponents(hour: 14, minute: 0),
            endTime: DateComponents(hour: 16, minute: 0)
        )
        
        let calendar = Calendar.current
        
        // Test during quiet hours (15:00)
        let during = calendar.date(from: DateComponents(year: 2025, month: 1, day: 1, hour: 15, minute: 0))!
        XCTAssertTrue(quietHours.isActive(at: during))
        
        // Test outside quiet hours (13:00)
        let before = calendar.date(from: DateComponents(year: 2025, month: 1, day: 1, hour: 13, minute: 0))!
        XCTAssertFalse(quietHours.isActive(at: before))
        
        // Test outside quiet hours (17:00)
        let after = calendar.date(from: DateComponents(year: 2025, month: 1, day: 1, hour: 17, minute: 0))!
        XCTAssertFalse(quietHours.isActive(at: after))
    }
    
    // MARK: - NotificationTemplate Tests
    
    func testNotificationTemplateRender() {
        let template = NotificationTemplate(
            type: .courseAssigned,
            titleTemplate: "Новый курс: {{courseName}}",
            bodyTemplate: "Здравствуйте, {{userName}}! Вам назначен курс '{{courseName}}'. Срок выполнения: {{deadline}}."
        )
        
        let parameters = [
            "userName": "Иван",
            "courseName": "Swift для начинающих",
            "deadline": "15 января 2025"
        ]
        
        let (title, body) = template.render(with: parameters)
        
        XCTAssertEqual(title, "Новый курс: Swift для начинающих")
        XCTAssertEqual(body, "Здравствуйте, Иван! Вам назначен курс 'Swift для начинающих'. Срок выполнения: 15 января 2025.")
    }
    
    func testNotificationTemplateWithMissingParameters() {
        let template = NotificationTemplate(
            type: .courseAssigned,
            titleTemplate: "Курс {{courseName}} от {{instructor}}",
            bodyTemplate: "Детали: {{details}}"
        )
        
        let parameters = [
            "courseName": "iOS Development"
            // Missing: instructor, details
        ]
        
        let (title, body) = template.render(with: parameters)
        
        XCTAssertEqual(title, "Курс iOS Development от {{instructor}}")
        XCTAssertEqual(body, "Детали: {{details}}")
    }
    
    // MARK: - Codable Tests
    
    func testNotificationCodable() throws {
        let notification = Notification(
            userId: UUID(),
            type: .courseAssigned,
            title: "Test",
            body: "Test body",
            data: ["courseId": "123"],
            channels: [.push, .email],
            priority: .high,
            metadata: NotificationMetadata(
                imageUrl: "https://example.com/image.jpg",
                badge: 3
            )
        )
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(notification)
        
        let decoder = JSONDecoder()
        let decodedNotification = try decoder.decode(Notification.self, from: data)
        
        XCTAssertEqual(notification.id, decodedNotification.id)
        XCTAssertEqual(notification.userId, decodedNotification.userId)
        XCTAssertEqual(notification.type, decodedNotification.type)
        XCTAssertEqual(notification.title, decodedNotification.title)
        XCTAssertEqual(notification.channels, decodedNotification.channels)
        XCTAssertEqual(notification.priority, decodedNotification.priority)
        XCTAssertEqual(notification.metadata?.imageUrl, decodedNotification.metadata?.imageUrl)
    }
    
    func testPushTokenCodable() throws {
        let token = PushToken(
            userId: UUID(),
            token: "test-token",
            deviceId: "device-123",
            platform: .iOS,
            environment: .production
        )
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(token)
        
        let decoder = JSONDecoder()
        let decodedToken = try decoder.decode(PushToken.self, from: data)
        
        XCTAssertEqual(token.id, decodedToken.id)
        XCTAssertEqual(token.userId, decodedToken.userId)
        XCTAssertEqual(token.token, decodedToken.token)
        XCTAssertEqual(token.platform, decodedToken.platform)
        XCTAssertEqual(token.environment, decodedToken.environment)
    }
    
    func testNotificationPreferencesCodable() throws {
        let preferences = NotificationPreferences(
            userId: UUID(),
            channelPreferences: [
                .courseAssigned: [.push, .email],
                .testDeadline: [.push, .inApp]
            ],
            quietHours: QuietHours(
                isEnabled: true,
                startTime: DateComponents(hour: 22, minute: 0),
                endTime: DateComponents(hour: 8, minute: 0)
            ),
            frequencyLimits: [
                .adminMessage: FrequencyLimit(maxPerDay: 5)
            ]
        )
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(preferences)
        
        let decoder = JSONDecoder()
        let decodedPreferences = try decoder.decode(NotificationPreferences.self, from: data)
        
        XCTAssertEqual(preferences.userId, decodedPreferences.userId)
        XCTAssertEqual(preferences.channelPreferences[.courseAssigned], decodedPreferences.channelPreferences[.courseAssigned])
        XCTAssertEqual(preferences.quietHours?.isEnabled, decodedPreferences.quietHours?.isEnabled)
        XCTAssertEqual(preferences.frequencyLimits[.adminMessage]?.maxPerDay, decodedPreferences.frequencyLimits[.adminMessage]?.maxPerDay)
    }
} 