import XCTest

final class FullLoginFlowTest: XCTestCase {
    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchEnvironment = ["UITEST_MODE": "1"]
    }

    override func tearDownWithError() throws {
        app = nil
    }

    func testFullLoginFlow() throws {
        // Запускаем приложение
        app.launch()

        // Проверяем начальный экран
        XCTAssertTrue(app.staticTexts["TSUM LMS"].exists, "Заголовок TSUM LMS должен отображаться")
        XCTAssertTrue(app.staticTexts["Корпоративный университет"].exists, "Подзаголовок должен отображаться")

        // Проверяем кнопку входа
        let loginButton = app.buttons.containing(NSPredicate(format: "label CONTAINS 'Войти'")).firstMatch
        XCTAssertTrue(loginButton.exists, "Кнопка входа должна существовать")
        XCTAssertTrue(loginButton.isEnabled, "Кнопка входа должна быть активна")

        // Нажимаем кнопку входа
        loginButton.tap()

        // Ждём появления модального окна
        let mockLoginView = app.otherElements["MockLoginView"]
        let exists = mockLoginView.waitForExistence(timeout: 5)

        if !exists {
            // Если нет идентификатора, ищем по элементам
            let studentButton = app.buttons["loginAsStudent"]
            let adminButton = app.buttons["loginAsAdmin"]

            if studentButton.exists {
                // Входим как студент
                studentButton.tap()

                // Ждём загрузки
                Thread.sleep(forTimeInterval: 2)

                // Проверяем, что мы на экране ожидания одобрения или на главном экране
                let pendingApprovalTitle = app.staticTexts["Ожидание одобрения"]
                let mainTabBar = app.tabBars.firstMatch

                XCTAssertTrue(pendingApprovalTitle.exists || mainTabBar.exists,
                             "Должен отображаться экран ожидания или главный экран")

                if pendingApprovalTitle.exists {
                    // Проверяем элементы экрана ожидания
                    XCTAssertTrue(app.staticTexts["Ваша учетная запись создана"].exists)

                    // Нажимаем кнопку самоодобрения (для тестов)
                    let approveButton = app.buttons.containing(NSPredicate(format: "label CONTAINS 'Одобрить себя'")).firstMatch
                    if approveButton.exists {
                        approveButton.tap()
                        Thread.sleep(forTimeInterval: 1.5)
                    }
                }

                // Проверяем главный экран
                let tabBar = app.tabBars.firstMatch
                XCTAssertTrue(tabBar.waitForExistence(timeout: 5), "TabBar должен появиться")

                // Проверяем вкладки
                XCTAssertTrue(app.tabBars.buttons["Обучение"].exists, "Вкладка Обучение должна существовать")
                XCTAssertTrue(app.tabBars.buttons["Профиль"].exists, "Вкладка Профиль должна существовать")
                XCTAssertTrue(app.tabBars.buttons["Ещё"].exists, "Вкладка Ещё должна существовать")
            } else if adminButton.exists {
                // Альтернативный вход как администратор
                adminButton.tap()

                // Ждём загрузки
                Thread.sleep(forTimeInterval: 2)

                // Проверяем главный экран
                let tabBar = app.tabBars.firstMatch
                XCTAssertTrue(tabBar.waitForExistence(timeout: 5), "TabBar должен появиться для админа")
            } else {
                XCTFail("Не найдены кнопки входа в модальном окне")
            }
        }
    }

    func testLoginAndLogout() throws {
        // Запускаем приложение
        app.launch()

        // Входим в систему
        let loginButton = app.buttons.containing(NSPredicate(format: "label CONTAINS 'Войти'")).firstMatch
        loginButton.tap()

        // Входим как администратор (автоматическое одобрение)
        let adminButton = app.buttons["loginAsAdmin"]
        if adminButton.waitForExistence(timeout: 3) {
            adminButton.tap()

            // Ждём появления главного экрана
            let tabBar = app.tabBars.firstMatch
            XCTAssertTrue(tabBar.waitForExistence(timeout: 5), "Должен появиться главный экран")

            // Переходим на вкладку профиля
            app.tabBars.buttons["Профиль"].tap()

            // Ищем кнопку выхода
            let logoutButton = app.buttons["Выйти"]
            if logoutButton.waitForExistence(timeout: 3) {
                logoutButton.tap()

                // Проверяем, что вернулись на экран входа
                XCTAssertTrue(app.staticTexts["TSUM LMS"].waitForExistence(timeout: 3),
                             "Должен отобразиться начальный экран после выхода")
            }
        }
    }
}
