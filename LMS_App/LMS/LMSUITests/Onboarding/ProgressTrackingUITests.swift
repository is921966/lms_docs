//
//  ProgressTrackingUITests.swift
//  LMSUITests
//
//  Created by Igor Shirokov on 27.06.2025.
//

import XCTest

final class ProgressTrackingUITests: XCTestCase {
    var app: XCUIApplication!
    
    // MARK: - Setup
    
    private func launchAndLogin(as role: String) {
        app = XCUIApplication()
        app.launchArguments = ["UI_TESTING", "MOCK_MODE"]
        app.launch()
        
        let emailField = app.textFields["emailTextField"]
        let passwordField = app.secureTextFields["passwordSecureField"]
        let loginButton = app.buttons["loginButton"]
        
        emailField.tap()
        emailField.typeText("\(role)@lms.ru")
        
        passwordField.tap()
        passwordField.typeText("Test123!")
        
        loginButton.tap()
    }
    
    override func tearDownWithError() throws {
        app = nil
    }
    
    // MARK: - Test Cases for New User
    
    func testViewPersonalOnboardingProgress() {
        launchAndLogin(as: "new.user")
        
        // Navigate to onboarding dashboard
        app.tabBars.buttons["Главная"].tap()
        app.buttons["Моя адаптация"].tap()
        
        // Wait for progress screen
        XCTAssertTrue(app.navigationBars["Прогресс адаптации"].waitForExistence(timeout: 3))
        
        // Verify progress indicator exists
        let progressView = app.progressIndicators["onboardingProgress"]
        XCTAssertTrue(progressView.exists)
        
        // Check for task list
        XCTAssertTrue(app.collectionViews["onboardingTasksList"].exists)
        
        // Check for completed/pending tasks
        XCTAssertTrue(app.collectionViews.cells.containing(.staticText, identifier: "Выполнено").firstMatch.exists)
        XCTAssertTrue(app.collectionViews.cells.containing(.staticText, identifier: "В процессе").firstMatch.exists)
    }
    
    func testReceiveProgressNotification() {
        launchAndLogin(as: "new.user")
        
        // This test is hard to implement as-is in UI tests.
        // We can simulate the tap on a notification banner.
        // Or check the notification list.
        
        app.tabBars.buttons["Уведомления"].tap()
        _ = app.navigationBars["Уведомления"].waitForExistence(timeout: 3)
        
        let notificationCell = app.collectionViews.cells.containing(.staticText, identifier: "Ваш наставник подтвердил выполнение задачи").firstMatch
        XCTAssertTrue(notificationCell.waitForExistence(timeout: 5))
        notificationCell.tap()
        
        // Verify it navigates to the completed task
        XCTAssertTrue(app.navigationBars["Задача: Знакомство с командой"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.staticTexts["Задача проверена и принята"].exists)
    }

    func testOnboardingCompletionAndCertificate() {
        launchAndLogin(as: "onboarding.completed.user") // Special user with 100% progress
        
        // Navigate to onboarding dashboard
        app.tabBars.buttons["Главная"].tap()
        app.buttons["Моя адаптация"].tap()
        
        // Verify completion state
        XCTAssertTrue(app.staticTexts["Поздравляем! Адаптация успешно пройдена!"].waitForExistence(timeout: 3))
        
        // Check for certificate button
        let certificateButton = app.buttons["Получить сертификат"]
        XCTAssertTrue(certificateButton.exists)
        certificateButton.tap()
        
        // Verify certificate view is shown
        XCTAssertTrue(app.navigationBars["Сертификат о прохождении адаптации"].waitForExistence(timeout: 3))
        
        // Check for export button
        XCTAssertTrue(app.buttons["Экспорт в PDF"].exists)
    }
    
    // MARK: - Test Cases for Manager
    
    func testManagerViewTeamOnboardingProgress() {
        launchAndLogin(as: "manager")
        
        // Navigate to manager dashboard for onboarding
        app.tabBars.buttons["Команда"].tap()
        app.segmentedControls.buttons["Адаптация"].tap()
        
        // Wait for team progress list
        XCTAssertTrue(app.navigationBars["Адаптация команды"].waitForExistence(timeout: 3))
        
        // Check for list of employees
        let employeeCell = app.collectionViews.cells.containing(.staticText, identifier: "Иван Иванов").firstMatch
        XCTAssertTrue(employeeCell.exists)
        
        // Verify progress bar is visible for the employee
        XCTAssertTrue(employeeCell.progressIndicators["employeeProgress"].exists)
        
        // Tap on employee to see details
        employeeCell.tap()
        
        // Verify detailed progress view
        XCTAssertTrue(app.navigationBars["Прогресс Ивана Иванова"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.collectionViews["employeeTasksList"].exists)
    }
} 