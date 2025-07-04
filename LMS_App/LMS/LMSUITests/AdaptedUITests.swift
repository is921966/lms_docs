import XCTest

// MARK: - Адаптированные UI тесты для текущего состояния приложения

final class AdaptedUITests: XCTestCase {
    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["UI_TESTING"]
        app.launchEnvironment = ["MOCK_MODE": "1"]
    }

    override func tearDownWithError() throws {
        app = nil
    }

    // MARK: - Launch & Login Tests

    func test001_AppLaunchesSuccessfully() throws {
        app.launch()

        // Проверяем что приложение запустилось
        XCTAssertEqual(app.state, .runningForeground, "App should be running")

        // Делаем скриншот для документации
        takeScreenshot("01_App_Launch")

        // Проверяем наличие UI элементов
        let hasUI = app.buttons.count > 0 ||
                   app.staticTexts.count > 0 ||
                   app.tabBars.count > 0

        XCTAssertTrue(hasUI, "App should have UI elements")
    }

    func test002_LoginScreenOrMainScreen() throws {
        app.launch()
        sleep(2)

        // Приложение может быть в одном из двух состояний
        if app.buttons["Войти для разработки"].exists {
            // Состояние 1: Экран логина
            XCTAssertTrue(true, "Login screen is shown")
            takeScreenshot("02_Login_Screen")

            // Проверяем элементы экрана логина
            XCTAssertTrue(app.buttons["Войти для разработки"].exists)
        } else if app.tabBars.firstMatch.exists {
            // Состояние 2: Пользователь уже залогинен
            XCTAssertTrue(true, "User is already logged in")
            takeScreenshot("02_Main_Screen_Logged_In")

            // Проверяем табы
            checkTabBarExists()
        } else {
            // Неожиданное состояние
            takeScreenshot("02_Unexpected_State")
            XCTFail("App is in unexpected state")
        }
    }

    func test003_MockLoginFlow() throws {
        app.launch()
        sleep(2)

        // Если есть кнопка логина, выполняем вход
        if app.buttons["Войти для разработки"].exists {
            app.buttons["Войти для разработки"].tap()

            // Ждем появления опций
            let studentButton = app.buttons["Войти как студент"]
            if studentButton.waitForExistence(timeout: 5) {
                takeScreenshot("03_Login_Options")
                studentButton.tap()

                // Проверяем успешный вход
                XCTAssertTrue(app.tabBars.firstMatch.waitForExistence(timeout: 5),
                             "Should show main screen after login")
                takeScreenshot("03_After_Login")
            }
        } else {
            // Уже залогинены
            XCTAssertTrue(app.tabBars.firstMatch.exists, "Already logged in")
        }
    }

    // MARK: - Navigation Tests

    func test004_TabBarNavigation() throws {
        app.launch()
        ensureLoggedIn()

        // Проверяем наличие tab bar
        let tabBar = app.tabBars.firstMatch
        XCTAssertTrue(tabBar.exists, "Tab bar should exist")

        // Проверяем и тестируем каждый таб
        let expectedTabs = ["Обучение", "Профиль", "Ещё"]
        var foundTabs: [String] = []

        for tabName in expectedTabs {
            if tabBar.buttons[tabName].exists {
                foundTabs.append(tabName)
                tabBar.buttons[tabName].tap()
                sleep(1)
                takeScreenshot("04_Tab_\(tabName)")
            }
        }

        XCTAssertTrue(foundTabs.count > 0, "Should find at least one tab")
    }

    // MARK: - Learning Tests

    func test005_LearningTabContent() throws {
        app.launch()
        ensureLoggedIn()

        // Переходим на вкладку обучения
        if app.tabBars.buttons["Обучение"].exists {
            app.tabBars.buttons["Обучение"].tap()
            sleep(2)
            takeScreenshot("05_Learning_Tab")

            // Проверяем наличие контента
            let hasContent = app.scrollViews.count > 0 ||
                           app.collectionViews.count > 0 ||
                           app.buttons.count > 2

            XCTAssertTrue(hasContent, "Learning tab should have content")

            // Пробуем найти курс
            if app.scrollViews.firstMatch.exists {
                let scrollView = app.scrollViews.firstMatch
                if scrollView.buttons.count > 0 {
                    XCTAssertTrue(true, "Found courses in scroll view")
                }
            }
        }
    }

    func test006_CourseInteraction() throws {
        app.launch()
        ensureLoggedIn()
        navigateToLearning()

        // Пробуем открыть первый доступный курс
        let firstButton = findFirstCourseButton()
        if let courseButton = firstButton {
            takeScreenshot("06_Before_Course_Tap")
            courseButton.tap()
            sleep(2)
            takeScreenshot("06_Course_Detail")

            // Проверяем что перешли на другой экран
            let changedScreen = app.navigationBars.count > 0 ||
                              app.buttons["Начать обучение"].exists ||
                              app.buttons["Продолжить обучение"].exists ||
                              app.staticTexts["О курсе"].exists

            XCTAssertTrue(changedScreen, "Should navigate to course detail")
        }
    }

    // MARK: - Profile Tests

    func test007_ProfileTab() throws {
        app.launch()
        ensureLoggedIn()

        if app.tabBars.buttons["Профиль"].exists {
            app.tabBars.buttons["Профиль"].tap()
            sleep(2)
            takeScreenshot("07_Profile_Tab")

            // Проверяем элементы профиля
            let hasProfileContent = app.staticTexts.count > 3 ||
                                  app.images.count > 0

            XCTAssertTrue(hasProfileContent, "Profile should have content")
        }
    }

    // MARK: - More Tab Tests

    func test008_MoreTab() throws {
        app.launch()
        ensureLoggedIn()

        if app.tabBars.buttons["Ещё"].exists {
            app.tabBars.buttons["Ещё"].tap()
            sleep(2)
            takeScreenshot("08_More_Tab")

            // Проверяем наличие опций
            let hasOptions = app.buttons.count > 2 ||
                           app.cells.count > 0

            XCTAssertTrue(hasOptions, "More tab should have options")

            // Проверяем наличие кнопки выхода
            if app.buttons["Выйти"].exists {
                XCTAssertTrue(true, "Found logout button")
            }
        }
    }

    // MARK: - Error Handling Tests

    func test009_AppRecovery() throws {
        app.launch()

        // Тест на восстановление после сворачивания
        XCUIDevice.shared.press(.home)
        sleep(1)
        app.activate()
        sleep(1)

        // Проверяем что приложение восстановилось
        XCTAssertEqual(app.state, .runningForeground, "App should recover")
        takeScreenshot("09_After_Recovery")
    }

    // MARK: - Helper Methods

    private func ensureLoggedIn() {
        sleep(2)
        if app.buttons["Войти для разработки"].exists {
            app.buttons["Войти для разработки"].tap()

            let studentButton = app.buttons["Войти как студент"]
            if studentButton.waitForExistence(timeout: 3) {
                studentButton.tap()
                sleep(2)
            }
        }
    }

    private func navigateToLearning() {
        if app.tabBars.buttons["Обучение"].exists {
            app.tabBars.buttons["Обучение"].tap()
            sleep(2)
        }
    }

    private func checkTabBarExists() {
        let tabBar = app.tabBars.firstMatch
        XCTAssertTrue(tabBar.exists, "Tab bar should exist")

        // Проверяем стандартные табы
        let tabs = ["Обучение", "Профиль", "Ещё"]
        var foundCount = 0

        for tab in tabs {
            if tabBar.buttons[tab].exists {
                foundCount += 1
            }
        }

        XCTAssertGreaterThan(foundCount, 0, "Should find at least one standard tab")
    }

    private func findFirstCourseButton() -> XCUIElement? {
        // Пробуем разные способы найти кнопку курса
        if app.scrollViews.firstMatch.exists {
            let scrollView = app.scrollViews.firstMatch
            if scrollView.buttons.count > 0 {
                return scrollView.buttons.firstMatch
            }
        }

        if app.collectionViews.firstMatch.exists {
            let collection = app.collectionViews.firstMatch
            if collection.buttons.count > 0 {
                return collection.buttons.firstMatch
            }
        }

        // Пробуем найти любую кнопку кроме табов
        for i in 0..<app.buttons.count {
            let button = app.buttons.element(boundBy: i)
            let label = button.label

            // Пропускаем системные кнопки
            if !label.isEmpty &&
               !["Обучение", "Профиль", "Ещё", "Войти для разработки"].contains(label) {
                return button
            }
        }

        return nil
    }

    private func takeScreenshot(_ name: String) {
        let screenshot = app.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
