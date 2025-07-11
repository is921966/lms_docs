import XCTest

final class CourseManagementE2ETests: XCTestCase {
    
    let app = XCUIApplication()
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launch()
        
        // Логинимся как администратор
        if app.buttons["Войти"].exists {
            app.buttons["Войти"].tap()
        }
        
        // Переходим в админ панель
        app.tabBars.buttons["Ещё"].tap()
        app.buttons["Панель администратора"].tap()
    }
    
    override func tearDownWithError() throws {
        app.terminate()
    }
    
    // MARK: - Полный E2E сценарий
    
    func testCompleteCourseCycle() throws {
        // 1. Создание курса
        app.buttons["Управление курсами"].tap()
        app.navigationBars.buttons["Добавить"].tap()
        
        // Заполняем форму
        let titleField = app.textFields["course-title-field"]
        titleField.tap()
        titleField.typeText("E2E Test Course")
        
        let descriptionField = app.textViews["course-description-field"]
        descriptionField.tap()
        descriptionField.typeText("This is an end-to-end test course")
        
        // Выбираем категорию
        app.buttons["course-category-picker"].tap()
        app.pickerWheels.element.adjust(toPickerWheelValue: "Технические навыки")
        app.buttons["Готово"].tap()
        
        // Устанавливаем продолжительность
        app.steppers["course-duration-stepper"].buttons["Increment"].tap()
        app.steppers["course-duration-stepper"].buttons["Increment"].tap()
        
        // Сохраняем курс
        app.buttons["Сохранить"].tap()
        
        // Проверяем, что курс появился в списке
        XCTAssertTrue(app.cells.containing(.staticText, identifier: "E2E Test Course").element.exists)
        
        // 2. Добавление материалов к курсу
        app.cells.containing(.staticText, identifier: "E2E Test Course").element.tap()
        app.buttons["Материалы курса"].tap()
        app.buttons["Добавить материал"].tap()
        
        // Добавляем видео урок
        app.buttons["Видео"].tap()
        app.textFields["material-title-field"].tap()
        app.textFields["material-title-field"].typeText("Введение в курс")
        app.textFields["material-url-field"].tap()
        app.textFields["material-url-field"].typeText("https://example.com/video1.mp4")
        app.buttons["Добавить"].tap()
        
        // Добавляем документ
        app.buttons["Добавить материал"].tap()
        app.buttons["Документ"].tap()
        app.textFields["material-title-field"].tap()
        app.textFields["material-title-field"].typeText("Методические материалы")
        app.buttons["Выбрать файл"].tap()
        // Симулируем выбор файла
        app.buttons["Добавить"].tap()
        
        // Возвращаемся к курсу
        app.navigationBars.buttons.element(boundBy: 0).tap()
        
        // 3. Назначение курса пользователям
        app.buttons["Назначить пользователям"].tap()
        
        // Выбираем всех новых сотрудников
        app.buttons["filter-button"].tap()
        app.buttons["Новые сотрудники"].tap()
        app.buttons["Применить"].tap()
        
        // Выбираем несколько пользователей
        app.switches["select-all-users"].tap()
        
        // Назначаем курс
        app.buttons["Назначить выбранным"].tap()
        
        // Подтверждаем
        app.alerts.buttons["Назначить"].tap()
        
        // Проверяем сообщение об успехе
        XCTAssertTrue(app.staticTexts["Курс успешно назначен"].exists)
        
        // 4. Переключаемся на студента
        app.navigationBars.buttons["Готово"].tap()
        app.navigationBars.buttons.element(boundBy: 0).tap() // Назад к админ панели
        app.navigationBars.buttons.element(boundBy: 0).tap() // Назад к More
        
        // Выходим и входим как студент
        app.buttons["Настройки"].tap()
        app.buttons["Выйти"].tap()
        app.alerts.buttons["Выйти"].tap()
        
        // Логинимся как студент
        app.buttons["Сменить пользователя"].tap()
        app.buttons["Студент Тестовый"].tap()
        
        // 5. Проходим курс как студент
        app.tabBars.buttons["Обучение"].tap()
        
        // Находим назначенный курс
        XCTAssertTrue(app.cells.containing(.staticText, identifier: "E2E Test Course").element.exists)
        
        app.cells.containing(.staticText, identifier: "E2E Test Course").element.tap()
        
        // Начинаем курс
        app.buttons["Начать курс"].tap()
        
        // Смотрим первый урок
        app.cells.containing(.staticText, identifier: "Введение в курс").element.tap()
        
        // Симулируем просмотр
        sleep(2)
        
        // Отмечаем как завершенный
        app.buttons["Завершить урок"].tap()
        
        // Проверяем прогресс
        XCTAssertTrue(app.progressIndicators["course-progress"].exists)
        
        // 6. Возвращаемся как админ и проверяем аналитику
        app.navigationBars.buttons.element(boundBy: 0).tap()
        app.navigationBars.buttons.element(boundBy: 0).tap()
        
        // Выходим и входим как админ
        app.tabBars.buttons["Ещё"].tap()
        app.buttons["Настройки"].tap()
        app.buttons["Выйти"].tap()
        app.alerts.buttons["Выйти"].tap()
        
        app.buttons["Войти"].tap()
        
        // Проверяем аналитику
        app.tabBars.buttons["Ещё"].tap()
        app.buttons["Панель администратора"].tap()
        app.buttons["Управление курсами"].tap()
        
        app.cells.containing(.staticText, identifier: "E2E Test Course").element.tap()
        app.buttons["Аналитика"].tap()
        
        // Проверяем, что есть данные о прохождении
        XCTAssertTrue(app.staticTexts["1 студент начал"].exists)
        XCTAssertTrue(app.staticTexts["1 урок завершен"].exists)
    }
    
    // MARK: - Тест массовых операций
    
    func testBulkCourseOperations() throws {
        app.buttons["Управление курсами"].tap()
        
        // Создаем несколько курсов для теста
        for i in 1...3 {
            app.navigationBars.buttons["Добавить"].tap()
            
            let titleField = app.textFields["course-title-field"]
            titleField.tap()
            titleField.typeText("Bulk Test Course \(i)")
            
            app.buttons["Сохранить"].tap()
            sleep(1) // Даем время на сохранение
        }
        
        // Включаем режим выбора
        app.buttons["Выбрать"].tap()
        
        // Выбираем все созданные курсы
        for i in 1...3 {
            app.cells.containing(.staticText, identifier: "Bulk Test Course \(i)").element.tap()
        }
        
        // Выполняем массовое действие
        app.buttons["Действия"].tap()
        app.buttons["Архивировать выбранные"].tap()
        app.alerts.buttons["Архивировать"].tap()
        
        // Проверяем, что курсы архивированы
        app.buttons["filter-button"].tap()
        app.buttons["Архивные"].tap()
        app.buttons["Применить"].tap()
        
        for i in 1...3 {
            XCTAssertTrue(app.cells.containing(.staticText, identifier: "Bulk Test Course \(i)").element.exists)
        }
    }
    
    // MARK: - Тест поиска и фильтрации
    
    func testCourseSearchAndFilter() throws {
        app.buttons["Управление курсами"].tap()
        
        // Тестируем поиск
        let searchField = app.searchFields["Поиск курсов"]
        searchField.tap()
        searchField.typeText("Python")
        
        // Проверяем, что отображаются только релевантные результаты
        XCTAssertTrue(app.cells.containing(.staticText, identifier: "Python для начинающих").element.exists)
        XCTAssertFalse(app.cells.containing(.staticText, identifier: "JavaScript основы").element.exists)
        
        // Очищаем поиск
        searchField.buttons["Clear text"].tap()
        
        // Тестируем фильтры
        app.buttons["filter-button"].tap()
        
        // Фильтр по категории
        app.buttons["Категория"].tap()
        app.buttons["Soft Skills"].tap()
        
        // Фильтр по статусу
        app.buttons["Статус"].tap()
        app.buttons["Активные"].tap()
        
        app.buttons["Применить"].tap()
        
        // Проверяем, что фильтры применены
        XCTAssertTrue(app.staticTexts["Фильтры: 2"].exists)
    }
} 