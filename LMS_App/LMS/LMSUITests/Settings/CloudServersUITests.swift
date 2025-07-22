import XCTest

final class CloudServersUITests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["UI-Testing"]
        app.launch()
    }
    
    func test_developerTools_accessible() throws {
        // Given - logged in as admin
        performAdminLogin()
        
        // When - navigate to settings
        app.tabBars.buttons["Ещё"].tap()
        wait(for: app.staticTexts["Настройки"].exists)
        app.staticTexts["Настройки"].tap()
        
        // Then - Developer Tools section should exist
        #if DEBUG
        XCTAssertTrue(app.staticTexts["🛠 Developer Tools"].exists)
        #endif
    }
    
    func test_cloudServers_navigation() throws {
        // Given - in settings
        navigateToDeveloperTools()
        
        // When - tap Cloud Servers
        app.cells["Cloud Servers"].tap()
        
        // Then - should see Cloud Servers view
        wait(for: app.navigationBars["Cloud Servers"].exists)
        XCTAssertTrue(app.segmentedControls.firstMatch.exists)
        XCTAssertTrue(app.staticTexts["📊 Log Dashboard"].exists)
        XCTAssertTrue(app.staticTexts["💬 Feedback Dashboard"].exists)
    }
    
    func test_serverSwitch_works() throws {
        // Given - in Cloud Servers view
        navigateToDeveloperTools()
        app.cells["Cloud Servers"].tap()
        wait(for: app.segmentedControls.firstMatch.exists)
        
        // When - switch between servers
        let segmentedControl = app.segmentedControls.firstMatch
        segmentedControl.buttons["💬 Feedback Dashboard"].tap()
        
        // Then - should see feedback server info
        wait(for: app.staticTexts["Управление отзывами пользователей"].exists)
    }
    
    func test_serverStatus_navigation() throws {
        // Given - in settings
        navigateToDeveloperTools()
        
        // When - tap Server Status
        app.cells["Server Status"].tap()
        
        // Then - should see Server Status view
        wait(for: app.navigationBars["Server Status"].exists)
        XCTAssertTrue(app.staticTexts["Server Health Check"].exists)
        XCTAssertTrue(app.staticTexts["📊 Log Server"].exists)
        XCTAssertTrue(app.staticTexts["💬 Feedback Server"].exists)
    }
    
    func test_openInSafari_menu() throws {
        // Given - in Cloud Servers view
        navigateToDeveloperTools()
        app.cells["Cloud Servers"].tap()
        wait(for: app.buttons["ellipsis.circle"].exists)
        
        // When - tap menu
        app.buttons["ellipsis.circle"].tap()
        
        // Then - should see menu options
        wait(for: app.buttons["Открыть в Safari"].exists)
        XCTAssertTrue(app.buttons["Обновить"].exists)
        XCTAssertTrue(app.buttons["Настройки серверов"].exists)
    }
    
    func test_serverSettings_navigation() throws {
        // Given - in Cloud Servers menu
        navigateToDeveloperTools()
        app.cells["Cloud Servers"].tap()
        wait(for: app.buttons["ellipsis.circle"].exists)
        app.buttons["ellipsis.circle"].tap()
        wait(for: app.buttons["Настройки серверов"].exists)
        
        // When - tap settings
        app.buttons["Настройки серверов"].tap()
        
        // Then - should see settings sheet
        wait(for: app.navigationBars["Настройки серверов"].exists)
        XCTAssertTrue(app.textFields.firstMatch.exists)
        XCTAssertTrue(app.buttons["Сохранить изменения"].exists)
        XCTAssertTrue(app.buttons["Сбросить на значения по умолчанию"].exists)
    }
    
    // MARK: - Helper Methods
    
    private func performAdminLogin() {
        if app.buttons["Войти как администратор"].exists {
            app.buttons["Войти как администратор"].tap()
            wait(for: app.tabBars.firstMatch.exists)
        }
    }
    
    private func navigateToDeveloperTools() {
        performAdminLogin()
        app.tabBars.buttons["Ещё"].tap()
        wait(for: app.staticTexts["Настройки"].exists)
        app.staticTexts["Настройки"].tap()
        wait(for: app.tables.firstMatch.exists)
    }
    
    private func wait(for condition: Bool, timeout: TimeInterval = 5) {
        let expectation = XCTNSPredicateExpectation(
            predicate: NSPredicate(value: condition),
            object: nil
        )
        wait(for: [expectation], timeout: timeout)
    }
} 