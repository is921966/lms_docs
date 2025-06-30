import XCTest

final class DiagnosticTest: XCTestCase {
    func testDiagnoseCurrentUIState() throws {
        let app = XCUIApplication()
        app.launchArguments = ["UI_TESTING", "MOCK_MODE"]
        app.launchEnvironment = ["UI_TESTING": "1", "MOCK_AUTH": "1"]
        app.launch()

        // Ждем загрузки
        sleep(3)

        print("\n=== DIAGNOSTIC REPORT ===")
        print("App State: \(app.state.rawValue)")

        // Проверяем различные элементы
        print("\n--- Checking Login Elements ---")
        print("'Войти для разработки' exists: \(app.buttons["Войти для разработки"].exists)")
        print("'Войти через VK ID' exists: \(app.buttons["Войти через VK ID"].exists)")
        print("'Login' exists: \(app.buttons["Login"].exists)")
        print("'Sign In' exists: \(app.buttons["Sign In"].exists)")

        print("\n--- Checking Tab Bar ---")
        print("Tab bar exists: \(app.tabBars.firstMatch.exists)")
        if app.tabBars.firstMatch.exists {
            print("Tab bar buttons count: \(app.tabBars.firstMatch.buttons.count)")
            print("'Обучение' tab exists: \(app.tabBars.buttons["Обучение"].exists)")
            print("'Профиль' tab exists: \(app.tabBars.buttons["Профиль"].exists)")
            print("'Ещё' tab exists: \(app.tabBars.buttons["Ещё"].exists)")
        }

        print("\n--- First 5 Buttons ---")
        for i in 0..<min(5, app.buttons.count) {
            let button = app.buttons.element(boundBy: i)
            if button.exists {
                print("Button \(i): '\(button.label)' (identifier: '\(button.identifier)')")
            }
        }

        print("\n--- First 5 Static Texts ---")
        for i in 0..<min(5, app.staticTexts.count) {
            let text = app.staticTexts.element(boundBy: i)
            if text.exists {
                print("Text \(i): '\(text.label)'")
            }
        }

        print("\n--- Navigation Bars ---")
        print("Navigation bars count: \(app.navigationBars.count)")
        if !app.navigationBars.isEmpty {
            let navBar = app.navigationBars.firstMatch
            print("First nav bar title: '\(navBar.identifier)'")
        }

        print("\n--- Alerts ---")
        print("Alerts count: \(app.alerts.count)")
        if !app.alerts.isEmpty {
            let alert = app.alerts.firstMatch
            print("Alert title: '\(alert.label)'")
        }

        // Делаем скриншот
        let screenshot = app.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = "Current UI State"
        attachment.lifetime = .keepAlways
        add(attachment)

        print("\n=== END DIAGNOSTIC REPORT ===\n")

        // Тест всегда проходит для диагностики
        XCTAssertTrue(true, "Diagnostic completed")
    }
}
