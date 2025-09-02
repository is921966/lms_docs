//
//  FeedChannelsNavigationTest.swift
//  LMSUITests
//
//  UI Test for Feed channels verification
//

import XCTest

final class FeedChannelsNavigationTest: XCTestCase {
    
    let app = XCUIApplication()
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launch()
    }
    
    func test_navigateToFeedAndVerifyChannels() throws {
        // Log test start
        print("🧪 TEST: Starting Feed channels navigation test")
        
        // Wait for app to fully launch
        let mainTabBar = app.tabBars.firstMatch
        XCTAssertTrue(mainTabBar.waitForExistence(timeout: 5), "Tab bar should appear")
        
        // Navigate to Feed tab
        let feedTab = mainTabBar.buttons["Новости"]
        XCTAssertTrue(feedTab.exists, "Feed tab should exist")
        feedTab.tap()
        
        // Wait for feed to load
        sleep(2)
        
        // Log what we see
        print("📱 Number of cells visible: \(app.cells.count)")
        print("📱 Number of buttons visible: \(app.buttons.count)")
        
        // Look for expected channels
        let expectedChannels = [
            "Релизы и обновления",
            "Отчеты спринтов", 
            "Методология",
            "Новые курсы",
            "Администратор",
            "HR",
            "Мои курсы",
            "Сообщество"
        ]
        
        var foundChannels: [String] = []
        
        // Check for channel cells
        for channelName in expectedChannels {
            let channelCell = app.cells.containing(.staticText, identifier: channelName).firstMatch
            if channelCell.exists {
                foundChannels.append(channelName)
                print("✅ Found channel: \(channelName)")
            } else {
                // Try alternative search
                let alternativeCell = app.staticTexts[channelName]
                if alternativeCell.exists {
                    foundChannels.append(channelName)
                    print("✅ Found channel (alternative): \(channelName)")
                } else {
                    print("❌ Channel not found: \(channelName)")
                }
            }
        }
        
        print("📊 Summary: Found \(foundChannels.count) out of \(expectedChannels.count) channels")
        
        // Try to tap on first channel if exists
        if app.cells.count > 0 {
            print("👆 Attempting to tap first channel...")
            let firstCell = app.cells.element(boundBy: 0)
            firstCell.tap()
            sleep(2)
            
            // Check if detail view opened
            if app.navigationBars.count > 0 || app.buttons["chevron.left"].exists {
                print("✅ Detail view opened")
                
                // Go back
                if app.buttons["chevron.left"].exists {
                    app.buttons["chevron.left"].tap()
                } else if app.navigationBars.buttons.count > 0 {
                    app.navigationBars.buttons.element(boundBy: 0).tap()
                }
            }
        }
        
        // Final assertion - at least some channels should be found
        XCTAssertTrue(foundChannels.count > 0, "Should find at least one channel")
        
        print("🎉 TEST: Feed navigation test completed")
    }
} 