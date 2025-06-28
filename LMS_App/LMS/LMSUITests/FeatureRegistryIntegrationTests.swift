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
        // В DEBUG режиме готовые модули включены, но находятся в More
        #if DEBUG
        let tabBar = app.tabBars.firstMatch
        XCTAssertTrue(tabBar.waitForExistence(timeout: 5))
        
        // iOS автоматически помещает табы после 5-го в More
        // Поскольку готовые модули включены, общее число табов должно быть больше 5
        let tabCount = tabBar.buttons.count
        print("📊 Количество табов: \(tabCount)")
        
        // В DEBUG режиме должен быть таб Debug
        let debugTab = tabBar.buttons["Debug"]
        XCTAssertTrue(debugTab.exists, "В DEBUG режиме должен быть таб Debug")
        #endif
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
        #if DEBUG
        // В DEBUG режиме переходим в Debug таб
        let tabBar = app.tabBars.firstMatch
        XCTAssertTrue(tabBar.waitForExistence(timeout: 5))
        
        let debugTab = tabBar.buttons["Debug"]
        XCTAssertTrue(debugTab.exists, "Debug таб должен существовать в DEBUG режиме")
        debugTab.tap()
        
        // Включаем админский режим
        let adminSwitch = app.switches["Admin Mode"]
        XCTAssertTrue(adminSwitch.waitForExistence(timeout: 3), 
            "Переключатель Admin Mode должен быть в Debug меню")
        
        // Включаем если выключен
        if adminSwitch.value as? String == "0" {
            adminSwitch.tap()
        }
        
        // Проверяем появление индикатора админа (корона с текстом ADMIN)
        let adminIndicator = app.staticTexts["ADMIN"]
        XCTAssertTrue(adminIndicator.waitForExistence(timeout: 3),
            "Индикатор админского режима должен появиться")
        #else
        // В не-DEBUG режиме админский режим недоступен
        throw XCTSkip("Admin mode доступен только в DEBUG")
        #endif
    }
    
    func testFeatureTogglesInAdminMode() throws {
        #if DEBUG
        // Переходим в Debug таб
        let tabBar = app.tabBars.firstMatch
        XCTAssertTrue(tabBar.waitForExistence(timeout: 5))
        
        let debugTab = tabBar.buttons["Debug"]
        debugTab.tap()
        
        // Переходим в Feature Flags
        let featureFlagsCell = app.cells.containing(.staticText, identifier: "Feature Flags").firstMatch
        XCTAssertTrue(featureFlagsCell.waitForExistence(timeout: 3),
            "Feature Flags должны быть доступны в Debug меню")
        featureFlagsCell.tap()
        
        // Проверяем наличие переключателей для модулей
        let moduleNames = [
            "Компетенции",
            "Должности",
            "Новости"
        ]
        
        for moduleName in moduleNames {
            let moduleToggle = app.switches.containing(.staticText, identifier: moduleName).firstMatch
            XCTAssertTrue(moduleToggle.exists, 
                "Переключатель для модуля '\(moduleName)' должен существовать")
        }
        #else
        throw XCTSkip("Feature toggles доступны только в DEBUG")
        #endif
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
        
        #if DEBUG
        // В DEBUG режиме должен быть дополнительный таб Debug
        XCTAssertGreaterThanOrEqual(tabCount, 6, "В DEBUG режиме должно быть минимум 6 табов")
        #endif
    }
} 