//
//  AuthViewModelTests.swift
//  LMSTests
//
//  Created on 06/07/2025.
//

import XCTest
import Combine
@testable import LMS

@MainActor
final class AuthViewModelTests: XCTestCase {
    
    var viewModel: AuthViewModel!
    var mockAuthService: LMS.MockAuthService!
    var cancellables: Set<AnyCancellable> = []
    
    override func setUp() async throws {
        try await super.setUp()
        mockAuthService = LMS.MockAuthService.shared
        viewModel = AuthViewModel(authService: mockAuthService)
        cancellables = []
        // Reset auth service state
        try await mockAuthService.logout()
    }
    
    override func tearDown() async throws {
        try await mockAuthService.logout()
        viewModel = nil
        mockAuthService = nil
        cancellables.removeAll()
        try await super.tearDown()
    }
    
    // MARK: - Initialization Tests
    
    func testInitialState() {
        XCTAssertNil(viewModel.currentUser)
        XCTAssertFalse(viewModel.isAuthenticated)
        XCTAssertFalse(viewModel.isAdmin)
        XCTAssertFalse(viewModel.isSuperAdmin)
    }
    
    // MARK: - Authentication Tests
    
    func testAuthenticationBinding() async throws {
        // When auth service becomes authenticated
        _ = try await mockAuthService.login(email: "test@example.com", password: "password")
        
        // Then viewModel should reflect this
        // Wait a bit for bindings to update
        try await Task.sleep(nanoseconds: 100_000_000) // 0.1 second
        
        XCTAssertTrue(viewModel.isAuthenticated)
        XCTAssertNotNil(viewModel.currentUser)
    }
    
    func testUserBinding() async throws {
        // Login to create user
        let result = try await mockAuthService.login(email: "test@example.com", password: "password")
        
        // Wait for binding
        try await Task.sleep(nanoseconds: 100_000_000) // 0.1 second
        
        XCTAssertNotNil(viewModel.currentUser)
        XCTAssertEqual(viewModel.currentUser?.email, result.user.email)
        XCTAssertEqual(viewModel.currentUser?.role, result.user.role)
    }
    
    // MARK: - Role Tests
    
    func testStudentRole() async throws {
        // Login as student
        _ = try await mockAuthService.login(email: "student@test.com", password: "password")
        
        // Wait and verify
        try await Task.sleep(nanoseconds: 100_000_000) // 0.1 second
        
        XCTAssertEqual(viewModel.currentUser?.role, .student)
        XCTAssertFalse(viewModel.isAdmin)
        XCTAssertFalse(viewModel.isSuperAdmin)
    }
    
    func testInstructorRole() async throws {
        // Login as instructor
        _ = try await mockAuthService.login(email: "instructor@test.com", password: "password")
        
        // Wait for binding
        try await Task.sleep(nanoseconds: 100_000_000) // 0.1 second
        
        XCTAssertEqual(viewModel.currentUser?.role, .instructor)
        XCTAssertFalse(viewModel.isAdmin)
        XCTAssertFalse(viewModel.isSuperAdmin)
    }
    
    func testAdminRole() async throws {
        // Login as admin
        _ = try await mockAuthService.login(email: "admin@test.com", password: "password")
        
        // Wait and verify
        try await Task.sleep(nanoseconds: 100_000_000)
        
        XCTAssertEqual(viewModel.currentUser?.role, .admin)
        XCTAssertTrue(viewModel.isAdmin)
        XCTAssertFalse(viewModel.isSuperAdmin)
    }
    
    func testSuperAdminRole() async throws {
        // Login as super admin
        _ = try await mockAuthService.login(email: "superadmin@test.com", password: "password")
        
        // Wait and verify
        try await Task.sleep(nanoseconds: 100_000_000)
        
        XCTAssertEqual(viewModel.currentUser?.role, .superAdmin)
        XCTAssertTrue(viewModel.isAdmin)
        XCTAssertTrue(viewModel.isSuperAdmin)
    }
    
    // MARK: - Manager Role Test
    
    func testManagerRole() async throws {
        // Login as manager
        _ = try await mockAuthService.login(email: "manager@test.com", password: "password")
        
        // Manager should not be considered admin
        try await Task.sleep(nanoseconds: 100_000_000)
        
        XCTAssertEqual(viewModel.currentUser?.role, .manager)
        XCTAssertFalse(viewModel.isAdmin)
        XCTAssertFalse(viewModel.isSuperAdmin)
    }
    
    // MARK: - Logout Tests
    
    func testLogout() async throws {
        // Setup authenticated user
        _ = try await mockAuthService.login(email: "admin@test.com", password: "password")
        
        // Wait for initial setup
        try await Task.sleep(nanoseconds: 100_000_000)
        
        XCTAssertTrue(viewModel.isAuthenticated)
        XCTAssertNotNil(viewModel.currentUser)
        XCTAssertEqual(viewModel.currentUser?.role, .admin)
        
        // Perform logout
        try await mockAuthService.logout()
        
        // Wait for logout to propagate
        try await Task.sleep(nanoseconds: 100_000_000)
        
        // Verify logout
        XCTAssertNil(viewModel.currentUser)
        XCTAssertFalse(viewModel.isAuthenticated)
        XCTAssertFalse(viewModel.isAdmin)
        XCTAssertFalse(viewModel.isSuperAdmin)
    }
} 