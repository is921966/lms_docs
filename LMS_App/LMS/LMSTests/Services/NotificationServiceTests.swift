//
//  NotificationServiceTests.swift
//  LMSTests
//

import XCTest
import Combine
@testable import LMS

final class NotificationServiceTests: XCTestCase {
    
    var sut: NotificationService!
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        sut = NotificationService.shared
        cancellables = []
        // Clear any existing notifications
        sut.notifications.removeAll()
    }
    
    override func tearDown() {
        cancellables = nil
        sut.notifications.removeAll()
        sut = nil
        super.tearDown()
    }
    
    // MARK: - Singleton Tests
    
    func testSharedInstance() {
        let instance1 = NotificationService.shared
        let instance2 = NotificationService.shared
        XCTAssertTrue(instance1 === instance2)
    }
    
    // MARK: - Initial State Tests
    
    func testInitialState() {
        XCTAssertTrue(sut.notifications.isEmpty)
        XCTAssertEqual(sut.unreadCount, 0)
    }
    
    // MARK: - Add Notification Tests
    
    func testAddNotification() async {
        // Given
        let notification = createTestNotification()
        
        // When
        await sut.add(notification)
        
        // Then
        XCTAssertEqual(sut.notifications.count, 1)
        XCTAssertEqual(sut.notifications.first?.id, notification.id)
        XCTAssertEqual(sut.unreadCount, 1)
    }
    
    func testAddMultipleNotifications() async {
        // Given
        let notifications = (1...5).map { _ in createTestNotification() }
        
        // When
        for notification in notifications {
            await sut.add(notification)
        }
        
        // Then
        XCTAssertEqual(sut.notifications.count, 5)
        XCTAssertEqual(sut.unreadCount, 5)
    }
    
    func testNotificationsAreSortedByDate() async {
        // Given
        let oldNotification = createTestNotification(createdAt: Date().addingTimeInterval(-3600))
        let newNotification = createTestNotification(createdAt: Date())
        
        // When
        await sut.add(oldNotification)
        await sut.add(newNotification)
        
        // Then
        XCTAssertTrue(sut.notifications.first!.createdAt > sut.notifications.last!.createdAt)
    }
    
    // MARK: - Mark As Read Tests
    
    func testMarkAsRead() async {
        // Given
        let notification = createTestNotification()
        await sut.add(notification)
        
        // When
        sut.markAsRead(notification)
        
        // Then
        XCTAssertTrue(sut.notifications.first?.isRead ?? false)
        XCTAssertEqual(sut.unreadCount, 0)
    }
    
    func testMarkAsReadAlreadyRead() async {
        // Given
        var notification = createTestNotification()
        notification.isRead = true
        await sut.add(notification)
        let initialCount = sut.unreadCount
        
        // When
        sut.markAsRead(notification)
        
        // Then
        XCTAssertEqual(sut.unreadCount, initialCount)
    }
    
    func testMarkAllAsRead() async {
        // Given
        let notifications = (1...5).map { _ in createTestNotification() }
        for notification in notifications {
            await sut.add(notification)
        }
        
        // When
        sut.markAllAsRead()
        
        // Then
        XCTAssertTrue(sut.notifications.allSatisfy { $0.isRead })
        XCTAssertEqual(sut.unreadCount, 0)
    }
    
    // MARK: - Delete Notification Tests
    
    func testDeleteNotification() async {
        // Given
        let notification = createTestNotification()
        await sut.add(notification)
        
        // When
        sut.deleteNotification(notification)
        
        // Then
        XCTAssertTrue(sut.notifications.isEmpty)
        XCTAssertEqual(sut.unreadCount, 0)
    }
    
    func testDeleteNonExistentNotification() async {
        // Given
        let notification1 = createTestNotification()
        let notification2 = createTestNotification()
        await sut.add(notification1)
        
        // When
        sut.deleteNotification(notification2)
        
        // Then
        XCTAssertEqual(sut.notifications.count, 1)
        XCTAssertEqual(sut.notifications.first?.id, notification1.id)
    }
    
    // MARK: - Send Notification Tests
    
    func testSendNotification() {
        // Given
        let recipientId = UUID()
        let title = "Test Notification"
        let message = "This is a test"
        let type = NotificationType.systemMessage
        let priority = NotificationPriority.medium
        
        // When
        sut.sendNotification(
            to: recipientId,
            title: title,
            message: message,
            type: type,
            priority: priority
        )
        
        // Then
        XCTAssertEqual(sut.notifications.count, 1)
        let notification = sut.notifications.first
        XCTAssertEqual(notification?.title, title)
        XCTAssertEqual(notification?.body, message)
        XCTAssertEqual(notification?.type, type)
        XCTAssertEqual(notification?.priority, priority)
    }
    
    func testNotifyCourseAssigned() {
        // Given
        let courseId = "course123"
        let courseName = "iOS Development"
        let recipientId = UUID()
        let deadline = Date().addingTimeInterval(7 * 24 * 3600) // 7 days
        
        // When
        sut.notifyCourseAssigned(
            courseId: courseId,
            courseName: courseName,
            recipientId: recipientId,
            deadline: deadline
        )
        
        // Then
        XCTAssertEqual(sut.notifications.count, 1)
        let notification = sut.notifications.first
        XCTAssertEqual(notification?.type, .courseAssigned)
        XCTAssertEqual(notification?.priority, .high)
        XCTAssertTrue(notification?.metadata?.actionUrl?.contains(recipientId.uuidString) ?? false)
    }
    
    func testNotifyTestReminder() {
        // Given
        let testId = "test123"
        let testName = "Swift Basics Test"
        let recipientId = UUID()
        let daysLeft = 3
        
        // When
        sut.notifyTestReminder(
            testId: testId,
            testName: testName,
            recipientId: recipientId,
            daysLeft: daysLeft
        )
        
        // Then
        XCTAssertEqual(sut.notifications.count, 1)
        let notification = sut.notifications.first
        XCTAssertEqual(notification?.type, .testReminder)
        XCTAssertEqual(notification?.priority, .medium)
        XCTAssertTrue(notification?.metadata?.actionUrl?.contains(recipientId.uuidString) ?? false)
    }
    
    // MARK: - Publisher Tests
    
    func testNotificationsPublisher() async {
        // Given
        let expectation = XCTestExpectation(description: "Notifications published")
        var receivedNotifications: [[LMS.Notification]] = []
        
        sut.$notifications
            .dropFirst() // Skip initial empty value
            .sink { notifications in
                receivedNotifications.append(notifications)
                if receivedNotifications.count >= 3 {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        // When
        await sut.add(createTestNotification(id: "1"))
        await sut.add(createTestNotification(id: "2"))
        await sut.add(createTestNotification(id: "3"))
        
        // Then
        await fulfillment(of: [expectation], timeout: 2.0)
        XCTAssertEqual(receivedNotifications.last?.count, 3)
    }
    
    func testUnreadCountPublisher() async {
        // Given
        let expectation = XCTestExpectation(description: "Unread count published")
        var receivedCounts: [Int] = []
        
        sut.$unreadCount
            .dropFirst() // Skip initial value
            .sink { count in
                receivedCounts.append(count)
                if receivedCounts.count >= 2 {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        // When
        let notification = createTestNotification()
        await sut.add(notification)
        sut.markAsRead(notification)
        
        // Then
        await fulfillment(of: [expectation], timeout: 2.0)
        XCTAssertTrue(receivedCounts.contains(1))
        XCTAssertTrue(receivedCounts.contains(0))
    }
    
    // MARK: - Helper Methods
    
    private func createTestNotification(
        id: UUID = UUID(),
        userId: UUID = UUID(),
        type: NotificationType = .systemMessage,
        title: String = "Test Notification",
        body: String = "Test message",
        createdAt: Date = Date(),
        isRead: Bool = false,
        priority: NotificationPriority = .medium
    ) -> LMS.Notification {
        return LMS.Notification(
            id: id,
            userId: userId,
            type: type,
            title: title,
            body: body,
            data: nil,
            channels: [.inApp],
            priority: priority,
            isRead: isRead,
            readAt: isRead ? Date() : nil,
            createdAt: createdAt,
            expiresAt: nil,
            metadata: nil
        )
    }
} 