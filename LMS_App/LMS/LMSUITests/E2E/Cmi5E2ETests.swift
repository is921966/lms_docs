import XCTest

final class Cmi5E2ETests: XCTestCase {
    
    let app = XCUIApplication()
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launch()
        
        // Логинимся как администратор
        if app.buttons["Войти"].exists {
            app.buttons["Войти"].tap()
        }
        
        // Переходим к Cmi5 модулю
        app.tabBars.buttons["Ещё"].tap()
        app.buttons["Cmi5 Контент"].tap()
    }
    
    override func tearDownWithError() throws {
        app.terminate()
    }
    
    // MARK: - Полный E2E сценарий Cmi5
    
    func testCompleteCmi5Workflow() throws {
        // 1. Импорт Cmi5 пакета
        app.navigationBars.buttons["add-package-button"].tap()
        
        // Выбираем способ импорта
        app.buttons["Загрузить с устройства"].tap()
        
        // Симулируем выбор файла
        // В реальном тесте здесь будет взаимодействие с файловым менеджером
        app.buttons["Выбрать файл"].tap()
        
        // Для теста используем заранее подготовленный файл
        app.cells["corporate_culture_tsum_v1.0.zip"].tap()
        
        // Начинаем импорт
        app.buttons["Импортировать"].tap()
        
        // Ждем завершения импорта
        let importSuccessAlert = app.alerts["Импорт завершен"]
        XCTAssertTrue(importSuccessAlert.waitForExistence(timeout: 10))
        importSuccessAlert.buttons["OK"].tap()
        
        // Проверяем, что пакет появился в списке
        XCTAssertTrue(app.cells.containing(.staticText, identifier: "Корпоративная культура ЦУМ").element.exists)
        
        // 2. Просмотр деталей пакета
        app.cells.containing(.staticText, identifier: "Корпоративная культура ЦУМ").element.tap()
        
        // Проверяем информацию о пакете
        XCTAssertTrue(app.staticTexts["3 модуля"].exists)
        XCTAssertTrue(app.staticTexts["8 активностей"].exists)
        XCTAssertTrue(app.staticTexts["Версия: 1.0.0"].exists)
        
        // Просматриваем структуру
        app.buttons["Структура курса"].tap()
        
        // Проверяем модули
        XCTAssertTrue(app.cells.containing(.staticText, identifier: "История компании").element.exists)
        XCTAssertTrue(app.cells.containing(.staticText, identifier: "Миссия и ценности").element.exists)
        XCTAssertTrue(app.cells.containing(.staticText, identifier: "Корпоративные стандарты").element.exists)
        
        app.navigationBars.buttons.element(boundBy: 0).tap()
        
        // 3. Назначение пакета пользователям
        app.buttons["Назначить пользователям"].tap()
        
        // Выбираем группу пользователей
        app.buttons["Выбрать группу"].tap()
        app.buttons["Все сотрудники"].tap()
        
        // Устанавливаем дедлайн
        app.buttons["Установить дедлайн"].tap()
        app.datePickers.element.adjust(toPickerWheelValue: "31 июля 2025")
        app.buttons["Готово"].tap()
        
        // Назначаем
        app.buttons["Назначить"].tap()
        app.alerts.buttons["Подтвердить"].tap()
        
        // Проверяем успех
        XCTAssertTrue(app.staticTexts["Пакет назначен 150 пользователям"].exists)
        
        // 4. Переключаемся на студента и проходим курс
        app.navigationBars.buttons["Готово"].tap()
        app.navigationBars.buttons.element(boundBy: 0).tap()
        
        // Выходим и входим как студент
        app.buttons["Настройки"].tap()
        app.buttons["Выйти"].tap()
        app.alerts.buttons["Выйти"].tap()
        
        app.buttons["Сменить пользователя"].tap()
        app.buttons["Студент Тестовый"].tap()
        
        // Переходим к обучению
        app.tabBars.buttons["Обучение"].tap()
        
        // Находим назначенный Cmi5 курс
        app.cells.containing(.staticText, identifier: "Корпоративная культура ЦУМ").element.tap()
        
        // Начинаем курс
        app.buttons["Начать курс"].tap()
        
        // Проходим первый модуль
        app.cells.containing(.staticText, identifier: "История компании").element.tap()
        
        // Ждем загрузки контента
        sleep(2)
        
        // Взаимодействуем с контентом
        // Симулируем клики по интерактивным элементам
        if app.webViews.buttons["timeline-1925"].exists {
            app.webViews.buttons["timeline-1925"].tap()
            sleep(1)
            app.webViews.buttons["timeline-1950"].tap()
            sleep(1)
            app.webViews.buttons["timeline-2000"].tap()
        }
        
        // Завершаем модуль
        app.buttons["Далее"].tap()
        
        // Проверяем, что прогресс сохранен
        XCTAssertTrue(app.progressIndicators["course-progress"].exists)
        
        // 5. Проходим тест
        app.cells.containing(.staticText, identifier: "Тест: Введение").element.tap()
        
        // Отвечаем на вопросы
        app.webViews.buttons["answer-1"].tap()
        app.buttons["Далее"].tap()
        
        app.webViews.buttons["answer-2"].tap()
        app.buttons["Далее"].tap()
        
        app.webViews.buttons["answer-3"].tap()
        app.buttons["Завершить тест"].tap()
        
        // Проверяем результат
        XCTAssertTrue(app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] 'баллов'")).element.exists)
        
        // 6. Возвращаемся как админ и проверяем аналитику
        app.navigationBars.buttons["Закрыть"].tap()
        app.navigationBars.buttons.element(boundBy: 0).tap()
        
        // Выходим и входим как админ
        app.tabBars.buttons["Ещё"].tap()
        app.buttons["Настройки"].tap()
        app.buttons["Выйти"].tap()
        app.alerts.buttons["Выйти"].tap()
        
        app.buttons["Войти"].tap()
        
        // Проверяем аналитику
        app.tabBars.buttons["Ещё"].tap()
        app.buttons["Cmi5 Контент"].tap()
        
        app.cells.containing(.staticText, identifier: "Корпоративная культура ЦУМ").element.tap()
        app.buttons["Аналитика"].tap()
        
        // Проверяем xAPI данные
        XCTAssertTrue(app.staticTexts["Statements: 5+"].exists)
        XCTAssertTrue(app.staticTexts["Активных сессий: 1"].exists)
        XCTAssertTrue(app.staticTexts["Средний прогресс: 40%"].exists)
        
        // Просматриваем детальную статистику
        app.buttons["Детальная статистика"].tap()
        XCTAssertTrue(app.cells.containing(.staticText, identifier: "initialized").element.exists)
        XCTAssertTrue(app.cells.containing(.staticText, identifier: "progressed").element.exists)
        XCTAssertTrue(app.cells.containing(.staticText, identifier: "completed").element.exists)
    }
    
    // MARK: - Тест офлайн режима
    
    func testCmi5OfflineMode() throws {
        // Импортируем пакет
        app.cells.containing(.staticText, identifier: "AI Fluency").element.tap()
        app.buttons["Начать курс"].tap()
        
        // Включаем авиарежим (симуляция)
        app.buttons["debug-menu"].tap()
        app.switches["simulate-offline"].tap()
        app.buttons["Закрыть"].tap()
        
        // Проходим контент в офлайн режиме
        app.cells.containing(.staticText, identifier: "Основы взаимодействия с ИИ").element.tap()
        
        // Проверяем индикатор офлайн режима
        XCTAssertTrue(app.staticTexts["Офлайн режим"].exists)
        
        // Взаимодействуем с контентом
        app.webViews.buttons["concept-1"].tap()
        app.webViews.buttons["concept-2"].tap()
        app.buttons["Далее"].tap()
        
        // Проверяем, что прогресс сохраняется локально
        XCTAssertTrue(app.staticTexts["Прогресс сохранен локально"].exists)
        
        // Выключаем авиарежим
        app.buttons["debug-menu"].tap()
        app.switches["simulate-offline"].tap()
        app.buttons["Закрыть"].tap()
        
        // Проверяем синхронизацию
        sleep(3) // Даем время на синхронизацию
        XCTAssertTrue(app.staticTexts["Данные синхронизированы"].exists)
    }
    
    // MARK: - Тест экспорта данных
    
    func testCmi5DataExport() throws {
        app.cells.containing(.staticText, identifier: "Корпоративная культура ЦУМ").element.tap()
        app.buttons["Аналитика"].tap()
        
        // Экспортируем данные
        app.buttons["Экспорт"].tap()
        app.buttons["Экспорт xAPI"].tap()
        
        // Выбираем период
        app.buttons["Выбрать период"].tap()
        app.buttons["Последние 30 дней"].tap()
        
        // Выбираем формат
        app.buttons["JSON"].tap()
        
        // Экспортируем
        app.buttons["Экспортировать"].tap()
        
        // Проверяем успех
        let successAlert = app.alerts["Экспорт завершен"]
        XCTAssertTrue(successAlert.waitForExistence(timeout: 5))
        successAlert.buttons["Поделиться"].tap()
        
        // Проверяем, что открылся share sheet
        XCTAssertTrue(app.otherElements["ActivityListView"].exists)
        
        // Закрываем
        app.buttons["Закрыть"].tap()
    }
} 