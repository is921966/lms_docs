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
        
        // Основные модули, которые должны быть всегда видны
        let expectedTabs = [
            "Пользователи",
            "Курсы", 
            "Тесты",
            "Аналитика",
            "Онбординг",
            "Еще"  // More tab
        ]
        
        for tabName in expectedTabs {
            let tab = tabBar.buttons[tabName]
            XCTAssertTrue(tab.exists, "Таб '\(tabName)' должен существовать")
        }
    }
    
    func testReadyModulesAreAccessibleInDebug() throws {
        // В DEBUG режиме должны быть включены дополнительные модули
        #if DEBUG
        let tabBar = app.tabBars.firstMatch
        XCTAssertTrue(tabBar.waitForExistence(timeout: 5))
        
        // Проверяем новые модули
        let newModules = ["Компетенции", "Должности", "Новости"]
        
        for moduleName in newModules {
            let tab = tabBar.buttons[moduleName]
            XCTAssertTrue(tab.exists, "Модуль '\(moduleName)' должен быть доступен в DEBUG")
        }
        #endif
    }
    
    func testNavigationToEachModule() throws {
        let tabBar = app.tabBars.firstMatch
        XCTAssertTrue(tabBar.waitForExistence(timeout: 5))
        
        // Тестируем навигацию к каждому модулю
        let modules = [
            ("Курсы", "Курсы"),
            ("Тесты", "Тесты"),
            ("Аналитика", "Аналитика"),
            ("Онбординг", "Мои программы онбординга")
        ]
        
        for (tabName, expectedTitle) in modules {
            let tab = tabBar.buttons[tabName]
            if tab.exists {
                tab.tap()
                
                // Проверяем, что навигация произошла
                let navBar = app.navigationBars[expectedTitle]
                XCTAssertTrue(navBar.waitForExistence(timeout: 3), 
                    "После нажатия на '\(tabName)' должен показаться экран '\(expectedTitle)'")
            }
        }
    }
    
    func testAdminModeToggle() throws {
        // Переходим в настройки
        let tabBar = app.tabBars.firstMatch
        XCTAssertTrue(tabBar.waitForExistence(timeout: 5))
        
        let moreTab = tabBar.buttons["Еще"]
        XCTAssertTrue(moreTab.exists)
        moreTab.tap()
        
        // Находим настройки
        let settingsCell = app.cells.containing(.staticText, identifier: "Настройки").firstMatch
        XCTAssertTrue(settingsCell.waitForExistence(timeout: 3))
        settingsCell.tap()
        
        // Проверяем наличие переключателя админского режима
        let adminSwitch = app.switches["Режим администратора"]
        XCTAssertTrue(adminSwitch.waitForExistence(timeout: 3), 
            "Переключатель админского режима должен быть в настройках")
        
        // Включаем админский режим
        if adminSwitch.value as? String == "0" {
            adminSwitch.tap()
        }
        
        // Возвращаемся назад
        app.navigationBars.buttons.firstMatch.tap()
        
        // Проверяем появление индикатора админа
        let adminIndicator = app.images["crown.fill"]
        XCTAssertTrue(adminIndicator.waitForExistence(timeout: 3),
            "Индикатор админского режима (корона) должен появиться")
    }
    
    func testFeatureTogglesInAdminMode() throws {
        // Сначала включаем админский режим
        try testAdminModeToggle()
        
        // Переходим в настройки модулей
        let tabBar = app.tabBars.firstMatch
        let moreTab = tabBar.buttons["Еще"]
        moreTab.tap()
        
        let settingsCell = app.cells.containing(.staticText, identifier: "Настройки").firstMatch
        settingsCell.tap()
        
        // Ищем Feature Flags
        let featureFlagsCell = app.cells.containing(.staticText, identifier: "Feature Flags").firstMatch
        XCTAssertTrue(featureFlagsCell.waitForExistence(timeout: 3),
            "Feature Flags должны быть доступны в админском режиме")
        featureFlagsCell.tap()
        
        // Проверяем наличие всех модулей
        let allModules = [
            "Пользователи",
            "Курсы",
            "Тесты", 
            "Аналитика",
            "Онбординг",
            "Компетенции",
            "Должности",
            "Новости",
            "Сертификаты",
            "Геймификация",
            "Уведомления"
        ]
        
        for moduleName in allModules {
            let moduleToggle = app.switches[moduleName]
            XCTAssertTrue(moduleToggle.exists, 
                "Переключатель для модуля '\(moduleName)' должен существовать")
        }
    }
    
    func testModuleIntegrationStatus() throws {
        // Этот тест проверяет, что все объявленные модули правильно интегрированы
        let tabBar = app.tabBars.firstMatch
        XCTAssertTrue(tabBar.waitForExistence(timeout: 5))
        
        // Получаем количество табов
        let tabCount = tabBar.buttons.count
        XCTAssertGreaterThan(tabCount, 5, "Должно быть больше 5 табов (базовые + новые модули)")
        
        // В DEBUG режиме с включенными модулями должно быть 9 табов
        #if DEBUG
        XCTAssertEqual(tabCount, 9, "В DEBUG режиме должно быть 9 табов")
        #endif
    }
} 