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
