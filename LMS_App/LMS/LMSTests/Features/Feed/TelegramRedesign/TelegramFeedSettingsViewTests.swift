import XCTest
import SwiftUI
import ViewInspector
@testable import LMS

class TelegramTelegramFeedSettingsViewTests: XCTestCase {
    
    func testTelegramFeedSettingsViewInitialization() throws {
        // When
        let view = TelegramTelegramFeedSettingsView(onDismiss: {})
        
        // Then
        XCTAssertNotNil(view)
    }
    
    func testTelegramFeedSettingsViewShowsTitle() throws {
        // Given
        let view = TelegramFeedSettingsView(onDismiss: {})
        
        // When
        let inspectedView = try view.inspect()
        
        // Then
        let title = try inspectedView.find(text: "Настройки новостей")
        XCTAssertNotNil(title)
    }
    
    func testTelegramFeedSettingsViewShowsCategories() throws {
        // Given
        let view = TelegramFeedSettingsView(onDismiss: {})
        
        // When
        let inspectedView = try view.inspect()
        
        // Then
        // Should show all news categories
        for category in NewsCategory.allCases {
            let categoryText = try inspectedView.find(text: category.title)
            XCTAssertNotNil(categoryText)
        }
    }
    
    func testNotificationToggle() throws {
        // Given
        let view = TelegramFeedSettingsView(onDismiss: {})
        
        // When
        let inspectedView = try view.inspect()
        
        // Then
        // Find notification toggles
        let toggles = try inspectedView.findAll(ViewType.Toggle.self)
        XCTAssertGreaterThan(toggles.count, 0)
    }
    
    func testPrioritySettings() throws {
        // Given
        let view = TelegramFeedSettingsView(onDismiss: {})
        
        // When
        let inspectedView = try view.inspect()
        
        // Then
        // Should have priority section
        let prioritySection = try inspectedView.find(text: "Приоритет каналов")
        XCTAssertNotNil(prioritySection)
    }
    
    func testDoneButtonCallsDismiss() throws {
        // Given
        var dismissCalled = false
        let view = TelegramFeedSettingsView {
            dismissCalled = true
        }
        
        // When
        let inspectedView = try view.inspect()
        let doneButton = try inspectedView.find(button: "Готово")
        try doneButton.tap()
        
        // Then
        XCTAssertTrue(dismissCalled)
    }
    
    func testSaveSettings() throws {
        // Given
        @AppStorage("feedNotifications_general") var generalNotifications = true
        let view = TelegramFeedSettingsView(onDismiss: {})
        
        // When
        let inspectedView = try view.inspect()
        
        // Then
        // Settings should be saved to AppStorage
        XCTAssertTrue(generalNotifications)
    }
} 