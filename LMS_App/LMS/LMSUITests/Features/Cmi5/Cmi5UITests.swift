//
//  Cmi5UITests.swift
//  LMSUITests
//
//  Created on Sprint 40 Day 5 - UI Tests
//

import XCTest

/// UI тесты для Cmi5 функциональности
final class Cmi5UITests: XCTestCase {
    
    private var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        
        app = XCUIApplication()
        app.launchArguments = ["-UITesting"]
        app.launch()
        
        // Логинимся
        performLogin()
        
        // Переходим в Course Builder
        navigateToCourseBuilder()
    }
    
    override func tearDownWithError() throws {
        app = nil
    }
    
    // MARK: - Import Tests
    
    func testCmi5ImportFlow() throws {
        // Given - находимся в Course Builder
        
        // When - начинаем импорт Cmi5
        let addContentButton = app.buttons["AddContentButton"]
        XCTAssertTrue(addContentButton.exists)
        addContentButton.tap()
        
        // Выбираем Cmi5
        let cmi5Option = app.buttons["ImportCmi5Package"]
        XCTAssertTrue(cmi5Option.waitForExistence(timeout: 2))
        cmi5Option.tap()
        
        // Then - проверяем что открылся импорт
        let importTitle = app.navigationBars["Импорт Cmi5 пакета"]
        XCTAssertTrue(importTitle.exists)
        
        // Проверяем элементы UI
        XCTAssertTrue(app.staticTexts["Инструкции"].exists)
        XCTAssertTrue(app.staticTexts["Перетащите файл сюда"].exists)
        XCTAssertTrue(app.buttons["Выбрать файл"].exists)
        
        // Нажимаем выбрать файл (в тесте используется демо)
        app.buttons["Выбрать файл"].tap()
        
        // Ждем обработку
        let successMessage = app.staticTexts["Пакет успешно обработан"]
        XCTAssertTrue(successMessage.waitForExistence(timeout: 5))
        
        // Проверяем информацию о пакете
        XCTAssertTrue(app.staticTexts["Корпоративная культура ЦУМ"].exists)
        XCTAssertTrue(app.staticTexts["Количество активностей"].exists)
        
        // Импортируем
        let importButton = app.buttons["Импортировать"]
        XCTAssertTrue(importButton.isEnabled)
        importButton.tap()
        
        // Проверяем что вернулись в Course Builder
        let courseBuilderTitle = app.navigationBars["Конструктор курса"]
        XCTAssertTrue(courseBuilderTitle.waitForExistence(timeout: 3))
    }
    
    func testCmi5PackagePreview() throws {
        // Given - импортировали пакет
        importDemoCmi5Package()
        
        // When - открываем предпросмотр
        let cmi5Activity = app.cells.containing(.staticText, identifier: "Корпоративная культура ЦУМ").firstMatch
        XCTAssertTrue(cmi5Activity.waitForExistence(timeout: 3))
        cmi5Activity.tap()
        
        // Then - проверяем экран предпросмотра
        let previewTitle = app.navigationBars["Предпросмотр пакета"]
        XCTAssertTrue(previewTitle.exists)
        
        // Проверяем информацию
        XCTAssertTrue(app.staticTexts["Информация о пакете"].exists)
        XCTAssertTrue(app.staticTexts["Структура курса"].exists)
        
        // Проверяем кнопки действий
        XCTAssertTrue(app.buttons["Создать уроки"].exists)
        XCTAssertTrue(app.buttons["Перепроверить"].exists)
        
        // Закрываем
        app.buttons["Закрыть"].tap()
    }
    
    func testCmi5ActivitySelection() throws {
        // Given - находимся в Course Builder с Cmi5 пакетом
        importDemoCmi5Package()
        
        // When - выбираем активности из пакета
        let selectActivitiesButton = app.buttons["Выбрать активности"]
        XCTAssertTrue(selectActivitiesButton.waitForExistence(timeout: 3))
        selectActivitiesButton.tap()
        
        // Then - проверяем селектор активностей
        let selectorTitle = app.navigationBars["Выберите активности"]
        XCTAssertTrue(selectorTitle.exists)
        
        // Проверяем список пакетов
        let packageCell = app.cells.containing(.staticText, identifier: "Корпоративная культура ЦУМ").firstMatch
        XCTAssertTrue(packageCell.exists)
        
        // Раскрываем пакет
        packageCell.tap()
        
        // Проверяем активности
        XCTAssertTrue(app.staticTexts["Введение в корпоративную культуру"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.staticTexts["Тест: Корпоративные ценности"].exists)
        XCTAssertTrue(app.staticTexts["Видео: История компании"].exists)
        
        // Выбираем активность
        let activityCell = app.cells.containing(.staticText, identifier: "Введение в корпоративную культуру").firstMatch
        activityCell.tap()
        
        // Добавляем
        let addButton = app.buttons["Добавить"]
        XCTAssertTrue(addButton.isEnabled)
        addButton.tap()
        
        // Проверяем что активность добавлена в курс
        XCTAssertTrue(app.staticTexts["Введение в корпоративную культуру"].waitForExistence(timeout: 3))
    }
    
    // MARK: - Lesson Player Tests
    
    func testCmi5LessonPlayer() throws {
        // Given - есть курс с Cmi5 уроком
        navigateToCourseWithCmi5()
        
        // When - открываем урок
        let lessonCell = app.cells.containing(.staticText, identifier: "Введение в корпоративную культуру").firstMatch
        XCTAssertTrue(lessonCell.waitForExistence(timeout: 3))
        lessonCell.tap()
        
        // Then - проверяем экран урока
        let lessonTitle = app.navigationBars["Введение в корпоративную культуру"]
        XCTAssertTrue(lessonTitle.exists)
        
        // Проверяем экран подготовки
        XCTAssertTrue(app.staticTexts["Подготовка к запуску"].exists)
        XCTAssertTrue(app.staticTexts["Продолжительность"].exists)
        XCTAssertTrue(app.staticTexts["30 мин"].exists)
        
        // Запускаем урок
        let startButton = app.buttons["Начать урок"]
        XCTAssertTrue(startButton.exists)
        startButton.tap()
        
        // Проверяем что WebView загрузился
        let webView = app.webViews.firstMatch
        XCTAssertTrue(webView.waitForExistence(timeout: 5))
        
        // Проверяем контролы
        XCTAssertTrue(app.buttons["exitFullScreenButton"].exists)
        XCTAssertTrue(app.buttons["Завершить"].exists)
    }
    
    func testCmi5FullScreenMode() throws {
        // Given - находимся в уроке
        navigateToCmi5Lesson()
        
        // When - включаем полноэкранный режим
        let fullScreenButton = app.buttons["enterFullScreenButton"]
        XCTAssertTrue(fullScreenButton.waitForExistence(timeout: 3))
        fullScreenButton.tap()
        
        // Then - проверяем полноэкранный режим
        // Навигация должна скрыться
        XCTAssertFalse(app.navigationBars.firstMatch.exists)
        
        // Кнопка выхода должна быть доступна
        let exitFullScreenButton = app.buttons["exitFullScreenButton"]
        XCTAssertTrue(exitFullScreenButton.exists)
        
        // Выходим из полноэкранного режима
        exitFullScreenButton.tap()
        
        // Проверяем что вернулись в обычный режим
        XCTAssertTrue(app.navigationBars.firstMatch.waitForExistence(timeout: 2))
    }
    
    func testCmi5LessonCompletion() throws {
        // Given - находимся в уроке
        navigateToCmi5Lesson()
        
        // When - завершаем урок
        let completeButton = app.buttons["Завершить"]
        XCTAssertTrue(completeButton.waitForExistence(timeout: 3))
        completeButton.tap()
        
        // Подтверждаем
        let alert = app.alerts["Завершить урок?"]
        XCTAssertTrue(alert.waitForExistence(timeout: 2))
        alert.buttons["Завершить"].tap()
        
        // Then - проверяем что вернулись к списку уроков
        let courseTitle = app.navigationBars.firstMatch
        XCTAssertTrue(courseTitle.waitForExistence(timeout: 3))
        
        // Проверяем что урок отмечен как пройденный
        let completedIcon = app.images["checkmark.circle.fill"]
        XCTAssertTrue(completedIcon.exists)
    }
    
    // MARK: - Error Handling Tests
    
    func testCmi5ImportError() throws {
        // Given - начинаем импорт
        app.buttons["AddContentButton"].tap()
        app.buttons["ImportCmi5Package"].tap()
        
        // When - симулируем ошибку (в демо режиме)
        app.switches["SimulateError"].tap() // Специальный switch для тестов
        app.buttons["Выбрать файл"].tap()
        
        // Then - проверяем отображение ошибки
        let errorMessage = app.staticTexts["Ошибка"]
        XCTAssertTrue(errorMessage.waitForExistence(timeout: 3))
        
        // Проверяем что кнопка импорта недоступна
        let importButton = app.buttons["Импортировать"]
        XCTAssertFalse(importButton.isEnabled)
    }
    
    // MARK: - Helper Methods
    
    private func performLogin() {
        // Пропускаем если уже залогинены
        if app.tabBars.firstMatch.exists {
            return
        }
        
        let emailField = app.textFields["EmailTextField"]
        if emailField.waitForExistence(timeout: 3) {
            emailField.tap()
            emailField.typeText("test@example.com")
            
            let passwordField = app.secureTextFields["PasswordTextField"]
            passwordField.tap()
            passwordField.typeText("password123")
            
            app.buttons["LoginButton"].tap()
            
            // Ждем появления главного экрана
            XCTAssertTrue(app.tabBars.firstMatch.waitForExistence(timeout: 5))
        }
    }
    
    private func navigateToCourseBuilder() {
        // Переходим в Курсы
        app.tabBars.buttons["Курсы"].tap()
        
        // Создаем новый курс или открываем существующий
        if app.buttons["CreateCourseButton"].exists {
            app.buttons["CreateCourseButton"].tap()
            
            // Заполняем форму
            let titleField = app.textFields["CourseTitleField"]
            titleField.tap()
            titleField.typeText("Test Cmi5 Course")
            
            app.buttons["Создать"].tap()
        } else {
            // Открываем первый курс
            app.cells.firstMatch.tap()
        }
        
        // Переходим в конструктор
        if app.buttons["EditCourseButton"].exists {
            app.buttons["EditCourseButton"].tap()
        }
    }
    
    private func importDemoCmi5Package() {
        app.buttons["AddContentButton"].tap()
        app.buttons["ImportCmi5Package"].tap()
        app.buttons["Выбрать файл"].tap()
        
        let importButton = app.buttons["Импортировать"]
        _ = importButton.waitForExistence(timeout: 5)
        if importButton.isEnabled {
            importButton.tap()
        }
    }
    
    private func navigateToCourseWithCmi5() {
        // Переходим в Курсы
        app.tabBars.buttons["Курсы"].tap()
        
        // Открываем курс с Cmi5
        let courseCell = app.cells.containing(.staticText, identifier: "Test Cmi5 Course").firstMatch
        if courseCell.waitForExistence(timeout: 3) {
            courseCell.tap()
        } else {
            // Создаем если нет
            navigateToCourseBuilder()
            importDemoCmi5Package()
            app.navigationBars.buttons.firstMatch.tap() // Назад
        }
    }
    
    private func navigateToCmi5Lesson() {
        navigateToCourseWithCmi5()
        
        let lessonCell = app.cells.containing(.staticText, identifier: "Введение в корпоративную культуру").firstMatch
        lessonCell.tap()
        
        let startButton = app.buttons["Начать урок"]
        if startButton.waitForExistence(timeout: 2) {
            startButton.tap()
        }
    }
} 