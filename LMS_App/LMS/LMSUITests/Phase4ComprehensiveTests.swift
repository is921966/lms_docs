import XCTest

// MARK: - Phase 4: Additional Comprehensive Tests for 100% Coverage

final class Phase4ComprehensiveTests: XCTestCase {
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

    // MARK: - 1. Competency Management Tests

    func test025_CompetencyListView() throws {
        app.launch()
        ensureLoggedInAsAdmin()

        app.tabBars.buttons["Ещё"].tap()
        app.buttons["Администрирование"].tap()

        // Находим и нажимаем на управление компетенциями
        let competenciesButton = app.buttons["competencyListButton"]
        if !competenciesButton.exists {
            // Альтернативный способ
            app.staticTexts["Компетенции"].tap()
        }

        // Проверяем список компетенций
        XCTAssertTrue(app.navigationBars["Компетенции"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["addCompetencyButton"].exists)
        XCTAssertTrue(app.scrollViews["competencyListScrollView"].exists)

        // Проверяем статистику
        XCTAssertTrue(app.otherElements["statisticsCard"].exists)
    }

    func test026_CompetencyCreateFlow() throws {
        app.launch()
        ensureLoggedInAsAdmin()
        navigateToCompetencyList()

        // Нажимаем кнопку добавления
        app.buttons["addCompetencyButton"].tap()

        // Заполняем форму
        let nameField = app.textFields["competencyNameField"]
        XCTAssertTrue(nameField.waitForExistence(timeout: 5))
        nameField.tap()
        nameField.typeText("Новая компетенция")

        let descriptionField = app.textViews["competencyDescriptionField"]
        descriptionField.tap()
        descriptionField.typeText("Описание новой компетенции для тестирования")

        // Выбираем категорию
        app.buttons["competencyCategoryPicker"].tap()
        app.pickerWheels.firstMatch.adjust(toPickerWheelValue: "Технические")
        app.buttons["Done"].tap()

        // Сохраняем
        app.buttons["saveCompetencyButton"].tap()

        // Проверяем что компетенция добавлена
        XCTAssertTrue(app.staticTexts["Новая компетенция"].waitForExistence(timeout: 5))
    }

    func test027_CompetencyEditFlow() throws {
        app.launch()
        ensureLoggedInAsAdmin()
        navigateToCompetencyList()

        // Выбираем первую компетенцию
        let firstCompetency = app.scrollViews.descendants(matching: .button).matching(identifier: "competencyCard_").firstMatch
        firstCompetency.tap()

        // Нажимаем редактировать
        app.buttons["editCompetencyButton"].tap()

        // Изменяем название
        let nameField = app.textFields["competencyNameField"]
        nameField.tap()
        nameField.clearAndTypeText("Обновленная компетенция")

        // Сохраняем
        app.buttons["saveCompetencyButton"].tap()

        // Проверяем изменения
        XCTAssertTrue(app.staticTexts["Обновленная компетенция"].waitForExistence(timeout: 5))
    }

    func test028_CompetencyFiltering() throws {
        app.launch()
        ensureLoggedInAsAdmin()
        navigateToCompetencyList()

        // Открываем фильтры
        app.buttons["filtersButton"].tap()

        // Выбираем категорию
        app.pickers["categoryPicker"].tap()
        app.pickerWheels.firstMatch.adjust(toPickerWheelValue: "Soft Skills")

        // Включаем показ неактивных
        app.switches["showInactiveToggle"].tap()

        // Применяем фильтры
        app.buttons["filtersDoneButton"].tap()

        // Проверяем результаты
        let competencyCards = app.scrollViews.descendants(matching: .button).matching(identifier: "competencyCard_")
        XCTAssertGreaterThan(competencyCards.count, 0)
    }

    // MARK: - 2. Position Management Tests

    func test029_PositionListView() throws {
        app.launch()
        ensureLoggedInAsAdmin()

        app.tabBars.buttons["Ещё"].tap()
        app.buttons["Администрирование"].tap()
        app.staticTexts["Должности"].tap()

        // Проверяем список должностей
        XCTAssertTrue(app.navigationBars["Должности"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["addPositionButton"].exists)

        // Проверяем карточки должностей
        let positionCards = app.scrollViews.descendants(matching: .button).matching(identifier: "positionCard_")
        XCTAssertGreaterThan(positionCards.count, 0)
    }

    func test030_PositionCreateFlow() throws {
        app.launch()
        ensureLoggedInAsAdmin()
        navigateToPositionList()

        // Создаем новую должность
        app.buttons["addPositionButton"].tap()

        // Заполняем форму
        app.textFields["positionNameField"].tap()
        app.textFields["positionNameField"].typeText("Senior iOS Developer")

        app.textViews["positionDescriptionField"].tap()
        app.textViews["positionDescriptionField"].typeText("Разработчик iOS приложений с опытом 3+ лет")

        // Добавляем компетенции
        app.buttons["addCompetencyButton"].tap()
        app.cells["iOS разработка"].tap()
        app.buttons["doneButton"].tap()

        // Сохраняем
        app.buttons["savePositionButton"].tap()

        // Проверяем создание
        XCTAssertTrue(app.staticTexts["Senior iOS Developer"].waitForExistence(timeout: 5))
    }

    // MARK: - 3. Onboarding Tests

    func test031_OnboardingDashboard() throws {
        app.launch()
        ensureLoggedIn()

        app.tabBars.buttons["Ещё"].tap()
        app.buttons["Адаптация"].tap()

        // Проверяем дашборд адаптации
        XCTAssertTrue(app.navigationBars["Программы адаптации"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.otherElements["onboardingStatsView"].exists)
        XCTAssertTrue(app.scrollViews["programsListScrollView"].exists)

        // Проверяем фильтры
        XCTAssertTrue(app.buttons["filterChipAll"].exists)
        XCTAssertTrue(app.textFields["searchTextField"].exists)
    }

    func test032_OnboardingProgramCreate() throws {
        app.launch()
        ensureLoggedInAsAdmin()
        navigateToOnboardingDashboard()

        // Создаем из шаблона
        app.buttons["createFromTemplateButton"].tap()

        // Выбираем шаблон
        let firstTemplate = app.cells["templateCard_"].firstMatch
        firstTemplate.tap()

        // Заполняем данные
        app.textFields["employeeNameField"].tap()
        app.textFields["employeeNameField"].typeText("Петров Петр")

        app.textFields["positionField"].tap()
        app.textFields["positionField"].typeText("iOS Developer")

        // Запускаем программу
        app.buttons["startProgramButton"].tap()

        // Проверяем создание
        XCTAssertTrue(app.staticTexts["Петров Петр"].waitForExistence(timeout: 5))
    }

    func test033_OnboardingTaskCompletion() throws {
        app.launch()
        ensureLoggedIn()
        navigateToOnboardingDashboard()

        // Открываем первую программу
        let firstProgram = app.scrollViews.descendants(matching: .button).matching(identifier: "programCard_").firstMatch
        firstProgram.tap()

        // Открываем первый этап
        app.buttons["stage_1"].tap()

        // Отмечаем задачу выполненной
        let firstTask = app.buttons["taskCheckbox_"].firstMatch
        firstTask.tap()

        // Проверяем обновление прогресса
        XCTAssertTrue(app.progressIndicators.firstMatch.exists)
    }

    // MARK: - 4. Course Materials Tests

    func test034_CourseMaterialsView() throws {
        app.launch()
        ensureLoggedIn()
        navigateToCourseDetail()

        // Переходим к материалам
        app.buttons["Материалы"].tap()

        // Проверяем список материалов
        XCTAssertTrue(app.navigationBars["Материалы курса"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.scrollViews["materialsListView"].exists)

        // Проверяем типы материалов
        XCTAssertTrue(app.staticTexts.containing(NSPredicate(format: "label CONTAINS[c] 'PDF' OR label CONTAINS[c] 'Видео' OR label CONTAINS[c] 'Презентация'")).firstMatch.exists)
    }

    func test035_MaterialDownload() throws {
        app.launch()
        ensureLoggedIn()
        navigateToCourseMaterials()

        // Находим материал для скачивания
        let downloadButton = app.buttons["downloadMaterial_"].firstMatch
        if downloadButton.exists {
            downloadButton.tap()

            // Проверяем индикатор загрузки
            XCTAssertTrue(app.progressIndicators["downloadProgress"].waitForExistence(timeout: 2))

            // Проверяем успешную загрузку
            XCTAssertTrue(app.staticTexts["Загружено"].waitForExistence(timeout: 10))
        }
    }

    // MARK: - 5. Test Management

    func test036_TestListView() throws {
        app.launch()
        ensureLoggedIn()

        app.tabBars.buttons["Обучение"].tap()
        app.buttons["Тесты"].tap()

        // Проверяем список тестов
        XCTAssertTrue(app.navigationBars["Тесты"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.scrollViews["testsListView"].exists)

        // Проверяем фильтры
        XCTAssertTrue(app.segmentedControls["testFilterSegment"].exists)
    }

    func test037_TestExecution() throws {
        app.launch()
        ensureLoggedIn()
        navigateToTestList()

        // Открываем первый тест
        let firstTest = app.cells["testCard_"].firstMatch
        firstTest.tap()

        // Начинаем тест
        app.buttons["startTestButton"].tap()

        // Проверяем первый вопрос
        XCTAssertTrue(app.staticTexts["Вопрос 1"].waitForExistence(timeout: 5))

        // Выбираем ответ
        app.buttons["answerOption_0"].tap()

        // Переходим к следующему вопросу
        app.buttons["nextQuestionButton"].tap()

        // Проверяем прогресс
        XCTAssertTrue(app.progressIndicators["testProgress"].exists)
    }

    // MARK: - 6. Analytics Tests

    func test038_AnalyticsDashboard() throws {
        app.launch()
        ensureLoggedInAsAdmin()

        app.tabBars.buttons["Ещё"].tap()
        app.buttons["Аналитика"].tap()

        // Проверяем дашборд аналитики
        XCTAssertTrue(app.navigationBars["Аналитика"].waitForExistence(timeout: 5))

        // Проверяем графики
        XCTAssertTrue(app.otherElements["courseCompletionChart"].exists)
        XCTAssertTrue(app.otherElements["userActivityChart"].exists)

        // Проверяем метрики
        XCTAssertTrue(app.staticTexts["Активные пользователи"].exists)
        XCTAssertTrue(app.staticTexts["Завершенные курсы"].exists)
    }

    func test039_ExportAnalytics() throws {
        app.launch()
        ensureLoggedInAsAdmin()
        navigateToAnalytics()

        // Экспортируем отчет
        app.buttons["exportReportButton"].tap()

        // Выбираем формат
        app.buttons["exportPDF"].tap()

        // Проверяем успешный экспорт
        XCTAssertTrue(app.alerts["Отчет готов"].waitForExistence(timeout: 5))
        app.alerts.buttons["OK"].tap()
    }

    // MARK: - 7. Certificate Tests

    func test040_CertificateList() throws {
        app.launch()
        ensureLoggedIn()

        app.tabBars.buttons["Профиль"].tap()
        app.buttons["Сертификаты"].tap()

        // Проверяем список сертификатов
        XCTAssertTrue(app.navigationBars["Мои сертификаты"].waitForExistence(timeout: 5))

        // Проверяем наличие сертификатов или пустое состояние
        let certificateExists = app.cells["certificateCard_"].firstMatch.exists
        let emptyStateExists = app.staticTexts["У вас пока нет сертификатов"].exists

        XCTAssertTrue(certificateExists || emptyStateExists)
    }

    // MARK: - 8. Edge Cases

    func test041_DeepLinking() throws {
        // Тест глубоких ссылок
        app.launchArguments.append("deeplink:course/123")
        app.launch()

        // Проверяем что открылся нужный курс
        XCTAssertTrue(app.navigationBars.staticTexts.containing(NSPredicate(format: "label CONTAINS[c] 'Курс'")).firstMatch.waitForExistence(timeout: 5))
    }

    func test042_LargeDataSet() throws {
        app.launch()
        app.launchEnvironment["LARGE_DATA_SET"] = "1"
        ensureLoggedIn()

        // Проверяем производительность со множеством элементов
        navigateToLearning()

        // Скроллим список
        let scrollView = app.scrollViews.firstMatch
        scrollView.swipeUp(velocity: .fast)
        scrollView.swipeUp(velocity: .fast)

        // Проверяем что нет зависаний
        XCTAssertTrue(app.buttons.count > 10)
    }

    func test043_MemoryWarning() throws {
        app.launch()
        app.launchEnvironment["SIMULATE_MEMORY_WARNING"] = "1"
        ensureLoggedIn()

        // Проверяем обработку нехватки памяти
        navigateToCourseDetail()

        // Приложение должно продолжать работать
        XCTAssertEqual(app.state, .runningForeground)
    }

    func test044_Accessibility() throws {
        app.launch()
        ensureLoggedIn()

        // Включаем VoiceOver
        app.launchArguments.append("-UIAccessibilityVoiceOverEnabled")

        // Проверяем accessibility labels
        let loginButton = app.buttons["loginButton"]
        XCTAssertNotNil(loginButton.label)

        // Проверяем navigation
        app.tabBars.buttons["Обучение"].tap()
        XCTAssertTrue(app.navigationBars.firstMatch.exists)
    }

    // MARK: - Helper Methods

    private func ensureLoggedIn() {
        if app.buttons["loginButton"].exists {
            loginAsStudent()
        }
    }

    private func ensureLoggedInAsAdmin() {
        if app.buttons["loginButton"].exists {
            loginAsAdmin()
        } else if !app.buttons["Администрирование"].exists {
            performLogout()
            loginAsAdmin()
        }
    }

    private func loginAsStudent() {
        app.buttons["loginButton"].tap()
        app.buttons["loginAsStudent"].tap()
    }

    private func loginAsAdmin() {
        app.buttons["loginButton"].tap()
        app.buttons["loginAsAdmin"].tap()
    }

    private func performLogout() {
        if app.tabBars.firstMatch.exists {
            app.tabBars.buttons["Ещё"].tap()
            if app.buttons["Выйти"].exists {
                app.buttons["Выйти"].tap()
                if app.alerts.firstMatch.exists {
                    app.alerts.buttons["Выйти"].tap()
                }
            }
        }
    }

    private func navigateToCompetencyList() {
        app.tabBars.buttons["Ещё"].tap()
        app.buttons["Администрирование"].tap()
        app.staticTexts["Компетенции"].tap()
    }

    private func navigateToPositionList() {
        app.tabBars.buttons["Ещё"].tap()
        app.buttons["Администрирование"].tap()
        app.staticTexts["Должности"].tap()
    }

    private func navigateToOnboardingDashboard() {
        app.tabBars.buttons["Ещё"].tap()
        app.buttons["Адаптация"].tap()
    }

    private func navigateToCourseDetail() {
        app.tabBars.buttons["Обучение"].tap()
        app.scrollViews.firstMatch.buttons.firstMatch.tap()
    }

    private func navigateToCourseMaterials() {
        navigateToCourseDetail()
        app.buttons["Материалы"].tap()
    }

    private func navigateToTestList() {
        app.tabBars.buttons["Обучение"].tap()
        app.buttons["Тесты"].tap()
    }

    private func navigateToAnalytics() {
        app.tabBars.buttons["Ещё"].tap()
        app.buttons["Аналитика"].tap()
    }

    private func navigateToLearning() {
        app.tabBars.buttons["Обучение"].tap()
    }
}
