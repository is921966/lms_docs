import XCTest
import SwiftUI
import ViewInspector
@testable import LMS

final class LoginViewTests: XCTestCase {
    
    func testLoginViewHasEmailField() throws {
        // Given
        let view = LoginView()
        
        // Then
        let emailField = try view.inspect().find(viewWithId: "emailField")
        XCTAssertNotNil(emailField)
    }
    
    func testLoginViewHasPasswordField() throws {
        // Given
        let view = LoginView()
        
        // Then
        let passwordField = try view.inspect().find(viewWithId: "passwordField")
        XCTAssertNotNil(passwordField)
    }
    
    func testLoginViewHasLoginButton() throws {
        // Given
        let view = LoginView()
        
        // Then
        let loginButton = try view.inspect().find(button: "Login")
        XCTAssertNotNil(loginButton)
    }
}
