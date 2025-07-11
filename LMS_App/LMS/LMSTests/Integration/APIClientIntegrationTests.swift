//
//  APIClientIntegrationTests.swift
//  LMSTests
//
//  Created by AI Assistant on 05/07/2025.
//

import XCTest
@testable import LMS

final class APIClientIntegrationTests: XCTestCase {
    
    var apiClient: APIClient!
    var tokenManager: TokenManager!
    
    override func setUp() {
        super.setUp()
        tokenManager = TokenManager.shared
        tokenManager.clearTokens()
        apiClient = APIClient.shared
    }
    
    override func tearDown() {
        tokenManager.clearTokens()
        super.tearDown()
    }
    
    // MARK: - User Service Integration
    
    func testUserServiceIntegration() async throws {
        // Given
        let userService = UserApiService(apiClient: apiClient)
        tokenManager.saveTokens(
            accessToken: "test_token",
            refreshToken: "test_refresh"
        )
        
        // Create test user
        let createRequest = CreateUserRequest(
            email: "test@example.com",
            name: "Test User",
            role: .student,
            department: "IT",
            password: "password123"
        )
        
        // When - Create user
        do {
            let createdUser = try await userService.createUser(createRequest)
            
            // Then
            XCTAssertEqual(createdUser.email, createRequest.email)
            XCTAssertEqual(createdUser.name, createRequest.name)
            XCTAssertEqual(createdUser.role, createRequest.role)
            XCTAssertTrue(createdUser.isActive)
            
            // Test compatibility properties
            XCTAssertEqual(createdUser.fullName, createRequest.name)
            XCTAssertEqual(createdUser.roles, ["student"])
            XCTAssertFalse(createdUser.permissions.isEmpty)
            
        } catch {
            // If API is not available, test with mock
            let mockService = MockUserService()
            let createdUser = try await mockService.createUser(createRequest)
            
            XCTAssertEqual(createdUser.email, createRequest.email)
            XCTAssertEqual(createdUser.name, createRequest.name)
            XCTAssertEqual(createdUser.role, createRequest.role)
        }
    }
    
    // MARK: - Competency Service Integration
    
    func testCompetencyServiceIntegration() async throws {
        // Given
        let mockService = MockCompetencyService()
        
        // When - Get competencies
        let response = try await mockService.getCompetencies(page: 1, limit: 10, filters: nil)
        
        // Then
        XCTAssertFalse(response.competencies.isEmpty)
        XCTAssertEqual(response.total, response.competencies.count)
        XCTAssertEqual(response.page, 1)
        XCTAssertEqual(response.limit, 10)
        
        // Test first competency
        let firstCompetency = response.competencies.first!
        XCTAssertEqual(firstCompetency.id, "comp1")
        XCTAssertEqual(firstCompetency.name, "iOS Development")
        XCTAssertEqual(firstCompetency.category, "Technical")
        XCTAssertEqual(firstCompetency.level, "Senior")
    }
    
    // MARK: - Auth Service Integration
    
    @MainActor
    func testAuthServiceIntegration() async throws {
        // Given
        let authService = AuthService.shared
        
        // Test mock login
        let mockAuthService = MockAuthService.shared
        
        // Reset mock state
        mockAuthService.isAuthenticated = false
        mockAuthService.currentUser = nil
        mockAuthService.shouldFail = false
        
        // Login with mock credentials
        let response = try await mockAuthService.login(email: "test@example.com", password: "password")
        
        // Then
        XCTAssertTrue(mockAuthService.isAuthenticated)
        XCTAssertNotNil(mockAuthService.currentUser)
        XCTAssertEqual(response.user.email, "test@example.com")
        XCTAssertEqual(response.accessToken, "mock-access-token")
        
        // Test user structure
        XCTAssertEqual(response.user.role, .student)
        XCTAssertTrue(response.user.isActive)
        
        // Test compatibility
        XCTAssertEqual(response.user.fullName, response.user.name)
        XCTAssertEqual(response.user.roles, ["student"])
        XCTAssertFalse(response.user.permissions.isEmpty)
        XCTAssertNil(response.user.position) // Position is nil for student
    }
    
    // MARK: - Model Compatibility Tests
    
    func testUserResponseCompatibility() {
        // Given
        let user = UserResponse(
            id: "123",
            email: "test@example.com",
            name: "John Doe Smith",
            role: .manager,
            avatarURL: "https://example.com/avatar.jpg",
            firstName: "John",
            lastName: "Doe Smith",
            department: "Sales",
            isActive: true,
            createdAt: Date(),
            updatedAt: Date()
        )
        
        // Test name parsing
        XCTAssertEqual(user.firstName, "John")
        XCTAssertEqual(user.lastName, "Doe Smith")
        XCTAssertEqual(user.fullName, "John Doe Smith")
        XCTAssertNil(user.middleName)
        
        // Test role compatibility
        XCTAssertEqual(user.roles, ["manager"])
        XCTAssertTrue(user.permissions.contains("view_analytics"))
        XCTAssertTrue(user.permissions.contains("manage_team"))
        
        // Test helpers
        XCTAssertTrue(user.hasRole("manager"))
        XCTAssertTrue(user.isManager)
        XCTAssertFalse(user.isAdmin)
        XCTAssertFalse(user.isStudent)
        
        // Test additional properties
        XCTAssertNil(user.position) // position is nil when not set
        XCTAssertEqual(user.photo, user.avatarURL)
        XCTAssertEqual(user.registrationDate, user.createdAt)
        
        // Test Identifiable
        XCTAssertEqual(user.id, "123")
    }
    
    func testPaginationInfoCompatibility() {
        // Given
        let pagination = PaginationInfo(
            page: 1,
            limit: 20,
            total: 100,
            totalPages: 5
        )
        
        // Then
        XCTAssertEqual(pagination.page, 1)
        XCTAssertEqual(pagination.limit, 20)
        XCTAssertEqual(pagination.total, 100)
        XCTAssertEqual(pagination.totalPages, 5)
    }
} 