//
//  AuthModelsTests.swift
//  LMSTests
//
//  Created on 12/07/2025.
//

import XCTest
@testable import LMS

final class AuthModelsTests: XCTestCase {
    
    private var encoder: JSONEncoder!
    private var decoder: JSONDecoder!
    
    override func setUp() {
        super.setUp()
        encoder = JSONEncoder()
        decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
    }
    
    override func tearDown() {
        encoder = nil
        decoder = nil
        super.tearDown()
    }
    
    // MARK: - Request Models Tests
    
    func testLoginRequestEncoding() throws {
        // Given
        let request = LoginRequest(
            email: "test@example.com",
            password: "securePassword123"
        )
        
        // When
        let data = try encoder.encode(request)
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        
        // Then
        XCTAssertNotNil(json)
        XCTAssertEqual(json?["email"] as? String, "test@example.com")
        XCTAssertEqual(json?["password"] as? String, "securePassword123")
    }
    
    func testRefreshTokenRequestEncoding() throws {
        // Given
        let request = RefreshTokenRequest(
            refreshToken: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.test.refresh"
        )
        
        // When
        let data = try encoder.encode(request)
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        
        // Then
        XCTAssertNotNil(json)
        XCTAssertEqual(json?["refreshToken"] as? String, "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.test.refresh")
    }
    
    // MARK: - Response Models Tests
    
    func testLoginResponseDecoding() throws {
        // Given
        let json = """
        {
            "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.test.access",
            "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.test.refresh",
            "user": {
                "id": "user-123",
                "email": "test@example.com",
                "name": "Test User",
                "role": "student",
                "isActive": true,
                "createdAt": "2025-01-01T00:00:00Z",
                "updatedAt": "2025-01-01T00:00:00Z"
            },
            "expiresIn": 3600
        }
        """.data(using: .utf8)!
        
        // When
        let response = try decoder.decode(LoginResponse.self, from: json)
        
        // Then
        XCTAssertEqual(response.accessToken, "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.test.access")
        XCTAssertEqual(response.refreshToken, "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.test.refresh")
        XCTAssertEqual(response.expiresIn, 3600)
        XCTAssertEqual(response.user.id, "user-123")
        XCTAssertEqual(response.user.email, "test@example.com")
        XCTAssertEqual(response.user.name, "Test User")
        XCTAssertEqual(response.user.role, "student")
    }
    
    func testRefreshTokenResponseDecoding() throws {
        // Given
        let json = """
        {
            "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.new.access",
            "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.new.refresh",
            "expiresIn": 7200
        }
        """.data(using: .utf8)!
        
        // When
        let response = try decoder.decode(RefreshTokenResponse.self, from: json)
        
        // Then
        XCTAssertEqual(response.accessToken, "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.new.access")
        XCTAssertEqual(response.refreshToken, "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.new.refresh")
        XCTAssertEqual(response.expiresIn, 7200)
    }
    
    // MARK: - Edge Cases
    
    func testEmptyEmailInLoginRequest() throws {
        // Given
        let request = LoginRequest(
            email: "",
            password: "password"
        )
        
        // When
        let data = try encoder.encode(request)
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        
        // Then
        XCTAssertEqual(json?["email"] as? String, "")
        XCTAssertEqual(json?["password"] as? String, "password")
    }
    
    func testEmptyPasswordInLoginRequest() throws {
        // Given
        let request = LoginRequest(
            email: "test@example.com",
            password: ""
        )
        
        // When
        let data = try encoder.encode(request)
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        
        // Then
        XCTAssertEqual(json?["email"] as? String, "test@example.com")
        XCTAssertEqual(json?["password"] as? String, "")
    }
    
    func testVeryLongTokens() throws {
        // Given
        let longToken = String(repeating: "a", count: 1000)
        let json = """
        {
            "accessToken": "\(longToken)",
            "refreshToken": "\(longToken)",
            "expiresIn": 3600
        }
        """.data(using: .utf8)!
        
        // When
        let response = try decoder.decode(RefreshTokenResponse.self, from: json)
        
        // Then
        XCTAssertEqual(response.accessToken, longToken)
        XCTAssertEqual(response.refreshToken, longToken)
        XCTAssertEqual(response.expiresIn, 3600)
    }
    
    func testZeroExpiresIn() throws {
        // Given
        let json = """
        {
            "accessToken": "token",
            "refreshToken": "refresh",
            "expiresIn": 0
        }
        """.data(using: .utf8)!
        
        // When
        let response = try decoder.decode(RefreshTokenResponse.self, from: json)
        
        // Then
        XCTAssertEqual(response.expiresIn, 0)
    }
    
    func testNegativeExpiresIn() throws {
        // Given
        let json = """
        {
            "accessToken": "token",
            "refreshToken": "refresh",
            "expiresIn": -1
        }
        """.data(using: .utf8)!
        
        // When
        let response = try decoder.decode(RefreshTokenResponse.self, from: json)
        
        // Then
        XCTAssertEqual(response.expiresIn, -1)
    }
    
    // MARK: - Backward Compatibility Tests
    
    func testAuthResponseTypeAlias() throws {
        // Given
        let json = """
        {
            "accessToken": "access",
            "refreshToken": "refresh",
            "user": {
                "id": "user-1",
                "email": "alias@test.com",
                "name": "Alias User",
                "role": "admin",
                "isActive": true,
                "createdAt": "2025-01-01T00:00:00Z",
                "updatedAt": "2025-01-01T00:00:00Z"
            },
            "expiresIn": 3600
        }
        """.data(using: .utf8)!
        
        // When - using type alias
        let response = try decoder.decode(AuthResponse.self, from: json)
        
        // Then - should work same as LoginResponse
        XCTAssertEqual(response.accessToken, "access")
        XCTAssertEqual(response.refreshToken, "refresh")
        XCTAssertEqual(response.user.email, "alias@test.com")
        XCTAssertEqual(response.expiresIn, 3600)
    }
    
    // MARK: - Special Characters Tests
    
    func testSpecialCharactersInEmail() throws {
        // Given
        let request = LoginRequest(
            email: "test+tag@example.com",
            password: "password"
        )
        
        // When
        let data = try encoder.encode(request)
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        
        // Then
        XCTAssertEqual(json?["email"] as? String, "test+tag@example.com")
    }
    
    func testSpecialCharactersInPassword() throws {
        // Given
        let request = LoginRequest(
            email: "test@example.com",
            password: "p@$$w0rd!#%^&*()"
        )
        
        // When
        let data = try encoder.encode(request)
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        
        // Then
        XCTAssertEqual(json?["password"] as? String, "p@$$w0rd!#%^&*()")
    }
    
    // MARK: - User Response in Login Tests
    
    func testLoginResponseWithOptionalUserFields() throws {
        // Given - user without department and avatar
        let json = """
        {
            "accessToken": "access",
            "refreshToken": "refresh",
            "user": {
                "id": "user-1",
                "email": "minimal@test.com",
                "name": "Minimal User",
                "role": "student",
                "isActive": true,
                "createdAt": "2025-01-01T00:00:00Z",
                "updatedAt": "2025-01-01T00:00:00Z"
            },
            "expiresIn": 3600
        }
        """.data(using: .utf8)!
        
        // When
        let response = try decoder.decode(LoginResponse.self, from: json)
        
        // Then
        XCTAssertNil(response.user.department)
        XCTAssertNil(response.user.avatar)
        XCTAssertEqual(response.user.name, "Minimal User")
    }
} 