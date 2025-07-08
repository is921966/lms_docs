//
//  MockNotificationRepositoryTests.swift
//  LMSTests
//
//  Created on Sprint 41 Day 2 - Tests for Mock Notification Repository
//

import XCTest
@testable import LMS

final class MockNotificationRepositoryTests: XCTestCase {
    
    private var repository: MockNotificationRepository!
    private let testUserId = UUID()
    
    override func setUp() {
        super.setUp()
        repository = MockNotificationRepository()
    }
    
    override func tearDown() {
        repository = nil
        super.tearDown()
    }
    
    // MARK: - Fetch Notifications Tests
    
    func testFetchNotificationsReturnsNotificationsForUser() async throws {
        // Given
        let notification = Notification(
            userId: testUserId,
            type: .courseAssigned,
            title: "Test",
            body: "Test Body"
        )
        _ = try await repository.createNotification(notification)
        
        // When
        let response = try await repository.fetchNotifications(
            for: testUserId,
            filter: nil,
            pagination: nil
        )
        
        // Then
        XCTAssertTrue(response.items.contains { $0.userId == testUserId })
    }
    
    func testFetchNotificationsWithTypeFilter() async throws {
        // Given
        let notification1 = Notification(
            userId: testUserId,
            type: .courseAssigned,
            title: "Course",
            body: "Course Body"
        )
        let notification2 = Notification(
            userId: testUserId,
            type: .testDeadline,
            title: "Test",
            body: "Test Body"
        )
        _ = try await repository.createNotification(notification1)
        _ = try await repository.createNotification(notification2)
        
        // When
        let filter = NotificationFilter(types: [.courseAssigned])
        let response = try await repository.fetchNotifications(
            for: testUserId,
            filter: filter,
            pagination: nil
        )
        
        // Then
        XCTAssertTrue(response.items.allSatisfy { $0.type == .courseAssigned })
    }
    
    func testFetchNotificationsWithPagination() async throws {
        // Given - create 5 notifications
        for i in 1...5 {
            let notification = Notification(
                userId: testUserId,
                type: .courseAssigned,
                title: "Test \(i)",
                body: "Body \(i)"
            )
            _ = try await repository.createNotification(notification)
        }
        
        // When - request page 1 with limit 2
        let pagination = PaginationRequest(page: 1, limit: 2)
        let response = try await repository.fetchNotifications(
            for: testUserId,
            filter: nil,
            pagination: pagination
        )
        
        // Then
        XCTAssertEqual(response.items.count, 2)
        XCTAssertEqual(response.currentPage, 1)
        XCTAssertEqual(response.totalPages, 3) // 5 items / 2 per page = 3 pages
    }
    
    // MARK: - Create/Update/Delete Tests
    
    func testCreateNotification() async throws {
        // Given
        let notification = Notification(
            userId: testUserId,
            type: .courseAssigned,
            title: "New Course",
            body: "Course assigned"
        )
        
        // When
        let created = try await repository.createNotification(notification)
        
        // Then
        XCTAssertEqual(created.id, notification.id)
        XCTAssertEqual(created.title, notification.title)
    }
    
    func testUpdateNotification() async throws {
        // Given
        var notification = Notification(
            userId: testUserId,
            type: .courseAssigned,
            title: "Original",
            body: "Original Body"
        )
        let created = try await repository.createNotification(notification)
        
        // When
        notification = created
        notification.markAsRead()
        let updated = try await repository.updateNotification(notification)
        
        // Then
        XCTAssertTrue(updated.isRead)
        XCTAssertNotNil(updated.readAt)
    }
    
    func testDeleteNotification() async throws {
        // Given
        let notification = Notification(
            userId: testUserId,
            type: .courseAssigned,
            title: "To Delete",
            body: "Will be deleted"
        )
        let created = try await repository.createNotification(notification)
        
        // When
        try await repository.deleteNotification(id: created.id)
        
        // Then
        let response = try await repository.fetchNotifications(
            for: testUserId,
            filter: nil,
            pagination: nil
        )
        XCTAssertFalse(response.items.contains { $0.id == created.id })
    }
    
    // MARK: - Mark as Read Tests
    
    func testMarkAsRead() async throws {
        // Given
        let notification = Notification(
            userId: testUserId,
            type: .courseAssigned,
            title: "Unread",
            body: "Unread notification",
            isRead: false
        )
        let created = try await repository.createNotification(notification)
        
        // When
        try await repository.markAsRead(notificationId: created.id)
        
        // Then
        let response = try await repository.fetchNotifications(
            for: testUserId,
            filter: nil,
            pagination: nil
        )
        let updated = response.items.first { $0.id == created.id }
        XCTAssertTrue(updated?.isRead ?? false)
    }
    
    func testMarkAllAsRead() async throws {
        // Given - create 3 unread notifications
        for i in 1...3 {
            let notification = Notification(
                userId: testUserId,
                type: .courseAssigned,
                title: "Unread \(i)",
                body: "Body \(i)",
                isRead: false
            )
            _ = try await repository.createNotification(notification)
        }
        
        // When
        try await repository.markAllAsRead(for: testUserId)
        
        // Then
        let response = try await repository.fetchNotifications(
            for: testUserId,
            filter: nil,
            pagination: nil
        )
        XCTAssertTrue(response.items.filter { $0.userId == testUserId }.allSatisfy { $0.isRead })
    }
    
    // MARK: - Push Token Tests
    
    func testSavePushToken() async throws {
        // Given
        let token = PushToken(
            userId: testUserId,
            token: "test-token-123",
            deviceId: "device-123"
        )
        
        // When
        let saved = try await repository.savePushToken(token)
        
        // Then
        XCTAssertEqual(saved.token, token.token)
        XCTAssertTrue(saved.isActive)
    }
    
    func testGetPushTokens() async throws {
        // Given
        let token1 = PushToken(
            userId: testUserId,
            token: "token-1",
            deviceId: "device-1"
        )
        let token2 = PushToken(
            userId: testUserId,
            token: "token-2",
            deviceId: "device-2"
        )
        _ = try await repository.savePushToken(token1)
        _ = try await repository.savePushToken(token2)
        
        // When
        let tokens = try await repository.getPushTokens(for: testUserId)
        
        // Then
        XCTAssertEqual(tokens.count, 2)
        XCTAssertTrue(tokens.allSatisfy { $0.isActive })
    }
    
    // MARK: - Preferences Tests
    
    func testGetDefaultPreferences() async throws {
        // When
        let prefs = try await repository.getPreferences(for: testUserId)
        
        // Then
        XCTAssertEqual(prefs.userId, testUserId)
        XCTAssertTrue(prefs.isEnabled)
    }
    
    func testUpdatePreferences() async throws {
        // Given
        var prefs = NotificationPreferences(
            userId: testUserId,
            isEnabled: false
        )
        
        // When
        let updated = try await repository.updatePreferences(prefs)
        
        // Then
        XCTAssertFalse(updated.isEnabled)
        
        // Verify persistence
        let fetched = try await repository.getPreferences(for: testUserId)
        XCTAssertFalse(fetched.isEnabled)
    }
    
    // MARK: - Template Tests
    
    func testGetTemplates() async throws {
        // When
        let templates = try await repository.getTemplates(for: nil)
        
        // Then
        XCTAssertGreaterThan(templates.count, 0)
    }
    
    func testGetTemplatesByType() async throws {
        // When
        let templates = try await repository.getTemplates(for: .courseAssigned)
        
        // Then
        XCTAssertTrue(templates.allSatisfy { $0.type == .courseAssigned })
    }
    
    func testCreateTemplate() async throws {
        // Given
        let template = NotificationTemplate(
            type: .testReminder,
            titleTemplate: "Test Reminder: {{testName}}",
            bodyTemplate: "Don't forget about {{testName}}"
        )
        
        // When
        let created = try await repository.createTemplate(template)
        
        // Then
        XCTAssertEqual(created.titleTemplate, template.titleTemplate)
        
        // Verify it's saved
        let templates = try await repository.getTemplates(for: .testReminder)
        XCTAssertTrue(templates.contains { $0.id == created.id })
    }
} 