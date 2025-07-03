import XCTest

class LoginFlowTests: XCTestCase {
    
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
    
    // MARK: - Tests
    
    func testSuccessfulLogin() throws {
        // Given - not authenticated
        navigateToLogin()
        
        // When - enter valid credentials
        let emailField = app.textFields["emailTextField"]
        let passwordField = app.secureTextFields["passwordTextField"]
        let loginButton = app.buttons["loginButton"]
        
        XCTAssertTrue(emailField.exists)
        XCTAssertTrue(passwordField.exists)
        XCTAssertTrue(loginButton.exists)
        
        emailField.tap()
        emailField.typeText("user@example.com")
        
        passwordField.tap()
        passwordField.typeText("password")
        
        // Then - login should succeed
        loginButton.tap()
        
        // Wait for login to complete
        let dashboardTitle = app.staticTexts["Главная"]
        XCTAssertTrue(dashboardTitle.waitForExistence(timeout: 5))
    }
    
    func testLoginWithInvalidEmail() throws {
        // Given
        navigateToLogin()
        
        // When - enter invalid email
        let emailField = app.textFields["emailTextField"]
        let passwordField = app.secureTextFields["passwordTextField"]
        let loginButton = app.buttons["loginButton"]
        
        emailField.tap()
        emailField.typeText("invalid-email")
        
        passwordField.tap()
        passwordField.typeText("password")
        
        // Then - login button should be disabled
        XCTAssertFalse(loginButton.isEnabled)
    }
    
    func testLoginWithEmptyFields() throws {
        // Given
        navigateToLogin()
        
        // When - fields are empty
        let loginButton = app.buttons["loginButton"]
        
        // Then - login button should be disabled
        XCTAssertFalse(loginButton.isEnabled)
    }
    
    func testLoginErrorAlert() throws {
        // Given
        navigateToLogin()
        
        // When - enter wrong credentials
        let emailField = app.textFields["emailTextField"]
        let passwordField = app.secureTextFields["passwordTextField"]
        let loginButton = app.buttons["loginButton"]
        
        emailField.tap()
        emailField.typeText("wrong@example.com")
        
        passwordField.tap()
        passwordField.typeText("wrongpassword")
        
        loginButton.tap()
        
        // Then - error alert should appear
        let alert = app.alerts["Ошибка"]
        XCTAssertTrue(alert.waitForExistence(timeout: 5))
        
        let okButton = alert.buttons["alertOKButton"]
        XCTAssertTrue(okButton.exists)
        okButton.tap()
    }
    
    func testLoginLoadingState() throws {
        // Given
        navigateToLogin()
        
        // When - start login
        let emailField = app.textFields["emailTextField"]
        let passwordField = app.secureTextFields["passwordTextField"]
        let loginButton = app.buttons["loginButton"]
        
        emailField.tap()
        emailField.typeText("user@example.com")
        
        passwordField.tap()
        passwordField.typeText("password")
        
        loginButton.tap()
        
        // Then - loading indicator should appear
        let progressView = app.otherElements["loginProgressView"]
        XCTAssertTrue(progressView.exists)
    }
    
    func testLogout() throws {
        // Given - logged in
        performLogin()
        
        // When - navigate to profile and logout
        app.tabBars.buttons["Профиль"].tap()
        
        let logoutButton = app.buttons["Выйти"]
        XCTAssertTrue(logoutButton.waitForExistence(timeout: 3))
        logoutButton.tap()
        
        // Handle confirmation alert if present
        if app.alerts.firstMatch.exists {
            app.alerts.buttons["Выйти"].tap()
        }
        
        // Then - should return to login
        let loginView = app.otherElements["loginView"]
        XCTAssertTrue(loginView.waitForExistence(timeout: 5))
    }
    
    // MARK: - Helper Methods
    
    private func navigateToLogin() {
        // If already on login, return
        if app.otherElements["loginView"].exists {
            return
        }
        
        // Otherwise navigate to login
        if app.tabBars.buttons["Профиль"].exists {
            app.tabBars.buttons["Профиль"].tap()
        }
        
        if app.buttons["Войти"].exists {
            app.buttons["Войти"].tap()
        }
    }
    
    private func performLogin() {
        navigateToLogin()
        
        let emailField = app.textFields["emailTextField"]
        let passwordField = app.secureTextFields["passwordTextField"]
        let loginButton = app.buttons["loginButton"]
        
        emailField.tap()
        emailField.typeText("user@example.com")
        
        passwordField.tap()
        passwordField.typeText("password")
        
        loginButton.tap()
        
        // Wait for login to complete
        _ = app.staticTexts["Главная"].waitForExistence(timeout: 5)
    }
} 