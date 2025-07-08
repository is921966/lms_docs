//
//  NotificationRepositoryQuickTest.swift
//  LMSTests
//
//  Quick test for notification repository functionality
//

import XCTest
@testable import LMS

final class NotificationRepositoryQuickTest: XCTestCase {
    
    func testBasicRepositoryCreation() {
        // Test creating repository
        let repository = MockNotificationRepository()
        XCTAssertNotNil(repository)
    }
    
    func testNotificationCreationAndFetch() async throws {
        // Given
        let repository = MockNotificationRepository()
        let userId = UUID()
        let notification = Notification(
            userId: userId,
            type: .courseAssigned,
            title: "Test Course",
            body: "Test Body"
        )
        
        // When
        let created = try await repository.createNotification(notification)
        let response = try await repository.fetchNotifications(
            for: userId,
            filter: nil,
            pagination: nil
        )
        
        // Then
        XCTAssertNotNil(created)
        XCTAssertTrue(response.items.contains { $0.id == created.id })
    }
    
    func testMarkAsRead() async throws {
        // Given
        let repository = MockNotificationRepository()
        let userId = UUID()
        let notification = Notification(
            userId: userId,
            type: .testDeadline,
            title: "Test Deadline",
            body: "Test is due soon",
            isRead: false
        )
        
        // When
        let created = try await repository.createNotification(notification)
        try await repository.markAsRead(notificationId: created.id)
        
        // Then
        let response = try await repository.fetchNotifications(
            for: userId,
            filter: nil,
            pagination: nil
        )
        let updated = response.items.first { $0.id == created.id }
        XCTAssertTrue(updated?.isRead ?? false)
    }
    
    func testPushTokenStorage() async throws {
        // Given
        let repository = MockNotificationRepository()
        let userId = UUID()
        let token = PushToken(
            userId: userId,
            token: "test-token-abc123",
            deviceId: "test-device-123"
        )
        
        // When
        let saved = try await repository.savePushToken(token)
        let tokens = try await repository.getPushTokens(for: userId)
        
        // Then
        XCTAssertEqual(saved.token, token.token)
        XCTAssertTrue(tokens.contains { $0.id == saved.id })
    }
    
    func testPreferencesUpdate() async throws {
        // Given
        let repository = MockNotificationRepository()
        let userId = UUID()
        let preferences = NotificationPreferences(
            userId: userId,
            channelPreferences: [
                .courseAssigned: [.push, .email]
            ],
            isEnabled: true
        )
        
        // When
        let updated = try await repository.updatePreferences(preferences)
        let fetched = try await repository.getPreferences(for: userId)
        
        // Then
        XCTAssertEqual(updated.userId, userId)
        XCTAssertEqual(fetched.channelPreferences[.courseAssigned], [.push, .email])
    }
} 