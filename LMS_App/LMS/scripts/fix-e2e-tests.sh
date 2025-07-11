#!/bin/bash

echo "🔧 Исправление E2E тестов..."
echo "============================"

# Создаем helper для E2E тестов
echo "📝 Создание E2E test helper..."
mkdir -p LMSUITests/Helpers

cat > "LMSUITests/Helpers/E2ETestHelper.swift" << 'EOF'
import Foundation
import XCTest

/// Helper для E2E тестов
extension XCTestCase {
    
    /// Выполнить полный сценарий авторизации
    func performLogin(in app: XCUIApplication, username: String = "test@example.com", password: String = "password123") {
        // Проверяем, не авторизованы ли уже
        if app.tabBars.firstMatch.exists {
            // Уже на главном экране
            return
        }
        
        // Ищем поля логина
        let emailField = app.textFields.firstMatch
        let passwordField = app.secureTextFields.firstMatch
        
        if emailField.exists {
            emailField.tap()
            emailField.typeText(username)
        }
        
        if passwordField.exists {
            passwordField.tap()
            passwordField.typeText(password)
        }
        
        // Нажимаем кнопку входа
        let loginButton = app.buttons["Войти"].exists ? app.buttons["Войти"] : app.buttons["Login"]
        if loginButton.exists {
            loginButton.tap()
        }
        
        // Ждем появления главного экрана
        XCTAssertTrue(app.tabBars.firstMatch.waitForExistence(timeout: 10))
    }
    
    /// Выполнить выход из системы
    func performLogout(in app: XCUIApplication) {
        // Переходим в профиль
        if app.tabBars.buttons["Профиль"].exists {
            app.tabBars.buttons["Профиль"].tap()
        } else if app.tabBars.buttons["Profile"].exists {
            app.tabBars.buttons["Profile"].tap()
        } else if app.tabBars.buttons["Ещё"].exists {
            app.tabBars.buttons["Ещё"].tap()
            if app.buttons["Профиль"].exists {
                app.buttons["Профиль"].tap()
            }
        }
        
        // Ищем кнопку выхода
        let logoutButton = app.buttons["Выйти"].exists ? app.buttons["Выйти"] : app.buttons["Logout"]
        if logoutButton.exists {
            logoutButton.tap()
            
            // Подтверждаем выход если нужно
            if app.alerts.firstMatch.exists {
                app.alerts.buttons["Выйти"].tap()
            }
        }
    }
    
    /// Создать тестовые данные
    func setupE2ETestData(in app: XCUIApplication) {
        // Этот метод может быть расширен для создания тестовых данных
        // Например, через API или специальные debug endpoints
    }
    
    /// Очистить тестовые данные
    func cleanupE2ETestData(in app: XCUIApplication) {
        // Очистка после тестов
    }
    
    /// Проверить основные элементы навигации
    func verifyMainNavigation(in app: XCUIApplication) {
        XCTAssertTrue(app.tabBars.firstMatch.exists, "Tab bar should exist")
        
        // Проверяем основные табы
        let expectedTabs = ["Главная", "Обучение", "Новости", "Профиль", "Home", "Learning", "Feed", "Profile"]
        
        var foundTabs = 0
        for tab in expectedTabs {
            if app.tabBars.buttons[tab].exists {
                foundTabs += 1
            }
        }
        
        XCTAssertGreaterThanOrEqual(foundTabs, 3, "Should have at least 3 main tabs")
    }
}

/// Mock данные для E2E тестов
struct E2ETestData {
    static let testUser = (
        email: "e2e.test@example.com",
        password: "Test123!",
        name: "E2E Test User"
    )
    
    static let testCourse = (
        title: "E2E Test Course",
        description: "Course for E2E testing",
        duration: "2 hours"
    )
    
    static let testCompetency = (
        name: "E2E Test Competency",
        level: "Beginner",
        description: "Competency for testing"
    )
}
EOF

echo "✅ E2E test helper создан"

# Обновляем E2E тесты
echo ""
echo "📝 Обновление E2E тестов..."

# Проверяем, есть ли уже E2E тесты
if [ -f "LMSUITests/E2E/FullFlowE2ETests.swift" ]; then
    echo "✅ E2E тесты уже существуют"
else
    echo "🔧 Создание базовых E2E тестов..."
    mkdir -p LMSUITests/E2E
    
    cat > "LMSUITests/E2E/FullFlowE2ETests.swift" << 'EOF'
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
EOF
fi

echo ""
echo "✅ E2E тесты настроены!"
echo ""
echo "📋 Что было сделано:"
echo "  1. Создан E2ETestHelper с общими методами"
echo "  2. Добавлены методы для авторизации/выхода"
echo "  3. Созданы тестовые данные E2ETestData"
echo "  4. Обновлены/созданы базовые E2E тесты" 