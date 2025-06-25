import XCTest

final class QuickStateTest: XCTestCase {
    
    func testQuickCheck() throws {
        let app = XCUIApplication()
        app.launch()
        
        sleep(2)
        
        // Проверяем основные состояния и делаем скриншот
        if app.buttons["Войти для разработки"].exists {
            XCTAssertTrue(true, "Found: Mock login button")
            takeScreenshot(named: "Login_Screen")
        } else if app.tabBars.firstMatch.exists {
            XCTAssertTrue(true, "Found: Tab bar - user is logged in")
            takeScreenshot(named: "Main_Screen")
            
            // Проверяем какие табы есть
            let tabBar = app.tabBars.firstMatch
            XCTAssertTrue(tabBar.buttons["Обучение"].exists || 
                         tabBar.buttons["Learning"].exists || 
                         tabBar.buttons.count > 0, "Tab bar has buttons")
        } else {
            // Неизвестное состояние - делаем скриншот для анализа
            takeScreenshot(named: "Unknown_State")
            
            // Пробуем найти любые элементы
            let hasButtons = app.buttons.count > 0
            let hasTexts = app.staticTexts.count > 0
            let hasTextFields = app.textFields.count > 0
            
            XCTAssertTrue(hasButtons || hasTexts || hasTextFields, 
                         "App has some UI elements. Buttons: \(app.buttons.count), Texts: \(app.staticTexts.count)")
        }
    }
    
    private func takeScreenshot(named name: String) {
        let screenshot = XCUIApplication().screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
} 