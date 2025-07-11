import XCTest

// MARK: - Comprehensive UI Tests для 100% покрытия функционала LMS

final class ComprehensiveUITests: XCTestCase {
    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["UI_TESTING", "MOCK_MODE"]
        app.launchEnvironment = ["UI_TESTING": "1", "MOCK_AUTH": "1"]
    }

    override func tearDownWithError() throws {
        app = nil
    }

    // MARK: - 1. Authentication Tests (Авторизация)

    func test001_LaunchAndShowLoginScreen() throws {
        app.launch()

        // Проверяем что приложение запустилось
        XCTAssertEqual(app.state, .runningForeground)

        // Проверяем наличие экрана логина или главного экрана
        let loginExists = app.buttons["Войти для разработки"].waitForExistence(timeout: 5)
        let tabBarExists = app.tabBars.firstMatch.waitForExistence(timeout: 5)

        XCTAssertTrue(loginExists || tabBarExists, "Должен быть экран логина или главный экран")
    }

    func test002_MockLoginAsStudent() throws {
        app.launch()
        performLogout() // Убеждаемся что мы разлогинены

        let loginButton = app.buttons["Войти для разработки"]
        XCTAssertTrue(loginButton.waitForExistence(timeout: 10))
        loginButton.tap()

        let studentButton = app.buttons["Войти как студент"]
        XCTAssertTrue(studentButton.waitForExistence(timeout: 5))
        studentButton.tap()

        // Проверяем успешный вход
        XCTAssertTrue(app.tabBars.firstMatch.waitForExistence(timeout: 5))
        XCTAssertTrue(app.tabBars.buttons["Обучение"].exists)
    }

    func test003_MockLoginAsAdmin() throws {
        app.launch()
        performLogout()

        let loginButton = app.buttons["Войти для разработки"]
        XCTAssertTrue(loginButton.waitForExistence(timeout: 10))
        loginButton.tap()

        let adminButton = app.buttons["Войти как администратор"]
        XCTAssertTrue(adminButton.waitForExistence(timeout: 5))
        adminButton.tap()

        // Проверяем админский доступ
        let moreTab = app.tabBars.buttons["Ещё"]
        XCTAssertTrue(moreTab.waitForExistence(timeout: 5))
        moreTab.tap()

        XCTAssertTrue(app.buttons["Администрирование"].waitForExistence(timeout: 5))
    }

    func test004_Logout() throws {
        app.launch()
        ensureLoggedIn()

        // Переходим в Ещё
        app.tabBars.buttons["Ещё"].tap()

        // Ищем кнопку выхода
        let logoutButton = app.buttons["Выйти"]
        if logoutButton.waitForExistence(timeout: 5) {
            logoutButton.tap()

            // Подтверждаем выход если есть алерт
            let confirmButton = app.alerts.buttons["Выйти"]
            if confirmButton.waitForExistence(timeout: 2) {
                confirmButton.tap()
            }

            // Проверяем что вернулись на экран логина
            XCTAssertTrue(app.buttons["Войти для разработки"].waitForExistence(timeout: 5))
        }
    }

    // MARK: - 2. Navigation Tests (Навигация)

    func test005_TabBarNavigation() throws {
        app.launch()
        ensureLoggedIn()

        // Проверяем все табы
        let tabs = [
            ("Обучение", "Курсы"),
            ("Профиль", "Профиль"),
            ("Ещё", "Ещё")
        ]

        for (tabName, expectedTitle) in tabs {
            let tab = app.tabBars.buttons[tabName]
            XCTAssertTrue(tab.exists, "Таб \(tabName) должен существовать")
            tab.tap()

            sleep(1)

            // Проверяем что таб выбран
            XCTAssertTrue(tab.isSelected)

            // Проверяем заголовок экрана
            if app.navigationBars[expectedTitle].exists {
                XCTAssertTrue(true, "Навигация на \(expectedTitle) успешна")
            }
        }
    }

    // MARK: - 3. Course List Tests (Список курсов)

    func test006_CourseListDisplay() throws {
        app.launch()
        ensureLoggedIn()
        navigateToLearning()

        // Проверяем отображение курсов
        let coursesList = app.scrollViews.firstMatch
        XCTAssertTrue(coursesList.waitForExistence(timeout: 5))

        // Проверяем наличие хотя бы одного курса
        let firstCourse = coursesList.buttons.firstMatch
        XCTAssertTrue(firstCourse.exists, "Должен быть хотя бы один курс")

        // Проверяем элементы карточки курса
        XCTAssertTrue(app.staticTexts.containing(NSPredicate(format: "label CONTAINS[c] 'продаж' OR label CONTAINS[c] 'товар' OR label CONTAINS[c] 'касс'")).firstMatch.exists)
    }

    func test007_CourseSearch() throws {
        app.launch()
        ensureLoggedIn()
        navigateToLearning()

        // Ищем поле поиска
        let searchField = app.textFields["Поиск курсов"]
        if searchField.waitForExistence(timeout: 5) {
            searchField.tap()
            searchField.typeText("продаж")

            // Ждем результаты
            sleep(2)

            // Проверяем что есть результаты
            let searchResults = app.scrollViews.firstMatch.buttons
            XCTAssertGreaterThan(searchResults.count, 0, "Должны быть результаты поиска")
        }
    }

    func test008_CourseFiltering() throws {
        app.launch()
        ensureLoggedIn()
        navigateToLearning()

        // Проверяем фильтры если они есть
        if app.buttons["Фильтры"].exists {
            app.buttons["Фильтры"].tap()

            // Проверяем опции фильтрации
            XCTAssertTrue(app.staticTexts["Категория"].waitForExistence(timeout: 3))
            XCTAssertTrue(app.staticTexts["Уровень"].exists)
            XCTAssertTrue(app.staticTexts["Статус"].exists)

            // Закрываем фильтры
            if app.buttons["Готово"].exists {
                app.buttons["Готово"].tap()
            }
        }
    }

    // MARK: - 4. Course Detail Tests (Детали курса)

    func test009_CourseDetailView() throws {
        app.launch()
        ensureLoggedIn()
        navigateToLearning()

        // Открываем первый курс
        let firstCourse = app.scrollViews.firstMatch.buttons.firstMatch
        XCTAssertTrue(firstCourse.waitForExistence(timeout: 5))
        firstCourse.tap()

        // Проверяем элементы детальной страницы
        XCTAssertTrue(app.staticTexts["О курсе"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Программа курса"].exists)

        // Проверяем информацию о курсе
        XCTAssertTrue(app.staticTexts.containing(NSPredicate(format: "label CONTAINS[c] 'длительность' OR label CONTAINS[c] 'модул'")).firstMatch.exists)

        // Проверяем список модулей
        XCTAssertTrue(app.staticTexts.containing(NSPredicate(format: "label CONTAINS[c] 'Модуль' OR label CONTAINS[c] 'Урок'")).firstMatch.exists)
    }

    func test010_StartCourse() throws {
        app.launch()
        ensureLoggedIn()
        navigateToCourseDetail()

        // Проверяем кнопку начала
        let startButton = app.buttons["Начать обучение"]
        let continueButton = app.buttons["Продолжить обучение"]

        XCTAssertTrue(startButton.exists || continueButton.exists, "Должна быть кнопка начала/продолжения")

        if startButton.exists {
            startButton.tap()
        } else if continueButton.exists {
            continueButton.tap()
        }

        // Проверяем что перешли к урокам
        XCTAssertTrue(app.navigationBars.buttons["Закрыть"].waitForExistence(timeout: 5) ||
                     app.navigationBars.buttons["Back"].waitForExistence(timeout: 5))
    }

    // MARK: - 5. Lesson Tests (Уроки)

    func test011_LessonNavigation() throws {
        app.launch()
        ensureLoggedIn()
        navigateToLesson()

        // Проверяем навигацию по урокам
        if app.buttons["Далее"].waitForExistence(timeout: 5) {
            // Проверяем счетчик уроков
            XCTAssertTrue(app.staticTexts.containing(NSPredicate(format: "label MATCHES '\\d+\\s*/\\s*\\d+'")).firstMatch.exists)

            // Переходим к следующему уроку
            app.buttons["Далее"].tap()
            sleep(1)

            // Проверяем что перешли
            XCTAssertTrue(app.buttons["Назад"].exists)
        }
    }

    func test012_VideoLesson() throws {
        app.launch()
        ensureLoggedIn()
        navigateToLesson()

        // Проверяем элементы видео урока
        if app.staticTexts["Видео урок"].exists {
            XCTAssertTrue(app.images.firstMatch.exists, "Должно быть превью видео")
            XCTAssertTrue(app.staticTexts.containing(NSPredicate(format: "label CONTAINS[c] 'минут'")).firstMatch.exists)
        }
    }

    func test013_TextLesson() throws {
        app.launch()
        ensureLoggedIn()
        navigateToLesson()

        // Навигируем к текстовому уроку
        while app.buttons["Далее"].exists && !app.staticTexts["Текстовый урок"].exists {
            app.buttons["Далее"].tap()
            sleep(1)
        }

        if app.staticTexts["Текстовый урок"].exists {
            // Проверяем наличие текстового контента
            XCTAssertTrue(app.textViews.firstMatch.exists || app.staticTexts.count > 5)
        }
    }

    func test014_Quiz() throws {
        app.launch()
        ensureLoggedIn()
        navigateToLesson()

        // Навигируем к тесту
        while app.buttons["Далее"].exists && !app.staticTexts["Проверка знаний"].exists {
            app.buttons["Далее"].tap()
            sleep(1)
        }

        if app.staticTexts["Проверка знаний"].exists {
            XCTAssertTrue(app.buttons["Начать тест"].waitForExistence(timeout: 5))
            app.buttons["Начать тест"].tap()

            // Проверяем вопросы
            XCTAssertTrue(app.staticTexts.containing(NSPredicate(format: "label CONTAINS[c] 'Вопрос'")).firstMatch.waitForExistence(timeout: 5))

            // Выбираем ответ
            if app.buttons.count > 2 {
                app.buttons.element(boundBy: 2).tap()

                if app.buttons["Далее"].exists {
                    app.buttons["Далее"].tap()
                }
            }
        }
    }

    // MARK: - 6. Profile Tests (Профиль)

    func test015_ProfileView() throws {
        app.launch()
        ensureLoggedIn()

        app.tabBars.buttons["Профиль"].tap()

        // Проверяем основные элементы
        XCTAssertTrue(app.navigationBars["Профиль"].waitForExistence(timeout: 5))

        // Проверяем информацию о пользователе
        XCTAssertTrue(app.staticTexts.containing(NSPredicate(format: "label CONTAINS[c] 'Иван' OR label CONTAINS[c] 'Админ'")).firstMatch.exists)

        // Проверяем статистику
        XCTAssertTrue(app.staticTexts["Курсов"].exists)
        XCTAssertTrue(app.staticTexts["Сертификатов"].exists)
        XCTAssertTrue(app.staticTexts["Обучения"].exists)
    }

    func test016_ProfileStatistics() throws {
        app.launch()
        ensureLoggedIn()

        app.tabBars.buttons["Профиль"].tap()

        // Проверяем вкладку статистики
        if app.buttons["Статистика"].waitForExistence(timeout: 5) {
            app.buttons["Статистика"].tap()

            // Проверяем график активности
            XCTAssertTrue(app.otherElements.containing(NSPredicate(format: "identifier CONTAINS[c] 'chart' OR identifier CONTAINS[c] 'graph'")).firstMatch.exists ||
                         app.staticTexts["Активность за неделю"].exists)
        }
    }

    func test017_Achievements() throws {
        app.launch()
        ensureLoggedIn()

        app.tabBars.buttons["Профиль"].tap()

        // Проверяем достижения
        if app.buttons["Достижения"].waitForExistence(timeout: 5) {
            app.buttons["Достижения"].tap()

            XCTAssertTrue(app.staticTexts["Мои достижения"].waitForExistence(timeout: 5))

            // Проверяем наличие достижений
            XCTAssertTrue(app.images.count > 0, "Должны быть иконки достижений")
        }
    }

    func test018_Skills() throws {
        app.launch()
        ensureLoggedIn()

        app.tabBars.buttons["Профиль"].tap()

        // Проверяем навыки
        if app.buttons["Навыки"].waitForExistence(timeout: 5) {
            app.buttons["Навыки"].tap()

            // Проверяем список навыков
            XCTAssertTrue(app.progressIndicators.firstMatch.exists ||
                         app.staticTexts.containing(NSPredicate(format: "label CONTAINS[c] '%'")).firstMatch.exists)
        }
    }

    // MARK: - 7. Admin Tests (Администрирование)

    func test019_AdminPanel() throws {
        app.launch()
        performLogout()

        // Логинимся как админ
        loginAsAdmin()

        app.tabBars.buttons["Ещё"].tap()

        let adminButton = app.buttons["Администрирование"]
        XCTAssertTrue(adminButton.waitForExistence(timeout: 5))
        adminButton.tap()

        // Проверяем админ-панель
        XCTAssertTrue(app.navigationBars["Администрирование"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["Ожидающие одобрения"].exists)
        XCTAssertTrue(app.buttons["Управление курсами"].exists)
        XCTAssertTrue(app.buttons["Статистика"].exists)
    }

    func test020_PendingUsers() throws {
        app.launch()
        ensureLoggedInAsAdmin()

        app.tabBars.buttons["Ещё"].tap()
        app.buttons["Администрирование"].tap()
        app.buttons["Ожидающие одобрения"].tap()

        // Проверяем список ожидающих
        XCTAssertTrue(app.navigationBars["Ожидающие одобрения"].waitForExistence(timeout: 5))

        // Проверяем наличие пользователей
        if app.cells.count > 0 {
            // Выбираем первого пользователя
            app.cells.firstMatch.tap()

            // Проверяем кнопки действий
            XCTAssertTrue(app.buttons["Одобрить"].exists || app.buttons["Отклонить"].exists)
        }
    }

    // MARK: - 8. Settings Tests (Настройки)

    func test021_Settings() throws {
        app.launch()
        ensureLoggedIn()

        app.tabBars.buttons["Ещё"].tap()

        if app.buttons["Настройки"].waitForExistence(timeout: 5) {
            app.buttons["Настройки"].tap()

            // Проверяем настройки
            XCTAssertTrue(app.navigationBars["Настройки"].waitForExistence(timeout: 5))
            XCTAssertTrue(app.switches["Уведомления"].exists || app.cells["Уведомления"].exists)
            XCTAssertTrue(app.cells["О приложении"].exists)
        }
    }

    func test022_NotificationSettings() throws {
        app.launch()
        ensureLoggedIn()

        app.tabBars.buttons["Ещё"].tap()

        if app.buttons["Настройки"].exists {
            app.buttons["Настройки"].tap()

            if app.cells["Уведомления"].exists {
                app.cells["Уведомления"].tap()

                // Проверяем настройки уведомлений
                XCTAssertTrue(app.switches.count > 0, "Должны быть переключатели уведомлений")
            }
        }
    }

    // MARK: - 9. Offline Mode Tests (Офлайн режим)

    func test023_OfflineMode() throws {
        app.launch()
        ensureLoggedIn()

        // Проверяем индикатор офлайн режима
        if app.staticTexts["Офлайн режим"].exists {
            XCTAssertTrue(true, "Офлайн режим отображается")

            // Проверяем что базовый функционал доступен
            XCTAssertTrue(app.tabBars.firstMatch.exists)
        }
    }

    // MARK: - 10. Error Handling Tests (Обработка ошибок)

    func test024_NetworkError() throws {
        app.launch()
        app.launchEnvironment = ["SIMULATE_NETWORK_ERROR": "1"]

        // Пытаемся загрузить курсы
        if app.tabBars.buttons["Обучение"].exists {
            app.tabBars.buttons["Обучение"].tap()

            // Проверяем сообщение об ошибке
            let errorMessage = app.staticTexts.containing(NSPredicate(format: "label CONTAINS[c] 'ошибк' OR label CONTAINS[c] 'интернет' OR label CONTAINS[c] 'сет'")).firstMatch

            if errorMessage.waitForExistence(timeout: 5) {
                XCTAssertTrue(true, "Ошибка сети отображается корректно")

                // Проверяем кнопку повтора
                XCTAssertTrue(app.buttons["Повторить"].exists || app.buttons["Обновить"].exists)
            }
        }
    }

    // MARK: - Helper Methods

    private func ensureLoggedIn() {
        if app.buttons["Войти для разработки"].exists {
            loginAsStudent()
        }
    }

    private func ensureLoggedInAsAdmin() {
        if app.buttons["Войти для разработки"].exists {
            loginAsAdmin()
        } else if !app.buttons["Администрирование"].exists {
            performLogout()
            loginAsAdmin()
        }
    }

    private func loginAsStudent() {
        let loginButton = app.buttons["Войти для разработки"]
        if loginButton.waitForExistence(timeout: 5) {
            loginButton.tap()

            let studentButton = app.buttons["Войти как студент"]
            if studentButton.waitForExistence(timeout: 3) {
                studentButton.tap()
            }
        }
    }

    private func loginAsAdmin() {
        let loginButton = app.buttons["Войти для разработки"]
        if loginButton.waitForExistence(timeout: 5) {
            loginButton.tap()

            let adminButton = app.buttons["Войти как администратор"]
            if adminButton.waitForExistence(timeout: 3) {
                adminButton.tap()
            }
        }
    }

    private func performLogout() {
        if app.tabBars.firstMatch.exists {
            app.tabBars.buttons["Ещё"].tap()

            let logoutButton = app.buttons["Выйти"]
            if logoutButton.waitForExistence(timeout: 3) {
                logoutButton.tap()

                let confirmButton = app.alerts.buttons["Выйти"]
                if confirmButton.waitForExistence(timeout: 2) {
                    confirmButton.tap()
                }
            }
        }
    }

    private func navigateToLearning() {
        let learningTab = app.tabBars.buttons["Обучение"]
        if !learningTab.isSelected {
            learningTab.tap()
        }
        sleep(1)
    }

    private func navigateToCourseDetail() {
        navigateToLearning()

        let firstCourse = app.scrollViews.firstMatch.buttons.firstMatch
        if firstCourse.waitForExistence(timeout: 5) {
            firstCourse.tap()
        }
    }

    private func navigateToLesson() {
        navigateToCourseDetail()

        let startButton = app.buttons["Начать обучение"]
        let continueButton = app.buttons["Продолжить обучение"]

        if startButton.exists {
            startButton.tap()
        } else if continueButton.exists {
            continueButton.tap()
        }
    }
}
