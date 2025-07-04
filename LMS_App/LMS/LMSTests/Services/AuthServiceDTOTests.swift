//
//  AuthServiceDTOTests.swift
//  LMSTests
//
//  Created by AI Assistant on 30/06/25.
//
//  Copyright © 2025 LMS. All rights reserved.
//

import XCTest
import Combine
@testable import LMS

@MainActor
final class AuthServiceDTOTests: XCTestCase {
    
    private var authService: AuthService!
    private var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        
        // Clear any existing state
        TokenManager.shared.clearTokens()
        UserDefaults.standard.removeObject(forKey: "currentUser")
        
        // Get AuthService instance
        authService = AuthService.shared
        
        cancellables = Set<AnyCancellable>()
    }
    
    override func tearDown() {
        cancellables = nil
        TokenManager.shared.clearTokens()
        UserDefaults.standard.removeObject(forKey: "currentUser")
        
        super.tearDown()
    }
    
    // MARK: - Authentication State Tests
    
    func testInitialAuthenticationState() {
        // Given/When - fresh AuthService
        
        // Then
        XCTAssertFalse(authService.isAuthenticated)
        XCTAssertNil(authService.currentUser)
        XCTAssertNil(authService.authStatus)
    }
    
    func testNeedsTokenRefresh() {
        // Given
        let nearExpiryDate = Date().addingTimeInterval(200) // 3 minutes from now
        TokenManager.shared.tokenExpiryDate = nearExpiryDate
        TokenManager.shared.saveTokens(
            accessToken: "test_access",
            refreshToken: "test_refresh"
        )
        
        // When & Then
        XCTAssertTrue(authService.needsTokenRefresh())
    }
    
    func testTokenTimeRemaining() {
        // Given
        let futureDate = Date().addingTimeInterval(3600) // 1 hour from now
        TokenManager.shared.tokenExpiryDate = futureDate
        
        // When
        let timeRemaining = authService.tokenTimeRemaining()
        
        // Then
        XCTAssertGreaterThan(timeRemaining, 3500) // Should be close to 1 hour
        XCTAssertLessThan(timeRemaining, 3700)
    }
    
    func testIsTokenExpired() {
        // Given
        let pastDate = Date().addingTimeInterval(-3600) // 1 hour ago
        TokenManager.shared.tokenExpiryDate = pastDate
        
        // When & Then
        XCTAssertTrue(authService.isTokenExpired())
    }
    
    // MARK: - DTO Validation Tests
    
    func testLoginRequestDTOValidation() {
        // Given
        let validDTO = LoginRequestDTO(
            email: "test@example.com",
            password: "password123"
        )
        
        let invalidDTO = LoginRequestDTO(
            email: "",
            password: "short"
        )
        
        // When & Then
        XCTAssertTrue(validDTO.validationErrors().isEmpty)
        XCTAssertFalse(invalidDTO.validationErrors().isEmpty)
        
        let errors = invalidDTO.validationErrors()
        XCTAssertTrue(errors.contains("Email is required"))
        XCTAssertTrue(errors.contains("Password must be at least 6 characters"))
    }
    
    func testAuthUserProfileDTOValidation() {
        // Given
        let validDTO = AuthUserProfileDTO(
            id: "user123",
            email: "test@example.com",
            firstName: "John",
            lastName: "Doe",
            role: "student",
            isActive: true
        )
        
        let invalidDTO = AuthUserProfileDTO(
            id: "",
            email: "",
            firstName: "",
            lastName: "",
            role: "",
            isActive: false
        )
        
        // When & Then
        XCTAssertTrue(validDTO.validationErrors().isEmpty)
        XCTAssertFalse(invalidDTO.validationErrors().isEmpty)
        
        let errors = invalidDTO.validationErrors()
        XCTAssertTrue(errors.contains("User ID is required"))
        XCTAssertTrue(errors.contains("Email is required"))
        XCTAssertTrue(errors.contains("First name is required"))
        XCTAssertTrue(errors.contains("Last name is required"))
        XCTAssertTrue(errors.contains("Role is required"))
    }
    
    func testLoginResponseDTOValidation() {
        // Given
        let userProfile = AuthUserProfileDTO(
            id: "user123",
            email: "test@example.com",
            firstName: "John",
            lastName: "Doe",
            role: "student",
            isActive: true
        )
        
        let validDTO = LoginResponseDTO(
            accessToken: "valid_access_token",
            refreshToken: "valid_refresh_token",
            expiresAt: ISO8601DateFormatter().string(from: Date().addingTimeInterval(3600)),
            user: userProfile
        )
        
        let invalidDTO = LoginResponseDTO(
            accessToken: "",
            refreshToken: "",
            expiresAt: "invalid_date",
            user: userProfile
        )
        
        // When & Then
        XCTAssertTrue(validDTO.validationErrors().isEmpty)
        XCTAssertFalse(invalidDTO.validationErrors().isEmpty)
        
        let errors = invalidDTO.validationErrors()
        XCTAssertTrue(errors.contains("Access token is required"))
        XCTAssertTrue(errors.contains("Refresh token is required"))
        XCTAssertTrue(errors.contains("Token expiry date must be in ISO8601 format"))
    }
    
    func testTokenRefreshRequestDTOValidation() {
        // Given
        let validDTO = TokenRefreshRequestDTO(
            refreshToken: "valid_refresh_token"
        )
        
        let invalidDTO = TokenRefreshRequestDTO(
            refreshToken: ""
        )
        
        // When & Then
        XCTAssertTrue(validDTO.validationErrors().isEmpty)
        XCTAssertFalse(invalidDTO.validationErrors().isEmpty)
        
        let errors = invalidDTO.validationErrors()
        XCTAssertTrue(errors.contains("Refresh token is required"))
    }
    
    func testTokenRefreshResponseDTOValidation() {
        // Given
        let validDTO = TokenRefreshResponseDTO(
            accessToken: "new_access_token",
            refreshToken: "new_refresh_token",
            expiresAt: ISO8601DateFormatter().string(from: Date().addingTimeInterval(3600))
        )
        
        let invalidDTO = TokenRefreshResponseDTO(
            accessToken: "",
            refreshToken: "",
            expiresAt: ""
        )
        
        // When & Then
        XCTAssertTrue(validDTO.validationErrors().isEmpty)
        XCTAssertFalse(invalidDTO.validationErrors().isEmpty)
        
        let errors = invalidDTO.validationErrors()
        XCTAssertTrue(errors.contains("Access token is required"))
        XCTAssertTrue(errors.contains("Refresh token is required"))
        XCTAssertTrue(errors.contains("Token expiry date is required"))
    }
    
    func testAuthStatusDTOValidation() {
        // Given
        let userProfile = AuthUserProfileDTO(
            id: "user123",
            email: "test@example.com",
            firstName: "John",
            lastName: "Doe",
            role: "student",
            isActive: true
        )
        
        let validDTO = AuthStatusDTO(
            isAuthenticated: true,
            user: userProfile,
            tokenExpiresAt: ISO8601DateFormatter().string(from: Date().addingTimeInterval(3600)),
            lastLoginAt: ISO8601DateFormatter().string(from: Date())
        )
        
        let invalidDTO = AuthStatusDTO(
            isAuthenticated: true,
            user: nil, // Should have user when authenticated
            tokenExpiresAt: "invalid_date",
            lastLoginAt: "invalid_date"
        )
        
        // When & Then
        XCTAssertTrue(validDTO.validationErrors().isEmpty)
        XCTAssertFalse(invalidDTO.validationErrors().isEmpty)
        
        let errors = invalidDTO.validationErrors()
        XCTAssertTrue(errors.contains("User profile is required when authenticated"))
        XCTAssertTrue(errors.contains("Token expiry date must be in ISO8601 format"))
        XCTAssertTrue(errors.contains("Last login date must be in ISO8601 format"))
    }
    
    func testLogoutRequestDTOValidation() {
        // Given
        let dto1 = LogoutRequestDTO()
        let dto2 = LogoutRequestDTO(
            refreshToken: "token",
            deviceId: "device123",
            logoutAllDevices: true
        )
        
        // When & Then - logout has no required fields
        XCTAssertTrue(dto1.validationErrors().isEmpty)
        XCTAssertTrue(dto2.validationErrors().isEmpty)
    }
    
    // MARK: - Type Alias Tests
    
    func testTokensDTOTypeAlias() {
        // Given
        let userProfile = AuthUserProfileDTO(
            id: "user123",
            email: "test@example.com",
            firstName: "John",
            lastName: "Doe",
            role: "student",
            isActive: true
        )
        
        // When - Using type alias
        let tokensDTO: TokensDTO = LoginResponseDTO(
            accessToken: "access",
            refreshToken: "refresh",
            expiresAt: ISO8601DateFormatter().string(from: Date()),
            user: userProfile
        )
        
        // Then
        XCTAssertEqual(tokensDTO.accessToken, "access")
        XCTAssertEqual(tokensDTO.refreshToken, "refresh")
    }
    
    func testTokenResponseDTOTypeAlias() {
        // When - Using type alias
        let tokenResponse: TokenResponseDTO = TokenRefreshResponseDTO(
            accessToken: "new_access",
            refreshToken: "new_refresh",
            expiresAt: ISO8601DateFormatter().string(from: Date())
        )
        
        // Then
        XCTAssertEqual(tokenResponse.accessToken, "new_access")
        XCTAssertEqual(tokenResponse.refreshToken, "new_refresh")
    }
} 