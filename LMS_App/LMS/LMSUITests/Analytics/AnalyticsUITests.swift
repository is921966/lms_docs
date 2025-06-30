//
//  AnalyticsUITests.swift
//  LMSUITests
//
//  Created by Igor Shirokov on 27.06.2025.
//

import XCTest

final class AnalyticsUITests: XCTestCase {
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

    private func navigateToAnalytics() {
        app.tabBars.buttons["Аналитика"].tap()
        _ = app.navigationBars["Аналитика"].waitForExistence(timeout: 3)
    }

    // MARK: - Dashboard Tests

    func testDashboardWidgetsLoad() {
        navigateToAnalytics()

        // Verify main dashboard widgets are visible
        XCTAssertTrue(app.otherElements["widget_user_activity"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.otherElements["widget_course_completion"].exists)
        XCTAssertTrue(app.otherElements["widget_test_pass_rate"].exists)
        XCTAssertTrue(app.otherElements["widget_top_competencies"].exists)
    }

    func testDashboardDateRangeFilter() {
        navigateToAnalytics()

        // Open date range picker
        app.buttons["dateRangeButton"].tap()

        // Select a new range (e.g., "Last 30 days")
        app.sheets.buttons["Последние 30 дней"].tap()

        // Verify that chart data updates (would need specific identifiers on chart data)
        // For now, we just check that the picker closes and the button label updates.
        XCTAssertTrue(app.buttons["Последние 30 дней"].waitForExistence(timeout: 3))
    }

    func testDashboardDrillDown() {
        navigateToAnalytics()

        // Tap on a widget to drill down
        let courseWidget = app.otherElements["widget_course_completion"]
        courseWidget.tap()

        // Verify navigation to detailed report
        XCTAssertTrue(app.navigationBars["Отчет по завершению курсов"].waitForExistence(timeout: 3))

        // Verify table with data is shown
        XCTAssertTrue(!app.tables["courseCompletionReportTable"].cells.isEmpty)
    }

    // MARK: - Reports Tests

    func testGenerateCustomReport() {
        navigateToAnalytics()

        // Go to reports section
        app.segmentedControls.buttons["Отчеты"].tap()

        // Tap create new report
        app.buttons["Создать отчет"].tap()

        // Configure report
        XCTAssertTrue(app.navigationBars["Новый отчет"].waitForExistence(timeout: 3))

        // Select report type
        app.buttons["reportTypeButton"].tap()
        app.sheets.buttons["Отчет по активностям пользователей"].tap()

        // Select users
        app.buttons["selectUsersButton"].tap()
        app.collectionViews.cells.element(boundBy: 0).tap()
        app.collectionViews.cells.element(boundBy: 1).tap()
        app.navigationBars.buttons["Готово"].tap()

        // Generate report
        app.buttons["Сформировать"].tap()

        // Verify report is generated and displayed
        XCTAssertTrue(app.webViews["reportWebView"].waitForExistence(timeout: 10))
    }

    func testScheduleReport() {
        navigateToAnalytics()
        app.segmentedControls.buttons["Отчеты"].tap()

        // Find a report and schedule it
        app.tables["reportsList"].cells.firstMatch.swipeLeft()
        app.buttons["Запланировать"].tap()

        // Configure schedule
        XCTAssertTrue(app.navigationBars["Планирование отчета"].waitForExistence(timeout: 3))

        app.buttons["frequencyButton"].tap()
        app.sheets.buttons["Еженедельно"].tap()

        app.buttons["dayOfWeekButton"].tap()
        app.sheets.buttons["Понедельник"].tap()

        // Add recipient
        app.textFields["recipientEmailField"].tap()
        app.textFields["recipientEmailField"].typeText("manager@lms.ru")
        app.buttons["addRecipientButton"].tap()

        // Save schedule
        app.buttons["Сохранить"].tap()

        // Verify success
        XCTAssertTrue(app.alerts["Отчет запланирован"].waitForExistence(timeout: 3))
        app.alerts.buttons["OK"].tap()
    }

    // MARK: - Export Tests

    func testExportReportToPDF() {
        navigateToAnalytics()
        app.segmentedControls.buttons["Отчеты"].tap()

        // Open a report
        app.tables["reportsList"].cells.firstMatch.tap()
        XCTAssertTrue(app.navigationBars["Отчет по завершению курсов"].waitForExistence(timeout: 3))

        // Tap export button
        app.buttons["exportButton"].tap()

        // Select PDF
        app.sheets.buttons["Экспорт в PDF"].tap()

        // Verify share sheet appears (or a success message)
        XCTAssertTrue(app.sheets["Share Sheet"].waitForExistence(timeout: 5) || app.alerts["Файл сохранен"].exists)
    }

    func testExportDashboardToExcel() {
        navigateToAnalytics()

        // Tap export on dashboard
        app.buttons["exportDashboardButton"].tap()

        // Select Excel
        app.sheets.buttons["Экспорт в Excel"].tap()

        // Verify success message
        XCTAssertTrue(app.alerts["Данные экспортированы в Excel"].waitForExistence(timeout: 5))
        app.alerts.buttons["OK"].tap()
    }
}
