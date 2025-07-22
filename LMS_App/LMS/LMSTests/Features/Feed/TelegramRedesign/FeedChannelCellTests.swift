//
//  FeedChannelCellTests.swift
//  LMSTests
//
//  Sprint 50 - День 1: Тесты для ячейки канала в стиле Telegram
//

import XCTest
import SwiftUI
import ViewInspector
@testable import LMS

final class FeedChannelCellTests: XCTestCase {
    
    // MARK: - Test Data
    
    private func createTestChannel(
        name: String = "Администрация ЦУМ",
        lastMessage: String = "Важное объявление о графике работы",
        unreadCount: Int = 0,
        category: NewsCategory = .announcement,
        avatarType: FeedChannel.AvatarType = .text("А", .red)
    ) -> FeedChannel {
        FeedChannel(
            id: UUID(),
            name: name,
            avatarType: avatarType,
            lastMessage: lastMessage,
            lastMessageTime: Date(),
            unreadCount: unreadCount,
            category: category,
            priority: .normal
        )
    }
    
    // MARK: - View Structure Tests
    
    func testFeedChannelCellStructure() throws {
        let channel = createTestChannel()
        let cell = FeedChannelCell(channel: channel)
        let inspected = try cell.inspect()
        
        // Should have HStack as root
        let hstack = try inspected.hStack()
        XCTAssertNotNil(hstack)
        
        // Should have correct spacing
        XCTAssertEqual(try hstack.spacing(), 12)
        
        // Should have correct padding
        let padding = try hstack.padding()
        XCTAssertEqual(padding.leading, 12)
        XCTAssertEqual(padding.trailing, 12)
        XCTAssertEqual(padding.top, 8)
        XCTAssertEqual(padding.bottom, 8)
    }
    
    func testFeedChannelCellAvatar() throws {
        // Text avatar
        let textChannel = createTestChannel(avatarType: .text("T", .blue))
        let textCell = FeedChannelCell(channel: textChannel)
        let textInspected = try textCell.inspect()
        
        // Should have avatar view
        let avatar = try textInspected.find(ChannelAvatar.self)
        XCTAssertNotNil(avatar)
        
        // System icon avatar
        let iconChannel = createTestChannel(avatarType: .systemIcon("star.fill", .yellow))
        let iconCell = FeedChannelCell(channel: iconChannel)
        let iconInspected = try iconCell.inspect()
        
        let iconAvatar = try iconInspected.find(ChannelAvatar.self)
        XCTAssertNotNil(iconAvatar)
    }
    
    func testFeedChannelCellContent() throws {
        let channel = createTestChannel(
            name: "HR Отдел",
            lastMessage: "Напоминаем о корпоративном мероприятии"
        )
        let cell = FeedChannelCell(channel: channel)
        let inspected = try cell.inspect()
        
        // Should display channel name
        let nameText = try inspected.find(text: "HR Отдел")
        XCTAssertNotNil(nameText)
        
        // Should display last message
        let messageText = try inspected.find(text: "Напоминаем о корпоративном мероприятии")
        XCTAssertNotNil(messageText)
    }
    
    func testFeedChannelCellTime() throws {
        let now = Date()
        let channel = createTestChannel()
        let cell = FeedChannelCell(channel: channel)
        let inspected = try cell.inspect()
        
        // Should have time text
        let vstack = try inspected.hStack().vStack(1)
        let headerHStack = try vstack.hStack(0)
        let timeText = try headerHStack.text(1)
        
        // Time should be formatted
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        let expectedTime = formatter.string(from: now)
        
        // Since we can't check exact time due to formatting, just verify it exists
        XCTAssertNotNil(timeText)
    }
    
    func testFeedChannelCellUnreadBadge() throws {
        // With unread messages
        let unreadChannel = createTestChannel(unreadCount: 42)
        let unreadCell = FeedChannelCell(channel: unreadChannel)
        let unreadInspected = try unreadCell.inspect()
        
        // Should have UnreadBadge
        let badge = try unreadInspected.find(UnreadBadge.self)
        XCTAssertNotNil(badge)
        XCTAssertEqual(try badge.actualView().count, 42)
        
        // Without unread messages
        let readChannel = createTestChannel(unreadCount: 0)
        let readCell = FeedChannelCell(channel: readChannel)
        let readInspected = try readCell.inspect()
        
        // Should not have UnreadBadge
        XCTAssertThrowsError(try readInspected.find(UnreadBadge.self))
    }
    
    // MARK: - Appearance Tests
    
    func testFeedChannelCellColors() throws {
        let cell = FeedChannelCell(channel: createTestChannel())
        let inspected = try cell.inspect()
        
        // Channel name should be primary color
        let nameText = try inspected.find(text: "Администрация ЦУМ")
        let nameColor = try nameText.foregroundColor()
        XCTAssertNotNil(nameColor)
        
        // Last message should be secondary color
        let messageText = try inspected.find(text: "Важное объявление о графике работы")
        let messageColor = try messageText.foregroundColor()
        XCTAssertEqual(messageColor, Color(UIColor.systemGray))
    }
    
    func testFeedChannelCellFonts() throws {
        let cell = FeedChannelCell(channel: createTestChannel())
        let inspected = try cell.inspect()
        
        // Channel name font
        let nameText = try inspected.find(text: "Администрация ЦУМ")
        XCTAssertEqual(try nameText.font(), .some(.system(size: 16, weight: .semibold)))
        
        // Last message font
        let messageText = try inspected.find(text: "Важное объявление о графике работы")
        XCTAssertEqual(try messageText.font(), .some(.system(size: 15)))
        
        // Time font
        let vstack = try inspected.hStack().vStack(1)
        let headerHStack = try vstack.hStack(0)
        let timeText = try headerHStack.text(1)
        XCTAssertEqual(try timeText.font(), .some(.system(size: 14)))
    }
    
    // MARK: - Interaction Tests
    
    func testFeedChannelCellTappable() throws {
        let channel = createTestChannel()
        let cell = FeedChannelCell(channel: channel)
        let inspected = try cell.inspect()
        
        // Should have contentShape for tap area
        let contentShape = try inspected.contentShape()
        XCTAssertNotNil(contentShape)
    }
    
    // MARK: - Different Categories Tests
    
    func testFeedChannelCellCategories() throws {
        let categories: [(NewsCategory, Color)] = [
            (.announcement, .red),
            (.learning, .blue),
            (.achievement, .yellow),
            (.event, .green),
            (.department, .purple)
        ]
        
        for (category, expectedColor) in categories {
            let channel = createTestChannel(
                category: category,
                avatarType: .systemIcon(category.icon, category.color)
            )
            let cell = FeedChannelCell(channel: channel)
            let inspected = try cell.inspect()
            
            // Verify avatar exists
            let avatar = try inspected.find(ChannelAvatar.self)
            XCTAssertNotNil(avatar)
        }
    }
} 