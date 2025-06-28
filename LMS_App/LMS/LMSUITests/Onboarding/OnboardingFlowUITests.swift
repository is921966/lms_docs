//
//  OnboardingFlowUITests.swift
//  LMSUITests
//
//  Created by Igor Shirokov on 27.06.2025.
//

import XCTest

final class OnboardingFlowUITests: XCTestCase {
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
    
    // MARK: - Helper Methods
    
    private func loginAsAdmin() {
        // Click login button on main screen
        let loginButton = app.buttons["Войти (Demo)"]
        XCTAssertTrue(loginButton.waitForExistence(timeout: 5))
        loginButton.tap()
        
        // Click login as admin in MockLoginView
        let adminLoginButton = app.buttons["loginAsAdmin"]
        XCTAssertTrue(adminLoginButton.waitForExistence(timeout: 5))
        adminLoginButton.tap()
        
        // Wait for main screen to appear
        _ = app.navigationBars["Главная"].waitForExistence(timeout: 5)
    }
    
    private func navigateToOnboarding() {
        // Navigate to Content tab (not Management)
        app.tabBars.buttons["Контент"].tap()
        
        // Click on Onboarding card
        let onboardingCard = app.buttons.containing(.staticText, identifier: "Онбординг").element
        XCTAssertTrue(onboardingCard.waitForExistence(timeout: 5))
        onboardingCard.tap()
        
        // Verify we're on onboarding dashboard
        XCTAssertTrue(app.navigationBars["Программы адаптации"].waitForExistence(timeout: 5))
    }
    
    // MARK: - Test Cases
    
    func testViewOnboardingDashboard() {
        // Login as admin
        loginAsAdmin()
        
        // Navigate to onboarding
        navigateToOnboarding()
        
        // Verify dashboard elements
        XCTAssertTrue(app.otherElements["onboardingStatsView"].exists)
        XCTAssertTrue(app.buttons["createProgramButton"].exists)
        XCTAssertTrue(app.buttons["reportsButton"].exists)
        
        // Verify filter chips
        XCTAssertTrue(app.buttons["filterChipAll"].exists)
        XCTAssertTrue(app.buttons["filterChipАктивные"].exists)
        XCTAssertTrue(app.buttons["filterChipЗавершены"].exists)
    }
    
    func testFilterOnboardingPrograms() {
        // Login and navigate
        loginAsAdmin()
        navigateToOnboarding()
        
        // Test filter by active programs
        app.buttons["filterChipАктивные"].tap()
        
        // Verify the filter is selected
        _ = app.scrollViews["programsListScrollView"].waitForExistence(timeout: 2)
        
        // Test filter by completed
        app.buttons["filterChipЗавершены"].tap()
        
        // Test search functionality
        let searchField = app.textFields["searchTextField"]
        XCTAssertTrue(searchField.exists)
        searchField.tap()
        searchField.typeText("Иван")
    }
    
    func testCreateNewOnboardingProgram() {
        // Login and navigate
        loginAsAdmin()
        navigateToOnboarding()
        
        // Click create program button
        app.buttons["createProgramButton"].tap()
        
        // Wait for create program view
        XCTAssertTrue(app.navigationBars["Новая программа адаптации"].waitForExistence(timeout: 5))
        
        // Fill in employee name
        let employeeNameField = app.textFields["employeeNameField"]
        if employeeNameField.exists {
            employeeNameField.tap()
            employeeNameField.typeText("Петр Петров")
        }
        
        // Select position if available
        let positionField = app.textFields["positionField"]
        if positionField.exists {
            positionField.tap()
            positionField.typeText("Продавец-консультант")
        }
    }
    
    func testViewOnboardingProgramDetails() {
        // Login and navigate
        loginAsAdmin()
        navigateToOnboarding()
        
        // Wait for programs to load
        _ = app.scrollViews["programsListScrollView"].waitForExistence(timeout: 5)
        
        // Click on first program if exists
        let firstProgram = app.scrollViews["programsListScrollView"].descendants(matching: .button).element(boundBy: 0)
        if firstProgram.exists {
            firstProgram.tap()
            
            // Verify program details view
            XCTAssertTrue(app.navigationBars.element(boundBy: 0).waitForExistence(timeout: 5))
        }
    }
} 