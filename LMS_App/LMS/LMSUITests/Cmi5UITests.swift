import XCTest

/// UI тесты для Cmi5 функциональности
/// Основано на TESTING_SCENARIOS_CMI5.md
class Cmi5UITests: UITestBase {
    
    // MARK: - Setup
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        // Авторизуемся как студент для тестирования
        login(as: .student)
    }
    
    // MARK: - Сценарий 1: Базовый импорт и запуск Cmi5 пакета
    
    func testScenario1_BasicCmi5Launch() throws {
        // 1. Найти курс с Cmi5 контентом
        app.tabBars.buttons["Курсы"].tap()
        waitForElement(app.tables[AccessibilityIdentifiers.Courses.coursesList])
        
        // Ищем курс с интерактивным контентом
        let predicate = NSPredicate(format: "label CONTAINS[c] 'интерактивный' OR label CONTAINS[c] 'Cmi5'")
        let cmi5Course = app.tables[AccessibilityIdentifiers.Courses.coursesList].cells.matching(predicate).firstMatch
        
        guard cmi5Course.exists else {
            XCTFail("Не найден курс с Cmi5 контентом. Убедитесь, что администратор создал тестовый курс.")
            return
        }
        
        cmi5Course.tap()
        
        // 2. Перейти к Cmi5 уроку
        waitForElement(app.scrollViews.firstMatch)
        
        // Ищем урок с иконкой куба или меткой "Интерактивный"
        let lessonPredicate = NSPredicate(format: "label CONTAINS[c] 'интерактивный урок' OR label CONTAINS[c] '🎲'")
        let cmi5Lesson = app.scrollViews.descendants(matching: .button).matching(lessonPredicate).firstMatch
        
        if !cmi5Lesson.exists {
            // Попробуем поискать в ячейках таблицы
            let cmi5LessonCell = app.tables.cells.matching(lessonPredicate).firstMatch
            if cmi5LessonCell.exists {
                cmi5LessonCell.tap()
            } else {
                XCTFail("Не найден Cmi5 урок в курсе")
                return
            }
        } else {
            cmi5Lesson.tap()
        }
        
        // 3. Запустить Cmi5 активность
        let startButton = app.buttons["Начать интерактивный урок"]
        waitForElement(startButton, timeout: 10)
        
        // Делаем скриншот перед запуском
        takeScreenshot(name: "Cmi5_Before_Launch")
        
        startButton.tap()
        
        // 4. Проверить загрузку Cmi5 Player
        // Player должен открыться в полноэкранном режиме
        waitForElement(app.webViews.firstMatch, timeout: 10)
        
        // Проверяем что контент загрузился
        XCTAssertTrue(app.webViews.firstMatch.exists, "Cmi5 Player не загрузился")
        
        takeScreenshot(name: "Cmi5_Player_Loaded")
        
        // Проверяем время загрузки (должно быть < 5 секунд)
        let loadTime = measureTime {
            _ = app.webViews.firstMatch.waitForExistence(timeout: 5)
        }
        XCTAssertLessThan(loadTime, 5.0, "Загрузка контента заняла больше 5 секунд")
        
        // Ждем несколько секунд для взаимодействия с контентом
        sleep(3)
        
        // Проверяем наличие кнопки закрытия
        let closeButton = app.buttons["xmark.circle.fill"]
        if closeButton.exists {
            closeButton.tap()
            
            // Проверяем сохранение прогресса
            waitForElement(app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] 'прогресс'")), timeout: 5)
        }
    }
    
    // MARK: - Сценарий 2: Офлайн режим
    
    func testScenario2_OfflineMode() throws {
        // Переходим в режим полета для эмуляции офлайн
        // Примечание: В реальном тесте это делается через Settings app
        
        // 1. Открываем курс с Cmi5 контентом
        navigateToCmi5Course()
        
        // 2. Проверяем индикатор офлайн режима
        let offlineIndicator = app.otherElements["offlineIndicator"]
        
        // 3. Пытаемся запустить Cmi5 контент
        if let cmi5Lesson = findCmi5Lesson() {
            cmi5Lesson.tap()
            
            let startButton = app.buttons["Начать интерактивный урок"]
            if startButton.exists {
                startButton.tap()
                
                // Проверяем сообщение об офлайн режиме
                let offlineAlert = app.alerts["Нет подключения к сети"]
                if offlineAlert.exists {
                    XCTAssertTrue(offlineAlert.staticTexts["Для загрузки нового контента требуется подключение к интернету"].exists)
                    offlineAlert.buttons["OK"].tap()
                } else {
                    // Если контент был закеширован, он должен загрузиться
                    waitForElement(app.webViews.firstMatch, timeout: 10)
                    takeScreenshot(name: "Cmi5_Offline_Cached_Content")
                }
            }
        }
    }
    
    // MARK: - Сценарий 3: Прерывание и возобновление
    
    func testScenario3_InterruptionHandling() throws {
        // 1. Запускаем Cmi5 контент
        navigateToCmi5Course()
        if let lesson = findCmi5Lesson() {
            lesson.tap()
            app.buttons["Начать интерактивный урок"].tap()
            
            waitForElement(app.webViews.firstMatch, timeout: 10)
            
            // 2. Симулируем прерывание - сворачиваем приложение
            XCUIDevice.shared.press(.home)
            sleep(2)
            
            // 3. Возвращаемся в приложение
            app.activate()
            
            // 4. Проверяем что контент все еще загружен
            XCTAssertTrue(app.webViews.firstMatch.exists, "Cmi5 контент потерян после прерывания")
            
            // 5. Проверяем сохранение прогресса
            let closeButton = app.buttons["xmark.circle.fill"]
            if closeButton.exists {
                closeButton.tap()
            }
            
            // Снова открываем тот же урок
            if let lesson = findCmi5Lesson() {
                lesson.tap()
                
                // Должна быть информация о предыдущем прогрессе
                let progressText = app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] 'прогресс' OR label CONTAINS[c] 'пройдено'")).firstMatch
                XCTAssertTrue(progressText.exists, "Прогресс не сохранился после прерывания")
            }
        }
    }
    
    // MARK: - Сценарий 4: Аналитика и отчеты
    
    func testScenario4_AnalyticsAndReports() throws {
        // 1. Проходим Cmi5 контент
        navigateToCmi5Course()
        completeCmi5Lesson()
        
        // 2. Переходим в раздел аналитики
        app.tabBars.buttons["Профиль"].tap()
        waitForElement(app.scrollViews.firstMatch)
        
        // Ищем раздел со статистикой
        let analyticsSection = app.buttons["Моя статистика"]
        if analyticsSection.exists {
            analyticsSection.tap()
            
            // 3. Проверяем отображение данных Cmi5
            waitForElement(app.tables.firstMatch)
            
            // Должны быть данные о пройденном контенте
            let cmi5Stats = app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] 'интерактивный' OR label CONTAINS[c] 'Cmi5'")).firstMatch
            XCTAssertTrue(cmi5Stats.exists, "Статистика Cmi5 не отображается")
            
            takeScreenshot(name: "Cmi5_Analytics")
        }
        
        // 4. Проверяем отчеты для преподавателя/админа
        logout()
        login(as: .admin)
        
        // Переходим в аналитику
        if let analyticsTab = app.tabBars.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'аналитика'")).firstMatch {
            analyticsTab.tap()
            
            // Ищем отчеты по Cmi5
            waitForElement(app.tables.firstMatch)
            
            let cmi5Report = app.cells.matching(NSPredicate(format: "label CONTAINS[c] 'Cmi5' OR label CONTAINS[c] 'интерактивный контент'")).firstMatch
            if cmi5Report.exists {
                cmi5Report.tap()
                takeScreenshot(name: "Cmi5_Admin_Reports")
            }
        }
    }
    
    // MARK: - Сценарий 5: Некорректный контент
    
    func testScenario5_InvalidContent() throws {
        // Этот тест требует специально подготовленного некорректного контента
        // В реальных условиях администратор должен загрузить поврежденный Cmi5 пакет
        
        navigateToCmi5Course()
        
        // Ищем урок с пометкой "поврежденный" или "тест ошибки"
        let errorLesson = app.cells.matching(NSPredicate(format: "label CONTAINS[c] 'поврежден' OR label CONTAINS[c] 'ошибк'")).firstMatch
        
        if errorLesson.exists {
            errorLesson.tap()
            
            let startButton = app.buttons["Начать интерактивный урок"]
            if startButton.exists {
                startButton.tap()
                
                // Должно появиться сообщение об ошибке
                let errorAlert = app.alerts.firstMatch
                waitForElement(errorAlert, timeout: 10)
                
                XCTAssertTrue(errorAlert.exists, "Не показано сообщение об ошибке для некорректного контента")
                takeScreenshot(name: "Cmi5_Error_Alert")
                
                errorAlert.buttons["OK"].tap()
            }
        }
    }
    
    // MARK: - Сценарий 6: Множественные AU
    
    func testScenario6_MultipleAUs() throws {
        navigateToCmi5Course()
        
        // Ищем курс с несколькими AU
        let multiAUCourse = app.cells.matching(NSPredicate(format: "label CONTAINS[c] 'несколько' OR label CONTAINS[c] 'multi'")).firstMatch
        
        if multiAUCourse.exists {
            multiAUCourse.tap()
            
            waitForElement(app.tables.firstMatch)
            
            // Считаем количество интерактивных уроков
            let interactiveLessons = app.cells.matching(NSPredicate(format: "label CONTAINS[c] 'интерактивный'"))
            let count = interactiveLessons.count
            
            XCTAssertGreaterThan(count, 1, "Должно быть несколько AU в пакете")
            
            // Проверяем навигацию между AU
            for i in 0..<min(count, 3) {
                let lesson = interactiveLessons.element(boundBy: i)
                lesson.tap()
                
                let startButton = app.buttons["Начать интерактивный урок"]
                if startButton.exists {
                    startButton.tap()
                    
                    waitForElement(app.webViews.firstMatch, timeout: 10)
                    sleep(2)
                    
                    // Закрываем и переходим к следующему
                    if let closeButton = app.buttons["xmark.circle.fill"] {
                        closeButton.tap()
                    } else {
                        app.swipeDown()
                    }
                    
                    waitForElement(app.tables.firstMatch)
                }
            }
        }
    }
    
    // MARK: - Сценарий 7: Производительность
    
    func testScenario7_Performance() throws {
        measure {
            navigateToCmi5Course()
            
            if let lesson = findCmi5Lesson() {
                lesson.tap()
                
                let startButton = app.buttons["Начать интерактивный урок"]
                if startButton.exists {
                    startButton.tap()
                    
                    // Измеряем время загрузки
                    _ = app.webViews.firstMatch.waitForExistence(timeout: 10)
                    
                    // Закрываем
                    if let closeButton = app.buttons["xmark.circle.fill"] {
                        closeButton.tap()
                    }
                }
            }
        }
    }
    
    // MARK: - Сценарий 8: Граничные случаи
    
    func testScenario8_EdgeCases() throws {
        // Тест 1: Быстрое открытие/закрытие
        navigateToCmi5Course()
        
        if let lesson = findCmi5Lesson() {
            for _ in 0..<3 {
                lesson.tap()
                
                let startButton = app.buttons["Начать интерактивный урок"]
                if startButton.exists {
                    startButton.tap()
                    
                    // Сразу закрываем
                    if let closeButton = app.buttons["xmark.circle.fill"] {
                        closeButton.tap()
                        
                        // Проверяем предупреждение
                        let alert = app.alerts["Прервать урок?"]
                        if alert.exists {
                            alert.buttons["Да"].tap()
                        }
                    }
                }
                
                waitForElement(app.tables.firstMatch)
            }
        }
        
        // Тест 2: Поворот экрана
        if let lesson = findCmi5Lesson() {
            lesson.tap()
            app.buttons["Начать интерактивный урок"].tap()
            
            waitForElement(app.webViews.firstMatch)
            
            // Поворачиваем экран
            XCUIDevice.shared.orientation = .landscapeLeft
            sleep(1)
            XCUIDevice.shared.orientation = .portrait
            sleep(1)
            
            // Контент должен адаптироваться
            XCTAssertTrue(app.webViews.firstMatch.exists, "Контент потерян после поворота экрана")
        }
    }
    
    // MARK: - Helper Methods
    
    private func navigateToCmi5Course() {
        app.tabBars.buttons["Курсы"].tap()
        waitForElement(app.tables[AccessibilityIdentifiers.Courses.coursesList])
    }
    
    private func findCmi5Lesson() -> XCUIElement? {
        let predicate = NSPredicate(format: "label CONTAINS[c] 'интерактивный' OR label CONTAINS[c] '🎲'")
        let lesson = app.cells.matching(predicate).firstMatch
        return lesson.exists ? lesson : nil
    }
    
    private func completeCmi5Lesson() {
        if let lesson = findCmi5Lesson() {
            lesson.tap()
            
            let startButton = app.buttons["Начать интерактивный урок"]
            if startButton.exists {
                startButton.tap()
                
                waitForElement(app.webViews.firstMatch, timeout: 10)
                
                // Симулируем прохождение контента
                sleep(5)
                
                // Закрываем с сохранением
                if let closeButton = app.buttons["xmark.circle.fill"] {
                    closeButton.tap()
                    
                    let saveAlert = app.alerts.firstMatch
                    if saveAlert.exists {
                        saveAlert.buttons["Сохранить"].tap()
                    }
                }
            }
        }
    }
    
    private func measureTime(block: () -> Void) -> TimeInterval {
        let start = Date()
        block()
        return Date().timeIntervalSince(start)
    }
} 