import XCTest

final class NavigationUITests: UITestBase {
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        // Login as student for navigation tests
        login(as: .student)
    }
    
    // MARK: - Tab Bar Navigation
    
    func testTabBarNavigation() throws {
        // Verify we're on default tab (Courses)
        let coursesTab = app.tabBars.buttons["Курсы"]
        XCTAssertTrue(coursesTab.isSelected)
        
        // Navigate to Tests tab
        let testsTab = app.tabBars.buttons["Тесты"]
        testsTab.tap()
        waitForElement(app.navigationBars["Тесты"])
        XCTAssertTrue(testsTab.isSelected)
        XCTAssertFalse(coursesTab.isSelected)
        
        // Navigate to Learning tab
        let learningTab = app.tabBars.buttons["Обучение"]
        learningTab.tap()
        waitForElement(app.navigationBars["Мое обучение"])
        XCTAssertTrue(learningTab.isSelected)
        
        // Navigate to Competencies tab
        let competenciesTab = app.tabBars.buttons["Компетенции"]
        competenciesTab.tap()
        waitForElement(app.navigationBars["Компетенции"])
        XCTAssertTrue(competenciesTab.isSelected)
        
        // Navigate to Profile tab
        let profileTab = app.tabBars.buttons["Профиль"]
        profileTab.tap()
        waitForElement(app.navigationBars["Профиль"])
        XCTAssertTrue(profileTab.isSelected)
        
        // Admin-only tabs should not be visible for student
        XCTAssertFalse(app.tabBars.buttons["Аналитика"].exists)
        
        // Logout and login as admin
        logout()
        login(as: .admin)
        
        // Check admin has Analytics tab
        XCTAssertTrue(app.tabBars.buttons["Аналитика"].exists)
        app.tabBars.buttons["Аналитика"].tap()
        waitForElement(app.navigationBars["Аналитика"])
        
        takeScreenshot(name: "Tab_Navigation_Complete")
    }
    
    // MARK: - Back Navigation
    
    func testBackNavigation() throws {
        // Navigate to Courses
        app.tabBars.buttons["Курсы"].tap()
        
        // Open first course
        let coursesList = app.collectionViews[AccessibilityIdentifiers.Courses.coursesList]
        waitForElement(coursesList)
        let firstCourse = coursesList.cells.element(boundBy: 0)
        let courseName = firstCourse.staticTexts.firstMatch.label
        firstCourse.tap()
        
        // Verify we're in course details
        waitForElement(app.navigationBars.staticTexts[courseName])
        
        // Go back using navigation bar
        app.navigationBars.buttons.element(boundBy: 0).tap()
        
        // Should be back at courses list
        waitForElement(coursesList)
        XCTAssertTrue(coursesList.exists)
        
        // Deep navigation test
        firstCourse.tap()
        
        // If enrolled, go to lesson
        if app.buttons["Начать обучение"].exists {
            app.buttons["Начать обучение"].tap()
            waitForElement(app.otherElements["lessonView"])
            
            // Navigate back from lesson
            app.navigationBars.buttons.firstMatch.tap()
            
            // Should be at course details
            waitForElement(app.navigationBars.staticTexts[courseName])
            
            // Navigate back to list
            app.navigationBars.buttons.firstMatch.tap()
            waitForElement(coursesList)
        }
        
        // Test swipe back gesture
        firstCourse.tap()
        waitForElement(app.navigationBars.staticTexts[courseName])
        
        // Swipe from left edge
        let coordinate1 = app.coordinate(withNormalizedOffset: CGVector(dx: 0.01, dy: 0.5))
        let coordinate2 = app.coordinate(withNormalizedOffset: CGVector(dx: 0.9, dy: 0.5))
        coordinate1.press(forDuration: 0.1, thenDragTo: coordinate2)
        
        // Should be back at list
        waitForElement(coursesList)
        
        takeScreenshot(name: "Back_Navigation_Test")
    }
    
    // MARK: - Deep Linking
    
    func testDeepLinking() throws {
        // Test deep link to specific course
        // Note: In real app, this would use URL scheme or universal links
        
        // For testing purposes, we'll simulate deep linking by navigating directly
        
        // Test 1: Deep link to course details
        if let courseId = navigateToCourseAndGetId() {
            // Go back to home
            app.tabBars.buttons["Курсы"].tap()
            
            // Simulate deep link by searching for course
            let searchField = app.searchFields[AccessibilityIdentifiers.Courses.searchField]
            searchField.tap()
            searchField.typeText(courseId)
            
            // Verify we can navigate directly to course
            let coursesList = app.collectionViews[AccessibilityIdentifiers.Courses.coursesList]
            if coursesList.cells.count > 0 {
                coursesList.cells.element(boundBy: 0).tap()
                
                // Should be in course details
                XCTAssertTrue(app.navigationBars.staticTexts.matching(NSPredicate(format: "label CONTAINS %@", courseId)).firstMatch.exists)
            }
        }
        
        // Test 2: Deep link to profile settings
        app.tabBars.buttons["Профиль"].tap()
        app.buttons[AccessibilityIdentifiers.Profile.settingsButton].tap()
        waitForElement(app.navigationBars["Настройки"])
        
        // Go back to home
        app.navigationBars.buttons.firstMatch.tap()
        app.tabBars.buttons["Курсы"].tap()
        
        // Simulate deep link to settings
        app.tabBars.buttons["Профиль"].tap()
        
        // Settings should be accessible
        XCTAssertTrue(app.buttons[AccessibilityIdentifiers.Profile.settingsButton].exists)
        
        // Test 3: Deep link to test
        app.tabBars.buttons["Тесты"].tap()
        let testsList = app.collectionViews[AccessibilityIdentifiers.Tests.testsList]
        waitForElement(testsList)
        
        if testsList.cells.count > 0 {
            let testName = testsList.cells.element(boundBy: 0).staticTexts.firstMatch.label
            
            // Navigate away
            app.tabBars.buttons["Курсы"].tap()
            
            // Deep link back to tests
            app.tabBars.buttons["Тесты"].tap()
            
            // Search for specific test
            if app.searchFields.firstMatch.exists {
                app.searchFields.firstMatch.tap()
                app.searchFields.firstMatch.typeText(testName)
                
                // Should find the test
                XCTAssertTrue(testsList.cells.staticTexts[testName].exists)
            }
        }
        
        takeScreenshot(name: "Deep_Linking_Test")
    }
    
    // MARK: - Helper Methods
    
    private func navigateToCourseAndGetId() -> String? {
        app.tabBars.buttons["Курсы"].tap()
        
        let coursesList = app.collectionViews[AccessibilityIdentifiers.Courses.coursesList]
        waitForElement(coursesList)
        
        if coursesList.cells.count > 0 {
            let firstCourse = coursesList.cells.element(boundBy: 0)
            let courseName = firstCourse.staticTexts.firstMatch.label
            firstCourse.tap()
            
            // Extract course ID from view if available
            // In real app, this would be from accessibility identifier
            return courseName
        }
        
        return nil
    }
} 