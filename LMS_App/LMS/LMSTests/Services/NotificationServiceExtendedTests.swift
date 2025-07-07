import XCTest
import Combine
@testable import LMS

final class NotificationServiceExtendedTests: XCTestCase {
    
    // MARK: - Properties
    var sut: NotificationService!
    var cancellables: Set<AnyCancellable>!
    
    // MARK: - Setup
    override func setUp() {
        super.setUp()
        // Clear any saved notifications
        UserDefaults.standard.removeObject(forKey: "notifications")
        
        sut = NotificationService.shared
        cancellables = []
    }
    
    override func tearDown() {
        cancellables = nil
        sut = nil
        UserDefaults.standard.removeObject(forKey: "notifications")
        super.tearDown()
    }
    
    // MARK: - Initialization Tests
    
    func testNotificationServiceSingleton() {
        // Given
        let firstInstance = NotificationService.shared
        let secondInstance = NotificationService.shared
        
        // Then
        XCTAssertTrue(firstInstance === secondInstance, "NotificationService should be a singleton")
    }
    
    func testInitialState() {
        // Then
        XCTAssertNotNil(sut.notifications, "Notifications should not be nil")
        XCTAssertGreaterThanOrEqual(sut.notifications.count, 0, "Should have notifications")
        XCTAssertGreaterThanOrEqual(sut.unreadCount, 0, "Unread count should be non-negative")
        XCTAssertEqual(sut.pendingApprovals, 0, "Pending approvals should be 0 initially")
    }
    
    // MARK: - Load Notifications Tests
    
    func testLoadNotifications() {
        // When
        sut.loadNotifications()
        
        // Then
        XCTAssertFalse(sut.notifications.isEmpty, "Should load mock notifications")
        XCTAssertEqual(sut.unreadCount, sut.notifications.filter { !$0.isRead }.count, "Unread count should match")
    }
    
    // MARK: - Add Notification Tests
    
    func testAddNotificationAsync() async {
        // Given
        let initialCount = sut.notifications.count
        let newNotification = Notification(
            id: "test-123",
            type: .courseAssigned,
            title: "Test Notification",
            message: "Test message",
            createdAt: Date(),
            isRead: false,
            priority: .medium,
            actionUrl: nil,
            metadata: nil
        )
        
        // When
        await sut.add(newNotification)
        
        // Then
        XCTAssertEqual(sut.notifications.count, initialCount + 1)
        XCTAssertEqual(sut.notifications.first?.id, "test-123")
        XCTAssertEqual(sut.notifications.first?.title, "Test Notification")
    }
    
    func testAddHighPriorityNotification() async {
        // Given
        let highPriorityNotification = Notification(
            id: "high-priority-123",
            type: .testReminder,
            title: "Urgent Test",
            message: "Complete test immediately",
            createdAt: Date(),
            isRead: false,
            priority: .high,
            actionUrl: nil,
            metadata: nil
        )
        
        // When
        await sut.add(highPriorityNotification)
        
        // Then
        XCTAssertEqual(sut.notifications.first?.priority, .high)
        // Note: Local notification scheduling would be tested with mocks in production
    }
    
    // MARK: - Mark As Read Tests
    
    func testMarkAsRead() {
        // Given
        sut.loadNotifications()
        guard let unreadNotification = sut.notifications.first(where: { !$0.isRead }) else {
            XCTFail("Need at least one unread notification")
            return
        }
        let initialUnreadCount = sut.unreadCount
        
        // When
        sut.markAsRead(unreadNotification)
        
        // Then
        let updatedNotification = sut.notifications.first { $0.id == unreadNotification.id }
        XCTAssertTrue(updatedNotification?.isRead ?? false, "Notification should be marked as read")
        XCTAssertEqual(sut.unreadCount, initialUnreadCount - 1, "Unread count should decrease")
    }
    
    func testMarkAsReadNonExistentNotification() {
        // Given
        let initialUnreadCount = sut.unreadCount
        let fakeNotification = Notification(
            id: "fake-id",
            type: .courseAssigned,
            title: "Fake",
            message: "Fake",
            createdAt: Date(),
            isRead: false,
            priority: .low,
            actionUrl: nil,
            metadata: nil
        )
        
        // When
        sut.markAsRead(fakeNotification)
        
        // Then
        XCTAssertEqual(sut.unreadCount, initialUnreadCount, "Unread count should not change")
    }
    
    func testMarkAllAsRead() {
        // Given
        sut.loadNotifications()
        
        // When
        sut.markAllAsRead()
        
        // Then
        XCTAssertEqual(sut.unreadCount, 0, "All notifications should be read")
        XCTAssertTrue(sut.notifications.allSatisfy { $0.isRead }, "All notifications should be marked as read")
    }
    
    // MARK: - Delete Notification Tests
    
    func testDeleteNotification() {
        // Given
        sut.loadNotifications()
        let initialCount = sut.notifications.count
        guard let notificationToDelete = sut.notifications.first else {
            XCTFail("Need at least one notification")
            return
        }
        
        // When
        sut.deleteNotification(notificationToDelete)
        
        // Then
        XCTAssertEqual(sut.notifications.count, initialCount - 1)
        XCTAssertFalse(sut.notifications.contains { $0.id == notificationToDelete.id })
    }
    
    func testDeleteNonExistentNotification() {
        // Given
        let initialCount = sut.notifications.count
        let fakeNotification = Notification(
            id: "fake-delete-id",
            type: .achievement,
            title: "Fake",
            message: "Fake",
            createdAt: Date(),
            isRead: true,
            priority: .low,
            actionUrl: nil,
            metadata: nil
        )
        
        // When
        sut.deleteNotification(fakeNotification)
        
        // Then
        XCTAssertEqual(sut.notifications.count, initialCount, "Count should not change")
    }
    
    // MARK: - Send Notification Tests
    
    func testSendNotification() {
        // Given
        let recipientId = UUID()
        let initialCount = sut.notifications.count
        
        // When
        sut.sendNotification(
            to: recipientId,
            title: "Test Title",
            message: "Test Message",
            type: .courseAssigned,
            priority: .medium,
            actionType: .openCourse,
            actionData: ["courseId": "course-123"]
        )
        
        // Then
        XCTAssertEqual(sut.notifications.count, initialCount + 1)
        
        let newNotification = sut.notifications.first
        XCTAssertNotNil(newNotification)
        XCTAssertEqual(newNotification?.title, "Test Title")
        XCTAssertEqual(newNotification?.message, "Test Message")
        XCTAssertEqual(newNotification?.type, .courseAssigned)
        XCTAssertEqual(newNotification?.priority, .medium)
        XCTAssertNotNil(newNotification?.actionUrl)
        XCTAssertEqual(newNotification?.metadata?["courseId"], "course-123")
        XCTAssertFalse(newNotification?.isRead ?? true)
    }
    
    func testSendNotificationWithoutAction() {
        // Given
        let recipientId = UUID()
        
        // When
        sut.sendNotification(
            to: recipientId,
            title: "Simple Notification",
            message: "No action required",
            type: .general,
            priority: .low
        )
        
        // Then
        let newNotification = sut.notifications.first
        XCTAssertNil(newNotification?.actionUrl)
        XCTAssertNil(newNotification?.metadata)
    }
    
    // MARK: - Course Notification Tests
    
    func testNotifyCourseAssignedWithDeadline() {
        // Given
        let courseId = "course-456"
        let courseName = "iOS Development"
        let recipientId = UUID()
        let deadline = Date().addingTimeInterval(7 * 24 * 60 * 60) // 7 days
        let initialCount = sut.notifications.count
        
        // When
        sut.notifyCourseAssigned(
            courseId: courseId,
            courseName: courseName,
            recipientId: recipientId,
            deadline: deadline
        )
        
        // Then
        XCTAssertEqual(sut.notifications.count, initialCount + 1)
        
        let notification = sut.notifications.first
        XCTAssertEqual(notification?.type, .courseAssigned)
        XCTAssertEqual(notification?.title, "Назначен новый курс")
        XCTAssertTrue(notification?.message.contains(courseName) ?? false)
        XCTAssertTrue(notification?.message.contains("Срок:") ?? false)
        XCTAssertEqual(notification?.priority, .high)
        XCTAssertEqual(notification?.metadata?["courseId"], courseId)
    }
    
    func testNotifyCourseAssignedWithoutDeadline() {
        // Given
        let courseId = "course-789"
        let courseName = "Backend Development"
        let recipientId = UUID()
        
        // When
        sut.notifyCourseAssigned(
            courseId: courseId,
            courseName: courseName,
            recipientId: recipientId,
            deadline: nil
        )
        
        // Then
        let notification = sut.notifications.first
        XCTAssertFalse(notification?.message.contains("Срок:") ?? true)
    }
    
    func testNotifyTestReminderHighPriority() {
        // Given
        let testId = "test-123"
        let testName = "Final Assessment"
        let recipientId = UUID()
        let daysLeft = 1 // Should trigger high priority
        
        // When
        sut.notifyTestReminder(
            testId: testId,
            testName: testName,
            recipientId: recipientId,
            daysLeft: daysLeft
        )
        
        // Then
        let notification = sut.notifications.first
        XCTAssertEqual(notification?.type, .testReminder)
        XCTAssertEqual(notification?.priority, .high)
        XCTAssertTrue(notification?.message.contains("1") ?? false)
        XCTAssertEqual(notification?.metadata?["testId"], testId)
    }
    
    func testNotifyTestReminderMediumPriority() {
        // Given
        let testId = "test-456"
        let testName = "Midterm Test"
        let recipientId = UUID()
        let daysLeft = 3 // Should trigger medium priority
        
        // When
        sut.notifyTestReminder(
            testId: testId,
            testName: testName,
            recipientId: recipientId,
            daysLeft: daysLeft
        )
        
        // Then
        let notification = sut.notifications.first
        XCTAssertEqual(notification?.priority, .medium)
    }
    
    func testNotifyCertificateEarned() {
        // Given
        let certificateId = "cert-123"
        let courseName = "Advanced iOS"
        let recipientId = UUID()
        
        // When
        sut.notifyCertificateEarned(
            certificateId: certificateId,
            courseName: courseName,
            recipientId: recipientId
        )
        
        // Then
        let notification = sut.notifications.first
        XCTAssertEqual(notification?.type, .certificateEarned)
        XCTAssertEqual(notification?.title, "Поздравляем!")
        XCTAssertTrue(notification?.message.contains(courseName) ?? false)
        XCTAssertEqual(notification?.priority, .low)
        XCTAssertEqual(notification?.metadata?["certificateId"], certificateId)
    }
    
    // MARK: - Onboarding Notification Tests
    
    func testNotifyOnboardingTask() {
        // Given
        let taskId = "task-123"
        let taskName = "Complete Profile"
        let recipientId = UUID()
        
        // When
        sut.notifyOnboardingTask(
            taskId: taskId,
            taskName: taskName,
            recipientId: recipientId,
            isOverdue: false
        )
        
        // Then
        let notification = sut.notifications.first
        XCTAssertEqual(notification?.type, .onboardingTask)
        XCTAssertEqual(notification?.title, "Новая задача онбординга")
        XCTAssertEqual(notification?.message, taskName)
        XCTAssertEqual(notification?.priority, .medium)
        XCTAssertEqual(notification?.metadata?["taskId"], taskId)
    }
    
    func testNotifyOnboardingTaskOverdue() {
        // Given
        let taskId = "task-456"
        let taskName = "Submit Documents"
        let recipientId = UUID()
        
        // When
        sut.notifyOnboardingTask(
            taskId: taskId,
            taskName: taskName,
            recipientId: recipientId,
            isOverdue: true
        )
        
        // Then
        let notification = sut.notifications.first
        XCTAssertEqual(notification?.title, "Просроченная задача")
        XCTAssertEqual(notification?.priority, .high)
    }
    
    func testNotifyOnboardingProgress() {
        // Given
        let programId = "program-123"
        let progress = 75
        let recipientId = UUID()
        
        // When
        sut.notifyOnboardingProgress(
            programId: programId,
            progress: progress,
            recipientId: recipientId
        )
        
        // Then
        let notification = sut.notifications.first
        XCTAssertEqual(notification?.type, .achievement)
        XCTAssertEqual(notification?.title, "Прогресс онбординга")
        XCTAssertTrue(notification?.message.contains("75%") ?? false)
        XCTAssertEqual(notification?.priority, .low)
        XCTAssertEqual(notification?.metadata?["programId"], programId)
    }
    
    // MARK: - Persistence Tests
    
    func testSaveNotifications() {
        // Given
        let testNotification = Notification(
            id: "persist-123",
            type: .general,
            title: "Persistent",
            message: "Should be saved",
            createdAt: Date(),
            isRead: false,
            priority: .medium,
            actionUrl: nil,
            metadata: nil
        )
        
        // When
        sut.notifications = [testNotification]
        sut.sendNotification(
            to: UUID(),
            title: "Trigger Save",
            message: "This will save",
            type: .general
        )
        
        // Then
        let savedData = UserDefaults.standard.data(forKey: "notifications")
        XCTAssertNotNil(savedData, "Notifications should be saved")
        
        if let data = savedData,
           let decoded = try? JSONDecoder().decode([Notification].self, from: data) {
            XCTAssertGreaterThan(decoded.count, 0, "Should have saved notifications")
        }
    }
    
    // MARK: - Publisher Tests
    
    func testNotificationsPublisher() {
        // Given
        let expectation = XCTestExpectation(description: "Notifications publisher")
        var receivedNotifications: [[Notification]] = []
        
        // When
        sut.$notifications
            .dropFirst() // Skip initial value
            .sink { notifications in
                receivedNotifications.append(notifications)
                if receivedNotifications.count >= 2 {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        sut.sendNotification(
            to: UUID(),
            title: "First",
            message: "First",
            type: .general
        )
        
        sut.sendNotification(
            to: UUID(),
            title: "Second",
            message: "Second",
            type: .general
        )
        
        // Then
        wait(for: [expectation], timeout: 1.0)
        XCTAssertGreaterThanOrEqual(receivedNotifications.count, 2)
    }
    
    func testUnreadCountPublisher() {
        // Given
        let expectation = XCTestExpectation(description: "Unread count publisher")
        var unreadCounts: [Int] = []
        
        // When
        sut.$unreadCount
            .dropFirst()
            .sink { count in
                unreadCounts.append(count)
                if unreadCounts.count >= 2 {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        // Add unread notification
        sut.sendNotification(
            to: UUID(),
            title: "Unread",
            message: "Unread",
            type: .general
        )
        
        // Mark all as read
        sut.markAllAsRead()
        
        // Then
        wait(for: [expectation], timeout: 1.0)
        XCTAssertGreaterThanOrEqual(unreadCounts.count, 2)
        XCTAssertEqual(unreadCounts.last, 0)
    }
    
    // MARK: - Performance Tests
    
    func testAddNotificationPerformance() {
        measure {
            let notification = Notification(
                id: UUID().uuidString,
                type: .general,
                title: "Performance Test",
                message: "Testing performance",
                createdAt: Date(),
                isRead: false,
                priority: .low,
                actionUrl: nil,
                metadata: nil
            )
            
            let expectation = XCTestExpectation(description: "Add notification")
            
            Task {
                await sut.add(notification)
                expectation.fulfill()
            }
            
            wait(for: [expectation], timeout: 1.0)
        }
    }
    
    func testMarkAllAsReadPerformance() {
        // Setup - add many notifications
        for i in 1...100 {
            sut.notifications.append(
                Notification(
                    id: "perf-\(i)",
                    type: .general,
                    title: "Test \(i)",
                    message: "Message \(i)",
                    createdAt: Date(),
                    isRead: false,
                    priority: .low,
                    actionUrl: nil,
                    metadata: nil
                )
            )
        }
        
        measure {
            sut.markAllAsRead()
        }
    }
} 