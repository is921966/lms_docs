//
//  CustomFolderTests.swift
//  LMSTests
//
//  Unit tests for custom folder functionality
//

import XCTest
@testable import LMS

final class CustomFolderTests: XCTestCase {
    
    var viewModel: TelegramFeedViewModel!
    
    @MainActor
    override func setUp() async throws {
        viewModel = TelegramFeedViewModel()
        // Clear any saved folders
        UserDefaults.standard.removeObject(forKey: "customFeedFolders")
    }
    
    override func tearDown() {
        viewModel = nil
        UserDefaults.standard.removeObject(forKey: "customFeedFolders")
    }
    
    // MARK: - Test 1: Create custom folder
    @MainActor
    func test_createCustomFolder_addsToFoldersList() async {
        // Given
        let initialCount = viewModel.folders.count
        let folderName = "Test Folder"
        let folderIcon = "star"
        let channelIds = ["channel1", "channel2"]
        
        // When
        viewModel.createCustomFolder(
            name: folderName,
            icon: folderIcon,
            channelIds: channelIds
        )
        
        // Then
        XCTAssertEqual(viewModel.folders.count, initialCount + 1)
        
        let lastFolder = viewModel.folders.last!
        XCTAssertEqual(lastFolder.name, folderName)
        XCTAssertEqual(lastFolder.icon, folderIcon)
        
        // Verify it's a custom folder
        if case .custom = lastFolder {
            // Success
        } else {
            XCTFail("Last folder should be custom type")
        }
    }
    
    // MARK: - Test 2: Custom folder filter
    @MainActor
    func test_customFolder_filtersChannelsCorrectly() async {
        // Given - Set up test channels
        let testChannel1 = FeedChannel(
            id: "test1",
            type: .sprints,
            name: "Test Channel 1",
            avatar: .emoji("🏃"),
            description: "Test",
            lastMessage: FeedMessage(
                id: "msg1",
                channelId: "test1",
                author: "System",
                content: "Test message",
                timestamp: Date(),
                isRead: true,
                attachments: []
            ),
            unreadCount: 0,
            isPinned: false,
            isMuted: false,
            members: 1,
            isVerified: false,
            customData: nil
        )
        
        let testChannel2 = FeedChannel(
            id: "test2",
            type: .releases,
            name: "Test Channel 2",
            avatar: .emoji("🚀"),
            description: "Test",
            lastMessage: FeedMessage(
                id: "msg2",
                channelId: "test2",
                author: "System",
                content: "Test message",
                timestamp: Date(),
                isRead: true,
                attachments: []
            ),
            unreadCount: 0,
            isPinned: false,
            isMuted: false,
            members: 1,
            isVerified: false,
            customData: nil
        )
        
        viewModel.channels = [testChannel1, testChannel2]
        
        // When - Create folder with only test1
        viewModel.createCustomFolder(
            name: "Filtered",
            icon: "folder",
            channelIds: ["test1"]
        )
        
        // Then - Filter should work
        let customFolder = viewModel.folders.last!
        if case let .custom(_, _, filter) = customFolder {
            XCTAssertTrue(filter(testChannel1))
            XCTAssertFalse(filter(testChannel2))
        } else {
            XCTFail("Should be custom folder")
        }
    }
    
    // MARK: - Test 3: Save and load custom folders
    @MainActor
    func test_customFolders_persistAcrossSessions() async {
        // Given
        viewModel.createCustomFolder(
            name: "Persistent",
            icon: "bookmark",
            channelIds: ["ch1", "ch2"]
        )
        
        // When - Create new view model (simulating app restart)
        let newViewModel = TelegramFeedViewModel()
        
        // Then - Custom folder should be loaded
        let customFolders = newViewModel.folders.filter { folder in
            if case .custom = folder { return true }
            return false
        }
        
        XCTAssertEqual(customFolders.count, 1)
        XCTAssertEqual(customFolders.first?.name, "Persistent")
    }
    
    // MARK: - Test 4: Delete custom folder
    @MainActor
    func test_deleteCustomFolder_removesFromList() async {
        // Given
        viewModel.createCustomFolder(
            name: "ToDelete",
            icon: "trash",
            channelIds: ["ch1"]
        )
        
        let folderToDelete = viewModel.folders.last!
        let countBefore = viewModel.folders.count
        
        // When
        viewModel.deleteCustomFolder(folderToDelete)
        
        // Then
        XCTAssertEqual(viewModel.folders.count, countBefore - 1)
        XCTAssertFalse(viewModel.folders.contains { $0.id == folderToDelete.id })
    }
    
    // MARK: - Test 5: Cannot delete default folders
    @MainActor
    func test_deleteCustomFolder_ignoresDefaultFolders() async {
        // Given
        let defaultFolder = FeedFolder.all
        let countBefore = viewModel.folders.count
        
        // When
        viewModel.deleteCustomFolder(defaultFolder)
        
        // Then - Count should not change
        XCTAssertEqual(viewModel.folders.count, countBefore)
    }
    
    // MARK: - Test 6: Get unread count for custom folder
    @MainActor
    func test_getUnreadCount_forCustomFolder() async {
        // Given
        let testChannel1 = FeedChannel(
            id: "test1",
            type: .sprints,
            name: "Test 1",
            avatar: .emoji("🏃"),
            description: "",
            lastMessage: FeedMessage(
                id: "msg1",
                channelId: "test1",
                author: "System",
                content: "Test",
                timestamp: Date(),
                isRead: false,
                attachments: []
            ),
            unreadCount: 5,
            isPinned: false,
            isMuted: false,
            members: 1,
            isVerified: false,
            customData: nil
        )
        
        let testChannel2 = FeedChannel(
            id: "test2",
            type: .releases,
            name: "Test 2",
            avatar: .emoji("🚀"),
            description: "",
            lastMessage: FeedMessage(
                id: "msg2",
                channelId: "test2",
                author: "System",
                content: "Test",
                timestamp: Date(),
                isRead: false,
                attachments: []
            ),
            unreadCount: 3,
            isPinned: false,
            isMuted: false,
            members: 1,
            isVerified: false,
            customData: nil
        )
        
        viewModel.channels = [testChannel1, testChannel2]
        
        // When - Create folder with both channels
        viewModel.createCustomFolder(
            name: "All Test",
            icon: "folder",
            channelIds: ["test1", "test2"]
        )
        
        let customFolder = viewModel.folders.last!
        let unreadCount = viewModel.getUnreadCount(for: customFolder)
        
        // Then
        XCTAssertEqual(unreadCount, 8) // 5 + 3
    }
} 