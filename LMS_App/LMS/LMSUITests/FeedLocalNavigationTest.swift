import XCTest

final class FeedLocalNavigationTest: XCTestCase {
    let app = XCUIApplication()
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launch()
    }
    
    func test_navigateToFeedAndCheckChannels() throws {
        // Wait for app
        sleep(2)
        
        // Find and tap Feed tab
        let tabBar = app.tabBars.firstMatch
        XCTAssertTrue(tabBar.waitForExistence(timeout: 5))
        
        let feedTab = tabBar.buttons["Новости"]
        if feedTab.exists {
            feedTab.tap()
            print("✅ Tapped Feed tab")
        } else {
            print("❌ Feed tab not found")
            // Try by index
            let tabs = tabBar.buttons
            if tabs.count > 1 {
                tabs.element(boundBy: 1).tap()
                print("✅ Tapped tab by index")
            }
        }
        
        // Wait for Feed screen
        sleep(3)
        
        // Look for channel cells
        let channelCells = app.cells
        print("📊 Found \(channelCells.count) cells")
        
        // Take screenshot
        let screenshot = app.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = "Feed_Screen_With_Channels"
        attachment.lifetime = .keepAlways
        add(attachment)
        
        // Check for specific text
        if app.staticTexts["Релизы и обновления"].exists {
            print("✅ Found 'Релизы и обновления' channel")
        }
        if app.staticTexts["Отчеты спринтов"].exists {
            print("✅ Found 'Отчеты спринтов' channel")
        }
        if app.staticTexts["Методология"].exists {
            print("✅ Found 'Методология' channel")
        }
        
        sleep(5) // Keep app open for logs
    }
}
