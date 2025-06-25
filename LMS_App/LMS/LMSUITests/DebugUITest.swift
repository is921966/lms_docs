import XCTest

final class DebugUITest: XCTestCase {
    
    func testCaptureCurrentUIState() throws {
        let app = XCUIApplication()
        app.launch()
        
        // Ждем загрузки приложения
        sleep(3)
        
        // Делаем скриншот
        let screenshot = app.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = "Current UI State"
        attachment.lifetime = .keepAlways
        add(attachment)
        
        // Выводим иерархию элементов
        print("=== UI HIERARCHY ===")
        print(app.debugDescription)
        
        // Выводим все кнопки
        print("\n=== BUTTONS ===")
        for i in 0..<app.buttons.count {
            let button = app.buttons.element(boundBy: i)
            if button.exists {
                print("Button \(i): '\(button.label)' - identifier: '\(button.identifier)'")
            }
        }
        
        // Выводим все текстовые элементы
        print("\n=== STATIC TEXTS ===")
        for i in 0..<min(10, app.staticTexts.count) {
            let text = app.staticTexts.element(boundBy: i)
            if text.exists {
                print("Text \(i): '\(text.label)'")
            }
        }
        
        // Выводим все текстовые поля
        print("\n=== TEXT FIELDS ===")
        for i in 0..<app.textFields.count {
            let field = app.textFields.element(boundBy: i)
            if field.exists {
                print("TextField \(i): placeholder='\(field.placeholderValue ?? "")' value='\(field.value ?? "")'")
            }
        }
        
        // Проверяем наличие табов
        print("\n=== TAB BARS ===")
        print("Tab bars count: \(app.tabBars.count)")
        if app.tabBars.count > 0 {
            let tabBar = app.tabBars.firstMatch
            print("Tab buttons count: \(tabBar.buttons.count)")
        }
        
        // Проверяем навигационные бары
        print("\n=== NAVIGATION BARS ===")
        print("Navigation bars count: \(app.navigationBars.count)")
        
        XCTAssertTrue(true, "Debug test completed")
    }
} 