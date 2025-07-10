//
//  NotificationRepositoryQuickTest.swift
//  LMSTests
//
//  Created by LMS Team on 13.01.2025.
//

import XCTest
@testable import LMS

@MainActor
final class NotificationRepositoryQuickTest: XCTestCase {
    
    func testBasicRepositoryCreation() {
        // This test should compile and run quickly
        let repository = MockNotificationRepository()
        XCTAssertNotNil(repository)
    }
    
    func testNotificationOperations() async throws {
        let repository = MockNotificationRepository()
        
        // Create notification
        let notification = Notification(
            id: UUID(),
            userId: UUID(),
            type: .courseAssigned,
            title: "Test",
            body: "Test body",
            isRead: false,
            createdAt: Date(),
            metadata: nil
        )
        
        let created = try await repository.createNotification(notification)
        XCTAssertEqual(created.id, notification.id)
        
        // Fetch notifications
        let response = try await repository.fetchNotifications(
            for: notification.userId,
            filter: nil,
            pagination: nil
        )
        
        XCTAssertEqual(response.items.count, 1)
        XCTAssertEqual(response.items.first?.id, notification.id)
    }
    
    func testPushTokenOperations() async throws {
        let repository = MockNotificationRepository()
        
        let token = PushToken(
            id: UUID(),
            userId: UUID(),
            token: "test-token",
            deviceId: "test-device",
            platform: .ios,
            createdAt: Date(),
            updatedAt: Date()
        )
        
        let saved = try await repository.savePushToken(token)
        XCTAssertEqual(saved.token, "test-token")
        
        // Get tokens
        let tokens = try await repository.getPushTokens(for: token.userId)
        XCTAssertEqual(tokens.count, 1)
        XCTAssertEqual(tokens.first?.token, "test-token")
    }
    
    func testNotificationPreferences() async throws {
        let repository = MockNotificationRepository()
        
        let userId = UUID()
        let prefs = NotificationPreferences(
            userId: userId,
            channelPreferences: [
                .courseAssigned: [.email, .push],
                .testResult: [.push]
            ],
            isEnabled: true,
            quietHoursStart: nil,
            quietHoursEnd: nil
        )
        
        let saved = try await repository.savePreferences(prefs)
        XCTAssertEqual(saved.userId, userId)
        
        // Get preferences
        let fetched = try await repository.getPreferences(for: userId)
        XCTAssertEqual(fetched.userId, userId)
        XCTAssertEqual(fetched.isEnabled, true)
        XCTAssertEqual(fetched.channelPreferences[.courseAssigned]?.contains(.email), true)
        XCTAssertEqual(fetched.channelPreferences[.courseAssigned]?.contains(.push), true)
        XCTAssertEqual(fetched.channelPreferences[.testResult]?.contains(.push), true)
    }
    
    func testMarkAsRead() async throws {
        let repository = MockNotificationRepository()
        
        let notification = Notification(
            id: UUID(),
            userId: UUID(),
            type: .testDeadline,
            title: "Deadline",
            body: "Test deadline approaching",
            isRead: false,
            createdAt: Date()
        )
        
        _ = try await repository.createNotification(notification)
        
        // Mark as read
        try await repository.markAsRead(notificationId: notification.id)
        
        // Verify it's marked as read
        let response = try await repository.fetchNotifications(
            for: notification.userId,
            filter: nil,
            pagination: nil
        )
        
        XCTAssertEqual(response.items.first?.isRead, true)
    }
} 