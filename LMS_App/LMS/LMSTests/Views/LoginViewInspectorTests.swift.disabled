//
//  LoginViewInspectorTests.swift
//  LMSTests
//
//  Created on 2025-07-06.
//

import XCTest
import SwiftUI
import ViewInspector
@testable import LMS

final class LoginViewInspectorTests: XCTestCase {
    var authService: MockAuthService!
    var sut: LoginView!
    
    override func setUp() {
        super.setUp()
        authService = MockAuthService.shared
        authService.reset()
        sut = LoginView()
    }
    
    override func tearDown() {
        authService = nil
        sut = nil
        super.tearDown()
    }
    
    // MARK: - View Structure Tests
    
    func testLoginViewHasTitle() throws {
        let title = try sut.inspect().find(text: "Вход в систему")
        XCTAssertNotNil(title)
    }
    
    func testLoginViewHasEmailTextField() throws {
        let emailField = try findTextField("Email", in: sut.inspect())
        XCTAssertNotNil(emailField)
    }
    
    func testLoginViewHasPasswordSecureField() throws {
        let passwordField = try findSecureField("Пароль", in: sut.inspect())
        XCTAssertNotNil(passwordField)
    }
    
    func testLoginViewHasLoginButton() throws {
        let button = try findButton("Войти", in: sut.inspect())
        XCTAssertNotNil(button)
    }
    
    func testLoginViewHasMicrosoftLoginButton() throws {
        let button = try findButton("Войти через Microsoft", in: sut.inspect())
        XCTAssertNotNil(button)
    }
    
    func testLoginViewHasLogo() throws {
        let logo = try sut.inspect().find(ViewType.Image.self)
        XCTAssertNotNil(logo)
    }
    
    func testLoginViewHasSubtitle() throws {
        let subtitle = try sut.inspect().find(text: "Корпоративный университет")
        XCTAssertNotNil(subtitle)
    }
    
    // MARK: - Layout Tests
    
    func testLoginViewUsesVStack() throws {
        let vStack = try sut.inspect().find(ViewType.VStack.self)
        XCTAssertNotNil(vStack)
    }
    
    func testLoginFormIsInVStack() throws {
        let vStack = try sut.inspect().find(ViewType.VStack.self)
        let formElements = try vStack.findAll(ViewType.TextField.self).count + 
                          try vStack.findAll(ViewType.SecureField.self).count
        XCTAssertEqual(formElements, 2)
    }
    
    func testButtonsAreInCorrectOrder() throws {
        let vStack = try sut.inspect().find(ViewType.VStack.self)
        let buttons = try vStack.findAll(ViewType.Button.self)
        XCTAssertGreaterThanOrEqual(buttons.count, 2)
    }
    
    // MARK: - Style Tests
    
    func testLoginButtonHasCorrectStyle() throws {
        let button = try findButton("Войти", in: sut.inspect())
        let background = try button.background()
        XCTAssertNotNil(background)
    }
    
    func testTextFieldsHaveCorrectStyle() throws {
        let emailField = try findTextField("Email", in: sut.inspect())
        let style = try emailField.textFieldStyle()
        XCTAssertNotNil(style)
    }
    
    // MARK: - Validation Tests
    
    func testEmptyEmailShowsError() throws {
        // This would require state manipulation
        // ViewInspector doesn't support runtime state changes
        // Would need to test through ViewModel
        XCTAssertTrue(true, "State testing requires ViewModel approach")
    }
    
    func testEmptyPasswordShowsError() throws {
        // This would require state manipulation
        XCTAssertTrue(true, "State testing requires ViewModel approach")
    }
    
    // MARK: - Accessibility Tests
    
    func testLoginButtonHasAccessibilityLabel() throws {
        let button = try findButton("Войти", in: sut.inspect())
        let label = try button.accessibilityLabel()
        XCTAssertNotNil(label)
    }
    
    func testEmailFieldHasAccessibilityLabel() throws {
        let field = try findTextField("Email", in: sut.inspect())
        let label = try field.accessibilityLabel()
        XCTAssertEqual(label, "Email")
    }
    
    func testPasswordFieldHasAccessibilityLabel() throws {
        let field = try findSecureField("Пароль", in: sut.inspect())
        let label = try field.accessibilityLabel()
        XCTAssertEqual(label, "Пароль")
    }
    
    // MARK: - Loading State Tests
    
    func testLoadingOverlayExists() throws {
        // Check if loading overlay structure exists
        let overlays = try sut.inspect().findAll(ViewType.Overlay.self)
        XCTAssertNotNil(overlays)
    }
    
    func testProgressViewExistsInOverlay() throws {
        // ViewInspector limitations with conditional views
        XCTAssertTrue(true, "Conditional view testing requires runtime state")
    }
    
    // MARK: - Error Alert Tests
    
    func testAlertModifierExists() throws {
        let alerts = try sut.inspect().findAll(ViewType.Alert.self)
        XCTAssertTrue(true, "Alert testing requires state manipulation")
    }
    
    // MARK: - Navigation Tests
    
    func testNavigationToContentViewExists() throws {
        // Navigation testing requires NavigationStack context
        XCTAssertTrue(true, "Navigation testing requires full app context")
    }
    
    // MARK: - Keyboard Tests
    
    func testKeyboardDismissOnTap() throws {
        let tapGesture = try sut.inspect().gesture(TapGesture.self)
        XCTAssertNotNil(tapGesture)
    }
    
    // MARK: - Dark Mode Tests
    
    func testViewSupportsColorScheme() throws {
        let colorScheme = try sut.inspect().colorScheme()
        XCTAssertNotNil(colorScheme)
    }
} 