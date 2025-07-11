//
//  AuthenticationServiceTests.swift
//  LMSTests
//
//  Created on Sprint 39 Day 2 - TDD Excellence
//

import XCTest
@testable import LMS

final class AuthenticationServiceTests: XCTestCase {
    
    var sut: AuthenticationService!
    
    override func setUp() {
        super.setUp()
        sut = AuthenticationService.shared
        sut.clearTokens() // Очищаем состояние перед каждым тестом
    }
    
    override func tearDown() {
        sut.clearTokens() // Очищаем после теста
        sut = nil
        super.tearDown()
    }
    
    // MARK: - Token Refresh Tests
    
    func testRefreshTokenSuccess() async throws {
        // Arrange
        let oldToken = "old-access-token"
        let refreshToken = "valid-refresh-token"
        sut.setTokens(accessToken: oldToken, refreshToken: refreshToken)
        
        // Act
        let newToken = try await sut.refreshAccessToken()
        
        // Assert
        XCTAssertNotEqual(newToken, oldToken)
        XCTAssertFalse(newToken.isEmpty)
        XCTAssertTrue(newToken.hasPrefix("new-access-token-"))
    }
    
    func testRefreshTokenWithInvalidRefreshToken() async {
        // Arrange
        let refreshToken = "invalid-refresh-token"
        sut.setTokens(accessToken: "old", refreshToken: refreshToken)
        
        // Act & Assert
        do {
            _ = try await sut.refreshAccessToken()
            XCTFail("Should throw error for invalid refresh token")
        } catch {
            XCTAssertEqual(error as? AuthenticationError, .invalidRefreshToken)
        }
    }
    
    func testTokenExpirationCheck() {
        // Arrange
        let expiredDate = Date().addingTimeInterval(-60) // 60 seconds ago
        sut.setTokens(
            accessToken: "expired-token",
            refreshToken: "refresh",
            expiryDate: expiredDate
        )
        
        // Act
        let isExpired = sut.isAccessTokenExpired()
        
        // Assert
        XCTAssertTrue(isExpired)
    }
    
    // MARK: - Additional Tests for Refactored Methods
    
    func testHasValidSession() {
        // Arrange & Act - no tokens set
        XCTAssertFalse(sut.hasValidSession())
        
        // Arrange - set valid tokens
        sut.setTokens(accessToken: "valid", refreshToken: "refresh")
        
        // Act & Assert
        XCTAssertTrue(sut.hasValidSession())
    }
    
    func testShouldRefreshToken() {
        // Arrange - token expires in 2 minutes (below threshold)
        let nearExpiryDate = Date().addingTimeInterval(120)
        sut.setTokens(
            accessToken: "token",
            refreshToken: "refresh",
            expiryDate: nearExpiryDate
        )
        
        // Act & Assert
        XCTAssertTrue(sut.shouldRefreshToken())
        
        // Arrange - token expires in 10 minutes (above threshold)
        let farExpiryDate = Date().addingTimeInterval(600)
        sut.setTokens(
            accessToken: "token",
            refreshToken: "refresh",
            expiryDate: farExpiryDate
        )
        
        // Act & Assert
        XCTAssertFalse(sut.shouldRefreshToken())
    }
} 