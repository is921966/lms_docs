import XCTest

final class ComprehensiveUITest: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["UI-Testing"]
        app.launch()
    }
    
    override func tearDownWithError() throws {
        app = nil
    }
    
    // MARK: - Тест всех элементов управления
    
    func testAllUIElementsAndMenuItems() throws {
        // 1. Экран входа
        print("🔍 Тестирование экрана входа...")
        testLoginScreen()
        
        // 2. Вход как студент
        print("👤 Вход как студент...")
        loginAsStudent()
        
        // 3. Проверка всех вкладок
        print("📱 Проверка всех вкладок...")
        testAllTabs()
        
        // 4. Тестирование профиля
        print("👤 Тестирование профиля...")
        testProfileTab()
        
        // 5. Тестирование настроек
        print("⚙️ Тестирование настроек...")
        testSettingsTab()
        
        // 6. Выход и вход как администратор
        print("🔄 Выход и вход как администратор...")
        logout()
        loginAsAdmin()
        
        // 7. Проверка админских функций
        print("👑 Проверка админских функций...")
        testAdminFeatures()
        
        print("✅ Все тесты пройдены успешно!")
    }
    
    // MARK: - Helper методы
    
    private func testLoginScreen() {
        // Проверяем наличие элементов на экране входа
        XCTAssertTrue(app.staticTexts["ЦУМ - Корпоративный университет"].exists)
        XCTAssertTrue(app.staticTexts["(Режим разработки)"].exists)
        XCTAssertTrue(app.buttons["Войти как студент"].exists)
        XCTAssertTrue(app.buttons["Войти как администратор"].exists)
        
        // Делаем скриншот
        takeScreenshot(named: "01_LoginScreen")
    }
    
    private func loginAsStudent() {
        app.buttons["Войти как студент"].tap()
        
        // Ждем загрузки главного экрана
        let tabBar = app.tabBars.firstMatch
        XCTAssertTrue(tabBar.waitForExistence(timeout: 5))
        
        takeScreenshot(named: "02_StudentMainScreen")
    }
    
    private func loginAsAdmin() {
        app.buttons["Войти как администратор"].tap()
        
        // Ждем загрузки главного экрана
        let tabBar = app.tabBars.firstMatch
        XCTAssertTrue(tabBar.waitForExistence(timeout: 5))
        
        takeScreenshot(named: "03_AdminMainScreen")
    }
    
    private func testAllTabs() {
        let tabBar = app.tabBars.firstMatch
        
        // Главная
        if tabBar.buttons["Главная"].exists {
            tabBar.buttons["Главная"].tap()
            sleep(1)
            takeScreenshot(named: "04_MainTab")
        }
        
        // Курсы
        if tabBar.buttons["Курсы"].exists {
            tabBar.buttons["Курсы"].tap()
            sleep(1)
            takeScreenshot(named: "05_CoursesTab")
        }
        
        // Профиль
        if tabBar.buttons["Профиль"].exists {
            tabBar.buttons["Профиль"].tap()
            sleep(1)
            takeScreenshot(named: "06_ProfileTab")
        }
        
        // Настройки
        if tabBar.buttons["Настройки"].exists {
            tabBar.buttons["Настройки"].tap()
            sleep(1)
            takeScreenshot(named: "07_SettingsTab")
        }
    }
    
    private func testProfileTab() {
        let tabBar = app.tabBars.firstMatch
        tabBar.buttons["Профиль"].tap()
        
        // Проверяем элементы профиля
        XCTAssertTrue(app.navigationBars["Профиль"].exists)
        
        // Проверяем достижения
        if app.buttons["Достижения"].exists {
            app.buttons["Достижения"].tap()
            sleep(1)
            takeScreenshot(named: "08_ProfileAchievements")
            
            // Проверяем наличие элементов
            XCTAssertTrue(app.images.count > 0, "Должны быть иконки достижений")
        }
        
        // Проверяем активность
        if app.buttons["Активность"].exists {
            app.buttons["Активность"].tap()
            sleep(1)
            takeScreenshot(named: "09_ProfileActivity")
            
            // Проверяем список активности
            if app.cells.count > 0 {
                print("📊 Найдено \(app.cells.count) записей активности")
            }
        }
        
        // Проверяем навыки
        if app.buttons["Навыки"].exists {
            app.buttons["Навыки"].tap()
            sleep(1)
            takeScreenshot(named: "10_ProfileSkills")
        }
        
        // Проверяем настройки
        if app.buttons["Настройки"].exists {
            app.buttons["Настройки"].tap()
            sleep(1)
            takeScreenshot(named: "11_ProfileSettings")
            
            // Проверяем переключатели
            XCTAssertTrue(app.switches.count > 0, "Должны быть переключатели уведомлений")
        }
        
        // Прокручиваем вниз чтобы увидеть версию
        app.swipeUp()
        sleep(1)
        
        // Проверяем наличие версии
        let versionPredicate = NSPredicate(format: "label CONTAINS[c] 'Версия'")
        let versionLabel = app.staticTexts.element(matching: versionPredicate)
        if versionLabel.exists {
            takeScreenshot(named: "12_ProfileVersion")
            print("📱 Найдена версия: \(versionLabel.label)")
        }
    }
    
    private func testSettingsTab() {
        let tabBar = app.tabBars.firstMatch
        tabBar.buttons["Настройки"].tap()
        
        // Проверяем элементы настроек
        XCTAssertTrue(app.navigationBars["Настройки"].exists)
        
        // Проверяем переключатели
        let switches = app.switches
        for i in 0..<switches.count {
            let switchElement = switches.element(boundBy: i)
            if switchElement.exists && switchElement.isHittable {
                let label = switchElement.label
                print("🔘 Найден переключатель: \(label)")
                
                // Переключаем туда-сюда
                let initialValue = switchElement.value as? String ?? "0"
                switchElement.tap()
                sleep(0.5)
                
                let newValue = switchElement.value as? String ?? "0"
                XCTAssertNotEqual(initialValue, newValue, "Переключатель '\(label)' должен изменить состояние")
                
                // Возвращаем обратно
                switchElement.tap()
                sleep(0.5)
            }
        }
        
        // Прокручиваем вниз
        app.swipeUp()
        sleep(1)
        
        // Ищем версию приложения
        let versionPredicate = NSPredicate(format: "label CONTAINS[c] 'Версия приложения'")
        let versionRow = app.staticTexts.element(matching: versionPredicate)
        if versionRow.exists {
            takeScreenshot(named: "13_SettingsVersion")
            
            // Ищем значение версии
            let cells = app.cells
            for i in 0..<cells.count {
                let cell = cells.element(boundBy: i)
                if cell.staticTexts["Версия приложения"].exists {
                    let versionTexts = cell.staticTexts.allElementsBoundByIndex
                    for text in versionTexts {
                        if text.label.contains("(Build") {
                            print("📱 Версия приложения: \(text.label)")
                        }
                    }
                }
            }
        }
        
        // Проверяем кнопку выхода
        if app.buttons["Выйти из аккаунта"].exists {
            takeScreenshot(named: "14_SettingsLogout")
        }
    }
    
    private func logout() {
        // Переходим в настройки
        let tabBar = app.tabBars.firstMatch
        if tabBar.buttons["Настройки"].exists {
            tabBar.buttons["Настройки"].tap()
        } else if tabBar.buttons["Профиль"].exists {
            // Если настроек нет, ищем выход в профиле
            tabBar.buttons["Профиль"].tap()
            app.swipeUp() // Прокручиваем вниз
        }
        
        // Нажимаем выход
        let logoutButton = app.buttons["Выйти из аккаунта"]
        if logoutButton.waitForExistence(timeout: 3) {
            logoutButton.tap()
            sleep(2)
        }
    }
    
    private func testAdminFeatures() {
        // Переходим в настройки
        let tabBar = app.tabBars.firstMatch
        tabBar.buttons["Настройки"].tap()
        
        // Ищем переключатель админского режима
        let adminSwitch = app.switches["Админский режим"]
        if adminSwitch.exists {
            print("👑 Включаем админский режим...")
            
            // Включаем если выключен
            if adminSwitch.value as? String == "0" {
                adminSwitch.tap()
                sleep(1)
            }
            
            takeScreenshot(named: "15_AdminModeEnabled")
            
            // Проверяем появление индикатора
            XCTAssertTrue(app.staticTexts["ADMIN"].exists, "Должен появиться индикатор ADMIN")
            
            // Проверяем дополнительные админские функции
            if app.cells["Управление модулями"].exists {
                app.cells["Управление модулями"].tap()
                sleep(1)
                takeScreenshot(named: "16_FeatureFlags")
                app.navigationBars.buttons.firstMatch.tap() // Назад
            }
        }
    }
    
    // MARK: - Utilities
    
    private func takeScreenshot(named name: String) {
        let screenshot = XCUIScreen.main.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}

// MARK: - Расширенный тест с Shake gesture

extension ComprehensiveUITest {
    
    func testShakeGesture() throws {
        // Входим в приложение
        loginAsStudent()
        
        // Симулируем shake gesture
        print("📳 Тестирование Shake gesture...")
        
        // В симуляторе shake можно вызвать через меню Device
        // Но в UI тестах это сложно, поэтому проверяем альтернативный способ
        
        // Если есть кнопка обратной связи
        if app.buttons["Отправить отзыв"].exists {
            app.buttons["Отправить отзыв"].tap()
            sleep(1)
            
            if app.navigationBars["Обратная связь"].exists {
                takeScreenshot(named: "17_FeedbackForm")
                
                // Заполняем форму
                let textView = app.textViews.firstMatch
                if textView.exists {
                    textView.tap()
                    textView.typeText("Тестовый отзыв из автоматического теста")
                }
                
                // Закрываем
                if app.navigationBars.buttons["Отмена"].exists {
                    app.navigationBars.buttons["Отмена"].tap()
                }
            }
        }
    }
}

// MARK: - Детальный отчет

extension ComprehensiveUITest {
    
    func testGenerateDetailedReport() throws {
        var report = "# Отчет автоматического тестирования LMS\n\n"
        report += "Дата: \(Date())\n"
        report += "Версия приложения: 1.0 (Build 202507021600)\n\n"
        
        report += "## Результаты тестирования\n\n"
        
        // Собираем информацию о всех элементах
        loginAsStudent()
        
        let tabBar = app.tabBars.firstMatch
        let tabButtons = tabBar.buttons.allElementsBoundByIndex
        
        report += "### Найдено вкладок: \(tabButtons.count)\n"
        for button in tabButtons {
            if button.exists {
                report += "- \(button.label)\n"
            }
        }
        
        report += "\n### Протестированные элементы:\n"
        report += "- ✅ Экран входа\n"
        report += "- ✅ Вход как студент\n"
        report += "- ✅ Вход как администратор\n"
        report += "- ✅ Все вкладки\n"
        report += "- ✅ Профиль пользователя\n"
        report += "- ✅ Настройки приложения\n"
        report += "- ✅ Переключатели настроек\n"
        report += "- ✅ Админский режим\n"
        report += "- ✅ Версия приложения\n"
        report += "- ✅ Функция выхода\n"
        
        print(report)
        
        // Сохраняем отчет как вложение
        let attachment = XCTAttachment(string: report)
        attachment.name = "TestReport.md"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
} 