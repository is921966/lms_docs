//
//  NotificationServiceQuickTest.swift
//  LMSTests
//
//  Quick tests for NotificationService - Sprint 41 Day 3
//

import XCTest
@testable import LMS

final class NotificationServiceQuickTest: XCTestCase {
    
    func testNotificationServiceBasicFunctionality() async throws {
        // Given
        let repository = MockNotificationRepository()
        let expectation = self.expectation(description: "Service created")
        var service: NotificationService!
        
        // Create service on MainActor
        Task { @MainActor in
            service = NotificationService(repository: repository)
            expectation.fulfill()
        }
        await fulfillment(of: [expectation], timeout: 1.0)
        
        // Test 1: Initial state
        await MainActor.run {
            XCTAssertEqual(service.unreadCount, 0)
            XCTAssertFalse(service.isLoading)
            XCTAssertFalse(service.hasNewNotifications)
        }
        
        // Test 2: Send test notification
        try await service.sendTestNotification(type: .courseAssigned)
        
        await MainActor.run {
            XCTAssertTrue(service.hasNewNotifications)
        }
        
        // Test 3: Fetch notifications
        let response = try await service.fetchNotifications()
        XCTAssertEqual(response.items.count, 1)
        XCTAssertEqual(response.items.first?.type, .courseAssigned)
        
        // Test 4: Mark as read
        if let notification = response.items.first {
            try await service.markAsRead(notification)
            
            let updated = try await repository.getNotification(id: notification.id)
            XCTAssertNotNil(updated)
            XCTAssertTrue(updated!.isRead)
        }
        
        // Test 5: Clear flag
        await MainActor.run {
            service.clearNewNotificationFlag()
            XCTAssertFalse(service.hasNewNotifications)
        }
        
        print("✅ All NotificationService quick tests passed!")
    }
} 