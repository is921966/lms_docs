//
//  TaskCompletionUITests.swift
//  LMSUITests
//
//  Created by Igor Shirokov on 27.06.2025.
//

import XCTest

final class TaskCompletionUITests: XCTestCase {
    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["UI_TESTING", "MOCK_MODE"]
        app.launch()

        loginAsNewUserAndNavigateToTasks()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    // MARK: - Helper Methods

    private func loginAsNewUserAndNavigateToTasks() {
        let emailField = app.textFields["emailTextField"]
        let passwordField = app.secureTextFields["passwordSecureField"]
        let loginButton = app.buttons["loginButton"]

        emailField.tap()
        emailField.typeText("new.user@lms.ru")

        passwordField.tap()
        passwordField.typeText("Test123!")

        loginButton.tap()

        // Navigate to tasks tab
        app.tabBars.buttons["Задачи"].tap()
        _ = app.navigationBars["Задачи на адаптацию"].waitForExistence(timeout: 3)
    }

    // MARK: - Test Cases

    func testCompleteSimpleTask() {
        // Find and tap on a simple task (e.g., read document)
        let taskCell = app.collectionViews.cells.containing(.staticText, identifier: "Прочитать регламент").firstMatch
        XCTAssertTrue(taskCell.exists)
        taskCell.tap()

        // Wait for task details
        XCTAssertTrue(app.navigationBars["Задача: Прочитать регламент"].waitForExistence(timeout: 3))

        // Mark as completed
        let completeButton = app.buttons["Отметить как выполненное"]
        XCTAssertTrue(completeButton.isEnabled)
        completeButton.tap()

        // Verify task is marked as completed
        XCTAssertTrue(app.alerts["Задача выполнена!"].waitForExistence(timeout: 3))
        app.alerts.buttons["OK"].tap()

        XCTAssertTrue(taskCell.images["completedIcon"].exists)
    }

    func testUploadDocumentForTask() {
        // Find and tap on an upload task
        let taskCell = app.collectionViews.cells.containing(.staticText, identifier: "Загрузить скан паспорта").firstMatch
        taskCell.tap()

        // Tap upload button
        app.buttons["Загрузить документ"].tap()

        // Mock file picker interaction
        if app.sheets["Выберите файл"].exists {
            app.sheets.buttons["Выбрать из галереи"].tap()
            // In a real scenario, we'd interact with photos picker
            sleep(1) // Simulate picking a photo
        }

        // Verify file is attached
        XCTAssertTrue(app.staticTexts["passport_scan.pdf"].exists)

        // Submit task
        app.buttons["Отправить на проверку"].tap()

        // Verify success
        XCTAssertTrue(app.alerts["Документ отправлен на проверку"].waitForExistence(timeout: 3))
        app.alerts.buttons["OK"].tap()
    }

    func testTaskWithValidationError() {
        // Find task that requires input
        let taskCell = app.collectionViews.cells.containing(.staticText, identifier: "Заполнить анкету").firstMatch
        taskCell.tap()

        // Try to submit without filling
        app.buttons["Сохранить"].tap()

        // Verify validation error
        let errorText = app.staticTexts["Все поля обязательны для заполнения"]
        XCTAssertTrue(errorText.waitForExistence(timeout: 2))
    }

    func testOverdueTaskState() {
        // Find an overdue task (mocked data)
        let overdueCell = app.collectionViews.cells.containing(.staticText, identifier: "Просрочено").firstMatch
        XCTAssertTrue(overdueCell.exists)

        // Verify visual state
        // This would require specific accessibility identifiers for colors or icons
        // For now, we just check for the text "Просрочено"

        overdueCell.tap()

        // Verify overdue warning in task details
        let warningText = app.staticTexts["Срок выполнения задачи истек!"]
        XCTAssertTrue(warningText.waitForExistence(timeout: 2))
    }
}
