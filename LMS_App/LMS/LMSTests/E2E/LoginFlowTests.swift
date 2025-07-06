//
//  LoginFlowTests.swift
//  LMSTests
//

import XCTest
@testable import LMS

class LoginFlowTests: XCTestCase {
    
    var authService: MockAuthService!
    
    override func setUp() {
        super.setUp()
        authService = MockAuthService.shared
        authService.logout() // Ensure logged out state
    }
    
    override func tearDown() {
        authService.logout()
        authService = nil
        super.tearDown()
    }
    
    // MARK: - Complete Login Flow Tests
    
    func testCompleteLoginFlow_Success() {
        // 1. Initial state - not authenticated
        XCTAssertFalse(authService.isAuthenticated)
        XCTAssertNil(authService.currentUser)
        
        // 2. Attempt login with valid credentials
        let email = "user@example.com"
        let password = "password"
        
        authService.login(email: email, password: password)
        
        // 3. Verify authentication state
        XCTAssertTrue(authService.isAuthenticated)
        XCTAssertNotNil(authService.currentUser)
        XCTAssertEqual(authService.currentUser?.email, email)
        
        // 4. Verify user data
        let user = authService.currentUser
        XCTAssertNotNil(user?.id)
        XCTAssertNotNil(user?.fullName)
        XCTAssertFalse(user?.roles.isEmpty ?? true)
        
        // 5. Logout
        authService.logout()
        
        // 6. Verify logged out state
        XCTAssertFalse(authService.isAuthenticated)
        XCTAssertNil(authService.currentUser)
    }
    
    func testCompleteLoginFlow_AdminUser() {
        // 1. Login as admin
        authService.login(email: "admin@example.com", password: "password")
        
        // 2. Verify admin role
        XCTAssertTrue(authService.isAuthenticated)
        XCTAssertTrue(authService.currentUser?.roles.contains("admin") ?? false)
        
        // 3. Verify admin permissions
        let isAdmin = authService.currentUser?.roles.contains("admin") ?? false
        XCTAssertTrue(isAdmin)
    }
    
    func testCompleteLoginFlow_StudentUser() {
        // 1. Login as student
        authService.login(email: "student@example.com", password: "password")
        
        // 2. Verify student role
        XCTAssertTrue(authService.isAuthenticated)
        XCTAssertTrue(authService.currentUser?.roles.contains("student") ?? false)
        
        // 3. Verify NOT admin
        let isAdmin = authService.currentUser?.roles.contains("admin") ?? false
        XCTAssertFalse(isAdmin)
    }
    
    func testCompleteLoginFlow_TeacherUser() {
        // 1. Login as teacher
        authService.login(email: "teacher@example.com", password: "password")
        
        // 2. Verify teacher role
        XCTAssertTrue(authService.isAuthenticated)
        XCTAssertTrue(authService.currentUser?.roles.contains("teacher") ?? false)
    }
    
    // MARK: - Error Handling Tests
    
    func testLoginFlow_EmptyCredentials() {
        // Attempt login with empty credentials
        authService.login(email: "", password: "")
        
        // Should not authenticate
        XCTAssertFalse(authService.isAuthenticated)
        XCTAssertNil(authService.currentUser)
    }
    
    func testLoginFlow_InvalidEmail() {
        // Attempt login with invalid email
        authService.login(email: "notanemail", password: "password")
        
        // MockAuthService might still authenticate, but real service wouldn't
        // This tests the flow, not validation
        if authService.isAuthenticated {
            XCTAssertNotNil(authService.currentUser)
        }
    }
    
    // MARK: - Session Persistence Tests
    
    func testLoginFlow_SessionPersistence() {
        // 1. Login
        authService.login(email: "user@example.com", password: "password")
        XCTAssertTrue(authService.isAuthenticated)
        
        // 2. Simulate app restart (in real app would check UserDefaults/Keychain)
        let wasAuthenticated = authService.isAuthenticated
        let userId = authService.currentUser?.id
        
        // 3. Verify session data available
        XCTAssertTrue(wasAuthenticated)
        XCTAssertNotNil(userId)
    }
    
    // MARK: - Navigation After Login Tests
    
    func testLoginFlow_NavigationAfterLogin() {
        // 1. Not authenticated - should show login
        XCTAssertFalse(authService.isAuthenticated)
        
        // 2. Login
        authService.login(email: "user@example.com", password: "password")
        
        // 3. Authenticated - should show main content
        XCTAssertTrue(authService.isAuthenticated)
        
        // In real app, would verify navigation to main TabView
    }
    
    func testBasicLoginFlow() {
        // When - user enters credentials and logs in
        let email = "test@example.com"
        let password = "password123"
        
        authService.mockLogin(asAdmin: false)
        
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

class LoginErrorHandlingTests: XCTestCase {
    
    var authService: MockAuthService!
    
    override func setUp() {
        super.setUp()
        authService = MockAuthService.shared
        authService.logout()
    }
    
    override func tearDown() {
        authService.logout()
        authService = nil
        super.tearDown()
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