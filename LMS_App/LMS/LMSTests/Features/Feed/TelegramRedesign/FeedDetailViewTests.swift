import XCTest
import SwiftUI
import ViewInspector
@testable import LMS

class FeedDetailViewTests: XCTestCase {
    
    func testFeedDetailViewInitialization() throws {
        // Given
        let channel = FeedChannel(
            id: UUID(),
            name: "Test Channel",
            avatarType: .text("TC"),
            lastMessage: "Last message",
            lastMessageTime: Date(),
            unreadCount: 0,
            category: .general,
            priority: .normal
        )
        
        // When
        let view = FeedDetailView(channel: channel, onBack: {})
        
        // Then
        XCTAssertNotNil(view)
    }
    
    func testFeedDetailViewShowsChannelInfo() throws {
        // Given
        let channel = FeedChannel(
            id: UUID(),
            name: "ЦУМ Новости",
            avatarType: .text("ЦН"),
            lastMessage: "Важное объявление",
            lastMessageTime: Date(),
            unreadCount: 0,
            category: .announcements,
            priority: .high
        )
        
        let view = FeedDetailView(channel: channel, onBack: {})
        
        // When
        let inspectedView = try view.inspect()
        
        // Then
        // Check navigation bar
        let navBar = try inspectedView.find(FeedDetailNavigationBar.self)
        XCTAssertNotNil(navBar)
        
        // Check channel name in nav bar
        let channelName = try navBar.find(text: "ЦУМ Новости")
        XCTAssertNotNil(channelName)
    }
    
    func testFeedDetailViewShowsMessages() throws {
        // Given
        let channel = FeedChannel(
            id: UUID(),
            name: "Test Channel",
            avatarType: .text("TC"),
            lastMessage: "Last message",
            lastMessageTime: Date(),
            unreadCount: 0,
            category: .general,
            priority: .normal
        )
        
        let view = FeedDetailView(channel: channel, onBack: {})
        
        // When
        let inspectedView = try view.inspect()
        
        // Then
        // Should contain a ScrollView for messages
        let scrollView = try inspectedView.find(ViewType.ScrollView.self)
        XCTAssertNotNil(scrollView)
    }
    
    func testBackButtonCallsOnBack() throws {
        // Given
        var backCalled = false
        let channel = FeedChannel(
            id: UUID(),
            name: "Test Channel",
            avatarType: .text("TC"),
            lastMessage: "Last message",
            lastMessageTime: Date(),
            unreadCount: 0,
            category: .general,
            priority: .normal
        )
        
        let view = FeedDetailView(channel: channel) {
            backCalled = true
        }
        
        // When
        let inspectedView = try view.inspect()
        let navBar = try inspectedView.find(FeedDetailNavigationBar.self)
        let backButton = try navBar.find(button: "arrow.left")
        try backButton.tap()
        
        // Then
        XCTAssertTrue(backCalled)
    }
    
    func testSwipeGesture() throws {
        // Given
        var backCalled = false
        let channel = FeedChannel(
            id: UUID(),
            name: "Test Channel",
            avatarType: .text("TC"),
            lastMessage: "Last message",
            lastMessageTime: Date(),
            unreadCount: 0,
            category: .general,
            priority: .normal
        )
        
        let view = FeedDetailView(channel: channel) {
            backCalled = true
        }
        
        // When
        let inspectedView = try view.inspect()
        
        // Then
        // Check that swipe gesture is attached
        let gesture = try inspectedView.find(ViewType.Gesture.self)
        XCTAssertNotNil(gesture)
    }
} 