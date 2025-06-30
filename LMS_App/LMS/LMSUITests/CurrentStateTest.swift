import XCTest

final class CurrentStateTest: XCTestCase {
    func testCheckCurrentScreen() throws {
        let app = XCUIApplication()
        app.launch()

        // Ждем загрузки
        sleep(2)

        // Проверяем различные возможные состояния
        if app.buttons["Войти для разработки"].exists {
            print("FOUND: Mock login button")
            XCTAssertTrue(true, "App shows mock login screen")
        } else if app.tabBars.firstMatch.exists {
            print("FOUND: Tab bar - user is logged in")
            // Проверяем табы
            let tabBar = app.tabBars.firstMatch
            if tabBar.buttons["Обучение"].exists {
                print("FOUND: Learning tab")
            }
            if tabBar.buttons["Профиль"].exists {
                print("FOUND: Profile tab")
            }
            if tabBar.buttons["Ещё"].exists {
                print("FOUND: More tab")
            }
            XCTAssertTrue(true, "App shows main screen with tabs")
        } else if app.buttons["Войти через VK ID"].exists {
            print("FOUND: VK ID login button")
            XCTAssertTrue(true, "App shows VK ID login screen")
        } else {
            // Выводим первые несколько элементов для диагностики
            print("UNKNOWN STATE - First buttons:")
            for i in 0..<min(5, app.buttons.count) {
                let button = app.buttons.element(boundBy: i)
                print("  Button: '\(button.label)'")
            }

            print("First texts:")
            for i in 0..<min(5, app.staticTexts.count) {
                let text = app.staticTexts.element(boundBy: i)
                print("  Text: '\(text.label)'")
            }

            XCTFail("Unknown app state")
        }
    }
}
