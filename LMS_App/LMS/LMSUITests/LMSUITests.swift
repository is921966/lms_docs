//
//  LMSUITests.swift
//  LMSUITests
//
//  Created by Igor Shirokov on 24.06.2025.
//

import XCTest

final class LMSUITests: XCTestCase {
    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false

        app = XCUIApplication()
        app.launchArguments = ["UI_TESTING"]
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    // MARK: - Login Tests

    func testMockLogin_AsStudent_ShouldSucceed() throws {
        // Given
        let loginButton = app.buttons["Войти для разработки"]
        XCTAssertTrue(loginButton.waitForExistence(timeout: 5))

        // When
        loginButton.tap()

        let studentButton = app.buttons["Войти как студент"]
        XCTAssertTrue(studentButton.waitForExistence(timeout: 3))
        studentButton.tap()

        // Then
        let learningTab = app.tabBars.buttons["Обучение"]
        XCTAssertTrue(learningTab.waitForExistence(timeout: 5))
        XCTAssertTrue(learningTab.isSelected)
    }

    func testMockLogin_AsAdmin_ShouldShowAdminFeatures() throws {
        // Given
        let loginButton = app.buttons["Войти для разработки"]
        XCTAssertTrue(loginButton.waitForExistence(timeout: 5))
        loginButton.tap()

        // When
        let adminButton = app.buttons["Войти как администратор"]
        XCTAssertTrue(adminButton.waitForExistence(timeout: 3))
        adminButton.tap()

        // Then
        let moreTab = app.tabBars.buttons["Ещё"]
        XCTAssertTrue(moreTab.waitForExistence(timeout: 5))
        moreTab.tap()

        let adminMenuItem = app.buttons["Администрирование"]
        XCTAssertTrue(adminMenuItem.exists)
    }

    // MARK: - Navigation Tests

    func testTabBarNavigation_ShouldSwitchBetweenTabs() throws {
        // Login first
        performMockLogin(asAdmin: false)

        // Test Learning tab
        let learningTab = app.tabBars.buttons["Обучение"]
        XCTAssertTrue(learningTab.isSelected)

        // Test Profile tab
        let profileTab = app.tabBars.buttons["Профиль"]
        profileTab.tap()
        XCTAssertTrue(profileTab.isSelected)
        XCTAssertTrue(app.navigationBars["Профиль"].exists)

        // Test More tab
        let moreTab = app.tabBars.buttons["Ещё"]
        moreTab.tap()
        XCTAssertTrue(moreTab.isSelected)
        XCTAssertTrue(app.navigationBars["Ещё"].exists)
    }

    // MARK: - Course List Tests

    func testCourseList_ShouldDisplayCourses() throws {
        performMockLogin(asAdmin: false)

        // Check if courses are displayed
        let firstCourse = app.scrollViews.otherElements.buttons.firstMatch
        XCTAssertTrue(firstCourse.waitForExistence(timeout: 5))

        // Check search functionality
        let searchField = app.textFields["Поиск курсов"]
        XCTAssertTrue(searchField.exists)

        searchField.tap()
        searchField.typeText("продаж")

        // Should show filtered results
        let salesCourse = app.staticTexts["Основы продаж в ЦУМ"]
        XCTAssertTrue(salesCourse.waitForExistence(timeout: 3))
    }

    func testCourseDetail_ShouldShowModules() throws {
        performMockLogin(asAdmin: false)

        // Navigate to course
        let firstCourse = app.scrollViews.otherElements.buttons.firstMatch
        XCTAssertTrue(firstCourse.waitForExistence(timeout: 5))
        firstCourse.tap()

        // Check course detail elements
        XCTAssertTrue(app.staticTexts["О курсе"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.staticTexts["Программа курса"].exists)

        // Check if modules are displayed
        XCTAssertTrue(app.staticTexts["Введение в продажи"].exists)

        // Check start button
        let startButton = app.buttons["Начать обучение"]
        XCTAssertTrue(startButton.exists || app.buttons["Продолжить обучение"].exists)
    }

    // MARK: - Profile Tests

    func testProfile_ShouldDisplayUserInfo() throws {
        performMockLogin(asAdmin: false)

        // Navigate to profile
        let profileTab = app.tabBars.buttons["Профиль"]
        profileTab.tap()

        // Check user info
        XCTAssertTrue(app.staticTexts["Иван Иванов"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.staticTexts["Продавец-консультант"].exists)

        // Check stats
        XCTAssertTrue(app.staticTexts["Курсов"].exists)
        XCTAssertTrue(app.staticTexts["Сертификатов"].exists)
        XCTAssertTrue(app.staticTexts["Обучения"].exists)

        // Check tabs
        let achievementsTab = app.buttons["Достижения"]
        XCTAssertTrue(achievementsTab.exists)
        achievementsTab.tap()

        XCTAssertTrue(app.staticTexts["Мои достижения"].waitForExistence(timeout: 3))
    }

    // MARK: - Admin Tests

    func testAdminPanel_ShouldShowPendingUsers() throws {
        performMockLogin(asAdmin: true)

        // Navigate to admin panel
        let moreTab = app.tabBars.buttons["Ещё"]
        moreTab.tap()

        let adminButton = app.buttons["Администрирование"]
        XCTAssertTrue(adminButton.waitForExistence(timeout: 3))
        adminButton.tap()

        let pendingUsersButton = app.buttons["Ожидающие одобрения"]
        XCTAssertTrue(pendingUsersButton.waitForExistence(timeout: 3))
        pendingUsersButton.tap()

        // Check pending users list
        XCTAssertTrue(app.navigationBars["Ожидающие одобрения"].exists)

        // Test approve action
        let approveButton = app.buttons["Одобрить"].firstMatch
        if approveButton.exists {
            approveButton.tap()

            // Check confirmation
            let confirmButton = app.alerts.buttons["Одобрить"]
            if confirmButton.waitForExistence(timeout: 2) {
                confirmButton.tap()
            }
        }
    }

    // MARK: - Helper Methods

    private func performMockLogin(asAdmin: Bool) {
        let loginButton = app.buttons["Войти для разработки"]
        guard loginButton.waitForExistence(timeout: 5) else {
            XCTFail("Login button not found")
            return
        }

        loginButton.tap()

        let roleButton = app.buttons[asAdmin ? "Войти как администратор" : "Войти как студент"]
        guard roleButton.waitForExistence(timeout: 3) else {
            XCTFail("Role button not found")
            return
        }

        roleButton.tap()

        // Wait for main screen
        let tabBar = app.tabBars.firstMatch
        XCTAssertTrue(tabBar.waitForExistence(timeout: 5), "Tab bar should appear after login")
    }
}
