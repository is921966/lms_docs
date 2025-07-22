//
//  TelegramFeedViewModelTests.swift
//  LMSTests
//
//  Sprint 50 - День 1: Тесты для ViewModel ленты в стиле Telegram
//

import XCTest
import Combine
@testable import LMS

final class TelegramFeedViewModelTests: XCTestCase {
    
    private var viewModel: TelegramFeedViewModel!
    private var mockService: MockTelegramFeedService!
    private var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        mockService = MockTelegramFeedService()
        viewModel = TelegramFeedViewModel(feedService: mockService)
        cancellables = []
    }
    
    override func tearDown() {
        viewModel = nil
        mockService = nil
        cancellables = nil
        super.tearDown()
    }
    
    // MARK: - Initialization Tests
    
    func testViewModelInitialization() {
        XCTAssertTrue(viewModel.channels.isEmpty)
        XCTAssertTrue(viewModel.filteredChannels.isEmpty)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.error)
        XCTAssertEqual(viewModel.searchText, "")
        XCTAssertNil(viewModel.selectedCategory)
    }
    
    // MARK: - Loading Tests
    
    @MainActor
    func testLoadChannels() async {
        // Given
        let expectation = XCTestExpectation(description: "Channels loaded")
        mockService.mockChannels = createTestChannels()
        
        // When
        await viewModel.loadChannels()
        
        // Then
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertEqual(viewModel.channels.count, 3)
        XCTAssertNil(viewModel.error)
        expectation.fulfill()
        
        await fulfillment(of: [expectation], timeout: 1.0)
    }
    
    @MainActor
    func testLoadChannelsError() async {
        // Given
        mockService.shouldThrowError = true
        
        // When
        await viewModel.loadChannels()
        
        // Then
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertTrue(viewModel.channels.isEmpty)
        XCTAssertNotNil(viewModel.error)
    }
    
    // MARK: - Filtering Tests
    
    func testSearchFiltering() {
        // Given
        viewModel.channels = createTestChannels()
        
        // When searching by name
        viewModel.searchText = "админ"
        
        // Then
        XCTAssertEqual(viewModel.filteredChannels.count, 1)
        XCTAssertEqual(viewModel.filteredChannels.first?.name, "Администрация ЦУМ")
        
        // When searching by message
        viewModel.searchText = "курс"
        
        // Then
        XCTAssertEqual(viewModel.filteredChannels.count, 1)
        XCTAssertEqual(viewModel.filteredChannels.first?.name, "Учебный центр")
        
        // When empty search
        viewModel.searchText = ""
        
        // Then
        XCTAssertEqual(viewModel.filteredChannels.count, 3)
    }
    
    func testCategoryFiltering() {
        // Given
        viewModel.channels = createTestChannels()
        
        // When filtering by announcement
        viewModel.selectedCategory = .announcement
        
        // Then
        XCTAssertEqual(viewModel.filteredChannels.count, 1)
        XCTAssertEqual(viewModel.filteredChannels.first?.name, "Администрация ЦУМ")
        
        // When filtering by learning
        viewModel.selectedCategory = .learning
        
        // Then
        XCTAssertEqual(viewModel.filteredChannels.count, 1)
        XCTAssertEqual(viewModel.filteredChannels.first?.name, "Учебный центр")
        
        // When no filter
        viewModel.selectedCategory = nil
        
        // Then
        XCTAssertEqual(viewModel.filteredChannels.count, 3)
    }
    
    func testCombinedFiltering() {
        // Given
        viewModel.channels = createTestChannels()
        
        // When filtering by category and search
        viewModel.selectedCategory = .announcement
        viewModel.searchText = "график"
        
        // Then
        XCTAssertEqual(viewModel.filteredChannels.count, 1)
        XCTAssertEqual(viewModel.filteredChannels.first?.name, "Администрация ЦУМ")
        
        // When search doesn't match category
        viewModel.searchText = "курс"
        
        // Then
        XCTAssertEqual(viewModel.filteredChannels.count, 0)
    }
    
    // MARK: - Sorting Tests
    
    func testChannelSorting() {
        // Given
        let channels = [
            createChannel(name: "Normal", priority: .normal),
            createChannel(name: "Critical", priority: .critical),
            createChannel(name: "Important", priority: .important),
            createChannel(name: "Archived", priority: .archived)
        ]
        viewModel.channels = channels
        
        // Then - should be sorted by priority and time
        let sorted = viewModel.filteredChannels
        XCTAssertEqual(sorted[0].name, "Critical")
        XCTAssertEqual(sorted[1].name, "Important")
        XCTAssertEqual(sorted[2].name, "Normal")
        XCTAssertEqual(sorted[3].name, "Archived")
    }
    
    // MARK: - Unread Count Tests
    
    func testTotalUnreadCount() {
        // Given
        viewModel.channels = [
            createChannel(unreadCount: 5),
            createChannel(unreadCount: 10),
            createChannel(unreadCount: 0),
            createChannel(unreadCount: 15)
        ]
        
        // Then
        XCTAssertEqual(viewModel.totalUnreadCount, 30)
    }
    
    func testHasUnreadMessages() {
        // When no channels
        XCTAssertFalse(viewModel.hasUnreadMessages)
        
        // When all read
        viewModel.channels = [
            createChannel(unreadCount: 0),
            createChannel(unreadCount: 0)
        ]
        XCTAssertFalse(viewModel.hasUnreadMessages)
        
        // When has unread
        viewModel.channels = [
            createChannel(unreadCount: 0),
            createChannel(unreadCount: 1)
        ]
        XCTAssertTrue(viewModel.hasUnreadMessages)
    }
    
    // MARK: - Refresh Tests
    
    @MainActor
    func testRefresh() async {
        // Given
        mockService.mockChannels = createTestChannels()
        
        // When
        await viewModel.refresh()
        
        // Then
        XCTAssertEqual(viewModel.channels.count, 3)
        XCTAssertFalse(viewModel.isLoading)
    }
    
    // MARK: - Helper Methods
    
    private func createTestChannels() -> [FeedChannel] {
        [
            createChannel(
                name: "Администрация ЦУМ",
                lastMessage: "Важное объявление о графике работы",
                category: .announcement,
                priority: .critical
            ),
            createChannel(
                name: "Учебный центр",
                lastMessage: "Открыта регистрация на курс Swift",
                category: .learning,
                priority: .normal
            ),
            createChannel(
                name: "HR Департамент",
                lastMessage: "Корпоративное мероприятие",
                category: .department,
                priority: .normal
            )
        ]
    }
    
    private func createChannel(
        name: String = "Test Channel",
        lastMessage: String = "Test message",
        unreadCount: Int = 0,
        category: NewsCategory = .announcement,
        priority: FeedChannel.Priority = .normal
    ) -> FeedChannel {
        FeedChannel(
            id: UUID(),
            name: name,
            avatarType: .text(String(name.prefix(1)), category.color),
            lastMessage: lastMessage,
            lastMessageTime: Date(),
            unreadCount: unreadCount,
            category: category,
            priority: priority
        )
    }
}

// MARK: - Mock Service

class MockTelegramFeedService: TelegramFeedServiceProtocol {
    var mockChannels: [FeedChannel] = []
    var shouldThrowError = false
    
    func loadChannels() async throws -> [FeedChannel] {
        if shouldThrowError {
            throw FeedError.networkError
        }
        return mockChannels
    }
    
    func markAsRead(channelId: UUID) async throws {
        // Mock implementation
    }
    
    func createMockChannels() -> [FeedChannel] {
        mockChannels
    }
} 