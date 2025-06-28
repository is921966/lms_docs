//
//  BasicLoginTest.swift
//  LMSUITests
//
//  Created on 27.06.2025.
//

import XCTest

final class BasicLoginTest: XCTestCase {
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["UI_TESTING", "MOCK_MODE"]
        app.launch()
    }
    
    override func tearDownWithError() throws {
        app = nil
    }
    
    func testBasicAppLaunch() {
        // Just verify the app launches
        XCTAssertTrue(app.exists)
        
        // Check if the main login button exists
        let loginButton = app.buttons["Войти (Demo)"]
        XCTAssertTrue(loginButton.waitForExistence(timeout: 10))
    }
    
    func testLoginAsAdmin() {
        // Click login button
        let loginButton = app.buttons["Войти (Demo)"]
        XCTAssertTrue(loginButton.waitForExistence(timeout: 10))
        loginButton.tap()
        
        // Wait for mock login view
        let adminButton = app.buttons["loginAsAdmin"]
        XCTAssertTrue(adminButton.waitForExistence(timeout: 5))
        adminButton.tap()
        
        // Verify we reach the main screen
        XCTAssertTrue(app.navigationBars["Главная"].waitForExistence(timeout: 5))
    }
    
    func testNavigateToContentTab() {
        // Login first
        let loginButton = app.buttons["Войти (Demo)"]
        XCTAssertTrue(loginButton.waitForExistence(timeout: 10))
        loginButton.tap()
        
        let adminButton = app.buttons["loginAsAdmin"]
        XCTAssertTrue(adminButton.waitForExistence(timeout: 5))
        adminButton.tap()
        
        // Wait for main screen
        _ = app.navigationBars["Главная"].waitForExistence(timeout: 5)
        
        // Navigate to Content tab
        let contentTab = app.tabBars.buttons["Контент"]
        XCTAssertTrue(contentTab.exists)
        contentTab.tap()
        
        // Verify we're on the content screen
        XCTAssertTrue(app.navigationBars["Контент"].waitForExistence(timeout: 5))
    }
} 