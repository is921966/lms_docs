import Foundation
import XCTest

/// Helper для работы с Cmi5 тестовыми данными
class Cmi5TestHelper {
    
    /// Пути к тестовым Cmi5 пакетам
    enum TestPackage: String, CaseIterable {
        case aiFluency = "ai_fluency_course_v1.0.zip"
        case corporateCulture = "corporate_culture_tsum_v1.0.zip"
        
        var displayName: String {
            switch self {
            case .aiFluency:
                return "AI Fluency: Mastering Artificial Intelligence"
            case .corporateCulture:
                return "Корпоративная культура ЦУМ"
            }
        }
        
        var description: String {
            switch self {
            case .aiFluency:
                return "Comprehensive course on AI fundamentals and applications"
            case .corporateCulture:
                return "Введение в корпоративную культуру ЦУМ"
            }
        }
        
        /// Получить URL тестового пакета
        var url: URL? {
            let bundle = Bundle(for: Cmi5TestHelper.self)
            return bundle.url(forResource: rawValue.replacingOccurrences(of: ".zip", with: ""), 
                            withExtension: "zip",
                            subdirectory: "TestData/Cmi5Packages")
        }
    }
    
    /// Проверить доступность всех тестовых пакетов
    static func verifyTestPackages() -> Bool {
        for package in TestPackage.allCases {
            guard let url = package.url, FileManager.default.fileExists(atPath: url.path) else {
                print("❌ Тестовый пакет не найден: \(package.rawValue)")
                return false
            }
            print("✅ Тестовый пакет найден: \(package.displayName)")
        }
        return true
    }
    
    /// Загрузить тестовый пакет в приложение (mock)
    static func mockUploadPackage(_ package: TestPackage, in app: XCUIApplication) {
        // Эмулируем загрузку пакета через UI
        // В реальном приложении это будет file picker
        
        // Нажимаем кнопку загрузки
        app.buttons["Загрузить пакет"].tap()
        
        // В тестовом режиме выбираем из предустановленных
        let picker = app.sheets.firstMatch
        XCTAssertTrue(picker.waitForExistence(timeout: 5))
        
        // Выбираем нужный пакет
        picker.buttons[package.displayName].tap()
        
        // Ждем загрузки
        let progressIndicator = app.progressIndicators.firstMatch
        if progressIndicator.exists {
            // Ждем пока индикатор исчезнет (макс 30 сек)
            XCTAssertTrue(progressIndicator.waitForNonExistence(timeout: 30))
        }
    }
}

/// Расширение для UI тестов с Cmi5
extension XCTestCase {
    
    /// Подготовить Cmi5 тестовое окружение
    func setupCmi5TestEnvironment(in app: XCUIApplication) {
        // Проверяем наличие тестовых пакетов
        XCTAssertTrue(Cmi5TestHelper.verifyTestPackages(), 
                     "Cmi5 тестовые пакеты должны быть доступны")
        
        // Включаем Cmi5 модуль если нужно
        if !app.buttons["Cmi5 Контент"].exists {
            // Переходим в настройки
            app.tabBars.buttons["Ещё"].tap()
            app.buttons["Настройки"].tap()
            app.buttons["Feature Flags"].tap()
            
            // Включаем Cmi5
            let cmi5Toggle = app.switches["Cmi5 Контент"]
            if cmi5Toggle.exists && cmi5Toggle.value as? String == "0" {
                cmi5Toggle.tap()
            }
            
            // Возвращаемся
            app.navigationBars.buttons.firstMatch.tap()
            app.navigationBars.buttons.firstMatch.tap()
        }
    }
    
    /// Перейти к Cmi5 модулю
    func navigateToCmi5(in app: XCUIApplication) {
        // Проверяем, есть ли Cmi5 в табах
        if app.tabBars.buttons["Cmi5 Контент"].exists {
            app.tabBars.buttons["Cmi5 Контент"].tap()
        } else {
            // Иначе ищем в меню "Ещё"
            app.tabBars.buttons["Ещё"].tap()
            
            let cmi5Button = app.buttons["Cmi5 Контент"]
            XCTAssertTrue(cmi5Button.waitForExistence(timeout: 5))
            cmi5Button.tap()
        }
        
        // Ждем загрузки Cmi5 экрана
        XCTAssertTrue(app.navigationBars["Cmi5 Контент"].waitForExistence(timeout: 5))
    }
}
