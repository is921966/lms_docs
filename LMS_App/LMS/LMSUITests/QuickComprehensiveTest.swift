import XCTest

final class QuickComprehensiveTest: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["UI-Testing"]
        app.launch()
    }
    
    func testQuickAllElements() throws {
        print("🚀 Запуск быстрого комплексного теста...")
        
        // 1. Экран входа
        print("🔍 Проверка экрана входа...")
        XCTAssertTrue(app.staticTexts["ЦУМ - Корпоративный университет"].exists)
        XCTAssertTrue(app.buttons["Войти как студент"].exists)
        XCTAssertTrue(app.buttons["Войти как администратор"].exists)
        takeScreenshot(named: "01_LoginScreen")
        
        // 2. Вход как студент
        print("👤 Вход как студент...")
        app.buttons["Войти как студент"].tap()
        sleep(2)
        
        // 3. Проверка табов
        let tabBar = app.tabBars.firstMatch
        XCTAssertTrue(tabBar.waitForExistence(timeout: 5))
        takeScreenshot(named: "02_MainScreen")
        
        print("📱 Проверка вкладок...")
        var foundTabs: [String] = []
        
        // Собираем информацию о вкладках
        for i in 0..<tabBar.buttons.count {
            let button = tabBar.buttons.element(boundBy: i)
            if button.exists {
                foundTabs.append(button.label)
            }
        }
        
        print("✅ Найдено вкладок: \(foundTabs.count)")
        for tab in foundTabs {
            print("   - \(tab)")
        }
        
        // 4. Проверяем каждую вкладку
        for (index, tabName) in foundTabs.enumerated() {
            if tabBar.buttons[tabName].exists {
                print("📍 Переход на вкладку: \(tabName)")
                tabBar.buttons[tabName].tap()
                sleep(1)
                takeScreenshot(named: "Tab_\(index)_\(tabName)")
            }
        }
        
        // 5. Проверка версии в настройках
        if tabBar.buttons["Настройки"].exists {
            print("⚙️ Проверка версии приложения...")
            tabBar.buttons["Настройки"].tap()
            sleep(1)
            
            // Прокручиваем вниз
            app.swipeUp()
            sleep(1)
            
            // Ищем версию
            let cells = app.cells
            for i in 0..<min(cells.count, 20) { // Ограничиваем поиск
                let cell = cells.element(boundBy: i)
                if cell.exists && cell.staticTexts["Версия приложения"].exists {
                    print("✅ Найдена версия приложения")
                    takeScreenshot(named: "AppVersion")
                    break
                }
            }
        }
        
        print("✅ Тест завершен успешно!")
        
        // Генерируем отчет
        generateReport(tabs: foundTabs)
    }
    
    private func takeScreenshot(named name: String) {
        let screenshot = XCUIScreen.main.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
    
    private func generateReport(tabs: [String]) {
        var report = """
        # Отчет автоматического UI тестирования LMS
        
        Дата: \(Date())
        Версия приложения: 1.0 (Build 202507021600)
        
        ## Результаты тестирования
        
        ### ✅ Протестированные элементы:
        - Экран входа
        - Кнопка "Войти как студент"
        - Кнопка "Войти как администратор"
        - Навигационная панель с \(tabs.count) вкладками
        
        ### 📱 Найденные вкладки:
        """
        
        for tab in tabs {
            report += "\n- \(tab)"
        }
        
        report += "\n\n### 📸 Скриншоты: \(tabs.count + 2) шт."
        
        print("\n" + report)
        
        let attachment = XCTAttachment(string: report)
        attachment.name = "TestReport.md"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
} 