//
//  FeedChannelTests.swift
//  LMSTests
//
//  Sprint 50 - День 1: Тесты для модели канала в стиле Telegram
//

import XCTest
@testable import LMS

final class FeedChannelTests: XCTestCase {
    
    // MARK: - Test Data
    
    private func createTestChannel(
        name: String = "Администрация ЦУМ",
        unreadCount: Int = 0,
        category: NewsCategory = .announcement
    ) -> FeedChannel {
        FeedChannel(
            id: UUID(),
            name: name,
            avatarType: .text("А", .red),
            lastMessage: "Важное объявление о графике работы...",
            lastMessageTime: Date(),
            unreadCount: unreadCount,
            category: category,
            priority: .normal
        )
    }
    
    // MARK: - Initialization Tests
    
    func testFeedChannelInitialization() {
        // Given
        let id = UUID()
        let name = "Учебный центр"
        let avatarType = FeedChannel.AvatarType.systemIcon("book.fill", .blue)
        let lastMessage = "Открыта регистрация на курс Swift"
        let lastMessageTime = Date()
        let unreadCount = 518
        let category = NewsCategory.learning
        let priority = FeedChannel.Priority.important
        
        // When
        let channel = FeedChannel(
            id: id,
            name: name,
            avatarType: avatarType,
            lastMessage: lastMessage,
            lastMessageTime: lastMessageTime,
            unreadCount: unreadCount,
            category: category,
            priority: priority
        )
        
        // Then
        XCTAssertEqual(channel.id, id)
        XCTAssertEqual(channel.name, name)
        XCTAssertEqual(channel.lastMessage, lastMessage)
        XCTAssertEqual(channel.lastMessageTime, lastMessageTime)
        XCTAssertEqual(channel.unreadCount, unreadCount)
        XCTAssertEqual(channel.category, category)
        XCTAssertEqual(channel.priority, priority)
        
        // Verify avatar type
        if case let .systemIcon(icon, color) = channel.avatarType {
            XCTAssertEqual(icon, "book.fill")
            XCTAssertEqual(color, .blue)
        } else {
            XCTFail("Avatar type should be systemIcon")
        }
    }
    
    // MARK: - Display Text Tests
    
    func testUnreadBadgeDisplayText() {
        // Test normal count
        XCTAssertEqual(createTestChannel(unreadCount: 5).unreadDisplayText, "5")
        XCTAssertEqual(createTestChannel(unreadCount: 99).unreadDisplayText, "99")
        
        // Test 100+
        XCTAssertEqual(createTestChannel(unreadCount: 100).unreadDisplayText, "100")
        XCTAssertEqual(createTestChannel(unreadCount: 999).unreadDisplayText, "999")
        
        // Test 1000+ (K format)
        XCTAssertEqual(createTestChannel(unreadCount: 1000).unreadDisplayText, "1K")
        XCTAssertEqual(createTestChannel(unreadCount: 1500).unreadDisplayText, "1K")
        XCTAssertEqual(createTestChannel(unreadCount: 2300).unreadDisplayText, "2K")
        XCTAssertEqual(createTestChannel(unreadCount: 9999).unreadDisplayText, "9K")
        XCTAssertEqual(createTestChannel(unreadCount: 10000).unreadDisplayText, "10K")
    }
    
    func testHasUnreadMessages() {
        XCTAssertFalse(createTestChannel(unreadCount: 0).hasUnread)
        XCTAssertTrue(createTestChannel(unreadCount: 1).hasUnread)
        XCTAssertTrue(createTestChannel(unreadCount: 100).hasUnread)
    }
    
    // MARK: - Avatar Tests
    
    func testAvatarTypeEquality() {
        // Text avatars
        let textAvatar1 = FeedChannel.AvatarType.text("A", .red)
        let textAvatar2 = FeedChannel.AvatarType.text("A", .red)
        let textAvatar3 = FeedChannel.AvatarType.text("B", .red)
        
        XCTAssertEqual(textAvatar1, textAvatar2)
        XCTAssertNotEqual(textAvatar1, textAvatar3)
        
        // System icon avatars
        let iconAvatar1 = FeedChannel.AvatarType.systemIcon("star", .yellow)
        let iconAvatar2 = FeedChannel.AvatarType.systemIcon("star", .yellow)
        let iconAvatar3 = FeedChannel.AvatarType.systemIcon("star", .blue)
        
        XCTAssertEqual(iconAvatar1, iconAvatar2)
        XCTAssertNotEqual(iconAvatar1, iconAvatar3)
        
        // Image avatars
        let imageAvatar1 = FeedChannel.AvatarType.image("avatar1.png")
        let imageAvatar2 = FeedChannel.AvatarType.image("avatar1.png")
        let imageAvatar3 = FeedChannel.AvatarType.image("avatar2.png")
        
        XCTAssertEqual(imageAvatar1, imageAvatar2)
        XCTAssertNotEqual(imageAvatar1, imageAvatar3)
    }
    
    // MARK: - Priority Tests
    
    func testPrioritySorting() {
        let critical = createTestChannel(name: "Critical", category: .announcement).withPriority(.critical)
        let important = createTestChannel(name: "Important", category: .learning).withPriority(.important)
        let normal = createTestChannel(name: "Normal", category: .event).withPriority(.normal)
        let archived = createTestChannel(name: "Archived", category: .department).withPriority(.archived)
        
        let channels = [normal, critical, archived, important]
        let sorted = channels.sorted { $0.priority.sortOrder < $1.priority.sortOrder }
        
        XCTAssertEqual(sorted[0].name, "Critical")
        XCTAssertEqual(sorted[1].name, "Important")
        XCTAssertEqual(sorted[2].name, "Normal")
        XCTAssertEqual(sorted[3].name, "Archived")
    }
    
    // MARK: - Category Tests
    
    func testCategoryProperties() {
        XCTAssertEqual(NewsCategory.announcement.icon, "megaphone.fill")
        XCTAssertEqual(NewsCategory.learning.icon, "book.fill")
        XCTAssertEqual(NewsCategory.achievement.icon, "star.fill")
        XCTAssertEqual(NewsCategory.event.icon, "calendar")
        XCTAssertEqual(NewsCategory.department.icon, "building.2.fill")
        
        XCTAssertEqual(NewsCategory.announcement.color, .red)
        XCTAssertEqual(NewsCategory.learning.color, .blue)
        XCTAssertEqual(NewsCategory.achievement.color, .yellow)
        XCTAssertEqual(NewsCategory.event.color, .green)
        XCTAssertEqual(NewsCategory.department.color, .purple)
    }
    
    // MARK: - Codable Tests
    
    func testFeedChannelCodable() throws {
        // Given
        let channel = createTestChannel()
        
        // When
        let encoded = try JSONEncoder().encode(channel)
        let decoded = try JSONDecoder().decode(FeedChannel.self, from: encoded)
        
        // Then
        XCTAssertEqual(decoded.id, channel.id)
        XCTAssertEqual(decoded.name, channel.name)
        XCTAssertEqual(decoded.lastMessage, channel.lastMessage)
        XCTAssertEqual(decoded.unreadCount, channel.unreadCount)
        XCTAssertEqual(decoded.category, channel.category)
        XCTAssertEqual(decoded.priority, channel.priority)
    }
    
    // MARK: - Search Tests
    
    func testSearchMatching() {
        let channel = createTestChannel(
            name: "Администрация ЦУМ",
            category: .announcement
        )
        
        // Should match by name
        XCTAssertTrue(channel.matches(searchText: "админ"))
        XCTAssertTrue(channel.matches(searchText: "АДМИН"))
        XCTAssertTrue(channel.matches(searchText: "цум"))
        
        // Should match by last message
        XCTAssertTrue(channel.matches(searchText: "объявление"))
        XCTAssertTrue(channel.matches(searchText: "график"))
        
        // Should not match
        XCTAssertFalse(channel.matches(searchText: "xyz"))
        XCTAssertFalse(channel.matches(searchText: "несуществующий"))
        
        // Empty search should match all
        XCTAssertTrue(channel.matches(searchText: ""))
    }
} 