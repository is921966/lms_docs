//
//  BasicLoginTest.swift
//  LMSUITests
//
//  Минимальный тест для проверки запуска
//

import XCTest

final class BasicLoginTest: XCTestCase {
    
    func testJustLaunchApp() {
        // Самый простой тест - просто запускаем приложение
        let app = XCUIApplication()
        app.launch()
        
        // Ждем секунду
        sleep(1)
        
        // Проверяем, что приложение запустилось
        XCTAssertTrue(app.state == .runningForeground, "App should be running")
        print("✅ App launched successfully")
    }
} 