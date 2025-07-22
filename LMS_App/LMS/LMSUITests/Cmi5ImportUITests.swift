import XCTest

/// UI тесты для импорта Cmi5 пакетов
final class Cmi5ImportUITests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        
        app = XCUIApplication()
        app.launchArguments = ["UI_TESTING", "MOCK_AUTH"]
        app.launch()
    }
    
    override func tearDownWithError() throws {
        app = nil
    }
    
    // MARK: - Test Cases
    
    func testCmi5ImportFlow() throws {
        // Переходим в раздел Обучение
        app.tabBars.buttons["Обучение"].tap()
        
        // Ждем загрузки экрана
        XCTAssertTrue(app.navigationBars["Обучение"].waitForExistence(timeout: 5))
        
        // Находим и нажимаем кнопку Управление Cmi5
        let cmi5Button = app.buttons["Управление Cmi5"]
        XCTAssertTrue(cmi5Button.waitForExistence(timeout: 5))
        cmi5Button.tap()
        
        // Проверяем, что открылся экран управления Cmi5
        XCTAssertTrue(app.navigationBars["Управление Cmi5"].waitForExistence(timeout: 5))
        
        // Нажимаем кнопку импорта
        let importButton = app.navigationBars.buttons["plus"]
        XCTAssertTrue(importButton.exists)
        importButton.tap()
        
        // Проверяем, что открылся экран импорта
        XCTAssertTrue(app.navigationBars["Импорт Cmi5 пакета"].waitForExistence(timeout: 5))
        
        // Нажимаем кнопку выбора файла
        let selectFileButton = app.buttons["Выбрать файл"]
        XCTAssertTrue(selectFileButton.exists)
        selectFileButton.tap()
        
        // В UI тестах мы не можем реально выбрать файл из системы
        // Поэтому проверяем, что кнопка работает
        
        // Проверяем наличие демо кнопки (для тестирования)
        let demoButton = app.buttons["Использовать демо пакет"]
        if demoButton.exists {
            demoButton.tap()
            
            // Ждем обработки
            let processingIndicator = app.activityIndicators.firstMatch
            if processingIndicator.exists {
                // Ждем завершения обработки (максимум 10 секунд)
                let predicate = NSPredicate(format: "exists == false")
                expectation(for: predicate, evaluatedWith: processingIndicator)
                waitForExpectations(timeout: 10)
            }
            
            // Проверяем, что появилась информация о пакете
            XCTAssertTrue(app.staticTexts["Демо курс Cmi5"].exists)
            
            // Нажимаем кнопку импорта
            let importPackageButton = app.buttons["Импортировать"]
            XCTAssertTrue(importPackageButton.exists)
            XCTAssertTrue(importPackageButton.isEnabled)
            importPackageButton.tap()
            
            // Ждем завершения импорта
            sleep(3)
            
            // Проверяем, что вернулись на экран управления
            XCTAssertTrue(app.navigationBars["Управление Cmi5"].waitForExistence(timeout: 5))
            
            // Проверяем, что пакет появился в списке
            XCTAssertTrue(app.cells.containing(.staticText, identifier: "Демо курс Cmi5").element.exists)
        }
    }
    
    func testCmi5PackageListDisplay() throws {
        // Переходим в Управление Cmi5
        navigateToCmi5Management()
        
        // Проверяем элементы интерфейса
        XCTAssertTrue(app.navigationBars["Управление Cmi5"].exists)
        
        // Проверяем наличие списка или сообщения о пустом списке
        let emptyMessage = app.staticTexts["Нет загруженных Cmi5 пакетов"]
        let packageList = app.tables.firstMatch
        
        XCTAssertTrue(emptyMessage.exists || packageList.exists)
        
        // Если есть пакеты, проверяем их отображение
        if packageList.exists && packageList.cells.count > 0 {
            let firstCell = packageList.cells.element(boundBy: 0)
            XCTAssertTrue(firstCell.exists)
            
            // Проверяем наличие основных элементов в ячейке
            XCTAssertTrue(firstCell.staticTexts.count >= 2) // Название и описание
        }
    }
    
    func testCmi5ImportValidation() throws {
        // Переходим к импорту
        navigateToCmi5Import()
        
        // Проверяем, что кнопка импорта изначально недоступна
        let importButton = app.buttons["Импортировать"]
        XCTAssertTrue(importButton.exists)
        XCTAssertFalse(importButton.isEnabled)
        
        // Проверяем отображение инструкций
        XCTAssertTrue(app.staticTexts.containing(NSPredicate(format: "label CONTAINS 'ZIP архив'")).element.exists)
    }
    
    // MARK: - Helper Methods
    
    private func navigateToCmi5Management() {
        app.tabBars.buttons["Обучение"].tap()
        
        let cmi5Button = app.buttons["Управление Cmi5"]
        XCTAssertTrue(cmi5Button.waitForExistence(timeout: 5))
        cmi5Button.tap()
        
        XCTAssertTrue(app.navigationBars["Управление Cmi5"].waitForExistence(timeout: 5))
    }
    
    private func navigateToCmi5Import() {
        navigateToCmi5Management()
        
        let importButton = app.navigationBars.buttons["plus"]
        XCTAssertTrue(importButton.exists)
        importButton.tap()
        
        XCTAssertTrue(app.navigationBars["Импорт Cmi5 пакета"].waitForExistence(timeout: 5))
    }
} 