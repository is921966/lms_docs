//
//  FeedDesignSwitchingUITests.swift
//  LMSUITests
//
//  Created for automated feed design switching verification
//

import XCTest

final class FeedDesignSwitchingUITests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
    }
    
    override func tearDownWithError() throws {
        app = nil
    }
    
    func testClassicFeedDisplays() throws {
        // Given: Launch with classic feed design
        app.launchArguments = ["-useNewFeedDesign", "NO"]
        app.launch()
        
        // When: App is launched
        
        // Then: Classic feed elements should be visible
        let classicTitle = app.staticTexts["Классическая лента новостей"]
        XCTAssertTrue(classicTitle.exists, "Classic feed title should be visible")
        
        let tryNewButton = app.buttons["Попробовать новую ленту"]
        XCTAssertTrue(tryNewButton.exists, "Try new feed button should be visible")
        
        // Take screenshot for verification
        let screenshot = app.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = "Classic_Feed_Design"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
    
    func testTelegramFeedDisplays() throws {
        // Given: Launch with new feed design
        app.launchArguments = ["-useNewFeedDesign", "YES"]
        app.launch()
        
        // When: App is launched
        
        // Then: Telegram feed elements should be visible
        let navigationBar = app.navigationBars["Новости"]
        XCTAssertTrue(navigationBar.exists, "News navigation bar should be visible")
        
        let classicButton = navigationBar.buttons["Классическая лента"]
        XCTAssertTrue(classicButton.exists, "Classic feed button should be visible in navigation")
        
        // Classic feed elements should NOT be visible
        let classicTitle = app.staticTexts["Классическая лента новостей"]
        XCTAssertFalse(classicTitle.exists, "Classic feed title should NOT be visible")
        
        // Take screenshot
        let screenshot = app.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = "Telegram_Feed_Design"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
    
    func testFeedSwitchingViaButton() throws {
        // Given: Start with classic feed
        app.launchArguments = ["-useNewFeedDesign", "NO"]
        app.launch()
        
        // When: Tap "Try new feed" button
        let tryNewButton = app.buttons["Попробовать новую ленту"]
        XCTAssertTrue(tryNewButton.waitForExistence(timeout: 5))
        tryNewButton.tap()
        
        // Then: Should switch to Telegram feed
        // Note: This test assumes the button triggers immediate switch
        // If app requires restart, this test would need modification
        
        let navigationBar = app.navigationBars["Новости"]
        XCTAssertTrue(navigationBar.waitForExistence(timeout: 5), "Should switch to Telegram feed")
    }
    
    func testFeedSwitchingViaSettings() throws {
        // Given: Start with new feed
        app.launchArguments = ["-useNewFeedDesign", "YES"]
        app.launch()
        
        // When: Navigate to settings and toggle feed design
        let settingsTab = app.tabBars.buttons["Настройки"]
        XCTAssertTrue(settingsTab.waitForExistence(timeout: 5))
        settingsTab.tap()
        
        let feedToggle = app.switches["Новый дизайн ленты"]
        XCTAssertTrue(feedToggle.waitForExistence(timeout: 5))
        feedToggle.tap()
        
        // Go back to feed
        let feedTab = app.tabBars.buttons["Лента"]
        feedTab.tap()
        
        // Then: Should show classic feed (after app restart)
        // Note: If immediate switch is implemented, check for classic elements
    }
    
    // Performance test
    func testFeedSwitchingPerformance() throws {
        app.launch()
        
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            app.terminate()
            app.launchArguments = ["-useNewFeedDesign", "YES"]
            app.launch()
        }
    }
} 