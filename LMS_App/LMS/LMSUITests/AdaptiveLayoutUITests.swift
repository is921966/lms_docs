import XCTest

final class AdaptiveLayoutUITests: XCTestCase {
    
    let app = XCUIApplication()
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launch()
    }
    
    func testCourseListLayoutOniPad() throws {
        // Skip test if not running on iPad
        guard UIDevice.current.userInterfaceIdiom == .pad else {
            throw XCTSkip("This test is for iPad only")
        }
        
        // Navigate to courses
        app.tabBars.buttons["Курсы"].tap()
        
        // Check for grid layout
        let courseCards = app.scrollViews.otherElements.buttons
        XCTAssertGreaterThan(courseCards.count, 0, "Should have course cards")
        
        // Check that cards are arranged in grid
        if courseCards.count >= 2 {
            let firstCard = courseCards.element(boundBy: 0)
            let secondCard = courseCards.element(boundBy: 1)
            
            // Cards should be side by side on iPad
            XCTAssertEqual(
                firstCard.frame.minY,
                secondCard.frame.minY,
                accuracy: 10,
                "Cards should be on the same row"
            )
        }
    }
    
    func testCourseListLayoutOniPhone() throws {
        // Skip test if not running on iPhone
        guard UIDevice.current.userInterfaceIdiom == .phone else {
            throw XCTSkip("This test is for iPhone only")
        }
        
        // Navigate to courses
        app.tabBars.buttons["Курсы"].tap()
        
        // Check for list layout
        let courseRows = app.scrollViews.otherElements.buttons
        XCTAssertGreaterThan(courseRows.count, 0, "Should have course rows")
        
        // Check that rows are stacked vertically
        if courseRows.count >= 2 {
            let firstRow = courseRows.element(boundBy: 0)
            let secondRow = courseRows.element(boundBy: 1)
            
            // Rows should be stacked on iPhone
            XCTAssertGreaterThan(
                secondRow.frame.minY,
                firstRow.frame.maxY,
                "Rows should be stacked vertically"
            )
        }
    }
    
    func testSplitViewOniPad() throws {
        guard UIDevice.current.userInterfaceIdiom == .pad else {
            throw XCTSkip("This test is for iPad only")
        }
        
        // Navigate to courses
        app.tabBars.buttons["Курсы"].tap()
        
        // Select a course
        let firstCourse = app.scrollViews.otherElements.buttons.firstMatch
        XCTAssertTrue(firstCourse.waitForExistence(timeout: 5))
        firstCourse.tap()
        
        // Check that both master and detail are visible
        XCTAssertTrue(app.navigationBars["Курсы"].exists, "Master view should be visible")
        XCTAssertTrue(app.staticTexts["Описание курса"].exists, "Detail view should be visible")
    }
    
    func testNavigationOniPhone() throws {
        guard UIDevice.current.userInterfaceIdiom == .phone else {
            throw XCTSkip("This test is for iPhone only")
        }
        
        // Navigate to courses
        app.tabBars.buttons["Курсы"].tap()
        
        // Select a course
        let firstCourse = app.scrollViews.otherElements.buttons.firstMatch
        XCTAssertTrue(firstCourse.waitForExistence(timeout: 5))
        firstCourse.tap()
        
        // Check that we navigated to detail
        XCTAssertTrue(app.navigationBars.buttons["Курсы"].exists, "Back button should exist")
        XCTAssertTrue(app.staticTexts["Описание курса"].exists, "Detail view should be visible")
        
        // Go back
        app.navigationBars.buttons["Курсы"].tap()
        XCTAssertTrue(app.navigationBars["Курсы"].exists, "Should be back to list")
    }
    
    func testMoreMenuLayoutOniPad() throws {
        guard UIDevice.current.userInterfaceIdiom == .pad else {
            throw XCTSkip("This test is for iPad only")
        }
        
        // Navigate to More
        app.tabBars.buttons["Ещё"].tap()
        
        let menuItems = app.tables.cells
        XCTAssertGreaterThan(menuItems.count, 5, "Should have menu items")
        
        // Check spacing on iPad
        let firstItem = menuItems.element(boundBy: 0)
        let secondItem = menuItems.element(boundBy: 1)
        
        let spacing = secondItem.frame.minY - firstItem.frame.maxY
        XCTAssertGreaterThan(spacing, 10, "iPad should have larger spacing")
    }
    
    func testRotationHandling() throws {
        guard UIDevice.current.userInterfaceIdiom == .pad else {
            throw XCTSkip("This test is for iPad only")
        }
        
        // Start in portrait
        XCUIDevice.shared.orientation = .portrait
        
        app.tabBars.buttons["Курсы"].tap()
        let portraitCards = app.scrollViews.otherElements.buttons.count
        
        // Rotate to landscape
        XCUIDevice.shared.orientation = .landscapeLeft
        
        // Wait for rotation animation
        Thread.sleep(forTimeInterval: 1)
        
        let landscapeCards = app.scrollViews.otherElements.buttons.count
        XCTAssertEqual(portraitCards, landscapeCards, "Should have same number of cards")
        
        // Reset orientation
        XCUIDevice.shared.orientation = .portrait
    }
} 