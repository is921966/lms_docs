//
//  MockAuthServiceTests.swift
//  LMSTests
//
//  Created on 10/07/2025.
//

import XCTest
import Combine
@testable import LMS

@MainActor
final class MockAuthServiceTests: XCTestCase {
    private var sut: MockAuthService!
    private var cancellables: Set<AnyCancellable>!
    
    override func setUp() async throws {
        try await super.setUp()
        // Create new instance for testing (not shared)
        sut = MockAuthService.shared
        try await sut.logout() // Ensure clean state
        cancellables = Set<AnyCancellable>()
    }
    
    override func tearDown() async throws {
        cancellables = nil
        try await sut.logout() // Clean up
        sut = nil
        try await super.tearDown()
    }
    
    // MARK: - Initialization Tests
    
    func testInitialization() async throws {
        // Check initial state after logout
        try await sut.logout()
        
        XCTAssertNil(sut.currentUser)
        XCTAssertFalse(sut.isAuthenticated)
    }
    
    // MARK: - Login Tests
    
    func testLoginAsStudent() async throws {
        // When
        let result = try await sut.login(
            email: "student@tsum.ru",
            password: "password"
        )
        
        // Then
        XCTAssertTrue(sut.isAuthenticated)
        XCTAssertNotNil(sut.currentUser)
        XCTAssertEqual(result.user.email, "student@tsum.ru")
        XCTAssertEqual(result.user.role, .student)
        XCTAssertNotNil(result.accessToken)
        XCTAssertNotNil(result.refreshToken)
    }
    
    func testLoginAsAdmin() async throws {
        // When
        let result = try await sut.login(
            email: "admin@tsum.ru",
            password: "password"
        )
        
        // Then
        XCTAssertTrue(sut.isAuthenticated)
        XCTAssertNotNil(sut.currentUser)
        XCTAssertEqual(result.user.email, "admin@tsum.ru")
        XCTAssertEqual(result.user.role, .student) // MockAuthService always creates student
    }
    
    func testLoginFailure() async {
        // Given
        sut.shouldFail = true
        sut.authError = APIError.invalidCredentials
        
        // When/Then
        do {
            _ = try await sut.login(
                email: "invalid@example.com",
                password: "wrongpassword"
            )
            XCTFail("Login should have failed")
        } catch {
            XCTAssertTrue(error is APIError)
        }
        
        // Verify state
        XCTAssertFalse(sut.isAuthenticated)
        XCTAssertNil(sut.currentUser)
    }
    
    // MARK: - Logout Tests
    
    func testLogout() async throws {
        // Given - logged in user
        _ = try await sut.login(
            email: "test@example.com",
            password: "password"
        )
        XCTAssertTrue(sut.isAuthenticated)
        
        // When
        try await sut.logout()
        
        // Then
        XCTAssertNil(sut.currentUser)
        XCTAssertFalse(sut.isAuthenticated)
    }
    
    // MARK: - Token Tests
    
    func testTokenRefresh() async throws {
        // Given - logged in
        _ = try await sut.login(
            email: "test@example.com",
            password: "password"
        )
        
        // When
        let newToken = try await sut.refreshToken()
        
        // Then
        XCTAssertNotNil(newToken)
        XCTAssertTrue(sut.hasRefreshedToken)
    }
    
    func testTokenValidation() async throws {
        // Initially not valid
        XCTAssertFalse(sut.isTokenValid())
        
        // After login
        _ = try await sut.login(
            email: "test@example.com",
            password: "password"
        )
        
        // Should be valid
        XCTAssertTrue(sut.isTokenValid())
    }
    
    // MARK: - User Management Tests
    
    func testGetCurrentUser() async throws {
        // Given - not logged in
        do {
            _ = try await sut.getCurrentUser()
            XCTFail("Should throw unauthorized")
        } catch {
            XCTAssertTrue(error is APIError)
        }
        
        // When logged in
        _ = try await sut.login(
            email: "test@example.com",
            password: "password"
        )
        
        // Then
        let user = try await sut.getCurrentUser()
        XCTAssertNotNil(user)
        XCTAssertEqual(user.email, "test@example.com")
    }
    
    func testUpdateProfile() async throws {
        // Given - logged in
        _ = try await sut.login(
            email: "test@example.com",
            password: "password"
        )
        
        // When
        let updatedUser = try await sut.updateProfile(
            firstName: "Updated",
            lastName: "Name"
        )
        
        // Then
        XCTAssertEqual(updatedUser.firstName, "Updated")
        XCTAssertEqual(updatedUser.lastName, "Name")
        XCTAssertEqual(updatedUser.name, "Updated Name")
    }
    
    // MARK: - Session Management Tests
    
    func testClearSession() async throws {
        // Given - logged in
        _ = try await sut.login(
            email: "test@example.com",
            password: "password"
        )
        XCTAssertTrue(sut.isAuthenticated)
        
        // When
        sut.clearSession()
        
        // Then
        XCTAssertFalse(sut.isAuthenticated)
        XCTAssertNil(sut.currentUser)
    }
    
    // MARK: - Error Handling Tests
    
    func testNetworkError() async {
        // Given
        sut.shouldFail = true
        sut.authError = APIError.networkError(URLError(.notConnectedToInternet))
        
        // When/Then
        do {
            _ = try await sut.login(
                email: "test@example.com",
                password: "password"
            )
            XCTFail("Should throw network error")
        } catch {
            if case APIError.networkError = error {
                // Success
            } else {
                XCTFail("Wrong error type")
            }
        }
    }
    
    // MARK: - State Persistence Tests
    
    func testStateReset() async throws {
        // Given - logged in
        _ = try await sut.login(
            email: "test@example.com",
            password: "password"
        )
        
        // When - reset error state
        sut.shouldFail = false
        sut.authError = nil
        
        // Then - can login again
        let result = try await sut.login(
            email: "another@example.com",
            password: "password"
        )
        
        XCTAssertTrue(sut.isAuthenticated)
        XCTAssertEqual(result.user.email, "another@example.com")
    }
} 