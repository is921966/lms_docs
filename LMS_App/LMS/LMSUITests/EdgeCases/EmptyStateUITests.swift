//
//  EmptyStateUITests.swift
//  LMSUITests
//
//  Created by Igor Shirokov on 27.06.2025.
//

import XCTest

final class EmptyStateUITests: XCTestCase {
    private var app: XCUIApplication!

    // MARK: - Setup

    private func launchAndLogin() {
        app = XCUIApplication()
        // Special launch argument to tell the mock service to return empty lists
        app.launchArguments = ["UI_TESTING", "EMPTY_STATE_MODE"]
        app.launch()

        let emailField = app.textFields["emailTextField"]
        let passwordField = app.secureTextFields["passwordSecureField"]
        let loginButton = app.buttons["loginButton"]

        emailField.tap()
        emailField.typeText("empty.user@lms.ru")

        passwordField.tap()
        passwordField.typeText("Test123!")

        loginButton.tap()

        _ = app.navigationBars["Главная"].waitForExistence(timeout: 5)
    }

    override func setUpWithError() throws {
        continueAfterFailure = false
        launchAndLogin()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    // MARK: - Test Cases

    func testEmptyCourseListState() {
        app.tabBars.buttons["Курсы"].tap()

        // Verify empty state view is shown
        let emptyStateView = app.otherElements["emptyStateView_courses"]
        XCTAssertTrue(emptyStateView.waitForExistence(timeout: 3))
        XCTAssertTrue(emptyStateView.staticTexts["Курсов пока нет"].exists)
        XCTAssertTrue(emptyStateView.staticTexts["Как только появятся новые курсы, они будут отображены здесь."].exists)
    }

    func testEmptyNotificationsState() {
        app.tabBars.buttons["Уведомления"].tap()

        // Verify empty state view for notifications
        let emptyStateView = app.otherElements["emptyStateView_notifications"]
        XCTAssertTrue(emptyStateView.waitForExistence(timeout: 3))
        XCTAssertTrue(emptyStateView.staticTexts["Уведомлений нет"].exists)
        XCTAssertTrue(emptyStateView.images["bell.slash.fill"].exists)
    }

    func testEmptySearchResultsState() {
        let searchBar = app.navigationBars["Главная"].searchFields["Поиск..."]
        searchBar.tap()

        // Search for something that doesn't exist
        searchBar.typeText("NonExistentQueryAbc123")

        // Verify empty search results view
        let emptyStateView = app.otherElements["emptyStateView_search"]
        XCTAssertTrue(emptyStateView.waitForExistence(timeout: 3))
        XCTAssertTrue(emptyStateView.staticTexts["Ничего не найдено"].exists)
        XCTAssertTrue(emptyStateView.staticTexts["Попробуйте изменить ваш запрос"].exists)
    }

    func testEmptyCertificatesState() {
        app.tabBars.buttons["Профиль"].tap()
        app.buttons["Мои сертификаты"].tap()

        // Verify empty state for certificates
        _ = app.navigationBars["Сертификаты"].waitForExistence(timeout: 3)
        let emptyStateView = app.otherElements["emptyStateView_certificates"]
        XCTAssertTrue(emptyStateView.waitForExistence(timeout: 3))
        XCTAssertTrue(emptyStateView.staticTexts["У вас пока нет сертификатов"].exists)
    }
}
