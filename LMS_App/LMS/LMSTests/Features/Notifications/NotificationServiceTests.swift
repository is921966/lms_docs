//
//  NotificationServiceTests.swift
//  LMSTests
//
//  Created on Sprint 41 Day 3 - Testing Real Notification Service
//

import XCTest
import Combine
@testable import LMS

final class NotificationServiceTests: XCTestCase {
    
    // MARK: - Properties
    
    private var sut: NotificationService!
    private var mockRepository: MockNotificationRepository!
    private var mockPushService: MockPushNotificationService!
    private var cancellables: Set<AnyCancellable>!
    
    // MARK: - Setup
    
    override func setUp() {
        super.setUp()
        mockRepository = MockNotificationRepository()
        mockPushService = MockPushNotificationService(repository: mockRepository)
        cancellables = Set<AnyCancellable>()
        
        // Create service on MainActor
        let expectation = self.expectation(description: "Service created")
        Task { @MainActor in
            sut = NotificationService(
                repository: mockRepository,
                pushService: mockPushService
            )
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }
    
    override func tearDown() {
        sut = nil
        mockRepository = nil
        mockPushService = nil
        cancellables = nil
        super.tearDown()
    }
    
    // MARK: - Tests
    
    func testInitialization() async {
        await MainActor.run {
            XCTAssertEqual(sut.unreadCount, 0)
            XCTAssertFalse(sut.isLoading)
            XCTAssertFalse(sut.hasNewNotifications)
        }
    }
    
    func testFetchNotifications() async throws {
        // Given
        let userId = UUID()
        let notifications = createTestNotifications(userId: userId, count: 5)
        for notification in notifications {
            _ = try await mockRepository.createNotification(notification)
        }
        
        // When
        let response = try await sut.fetchNotifications(page: 1, limit: 3)
        
        // Then
        XCTAssertEqual(response.items.count, 3)
        XCTAssertEqual(response.currentPage, 1)
        XCTAssertEqual(response.pageSize, 3)
        XCTAssertTrue(response.hasNextPage)
        XCTAssertFalse(response.hasPreviousPage)
    }
    
    func testFetchNotificationsWithFilter() async throws {
        // Given
        let userId = UUID()
        let notifications = [
            createTestNotification(userId: userId, type: .courseAssigned, priority: .high),
            createTestNotification(userId: userId, type: .testAvailable, priority: .medium),
            createTestNotification(userId: userId, type: .reminder, priority: .low),
            createTestNotification(userId: userId, type: .courseAssigned, priority: .high, isRead: true)
        ]
        
        for notification in notifications {
            _ = try await mockRepository.createNotification(notification)
        }
        
        // When - Filter by type
        let filter = NotificationFilter(
            types: [.courseAssigned],
            showRead: true
        )
        let response = try await sut.fetchNotifications(filter: filter)
        
        // Then
        XCTAssertEqual(response.items.count, 2)
        XCTAssertTrue(response.items.allSatisfy { $0.type == .courseAssigned })
        
        // When - Filter by priority
        let priorityFilter = NotificationFilter(
            priorities: [.high],
            showRead: true
        )
        let priorityResponse = try await sut.fetchNotifications(filter: priorityFilter)
        
        // Then
        XCTAssertEqual(priorityResponse.items.count, 2)
        XCTAssertTrue(priorityResponse.items.allSatisfy { $0.priority == .high })
    }
    
    func testMarkAsRead() async throws {
        // Given
        let notification = createTestNotification()
        let created = try await mockRepository.createNotification(notification)
        XCTAssertFalse(created.isRead)
        
        var readNotificationReceived = false
        sut.notificationRead
            .sink { _ in
                readNotificationReceived = true
            }
            .store(in: &cancellables)
        
        // When
        try await sut.markAsRead(created)
        
        // Then
        let updated = try await mockRepository.getNotification(id: created.id)
        XCTAssertNotNil(updated)
        XCTAssertTrue(updated!.isRead)
        XCTAssertNotNil(updated!.readAt)
        XCTAssertTrue(readNotificationReceived)
    }
    
    func testMarkAllAsRead() async throws {
        // Given
        let userId = UUID()
        let notifications = createTestNotifications(userId: userId, count: 5)
        for notification in notifications {
            _ = try await mockRepository.createNotification(notification)
        }
        
        // When
        try await sut.markAllAsRead()
        
        // Then
        let response = try await sut.fetchNotifications()
        XCTAssertTrue(response.items.allSatisfy { $0.isRead })
    }
    
    func testDeleteNotification() async throws {
        // Given
        let notification = createTestNotification()
        let created = try await mockRepository.createNotification(notification)
        
        var deleteNotificationReceived = false
        sut.notificationDeleted
            .sink { _ in
                deleteNotificationReceived = true
            }
            .store(in: &cancellables)
        
        // When
        try await sut.deleteNotification(created)
        
        // Then
        let deleted = try await mockRepository.getNotification(id: created.id)
        XCTAssertNil(deleted)
        XCTAssertTrue(deleteNotificationReceived)
    }
    
    func testSendTestNotification() async throws {
        // Given
        var newNotificationReceived = false
        sut.notificationReceived
            .sink { _ in
                newNotificationReceived = true
            }
            .store(in: &cancellables)
        
        // When
        try await sut.sendTestNotification(type: .courseAssigned)
        
        // Then
        XCTAssertTrue(newNotificationReceived)
        await MainActor.run {
            XCTAssertTrue(sut.hasNewNotifications)
        }
        
        // Verify notification was created
        let response = try await sut.fetchNotifications()
        XCTAssertEqual(response.items.count, 1)
        XCTAssertEqual(response.items.first?.type, .courseAssigned)
    }
    
    func testGetPreferences() async throws {
        // When - No existing preferences
        let preferences = try await sut.getPreferences()
        
        // Then
        XCTAssertNotNil(preferences)
        XCTAssertTrue(preferences.isEnabled)
        XCTAssertNil(preferences.quietHours)
        
        // When - Update preferences
        var updatedPrefs = preferences
        updatedPrefs.isEnabled = false
        updatedPrefs.quietHours = QuietHours(
            isEnabled: true,
            startTime: DateComponents(hour: 22, minute: 0),
            endTime: DateComponents(hour: 8, minute: 0)
        )
        
        try await sut.updatePreferences(updatedPrefs)
        
        // Then
        let retrieved = try await sut.getPreferences()
        XCTAssertFalse(retrieved.isEnabled)
        XCTAssertNotNil(retrieved.quietHours)
        XCTAssertTrue(retrieved.quietHours!.isEnabled)
    }
    
    func testNotificationReceived() async throws {
        // Given
        let expectation = XCTestExpectation(description: "Notification received")
        var receivedNotification: Notification?
        
        sut.notificationReceived
            .sink { notification in
                receivedNotification = notification
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        // When
        try await sut.sendTestNotification(type: .testAvailable)
        
        // Then
        await fulfillment(of: [expectation], timeout: 1.0)
        XCTAssertNotNil(receivedNotification)
        XCTAssertEqual(receivedNotification?.type, .testAvailable)
    }
    
    func testRefreshUnreadCount() async throws {
        // Given
        let userId = UUID()
        let notifications = [
            createTestNotification(userId: userId, isRead: false),
            createTestNotification(userId: userId, isRead: false),
            createTestNotification(userId: userId, isRead: true)
        ]
        
        for notification in notifications {
            _ = try await mockRepository.createNotification(notification)
        }
        
        // When
        await sut.refreshUnreadCount()
        
        // Then
        await MainActor.run {
            XCTAssertEqual(sut.unreadCount, 2)
        }
    }
    
    func testClearNewNotificationFlag() async {
        // Given
        try? await sut.sendTestNotification(type: .reminder)
        await MainActor.run {
            XCTAssertTrue(sut.hasNewNotifications)
        }
        
        // When
        await MainActor.run {
            sut.clearNewNotificationFlag()
        }
        
        // Then
        await MainActor.run {
            XCTAssertFalse(sut.hasNewNotifications)
        }
    }
    
    // MARK: - Helpers
    
    private func createTestNotification(
        userId: UUID = UUID(),
        type: NotificationType = .courseAssigned,
        priority: NotificationPriority = .medium,
        isRead: Bool = false
    ) -> Notification {
        return Notification(
            userId: userId,
            type: type,
            title: "Test Notification",
            body: "This is a test notification",
            channels: [.inApp],
            priority: priority,
            isRead: isRead,
            readAt: isRead ? Date() : nil
        )
    }
    
    private func createTestNotifications(userId: UUID, count: Int) -> [Notification] {
        return (0..<count).map { index in
            createTestNotification(
                userId: userId,
                type: NotificationType.allCases[index % NotificationType.allCases.count],
                priority: NotificationPriority.allCases[index % NotificationPriority.allCases.count]
            )
        }
    }
} 