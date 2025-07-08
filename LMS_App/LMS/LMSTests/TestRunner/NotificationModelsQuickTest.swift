//
//  NotificationModelsQuickTest.swift
//  LMSTests
//
//  Quick test to verify notification models work
//

import XCTest
@testable import LMS

final class NotificationModelsQuickTest: XCTestCase {
    
    func testBasicNotificationCreation() {
        // Test creating a notification
        let userId = UUID()
        let notification = Notification(
            userId: userId,
            type: .courseAssigned,
            title: "Test Notification",
            body: "Test Body"
        )
        
        XCTAssertNotNil(notification.id)
        XCTAssertEqual(notification.userId, userId)
        XCTAssertEqual(notification.type, .courseAssigned)
        XCTAssertEqual(notification.title, "Test Notification")
        XCTAssertEqual(notification.body, "Test Body")
        XCTAssertFalse(notification.isRead)
        XCTAssertEqual(notification.priority, .medium)
    }
    
    func testNotificationTypeDisplayName() {
        XCTAssertEqual(NotificationType.courseAssigned.displayName, "Новый курс")
        XCTAssertEqual(NotificationType.testDeadline.displayName, "Дедлайн теста")
    }
    
    func testNotificationChannels() {
        XCTAssertEqual(NotificationChannel.push.displayName, "Push-уведомления")
        XCTAssertEqual(NotificationChannel.email.displayName, "Email")
    }
} 