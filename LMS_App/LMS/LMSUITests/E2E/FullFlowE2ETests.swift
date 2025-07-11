//
//  FullFlowE2ETests.swift
//  LMSUITests
//
//  End-to-End тесты полных сценариев
//

import XCTest

class FullFlowE2ETests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["UI_TESTING", "E2E_TESTING"]
        app.launch()
    }
    
    override func tearDownWithError() throws {
        // Очистка после тестов
        cleanupE2ETestData(in: app)
    }
    
    // MARK: - Full User Journey Tests
    
    func testCompleteUserJourney() {
        // 1. Авторизация
        performLogin(in: app)
        
        // 2. Проверка главного экрана
        verifyMainNavigation(in: app)
        
        // 3. Переход в обучение
        app.tabBars.buttons["Обучение"].tap()
        XCTAssertTrue(app.navigationBars["Обучение"].waitForExistence(timeout: 5))
        
        // 4. Просмотр курса
        if app.collectionViews.cells.count > 0 {
            app.collectionViews.cells.firstMatch.tap()
            XCTAssertTrue(app.navigationBars.buttons.firstMatch.waitForExistence(timeout: 5))
            app.navigationBars.buttons.firstMatch.tap()
        }
        
        // 5. Переход в профиль
        app.tabBars.buttons["Профиль"].tap()
        XCTAssertTrue(app.staticTexts["E2E Test User"].exists || 
                     app.staticTexts["test@example.com"].exists)
        
        // 6. Выход
        performLogout(in: app)
    }
    
    func testCourseEnrollmentFlow() {
        // Авторизация
        performLogin(in: app)
        
        // Переход к курсам
        app.tabBars.buttons["Обучение"].tap()
        
        // Выбор курса
        let courseCell = app.collectionViews.cells.firstMatch
        guard courseCell.waitForExistence(timeout: 5) else {
            XCTSkip("No courses available for testing")
            return
        }
        
        courseCell.tap()
        
        // Запись на курс
        if app.buttons["Записаться"].exists {
            app.buttons["Записаться"].tap()
            
            // Проверка успешной записи
            XCTAssertTrue(
                app.buttons["Начать обучение"].waitForExistence(timeout: 5) ||
                app.buttons["Продолжить"].waitForExistence(timeout: 5)
            )
        }
    }
    
    func testCompetencyProgressFlow() {
        // Авторизация
        performLogin(in: app)
        
        // Переход к компетенциям
        if app.tabBars.buttons["Компетенции"].exists {
            app.tabBars.buttons["Компетенции"].tap()
        } else {
            app.tabBars.buttons["Ещё"].tap()
            app.buttons["Компетенции"].tap()
        }
        
        // Просмотр компетенции
        let competencyCell = app.collectionViews.cells.firstMatch
        if competencyCell.waitForExistence(timeout: 5) {
            competencyCell.tap()
            
            // Проверка деталей
            XCTAssertTrue(app.staticTexts["Уровень"].exists || 
                         app.staticTexts["Level"].exists)
        }
    }
}
