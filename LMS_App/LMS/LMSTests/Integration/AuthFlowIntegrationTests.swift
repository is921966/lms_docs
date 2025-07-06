//
//  AuthFlowIntegrationTests.swift
//  LMSTests
//
//  Created on 06/07/2025.
//

import XCTest
import Combine
@testable import LMS

@MainActor
final class AuthFlowIntegrationTests: XCTestCase {
    
    var authService: LMS.MockAuthService!
    var authViewModel: AuthViewModel!
    var cancellables: Set<AnyCancellable> = []
    
    override func setUp() async throws {
        try await super.setUp()
        authService = LMS.MockAuthService.shared
        // Reset state using the new method
        authService.resetForTesting()
        
        authViewModel = AuthViewModel(authService: authService)
        cancellables = []
    }
    
    override func tearDown() {
        authService = nil
        authViewModel = nil
        cancellables.removeAll()
        super.tearDown()
    }
    
    // MARK: - Full Authentication Flow Tests
    
    func testCompleteLoginFlow() async throws {
        // Initial state
        XCTAssertFalse(authViewModel.isAuthenticated)
        XCTAssertNil(authViewModel.currentUser)
        
        // Perform login
        let result = try await authService.login(
            email: "admin@example.com",
            password: "password123"
        )
        
        // Verify login result
        XCTAssertNotNil(result.accessToken)
        XCTAssertNotNil(result.user)
        
        // Wait for ViewModel to update
        let expectation = XCTestExpectation(description: "Auth state updated")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertTrue(self.authViewModel.isAuthenticated)
            XCTAssertNotNil(self.authViewModel.currentUser)
            XCTAssertEqual(self.authViewModel.currentUser?.email, "admin@example.com")
            expectation.fulfill()
        }
        
        await fulfillment(of: [expectation], timeout: 0.5)
    }
    
    func testLoginWithInvalidCredentials() async {
        // Set up failure
        authService.shouldFail = true
        authService.authError = APIError.invalidCredentials
        
        // Try invalid login
        do {
            _ = try await authService.login(
                email: "invalid@example.com",
                password: "wrongpassword"
            )
            XCTFail("Login should have failed")
        } catch {
            // Expected error
            XCTAssertTrue(error is APIError)
        }
        
        // Verify state remains unauthenticated
        XCTAssertFalse(authViewModel.isAuthenticated)
        XCTAssertNil(authViewModel.currentUser)
    }
    
    func testLogoutFlow() async throws {
        // First login
        _ = try await authService.login(
            email: "admin@example.com",
            password: "password123"
        )
        
        // Wait for login to complete
        try await Task.sleep(nanoseconds: 100_000_000)
        XCTAssertTrue(authViewModel.isAuthenticated)
        
        // Perform logout
        try await authService.logout()
        
        // Wait for logout to complete
        let expectation = XCTestExpectation(description: "Logout complete")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertFalse(self.authViewModel.isAuthenticated)
            XCTAssertNil(self.authViewModel.currentUser)
            expectation.fulfill()
        }
        
        await fulfillment(of: [expectation], timeout: 0.5)
    }
    
    // MARK: - Token Management Tests
    
    func testTokenRefresh() async throws {
        // Login first
        let loginResult = try await authService.login(
            email: "admin@example.com",
            password: "password123"
        )
        let originalToken = loginResult.accessToken
        
        // Refresh token
        let newToken = try await authService.refreshToken()
        
        // Verify new token
        XCTAssertNotEqual(originalToken, newToken)
        XCTAssertFalse(newToken.isEmpty)
        XCTAssertTrue(authService.hasRefreshedToken)
    }
    
    func testAutoTokenRefreshOnExpiry() async throws {
        // Login
        _ = try await authService.login(
            email: "admin@example.com",
            password: "password123"
        )
        
        // Get current user - should work
        let user = try await authService.getCurrentUser()
        
        // Should still work
        XCTAssertNotNil(user)
        XCTAssertTrue(authService.isAuthenticated)
    }
    
    // MARK: - User Profile Tests
    
    func testUpdateUserProfile() async throws {
        // Login
        _ = try await authService.login(
            email: "admin@example.com",
            password: "password123"
        )
        
        // Update profile
        let result = try await authService.updateProfile(
            firstName: "Updated",
            lastName: "Name"
        )
        
        // Verify update
        XCTAssertEqual(result.firstName, "Updated")
        XCTAssertEqual(result.lastName, "Name")
        XCTAssertEqual(result.name, "Updated Name")
        
        // Verify ViewModel updated
        let expectation = XCTestExpectation(description: "Profile updated")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertEqual(self.authViewModel.currentUser?.firstName, "Updated")
            XCTAssertEqual(self.authViewModel.currentUser?.lastName, "Name")
            expectation.fulfill()
        }
        
        await fulfillment(of: [expectation], timeout: 0.5)
    }
    
    // MARK: - Role-Based Access Tests
    
    func testAdminAccess() async throws {
        // Login as admin
        _ = try await authService.login(
            email: "admin@example.com",
            password: "password123"
        )
        
        // Wait for auth
        try await Task.sleep(nanoseconds: 100_000_000)
        
        // Verify admin access
        XCTAssertTrue(authViewModel.isAdmin)
        XCTAssertFalse(authViewModel.isSuperAdmin)
    }
    
    func testSuperAdminAccess() async throws {
        // Login as super admin
        _ = try await authService.login(
            email: "superadmin@example.com",
            password: "password123"
        )
        
        // Wait for auth
        try await Task.sleep(nanoseconds: 100_000_000)
        
        // Verify super admin access
        XCTAssertTrue(authViewModel.isAdmin)
        XCTAssertTrue(authViewModel.isSuperAdmin)
    }
    
    func testStudentAccess() async throws {
        // Login as student
        _ = try await authService.login(
            email: "student@example.com",
            password: "password123"
        )
        
        // Wait for auth
        try await Task.sleep(nanoseconds: 100_000_000)
        
        // Verify student access
        XCTAssertFalse(authViewModel.isAdmin)
        XCTAssertFalse(authViewModel.isSuperAdmin)
    }
    
    // MARK: - Session Management Tests
    
    func testSessionPersistence() async throws {
        // Login
        _ = try await authService.login(
            email: "admin@example.com",
            password: "password123"
        )
        
        // Verify session (MockAuthService is a singleton so it persists)
        try await Task.sleep(nanoseconds: 100_000_000)
        XCTAssertTrue(authService.isAuthenticated)
        XCTAssertNotNil(authService.currentUser)
    }
    
    func testConcurrentRequests() async throws {
        // Login
        _ = try await authService.login(
            email: "admin@example.com",
            password: "password123"
        )
        
        // Make multiple concurrent requests
        async let user1 = authService.getCurrentUser()
        async let user2 = authService.getCurrentUser()
        async let user3 = authService.getCurrentUser()
        
        // All should succeed
        let results = try await [user1, user2, user3]
        XCTAssertEqual(results.count, 3)
        XCTAssertTrue(results.allSatisfy { $0.email == "admin@example.com" })
    }
    
    // MARK: - Error Recovery Tests
    
    func testNetworkErrorRecovery() async {
        // Simulate network error
        authService.shouldFail = true
        authService.authError = APIError.networkError(URLError(.notConnectedToInternet))
        
        // Try login
        do {
            _ = try await authService.login(
                email: "admin@example.com",
                password: "password123"
            )
            XCTFail("Should have thrown network error")
        } catch {
            XCTAssertTrue(error is APIError)
        }
        
        // Fix network
        authService.shouldFail = false
        
        // Retry should work
        do {
            _ = try await authService.login(
                email: "admin@example.com",
                password: "password123"
            )
            XCTAssertTrue(authViewModel.isAuthenticated)
        } catch {
            XCTFail("Login should have succeeded")
        }
    }
} 