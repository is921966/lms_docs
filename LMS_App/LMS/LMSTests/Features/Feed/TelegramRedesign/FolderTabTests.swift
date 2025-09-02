//
//  FolderTabTests.swift
//  LMSTests
//
//  Tests for FolderTab component
//

import XCTest
import SwiftUI
import ViewInspector
@testable import LMS

final class FolderTabTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    // MARK: - Test 1: FolderTab displays correct content
    func test_folderTab_displaysCorrectContent() throws {
        // Given
        let folder = FeedFolder.sprints
        let isSelected = false
        let unreadCount = 5
        var tapped = false
        
        // When
        let view = FolderTab(
            folder: folder,
            isSelected: isSelected,
            unreadCount: unreadCount,
            action: { tapped = true }
        )
        
        // Then
        let button = try view.inspect().button()
        let hStack = try button.labelView().hStack()
        
        // Check icon
        let icon = try hStack.image(0)
        XCTAssertEqual(try icon.actualImage().name(), "calendar")
        
        // Check name
        let name = try hStack.text(1)
        XCTAssertEqual(try name.string(), "Sprints")
        
        // Check count
        let count = try hStack.text(2)
        XCTAssertEqual(try count.string(), "(5)")
    }
    
    // MARK: - Test 2: Selected state styling
    func test_folderTab_selectedStateStyling() throws {
        // Given
        let folder = FeedFolder.all
        let isSelected = true
        let unreadCount = 3
        
        // When
        let view = FolderTab(
            folder: folder,
            isSelected: isSelected,
            unreadCount: unreadCount,
            action: {}
        )
        
        // Then
        let button = try view.inspect().button()
        let hStack = try button.labelView().hStack()
        
        // Check that text is white when selected
        let name = try hStack.text(1)
        let nameColor = try name.attributes().foregroundColor()
        XCTAssertEqual(nameColor, .white)
    }
    
    // MARK: - Test 3: Unselected state styling
    func test_folderTab_unselectedStateStyling() throws {
        // Given
        let folder = FeedFolder.docs
        let isSelected = false
        let unreadCount = 0
        
        // When
        let view = FolderTab(
            folder: folder,
            isSelected: isSelected,
            unreadCount: unreadCount,
            action: {}
        )
        
        // Then
        let button = try view.inspect().button()
        let hStack = try button.labelView().hStack()
        
        // Check that name is primary color when unselected
        let name = try hStack.text(1)
        let nameColor = try name.attributes().foregroundColor()
        XCTAssertEqual(nameColor, .primary)
        
        // Check that there's no count when unreadCount is 0
        XCTAssertEqual(hStack.count, 2) // Only icon and name
    }
    
    // MARK: - Test 4: Tap action
    func test_folderTab_tapAction() throws {
        // Given
        var tapped = false
        let view = FolderTab(
            folder: .all,
            isSelected: false,
            unreadCount: 0,
            action: { tapped = true }
        )
        
        // When
        let button = try view.inspect().button()
        try button.tap()
        
        // Then
        XCTAssertTrue(tapped)
    }
} 