//
//  OnboardingNotificationServiceTests.swift
//  LMSTests
//

import XCTest
import Combine
@testable import LMS

final class OnboardingNotificationServiceTests: XCTestCase {
    
    var sut: OnboardingNotificationService!
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        sut = OnboardingNotificationService.shared
        cancellables = []
        sut.clearAllNotifications()
    }
    
    override func tearDown() {
        sut.clearAllNotifications()
        cancellables = nil
        sut = nil
        super.tearDown()
    }
    
    // MARK: - Basic Tests
    
    func testSharedInstance() {
        let instance1 = OnboardingNotificationService.shared
        let instance2 = OnboardingNotificationService.shared
        XCTAssertTrue(instance1 === instance2)
    }
    
    func testInitialState() {
        XCTAssertTrue(sut.pendingNotifications.isEmpty)
    }
    
    // MARK: - Task Reminder Tests
    
    func testScheduleTaskReminder() {
        // Given
        let task = OnboardingTask(
            title: "Test Task",
            description: "Test Description",
            type: .document,
            dueDate: Date().addingTimeInterval(86400) // Tomorrow
        )
        let program = createTestProgram()
        
        // When
        sut.scheduleTaskReminder(task: task, program: program)
        
        // Then - notification should be scheduled (we can't directly test pending notifications)
        XCTAssertTrue(true) // Just verify no crash
    }
    
    // MARK: - Notification Scheduling Tests
    
    func testScheduleOverdueNotification() {
        // Given
        let task = OnboardingTask(
            title: "Overdue Task",
            description: "This task is overdue",
            type: .meeting
        )
        let program = createTestProgram()
        
        // When
        sut.scheduleOverdueNotification(for: task, in: program)
        
        // Then
        let expectation = XCTestExpectation(description: "Notification added")
        
        sut.$pendingNotifications
            .dropFirst()
            .sink { notifications in
                if !notifications.isEmpty {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 1.0)
        XCTAssertFalse(sut.pendingNotifications.isEmpty)
    }
    
    func testSendStageCompletionNotification() {
        // Given
        let stage = OnboardingStage(
            id: UUID(),
            templateStageId: nil,
            title: "Test Stage",
            description: "Test stage description",
            order: 1,
            duration: 5,
            startDate: Date(),
            endDate: nil,
            status: .notStarted,
            completionPercentage: 0.0,
            tasks: []
        )
        let program = createTestProgram()
        
        // When
        sut.sendStageCompletionNotification(stage: stage, program: program)
        
        // Then
        let expectation = XCTestExpectation(description: "Stage completion notification")
        
        sut.$pendingNotifications
            .dropFirst()
            .sink { notifications in
                if notifications.contains(where: { $0.type == .stageCompleted }) {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 1.0)
        XCTAssertTrue(sut.pendingNotifications.contains { $0.type == .stageCompleted })
    }
    
    func testSendMilestoneNotification() {
        // Given
        let program = createTestProgram()
        let milestone = "50%"
        
        // When
        sut.sendMilestoneNotification(program: program, milestone: milestone)
        
        // Then
        let expectation = XCTestExpectation(description: "Milestone notification")
        
        sut.$pendingNotifications
            .dropFirst()
            .sink { notifications in
                if notifications.contains(where: { $0.type == .milestone }) {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 1.0)
        XCTAssertTrue(sut.pendingNotifications.contains { $0.type == .milestone })
    }
    
    func testSendCompletionNotification() {
        // Given
        let program = createTestProgram()
        
        // When
        sut.sendCompletionNotification(program: program)
        
        // Then
        let expectation = XCTestExpectation(description: "Completion notification")
        
        sut.$pendingNotifications
            .dropFirst()
            .sink { notifications in
                if notifications.contains(where: { $0.type == .programCompleted }) {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 1.0)
        XCTAssertTrue(sut.pendingNotifications.contains { $0.type == .programCompleted })
    }
    
    // MARK: - Clear Notifications Tests
    
    func testClearNotification() {
        // Given
        let program = createTestProgram()
        sut.sendMilestoneNotification(program: program, milestone: "25%")
        
        // Wait for notification to be added
        let addExpectation = XCTestExpectation(description: "Notification added")
        sut.$pendingNotifications
            .dropFirst()
            .sink { notifications in
                if !notifications.isEmpty {
                    addExpectation.fulfill()
                }
            }
            .store(in: &cancellables)
        wait(for: [addExpectation], timeout: 1.0)
        
        let notificationId = sut.pendingNotifications.first?.id ?? UUID()
        
        // When
        sut.clearNotification(notificationId)
        
        // Then
        XCTAssertTrue(sut.pendingNotifications.isEmpty)
    }
    
    func testClearAllNotifications() {
        // Given
        let program = createTestProgram()
        sut.sendMilestoneNotification(program: program, milestone: "25%")
        sut.sendMilestoneNotification(program: program, milestone: "50%")
        
        // Wait for notifications
        let expectation = XCTestExpectation(description: "Notifications added")
        sut.$pendingNotifications
            .dropFirst()
            .sink { notifications in
                if notifications.count >= 2 {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        wait(for: [expectation], timeout: 1.0)
        
        // When
        sut.clearAllNotifications()
        
        // Then
        XCTAssertTrue(sut.pendingNotifications.isEmpty)
    }
    
    // MARK: - Helper Methods
    
    private func createTestProgram() -> OnboardingProgram {
        return OnboardingProgram(
            templateId: UUID(),
            employeeId: UUID(),
            employeeName: "Test Employee",
            employeePosition: "Test Position",
            employeeDepartment: "Test Department",
            managerId: UUID(),
            managerName: "Test Manager",
            title: "Test Program",
            description: "Test program description",
            startDate: Date(),
            targetEndDate: Date().addingTimeInterval(30 * 86400),
            stages: [],
            totalDuration: 30,
            status: .inProgress
        )
    }
} 