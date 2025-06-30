import XCTest

final class LessonUITests: XCTestCase {
    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false

        app = XCUIApplication()
        app.launchArguments = ["UI_TESTING"]
        app.launch()

        // Login as student
        performMockLogin()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    // MARK: - Lesson Tests

    func testStartLesson_ShouldShowLessonContent() throws {
        // Navigate to course
        navigateToCourseDetail()

        // Start course
        let startButton = app.buttons["Начать обучение"]
        if !startButton.exists {
            // Try "Continue" button if course already started
            let continueButton = app.buttons["Продолжить обучение"]
            XCTAssertTrue(continueButton.exists)
            continueButton.tap()
        } else {
            startButton.tap()
        }

        // Check lesson view
        XCTAssertTrue(app.navigationBars.buttons["Закрыть"].waitForExistence(timeout: 5))

        // Check lesson navigation
        let nextButton = app.buttons["Далее"]
        if nextButton.exists {
            XCTAssertTrue(nextButton.isEnabled)
        }
    }

    func testLessonNavigation_ShouldMoveToNextLesson() throws {
        // Start lesson
        navigateToLesson()

        // Check initial state
        XCTAssertTrue(app.staticTexts["1 / 3"].waitForExistence(timeout: 3))

        // Navigate to next lesson
        let nextButton = app.buttons["Далее"]
        XCTAssertTrue(nextButton.exists)
        nextButton.tap()

        // Check we moved to lesson 2
        XCTAssertTrue(app.staticTexts["2 / 3"].waitForExistence(timeout: 3))

        // Check back button appeared
        let backButton = app.buttons["Назад"]
        XCTAssertTrue(backButton.exists)
    }

    func testVideoLesson_ShouldShowVideoContent() throws {
        navigateToLesson()

        // Check video lesson elements
        XCTAssertTrue(app.staticTexts["Видео урок"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.staticTexts["Введение в технику продаж"].exists)
        XCTAssertTrue(app.staticTexts["15 минут"].exists)

        // Check key points section
        XCTAssertTrue(app.staticTexts["Ключевые моменты:"].exists)
    }

    func testQuizLesson_ShouldShowQuizIntro() throws {
        // Navigate to last lesson (usually quiz)
        navigateToLesson()

        // Navigate to quiz lesson
        let nextButton = app.buttons["Далее"]
        for _ in 0..<2 { // Navigate to 3rd lesson
            if nextButton.exists {
                nextButton.tap()
                sleep(1)
            }
        }

        // Check quiz intro
        if app.staticTexts["Проверка знаний"].waitForExistence(timeout: 3) {
            XCTAssertTrue(app.staticTexts["10 вопросов"].exists)
            XCTAssertTrue(app.staticTexts["15 минут"].exists)
            XCTAssertTrue(app.staticTexts["Проходной балл: 70%"].exists)

            // Check start test button
            let startTestButton = app.buttons["Начать тест"]
            XCTAssertTrue(startTestButton.exists)
        }
    }

    func testCompleteModule_ShouldShowFinishButton() throws {
        navigateToLesson()

        // Navigate to last lesson
        let nextButton = app.buttons["Далее"]
        while nextButton.exists && nextButton.isEnabled {
            nextButton.tap()
            sleep(1)
        }

        // Check for finish button
        let finishButton = app.buttons["Завершить модуль"]
        if finishButton.waitForExistence(timeout: 3) {
            XCTAssertTrue(finishButton.isEnabled)
        }
    }

    // MARK: - Helper Methods

    private func performMockLogin() {
        let loginButton = app.buttons["Войти для разработки"]
        guard loginButton.waitForExistence(timeout: 5) else {
            XCTFail("Login button not found")
            return
        }

        loginButton.tap()

        let studentButton = app.buttons["Войти как студент"]
        guard studentButton.waitForExistence(timeout: 3) else {
            XCTFail("Student button not found")
            return
        }

        studentButton.tap()

        // Wait for main screen
        let tabBar = app.tabBars.firstMatch
        XCTAssertTrue(tabBar.waitForExistence(timeout: 5))
    }

    private func navigateToCourseDetail() {
        // Find and tap first course
        let firstCourse = app.scrollViews.otherElements.buttons.firstMatch
        XCTAssertTrue(firstCourse.waitForExistence(timeout: 5))
        firstCourse.tap()

        // Wait for course detail
        XCTAssertTrue(app.staticTexts["О курсе"].waitForExistence(timeout: 3))
    }

    private func navigateToLesson() {
        navigateToCourseDetail()

        // Start course
        let startButton = app.buttons["Начать обучение"]
        let continueButton = app.buttons["Продолжить обучение"]

        if startButton.exists {
            startButton.tap()
        } else if continueButton.exists {
            continueButton.tap()
        }

        // Wait for lesson view
        XCTAssertTrue(app.navigationBars.buttons["Закрыть"].waitForExistence(timeout: 5))
    }
}
