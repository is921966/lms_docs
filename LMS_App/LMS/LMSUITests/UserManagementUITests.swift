//
//  UserManagementUITests.swift
//  LMSUITests
//
//  Created by Igor Shirokov on 27.06.2025.
//

import XCTest

final class UserManagementUITests: XCTestCase {
    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["UI_TESTING", "MOCK_MODE"]
        app.launch()

        // Login as admin
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

        // Wait for dashboard
        _ = app.navigationBars["Главная"].waitForExistence(timeout: 5)
    }

    private func navigateToUsers() {
        app.tabBars.buttons["Ещё"].tap()
        app.collectionViews.buttons["Пользователи"].tap()

        // Wait for users list
        _ = app.navigationBars["Пользователи"].waitForExistence(timeout: 3)
    }

    // MARK: - Test Cases

    func testViewUsersList() throws {
        // Navigate to users
        navigateToUsers()

        // Verify users list is displayed
        XCTAssertTrue(app.navigationBars["Пользователи"].exists)
        XCTAssertTrue(app.searchFields["Поиск пользователей"].exists)

        // Check for at least one user in the list
        let firstUser = app.collectionViews.cells.firstMatch
        XCTAssertTrue(firstUser.waitForExistence(timeout: 3))
    }

    func testSearchUsers() throws {
        // Navigate to users
        navigateToUsers()

        // Search for a user
        let searchField = app.searchFields["Поиск пользователей"]
        searchField.tap()
        searchField.typeText("Иван")

        // Wait for search results
        sleep(1)

        // Verify filtered results
        let userCell = app.collectionViews.cells.containing(.staticText, identifier: "Иван").firstMatch
        XCTAssertTrue(userCell.exists)
    }

    func testCreateNewUser() throws {
        // Navigate to users
        navigateToUsers()

        // Tap add button
        app.navigationBars["Пользователи"].buttons["plus"].tap()

        // Wait for create user form
        XCTAssertTrue(app.navigationBars["Новый пользователь"].waitForExistence(timeout: 3))

        // Fill in user details
        let firstNameField = app.textFields["firstNameTextField"]
        firstNameField.tap()
        firstNameField.typeText("Тест")

        let lastNameField = app.textFields["lastNameTextField"]
        lastNameField.tap()
        lastNameField.typeText("Пользователь")

        let emailField = app.textFields["emailTextField"]
        emailField.tap()
        emailField.typeText("test.user@lms.ru")

        // Select role
        app.buttons["roleButton"].tap()
        app.sheets.buttons["Сотрудник"].tap()

        // Select department
        app.buttons["departmentButton"].tap()
        app.sheets.buttons["IT отдел"].tap()

        // Save user
        app.navigationBars["Новый пользователь"].buttons["Сохранить"].tap()

        // Verify success
        XCTAssertTrue(app.alerts["Успешно"].waitForExistence(timeout: 3))
        app.alerts.buttons["OK"].tap()

        // Verify user appears in list
        XCTAssertTrue(app.navigationBars["Пользователи"].waitForExistence(timeout: 3))
    }

    func testEditUserDetails() throws {
        // Navigate to users
        navigateToUsers()

        // Select first user
        let firstUser = app.collectionViews.cells.firstMatch
        firstUser.tap()

        // Wait for user details
        XCTAssertTrue(app.navigationBars["Профиль пользователя"].waitForExistence(timeout: 3))

        // Tap edit button
        app.navigationBars["Профиль пользователя"].buttons["Редактировать"].tap()

        // Edit phone number
        let phoneField = app.textFields["phoneTextField"]
        if phoneField.value as? String != "" {
            phoneField.tap()
            phoneField.doubleTap()
            app.menuItems["Select All"].tap()
            phoneField.typeText(XCUIKeyboardKey.delete.rawValue)
        }
        phoneField.typeText("+7 999 123-45-67")

        // Save changes
        app.navigationBars["Редактирование"].buttons["Сохранить"].tap()

        // Verify success
        XCTAssertTrue(app.alerts["Изменения сохранены"].waitForExistence(timeout: 3))
        app.alerts.buttons["OK"].tap()
    }

    func testDeactivateUser() throws {
        // Navigate to users
        navigateToUsers()

        // Select a user
        let userCell = app.collectionViews.cells.element(boundBy: 1)
        userCell.tap()

        // Wait for user details
        XCTAssertTrue(app.navigationBars["Профиль пользователя"].waitForExistence(timeout: 3))

        // Tap more options
        app.navigationBars["Профиль пользователя"].buttons["ellipsis"].tap()

        // Select deactivate
        app.sheets.buttons["Деактивировать пользователя"].tap()

        // Confirm deactivation
        XCTAssertTrue(app.alerts["Подтверждение"].waitForExistence(timeout: 3))
        app.alerts.buttons["Деактивировать"].tap()

        // Verify success
        XCTAssertTrue(app.alerts["Пользователь деактивирован"].waitForExistence(timeout: 3))
        app.alerts.buttons["OK"].tap()
    }

    func testBulkUserImport() throws {
        // Navigate to users
        navigateToUsers()

        // Tap more options
        app.navigationBars["Пользователи"].buttons["ellipsis"].tap()

        // Select import
        app.sheets.buttons["Импорт пользователей"].tap()

        // Wait for import screen
        XCTAssertTrue(app.navigationBars["Импорт пользователей"].waitForExistence(timeout: 3))

        // Download template
        app.buttons["Скачать шаблон"].tap()
        sleep(1)

        // Select file (in real app would use document picker)
        app.buttons["Выбрать файл"].tap()

        // Mock file selection
        if app.sheets["Выберите файл"].exists {
            app.sheets.buttons["Использовать пример"].tap()
        }

        // Start import
        app.buttons["Начать импорт"].tap()

        // Wait for progress
        XCTAssertTrue(app.progressIndicators["importProgress"].waitForExistence(timeout: 3))

        // Verify completion
        XCTAssertTrue(app.staticTexts["Импорт завершен"].waitForExistence(timeout: 10))
    }
}
