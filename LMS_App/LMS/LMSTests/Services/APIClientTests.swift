//
//  APIClientTests.swift
//  LMSTests
//

import XCTest
import Combine
@testable import LMS

final class APIClientTests: XCTestCase {
    
    var sut: APIClient!
    
    override func setUp() {
        super.setUp()
        sut = APIClient.shared
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    // MARK: - Singleton Tests
    
    func testSharedInstance() {
        let instance1 = APIClient.shared
        let instance2 = APIClient.shared
        XCTAssertTrue(instance1 === instance2)
    }
    
    // MARK: - API Endpoint Tests
    
    func testAuthEndpointConfiguration() {
        // Test login endpoint
        let loginEndpoint = AuthEndpoint.login(credentials: LoginRequest(email: "test@test.com", password: "password"))
        XCTAssertEqual(loginEndpoint.path, "/auth/login")
        XCTAssertEqual(loginEndpoint.method, .post)
        XCTAssertFalse(loginEndpoint.requiresAuth)
        
        // Test refresh endpoint
        let refreshEndpoint = AuthEndpoint.refresh(token: "refresh-token")
        XCTAssertEqual(refreshEndpoint.path, "/auth/refresh")
        XCTAssertEqual(refreshEndpoint.method, .post)
        XCTAssertFalse(refreshEndpoint.requiresAuth)
        
        // Test logout endpoint
        let logoutEndpoint = AuthEndpoint.logout
        XCTAssertEqual(logoutEndpoint.path, "/auth/logout")
        XCTAssertEqual(logoutEndpoint.method, .post)
        XCTAssertTrue(logoutEndpoint.requiresAuth)
    }
    
    func testUserEndpointConfiguration() {
        // Test get users endpoint
        let getUsersEndpoint = UserEndpoint.getUsers(page: 1, limit: 20)
        XCTAssertEqual(getUsersEndpoint.path, "/users")
        XCTAssertEqual(getUsersEndpoint.method, .get)
        XCTAssertTrue(getUsersEndpoint.requiresAuth)
        XCTAssertNotNil(getUsersEndpoint.parameters)
        
        // Test create user endpoint
        let createUserEndpoint = UserEndpoint.createUser(user: CreateUserRequest(
            email: "test@test.com",
            name: "Test User",
            role: .student,
            department: "IT",
            password: "password123"
        ))
        XCTAssertEqual(createUserEndpoint.path, "/users")
        XCTAssertEqual(createUserEndpoint.method, .post)
        XCTAssertTrue(createUserEndpoint.requiresAuth)
        XCTAssertNotNil(createUserEndpoint.body)
    }
    
    func testCompetencyEndpointConfiguration() {
        // Test get competencies endpoint
        let getCompetenciesEndpoint = CompetencyEndpoint.getCompetencies(page: 1, limit: 10, filters: nil)
        XCTAssertEqual(getCompetenciesEndpoint.path, "/competencies")
        XCTAssertEqual(getCompetenciesEndpoint.method, .get)
        XCTAssertTrue(getCompetenciesEndpoint.requiresAuth)
        XCTAssertNotNil(getCompetenciesEndpoint.parameters)
        
        // Test get competency endpoint
        let getCompetencyEndpoint = CompetencyEndpoint.getCompetency(id: "comp123")
        XCTAssertEqual(getCompetencyEndpoint.path, "/competencies/comp123")
        XCTAssertEqual(getCompetencyEndpoint.method, .get)
        XCTAssertTrue(getCompetencyEndpoint.requiresAuth)
    }
    
    // MARK: - HTTPMethod Tests
    
    func testHTTPMethodRawValues() {
        XCTAssertEqual(HTTPMethod.get.rawValue, "GET")
        XCTAssertEqual(HTTPMethod.post.rawValue, "POST")
        XCTAssertEqual(HTTPMethod.put.rawValue, "PUT")
        XCTAssertEqual(HTTPMethod.delete.rawValue, "DELETE")
        XCTAssertEqual(HTTPMethod.patch.rawValue, "PATCH")
    }
    
    // MARK: - APIError Tests
    
    func testAPIErrorDescriptions() {
        XCTAssertEqual(APIError.invalidURL.errorDescription, "Invalid URL")
        XCTAssertEqual(APIError.invalidResponse.errorDescription, "Invalid server response")
        XCTAssertEqual(APIError.noInternet.errorDescription, "No internet connection")
        XCTAssertEqual(APIError.timeout.errorDescription, "Request timed out")
        XCTAssertEqual(APIError.cancelled.errorDescription, "Request was cancelled")
        XCTAssertEqual(APIError.unauthorized.errorDescription, "Authentication required")
        XCTAssertEqual(APIError.forbidden.errorDescription, "Access denied")
        XCTAssertEqual(APIError.notFound.errorDescription, "Resource not found")
        XCTAssertEqual(APIError.rateLimitExceeded.errorDescription, "Too many requests. Please try again later")
        XCTAssertEqual(APIError.invalidCredentials.errorDescription, "Invalid email or password")
        XCTAssertEqual(APIError.serverError(statusCode: 500).errorDescription, "Server error (500)")
        XCTAssertEqual(APIError.custom(message: "Test error").errorDescription, "Test error")
        XCTAssertEqual(APIError.unknown(statusCode: 999).errorDescription, "Unknown error (999)")
    }
    
    func testAPIErrorEquality() {
        XCTAssertEqual(APIError.invalidURL, APIError.invalidURL)
        XCTAssertEqual(APIError.unauthorized, APIError.unauthorized)
        XCTAssertEqual(APIError.serverError(statusCode: 500), APIError.serverError(statusCode: 500))
        XCTAssertNotEqual(APIError.serverError(statusCode: 500), APIError.serverError(statusCode: 503))
        XCTAssertEqual(APIError.custom(message: "Test"), APIError.custom(message: "Test"))
        XCTAssertNotEqual(APIError.custom(message: "Test1"), APIError.custom(message: "Test2"))
    }
    
    // MARK: - Request Structure Tests
    
    func testLoginRequest() {
        let loginRequest = LoginRequest(email: "test@example.com", password: "securePassword123")
        XCTAssertEqual(loginRequest.email, "test@example.com")
        XCTAssertEqual(loginRequest.password, "securePassword123")
    }
    
    func testRefreshTokenRequest() {
        let refreshRequest = RefreshTokenRequest(refreshToken: "refresh-token-123")
        XCTAssertEqual(refreshRequest.refreshToken, "refresh-token-123")
    }
    
    func testCreateUserRequest() {
        let createUserRequest = CreateUserRequest(
            email: "newuser@example.com",
            name: "John Doe",
            role: .student,
            department: "IT",
            password: "password123"
        )
        XCTAssertEqual(createUserRequest.email, "newuser@example.com")
        XCTAssertEqual(createUserRequest.name, "John Doe")
        XCTAssertEqual(createUserRequest.role, .student)
        XCTAssertEqual(createUserRequest.department, "IT")
        XCTAssertEqual(createUserRequest.password, "password123")
    }
    
    // MARK: - Bundle Extension Tests
    
    func testBundleAppVersion() {
        let bundle = Bundle.main
        let appVersion = bundle.appVersion
        XCTAssertFalse(appVersion.isEmpty)
        XCTAssertTrue(appVersion.contains("("))
        XCTAssertTrue(appVersion.contains(")"))
    }
} 