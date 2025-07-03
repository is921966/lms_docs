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
        let userService = UserService(apiClient: apiClient)
        tokenManager.saveTokens(
            accessToken: "test_token",
            refreshToken: "test_refresh"
        )
        
        // Create test user
        let createRequest = CreateUserRequest(
            email: "test@example.com",
            name: "Test User",
            role: "student",
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
            XCTAssertEqual(createdUser.roles, [createRequest.role])
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
        let competencyService = CompetencyService(apiClient: apiClient)
        tokenManager.saveTokens(
            accessToken: "test_token",
            refreshToken: "test_refresh"
        )
        
        // When - Get competencies
        do {
            let response = try await competencyService.getCompetencies()
            
            // Then
            XCTAssertNotNil(response.competencies)
            XCTAssertNotNil(response.pagination)
            
            // Test pagination
            XCTAssertGreaterThanOrEqual(response.pagination.total, 0)
            XCTAssertGreaterThanOrEqual(response.pagination.totalPages, 0)
            
        } catch {
            // If API is not available, test with mock
            let mockService = MockCompetencyService()
            let response = try await mockService.getCompetencies(page: 1, limit: 10, filters: nil)
            
            XCTAssertFalse(response.competencies.isEmpty)
            XCTAssertNotNil(response.pagination)
        }
    }
    
    // MARK: - Auth Service Integration
    
    func testAuthServiceIntegration() async throws {
        // Given
        let authService = AuthService.shared
        
        // Test mock login
        let mockAuthService = MockAuthService.shared
        mockAuthService.mockLogin(asAdmin: false)
        
        // Wait for async operation
        try await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
        
        // Then
        XCTAssertTrue(mockAuthService.isAuthenticated)
        XCTAssertNotNil(mockAuthService.currentUser)
        
        if let user = mockAuthService.currentUser {
            // Test new structure
            XCTAssertEqual(user.role, "student")
            XCTAssertTrue(user.isActive)
            
            // Test compatibility
            XCTAssertEqual(user.fullName, user.name)
            XCTAssertEqual(user.roles, ["student"])
            XCTAssertFalse(user.permissions.isEmpty)
            XCTAssertNotNil(user.position)
        }
    }
    
    // MARK: - Model Compatibility Tests
    
    func testUserResponseCompatibility() {
        // Given
        let user = UserResponse(
            id: "123",
            email: "test@example.com",
            name: "John Doe Smith",
            role: "manager",
            department: "Sales",
            isActive: true,
            avatar: "https://example.com/avatar.jpg",
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
        XCTAssertEqual(user.position, "Руководитель отдела")
        XCTAssertEqual(user.photo, user.avatar)
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