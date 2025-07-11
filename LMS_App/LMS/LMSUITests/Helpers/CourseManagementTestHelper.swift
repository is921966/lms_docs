import Foundation
import XCTest

/// Helper для Course Management UI тестов
extension XCTestCase {
    
    /// Перейти к Course Management модулю
    func navigateToCourseManagement(in app: XCUIApplication) {
        // Сначала проверяем, включен ли модуль
        if !app.buttons["Управление курсами"].exists && 
           !app.buttons["Course Management"].exists {
            
            // Включаем через настройки
            enableCourseManagement(in: app)
        }
        
        // Теперь переходим к модулю
        // Вариант 1: Прямо в табах
        if app.tabBars.buttons["Управление курсами"].exists {
            app.tabBars.buttons["Управление курсами"].tap()
        } else if app.tabBars.buttons["Course Management"].exists {
            app.tabBars.buttons["Course Management"].tap()
        } else {
            // Вариант 2: Через меню "Ещё"
            app.tabBars.buttons["Ещё"].tap()
            
            // Ищем в списке
            let courseButton = app.buttons["Управление курсами"].exists ? 
                              app.buttons["Управление курсами"] : 
                              app.buttons["Course Management"]
            
            if courseButton.waitForExistence(timeout: 5) {
                courseButton.tap()
            }
        }
    }
    
    /// Включить Course Management через настройки
    func enableCourseManagement(in app: XCUIApplication) {
        // Переходим в настройки
        if app.tabBars.buttons["Ещё"].exists {
            app.tabBars.buttons["Ещё"].tap()
        }
        
        if app.buttons["Настройки"].exists {
            app.buttons["Настройки"].tap()
        } else if app.buttons["Settings"].exists {
            app.buttons["Settings"].tap()
        }
        
        // Feature Flags
        if app.buttons["Feature Flags"].exists {
            app.buttons["Feature Flags"].tap()
        }
        
        // Включаем Course Management
        let toggle = app.switches["Course Management"].exists ?
                    app.switches["Course Management"] :
                    app.switches["Управление курсами"]
        
        if toggle.exists && toggle.value as? String == "0" {
            toggle.tap()
        }
        
        // Возвращаемся
        app.navigationBars.buttons.firstMatch.tap()
        if app.navigationBars.buttons.firstMatch.exists {
            app.navigationBars.buttons.firstMatch.tap()
        }
    }
    
    /// Создать тестовый курс
    func createTestCourse(in app: XCUIApplication, 
                         title: String = "Test Course",
                         description: String = "Test Description") {
        
        // Нажимаем кнопку создания
        if app.buttons["Создать курс"].exists {
            app.buttons["Создать курс"].tap()
        } else if app.buttons["Create Course"].exists {
            app.buttons["Create Course"].tap()
        } else if app.navigationBars.buttons["Add"].exists {
            app.navigationBars.buttons["Add"].tap()
        }
        
        // Заполняем форму
        let titleField = app.textFields.firstMatch
        if titleField.exists {
            titleField.tap()
            titleField.typeText(title)
        }
        
        let descField = app.textViews.firstMatch
        if descField.exists {
            descField.tap()
            descField.typeText(description)
        }
        
        // Сохраняем
        if app.buttons["Сохранить"].exists {
            app.buttons["Сохранить"].tap()
        } else if app.buttons["Save"].exists {
            app.buttons["Save"].tap()
        } else if app.navigationBars.buttons["Done"].exists {
            app.navigationBars.buttons["Done"].tap()
        }
    }
}

/// Mock данные для тестов
struct CourseManagementMockData {
    static let courses = [
        (title: "iOS Development", description: "Learn Swift and SwiftUI"),
        (title: "Backend Development", description: "PHP and Laravel"),
        (title: "Project Management", description: "Agile and Scrum")
    ]
    
    static let modules = [
        "Introduction",
        "Basic Concepts", 
        "Advanced Topics",
        "Practice",
        "Final Project"
    ]
}
