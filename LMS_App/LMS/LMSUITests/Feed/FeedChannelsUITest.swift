//
//  FeedChannelsUITest.swift
//  LMSUITests
//
//  UI tests for Feed channels full history
//

import XCTest

final class FeedChannelsUITest: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }
    
    override func tearDownWithError() throws {
        app = nil
    }
    
    func test_feedChannels_showAllHistory() throws {
        // Given - app is launched
        
        // When - navigate to Feed tab
        let feedTab = app.tabBars.buttons["Новости"]
        XCTAssertTrue(feedTab.waitForExistence(timeout: 5))
        feedTab.tap()
        
        // Then - verify Feed screen is shown
        let feedTitle = app.navigationBars.staticTexts["Новости"]
        XCTAssertTrue(feedTitle.waitForExistence(timeout: 5), "Feed screen should be displayed")
        
        // Check that channels are loaded
        Thread.sleep(forTimeInterval: 2) // Wait for data loading
        
        // Screenshot initial state
        let screenshot = app.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = "Feed_Initial_State"
        attachment.lifetime = .keepAlways
        add(attachment)
        
        // Scroll down to see more channels
        app.swipeUp()
        Thread.sleep(forTimeInterval: 1)
        
        // Take another screenshot
        let screenshot2 = app.screenshot()
        let attachment2 = XCTAttachment(screenshot: screenshot2)
        attachment2.name = "Feed_After_Scroll"
        attachment2.lifetime = .keepAlways
        add(attachment2)
        
        // Try to tap on "Релизы и обновления" channel
        let releasesChannel = app.cells.containing(.staticText, identifier: "Релизы и обновления").firstMatch
        if releasesChannel.waitForExistence(timeout: 3) {
            releasesChannel.tap()
            Thread.sleep(forTimeInterval: 2)
            
            // Take screenshot of channel detail
            let screenshot3 = app.screenshot()
            let attachment3 = XCTAttachment(screenshot: screenshot3)
            attachment3.name = "Releases_Channel_Detail"
            attachment3.lifetime = .keepAlways
            add(attachment3)
            
            // Verify we can see release content
            XCTAssertTrue(app.staticTexts["Релизы и обновления"].exists, "Channel title should be displayed")
        }
    }
    
    func test_feedChannels_checkAllChannelsExist() throws {
        // Navigate to Feed
        let feedTab = app.tabBars.buttons["Новости"]
        XCTAssertTrue(feedTab.waitForExistence(timeout: 5))
        feedTab.tap()
        
        Thread.sleep(forTimeInterval: 3) // Wait for data
        
        // Expected channels
        let expectedChannels = [
            "Релизы и обновления",
            "Отчеты спринтов",
            "Методология",
            "Новые курсы",
            "Администрация",
            "HR отдел",
            "Мои курсы",
            "Посты пользователей"
        ]
        
        var foundChannels: [String] = []
        
        // Scroll and look for channels
        for _ in 0..<5 {
            for channelName in expectedChannels {
                let channelCell = app.cells.containing(.staticText, identifier: channelName).firstMatch
                if channelCell.exists && !foundChannels.contains(channelName) {
                    foundChannels.append(channelName)
                    print("✅ Found channel: \(channelName)")
                }
            }
            
            if foundChannels.count < expectedChannels.count {
                app.swipeUp()
                Thread.sleep(forTimeInterval: 0.5)
            }
        }
        
        // Report results
        print("\n📊 Channel Discovery Results:")
        print("Expected: \(expectedChannels.count) channels")
        print("Found: \(foundChannels.count) channels")
        print("Missing: \(expectedChannels.filter { !foundChannels.contains($0) })")
        
        XCTAssertEqual(foundChannels.count, expectedChannels.count, 
                      "Should find all expected channels. Found: \(foundChannels)")
    }
} 