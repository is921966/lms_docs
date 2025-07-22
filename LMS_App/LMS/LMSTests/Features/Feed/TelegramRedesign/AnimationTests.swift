import XCTest
import SwiftUI
@testable import LMS

@MainActor
final class AnimationTests: XCTestCase {
    
    func testMessageAppearanceAnimation() {
        // Given
        let viewModel = TelegramFeedViewModel()
        let initialCount = viewModel.channels.count
        
        // When
        let newChannel = FeedChannel(
            id: UUID(),
            name: "New Channel",
            avatarType: .icon("star", .yellow),
            lastMessage: FeedMessage(
                id: UUID(),
                text: "New message",
                timestamp: Date(),
                author: "System",
                isRead: false
            ),
            unreadCount: 1,
            category: .announcement,
            priority: .high
        )
        viewModel.channels.insert(newChannel, at: 0)
        
        // Then
        XCTAssertEqual(viewModel.channels.count, initialCount + 1)
        XCTAssertEqual(viewModel.channels.first?.id, newChannel.id)
    }
    
    func testLazyLoadingPerformance() {
        // Given
        let viewModel = TelegramFeedViewModel()
        
        // When - Create 100 channels
        let channels = (0..<100).map { index in
            FeedChannel(
                id: UUID(),
                name: "Channel \(index)",
                avatarType: .icon("star", .blue),
                lastMessage: FeedMessage(
                    id: UUID(),
                    text: "Message \(index)",
                    timestamp: Date().addingTimeInterval(Double(-index)),
                    author: "User \(index)",
                    isRead: index % 2 == 0
                ),
                unreadCount: index % 5,
                category: NewsCategory.allCases.randomElement()!,
                priority: ChannelPriority.allCases.randomElement()!
            )
        }
        
        let startTime = Date()
        viewModel.channels = channels
        let endTime = Date()
        
        // Then - Should be fast
        let timeInterval = endTime.timeIntervalSince(startTime)
        XCTAssertLessThan(timeInterval, 0.1, "Setting 100 channels should take less than 100ms")
    }
    
    func testSortingPerformance() {
        // Given
        let viewModel = TelegramFeedViewModel()
        let channels = (0..<50).map { index in
            FeedChannel(
                id: UUID(),
                name: "Channel \(index)",
                avatarType: .icon("star", .blue),
                lastMessage: FeedMessage.mock,
                unreadCount: index,
                category: .announcement,
                priority: index % 2 == 0 ? .high : .normal,
                isPinned: index % 10 == 0
            )
        }
        viewModel.channels = channels
        
        // When
        let startTime = Date()
        viewModel.togglePin(channels[25])
        let endTime = Date()
        
        // Then
        let timeInterval = endTime.timeIntervalSince(startTime)
        XCTAssertLessThan(timeInterval, 0.05, "Sorting after pin toggle should take less than 50ms")
    }
    
    func testSearchPerformance() {
        // Given
        let viewModel = TelegramFeedViewModel()
        viewModel.channels = (0..<100).map { index in
            FeedChannel(
                id: UUID(),
                name: "Channel \(index)",
                avatarType: .icon("star", .blue),
                lastMessage: FeedMessage(
                    id: UUID(),
                    text: "Message text \(index)",
                    timestamp: Date(),
                    author: "Author",
                    isRead: false
                ),
                unreadCount: 1,
                category: .announcement,
                priority: .normal
            )
        }
        
        // When
        let startTime = Date()
        viewModel.searchText = "50"
        _ = viewModel.filteredChannels
        let endTime = Date()
        
        // Then
        let timeInterval = endTime.timeIntervalSince(startTime)
        XCTAssertLessThan(timeInterval, 0.01, "Search should complete in less than 10ms")
    }
} 