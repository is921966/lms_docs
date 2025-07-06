import XCTest
import SwiftUI
@testable import LMS

final class LoginViewTests: XCTestCase {
    
    func testLoginViewInitialState() {
        // Given
        let viewModel = AuthViewModel()
        
        // Then
        XCTAssertEqual(viewModel.email, "")
        XCTAssertEqual(viewModel.password, "")
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertFalse(viewModel.isAuthenticated)
    }
    
    func testLoginButtonDisabledWithEmptyFields() {
        // Given
        let viewModel = AuthViewModel()
        
        // When
        viewModel.email = ""
        viewModel.password = ""
        
        // Then
        XCTAssertFalse(viewModel.canLogin)
    }
    
    func testLoginButtonEnabledWithValidFields() {
        // Given
        let viewModel = AuthViewModel()
        
        // When
        viewModel.email = "test@example.com"
        viewModel.password = "password123"
        
        // Then
        XCTAssertTrue(viewModel.canLogin)
    }
    
    func testEmailValidation() {
        // Given
        let viewModel = AuthViewModel()
        
        // When/Then - Invalid emails
        viewModel.email = "invalid"
        XCTAssertFalse(viewModel.isEmailValid)
        
        viewModel.email = "@example.com"
        XCTAssertFalse(viewModel.isEmailValid)
        
        viewModel.email = "test@"
        XCTAssertFalse(viewModel.isEmailValid)
        
        // Valid emails
        viewModel.email = "test@example.com"
        XCTAssertTrue(viewModel.isEmailValid)
        
        viewModel.email = "user.name@company.co.uk"
        XCTAssertTrue(viewModel.isEmailValid)
    }
    
    func testPasswordValidation() {
        // Given
        let viewModel = AuthViewModel()
        
        // When/Then - Invalid passwords
        viewModel.password = "123"
        XCTAssertFalse(viewModel.isPasswordValid)
        
        viewModel.password = ""
        XCTAssertFalse(viewModel.isPasswordValid)
        
        // Valid passwords
        viewModel.password = "password123"
        XCTAssertTrue(viewModel.isPasswordValid)
        
        viewModel.password = "StrongP@ssw0rd!"
        XCTAssertTrue(viewModel.isPasswordValid)
    }
    
    func testLoginSuccess() async {
        // Given
        let mockAuthService = MockAuthService()
        mockAuthService.shouldSucceed = true
        let viewModel = AuthViewModel(authService: mockAuthService)
        
        viewModel.email = "test@example.com"
        viewModel.password = "password123"
        
        // When
        await viewModel.login()
        
        // Then
        XCTAssertTrue(viewModel.isAuthenticated)
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertFalse(viewModel.isLoading)
    }
    
    func testLoginFailure() async {
        // Given
        let mockAuthService = MockAuthService()
        mockAuthService.shouldSucceed = false
        mockAuthService.errorMessage = "Invalid credentials"
        let viewModel = AuthViewModel(authService: mockAuthService)
        
        viewModel.email = "test@example.com"
        viewModel.password = "wrongpassword"
        
        // When
        await viewModel.login()
        
        // Then
        XCTAssertFalse(viewModel.isAuthenticated)
        XCTAssertEqual(viewModel.errorMessage, "Invalid credentials")
        XCTAssertFalse(viewModel.isLoading)
    }
    
    func testBiometricAuthenticationAvailable() {
        // Given
        let viewModel = AuthViewModel()
        
        // Then
        // This will be false in tests, but the property should exist
        XCTAssertNotNil(viewModel.isBiometricAvailable)
    }
    
    func testErrorMessageClearedOnNewAttempt() async {
        // Given
        let mockAuthService = MockAuthService()
        let viewModel = AuthViewModel(authService: mockAuthService)
        
        // First failed attempt
        mockAuthService.shouldSucceed = false
        mockAuthService.errorMessage = "First error"
        await viewModel.login()
        XCTAssertEqual(viewModel.errorMessage, "First error")
        
        // When - Start new attempt
        viewModel.email = "new@example.com"
        
        // Then
        XCTAssertNil(viewModel.errorMessage)
    }
}

// MARK: - Mock AuthService
class MockAuthService: AuthServiceProtocol {
    var shouldSucceed = true
    var errorMessage = "Authentication failed"
    var delay: TimeInterval = 0
    
    func login(email: String, password: String) async throws -> User {
        if delay > 0 {
            try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
        }
        
        if shouldSucceed {
            return User(
                id: UUID(),
                email: email,
                name: "Test User",
                role: .student,
                avatarURL: nil
            )
        } else {
            throw AuthError.invalidCredentials(errorMessage)
        }
    }
    
    func logout() async throws {
        // No-op for tests
    }
    
    func refreshToken() async throws {
        // No-op for tests
    }
    
    var currentUser: User? = nil
}
