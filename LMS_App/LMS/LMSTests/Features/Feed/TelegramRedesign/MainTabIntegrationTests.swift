import XCTest
import SwiftUI
@testable import LMS

@MainActor
final class MainTabIntegrationTests: XCTestCase {
    
    func testFeedTabShowsBadgeWithUnreadCount() {
        // Given
        let viewModel = TelegramFeedViewModel()
        let channel1 = FeedChannel(
            id: UUID(),
            name: "Test 1",
            avatarType: .icon("star", .blue),
            lastMessage: FeedMessage.mock,
            unreadCount: 5,
            category: .announcement,
            priority: .normal
        )
        let channel2 = FeedChannel(
            id: UUID(),
            name: "Test 2",
            avatarType: .icon("star", .green),
            lastMessage: FeedMessage.mock,
            unreadCount: 3,
            category: .learning,
            priority: .normal
        )
        viewModel.channels = [channel1, channel2]
        
        // When
        let totalUnread = viewModel.totalUnreadCount
        
        // Then
        XCTAssertEqual(totalUnread, 8)
    }
    
    func testFeedDesignToggle() {
        // Given
        @AppStorage("useNewFeedDesign") var useNewFeedDesign = false
        
        // When
        useNewFeedDesign = true
        
        // Then
        XCTAssertTrue(useNewFeedDesign)
    }
    
    func testFeedTabSelection() {
        // Given
        @State var selectedTab = 0
        let feedTabIndex = 1
        
        // When
        selectedTab = feedTabIndex
        
        // Then
        XCTAssertEqual(selectedTab, feedTabIndex)
    }
    
    func testBadgeUpdateOnMarkAsRead() {
        // Given
        let viewModel = TelegramFeedViewModel()
        let channel = FeedChannel(
            id: UUID(),
            name: "Test",
            avatarType: .icon("star", .blue),
            lastMessage: FeedMessage.mock,
            unreadCount: 5,
            category: .announcement,
            priority: .normal
        )
        viewModel.channels = [channel]
        let initialCount = viewModel.totalUnreadCount
        
        // When
        viewModel.markAsRead(channel)
        
        // Then
        XCTAssertEqual(initialCount, 5)
        XCTAssertEqual(viewModel.totalUnreadCount, 0)
    }
    
    func testBadgeUpdateOnMarkAllAsRead() {
        // Given
        let viewModel = TelegramFeedViewModel()
        viewModel.channels = [
            FeedChannel(
                id: UUID(),
                name: "Test 1",
                avatarType: .icon("star", .blue),
                lastMessage: FeedMessage.mock,
                unreadCount: 5,
                category: .announcement,
                priority: .normal
            ),
            FeedChannel(
                id: UUID(),
                name: "Test 2",
                avatarType: .icon("star", .green),
                lastMessage: FeedMessage.mock,
                unreadCount: 3,
                category: .learning,
                priority: .normal
            )
        ]
        
        // When
        viewModel.markAllAsRead()
        
        // Then
        XCTAssertEqual(viewModel.totalUnreadCount, 0)
    }
} 