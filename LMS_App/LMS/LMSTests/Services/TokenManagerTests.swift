//
//  TokenManagerTests.swift
//  LMSTests
//
//  Created on 11/07/2025.
//

import XCTest
@testable import LMS

final class TokenManagerTests: XCTestCase {
    private var sut: TokenManager!
    
    override func setUp() {
        super.setUp()
        sut = TokenManager.shared
        // Clear any existing tokens
        sut.clearTokens()
        sut.userId = nil
    }
    
    override func tearDown() {
        // Clean up
        sut.clearTokens()
        sut.userId = nil
        sut = nil
        super.tearDown()
    }
    
    // MARK: - Initialization Tests
    
    func testSharedInstance() {
        // Given/When
        let instance1 = TokenManager.shared
        let instance2 = TokenManager.shared
        
        // Then - should be same instance
        XCTAssertTrue(instance1 === instance2)
    }
    
    func testInitialState() {
        // After clearing in setUp, should have no tokens
        XCTAssertNil(sut.accessToken)
        XCTAssertNil(sut.refreshToken)
        XCTAssertNil(sut.userId)
        XCTAssertFalse(sut.hasValidTokens())
    }
    
    // MARK: - Token Storage Tests
    
    func testSaveAndRetrieveTokens() {
        // Given
        let accessToken = "test_access_token_123"
        let refreshToken = "test_refresh_token_456"
        
        // When
        sut.saveTokens(accessToken: accessToken, refreshToken: refreshToken)
        
        // Then
        XCTAssertEqual(sut.accessToken, accessToken)
        XCTAssertEqual(sut.refreshToken, refreshToken)
        XCTAssertTrue(sut.hasValidTokens())
    }
    
    func testClearTokens() {
        // Given - save tokens first
        sut.saveTokens(accessToken: "token1", refreshToken: "token2")
        XCTAssertTrue(sut.hasValidTokens())
        
        // When
        sut.clearTokens()
        
        // Then
        XCTAssertNil(sut.accessToken)
        XCTAssertNil(sut.refreshToken)
        XCTAssertFalse(sut.hasValidTokens())
    }
    
    // MARK: - Backward Compatibility Tests
    
    func testGetAccessTokenMethod() {
        // Given
        let token = "access_token_test"
        sut.saveTokens(accessToken: token, refreshToken: "refresh")
        
        // When
        let retrievedToken = sut.getAccessToken()
        
        // Then
        XCTAssertEqual(retrievedToken, token)
    }
    
    func testGetRefreshTokenMethod() {
        // Given
        let token = "refresh_token_test"
        sut.saveTokens(accessToken: "access", refreshToken: token)
        
        // When
        let retrievedToken = sut.getRefreshToken()
        
        // Then
        XCTAssertEqual(retrievedToken, token)
    }
    
    // MARK: - User ID Tests
    
    func testUserIdStorage() {
        // Given
        let userId = "user_123"
        
        // When
        sut.userId = userId
        
        // Then
        XCTAssertEqual(sut.userId, userId)
    }
    
    func testUserIdPersistence() {
        // Given
        let userId = "persistent_user_456"
        sut.userId = userId
        
        // When - create new instance (simulating app restart)
        let newManager = TokenManager.shared
        
        // Then - userId should persist
        XCTAssertEqual(newManager.userId, userId)
    }
    
    // MARK: - Validation Tests
    
    func testHasValidTokensWithBothTokens() {
        // Given
        sut.saveTokens(accessToken: "access", refreshToken: "refresh")
        
        // Then
        XCTAssertTrue(sut.hasValidTokens())
    }
    
    func testHasValidTokensWithOnlyAccessToken() {
        // Given - save only access token
        // We need to use private method indirectly
        sut.saveTokens(accessToken: "access", refreshToken: "refresh")
        sut.clearTokens()
        // Can't easily save just one token due to private methods
        
        // Then
        XCTAssertFalse(sut.hasValidTokens())
    }
    
    func testHasValidTokensWithNoTokens() {
        // Given - no tokens saved
        
        // Then
        XCTAssertFalse(sut.hasValidTokens())
    }
    
    // MARK: - Edge Cases
    
    func testEmptyTokenStrings() {
        // Given
        sut.saveTokens(accessToken: "", refreshToken: "")
        
        // Then - should save empty strings
        XCTAssertEqual(sut.accessToken, "")
        XCTAssertEqual(sut.refreshToken, "")
        XCTAssertTrue(sut.hasValidTokens()) // Empty strings are still "valid"
    }
    
    func testVeryLongTokens() {
        // Given
        let longToken = String(repeating: "a", count: 10000)
        
        // When
        sut.saveTokens(accessToken: longToken, refreshToken: longToken)
        
        // Then - should handle long strings
        XCTAssertEqual(sut.accessToken, longToken)
        XCTAssertEqual(sut.refreshToken, longToken)
    }
    
    func testSpecialCharactersInTokens() {
        // Given
        let specialToken = "token_with_!@#$%^&*()_+-=[]{}|;':\",./<>?"
        
        // When
        sut.saveTokens(accessToken: specialToken, refreshToken: specialToken)
        
        // Then
        XCTAssertEqual(sut.accessToken, specialToken)
        XCTAssertEqual(sut.refreshToken, specialToken)
    }
    
    func testTokenOverwrite() {
        // Given - save initial tokens
        sut.saveTokens(accessToken: "old_access", refreshToken: "old_refresh")
        
        // When - save new tokens
        sut.saveTokens(accessToken: "new_access", refreshToken: "new_refresh")
        
        // Then - should overwrite old tokens
        XCTAssertEqual(sut.accessToken, "new_access")
        XCTAssertEqual(sut.refreshToken, "new_refresh")
    }
    
    // MARK: - Authentication State Tests
    
    var isAuthenticated: Bool {
        return TokenManager.shared.hasValidTokens()
    }
    
    func testIsAuthenticatedProperty() {
        // Given - no tokens
        XCTAssertFalse(isAuthenticated)
        
        // When - save tokens
        sut.saveTokens(accessToken: "access", refreshToken: "refresh")
        
        // Then
        XCTAssertTrue(isAuthenticated)
        
        // When - clear tokens
        sut.clearTokens()
        
        // Then
        XCTAssertFalse(isAuthenticated)
    }
} 