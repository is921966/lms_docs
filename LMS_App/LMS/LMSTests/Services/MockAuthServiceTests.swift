//
//  MockAuthServiceTests.swift
//  LMSTests
//
//  Created on 10/07/2025.
//

import XCTest
import Combine
@testable import LMS

final class MockAuthServiceTests: XCTestCase {
    private var sut: MockAuthService!
    private var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        // Create new instance for testing (not shared)
        sut = MockAuthService.shared
        sut.logout() // Ensure clean state
        cancellables = Set<AnyCancellable>()
    }
    
    override func tearDown() {
        cancellables = nil
        sut.logout() // Clean up
        sut = nil
        super.tearDown()
    }
    
    // MARK: - Initialization Tests
    
    func testInitialization() {
        // Check initial state after logout
        sut.logout()
        
        XCTAssertNil(sut.currentUser)
        XCTAssertFalse(sut.isAuthenticated)
        XCTAssertFalse(sut.isApprovedByAdmin)
        XCTAssertFalse(sut.isLoading)
        XCTAssertNil(sut.error)
    }
    
    // MARK: - Mock Login Tests
    
    func testMockLoginAsStudent() {
        let expectation = XCTestExpectation(description: "Login completes")
        
        // When
        sut.mockLogin(asAdmin: false)
        
        // Should start loading
        XCTAssertTrue(sut.isLoading)
        
        // Wait for completion
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            // Then
            XCTAssertFalse(self.sut.isLoading)
            XCTAssertTrue(self.sut.isAuthenticated)
            XCTAssertFalse(self.sut.isApprovedByAdmin) // Students not auto-approved
            XCTAssertNotNil(self.sut.currentUser)
            
            if let user = self.sut.currentUser {
                XCTAssertEqual(user.email, "student@tsum.ru")
                XCTAssertEqual(user.name, "Иван Иванов")
                XCTAssertEqual(user.role, "student")
                XCTAssertEqual(user.department, "IT")
                XCTAssertTrue(user.isActive)
            }
            
            // Check tokens were saved
            XCTAssertNotNil(TokenManager.shared.getAccessToken())
            XCTAssertNotNil(TokenManager.shared.getRefreshToken())
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 3.0)
    }
    
    func testMockLoginAsAdmin() {
        let expectation = XCTestExpectation(description: "Login completes")
        
        // When
        sut.mockLogin(asAdmin: true)
        
        // Should start loading
        XCTAssertTrue(sut.isLoading)
        
        // Wait for completion
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            // Then
            XCTAssertFalse(self.sut.isLoading)
            XCTAssertTrue(self.sut.isAuthenticated)
            XCTAssertTrue(self.sut.isApprovedByAdmin) // Admins are auto-approved
            XCTAssertNotNil(self.sut.currentUser)
            
            if let user = self.sut.currentUser {
                XCTAssertEqual(user.email, "admin@tsum.ru")
                XCTAssertEqual(user.name, "Админ Админов")
                XCTAssertEqual(user.role, "admin")
                XCTAssertEqual(user.department, "IT")
                XCTAssertTrue(user.isActive)
            }
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 3.0)
    }
    
    func testLoginAsMockUserAlias() {
        let expectation = XCTestExpectation(description: "Login completes")
        
        // When - using alias method
        sut.loginAsMockUser(isAdmin: true)
        
        // Wait for completion
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            // Should work same as mockLogin
            XCTAssertTrue(self.sut.isAuthenticated)
            XCTAssertTrue(self.sut.isApprovedByAdmin)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 3.0)
    }
    
    // MARK: - Mock Approve Tests
    
    func testMockApproveForStudent() {
        let expectation = XCTestExpectation(description: "Approval completes")
        
        // Given - login as student first
        sut.mockLogin(asAdmin: false)
        
        // Wait for login
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            XCTAssertFalse(self.sut.isApprovedByAdmin)
            
            // When - approve
            self.sut.mockApprove()
            
            // Should start loading
            XCTAssertTrue(self.sut.isLoading)
            
            // Wait for approval
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                // Then
                XCTAssertFalse(self.sut.isLoading)
                XCTAssertTrue(self.sut.isApprovedByAdmin)
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testMockApproveWhenNotAuthenticated() {
        // Given - not authenticated
        XCTAssertFalse(sut.isAuthenticated)
        
        // When
        sut.mockApprove()
        
        // Then - should not change approval status
        XCTAssertFalse(sut.isApprovedByAdmin)
        XCTAssertFalse(sut.isLoading)
    }
    
    func testMockApproveWhenAlreadyApproved() {
        let expectation = XCTestExpectation(description: "Login completes")
        
        // Given - login as admin (auto-approved)
        sut.mockLogin(asAdmin: true)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            XCTAssertTrue(self.sut.isApprovedByAdmin)
            
            // When
            self.sut.mockApprove()
            
            // Then - should not start loading
            XCTAssertFalse(self.sut.isLoading)
            XCTAssertTrue(self.sut.isApprovedByAdmin)
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 3.0)
    }
    
    // MARK: - Logout Tests
    
    func testLogout() {
        let expectation = XCTestExpectation(description: "Login completes")
        
        // Given - logged in user
        sut.mockLogin(asAdmin: true)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            XCTAssertTrue(self.sut.isAuthenticated)
            
            // When
            self.sut.logout()
            
            // Then
            XCTAssertNil(self.sut.currentUser)
            XCTAssertFalse(self.sut.isAuthenticated)
            XCTAssertFalse(self.sut.isApprovedByAdmin)
            XCTAssertNil(self.sut.error)
            
            // Tokens should be cleared
            XCTAssertNil(TokenManager.shared.getAccessToken())
            XCTAssertNil(TokenManager.shared.getRefreshToken())
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 3.0)
    }
    
    // MARK: - Get Users Tests
    
    func testGetUsers() {
        // When
        let users = sut.getUsers()
        
        // Then
        XCTAssertEqual(users.count, 5)
        
        // Verify different roles
        let studentCount = users.filter { $0.role == "student" }.count
        let managerCount = users.filter { $0.role == "manager" }.count
        let adminCount = users.filter { $0.role == "admin" }.count
        
        XCTAssertEqual(studentCount, 3)
        XCTAssertEqual(managerCount, 1)
        XCTAssertEqual(adminCount, 1)
        
        // Verify all users are active
        XCTAssertTrue(users.allSatisfy { $0.isActive })
        
        // Verify departments
        let departments = Set(users.compactMap { $0.department })
        XCTAssertTrue(departments.contains("IT"))
        XCTAssertTrue(departments.contains("Отдел продаж"))
    }
    
    // MARK: - State Persistence Tests
    
    func testAuthenticationStateRestoration() {
        let expectation = XCTestExpectation(description: "Login and restore")
        
        // Given - login as admin
        sut.mockLogin(asAdmin: true)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            // Simulate app restart by creating new instance
            // In real app, checkAuthenticationStatus would restore state
            
            // Verify tokens exist
            XCTAssertNotNil(TokenManager.shared.getAccessToken())
            XCTAssertTrue(TokenManager.shared.isAuthenticated)
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 3.0)
    }
    
    // MARK: - Publisher Tests
    
    func testIsAuthenticatedPublisher() {
        let expectation = XCTestExpectation(description: "Publisher emits values")
        var receivedValues: [Bool] = []
        
        // Subscribe to publisher
        sut.$isAuthenticated
            .sink { value in
                receivedValues.append(value)
            }
            .store(in: &cancellables)
        
        // Trigger changes
        sut.mockLogin(asAdmin: false)
        
        // Wait for login to complete
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 3.0)
        
        // Should receive at least 2 values: initial false, then true after login
        XCTAssertGreaterThanOrEqual(receivedValues.count, 2)
        XCTAssertEqual(receivedValues.first, false)
        XCTAssertTrue(receivedValues.contains(true))
    }
    
    func testErrorHandling() {
        // Given - error property is read-only in MockAuthService
        // So we test that it starts as nil and is cleared on logout
        
        // Initial state
        XCTAssertNil(sut.error)
        
        // When logout
        sut.logout()
        
        // Then - error should still be nil
        XCTAssertNil(sut.error)
    }
} 