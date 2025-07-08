//
//  NotificationE2ETests.swift
//  LMSTests
//
//  Created on Sprint 41 Day 4 - E2E Tests for Notifications
//

import XCTest
@testable import LMS

@MainActor
final class NotificationE2ETests: XCTestCase {
    
    // MARK: - Properties
    
    private var notificationService: NotificationService!
    private var apiService: NotificationAPIService!
    private var pushService: PushNotificationServiceProtocol!
    private var authService: MockAuthService!
    
    // MARK: - Setup
    
    override func setUp() async throws {
        try await super.setUp()
        
        // Setup services
        authService = MockAuthService.shared
        await authService.login(email: "test@example.com", password: "password")
        
        // Use mock services for testing
        let repository = MockNotificationRepository()
        pushService = MockPushNotificationService(repository: repository)
        
        notificationService = NotificationService(
            repository: repository,
            pushService: pushService
        )
        
        apiService = NotificationAPIService()
    }
    
    override func tearDown() async throws {
        await authService.logout()
        notificationService = nil
        apiService = nil
        pushService = nil
        
        try await super.tearDown()
    }
    
    // MARK: - E2E Tests
    
    func testCompleteNotificationFlow() async throws {
        // 1. Request push permission
        let authorized = try await pushService.requestAuthorization()
        XCTAssertTrue(authorized, "Push authorization should be granted")
        
        // 2. Register device token
        let mockToken = Data("mock-token".utf8)
        try await pushService.registerDeviceToken(mockToken)
        
        let currentToken = pushService.getCurrentToken()
        XCTAssertNotNil(currentToken, "Token should be registered")
        
        // 3. Create a notification through service
        let recipientId = authService.currentUser?.id ?? UUID()
        try await notificationService.notifyCourseAssigned(
            courseId: "course-123",
            courseName: "iOS Development",
            recipientIds: [recipientId],
            deadline: Date().addingTimeInterval(7 * 24 * 60 * 60) // 1 week
        )
        
        // 4. Verify notification was created
        try await notificationService.loadNotifications()
        
        await waitForExpectation { [weak self] in
            guard let self = self else { return false }
            return await !self.notificationService._notifications.isEmpty
        }
        
        let notifications = await notificationService._notifications
        XCTAssertEqual(notifications.count, 1, "Should have one notification")
        
        let notification = notifications[0]
        XCTAssertEqual(notification.type, .courseAssigned)
        XCTAssertEqual(notification.title, "Новый курс назначен")
        XCTAssertTrue(notification.body.contains("iOS Development"))
        
        // 5. Test marking as read
        try await notificationService.markAsRead(notification.id)
        
        let updatedNotifications = await notificationService._notifications
        XCTAssertTrue(updatedNotifications[0].isRead, "Notification should be marked as read")
        
        // 6. Test unread count
        let unreadCount = await notificationService.unreadCountValue
        XCTAssertEqual(unreadCount, 0, "Unread count should be 0")
        
        // 7. Test deletion
        try await notificationService.deleteNotification(notification.id)
        
        await waitForExpectation { [weak self] in
            guard let self = self else { return false }
            return await self.notificationService._notifications.isEmpty
        }
        
        let finalNotifications = await notificationService._notifications
        XCTAssertTrue(finalNotifications.isEmpty, "Notification should be deleted")
    }
    
    func testPushNotificationDelivery() async throws {
        // 1. Setup preferences
        var preferences = NotificationPreferences(userId: authService.currentUser?.id ?? UUID())
        preferences.channelPreferences[.testDeadline] = [.push, .inApp]
        try await notificationService.updatePreferences(preferences)
        
        // 2. Send test reminder
        try await notificationService.notifyTestReminder(
            testId: "test-456",
            testName: "Swift Basics",
            recipientIds: [authService.currentUser?.id ?? UUID()],
            daysLeft: 1
        )
        
        // 3. Verify push was scheduled
        let pendingNotifications = await pushService.getPendingNotifications()
        XCTAssertFalse(pendingNotifications.isEmpty, "Should have pending push notification")
        
        // 4. Simulate push notification tap
        let userInfo: [AnyHashable: Any] = [
            "aps": [
                "alert": [
                    "title": "Напоминание о тесте",
                    "body": "Осталось 1 день для прохождения теста 'Swift Basics'"
                ]
            ],
            "type": "test_deadline",
            "userId": authService.currentUser?.id.uuidString ?? "",
            "data": ["testId": "test-456"]
        ]
        
        let expectation = XCTestExpectation(description: "Remote notification handled")
        
        pushService.handleRemoteNotification(userInfo) { result in
            XCTAssertEqual(result, .newData)
            expectation.fulfill()
        }
        
        await fulfillment(of: [expectation], timeout: 5.0)
    }
    
    func testQuietHoursRespected() async throws {
        // 1. Setup quiet hours (current time)
        let calendar = Calendar.current
        let now = Date()
        let startComponents = calendar.dateComponents([.hour, .minute], from: now.addingTimeInterval(-3600))
        let endComponents = calendar.dateComponents([.hour, .minute], from: now.addingTimeInterval(3600))
        
        let quietHours = QuietHours(
            isEnabled: true,
            startTime: startComponents,
            endTime: endComponents,
            allowUrgent: true
        )
        
        var preferences = NotificationPreferences(userId: authService.currentUser?.id ?? UUID())
        preferences.quietHours = quietHours
        try await notificationService.updatePreferences(preferences)
        
        // 2. Send non-urgent notification
        let notification = Notification(
            userId: authService.currentUser?.id ?? UUID(),
            type: .feedActivity,
            title: "New Activity",
            body: "Someone liked your post",
            priority: .low
        )
        
        let scheduled = await pushService.scheduleRespectingQuietHours(
            notification,
            preferences: preferences
        )
        
        XCTAssertNotNil(scheduled, "Should be scheduled for later")
        
        // 3. Send urgent notification
        let urgentNotification = Notification(
            userId: authService.currentUser?.id ?? UUID(),
            type: .systemMessage,
            title: "System Alert",
            body: "Critical update required",
            priority: .urgent
        )
        
        let shouldDeliver = pushService.shouldDeliverNotification(
            urgentNotification,
            preferences: preferences
        )
        
        XCTAssertTrue(shouldDeliver, "Urgent notification should be delivered during quiet hours")
    }
    
    func testNotificationSynchronization() async throws {
        // 1. Create notifications on multiple "devices"
        let userId = authService.currentUser?.id ?? UUID()
        
        // Device 1
        try await notificationService.sendNotification(
            to: [userId],
            type: .courseAssigned,
            title: "Course 1",
            body: "First course",
            data: ["courseId": "1"]
        )
        
        // Device 2 (simulated)
        let notification2 = Notification(
            userId: userId,
            type: .testAvailable,
            title: "Test Available",
            body: "New test ready",
            data: ["testId": "2"]
        )
        _ = try await (notificationService.repository as! MockNotificationRepository)
            .createNotification(notification2)
        
        // 2. Refresh and verify sync
        try await notificationService.refreshNotifications()
        
        let allNotifications = await notificationService._notifications
        XCTAssertEqual(allNotifications.count, 2, "Should have all notifications from both devices")
        
        // 3. Mark one as read on device 1
        try await notificationService.markAsRead(allNotifications[0].id)
        
        // 4. Verify read status synced
        let updatedNotification = try await notificationService.repository
            .getNotification(id: allNotifications[0].id)
        XCTAssertTrue(updatedNotification?.isRead ?? false, "Read status should be synced")
    }
    
    func testNotificationCategories() async throws {
        // Register categories
        pushService.registerCategories()
        
        // Test each category has appropriate actions
        for category in NotificationCategory.allCases {
            let actions = category.actions
            XCTAssertFalse(actions.isEmpty, "Category \(category) should have actions")
            
            // Verify action identifiers are unique
            let identifiers = actions.map { $0.identifier }
            let uniqueIdentifiers = Set(identifiers)
            XCTAssertEqual(identifiers.count, uniqueIdentifiers.count, "Actions should have unique identifiers")
        }
    }
    
    func testNotificationAnalytics() async throws {
        let userId = authService.currentUser?.id ?? UUID()
        
        // Create test notifications
        for i in 1...5 {
            let notification = Notification(
                userId: userId,
                type: .courseAssigned,
                title: "Course \(i)",
                body: "Course \(i) assigned",
                priority: i % 2 == 0 ? .high : .low
            )
            _ = try await notificationService.repository.createNotification(notification)
        }
        
        // Track some events
        let notifications = try await notificationService.repository
            .fetchNotifications(for: userId, limit: 10, offset: 0, includeRead: true)
        
        for (index, notification) in notifications.prefix(3).enumerated() {
            // Track opened
            try await notificationService.trackNotificationOpened(notification.id)
            
            // Track action for first two
            if index < 2 {
                try await notificationService.trackNotificationAction(
                    notification.id,
                    action: "view_course"
                )
            }
        }
        
        // Get analytics
        let endDate = Date()
        let startDate = endDate.addingTimeInterval(-24 * 60 * 60) // 24 hours ago
        
        let stats = try await notificationService.getNotificationStats(
            from: startDate,
            to: endDate
        )
        
        XCTAssertEqual(stats.totalSent, 5, "Should have 5 notifications sent")
        XCTAssertEqual(stats.totalOpened, 3, "Should have 3 notifications opened")
        XCTAssertEqual(stats.totalClicked, 2, "Should have 2 notifications with actions")
        XCTAssertGreaterThan(stats.openRate, 0, "Open rate should be calculated")
        XCTAssertGreaterThan(stats.clickRate, 0, "Click rate should be calculated")
    }
    
    // MARK: - Helper Methods
    
    private func waitForExpectation(
        timeout: TimeInterval = 5.0,
        condition: @escaping () async -> Bool
    ) async {
        let startTime = Date()
        
        while Date().timeIntervalSince(startTime) < timeout {
            if await condition() {
                return
            }
            try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 second
        }
        
        XCTFail("Expectation timed out")
    }
} 