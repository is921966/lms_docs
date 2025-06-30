//
//  CompetencyManagementUITests.swift
//  LMSUITests
//
//  Created by Igor Shirokov on 27.06.2025.
//

import XCTest

final class CompetencyManagementUITests: XCTestCase {
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

    private func navigateToCompetencies() {
        app.tabBars.buttons["Ещё"].tap()
        app.collectionViews.buttons["Компетенции"].tap()

        // Wait for competencies list
        _ = app.navigationBars["Компетенции"].waitForExistence(timeout: 3)
    }

    // MARK: - Test Cases

    func testViewCompetenciesList() throws {
        // Navigate to competencies
        navigateToCompetencies()

        // Verify competencies list is displayed
        XCTAssertTrue(app.navigationBars["Компетенции"].exists)
        XCTAssertTrue(app.searchFields["Поиск компетенций"].exists)

        // Check for categories
        XCTAssertTrue(app.segmentedControls["competencyCategories"].exists)

        // Check for at least one competency
        let firstCompetency = app.collectionViews.cells.firstMatch
        XCTAssertTrue(firstCompetency.waitForExistence(timeout: 3))
    }

    func testCreateNewCompetency() throws {
        // Navigate to competencies
        navigateToCompetencies()

        // Tap add button
        app.navigationBars["Компетенции"].buttons["plus"].tap()

        // Wait for create competency form
        XCTAssertTrue(app.navigationBars["Новая компетенция"].waitForExistence(timeout: 3))

        // Fill competency details
        let nameField = app.textFields["competencyNameTextField"]
        nameField.tap()
        nameField.typeText("iOS разработка")

        // Select category
        app.buttons["categoryButton"].tap()
        app.sheets.buttons["Технические навыки"].tap()

        // Add description
        let descriptionView = app.textViews["descriptionTextView"]
        descriptionView.tap()
        descriptionView.typeText("Навыки разработки iOS приложений на Swift")

        // Add levels
        app.buttons["Добавить уровень"].tap()

        let levelNameField = app.textFields["levelNameTextField"]
        levelNameField.tap()
        levelNameField.typeText("Начальный")

        let levelDescField = app.textViews["levelDescriptionTextView"]
        levelDescField.tap()
        levelDescField.typeText("Базовые знания Swift и UIKit")

        // Save competency
        app.navigationBars["Новая компетенция"].buttons["Сохранить"].tap()

        // Verify success
        XCTAssertTrue(app.alerts["Компетенция создана"].waitForExistence(timeout: 3))
        app.alerts.buttons["OK"].tap()
    }

    func testEditCompetencyLevels() throws {
        // Navigate to competencies
        navigateToCompetencies()

        // Select first competency
        let firstCompetency = app.collectionViews.cells.firstMatch
        firstCompetency.tap()

        // Wait for competency details
        XCTAssertTrue(app.navigationBars.element(matching: .navigationBar, identifier: nil).waitForExistence(timeout: 3))

        // Tap edit button
        app.navigationBars.buttons["Редактировать"].tap()

        // Edit level description
        let levelCell = app.collectionViews.cells.element(boundBy: 0)
        levelCell.tap()

        let levelDescField = app.textViews["levelDescriptionTextView"]
        levelDescField.tap()
        levelDescField.doubleTap()
        app.menuItems["Select All"].tap()
        levelDescField.typeText("Обновленное описание уровня компетенции")

        // Save changes
        app.navigationBars.buttons["Сохранить"].tap()

        // Verify success
        XCTAssertTrue(app.alerts["Изменения сохранены"].waitForExistence(timeout: 3))
        app.alerts.buttons["OK"].tap()
    }

    func testAssignCompetencyToUser() throws {
        // Navigate to competencies
        navigateToCompetencies()

        // Select a competency
        app.collectionViews.cells.firstMatch.tap()

        // Tap assign button
        app.buttons["Назначить пользователям"].tap()

        // Search for user
        let searchField = app.searchFields["Поиск пользователей"]
        searchField.tap()
        searchField.typeText("Иван")

        // Select user
        sleep(1)
        app.collectionViews.cells.firstMatch.tap()

        // Set target level
        app.segmentedControls["targetLevel"].buttons["Средний"].tap()

        // Set deadline
        app.buttons["deadlineButton"].tap()
        app.datePickers.firstMatch.pickerWheels.element(boundBy: 0).adjust(toPickerWheelValue: "31")
        app.buttons["Готово"].tap()

        // Assign
        app.buttons["Назначить"].tap()

        // Verify success
        XCTAssertTrue(app.alerts["Компетенция назначена"].waitForExistence(timeout: 3))
        app.alerts.buttons["OK"].tap()
    }

    func testCompetencyMatrix() throws {
        // Navigate to competencies
        navigateToCompetencies()

        // Switch to matrix view
        app.buttons["matrixViewButton"].tap()

        // Wait for matrix
        XCTAssertTrue(app.tables["competencyMatrix"].waitForExistence(timeout: 3))

        // Filter by department
        app.buttons["filterButton"].tap()
        app.sheets.buttons["IT отдел"].tap()

        // Verify matrix cells
        let matrixCells = app.tables["competencyMatrix"].cells
        XCTAssertTrue(!matrixCells.isEmpty)

        // Tap on a cell to see details
        matrixCells.firstMatch.tap()

        // Verify detail popover
        XCTAssertTrue(app.popovers.firstMatch.waitForExistence(timeout: 3))

        // Close popover
        app.tap()
    }

    func testCompetencyAssessment() throws {
        // Navigate to competencies
        navigateToCompetencies()

        // Tap assessments tab
        app.buttons["Оценки"].tap()

        // Start new assessment
        app.buttons["Начать оценку"].tap()

        // Select assessment type
        XCTAssertTrue(app.sheets["Тип оценки"].waitForExistence(timeout: 3))
        app.sheets.buttons["Самооценка"].tap()

        // Select competencies to assess
        XCTAssertTrue(app.navigationBars["Выбор компетенций"].waitForExistence(timeout: 3))

        // Select first 3 competencies
        for i in 0..<3 {
            app.collectionViews.cells.element(boundBy: i).tap()
        }

        app.buttons["Далее"].tap()

        // Rate first competency
        XCTAssertTrue(app.navigationBars["Оценка компетенций"].waitForExistence(timeout: 3))
        app.segmentedControls["ratingControl"].buttons["3"].tap()

        // Add comment
        let commentField = app.textViews["commentTextView"]
        commentField.tap()
        commentField.typeText("Хорошие базовые знания")

        // Navigate to next
        app.buttons["Следующая"].tap()

        // Complete assessment
        app.buttons["Завершить оценку"].tap()

        // Verify completion
        XCTAssertTrue(app.alerts["Оценка завершена"].waitForExistence(timeout: 3))
        app.alerts.buttons["OK"].tap()
    }

    func testCompetencyGapAnalysis() throws {
        // Navigate to competencies
        navigateToCompetencies()

        // Tap analytics button
        app.buttons["analyticsButton"].tap()

        // Select gap analysis
        app.sheets.buttons["Gap-анализ"].tap()

        // Wait for analysis screen
        XCTAssertTrue(app.navigationBars["Gap-анализ компетенций"].waitForExistence(timeout: 3))

        // Select department
        app.buttons["departmentFilterButton"].tap()
        app.sheets.buttons["IT отдел"].tap()

        // Generate report
        app.buttons["Сформировать отчет"].tap()

        // Wait for results
        XCTAssertTrue(app.progressIndicators["analysisProgress"].waitForExistence(timeout: 3))

        // Verify results displayed
        XCTAssertTrue(app.otherElements["gapChart"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.tables["gapDetails"].exists)

        // Export report
        app.buttons["exportButton"].tap()
        app.sheets.buttons["PDF"].tap()

        // Verify export success
        XCTAssertTrue(app.alerts["Отчет экспортирован"].waitForExistence(timeout: 3))
        app.alerts.buttons["OK"].tap()
    }
}
