//
//  OnboardingNotificationServiceTests.swift
//  LMSTests
//

import XCTest
import Combine
@testable import LMS

final class OnboardingNotificationServiceTests: XCTestCase {
    
    var sut: OnboardingNotificationService!
    var notificationService: NotificationService!
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        notificationService = NotificationService.shared
        sut = OnboardingNotificationService(notificationService: notificationService)
        cancellables = []
        // Clear notifications
        notificationService.notifications.removeAll()
    }
    
    override func tearDown() {
        notificationService.notifications.removeAll()
        cancellables = nil
        sut = nil
        super.tearDown()
    }
    
    // MARK: - Initialization Tests
    
    func testInitialization() {
        XCTAssertNotNil(sut)
        XCTAssertNotNil(sut.notificationService)
    }
    
    // MARK: - Welcome Notification Tests
    
    func testSendWelcomeNotification() {
        // Given
        let userId = "user123"
        let userName = "John Doe"
        
        // When
        sut.sendWelcomeNotification(userId: userId, userName: userName)
        
        // Then
        XCTAssertEqual(notificationService.notifications.count, 1)
        let notification = notificationService.notifications.first
        XCTAssertEqual(notification?.type, .system)
        XCTAssertEqual(notification?.priority, .low)
        XCTAssertTrue(notification?.title.contains("Добро пожаловать") ?? false)
        XCTAssertTrue(notification?.message.contains(userName) ?? false)
    }
    
    // MARK: - Program Assignment Tests
    
    func testNotifyProgramAssigned() {
        // Given
        let userId = "user123"
        let programName = "iOS Developer Onboarding"
        let programId = "prog123"
        
        // When
        sut.notifyProgramAssigned(
            userId: userId,
            programName: programName,
            programId: programId
        )
        
        // Then
        XCTAssertEqual(notificationService.notifications.count, 1)
        let notification = notificationService.notifications.first
        XCTAssertEqual(notification?.type, .courseAssigned)
        XCTAssertEqual(notification?.priority, .high)
        XCTAssertTrue(notification?.title.contains("программа") ?? false)
        XCTAssertTrue(notification?.message.contains(programName) ?? false)
        XCTAssertEqual(notification?.actionUrl, "lms://onboarding/\(programId)")
    }
    
    // MARK: - Task Reminder Tests
    
    func testNotifyTaskDeadline() {
        // Given
        let userId = "user123"
        let taskName = "Complete Profile"
        let taskId = "task123"
        let daysLeft = 3
        
        // When
        sut.notifyTaskDeadline(
            userId: userId,
            taskName: taskName,
            taskId: taskId,
            daysLeft: daysLeft
        )
        
        // Then
        XCTAssertEqual(notificationService.notifications.count, 1)
        let notification = notificationService.notifications.first
        XCTAssertEqual(notification?.type, .testReminder)
        XCTAssertEqual(notification?.priority, .high)
        XCTAssertTrue(notification?.title.contains("задача") ?? false)
        XCTAssertTrue(notification?.message.contains(taskName) ?? false)
        XCTAssertTrue(notification?.message.contains("\(daysLeft)") ?? false)
    }
    
    func testNotifyTaskOverdue() {
        // Given
        let userId = "user123"
        let taskName = "Submit Documents"
        let taskId = "task456"
        
        // When
        sut.notifyTaskOverdue(
            userId: userId,
            taskName: taskName,
            taskId: taskId
        )
        
        // Then
        XCTAssertEqual(notificationService.notifications.count, 1)
        let notification = notificationService.notifications.first
        XCTAssertEqual(notification?.type, .testReminder)
        XCTAssertEqual(notification?.priority, .critical)
        XCTAssertTrue(notification?.title.contains("Просроченная задача") ?? false)
        XCTAssertTrue(notification?.message.contains(taskName) ?? false)
    }
    
    // MARK: - Progress Update Tests
    
    func testNotifyMilestoneReached() {
        // Given
        let userId = "user123"
        let milestoneName = "First Week Completed"
        let progress = 25
        
        // When
        sut.notifyMilestoneReached(
            userId: userId,
            milestoneName: milestoneName,
            progress: progress
        )
        
        // Then
        XCTAssertEqual(notificationService.notifications.count, 1)
        let notification = notificationService.notifications.first
        XCTAssertEqual(notification?.type, .achievement)
        XCTAssertEqual(notification?.priority, .medium)
        XCTAssertTrue(notification?.title.contains("Достижение") ?? false)
        XCTAssertTrue(notification?.message.contains(milestoneName) ?? false)
        XCTAssertTrue(notification?.message.contains("\(progress)%") ?? false)
    }
    
    func testNotifyOnboardingCompleted() {
        // Given
        let userId = "user123"
        let programName = "Basic Onboarding"
        
        // When
        sut.notifyOnboardingCompleted(
            userId: userId,
            programName: programName
        )
        
        // Then
        XCTAssertEqual(notificationService.notifications.count, 1)
        let notification = notificationService.notifications.first
        XCTAssertEqual(notification?.type, .achievement)
        XCTAssertEqual(notification?.priority, .high)
        XCTAssertTrue(notification?.title.contains("Поздравляем") ?? false)
        XCTAssertTrue(notification?.message.contains(programName) ?? false)
    }
    
    // MARK: - Manager Notification Tests
    
    func testNotifyManagerAboutNewEmployee() {
        // Given
        let managerId = "manager123"
        let employeeName = "Jane Smith"
        let employeeId = "emp456"
        
        // When
        sut.notifyManagerAboutNewEmployee(
            managerId: managerId,
            employeeName: employeeName,
            employeeId: employeeId
        )
        
        // Then
        XCTAssertEqual(notificationService.notifications.count, 1)
        let notification = notificationService.notifications.first
        XCTAssertEqual(notification?.type, .system)
        XCTAssertEqual(notification?.priority, .medium)
        XCTAssertTrue(notification?.title.contains("Новый сотрудник") ?? false)
        XCTAssertTrue(notification?.message.contains(employeeName) ?? false)
        XCTAssertEqual(notification?.actionUrl, "lms://employees/\(employeeId)")
    }
    
    func testNotifyManagerAboutEmployeeProgress() {
        // Given
        let managerId = "manager123"
        let employeeName = "John Doe"
        let progress = 75
        
        // When
        sut.notifyManagerAboutEmployeeProgress(
            managerId: managerId,
            employeeName: employeeName,
            progress: progress
        )
        
        // Then
        XCTAssertEqual(notificationService.notifications.count, 1)
        let notification = notificationService.notifications.first
        XCTAssertEqual(notification?.type, .info)
        XCTAssertEqual(notification?.priority, .low)
        XCTAssertTrue(notification?.message.contains(employeeName) ?? false)
        XCTAssertTrue(notification?.message.contains("\(progress)%") ?? false)
    }
    
    // MARK: - Batch Notification Tests
    
    func testSendMultipleNotifications() {
        // Given
        let userId = "user123"
        
        // When
        sut.sendWelcomeNotification(userId: userId, userName: "Test User")
        sut.notifyProgramAssigned(userId: userId, programName: "Test Program", programId: "prog1")
        sut.notifyTaskDeadline(userId: userId, taskName: "Test Task", taskId: "task1", daysLeft: 2)
        
        // Then
        XCTAssertEqual(notificationService.notifications.count, 3)
        
        // Check notification types
        let types = notificationService.notifications.map { $0.type }
        XCTAssertTrue(types.contains(.system))
        XCTAssertTrue(types.contains(.courseAssigned))
        XCTAssertTrue(types.contains(.testReminder))
    }
    
    // MARK: - Helper Tests
    
    func testNotificationMetadata() {
        // Given
        let userId = "user123"
        let programId = "prog123"
        
        // When
        sut.notifyProgramAssigned(
            userId: userId,
            programName: "Test Program",
            programId: programId
        )
        
        // Then
        let notification = notificationService.notifications.first
        XCTAssertNotNil(notification?.metadata)
        XCTAssertEqual(notification?.metadata?["programId"] as? String, programId)
        XCTAssertEqual(notification?.metadata?["type"] as? String, "onboarding")
    }
}

// MARK: - Test Extension

extension OnboardingNotificationService {
    convenience init(notificationService: NotificationService) {
        self.init()
        self.notificationService = notificationService
    }
    
    var notificationService: NotificationService {
        NotificationService.shared
    }
} 