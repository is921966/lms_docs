import XCTest
import SwiftUI
@testable import LMS

@MainActor
final class SwipeActionsTests: XCTestCase {
    
    func testChannelSwipeToMarkAsRead() {
        // Given
        let channel = FeedChannel.mock
        let viewModel = TelegramFeedViewModel()
        viewModel.channels = [channel]
        
        // When
        viewModel.markAsRead(channel)
        
        // Then
        XCTAssertEqual(viewModel.channels.first?.unreadCount, 0)
        XCTAssertTrue(viewModel.channels.first?.lastMessage.isRead ?? false)
    }
    
    func testChannelSwipeToPin() {
        // Given
        let channel = FeedChannel.mock
        let viewModel = TelegramFeedViewModel()
        viewModel.channels = [channel]
        
        // When
        viewModel.togglePin(channel)
        
        // Then
        XCTAssertTrue(viewModel.channels.first?.isPinned ?? false)
    }
    
    func testChannelSwipeToUnpin() {
        // Given
        var channel = FeedChannel.mock
        channel.isPinned = true
        let viewModel = TelegramFeedViewModel()
        viewModel.channels = [channel]
        
        // When
        viewModel.togglePin(channel)
        
        // Then
        XCTAssertFalse(viewModel.channels.first?.isPinned ?? true)
    }
    
    func testChannelSwipeToMute() {
        // Given
        let channel = FeedChannel.mock
        let viewModel = TelegramFeedViewModel()
        viewModel.channels = [channel]
        
        // When
        viewModel.toggleMute(channel)
        
        // Then
        XCTAssertTrue(viewModel.channels.first?.isMuted ?? false)
    }
    
    func testMultipleSwipeActions() {
        // Given
        let channel = FeedChannel.mock
        let viewModel = TelegramFeedViewModel()
        viewModel.channels = [channel]
        
        // When
        viewModel.markAsRead(channel)
        viewModel.togglePin(channel)
        viewModel.toggleMute(channel)
        
        // Then
        let updatedChannel = viewModel.channels.first
        XCTAssertEqual(updatedChannel?.unreadCount, 0)
        XCTAssertTrue(updatedChannel?.isPinned ?? false)
        XCTAssertTrue(updatedChannel?.isMuted ?? false)
    }
    
    func testSwipeActionsWithMultipleChannels() {
        // Given
        let channels = [
            FeedChannel.mock,
            FeedChannel.mock,
            FeedChannel.mock
        ]
        let viewModel = TelegramFeedViewModel()
        viewModel.channels = channels
        
        // When
        viewModel.markAsRead(channels[1])
        
        // Then
        XCTAssertNotEqual(viewModel.channels[0].unreadCount, 0)
        XCTAssertEqual(viewModel.channels[1].unreadCount, 0)
        XCTAssertNotEqual(viewModel.channels[2].unreadCount, 0)
    }
} 