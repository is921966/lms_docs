//
//  PositionManagementUITests.swift
//  LMSUITests
//
//  Created by Igor Shirokov on 27.06.2025.
//

import XCTest

final class PositionManagementUITests: XCTestCase {
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

    private func navigateToPositions() {
        app.tabBars.buttons["Ещё"].tap()
        app.collectionViews.buttons["Должности"].tap()

        // Wait for positions list
        _ = app.navigationBars["Должности"].waitForExistence(timeout: 3)
    }

    // MARK: - Test Cases

    func testViewPositionsList() throws {
        // Navigate to positions
        navigateToPositions()

        // Verify positions list is displayed
        XCTAssertTrue(app.navigationBars["Должности"].exists)
        XCTAssertTrue(app.searchFields["Поиск должностей"].exists)

        // Check for sections
        XCTAssertTrue(app.segmentedControls["positionSections"].exists)

        // Check for at least one position
        let firstPosition = app.collectionViews.cells.firstMatch
        XCTAssertTrue(firstPosition.waitForExistence(timeout: 3))
    }

    func testCreateNewPosition() throws {
        // Navigate to positions
        navigateToPositions()

        // Tap add button
        app.navigationBars["Должности"].buttons["plus"].tap()

        // Wait for create position form
        XCTAssertTrue(app.navigationBars["Новая должность"].waitForExistence(timeout: 3))

        // Fill position details
        let nameField = app.textFields["positionNameTextField"]
        nameField.tap()
        nameField.typeText("Senior iOS Developer")

        let levelField = app.textFields["levelTextField"]
        levelField.tap()
        levelField.typeText("L4")

        // Select department
        app.buttons["departmentButton"].tap()
        app.sheets.buttons["IT отдел"].tap()

        // Add description
        let descriptionView = app.textViews["descriptionTextView"]
        descriptionView.tap()
        descriptionView.typeText("Разработка iOS приложений для корпоративных клиентов")

        // Save position
        app.navigationBars["Новая должность"].buttons["Сохранить"].tap()

        // Verify success
        XCTAssertTrue(app.alerts["Должность создана"].waitForExistence(timeout: 3))
        app.alerts.buttons["OK"].tap()
    }

    func testEditPositionRequirements() throws {
        // Navigate to positions
        navigateToPositions()

        // Select first position
        let firstPosition = app.collectionViews.cells.firstMatch
        firstPosition.tap()

        // Wait for position details
        XCTAssertTrue(app.navigationBars.element(matching: .navigationBar, identifier: nil).waitForExistence(timeout: 3))

        // Tap requirements tab
        app.buttons["Требования"].tap()

        // Add new requirement
        app.buttons["Добавить требование"].tap()

        // Select competency
        XCTAssertTrue(app.navigationBars["Выбор компетенции"].waitForExistence(timeout: 3))
        app.collectionViews.cells.element(boundBy: 0).tap()

        // Set level
        app.segmentedControls["levelControl"].buttons["Продвинутый"].tap()

        // Save requirement
        app.buttons["Добавить"].tap()

        // Verify requirement added
        XCTAssertTrue(!app.collectionViews.cells.isEmpty)
    }

    func testPositionHierarchy() throws {
        // Navigate to positions
        navigateToPositions()

        // Switch to hierarchy view
        app.buttons["hierarchyViewButton"].tap()

        // Wait for hierarchy
        XCTAssertTrue(app.otherElements["positionHierarchy"].waitForExistence(timeout: 3))

        // Expand a node
        let expandButton = app.buttons.matching(identifier: "expandButton").firstMatch
        if expandButton.exists {
            expandButton.tap()
            sleep(1)
        }

        // Verify child positions are visible
        let hierarchyCells = app.collectionViews["hierarchyView"].cells
        XCTAssertTrue(hierarchyCells.count > 1)
    }

    func testCareerPathCreation() throws {
        // Navigate to positions
        navigateToPositions()

        // Select a position
        app.collectionViews.cells.firstMatch.tap()

        // Tap career paths tab
        app.buttons["Карьерные пути"].tap()

        // Add new career path
        app.buttons["Создать карьерный путь"].tap()

        // Select target position
        XCTAssertTrue(app.navigationBars["Целевая должность"].waitForExistence(timeout: 3))
        app.collectionViews.cells.element(boundBy: 1).tap()

        // Add milestones
        app.buttons["Добавить этап"].tap()

        let milestoneField = app.textFields["milestoneTextField"]
        milestoneField.tap()
        milestoneField.typeText("Получить сертификацию")

        app.buttons["durationButton"].tap()
        app.sheets.buttons["6 месяцев"].tap()

        // Save career path
        app.navigationBars.buttons["Сохранить"].tap()

        // Verify success
        XCTAssertTrue(app.alerts["Карьерный путь создан"].waitForExistence(timeout: 3))
        app.alerts.buttons["OK"].tap()
    }
}
