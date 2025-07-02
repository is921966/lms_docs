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
    private var mockNetworkService: MockNetworkService!
    private var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        
        // Clear any existing state
        TokenManager.shared.clearTokens()
        UserDefaults.standard.removeObject(forKey: "currentUser")
        
        // Setup mock network service
        mockNetworkService = MockNetworkService()
        
        // Create AuthService instance
        authService = AuthService.shared
        
        // Replace network service with mock
        authService.networkService = mockNetworkService
        
        cancellables = Set<AnyCancellable>()
    }
    
    override func tearDown() {
        cancellables = nil
        TokenManager.shared.clearTokens()
        UserDefaults.standard.removeObject(forKey: "currentUser")
        
        super.tearDown()
    }
    
    // MARK: - Login Tests
    
    func testLoginWithValidCredentials() async throws {
        // Given
        let email = "test@example.com"
        let password = "password123"
        let expectedUser = createMockUserProfileDTO()
        let expectedTokens = createMockTokensDTO()
        let loginResponse = createMockLoginResponseDTO(user: expectedUser, tokens: expectedTokens)
        
        mockNetworkService.mockResponse = loginResponse
        
        // When
        let result = try await authService.login(email: email, password: password)
            .asyncMap()
        
        // Then
        XCTAssertNotNil(result)
        XCTAssertTrue(authService.isAuthenticated)
        XCTAssertNotNil(authService.currentUser)
        XCTAssertEqual(authService.currentUser?.email, email)
        XCTAssertNotNil(authService.authStatus)
        XCTAssertTrue(authService.authStatus!.isAuthenticated)
    }
    
    func testLoginWithInvalidCredentials() async {
        // Given
        let email = ""
        let password = "short"
        
        // When & Then
        do {
            _ = try await authService.login(email: email, password: password)
                .asyncMap()
            XCTFail("Expected validation error")
        } catch let error as NetworkError {
            if case .invalidRequest(let message) = error {
                XCTAssertTrue(message.contains("Email cannot be empty"))
                XCTAssertTrue(message.contains("Password must be at least 6 characters long"))
            } else {
                XCTFail("Expected invalidRequest error")
            }
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testLoginWithNetworkError() async {
        // Given
        let email = "test@example.com"
        let password = "password123"
        
        mockNetworkService.shouldFail = true
        mockNetworkService.mockError = NetworkError.noConnection
        
        // When & Then
        do {
            _ = try await authService.login(email: email, password: password)
                .asyncMap()
            XCTFail("Expected network error")
        } catch let error as NetworkError {
            XCTAssertEqual(error, NetworkError.noConnection)
            XCTAssertFalse(authService.isAuthenticated)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    // MARK: - Logout Tests
    
    func testLogoutSuccess() async throws {
        // Given
        setupAuthenticatedState()
        mockNetworkService.mockResponse = EmptyResponse()
        
        // When
        try await authService.logout()
            .asyncMap()
        
        // Then
        XCTAssertFalse(authService.isAuthenticated)
        XCTAssertNil(authService.currentUser)
        XCTAssertNil(TokenManager.shared.accessToken)
        XCTAssertNil(TokenManager.shared.refreshToken)
    }
    
    func testLogoutWithAllDevices() async throws {
        // Given
        setupAuthenticatedState()
        mockNetworkService.mockResponse = EmptyResponse()
        
        // When
        try await authService.logout(logoutAllDevices: true)
            .asyncMap()
        
        // Then
        XCTAssertFalse(authService.isAuthenticated)
        
        // Verify logout request DTO was created correctly
        if let lastRequest = mockNetworkService.lastRequestBody as? LogoutRequestDTO {
            XCTAssertTrue(lastRequest.logoutAllDevices)
        } else {
            XCTFail("Expected LogoutRequestDTO")
        }
    }
    
    // MARK: - Token Refresh Tests
    
    func testRefreshTokenSuccess() async throws {
        // Given
        setupAuthenticatedState()
        let newTokenResponse = createMockTokenResponseDTO()
        mockNetworkService.mockResponse = newTokenResponse
        
        // When
        try await authService.refreshToken()
            .asyncMap()
        
        // Then
        XCTAssertEqual(TokenManager.shared.accessToken, newTokenResponse.accessToken)
        XCTAssertEqual(TokenManager.shared.refreshToken, newTokenResponse.refreshToken)
        XCTAssertNotNil(authService.authStatus)
    }
    
    func testRefreshTokenWithInvalidToken() async {
        // Given
        TokenManager.shared.clearTokens()
        
        // When & Then
        do {
            try await authService.refreshToken()
                .asyncMap()
            XCTFail("Expected unauthorized error")
        } catch let error as NetworkError {
            XCTAssertEqual(error, NetworkError.unauthorized)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testRefreshTokenWithEmptyToken() async {
        // Given
        TokenManager.shared.refreshToken = ""
        
        // When & Then
        do {
            try await authService.refreshToken()
                .asyncMap()
            XCTFail("Expected validation error")
        } catch let error as NetworkError {
            if case .invalidRequest(let message) = error {
                XCTAssertTrue(message.contains("Refresh token cannot be empty"))
            } else {
                XCTFail("Expected invalidRequest error")
            }
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    // MARK: - Get Current User Tests
    
    func testGetCurrentUserSuccess() async throws {
        // Given
        setupAuthenticatedState()
        let userProfileDTO = createMockUserProfileDTO()
        mockNetworkService.mockResponse = userProfileDTO
        
        // When
        let result = try await authService.getCurrentUser()
            .asyncMap()
        
        // Then
        XCTAssertNotNil(result)
        XCTAssertEqual(result.email, userProfileDTO.email)
        XCTAssertEqual(authService.currentUser?.email, userProfileDTO.email)
    }
    
    // MARK: - Authentication State Tests
    
    func testNeedsTokenRefresh() {
        // Given
        let nearExpiryDate = Date().addingTimeInterval(200) // 3 minutes from now
        authService.authStatus = AuthMapper.createAuthStatus(
            isAuthenticated: true,
            tokenExpiresAt: nearExpiryDate,
            needsRefresh: true
        )
        
        // When & Then
        XCTAssertTrue(authService.needsTokenRefresh())
    }
    
    func testTokenTimeRemaining() {
        // Given
        let futureDate = Date().addingTimeInterval(3600) // 1 hour from now
        authService.authStatus = AuthMapper.createAuthStatus(
            isAuthenticated: true,
            tokenExpiresAt: futureDate
        )
        
        // When
        let timeRemaining = authService.tokenTimeRemaining()
        
        // Then
        XCTAssertGreaterThan(timeRemaining, 3500) // Should be close to 1 hour
        XCTAssertLessThan(timeRemaining, 3700)
    }
    
    func testIsTokenExpired() {
        // Given
        let pastDate = Date().addingTimeInterval(-3600) // 1 hour ago
        authService.authStatus = AuthMapper.createAuthStatus(
            isAuthenticated: false,
            tokenExpiresAt: pastDate
        )
        
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
        XCTAssertTrue(validDTO.isValid())
        XCTAssertFalse(invalidDTO.isValid())
        
        let errors = invalidDTO.validationErrors()
        XCTAssertTrue(errors.contains("Email cannot be empty"))
        XCTAssertTrue(errors.contains("Password must be at least 6 characters long"))
    }
    
    func testTokensDTOValidation() {
        // Given
        let validDTO = TokensDTO(
            accessToken: "valid_access_token",
            refreshToken: "valid_refresh_token",
            expiresIn: 3600
        )
        
        let invalidDTO = TokensDTO(
            accessToken: "",
            refreshToken: "",
            expiresIn: -1
        )
        
        // When & Then
        XCTAssertTrue(validDTO.isValid())
        XCTAssertFalse(invalidDTO.isValid())
        
        let errors = invalidDTO.validationErrors()
        XCTAssertTrue(errors.contains("Access token cannot be empty"))
        XCTAssertTrue(errors.contains("Refresh token cannot be empty"))
        XCTAssertTrue(errors.contains("Expires in must be positive"))
    }
    
    // MARK: - Helper Methods
    
    private func setupAuthenticatedState() {
        TokenManager.shared.saveTokens(
            accessToken: "mock_access_token",
            refreshToken: "mock_refresh_token"
        )
        authService.isAuthenticated = true
    }
    
    private func createMockUserProfileDTO() -> UserProfileDTO {
        return UserProfileDTO(
            id: "user123",
            firstName: "John",
            lastName: "Doe",
            email: "test@example.com",
            profileImageUrl: "https://example.com/avatar.jpg",
            department: "Engineering",
            position: "Developer"
        )
    }
    
    private func createMockTokensDTO() -> TokensDTO {
        return TokensDTO(
            accessToken: "mock_access_token",
            refreshToken: "mock_refresh_token",
            expiresIn: 3600
        )
    }
    
    private func createMockLoginResponseDTO(
        user: UserProfileDTO,
        tokens: TokensDTO
    ) -> LoginResponseDTO {
        return LoginResponseDTO(
            success: true,
            message: "Login successful",
            user: user,
            tokens: tokens,
            expiresAt: ISO8601DateFormatter().string(from: Date().addingTimeInterval(3600))
        )
    }
    
    private func createMockTokenResponseDTO() -> TokenResponseDTO {
        return TokenResponseDTO(
            accessToken: "new_access_token",
            refreshToken: "new_refresh_token",
            expiresIn: 3600,
            expiresAt: ISO8601DateFormatter().string(from: Date().addingTimeInterval(3600))
        )
    }
}

// MARK: - Mock Network Service

private class MockNetworkService: NetworkServiceProtocol {
    var mockResponse: Any?
    var mockError: NetworkError?
    var shouldFail = false
    var lastRequestBody: Any?
    
    func get<T: Decodable>(endpoint: String, responseType: T.Type) -> AnyPublisher<T, NetworkError> {
        if shouldFail, let error = mockError {
            return Fail(error: error)
                .eraseToAnyPublisher()
        }
        
        if let response = mockResponse as? T {
            return Just(response)
                .setFailureType(to: NetworkError.self)
                .eraseToAnyPublisher()
        }
        
        return Fail(error: NetworkError.invalidResponse("No mock response"))
            .eraseToAnyPublisher()
    }
    
    func post<T: Encodable, U: Decodable>(
        endpoint: String,
        body: T,
        responseType: U.Type
    ) -> AnyPublisher<U, NetworkError> {
        lastRequestBody = body
        
        if shouldFail, let error = mockError {
            return Fail(error: error)
                .eraseToAnyPublisher()
        }
        
        if let response = mockResponse as? U {
            return Just(response)
                .setFailureType(to: NetworkError.self)
                .eraseToAnyPublisher()
        }
        
        return Fail(error: NetworkError.invalidResponse("No mock response"))
            .eraseToAnyPublisher()
    }
}

// MARK: - Publisher Extensions for Testing

extension Publisher {
    func asyncMap() async throws -> Output {
        return try await withCheckedThrowingContinuation { continuation in
            var cancellable: AnyCancellable?
            
            cancellable = self
                .sink(
                    receiveCompletion: { completion in
                        switch completion {
                        case .finished:
                            break
                        case .failure(let error):
                            continuation.resume(throwing: error)
                        }
                        cancellable?.cancel()
                    },
                    receiveValue: { value in
                        continuation.resume(returning: value)
                        cancellable?.cancel()
                    }
                )
        }
    }
}

// MARK: - Empty Response for Testing

private struct EmptyResponse: Decodable {} 