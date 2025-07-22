import XCTest

final class Cmi5ContentUrlUITest: XCTestCase {
    
    let app = XCUIApplication()
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launch()
    }
    
    func test_cmi5ModulePreview_shouldShowContentOrError() throws {
        // Login as admin
        loginAsAdmin()
        
        // Navigate to Course Management
        app.tabBars.buttons["Ещё"].tap()
        app.tables.staticTexts["Управление курсами"].tap()
        
        // Wait for courses to load
        XCTAssertTrue(app.navigationBars["Управление курсами"].waitForExistence(timeout: 5))
        
        // Find a Cmi5 course (e.g., AI Fluency)
        let cmi5Course = app.cells.containing(.staticText, identifier: "AI Fluency").firstMatch
        if cmi5Course.exists {
            cmi5Course.tap()
            
            // Wait for course detail
            XCTAssertTrue(app.navigationBars.buttons["Просмотреть как студент"].waitForExistence(timeout: 5))
            
            // Tap preview as student
            app.navigationBars.buttons["Просмотреть как студент"].tap()
            
            // Wait for student preview
            XCTAssertTrue(app.staticTexts["Режим предпросмотра"].waitForExistence(timeout: 5))
            
            // Try to open first Cmi5 module
            let firstModule = app.cells.firstMatch
            if firstModule.exists {
                firstModule.tap()
                
                // Check what happens
                // Either we see:
                // 1. "ID активности не указан" error
                // 2. Cmi5 content loading
                // 3. Simulation view
                
                let errorAlert = app.alerts["Ошибка"]
                let contentView = app.otherElements["Cmi5Content"]
                let simulationView = app.staticTexts["Симуляция Cmi5 контента"]
                
                // Wait for any of these to appear
                let expectation = XCTNSPredicateExpectation(
                    predicate: NSPredicate { _, _ in
                        errorAlert.exists || contentView.exists || simulationView.exists
                    },
                    object: nil
                )
                
                let result = XCTWaiter().wait(for: [expectation], timeout: 10)
                
                if result == .completed {
                    if errorAlert.exists {
                        // Log the error message
                        let errorMessage = errorAlert.staticTexts.element(boundBy: 1).label
                        print("❌ Error found: \(errorMessage)")
                        
                        // This is the bug we're trying to fix
                        XCTAssertFalse(errorMessage.contains("ID активности не указан"), 
                                      "ContentUrl should be populated for Cmi5 modules")
                        
                        errorAlert.buttons["OK"].tap()
                    } else if contentView.exists {
                        print("✅ Cmi5 content loaded successfully")
                        XCTAssertTrue(true, "Content loaded as expected")
                    } else if simulationView.exists {
                        print("ℹ️ Showing Cmi5 simulation (content not available)")
                        XCTAssertTrue(true, "Simulation shown as fallback")
                    }
                } else {
                    XCTFail("No expected UI element appeared within timeout")
                }
            }
        } else {
            // No Cmi5 courses found - might need to import first
            print("⚠️ No Cmi5 courses found. Please import a Cmi5 course first.")
            XCTSkip("No Cmi5 courses available for testing")
        }
    }
    
    func test_importAndCheckCmi5ContentUrl() throws {
        // Login as admin
        loginAsAdmin()
        
        // Navigate to Course Management
        app.tabBars.buttons["Ещё"].tap()
        app.tables.staticTexts["Управление курсами"].tap()
        
        // Import new Cmi5 course
        if app.buttons["Импортировать курс"].exists {
            app.buttons["Импортировать курс"].tap()
            
            // Select demo course if available
            if app.staticTexts["AI Fluency"].waitForExistence(timeout: 3) {
                app.staticTexts["AI Fluency"].tap()
                app.buttons["Импортировать"].tap()
                
                // Wait for import to complete
                let successAlert = app.alerts["Успех"]
                if successAlert.waitForExistence(timeout: 10) {
                    successAlert.buttons["OK"].tap()
                    
                    // Now test the newly imported course
                    let newCourse = app.cells.containing(.staticText, identifier: "AI Fluency").firstMatch
                    XCTAssertTrue(newCourse.waitForExistence(timeout: 5))
                    
                    newCourse.tap()
                    
                    // Preview as student
                    app.navigationBars.buttons["Просмотреть как студент"].tap()
                    
                    // Try first module
                    let firstModule = app.cells.firstMatch
                    if firstModule.exists {
                        firstModule.tap()
                        
                        // Should NOT show "ID активности не указан" error
                        let errorAlert = app.alerts["Ошибка"]
                        if errorAlert.waitForExistence(timeout: 3) {
                            let errorMessage = errorAlert.staticTexts.element(boundBy: 1).label
                            XCTAssertFalse(errorMessage.contains("ID активности не указан"), 
                                          "Newly imported course should have contentUrl populated")
                        }
                    }
                }
            }
        }
    }
    
    private func loginAsAdmin() {
        // Check if already logged in
        if app.tabBars.buttons["Главная"].exists {
            return
        }
        
        // Login flow
        if app.buttons["Войти как администратор"].exists {
            app.buttons["Войти как администратор"].tap()
        } else if app.textFields["Email"].exists {
            app.textFields["Email"].tap()
            app.textFields["Email"].typeText("admin@tsum.ru")
            app.secureTextFields["Пароль"].tap()
            app.secureTextFields["Пароль"].typeText("Admin123!")
            app.buttons["Войти"].tap()
        }
        
        // Wait for main screen
        XCTAssertTrue(app.tabBars.buttons["Главная"].waitForExistence(timeout: 10))
    }
} 