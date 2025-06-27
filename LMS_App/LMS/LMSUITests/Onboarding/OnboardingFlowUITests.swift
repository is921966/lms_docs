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
        
        // Login as new user for onboarding
        loginAsNewUser()
    }
    
    override func tearDownWithError() throws {
        app = nil
    }
    
    // MARK: - Helper Methods
    
    private func loginAsNewUser() {
        let emailField = app.textFields["emailTextField"]
        let passwordField = app.secureTextFields["passwordSecureField"]
        let loginButton = app.buttons["loginButton"]
        
        emailField.tap()
        emailField.typeText("new.user@lms.ru") // Special user that triggers onboarding
        
        passwordField.tap()
        passwordField.typeText("Test123!")
        
        loginButton.tap()
        
        // Wait for onboarding to start
        _ = app.staticTexts["Добро пожаловать в команду!"].waitForExistence(timeout: 5)
    }
    
    // MARK: - Test Cases
    
    func testStartOnboardingFlow() {
        // Verify welcome screen is shown
        XCTAssertTrue(app.staticTexts["Добро пожаловать в команду!"].exists)
        XCTAssertTrue(app.buttons["Начать адаптацию"].exists)
        
        // Start onboarding
        app.buttons["Начать адаптацию"].tap()
        
        // Verify first step is shown
        XCTAssertTrue(app.navigationBars["Шаг 1: Знакомство с компанией"].waitForExistence(timeout: 3))
    }
    
    func testNavigateThroughOnboardingSteps() {
        // Start onboarding
        app.buttons["Начать адаптацию"].tap()
        XCTAssertTrue(app.navigationBars["Шаг 1: Знакомство с компанией"].waitForExistence(timeout: 3))
        
        // Complete first step
        app.buttons["Я ознакомился"].tap()
        
        // Verify second step
        XCTAssertTrue(app.navigationBars["Шаг 2: Настройка рабочего места"].waitForExistence(timeout: 3))
        
        // Complete second step
        app.buttons["Все настроено"].tap()
        
        // Verify final step
        XCTAssertTrue(app.staticTexts["Адаптация почти завершена!"].waitForExistence(timeout: 3))
    }
    
    func testSkipOptionalStep() {
        // Navigate to an optional step (e.g., Step 3)
        app.buttons["Начать адаптацию"].tap()
        app.buttons["Я ознакомился"].tap()
        app.buttons["Все настроено"].tap()
        
        // Assume Step 3 is optional survey
        XCTAssertTrue(app.navigationBars["Шаг 3: Опрос"].waitForExistence(timeout: 3))
        
        // Check for skip button
        let skipButton = app.buttons["Пропустить"]
        XCTAssertTrue(skipButton.exists)
        
        // Skip the step
        skipButton.tap()
        
        // Verify next step is shown
        XCTAssertTrue(app.navigationBars["Шаг 4: План на первую неделю"].waitForExistence(timeout: 3))
    }
    
    func testSaveProgressAndResume() {
        // Start onboarding and complete one step
        app.buttons["Начать адаптацию"].tap()
        app.buttons["Я ознакомился"].tap()
        XCTAssertTrue(app.navigationBars["Шаг 2: Настройка рабочего места"].waitForExistence(timeout: 3))

        // Close and relaunch app (simulated)
        app.terminate()
        app.launch()
        
        // Login again
        loginAsNewUser()
        
        // Verify app resumes from the correct step
        XCTAssertTrue(app.staticTexts["Продолжить адаптацию?"].waitForExistence(timeout: 5))
        app.buttons["Продолжить"].tap()
        
        XCTAssertTrue(app.navigationBars["Шаг 2: Настройка рабочего места"].waitForExistence(timeout: 3))
    }
} 