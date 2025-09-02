import XCTest

final class FeedCloudTestNavigation: XCTestCase {
    let app = XCUIApplication()
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launch()
    }
    
    func test_navigateToFeedAndWait() throws {
        // Wait for tab bar
        let tabBar = app.tabBars.firstMatch
        XCTAssertTrue(tabBar.waitForExistence(timeout: 5))
        
        // Tap Feed tab
        let feedTab = tabBar.buttons["Новости"]
        XCTAssertTrue(feedTab.exists)
        feedTab.tap()
        
        // Wait for Feed screen
        sleep(3)
        
        // Take screenshot
        let screenshot = app.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = "Feed_Screen"
        attachment.lifetime = .keepAlways
        add(attachment)
        
        // Keep app open for a bit to let logs upload
        sleep(10)
    }
}
