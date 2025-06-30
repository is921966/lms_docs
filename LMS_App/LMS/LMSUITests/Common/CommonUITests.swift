//
//  CommonUITests.swift
//  LMSUITests
//
//  Created by Igor Shirokov on 27.06.2025.
//

import XCTest

final class CommonUITests: XCTestCase {
    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["UI_TESTING", "MOCK_MODE"]
        app.launch()

        loginAsAdmin()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    // MARK: - Helper Methods

    private func loginAsAdmin() {
        let emailField = app.textFields["emailTextField"]
        let passwordField = app.secureTextFields["passwordSecureField"]
        let loginButton = app.buttons["loginButton"]

        emailField.tap()
        emailField.typeText("admin@lms.ru")

        passwordField.tap()
        passwordField.typeText("Test123!")

        loginButton.tap()

        _ = app.navigationBars["Главная"].waitForExistence(timeout: 5)
    }

    // MARK: - Search Tests

    func testGlobalSearch() {
        // Tap on the global search bar
        let searchBar = app.navigationBars["Главная"].searchFields["Поиск..."]
        searchBar.tap()

        // Search for a course
        searchBar.typeText("Дизайн")

        // Verify search results are shown
        XCTAssertTrue(app.tables["searchResults"].staticTexts["Курс: Основы дизайна"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.tables["searchResults"].staticTexts["Тест: Принципы дизайна"].exists)
        XCTAssertTrue(app.tables["searchResults"].staticTexts["Сотрудник: Диана Смирнова"].exists)
    }

    func testSearchFilters() {
        let searchBar = app.navigationBars["Главная"].searchFields["Поиск..."]
        searchBar.tap()
        searchBar.typeText("Дизайн")

        // Tap filter button
        app.buttons["filterButton"].tap()

        // Select filter by "Courses"
        app.sheets.buttons["Только курсы"].tap()

        // Verify results are filtered
        XCTAssertTrue(app.tables["searchResults"].staticTexts["Курс: Основы дизайна"].exists)
        XCTAssertFalse(app.tables["searchResults"].staticTexts["Тест: Принципы дизайна"].exists)
    }

    // MARK: - Profile Tests

    func testEditProfileAndChangeAvatar() {
        // Navigate to profile
        app.tabBars.buttons["Профиль"].tap()
        _ = app.navigationBars["Профиль"].waitForExistence(timeout: 3)

        // Tap edit button
        app.buttons["Редактировать профиль"].tap()

        // Change avatar
        app.buttons["сменить фото"].tap()
        app.sheets.buttons["Выбрать из галереи"].tap()
        sleep(1) // Simulate photo picker

        // Edit phone number
        let phoneField = app.textFields["phoneTextField"]
        phoneField.tap()
        phoneField.doubleTap()
        app.menuItems["Select All"].tap()
        phoneField.typeText(XCUIKeyboardKey.delete.rawValue)
        phoneField.typeText("+7 (111) 222-33-44")

        // Save
        app.buttons["Сохранить"].tap()

        // Verify success
        XCTAssertTrue(app.staticTexts["+7 (111) 222-33-44"].waitForExistence(timeout: 3))
    }

    func testChangeAppSettings() {
        // Navigate to profile
        app.tabBars.buttons["Профиль"].tap()
        app.navigationBars["Профиль"].buttons["settingsButton"].tap()

        // Wait for settings screen
        _ = app.navigationBars["Настройки"].waitForExistence(timeout: 3)

        // Toggle push notifications
        let pushToggle = app.switches["pushNotificationsSwitch"]
        let initialValue = pushToggle.value as? String
        pushToggle.tap()
        XCTAssertNotEqual(pushToggle.value as? String, initialValue)

        // Change language
        app.buttons["languageButton"].tap()
        app.sheets.buttons["English"].tap()

        // Verify language change
        XCTAssertTrue(app.navigationBars["Settings"].waitForExistence(timeout: 3))
    }
}
