import XCTest

final class ModulesIntegrationE2ETests: XCTestCase {
    
    let app = XCUIApplication()
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launch()
        
        // Логинимся
        if app.buttons["Войти"].exists {
            app.buttons["Войти"].tap()
        }
    }
    
    override func tearDownWithError() throws {
        app.terminate()
    }
    
    // MARK: - Feed + Course Integration
    
    func testFeedCourseIntegration() throws {
        // 1. Создаем курс
        app.tabBars.buttons["Ещё"].tap()
        app.buttons["Панель администратора"].tap()
        app.buttons["Управление курсами"].tap()
        app.navigationBars.buttons["Добавить"].tap()
        
        let titleField = app.textFields["course-title-field"]
        titleField.tap()
        titleField.typeText("Новый курс для Feed")
        
        app.buttons["Сохранить"].tap()
        
        // 2. Возвращаемся к Feed
        app.navigationBars.buttons.element(boundBy: 0).tap()
        app.navigationBars.buttons.element(boundBy: 0).tap()
        app.navigationBars.buttons.element(boundBy: 0).tap()
        
        app.tabBars.buttons["Лента"].tap()
        
        // 3. Проверяем, что появился пост о новом курсе
        let feedPost = app.cells.containing(.staticText, identifier: "Добавлен новый курс").element
        XCTAssertTrue(feedPost.waitForExistence(timeout: 5))
        
        // 4. Проверяем содержимое поста
        feedPost.tap()
        XCTAssertTrue(app.staticTexts["Новый курс для Feed"].exists)
        XCTAssertTrue(app.buttons["Перейти к курсу"].exists)
        
        // 5. Переходим к курсу из поста
        app.buttons["Перейти к курсу"].tap()
        
        // Проверяем, что открылся правильный курс
        XCTAssertTrue(app.navigationBars["Новый курс для Feed"].exists)
    }
    
    // MARK: - Notifications + Course Integration
    
    func testNotificationsCourseIntegration() throws {
        // 1. Назначаем курс пользователю
        app.tabBars.buttons["Ещё"].tap()
        app.buttons["Панель администратора"].tap()
        app.buttons["Управление курсами"].tap()
        
        app.cells.firstMatch.tap()
        app.buttons["Назначить пользователям"].tap()
        app.cells.firstMatch.tap()
        app.buttons["Назначить выбранным"].tap()
        app.alerts.buttons["Назначить"].tap()
        
        // 2. Переключаемся на пользователя
        app.navigationBars.buttons["Готово"].tap()
        app.navigationBars.buttons.element(boundBy: 0).tap()
        app.navigationBars.buttons.element(boundBy: 0).tap()
        
        app.buttons["Настройки"].tap()
        app.buttons["Выйти"].tap()
        app.alerts.buttons["Выйти"].tap()
        
        app.buttons["Сменить пользователя"].tap()
        app.buttons["Студент Тестовый"].tap()
        
        // 3. Проверяем уведомление
        app.tabBars.buttons["Уведомления"].tap()
        
        let notification = app.cells.containing(.staticText, identifier: "Вам назначен новый курс").element
        XCTAssertTrue(notification.exists)
        
        // 4. Открываем уведомление
        notification.tap()
        
        // 5. Проверяем, что можем перейти к курсу
        XCTAssertTrue(app.buttons["Перейти к курсу"].exists)
        app.buttons["Перейти к курсу"].tap()
        
        // Проверяем, что открылся курс
        XCTAssertTrue(app.buttons["Начать курс"].exists)
    }
    
    // MARK: - User Management + Course Integration
    
    func testUserManagementCourseIntegration() throws {
        // 1. Переходим к управлению пользователями
        app.tabBars.buttons["Ещё"].tap()
        app.buttons["Панель администратора"].tap()
        app.buttons["Управление пользователями"].tap()
        
        // 2. Выбираем пользователя
        app.cells.firstMatch.tap()
        
        // 3. Проверяем вкладку с курсами
        app.buttons["Курсы"].tap()
        
        // Проверяем список назначенных курсов
        XCTAssertTrue(app.staticTexts["Назначенные курсы"].exists)
        
        // 4. Назначаем новый курс прямо из профиля
        app.buttons["Назначить курс"].tap()
        
        // Выбираем курс
        app.cells.containing(.staticText, identifier: "Python для начинающих").element.tap()
        app.buttons["Назначить"].tap()
        
        // Проверяем, что курс появился в списке
        XCTAssertTrue(app.cells.containing(.staticText, identifier: "Python для начинающих").element.exists)
        
        // 5. Проверяем прогресс пользователя
        app.cells.containing(.staticText, identifier: "Python для начинающих").element.tap()
        
        XCTAssertTrue(app.staticTexts["Прогресс: 0%"].exists)
        XCTAssertTrue(app.staticTexts["Статус: Не начат"].exists)
    }
    
    // MARK: - Cmi5 + Feed Integration
    
    func testCmi5FeedIntegration() throws {
        // 1. Импортируем Cmi5 пакет
        app.tabBars.buttons["Ещё"].tap()
        app.buttons["Cmi5 Контент"].tap()
        
        // Проверяем, что есть пакеты
        let hasPackages = app.cells.count > 0
        
        if !hasPackages {
            // Если нет пакетов, пропускаем тест
            XCTSkip("No Cmi5 packages available for testing")
        }
        
        // 2. Начинаем прохождение пакета
        app.cells.firstMatch.tap()
        app.buttons["Начать курс"].tap()
        
        // Проходим первую активность
        app.cells.firstMatch.tap()
        sleep(2)
        app.buttons["Далее"].tap()
        
        // 3. Возвращаемся к Feed
        app.navigationBars.buttons["Закрыть"].tap()
        app.navigationBars.buttons.element(boundBy: 0).tap()
        app.tabBars.buttons["Лента"].tap()
        
        // 4. Проверяем, что появился пост о прогрессе
        let progressPost = app.cells.containing(.staticText, identifier: "прогресс в курсе").element
        XCTAssertTrue(progressPost.waitForExistence(timeout: 5))
        
        // 5. Проверяем реакции на пост
        progressPost.swipeUp() // Скроллим к кнопкам
        
        // Ставим лайк
        app.buttons["like-button"].firstMatch.tap()
        
        // Проверяем, что счетчик увеличился
        XCTAssertTrue(app.staticTexts["1"].exists)
    }
    
    // MARK: - Complete Integration Flow
    
    func testCompleteIntegrationFlow() throws {
        // Этот тест проверяет полный цикл работы с несколькими модулями
        
        // 1. Админ создает курс с Cmi5 контентом
        app.tabBars.buttons["Ещё"].tap()
        app.buttons["Панель администратора"].tap()
        app.buttons["Управление курсами"].tap()
        app.navigationBars.buttons["Добавить"].tap()
        
        let titleField = app.textFields["course-title-field"]
        titleField.tap()
        titleField.typeText("Интеграционный курс")
        
        // Добавляем Cmi5 контент к курсу
        app.buttons["Добавить Cmi5 контент"].tap()
        app.cells.containing(.staticText, identifier: "AI Fluency").element.tap()
        app.buttons["Добавить"].tap()
        
        app.buttons["Сохранить"].tap()
        
        // 2. Назначаем курс группе пользователей
        app.cells.containing(.staticText, identifier: "Интеграционный курс").element.tap()
        app.buttons["Назначить пользователям"].tap()
        app.buttons["Все сотрудники IT"].tap()
        app.buttons["Назначить"].tap()
        app.alerts.buttons["Назначить"].tap()
        
        // 3. Проверяем Feed
        app.navigationBars.buttons["Готово"].tap()
        app.navigationBars.buttons.element(boundBy: 0).tap()
        app.navigationBars.buttons.element(boundBy: 0).tap()
        app.tabBars.buttons["Лента"].tap()
        
        // Должен появиться пост о новом курсе
        XCTAssertTrue(app.cells.containing(.staticText, identifier: "Новый курс доступен").element.exists)
        
        // 4. Переключаемся на студента
        app.tabBars.buttons["Ещё"].tap()
        app.buttons["Настройки"].tap()
        app.buttons["Выйти"].tap()
        app.alerts.buttons["Выйти"].tap()
        
        app.buttons["Сменить пользователя"].tap()
        app.buttons["IT Специалист"].tap()
        
        // 5. Проверяем уведомление
        app.tabBars.buttons["Уведомления"].tap()
        XCTAssertTrue(app.cells.containing(.staticText, identifier: "Вам назначен курс: Интеграционный курс").element.exists)
        
        // 6. Начинаем курс
        app.tabBars.buttons["Обучение"].tap()
        app.cells.containing(.staticText, identifier: "Интеграционный курс").element.tap()
        app.buttons["Начать курс"].tap()
        
        // 7. Проходим Cmi5 контент
        app.cells.containing(.staticText, identifier: "AI Fluency").element.tap()
        app.cells.firstMatch.tap()
        sleep(3)
        app.buttons["Завершить"].tap()
        
        // 8. Проверяем обновление в Feed
        app.navigationBars.buttons["Закрыть"].tap()
        app.navigationBars.buttons.element(boundBy: 0).tap()
        app.tabBars.buttons["Лента"].tap()
        
        // Должен появиться пост о прогрессе
        let myProgressPost = app.cells.containing(.staticText, identifier: "Мой прогресс").element
        XCTAssertTrue(myProgressPost.waitForExistence(timeout: 5))
        
        // 9. Возвращаемся как админ и проверяем аналитику
        app.tabBars.buttons["Ещё"].tap()
        app.buttons["Настройки"].tap()
        app.buttons["Выйти"].tap()
        app.alerts.buttons["Выйти"].tap()
        
        app.buttons["Войти"].tap()
        
        // Проверяем общую аналитику
        app.tabBars.buttons["Ещё"].tap()
        app.buttons["Панель администратора"].tap()
        app.buttons["Аналитика обучения"].tap()
        
        // Проверяем метрики
        XCTAssertTrue(app.staticTexts["Активных курсов: 1"].exists)
        XCTAssertTrue(app.staticTexts["Студентов обучается: 1"].exists)
        XCTAssertTrue(app.staticTexts["Средний прогресс: 25%"].exists)
    }
} 