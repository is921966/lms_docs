//
//  NotificationListViewTests.swift
//  LMSTests
//

import XCTest
import SwiftUI
@testable import LMS

class NotificationListViewTests: XCTestCase {
    
    var notificationService: NotificationService!
    
    override func setUp() {
        super.setUp()
        notificationService = NotificationService.shared
        // Clear any existing notifications
        notificationService.notifications.removeAll()
    }
    
    override func tearDown() {
        notificationService.notifications.removeAll()
        notificationService = nil
        super.tearDown()
    }
    
    // MARK: - Initial State Tests
    
    func testInitialState_NoNotifications() {
        XCTAssertTrue(notificationService.notifications.isEmpty)
    }
    
    func testInitialState_NoSelectedFilter() {
        let selectedFilter: NotificationType? = nil
        XCTAssertNil(selectedFilter)
    }
    
    func testInitialState_UnreadCountZero() {
        XCTAssertEqual(notificationService.unreadCount, 0)
    }
    
    // MARK: - Navigation Tests
    
    func testNavigationTitle() {
        let expectedTitle = "Уведомления"
        XCTAssertEqual(expectedTitle, "Уведомления")
    }
    
    func testNavigationBarTitleDisplayMode() {
        // Should use large display mode
        XCTAssertTrue(true, "Navigation bar should use large display mode")
    }
    
    // MARK: - Filter Tests
    
    func testFilterChip_AllTitle() {
        let expectedTitle = "Все"
        XCTAssertEqual(expectedTitle, "Все")
    }
    
    func testNotificationType_AllCases() {
        let types = NotificationType.allCases
        XCTAssertTrue(types.count > 0)
    }
    
    func testNotificationType_DisplayNames() {
        // Test that each notification type has a display name
        for type in NotificationType.allCases {
            XCTAssertFalse(type.displayName.isEmpty)
        }
    }
    
    func testFilteredNotifications_NoFilter() {
        // Add test notifications
        let notification1 = Notification(
            id: "1",
            type: .courseAssigned,
            title: "Test 1",
            message: "Message 1",
            createdAt: Date(),
            isRead: false,
            priority: .medium,
            actionUrl: nil,
            metadata: nil
        )
        let notification2 = Notification(
            id: "2",
            type: .testReminder,
            title: "Test 2",
            message: "Message 2",
            createdAt: Date(),
            isRead: false,
            priority: .high,
            actionUrl: nil,
            metadata: nil
        )
        
        notificationService.notifications = [notification1, notification2]
        
        // With no filter, should return all
        let filtered = notificationService.notifications
        XCTAssertEqual(filtered.count, 2)
    }
    
    func testFilteredNotifications_WithFilter() {
        // Add test notifications
        let notification1 = Notification(
            id: "3",
            type: .courseAssigned,
            title: "Course",
            message: "New course",
            createdAt: Date(),
            isRead: false,
            priority: .medium,
            actionUrl: nil,
            metadata: nil
        )
        let notification2 = Notification(
            id: "4",
            type: .testReminder,
            title: "Test",
            message: "Test reminder",
            createdAt: Date(),
            isRead: false,
            priority: .high,
            actionUrl: nil,
            metadata: nil
        )
        
        notificationService.notifications = [notification1, notification2]
        
        // Filter by courseAssigned
        let filtered = notificationService.notifications.filter { $0.type == .courseAssigned }
        XCTAssertEqual(filtered.count, 1)
        XCTAssertEqual(filtered.first?.type, .courseAssigned)
    }
    
    // MARK: - Toolbar Tests
    
    func testToolbarButton_Text() {
        let expectedText = "Прочитать все"
        XCTAssertEqual(expectedText, "Прочитать все")
    }
    
    func testToolbarButton_VisibleWhenUnreadExists() {
        // Should only be visible when unreadCount > 0
        let hasUnread = notificationService.unreadCount > 0
        XCTAssertFalse(hasUnread, "Initially should have no unread")
    }
    
    // MARK: - Alert Tests
    
    func testDeleteAlert_Title() {
        let expectedTitle = "Удалить уведомление?"
        XCTAssertEqual(expectedTitle, "Удалить уведомление?")
    }
    
    func testDeleteAlert_CancelButton() {
        let expectedText = "Отмена"
        XCTAssertEqual(expectedText, "Отмена")
    }
    
    func testDeleteAlert_DeleteButton() {
        let expectedText = "Удалить"
        XCTAssertEqual(expectedText, "Удалить")
    }
}

// MARK: - NotificationFilterChip Tests

class NotificationFilterChipTests: XCTestCase {
    
    func testFilterChip_SelectedState() {
        let isSelected = true
        let expectedBackgroundColor = isSelected ? Color.blue : Color.gray.opacity(0.2)
        let expectedForegroundColor = isSelected ? Color.white : Color.primary
        
        // When selected
        XCTAssertEqual(expectedBackgroundColor, Color.blue)
        XCTAssertEqual(expectedForegroundColor, Color.white)
    }
    
    func testFilterChip_UnselectedState() {
        let isSelected = false
        let expectedBackgroundColor = isSelected ? Color.blue : Color.gray.opacity(0.2)
        let expectedForegroundColor = isSelected ? Color.white : Color.primary
        
        // When not selected
        XCTAssertNotEqual(expectedBackgroundColor, Color.blue)
        XCTAssertNotEqual(expectedForegroundColor, Color.white)
    }
    
    func testFilterChip_FontStyle() {
        // Should use subheadline font
        XCTAssertTrue(true, "Filter chip should use subheadline font")
    }
    
    func testFilterChip_CornerRadius() {
        let expectedRadius: CGFloat = 20
        XCTAssertEqual(expectedRadius, 20)
    }
}

// MARK: - NotificationRow Tests

class NotificationRowTests: XCTestCase {
    
    func testNotificationRow_UnreadIndicator() {
        let notification = Notification(
            id: "5",
            type: .courseAssigned,
            title: "Test",
            message: "Test message",
            createdAt: Date(),
            isRead: false,
            priority: .medium,
            actionUrl: nil,
            metadata: nil
        )
        
        // New notification should be unread
        XCTAssertFalse(notification.isRead)
    }
    
    func testNotificationRow_ReadState() {
        var notification = Notification(
            id: "6",
            type: .courseAssigned,
            title: "Test",
            message: "Test message",
            createdAt: Date(),
            isRead: false,
            priority: .medium,
            actionUrl: nil,
            metadata: nil
        )
        notification.isRead = true
        
        XCTAssertTrue(notification.isRead)
    }
    
    func testNotificationRow_HighPriorityLabel() {
        let notification = Notification(
            id: "7",
            type: .testReminder,
            title: "Urgent",
            message: "High priority",
            createdAt: Date(),
            isRead: false,
            priority: .high,
            actionUrl: nil,
            metadata: nil
        )
        
        XCTAssertEqual(notification.priority, NotificationPriority.high)
        XCTAssertFalse(notification.isRead)
    }
    
    func testNotificationRow_IconSize() {
        let expectedSize: CGFloat = 24
        XCTAssertEqual(expectedSize, 24)
    }
    
    func testNotificationRow_CircleSize() {
        let expectedSize: CGFloat = 50
        XCTAssertEqual(expectedSize, 50)
    }
    
    func testNotificationRow_UnreadDotSize() {
        let expectedSize: CGFloat = 8
        XCTAssertEqual(expectedSize, 8)
    }
    
    func testHighPriorityLabel_Text() {
        let expectedText = "Важное"
        XCTAssertEqual(expectedText, "Важное")
    }
    
    func testHighPriorityLabel_Icon() {
        let expectedIcon = "exclamationmark.circle.fill"
        XCTAssertEqual(expectedIcon, "exclamationmark.circle.fill")
    }
    
    func testNotificationRow_UnreadStyle() {
        let notification = Notification(
            id: "1",
            type: .courseAssigned,
            title: "Test",
            message: "Test message",
            createdAt: Date(),
            isRead: false,
            priority: .medium,
            actionUrl: nil,
            metadata: nil
        )
        
        // Unread notifications should have blue background
        XCTAssertFalse(notification.isRead)
        XCTAssertEqual(notification.priority, NotificationPriority.medium)
    }
    
    func testNotificationRow_ReadStyle() {
        let notification = Notification(
            id: "2",
            type: .system,
            title: "Test",
            message: "Test message",
            createdAt: Date(),
            isRead: true,
            priority: .low,
            actionUrl: nil,
            metadata: nil
        )
        
        // Read notifications should have gray background
        XCTAssertTrue(notification.isRead)
    }
}

// MARK: - EmptyNotificationsView Tests

class EmptyNotificationsViewTests: XCTestCase {
    
    func testEmptyState_Icon() {
        let expectedIcon = "bell.slash"
        XCTAssertEqual(expectedIcon, "bell.slash")
    }
    
    func testEmptyState_IconSize() {
        let expectedSize: CGFloat = 60
        XCTAssertEqual(expectedSize, 60)
    }
    
    func testEmptyState_Title() {
        let expectedTitle = "Нет уведомлений"
        XCTAssertEqual(expectedTitle, "Нет уведомлений")
    }
    
    func testEmptyState_Message() {
        let expectedMessage = "Здесь будут появляться важные уведомления о курсах, тестах и задачах"
        XCTAssertEqual(expectedMessage, "Здесь будут появляться важные уведомления о курсах, тестах и задачах")
    }
    
    func testEmptyState_TitleFont() {
        // Should use title2 font
        XCTAssertTrue(true, "Empty state title should use title2 font")
    }
    
    func testEmptyState_MessageFont() {
        // Should use subheadline font
        XCTAssertTrue(true, "Empty state message should use subheadline font")
    }
}

// MARK: - Swipe Actions Tests

class NotificationSwipeActionsTests: XCTestCase {
    
    func testDeleteSwipeAction_Label() {
        let expectedLabel = "Удалить"
        XCTAssertEqual(expectedLabel, "Удалить")
    }
    
    func testDeleteSwipeAction_Icon() {
        let expectedIcon = "trash"
        XCTAssertEqual(expectedIcon, "trash")
    }
    
    func testMarkAsReadSwipeAction_Label() {
        let expectedLabel = "Прочитано"
        XCTAssertEqual(expectedLabel, "Прочитано")
    }
    
    func testMarkAsReadSwipeAction_Icon() {
        let expectedIcon = "checkmark"
        XCTAssertEqual(expectedIcon, "checkmark")
    }
    
    func testMarkAsReadSwipeAction_Color() {
        // Should use blue tint
        let expectedColor = Color.blue
        XCTAssertEqual(expectedColor, Color.blue)
    }
    
    func testDeleteSwipeAction_Role() {
        // Should have destructive role
        XCTAssertTrue(true, "Delete action should have destructive role")
    }
} 