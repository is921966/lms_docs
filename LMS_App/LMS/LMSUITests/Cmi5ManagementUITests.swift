import XCTest

final class Cmi5ManagementUITests: UITestBase {
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        // Login as admin
        loginAsAdmin()
        
        // Navigate to Cmi5 Management
        navigateToCmi5Management()
    }
    
    // MARK: - Helper Methods
    
    private func loginAsAdmin() {
        // Wait for login screen
        let emailField = app.textFields["Email"]
        XCTAssertTrue(emailField.waitForExistence(timeout: 5))
        
        // Enter admin credentials
        emailField.tap()
        emailField.typeText("admin@test.com")
        
        let passwordField = app.secureTextFields["Пароль"]
        passwordField.tap()
        passwordField.typeText("password")
        
        // Login
        app.buttons["Войти"].tap()
        
        // Wait for main screen
        XCTAssertTrue(app.navigationBars["Главная"].waitForExistence(timeout: 5))
    }
    
    private func navigateToCmi5Management() {
        // Navigate to More tab
        app.tabBars.buttons["Ещё"].tap()
        
        // Find and tap "Cmi5 Контент"
        let cmi5Cell = app.buttons.containing(.staticText, identifier: "Cmi5 Контент").firstMatch
        XCTAssertTrue(cmi5Cell.waitForExistence(timeout: 5))
        cmi5Cell.tap()
        
        // Wait for Cmi5 management screen
        XCTAssertTrue(app.navigationBars["Управление Cmi5"].waitForExistence(timeout: 5))
    }
    
    // MARK: - Test Cases
    
    func testCmi5ListDisplay() throws {
        // Verify Cmi5 package list is displayed
        XCTAssertTrue(app.scrollViews.firstMatch.exists)
        
        // Check for search field
        let searchField = app.textFields["Поиск пакетов"]
        XCTAssertTrue(searchField.exists)
        
        // Check for import button
        let importButton = app.buttons["Импортировать пакет"]
        XCTAssertTrue(importButton.exists)
        
        // Verify statistics are shown
        XCTAssertTrue(app.staticTexts["Всего пакетов:"].exists)
        XCTAssertTrue(app.staticTexts["Активных:"].exists)
    }
    
    func testCmi5PackageImport() throws {
        // Tap import button
        app.buttons["Импортировать пакет"].tap()
        
        // Wait for import dialog
        XCTAssertTrue(app.navigationBars["Импорт Cmi5 пакета"].waitForExistence(timeout: 5))
        
        // Select file source
        app.buttons["Выбрать файл"].tap()
        
        // In real test, we would interact with file picker
        // For now, simulate file selection
        app.buttons["Использовать пример"].tap()
        
        // Fill package details
        let titleField = app.textFields["Название пакета"]
        titleField.tap()
        titleField.typeText("Тестовый Cmi5 курс")
        
        let descriptionField = app.textViews["Описание"]
        descriptionField.tap()
        descriptionField.typeText("Описание тестового Cmi5 пакета")
        
        // Start import
        app.buttons["Импортировать"].tap()
        
        // Wait for progress
        XCTAssertTrue(app.progressIndicators.firstMatch.waitForExistence(timeout: 5))
        
        // Wait for completion
        XCTAssertTrue(app.alerts["Успешно"].waitForExistence(timeout: 30))
        app.alerts.buttons["OK"].tap()
        
        // Verify package appears in list
        XCTAssertTrue(app.staticTexts["Тестовый Cmi5 курс"].exists)
    }
    
    func testCmi5PackageValidation() throws {
        // Import invalid package
        app.buttons["Импортировать пакет"].tap()
        
        // Select invalid file
        app.buttons["Выбрать файл"].tap()
        app.buttons["Использовать невалидный пример"].tap()
        
        // Try to import
        app.buttons["Импортировать"].tap()
        
        // Verify validation error
        XCTAssertTrue(app.alerts["Ошибка валидации"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] %@", "manifest.xml")).firstMatch.exists)
        
        app.alerts.buttons["OK"].tap()
    }
    
    func testCmi5PackagePreview() throws {
        // Find and tap on a package
        let firstPackage = app.cells.firstMatch
        XCTAssertTrue(firstPackage.waitForExistence(timeout: 5))
        firstPackage.tap()
        
        // Wait for preview screen
        XCTAssertTrue(app.navigationBars["Детали пакета"].waitForExistence(timeout: 5))
        
        // Verify package info is displayed
        XCTAssertTrue(app.staticTexts["Информация о пакете"].exists)
        XCTAssertTrue(app.staticTexts["Структура контента"].exists)
        XCTAssertTrue(app.staticTexts["Активности"].exists)
        
        // Check for launch button
        XCTAssertTrue(app.buttons["Запустить"].exists)
    }
    
    func testCmi5PlayerLaunch() throws {
        // Open package details
        let firstPackage = app.cells.firstMatch
        firstPackage.tap()
        
        // Launch player
        app.buttons["Запустить"].tap()
        
        // Wait for player to load
        XCTAssertTrue(app.webViews.firstMatch.waitForExistence(timeout: 10))
        
        // Verify player controls
        XCTAssertTrue(app.buttons["Пауза"].exists || app.buttons["Продолжить"].exists)
        XCTAssertTrue(app.buttons["Выход"].exists)
        
        // Check progress indicator
        XCTAssertTrue(app.progressIndicators["Прогресс"].exists)
    }
    
    func testCmi5StatementTracking() throws {
        // Open package details
        let firstPackage = app.cells.firstMatch
        firstPackage.tap()
        
        // Navigate to analytics
        app.buttons["Аналитика"].tap()
        
        // Verify statement list
        XCTAssertTrue(app.tables["Statements"].waitForExistence(timeout: 5))
        
        // Check for statement types
        XCTAssertTrue(app.staticTexts["initialized"].exists || app.staticTexts["Нет данных"].exists)
        
        // If statements exist, verify details
        if app.cells.count > 0 {
            app.cells.firstMatch.tap()
            XCTAssertTrue(app.staticTexts["Actor"].exists)
            XCTAssertTrue(app.staticTexts["Verb"].exists)
            XCTAssertTrue(app.staticTexts["Object"].exists)
        }
    }
    
    func testCmi5OfflineMode() throws {
        // Enable offline mode
        app.switches["Offline режим"].tap()
        
        // Open package
        let firstPackage = app.cells.firstMatch
        firstPackage.tap()
        
        // Launch in offline mode
        app.buttons["Запустить"].tap()
        
        // Verify offline indicator
        XCTAssertTrue(app.staticTexts["Offline"].exists)
        
        // Complete some activity
        // ... simulate activity completion ...
        
        // Exit player
        app.buttons["Выход"].tap()
        
        // Check pending sync indicator
        XCTAssertTrue(app.staticTexts["Ожидает синхронизации"].exists)
        
        // Disable offline mode to trigger sync
        app.switches["Offline режим"].tap()
        
        // Verify sync starts
        XCTAssertTrue(app.progressIndicators["Синхронизация"].waitForExistence(timeout: 5))
    }
    
    func testCmi5PackageSearch() throws {
        let searchField = app.textFields["Поиск пакетов"]
        searchField.tap()
        searchField.typeText("Безопасность")
        
        // Wait for search results
        sleep(1)
        
        // Verify filtered results
        XCTAssertTrue(app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] %@", "Безопасность")).firstMatch.exists)
        
        // Clear search
        if searchField.buttons["Clear text"].exists {
            searchField.buttons["Clear text"].tap()
        } else {
            clearAndTypeText(searchField, text: "")
        }
        
        // Verify all packages shown again
        sleep(1)
        XCTAssertTrue(app.cells.count > 1)
    }
    
    func testCmi5PackageExport() throws {
        // Open package details
        let firstPackage = app.cells.firstMatch
        firstPackage.tap()
        
        // Open more options
        app.buttons["Ещё"].tap()
        
        // Select export
        app.buttons["Экспортировать отчет"].tap()
        
        // Select format
        app.buttons["PDF"].tap()
        
        // Configure export options
        app.switches["Включить детали"].tap()
        app.switches["Включить статистику"].tap()
        
        // Export
        app.buttons["Экспортировать"].tap()
        
        // Verify success
        XCTAssertTrue(app.alerts["Экспорт завершен"].waitForExistence(timeout: 10))
        app.alerts.buttons["OK"].tap()
    }
    
    func testCmi5PackageDelete() throws {
        // Create test package first
        app.buttons["Импортировать пакет"].tap()
        app.buttons["Использовать пример"].tap()
        
        let titleField = app.textFields["Название пакета"]
        titleField.tap()
        titleField.typeText("Пакет для удаления")
        
        app.buttons["Импортировать"].tap()
        app.alerts.buttons["OK"].tap()
        
        // Find the package
        let searchField = app.textFields["Поиск пакетов"]
        searchField.tap()
        searchField.typeText("Пакет для удаления")
        
        sleep(1)
        
        // Open package
        app.cells.firstMatch.tap()
        
        // Delete package
        app.buttons["Удалить пакет"].tap()
        
        // Confirm deletion
        app.alerts["Подтверждение"].buttons["Удалить"].tap()
        
        // Verify package was deleted
        XCTAssertTrue(app.navigationBars["Управление Cmi5"].waitForExistence(timeout: 5))
        XCTAssertFalse(app.staticTexts["Пакет для удаления"].exists)
    }
    
    func testCmi5Analytics() throws {
        // Navigate to analytics tab
        app.buttons["Аналитика Cmi5"].tap()
        
        // Verify analytics dashboard
        XCTAssertTrue(app.staticTexts["Общая статистика"].exists)
        XCTAssertTrue(app.staticTexts["Активность по дням"].exists)
        
        // Check for any graphical elements (charts might be rendered as images or other views)
        XCTAssertTrue(app.images.firstMatch.exists || app.otherElements["График"].exists)
        
        // Check metrics
        XCTAssertTrue(app.staticTexts["Всего сессий:"].exists)
        XCTAssertTrue(app.staticTexts["Уникальных пользователей:"].exists)
        XCTAssertTrue(app.staticTexts["Средний прогресс:"].exists)
        
        // Filter by date
        app.buttons["Период"].tap()
        app.buttons["Последние 7 дней"].tap()
        
        // Verify chart updates
        sleep(1)
        XCTAssertTrue(app.images.firstMatch.exists || app.otherElements["График"].exists)
    }
    
    func testCmi5ErrorHandling() throws {
        // Simulate network error
        app.switches["Режим отладки"].tap()
        app.buttons["Симулировать ошибку сети"].tap()
        
        // Try to import package
        app.buttons["Импортировать пакет"].tap()
        app.buttons["Использовать пример"].tap()
        app.buttons["Импортировать"].tap()
        
        // Verify error handling
        XCTAssertTrue(app.alerts["Ошибка сети"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Проверьте подключение к интернету"].exists)
        
        app.alerts.buttons["Повторить"].tap()
        
        // Disable error simulation
        app.switches["Режим отладки"].tap()
    }
} 