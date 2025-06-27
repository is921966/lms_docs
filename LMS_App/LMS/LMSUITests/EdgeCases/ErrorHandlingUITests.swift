//
//  ErrorHandlingUITests.swift
//  LMSUITests
//
//  Created by Igor Shirokov on 27.06.2025.
//

import XCTest

final class ErrorHandlingUITests: XCTestCase {
    var app: XCUIApplication!
    
    // MARK: - Setup
    
    private func launch(with args: [String]) {
        app = XCUIApplication()
        app.launchArguments = ["UI_TESTING"] + args
        app.launch()
    }
    
    override func tearDownWithError() throws {
        app = nil
    }

    // MARK: - Network Error Tests
    
    func testOfflineModeBannerIsShownOnLaunch() {
        launch(with: ["OFFLINE_MODE"])
        
        // Verify offline banner is visible
        let offlineBanner = app.otherElements["offlineBanner"]
        XCTAssertTrue(offlineBanner.waitForExistence(timeout: 5))
        XCTAssertTrue(offlineBanner.staticTexts["Отсутствует подключение к сети"].exists)
    }
    
    func testSlowNetworkShowsLoadingIndicators() {
        launch(with: ["SLOW_NETWORK_MODE"])
        
        // Login
        let emailField = app.textFields["emailTextField"]
        let passwordField = app.secureTextFields["passwordSecureField"]
        let loginButton = app.buttons["loginButton"]
        
        emailField.tap()
        emailField.typeText("admin@lms.ru")
        passwordField.tap()
        passwordField.typeText("Test123!")
        loginButton.tap()
        
        // Verify loading indicator is shown for a while
        let loadingIndicator = app.activityIndicators["loginLoadingIndicator"]
        XCTAssertTrue(loadingIndicator.waitForExistence(timeout: 3))
        
        // And eventually dashboard appears
        XCTAssertTrue(app.navigationBars["Главная"].waitForExistence(timeout: 10))
    }
    
    func testFailedAPIRequestShowsErrorAlert() {
        launch(with: ["API_ERROR_MODE"])
        
        // Login - this will succeed, but subsequent requests will fail
        let emailField = app.textFields["emailTextField"]
        let passwordField = app.secureTextFields["passwordSecureField"]
        let loginButton = app.buttons["loginButton"]
        
        emailField.tap()
        emailField.typeText("admin@lms.ru")
        passwordField.tap()
        passwordField.typeText("Test123!")
        loginButton.tap()
        
        _ = app.navigationBars["Главная"].waitForExistence(timeout: 5)
        
        // Navigate to a screen that loads data
        app.tabBars.buttons["Курсы"].tap()
        
        // Verify an error alert is shown
        let errorAlert = app.alerts["Ошибка сервера"]
        XCTAssertTrue(errorAlert.waitForExistence(timeout: 5))
        XCTAssertTrue(errorAlert.staticTexts["Не удалось загрузить данные. Попробуйте позже."].exists)
        errorAlert.buttons["OK"].tap()
    }
    
    // MARK: - Validation Error Tests
    
    func testLoginFormValidation() {
        launch(with: ["MOCK_MODE"])

        // Empty fields
        app.buttons["loginButton"].tap()
        XCTAssertTrue(app.staticTexts["Поле E-mail не может быть пустым"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.staticTexts["Поле Пароль не может быть пустым"].exists)
        
        // Invalid email
        let emailField = app.textFields["emailTextField"]
        emailField.tap()
        emailField.typeText("invalid-email")
        app.buttons["loginButton"].tap()
        XCTAssertTrue(app.staticTexts["Введите корректный E-mail"].waitForExistence(timeout: 2))
    }
    
    func testCreateCourseFormValidation() {
        launch(with: ["MOCK_MODE"])
        
        // Login as admin
        let emailField = app.textFields["emailTextField"]
        let passwordField = app.secureTextFields["passwordSecureField"]
        let loginButton = app.buttons["loginButton"]
        emailField.tap()
        emailField.typeText("admin@lms.ru")
        passwordField.tap()
        passwordField.typeText("Test123!")
        loginButton.tap()
        _ = app.navigationBars["Главная"].waitForExistence(timeout: 5)

        // Navigate to create course
        app.tabBars.buttons["Курсы"].tap()
        app.buttons["addCourseButton"].tap()
        _ = app.navigationBars["Новый курс"].waitForExistence(timeout: 3)
        
        // Try to save with empty name
        app.buttons["Сохранить"].tap()
        XCTAssertTrue(app.staticTexts["Название курса обязательно"].waitForExistence(timeout: 2))
        
        // Enter name, try to save with no category
        app.textFields["courseNameTextField"].tap()
        app.textFields["courseNameTextField"].typeText("Тестовый курс")
        app.buttons["Сохранить"].tap()
        XCTAssertTrue(app.staticTexts["Выберите категорию"].waitForExistence(timeout: 2))
    }
} 