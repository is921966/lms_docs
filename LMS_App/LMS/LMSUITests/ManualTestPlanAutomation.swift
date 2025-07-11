import XCTest

/// Автоматизация тестов из MANUAL_TESTING_PLAN.md
class ManualTestPlanAutomation: UITestBase {
    
    // MARK: - 1. Авторизация и роли
    
    func test_1_1_LoginScreen() throws {
        // Выходим если залогинены
        if app.tabBars.firstMatch.exists {
            logout()
        }
        
        // 1.1.1 Отображается форма входа
        waitForElement(app.textFields[AccessibilityIdentifiers.Auth.emailField])
        XCTAssertTrue(app.textFields[AccessibilityIdentifiers.Auth.emailField].exists)
        XCTAssertTrue(app.secureTextFields[AccessibilityIdentifiers.Auth.passwordField].exists)
        XCTAssertTrue(app.buttons[AccessibilityIdentifiers.Auth.loginButton].exists)
        
        takeScreenshot(name: "Login_Screen")
        
        // 1.1.2 Валидация полей работает
        app.buttons[AccessibilityIdentifiers.Auth.loginButton].tap()
        
        // Должно появиться сообщение об ошибке
        let errorLabel = app.staticTexts[AccessibilityIdentifiers.Auth.errorLabel]
        waitForElement(errorLabel, timeout: 3)
        XCTAssertTrue(errorLabel.exists, "Валидация пустых полей не работает")
        
        // 1.1.3 Неверные данные показывают ошибку
        clearAndTypeText(app.textFields[AccessibilityIdentifiers.Auth.emailField], text: "wrong@email.com")
        clearAndTypeText(app.secureTextFields[AccessibilityIdentifiers.Auth.passwordField], text: "wrongpass")
        app.buttons[AccessibilityIdentifiers.Auth.loginButton].tap()
        
        waitForElement(errorLabel, timeout: 5)
        XCTAssertTrue(errorLabel.label.contains("неверн") || errorLabel.label.contains("ошибк"))
        
        // 1.1.4 Remember me работает
        if app.switches[AccessibilityIdentifiers.Auth.rememberMeToggle].exists {
            app.switches[AccessibilityIdentifiers.Auth.rememberMeToggle].tap()
        }
        
        // 1.1.5 Успешный вход
        clearAndTypeText(app.textFields[AccessibilityIdentifiers.Auth.emailField], text: "student@company.com")
        clearAndTypeText(app.secureTextFields[AccessibilityIdentifiers.Auth.passwordField], text: "password123")
        app.buttons[AccessibilityIdentifiers.Auth.loginButton].tap()
        
        waitForElement(app.tabBars.firstMatch, timeout: 10)
        XCTAssertTrue(app.tabBars.firstMatch.exists, "Не удалось войти в систему")
    }
    
    func test_1_2_RoleBasedAccess() throws {
        // 1.2.1 Тест доступа студента
        login(as: .student)
        
        // Проверяем что нет админских функций
        app.tabBars.buttons["Профиль"].tap()
        waitForElement(app.scrollViews.firstMatch)
        
        let adminSection = app.staticTexts["Режим администратора"]
        XCTAssertFalse(adminSection.exists, "У студента есть доступ к админским функциям")
        
        takeScreenshot(name: "Student_Profile")
        
        logout()
        
        // 1.2.2 Тест доступа администратора
        login(as: .admin)
        
        app.tabBars.buttons["Профиль"].tap()
        waitForElement(app.scrollViews.firstMatch)
        
        // У админа должен быть доступ к админским функциям
        XCTAssertTrue(app.staticTexts["Режим администратора"].exists)
        
        takeScreenshot(name: "Admin_Profile")
    }
    
    // MARK: - 2. Дашборд
    
    func test_2_1_Dashboard() throws {
        login(as: .student)
        
        // 2.1.1 Отображаются актуальные курсы
        waitForElement(app.tabBars.firstMatch)
        
        // Если есть таб "Главная"
        if app.tabBars.buttons["Главная"].exists {
            app.tabBars.buttons["Главная"].tap()
            
            waitForElement(app.scrollViews.firstMatch)
            
            // Проверяем наличие секций
            XCTAssertTrue(app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] 'курс'")).count > 0)
            
            takeScreenshot(name: "Dashboard_Main")
        }
        
        // 2.1.2 Статистика обучения видна
        app.tabBars.buttons["Профиль"].tap()
        waitForElement(app.scrollViews.firstMatch)
        
        // Должна быть статистика
        let statsSection = app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] 'статистик' OR label CONTAINS[c] 'прогресс'")).firstMatch
        XCTAssertTrue(statsSection.exists, "Статистика не отображается")
    }
    
    // MARK: - 3. Модуль обучения
    
    func test_3_1_CoursesList() throws {
        login(as: .student)
        
        // 3.1.1 Отображается список курсов
        app.tabBars.buttons["Курсы"].tap()
        waitForElement(app.tables[AccessibilityIdentifiers.Courses.coursesList])
        
        XCTAssertTrue(app.tables[AccessibilityIdentifiers.Courses.coursesList].exists)
        XCTAssertGreaterThan(app.tables[AccessibilityIdentifiers.Courses.coursesList].cells.count, 0, "Список курсов пуст")
        
        takeScreenshot(name: "Courses_List")
        
        // 3.1.2 Поиск курсов
        if app.searchFields[AccessibilityIdentifiers.Courses.searchField].exists {
            app.searchFields[AccessibilityIdentifiers.Courses.searchField].tap()
            app.searchFields[AccessibilityIdentifiers.Courses.searchField].typeText("тест")
            
            // Ждем обновления результатов
            sleep(1)
            
            takeScreenshot(name: "Courses_Search_Results")
            
            // Очищаем поиск
            app.buttons["Cancel"].tap()
        }
        
        // 3.1.3 Фильтрация
        if app.buttons[AccessibilityIdentifiers.Courses.filterButton].exists {
            app.buttons[AccessibilityIdentifiers.Courses.filterButton].tap()
            
            waitForElement(app.sheets.firstMatch)
            takeScreenshot(name: "Courses_Filter")
            
            app.sheets.buttons["Отмена"].tap()
        }
    }
    
    func test_3_2_CourseDetails() throws {
        login(as: .student)
        
        app.tabBars.buttons["Курсы"].tap()
        waitForElement(app.tables[AccessibilityIdentifiers.Courses.coursesList])
        
        // Открываем первый курс
        let firstCourse = app.tables[AccessibilityIdentifiers.Courses.coursesList].cells.firstMatch
        XCTAssertTrue(firstCourse.exists)
        
        let courseName = firstCourse.label
        firstCourse.tap()
        
        // 3.2.1 Детальная страница загружается
        waitForElement(app.scrollViews.firstMatch)
        
        // 3.2.2 Информация о курсе отображается
        XCTAssertTrue(app.navigationBars.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] %@", courseName)).count > 0)
        
        takeScreenshot(name: "Course_Details")
        
        // 3.2.3 Кнопка записи/отписки
        let enrollButton = app.buttons[AccessibilityIdentifiers.Courses.enrollButton]
        if enrollButton.exists {
            let initialLabel = enrollButton.label
            enrollButton.tap()
            
            // Ждем изменения состояния
            sleep(2)
            
            XCTAssertNotEqual(enrollButton.label, initialLabel, "Состояние кнопки не изменилось")
        }
    }
    
    func test_3_3_Lessons() throws {
        login(as: .student)
        
        // Переходим к курсу с уроками
        app.tabBars.buttons["Курсы"].tap()
        waitForElement(app.tables[AccessibilityIdentifiers.Courses.coursesList])
        
        app.tables[AccessibilityIdentifiers.Courses.coursesList].cells.firstMatch.tap()
        waitForElement(app.scrollViews.firstMatch)
        
        // Ищем урок
        let lessonButton = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'урок' OR label CONTAINS[c] 'модуль'")).firstMatch
        
        if lessonButton.exists {
            lessonButton.tap()
            
            waitForElement(app.scrollViews.firstMatch, timeout: 10)
            
            // 3.3.1 Проверяем типы уроков
            // Видео
            if app.otherElements["AVPlayerViewController"].exists {
                takeScreenshot(name: "Lesson_Video")
            }
            
            // Текст
            if app.textViews.count > 0 {
                takeScreenshot(name: "Lesson_Text")
            }
            
            // Интерактивный (Cmi5)
            if app.buttons["Начать интерактивный урок"].exists {
                takeScreenshot(name: "Lesson_Interactive")
            }
            
            // 3.3.2 Навигация между уроками
            if app.buttons["Следующий урок"].exists {
                app.buttons["Следующий урок"].tap()
                waitForElement(app.scrollViews.firstMatch)
            }
        }
    }
    
    // MARK: - 4. Тестирование
    
    func test_4_1_TestsList() throws {
        login(as: .student)
        
        // Ищем таб с тестами
        if app.tabBars.buttons["Тесты"].exists {
            app.tabBars.buttons["Тесты"].tap()
        } else {
            // Возможно тесты в курсах
            app.tabBars.buttons["Курсы"].tap()
            waitForElement(app.tables[AccessibilityIdentifiers.Courses.coursesList])
            
            // Ищем курс с тестом
            let testCourse = app.cells.matching(NSPredicate(format: "label CONTAINS[c] 'тест'")).firstMatch
            if testCourse.exists {
                testCourse.tap()
            }
        }
        
        waitForElement(app.tables[AccessibilityIdentifiers.Tests.testsList], timeout: 10)
        
        // 4.1.1 Список тестов отображается
        XCTAssertTrue(app.tables[AccessibilityIdentifiers.Tests.testsList].exists)
        
        takeScreenshot(name: "Tests_List")
    }
    
    func test_4_2_TakeTest() throws {
        login(as: .student)
        
        // Находим и открываем тест
        navigateToTest()
        
        if app.buttons[AccessibilityIdentifiers.Tests.startTestButton].exists {
            app.buttons[AccessibilityIdentifiers.Tests.startTestButton].tap()
            
            // 4.2.1 Вопросы отображаются корректно
            waitForElement(app.scrollViews.firstMatch)
            
            // Проверяем элементы теста
            XCTAssertTrue(app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] 'вопрос'")).count > 0)
            
            takeScreenshot(name: "Test_Question")
            
            // 4.2.2 Выбор ответов
            let answerOption = app.buttons.matching(identifier: AccessibilityIdentifiers.Tests.answerOption).firstMatch
            if answerOption.exists {
                answerOption.tap()
            }
            
            // 4.2.3 Навигация между вопросами
            if app.buttons[AccessibilityIdentifiers.Tests.nextQuestionButton].exists {
                app.buttons[AccessibilityIdentifiers.Tests.nextQuestionButton].tap()
                sleep(1)
                
                if app.buttons[AccessibilityIdentifiers.Tests.previousQuestionButton].exists {
                    app.buttons[AccessibilityIdentifiers.Tests.previousQuestionButton].tap()
                }
            }
            
            // 4.2.4 Отправка теста
            if app.buttons[AccessibilityIdentifiers.Tests.submitTestButton].exists {
                app.buttons[AccessibilityIdentifiers.Tests.submitTestButton].tap()
                
                // Подтверждение
                if app.alerts.firstMatch.exists {
                    app.alerts.firstMatch.buttons["Отправить"].tap()
                }
                
                // 4.2.5 Результаты
                waitForElement(app.otherElements[AccessibilityIdentifiers.Tests.testResultView], timeout: 10)
                takeScreenshot(name: "Test_Results")
            }
        }
    }
    
    // MARK: - 5. Дашборды по ролям
    
    func test_5_1_StudentDashboard() throws {
        login(as: .student)
        
        // 5.1.1 Мои курсы
        if app.tabBars.buttons["Мои курсы"].exists {
            app.tabBars.buttons["Мои курсы"].tap()
            waitForElement(app.tables.firstMatch)
            takeScreenshot(name: "Student_My_Courses")
        }
        
        // 5.1.2 Прогресс обучения
        app.tabBars.buttons["Профиль"].tap()
        waitForElement(app.scrollViews.firstMatch)
        
        // Ищем секцию с прогрессом
        swipeToElement(app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] 'прогресс'")).firstMatch)
        takeScreenshot(name: "Student_Progress")
        
        // 5.1.3 Календарь
        if app.buttons["Календарь"].exists {
            app.buttons["Календарь"].tap()
            waitForElement(app.otherElements.matching(NSPredicate(format: "identifier CONTAINS[c] 'calendar'")).firstMatch)
            takeScreenshot(name: "Student_Calendar")
        }
    }
    
    func test_5_2_AdminDashboard() throws {
        login(as: .admin)
        
        // 5.2.1 Статистика системы
        if app.tabBars.buttons["Аналитика"].exists {
            app.tabBars.buttons["Аналитика"].tap()
            waitForElement(app.scrollViews.firstMatch)
            takeScreenshot(name: "Admin_Analytics")
        }
        
        // 5.2.2 Управление пользователями
        if app.tabBars.buttons["Пользователи"].exists {
            app.tabBars.buttons["Пользователи"].tap()
            waitForElement(app.tables.firstMatch)
            takeScreenshot(name: "Admin_Users")
        }
        
        // 5.2.3 Управление контентом
        app.tabBars.buttons["Профиль"].tap()
        app.buttons["Настройки"].tap()
        
        if app.cells["Управление контентом"].exists {
            app.cells["Управление контентом"].tap()
            waitForElement(app.tables.firstMatch)
            takeScreenshot(name: "Admin_Content_Management")
        }
    }
    
    // MARK: - 6. Административные функции
    
    func test_6_1_UserManagement() throws {
        login(as: .admin)
        
        // Переходим к управлению пользователями
        if app.tabBars.buttons["Пользователи"].exists {
            app.tabBars.buttons["Пользователи"].tap()
        } else {
            navigateToAdminSection("Пользователи")
        }
        
        waitForElement(app.tables.firstMatch)
        
        // 6.1.1 Список пользователей
        XCTAssertGreaterThan(app.tables.cells.count, 0, "Список пользователей пуст")
        takeScreenshot(name: "Admin_Users_List")
        
        // 6.1.2 Поиск пользователей
        if app.searchFields.firstMatch.exists {
            app.searchFields.firstMatch.tap()
            app.searchFields.firstMatch.typeText("student")
            sleep(1)
            takeScreenshot(name: "Admin_Users_Search")
            app.buttons["Cancel"].tap()
        }
        
        // 6.1.3 Добавление пользователя
        if app.buttons["person.badge.plus"].exists {
            app.buttons["person.badge.plus"].tap()
            waitForElement(app.textFields.firstMatch)
            takeScreenshot(name: "Admin_Add_User")
            app.buttons["Отмена"].tap()
        }
    }
    
    // MARK: - 7. Технические аспекты
    
    func test_7_1_Performance() throws {
        login(as: .student)
        
        // 7.1.1 Скорость загрузки
        let startTime = Date()
        app.tabBars.buttons["Курсы"].tap()
        waitForElement(app.tables[AccessibilityIdentifiers.Courses.coursesList])
        let loadTime = Date().timeIntervalSince(startTime)
        
        XCTAssertLessThan(loadTime, 3.0, "Загрузка списка курсов заняла больше 3 секунд")
        
        // 7.1.2 Плавность скролла
        let table = app.tables[AccessibilityIdentifiers.Courses.coursesList]
        
        // Скроллим вниз и вверх
        table.swipeUp()
        table.swipeUp()
        table.swipeDown()
        table.swipeDown()
        
        // Проверяем что приложение не зависло
        XCTAssertTrue(table.exists)
    }
    
    func test_7_2_ErrorHandling() throws {
        login(as: .student)
        
        // Симулируем сетевую ошибку (если есть debug меню)
        if navigateToDebugMenu() {
            if app.switches["Simulate Network Error"].exists {
                app.switches["Simulate Network Error"].tap()
                
                // Возвращаемся и пытаемся загрузить данные
                app.navigationBars.buttons.firstMatch.tap()
                app.tabBars.buttons["Курсы"].tap()
                
                // Должно появиться сообщение об ошибке
                waitForElement(app.staticTexts[AccessibilityIdentifiers.Common.errorView], timeout: 5)
                
                // Кнопка повтора
                if app.buttons[AccessibilityIdentifiers.Common.retryButton].exists {
                    takeScreenshot(name: "Error_State")
                    
                    // Выключаем симуляцию ошибки и повторяем
                    navigateToDebugMenu()
                    app.switches["Simulate Network Error"].tap()
                    app.navigationBars.buttons.firstMatch.tap()
                    
                    app.buttons[AccessibilityIdentifiers.Common.retryButton].tap()
                    waitForElement(app.tables[AccessibilityIdentifiers.Courses.coursesList])
                }
            }
        }
    }
    
    func test_7_3_Accessibility() throws {
        login(as: .student)
        
        // Включаем VoiceOver для проверки доступности
        // Примечание: В реальном тесте это делается через настройки системы
        
        // Проверяем что у элементов есть accessibility labels
        app.tabBars.buttons["Курсы"].tap()
        
        let table = app.tables[AccessibilityIdentifiers.Courses.coursesList]
        waitForElement(table)
        
        // Проверяем первую ячейку
        let firstCell = table.cells.firstMatch
        XCTAssertTrue(firstCell.exists)
        XCTAssertFalse(firstCell.label.isEmpty, "У ячейки нет accessibility label")
        
        // Проверяем кнопки
        for button in app.buttons.allElementsBoundByIndex {
            if button.exists && button.isHittable {
                XCTAssertFalse(button.label.isEmpty, "У кнопки нет accessibility label")
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func navigateToTest() {
        if app.tabBars.buttons["Тесты"].exists {
            app.tabBars.buttons["Тесты"].tap()
        } else {
            app.tabBars.buttons["Курсы"].tap()
            waitForElement(app.tables[AccessibilityIdentifiers.Courses.coursesList])
            
            let testCourse = app.cells.matching(NSPredicate(format: "label CONTAINS[c] 'тест'")).firstMatch
            if testCourse.exists {
                testCourse.tap()
                waitForElement(app.scrollViews.firstMatch)
                
                let testButton = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'тест'")).firstMatch
                if testButton.exists {
                    testButton.tap()
                }
            }
        }
    }
    
    private func navigateToAdminSection(_ section: String) {
        app.tabBars.buttons["Профиль"].tap()
        waitForElement(app.scrollViews.firstMatch)
        
        if app.cells[section].exists {
            app.cells[section].tap()
        } else if app.buttons[section].exists {
            app.buttons[section].tap()
        }
    }
    
    private func navigateToDebugMenu() -> Bool {
        app.tabBars.buttons["Профиль"].tap()
        waitForElement(app.scrollViews.firstMatch)
        
        app.buttons["Настройки"].tap()
        waitForElement(app.tables.firstMatch)
        
        // В debug режиме должен быть раздел для разработчиков
        if app.cells["Debug Menu"].exists {
            app.cells["Debug Menu"].tap()
            waitForElement(app.tables.firstMatch)
            return true
        }
        
        return false
    }
} 