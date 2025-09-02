//
//  CreateFolderUITests.swift
//  LMSUITests
//
//  UI tests for creating custom folders
//

import XCTest

final class CreateFolderUITests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["UI_TESTING"]
        app.launch()
    }
    
    override func tearDownWithError() throws {
        app = nil
    }
    
    // MARK: - Test 1: Create folder flow
    func test_createFolder_fullFlow() throws {
        // Given - Navigate to Feed
        navigateToFeed()
        
        // Wait for feed to load
        let feedTitle = app.staticTexts["LMS News"]
        XCTAssertTrue(feedTitle.waitForExistence(timeout: 5))
        
        // When - Tap create folder button
        let createFolderButton = app.buttons["plus.circle.fill"]
        XCTAssertTrue(createFolderButton.exists)
        createFolderButton.tap()
        
        // Then - Create folder sheet should appear
        let createFolderTitle = app.navigationBars["Новая папка"]
        XCTAssertTrue(createFolderTitle.waitForExistence(timeout: 3))
        
        // When - Fill folder details
        let folderNameField = app.textFields["Введите название"]
        XCTAssertTrue(folderNameField.exists)
        folderNameField.tap()
        folderNameField.typeText("Важное")
        
        // Select icon
        let starIcon = app.images["star.fill"]
        if starIcon.exists {
            starIcon.tap()
        }
        
        // Select channels
        let sprintChannel = app.cells.containing(.staticText, identifier: "🏃 Спринты").element
        if sprintChannel.exists {
            sprintChannel.tap()
        }
        
        let releaseChannel = app.cells.containing(.staticText, identifier: "🚀 Релизы").element
        if releaseChannel.exists {
            releaseChannel.tap()
        }
        
        // Verify selection count
        let selectionCount = app.staticTexts["Выбрано каналов: 2"]
        XCTAssertTrue(selectionCount.exists)
        
        // When - Create folder
        let createButton = app.buttons["Создать"]
        XCTAssertTrue(createButton.exists)
        XCTAssertTrue(createButton.isEnabled)
        createButton.tap()
        
        // Then - Folder should appear in feed
        sleep(1) // Wait for sheet to dismiss
        
        let newFolder = app.buttons.containing(.staticText, identifier: "Важное").element
        XCTAssertTrue(newFolder.waitForExistence(timeout: 3))
    }
    
    // MARK: - Test 2: Create folder validation
    func test_createFolder_validation() throws {
        // Given - Navigate to Feed
        navigateToFeed()
        
        // When - Open create folder
        let createFolderButton = app.buttons["plus.circle.fill"]
        createFolderButton.tap()
        
        // Then - Create button should be disabled initially
        let createButton = app.buttons["Создать"]
        XCTAssertTrue(createButton.exists)
        XCTAssertFalse(createButton.isEnabled)
        
        // When - Enter only name
        let folderNameField = app.textFields["Введите название"]
        folderNameField.tap()
        folderNameField.typeText("Test")
        
        // Then - Create button should still be disabled (no channels selected)
        XCTAssertFalse(createButton.isEnabled)
        
        // When - Select a channel
        let firstChannel = app.cells.firstMatch
        firstChannel.tap()
        
        // Then - Create button should be enabled
        XCTAssertTrue(createButton.isEnabled)
    }
    
    // MARK: - Test 3: Cancel folder creation
    func test_createFolder_cancel() throws {
        // Given - Navigate to Feed
        navigateToFeed()
        
        // When - Open and cancel folder creation
        let createFolderButton = app.buttons["plus.circle.fill"]
        createFolderButton.tap()
        
        let cancelButton = app.buttons["Отмена"]
        XCTAssertTrue(cancelButton.exists)
        cancelButton.tap()
        
        // Then - Should be back at feed
        let feedTitle = app.staticTexts["LMS News"]
        XCTAssertTrue(feedTitle.exists)
    }
    
    // MARK: - Test 4: Custom folder filtering
    func test_customFolder_filtering() throws {
        // Given - Create a custom folder
        createTestFolder(name: "Тест", channelNames: ["🏃 Спринты"])
        
        // When - Tap on custom folder
        let customFolder = app.buttons.containing(.staticText, identifier: "Тест").element
        XCTAssertTrue(customFolder.waitForExistence(timeout: 3))
        customFolder.tap()
        
        // Then - Should show only sprint channels
        sleep(1) // Wait for filtering
        
        let sprintChannel = app.cells.containing(.staticText, identifier: "🏃 Спринты").element
        XCTAssertTrue(sprintChannel.exists)
        
        // Other channels should not be visible
        let releaseChannel = app.cells.containing(.staticText, identifier: "🚀 Релизы").element
        XCTAssertFalse(releaseChannel.exists)
    }
    
    // MARK: - Helper Methods
    
    private func navigateToFeed() {
        // Check if we're already in Feed
        if app.staticTexts["LMS News"].exists {
            return
        }
        
        // Otherwise navigate to Feed tab
        let feedTab = app.tabBars.buttons["Feed"]
        if feedTab.exists {
            feedTab.tap()
        }
    }
    
    private func createTestFolder(name: String, channelNames: [String]) {
        navigateToFeed()
        
        // Open create folder
        let createFolderButton = app.buttons["plus.circle.fill"]
        createFolderButton.tap()
        
        // Fill name
        let folderNameField = app.textFields["Введите название"]
        folderNameField.tap()
        folderNameField.typeText(name)
        
        // Select channels
        for channelName in channelNames {
            let channel = app.cells.containing(.staticText, identifier: channelName).element
            if channel.exists {
                channel.tap()
            }
        }
        
        // Create
        let createButton = app.buttons["Создать"]
        createButton.tap()
        
        sleep(1) // Wait for creation
    }
} 