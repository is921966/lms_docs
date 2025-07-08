//
//  MockPushNotificationServiceTests.swift
//  LMSTests
//
//  Created on Sprint 41 Day 3 - Testing Mock Push Notification Service
//

import XCTest
import UserNotifications
@testable import LMS

final class MockPushNotificationServiceTests: XCTestCase {
    
    // MARK: - Properties
    
    private var sut: MockPushNotificationService!
    private var mockRepository: MockNotificationRepository!
    
    // MARK: - Setup
    
    override func setUp() {
        super.setUp()
        mockRepository = MockNotificationRepository()
        sut = MockPushNotificationService(repository: mockRepository)
    }
    
    override func tearDown() {
        sut = nil
        mockRepository = nil
        super.tearDown()
    }
    
    // MARK: - Permission Tests
    
    func testRequestAuthorization() async throws {
        // Act
        let authorized = try await sut.requestAuthorization()
        
        // Assert
        XCTAssertTrue(authorized)
        let status = await sut.getAuthorizationStatus()
        XCTAssertEqual(status, .authorized)
    }
    
    func testIsEnabled() async {
        // Initially not authorized
        let initialEnabled = await sut.isEnabled()
        XCTAssertFalse(initialEnabled)
        
        // After authorization
        _ = try? await sut.requestAuthorization()
        let afterEnabled = await sut.isEnabled()
        XCTAssertTrue(afterEnabled)
    }
    
    // MARK: - Token Management Tests
    
    func testRegisterDeviceToken() async throws {
        // Arrange
        let tokenData = "mock-token-data".data(using: .utf8)!
        
        // Act
        try await sut.registerDeviceToken(tokenData)
        
        // Assert
        XCTAssertNotNil(sut.getCurrentToken())
        
        // Verify token was saved to repository
        let savedTokens = await mockRepository.getAllPushTokens()
        XCTAssertEqual(savedTokens.count, 1)
    }
    
    func testHandleRegistrationError() {
        // Arrange
        let initialToken = sut.getCurrentToken()
        XCTAssertNotNil(initialToken)
        
        // Act
        sut.handleRegistrationError(NSError(domain: "test", code: 1))
        
        // Assert
        XCTAssertNil(sut.getCurrentToken())
    }
    
    // MARK: - Local Notification Tests
    
    func testScheduleLocalNotification() async throws {
        // Arrange
        let notification = Notification(
            type: .courseAssigned,
            title: "Новый курс",
            body: "Вам назначен новый курс"
        )
        
        // Act
        let identifier = try await sut.scheduleLocalNotification(notification, triggerDate: nil)
        
        // Assert
        XCTAssertEqual(identifier, notification.id.uuidString)
        
        let pending = await sut.getPendingNotifications()
        XCTAssertEqual(pending.count, 1)
    }
    
    func testScheduleLocalNotificationWithTriggerDate() async throws {
        // Arrange
        let notification = Notification(
            type: .testDeadline,
            title: "Дедлайн теста",
            body: "Завтра истекает срок сдачи теста"
        )
        let triggerDate = Date().addingTimeInterval(86400) // Tomorrow
        
        // Act
        let identifier = try await sut.scheduleLocalNotification(notification, triggerDate: triggerDate)
        
        // Assert
        XCTAssertEqual(identifier, notification.id.uuidString)
        
        let pending = await sut.getPendingNotifications()
        XCTAssertEqual(pending.count, 1)
        
        // Verify trigger
        let request = pending.first!
        XCTAssertNotNil(request.trigger as? UNCalendarNotificationTrigger)
    }
    
    func testCancelScheduledNotification() async throws {
        // Arrange
        let notification = Notification(
            type: .courseAssigned,
            title: "Test",
            body: "Test"
        )
        let identifier = try await sut.scheduleLocalNotification(notification, triggerDate: nil)
        
        // Act
        try await sut.cancelScheduledNotification(identifier: identifier)
        
        // Assert
        let pending = await sut.getPendingNotifications()
        XCTAssertEqual(pending.count, 0)
    }
    
    func testCancelAllScheduledNotifications() async throws {
        // Arrange
        for i in 0..<5 {
            let notification = Notification(
                type: .courseAssigned,
                title: "Test \(i)",
                body: "Test body \(i)"
            )
            _ = try await sut.scheduleLocalNotification(notification, triggerDate: nil)
        }
        
        var pending = await sut.getPendingNotifications()
        XCTAssertEqual(pending.count, 5)
        
        // Act
        try await sut.cancelAllScheduledNotifications()
        
        // Assert
        pending = await sut.getPendingNotifications()
        XCTAssertEqual(pending.count, 0)
    }
    
    // MARK: - Remote Notification Tests
    
    func testHandleRemoteNotificationWithNewData() {
        // Arrange
        let expectation = expectation(description: "Completion handler called")
        let userInfo: [AnyHashable: Any] = [
            "notificationId": "123",
            "hasNewData": true
        ]
        
        // Act
        sut.handleRemoteNotification(userInfo) { result in
            // Assert
            XCTAssertEqual(result, .newData)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testHandleRemoteNotificationWithoutNewData() {
        // Arrange
        let expectation = expectation(description: "Completion handler called")
        let userInfo: [AnyHashable: Any] = [
            "notificationId": "123"
        ]
        
        // Act
        sut.handleRemoteNotification(userInfo) { result in
            // Assert
            XCTAssertEqual(result, .noData)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    // MARK: - Rich Content Tests
    
    func testCreateRichContent() async throws {
        // Arrange
        let notification = Notification(
            type: .achievementUnlocked,
            title: "Достижение!",
            body: "Вы получили новое достижение",
            metadata: NotificationMetadata(
                badge: 5,
                sound: "achievement.mp3"
            )
        )
        
        // Act
        let content = try await sut.createRichContent(from: notification)
        
        // Assert
        XCTAssertEqual(content.title, notification.title)
        XCTAssertEqual(content.body, notification.body)
        XCTAssertEqual(content.badge?.intValue, 5)
        XCTAssertEqual(content.categoryIdentifier, NotificationCategory.achievement.rawValue)
        XCTAssertEqual(content.threadIdentifier, notification.type.rawValue)
    }
    
    // MARK: - Category Tests
    
    func testRegisterCategories() {
        // Act
        sut.registerCategories()
        
        // Assert - just verify no crash
        XCTAssertTrue(true)
    }
    
    // MARK: - Badge Tests
    
    func testUpdateBadge() async {
        // Act
        await sut.updateBadge(count: 10)
        
        // Assert - just verify no crash
        XCTAssertTrue(true)
    }
    
    func testClearBadge() async {
        // Act
        await sut.clearBadge()
        
        // Assert - just verify no crash
        XCTAssertTrue(true)
    }
    
    // MARK: - Quiet Hours Tests
    
    func testShouldDeliverNotificationRespectingQuietHours() {
        // Arrange
        let notification = Notification(
            type: .courseAssigned,
            title: "Test",
            body: "Test"
        )
        
        // Test 1: Notifications disabled
        var preferences = NotificationPreferences(
            userId: UUID(),
            isEnabled: false
        )
        XCTAssertFalse(sut.shouldDeliverNotification(notification, preferences: preferences))
        
        // Test 2: In quiet hours, non-urgent
        preferences = NotificationPreferences(
            userId: UUID(),
            isEnabled: true,
            quietHours: QuietHours(
                isEnabled: true,
                startTime: DateComponents(hour: 0, minute: 0),
                endTime: DateComponents(hour: 23, minute: 59),
                allowUrgent: true
            )
        )
        XCTAssertFalse(sut.shouldDeliverNotification(notification, preferences: preferences))
        
        // Test 3: In quiet hours, urgent allowed
        let urgentNotification = Notification(
            type: .testDeadline,
            title: "Urgent",
            body: "Urgent",
            priority: .urgent
        )
        XCTAssertTrue(sut.shouldDeliverNotification(urgentNotification, preferences: preferences))
        
        // Test 4: Not in quiet hours
        preferences = NotificationPreferences(
            userId: UUID(),
            isEnabled: true
        )
        XCTAssertTrue(sut.shouldDeliverNotification(notification, preferences: preferences))
    }
    
    func testScheduleRespectingQuietHours() async throws {
        // Arrange
        let notification = Notification(
            type: .courseAssigned,
            title: "Test",
            body: "Test"
        )
        
        // Test 1: No quiet hours - immediate delivery
        let preferences1 = NotificationPreferences(
            userId: UUID(),
            isEnabled: true
        )
        let id1 = try await sut.scheduleRespectingQuietHours(notification, preferences: preferences1)
        XCTAssertNotNil(id1)
        
        // Test 2: In quiet hours - scheduled for later
        let preferences2 = NotificationPreferences(
            userId: UUID(),
            isEnabled: true,
            quietHours: QuietHours(
                isEnabled: true,
                startTime: DateComponents(hour: 0, minute: 0),
                endTime: DateComponents(hour: 23, minute: 59),
                allowUrgent: false
            )
        )
        let id2 = try await sut.scheduleRespectingQuietHours(notification, preferences: preferences2)
        XCTAssertNotNil(id2)
        
        // Clean up
        try await sut.cancelAllScheduledNotifications()
    }
}

// MARK: - Quick Test

final class MockPushNotificationServiceQuickTest: XCTestCase {
    
    func testBasicFunctionality() async throws {
        // Arrange
        let service = MockPushNotificationService()
        
        // Test authorization
        let authorized = try await service.requestAuthorization()
        XCTAssertTrue(authorized)
        
        // Test scheduling
        let notification = Notification(
            type: .courseAssigned,
            title: "Quick Test",
            body: "Testing basic functionality"
        )
        
        let identifier = try await service.scheduleLocalNotification(notification, triggerDate: nil)
        XCTAssertEqual(identifier, notification.id.uuidString)
        
        // Test cancel
        try await service.cancelScheduledNotification(identifier: identifier)
        
        let pending = await service.getPendingNotifications()
        XCTAssertEqual(pending.count, 0)
    }
} 