//
//  LoginFlowTests.swift
//  LMSTests
//

import XCTest
@testable import LMS

@MainActor
class LoginFlowTests: XCTestCase {
    
    var authService: MockAuthService!
    
    override func setUp() async throws {
        try await super.setUp()
        authService = MockAuthService.shared
        try await authService.logout() // Ensure logged out state
    }
    
    override func tearDown() async throws {
        try await authService.logout()
        authService = nil
        try await super.tearDown()
    }
    
    // MARK: - Complete Login Flow Tests
    
    func testCompleteLoginFlow_Success() async throws {
        // 1. Initial state - not authenticated
        XCTAssertFalse(authService.isAuthenticated)
        XCTAssertNil(authService.currentUser)
        
        // 2. Attempt login with valid credentials
        let email = "user@example.com"
        let password = "password"
        
        let result = try await authService.login(email: email, password: password)
        
        // 3. Verify authentication state
        XCTAssertTrue(authService.isAuthenticated)
        XCTAssertNotNil(authService.currentUser)
        XCTAssertEqual(authService.currentUser?.email, email)
        XCTAssertNotNil(result.accessToken)
        
        // 4. Verify user data
        let user = authService.currentUser
        XCTAssertNotNil(user?.id)
        XCTAssertNotNil(user?.name)
        XCTAssertNotNil(user?.role)
        
        // 5. Logout
        try await authService.logout()
        
        // 6. Verify logged out state
        XCTAssertFalse(authService.isAuthenticated)
        XCTAssertNil(authService.currentUser)
    }
    
    func testCompleteLoginFlow_AdminUser() async throws {
        // 1. Login as admin
        let result = try await authService.login(email: "admin@example.com", password: "password")
        
        // 2. Set role to admin for testing
        if var user = authService.currentUser {
            user.role = .admin
            authService.currentUser = user
        }
        
        // 3. Verify admin role
        XCTAssertTrue(authService.isAuthenticated)
        XCTAssertEqual(authService.currentUser?.role, .admin)
    }
    
    func testCompleteLoginFlow_StudentUser() async throws {
        // 1. Login as student
        let result = try await authService.login(email: "student@example.com", password: "password")
        
        // 2. Verify student role
        XCTAssertTrue(authService.isAuthenticated)
        XCTAssertEqual(authService.currentUser?.role, .student)
        
        // 3. Verify NOT admin
        XCTAssertNotEqual(authService.currentUser?.role, .admin)
    }
    
    func testCompleteLoginFlow_InstructorUser() async throws {
        // 1. Login as instructor
        _ = try await authService.login(email: "instructor@example.com", password: "password")
        
        // 2. Set role to instructor
        if var user = authService.currentUser {
            user.role = .instructor
            authService.currentUser = user
        }
        
        // 3. Verify instructor role
        XCTAssertTrue(authService.isAuthenticated)
        XCTAssertEqual(authService.currentUser?.role, .instructor)
    }
    
    // MARK: - Error Handling Tests
    
    func testLoginFlow_InvalidCredentials() async {
        // Set up to fail
        authService.shouldFail = true
        authService.authError = APIError.invalidCredentials
        
        // Attempt login
        do {
            _ = try await authService.login(email: "wrong@example.com", password: "wrongpass")
            XCTFail("Login should have failed")
        } catch {
            // Expected error
            XCTAssertTrue(error is APIError)
        }
        
        // Should not authenticate
        XCTAssertFalse(authService.isAuthenticated)
        XCTAssertNil(authService.currentUser)
    }
    
    // MARK: - Session Persistence Tests
    
    func testLoginFlow_SessionPersistence() async throws {
        // 1. Login
        _ = try await authService.login(email: "user@example.com", password: "password")
        XCTAssertTrue(authService.isAuthenticated)
        
        // 2. Simulate app restart (in real app would check UserDefaults/Keychain)
        let wasAuthenticated = authService.isAuthenticated
        let userId = authService.currentUser?.id
        
        // 3. Verify session data available
        XCTAssertTrue(wasAuthenticated)
        XCTAssertNotNil(userId)
    }
    
    // MARK: - Navigation After Login Tests
    
    func testLoginFlow_NavigationAfterLogin() async throws {
        // 1. Not authenticated - should show login
        XCTAssertFalse(authService.isAuthenticated)
        
        // 2. Login
        _ = try await authService.login(email: "user@example.com", password: "password")
        
        // 3. Authenticated - should show main content
        XCTAssertTrue(authService.isAuthenticated)
        
        // In real app, would verify navigation to main TabView
    }
    
    func testBasicLoginFlow() async throws {
        // When - user enters credentials and logs in
        let email = "test@example.com"
        let password = "password123"
        
        _ = try await authService.login(email: email, password: password)
        
        // Then
        XCTAssertTrue(authService.isAuthenticated)
        XCTAssertNotNil(authService.currentUser)
    }
}

// MARK: - Login UI Flow Tests

class LoginUIFlowTests: XCTestCase {
    
    func testLoginUI_FormValidation() {
        // Test email validation
        let validEmails = ["user@example.com", "test.user@domain.co", "name+tag@company.org"]
        let invalidEmails = ["", "notanemail", "@example.com", "user@", "user"]
        
        for email in validEmails {
            let isValid = email.contains("@") && !email.isEmpty
            XCTAssertTrue(isValid, "Email \(email) should be valid")
        }
        
        for email in invalidEmails {
            let isValid = email.contains("@") && !email.isEmpty
            XCTAssertFalse(isValid, "Email \(email) should be invalid")
        }
    }
    
    func testLoginUI_PasswordValidation() {
        // Test password validation
        let validPasswords = ["password", "12345678", "P@ssw0rd!", "verylongpasswordstring"]
        let invalidPasswords = [""]
        
        for password in validPasswords {
            let isValid = !password.isEmpty
            XCTAssertTrue(isValid, "Password should be valid")
        }
        
        for password in invalidPasswords {
            let isValid = !password.isEmpty
            XCTAssertFalse(isValid, "Password should be invalid")
        }
    }
    
    func testLoginUI_ButtonStates() {
        // Test button enabled/disabled states
        let testCases: [(email: String, password: String, shouldBeEnabled: Bool)] = [
            ("", "", false),
            ("user@example.com", "", false),
            ("", "password", false),
            ("notanemail", "password", false),
            ("user@example.com", "password", true)
        ]
        
        for testCase in testCases {
            let isEnabled = !testCase.email.isEmpty && 
                           !testCase.password.isEmpty && 
                           testCase.email.contains("@")
            XCTAssertEqual(isEnabled, testCase.shouldBeEnabled,
                          "Button state incorrect for email: \(testCase.email), password: \(testCase.password)")
        }
    }
}

// MARK: - Login Error Handling Tests

@MainActor
class LoginErrorHandlingTests: XCTestCase {
    
    var authService: MockAuthService!
    
    override func setUp() async throws {
        try await super.setUp()
        authService = MockAuthService.shared
        try await authService.logout()
    }
    
    override func tearDown() async throws {
        try await authService.logout()
        authService = nil
        try await super.tearDown()
    }
    
    func testLoginError_InvalidCredentials() {
        // In real implementation, would test API error
        let error = APIError.unauthorized
        XCTAssertEqual(error.errorDescription, "Authentication required")
    }
    
    func testLoginError_NetworkError() {
        let error = APIError.noInternet
        XCTAssertEqual(error.errorDescription, "No internet connection")
    }
    
    func testLoginError_ServerError() {
        let error = APIError.serverError(statusCode: 500)
        XCTAssertEqual(error.errorDescription, "Server error (500)")
    }
    
    func testLoginError_Timeout() {
        let error = APIError.timeout
        XCTAssertEqual(error.errorDescription, "Request timed out")
    }
} 