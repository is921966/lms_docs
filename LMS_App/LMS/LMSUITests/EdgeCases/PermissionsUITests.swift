//
//  PermissionsUITests.swift
//  LMSUITests
//
//  Created by Igor Shirokov on 27.06.2025.
//

import XCTest

final class PermissionsUITests: XCTestCase {
    private var app: XCUIApplication!

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

        _ = app.navigationBars["Главная"].waitForExistence(timeout: 5)
    }

    override func tearDownWithError() throws {
        app = nil
    }

    // MARK: - Test Cases

    func testStudentAccessToAdminPanelIsDenied() {
        launchAndLogin(as: "student")

        // Try to find Admin panel button
        let moreButton = app.tabBars.buttons["Ещё"]
        moreButton.tap()

        let adminPanelButton = app.collectionViews.buttons["Панель администратора"]
        XCTAssertFalse(adminPanelButton.exists, "Student should not see the Admin Panel button")
    }

    func testStudentCannotEditCourse() {
        launchAndLogin(as: "student")

        // Navigate to a course
        app.tabBars.buttons["Курсы"].tap()
        app.collectionViews.cells.firstMatch.tap()

        // Verify no edit button is present
        _ = app.navigationBars.element.waitForExistence(timeout: 3)
        XCTAssertFalse(app.buttons["Редактировать курс"].exists)
        XCTAssertFalse(app.buttons["Управление материалами"].exists)
    }

    func testManagerCanSeeTeamAnalytics() {
        launchAndLogin(as: "manager")

        // Navigate to analytics
        app.tabBars.buttons["Аналитика"].tap()

        // Verify "My Team" tab is visible
        XCTAssertTrue(app.segmentedControls.buttons["Моя команда"].waitForExistence(timeout: 3))
        app.segmentedControls.buttons["Моя команда"].tap()

        // Verify team data is loaded
        XCTAssertTrue(app.tables["teamReportsTable"].cells.count > 0)
    }

    func testStudentCannotSeeTeamAnalytics() {
        launchAndLogin(as: "student")

        // Navigate to analytics
        app.tabBars.buttons["Аналитика"].tap()

        // Verify "My Team" tab is NOT visible
        XCTAssertFalse(app.segmentedControls.buttons["Моя команда"].exists)
    }

    func testAccessingRestrictedCourse() {
        launchAndLogin(as: "student")

        // Navigate to courses
        app.tabBars.buttons["Курсы"].tap()

        // Find a course marked as "Только для руководителей"
        let restrictedCourse = app.collectionViews.cells.containing(.staticText, identifier: "Лидерство для руководителей").firstMatch
        restrictedCourse.tap()

        // Verify access denied message
        let alert = app.alerts["Доступ запрещен"]
        XCTAssertTrue(alert.waitForExistence(timeout: 3))
        XCTAssertTrue(alert.staticTexts["Этот курс доступен только для руководителей."].exists)
        alert.buttons["OK"].tap()
    }
}
