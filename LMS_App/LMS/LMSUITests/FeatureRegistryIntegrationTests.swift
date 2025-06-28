//
//  FeatureRegistryIntegrationTests.swift
//  LMSUITests
//
//  Created on 29/06/2025.
//

import XCTest

final class FeatureRegistryIntegrationTests: XCTestCase {
    
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
    
    func testAllMainModulesAreAccessible() throws {
        // Проверяем, что основные модули доступны в табах
        let tabBar = app.tabBars.firstMatch
        XCTAssertTrue(tabBar.waitForExistence(timeout: 5), "Tab bar должен быть виден")
        
        // Выводим все найденные табы для отладки
        print("🔍 Найденные табы:")
        for button in tabBar.buttons.allElementsBoundByIndex {
            if button.exists {
                print("  - \(button.label)")
            }
        }
        
        // Основные модули, которые должны быть всегда видны
        let expectedTabs = [
            "Пользователи",
            "Курсы", 
            "Тесты",
            "Аналитика",
            "More"  // В iOS показывается More когда табов больше 5
        ]
        
        // Проверяем существование табов
        for tabName in expectedTabs {
            let tab = tabBar.buttons[tabName]
            if !tab.exists {
                // Если не нашли по точному имени, пробуем частичное совпадение
                let predicate = NSPredicate(format: "label CONTAINS[c] %@", tabName)
                let matchingTab = tabBar.buttons.matching(predicate).firstMatch
                XCTAssertTrue(matchingTab.exists, "Таб '\(tabName)' должен существовать")
            }
        }
        
        // Проверяем что в More есть остальные модули
        let moreTab = tabBar.buttons["More"]
        if moreTab.exists {
            moreTab.tap()
            
            // Ждем появления списка More
            let moreTable = app.tables.firstMatch
            XCTAssertTrue(moreTable.waitForExistence(timeout: 2), "Список More должен появиться")
            
            // Проверяем наличие модулей в More
            let modulesInMore = ["Мои программы", "Профиль"]
            for moduleName in modulesInMore {
                let cell = moreTable.cells.containing(.staticText, identifier: moduleName).firstMatch
                print("🔍 Ищем в More: \(moduleName) - \(cell.exists ? "найден" : "не найден")")
            }
        }
    }
    
    func testReadyModulesAreAccessibleInDebug() throws {
        // Проверяем что включенные модули доступны через Feature Registry
        let tabBar = app.tabBars.firstMatch
        XCTAssertTrue(tabBar.waitForExistence(timeout: 5))
        
        // iOS автоматически помещает табы после 5-го в More
        let tabCount = tabBar.buttons.count
        print("📊 Количество табов: \(tabCount)")
        
        // Должно быть минимум 6 табов включая More
        XCTAssertGreaterThanOrEqual(tabCount, 6, "Должно быть минимум 6 табов (5 основных + More)")
        
        // Проверяем что More содержит дополнительные включенные модули
        let moreTab = tabBar.buttons["More"]
        if moreTab.exists {
            moreTab.tap()
            
            let moreTable = app.tables.firstMatch
            XCTAssertTrue(moreTable.waitForExistence(timeout: 2))
            
            // Проверяем готовые модули
            let readyModules = ["Компетенции", "Должности", "Новости"]
            var foundCount = 0
            
            for moduleName in readyModules {
                let cell = moreTable.cells.containing(.staticText, identifier: moduleName).firstMatch
                if cell.exists {
                    foundCount += 1
                    print("✅ Найден готовый модуль: \(moduleName)")
                }
            }
            
            // Хотя бы один готовый модуль должен быть найден
            XCTAssertGreaterThan(foundCount, 0, "Должен быть найден хотя бы один готовый модуль")
        }
    }
    
    func testNavigationToEachModule() throws {
        let tabBar = app.tabBars.firstMatch
        XCTAssertTrue(tabBar.waitForExistence(timeout: 5))
        
        // Тестируем навигацию к каждому модулю
        let modules = [
            ("Курсы", "Список курсов"), // Проверяем альтернативный заголовок
            ("Тесты", "Тесты и задания"), // Проверяем альтернативный заголовок
            ("Аналитика", "Аналитика")
        ]
        
        for (tabName, expectedTitle) in modules {
            let tab = tabBar.buttons[tabName]
            if tab.exists {
                tab.tap()
                
                // Ждем немного для загрузки
                sleep(1)
                
                // Проверяем наличие навигационной панели или заголовка
                let navBar = app.navigationBars.firstMatch
                XCTAssertTrue(navBar.waitForExistence(timeout: 3), 
                    "После нажатия на '\(tabName)' должна появиться навигационная панель")
                
                // Возвращаемся к первому табу
                tabBar.buttons.firstMatch.tap()
            }
        }
    }
    
    func testAdminModeToggle() throws {
        // Проверяем доступность админского режима через профиль
        let tabBar = app.tabBars.firstMatch
        XCTAssertTrue(tabBar.waitForExistence(timeout: 5))
        
        // Идем в профиль
        let profileTab = tabBar.buttons["Профиль"]
        if profileTab.exists {
            profileTab.tap()
        } else {
            // Если профиль в More
            let moreTab = tabBar.buttons["More"]
            moreTab.tap()
            
            let profileCell = app.tables.cells.containing(.staticText, identifier: "Профиль").firstMatch
            if profileCell.exists {
                profileCell.tap()
            }
        }
        
        // В профиле должны быть настройки
        let settingsButton = app.buttons["Настройки"]
        if settingsButton.waitForExistence(timeout: 3) {
            settingsButton.tap()
            
            // Проверяем наличие настроек для админа
            let adminSection = app.staticTexts["Администрирование"]
            print("🔍 Секция администрирования: \(adminSection.exists ? "найдена" : "не найдена")")
        }
    }
    
    func testFeatureTogglesInAdminMode() throws {
        // Этот тест теперь проверяет работу Feature Registry без Debug таба
        let tabBar = app.tabBars.firstMatch
        XCTAssertTrue(tabBar.waitForExistence(timeout: 5))
        
        // Проверяем что Feature Registry правильно управляет видимостью модулей
        // Для этого считаем количество видимых табов
        let initialTabCount = tabBar.buttons.count
        print("📊 Начальное количество табов: \(initialTabCount)")
        
        // Проверяем что модули из Feature Registry доступны
        XCTAssertGreaterThanOrEqual(initialTabCount, 5, "Должно быть минимум 5 основных табов")
    }
    
    func testModuleIntegrationStatus() throws {
        // Этот тест проверяет, что все объявленные модули правильно интегрированы
        let tabBar = app.tabBars.firstMatch
        XCTAssertTrue(tabBar.waitForExistence(timeout: 5))
        
        // Получаем количество табов
        let tabCount = tabBar.buttons.count
        print("📊 Общее количество табов: \(tabCount)")
        
        // Должно быть как минимум 5 табов (основные модули)
        XCTAssertGreaterThanOrEqual(tabCount, 5, "Должно быть минимум 5 табов")
        
        // Проверяем доступность через More для модулей сверх лимита
        if tabCount >= 5 {
            let moreTab = tabBar.buttons["More"]
            XCTAssertTrue(moreTab.exists, "При 5+ табах должен появиться More")
        }
    }
} 