import XCTest

class UITestBase: XCTestCase {
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["--uitesting"]
        app.launch()
    }
    
    override func tearDownWithError() throws {
        app = nil
        try super.tearDownWithError()
    }
    
    // MARK: - Helper Methods
    
    func login(as role: UserRole) {
        let email = role == .admin ? "admin@company.com" : "student@company.com"
        let password = "password123"
        
        let emailField = app.textFields["loginEmailField"]
        let passwordField = app.secureTextFields["loginPasswordField"]
        let loginButton = app.buttons["loginButton"]
        
        emailField.tap()
        emailField.typeText(email)
        
        passwordField.tap()
        passwordField.typeText(password)
        
        loginButton.tap()
        
        // Wait for main screen
        waitForElement(app.tabBars.firstMatch)
    }
    
    func logout() {
        app.tabBars.buttons["Профиль"].tap()
        app.buttons["logoutButton"].tap()
        app.alerts.buttons["Выйти"].tap()
    }
    
    func waitForElement(_ element: XCUIElement, timeout: TimeInterval = 5) {
        let exists = element.waitForExistence(timeout: timeout)
        XCTAssertTrue(exists, "Element \(element) did not appear in \(timeout) seconds")
    }
    
    func waitForElementToDisappear(_ element: XCUIElement, timeout: TimeInterval = 5) {
        let predicate = NSPredicate(format: "exists == false")
        let expectation = XCTNSPredicateExpectation(predicate: predicate, object: element)
        let result = XCTWaiter().wait(for: [expectation], timeout: timeout)
        XCTAssertEqual(result, .completed)
    }
    
    func clearAndTypeText(_ element: XCUIElement, text: String) {
        element.tap()
        
        // Clear existing text
        if let existingText = element.value as? String, !existingText.isEmpty {
            element.tap()
            
            // Triple tap to select all
            element.tap(withNumberOfTaps: 3, numberOfTouches: 1)
            
            // Type new text (replaces selection)
            element.typeText(text)
        } else {
            element.typeText(text)
        }
    }
    
    func swipeToElement(_ element: XCUIElement, in scrollView: XCUIElement? = nil, maxSwipes: Int = 10) {
        let scrollableElement = scrollView ?? app.scrollViews.firstMatch
        var swipeCount = 0
        
        while !element.isHittable && swipeCount < maxSwipes {
            scrollableElement.swipeUp()
            swipeCount += 1
        }
        
        XCTAssertTrue(element.isHittable, "Element not found after \(swipeCount) swipes")
    }
    
    func takeScreenshot(name: String) {
        let screenshot = XCTAttachment(screenshot: app.screenshot())
        screenshot.name = name
        screenshot.lifetime = .keepAlways
        add(screenshot)
    }
    
    func dismissKeyboard() {
        if app.keyboards.count > 0 {
            app.toolbars.buttons["Done"].tap()
        }
    }
    
    func pullToRefresh(in element: XCUIElement? = nil) {
        let scrollView = element ?? app.scrollViews.firstMatch
        scrollView.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.1))
            .press(forDuration: 0, thenDragTo: scrollView.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.8)))
    }
    
    func checkAlert(title: String, message: String? = nil, dismiss: Bool = true) {
        let alert = app.alerts[title]
        waitForElement(alert)
        
        if let message = message {
            XCTAssertTrue(app.alerts.staticTexts[message].exists)
        }
        
        if dismiss {
            alert.buttons.firstMatch.tap()
        }
    }
}

enum UserRole {
    case admin
    case student
} 