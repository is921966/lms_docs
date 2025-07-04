import XCTest

final class LoginUITests: UITestBase {
    override func setUpWithError() throws {
        try super.setUpWithError()

        // Make sure we're logged out before each test
        if app.tabBars.firstMatch.exists {
            logout()
        }
    }

    // MARK: - Successful Login Tests

    func testSuccessfulAdminLogin() throws {
        // Arrange
        let emailField = app.textFields[AccessibilityIdentifiers.Auth.emailField]
        let passwordField = app.secureTextFields[AccessibilityIdentifiers.Auth.passwordField]
        let loginButton = app.buttons[AccessibilityIdentifiers.Auth.loginButton]

        // Act
        emailField.tap()
        emailField.typeText("admin@company.com")

        passwordField.tap()
        passwordField.typeText("password123")

        loginButton.tap()

        // Assert
        waitForElement(app.tabBars.firstMatch)
        XCTAssertTrue(app.tabBars.buttons["Курсы"].exists)
        XCTAssertTrue(app.tabBars.buttons["Аналитика"].exists) // Admin only tab

        takeScreenshot(name: "Admin_Home_Screen")
    }

    func testSuccessfulStudentLogin() throws {
        // Arrange
        let emailField = app.textFields[AccessibilityIdentifiers.Auth.emailField]
        let passwordField = app.secureTextFields[AccessibilityIdentifiers.Auth.passwordField]
        let loginButton = app.buttons[AccessibilityIdentifiers.Auth.loginButton]

        // Act
        emailField.tap()
        emailField.typeText("student@company.com")

        passwordField.tap()
        passwordField.typeText("password123")

        loginButton.tap()

        // Assert
        waitForElement(app.tabBars.firstMatch)
        XCTAssertTrue(app.tabBars.buttons["Курсы"].exists)
        XCTAssertFalse(app.tabBars.buttons["Аналитика"].exists) // Student should not see Analytics

        takeScreenshot(name: "Student_Home_Screen")
    }

    // MARK: - Validation Tests

    func testEmptyFieldsValidation() throws {
        // Arrange
        let loginButton = app.buttons[AccessibilityIdentifiers.Auth.loginButton]

        // Act
        loginButton.tap()

        // Assert
        checkAlert(title: "Ошибка", message: "Пожалуйста, заполните все поля")
    }

    func testEmptyEmailValidation() throws {
        // Arrange
        let passwordField = app.secureTextFields[AccessibilityIdentifiers.Auth.passwordField]
        let loginButton = app.buttons[AccessibilityIdentifiers.Auth.loginButton]

        // Act
        passwordField.tap()
        passwordField.typeText("password123")
        loginButton.tap()

        // Assert
        checkAlert(title: "Ошибка", message: "Введите email")
    }

    func testEmptyPasswordValidation() throws {
        // Arrange
        let emailField = app.textFields[AccessibilityIdentifiers.Auth.emailField]
        let loginButton = app.buttons[AccessibilityIdentifiers.Auth.loginButton]

        // Act
        emailField.tap()
        emailField.typeText("admin@company.com")
        loginButton.tap()

        // Assert
        checkAlert(title: "Ошибка", message: "Введите пароль")
    }

    func testInvalidEmailFormat() throws {
        // Arrange
        let emailField = app.textFields[AccessibilityIdentifiers.Auth.emailField]
        let passwordField = app.secureTextFields[AccessibilityIdentifiers.Auth.passwordField]
        let loginButton = app.buttons[AccessibilityIdentifiers.Auth.loginButton]

        // Act
        emailField.tap()
        emailField.typeText("invalid-email")

        passwordField.tap()
        passwordField.typeText("password123")

        loginButton.tap()

        // Assert
        checkAlert(title: "Ошибка", message: "Неверный формат email")
    }

    // MARK: - Invalid Credentials Tests

    func testInvalidCredentials() throws {
        // Arrange
        let emailField = app.textFields[AccessibilityIdentifiers.Auth.emailField]
        let passwordField = app.secureTextFields[AccessibilityIdentifiers.Auth.passwordField]
        let loginButton = app.buttons[AccessibilityIdentifiers.Auth.loginButton]

        // Act
        emailField.tap()
        emailField.typeText("wrong@company.com")

        passwordField.tap()
        passwordField.typeText("wrongpassword")

        loginButton.tap()

        // Assert
        checkAlert(title: "Ошибка входа", message: "Неверный email или пароль")

        // Verify we're still on login screen
        XCTAssertTrue(loginButton.exists)
    }

    // MARK: - Remember Me Tests

    func testRememberMeFunction() throws {
        // Arrange
        let emailField = app.textFields[AccessibilityIdentifiers.Auth.emailField]
        let passwordField = app.secureTextFields[AccessibilityIdentifiers.Auth.passwordField]
        let rememberMeToggle = app.switches[AccessibilityIdentifiers.Auth.rememberMeToggle]
        let loginButton = app.buttons[AccessibilityIdentifiers.Auth.loginButton]

        // Act - Login with Remember Me enabled
        emailField.tap()
        emailField.typeText("admin@company.com")

        passwordField.tap()
        passwordField.typeText("password123")

        rememberMeToggle.tap()
        XCTAssertTrue(rememberMeToggle.value as? String == "1")

        loginButton.tap()

        // Wait for successful login
        waitForElement(app.tabBars.firstMatch)

        // Logout
        logout()

        // Assert - Email should be pre-filled
        XCTAssertEqual(emailField.value as? String, "admin@company.com")
        XCTAssertTrue(rememberMeToggle.value as? String == "1")

        takeScreenshot(name: "Remember_Me_Prefilled")
    }

    // MARK: - UI State Tests

    func testLoadingStateWhileLoggingIn() throws {
        // Arrange
        let emailField = app.textFields[AccessibilityIdentifiers.Auth.emailField]
        let passwordField = app.secureTextFields[AccessibilityIdentifiers.Auth.passwordField]
        let loginButton = app.buttons[AccessibilityIdentifiers.Auth.loginButton]

        // Act
        emailField.tap()
        emailField.typeText("admin@company.com")

        passwordField.tap()
        passwordField.typeText("password123")

        loginButton.tap()

        // Assert - Loading indicator should appear briefly
        let loadingIndicator = app.activityIndicators[AccessibilityIdentifiers.Common.loadingIndicator]
        XCTAssertTrue(loadingIndicator.exists)

        // Wait for login to complete
        waitForElement(app.tabBars.firstMatch)

        // Loading should disappear
        waitForElementToDisappear(loadingIndicator)
    }

    func testKeyboardDismissalOnLoginTap() throws {
        // Arrange
        let emailField = app.textFields[AccessibilityIdentifiers.Auth.emailField]
        let loginButton = app.buttons[AccessibilityIdentifiers.Auth.loginButton]

        // Act - Focus email field to show keyboard
        emailField.tap()
        emailField.typeText("test")

        // Verify keyboard is shown
        XCTAssertTrue(app.keyboards.count > 0)

        // Tap login button
        loginButton.tap()

        // Assert - Keyboard should be dismissed
        let keyboardDismissed = !app.keyboards.firstMatch.exists
        XCTAssertTrue(keyboardDismissed || app.keyboards.firstMatch.frame.height == 0)
    }
}
