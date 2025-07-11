//
//  UserManagementViewModelTests.swift
//  LMSTests
//
//  Created on 06/07/2025.
//

import XCTest
import Combine
@testable import LMS

final class UserManagementViewModelTests: XCTestCase {
    
    var viewModel: UserManagementViewModel!
    var cancellables: Set<AnyCancellable> = []
    
    override func setUp() {
        super.setUp()
        viewModel = UserManagementViewModel()
        cancellables = []
    }
    
    override func tearDown() {
        viewModel = nil
        cancellables.removeAll()
        super.tearDown()
    }
    
    // MARK: - Initialization Tests
    
    func testInitialState() {
        // Initially loading
        XCTAssertTrue(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
        
        // Wait for load to complete
        let expectation = XCTestExpectation(description: "Initial load")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
        
        // After load
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNotNil(viewModel.users)
        XCTAssertNotNil(viewModel.pendingUsers)
    }
    
    // MARK: - Loading Tests
    
    func testLoadUsers() {
        // Clear initial data
        viewModel.users = [createMockUser(name: "Test")]
        
        // Start loading
        viewModel.loadUsers()
        XCTAssertTrue(viewModel.isLoading)
        
        // Wait for load
        let expectation = XCTestExpectation(description: "Users loaded")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
        
        // Verify loaded data (mock returns empty array)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertTrue(viewModel.users.isEmpty)
    }
    
    func testLoadPendingUsers() {
        // Set initial data
        viewModel.pendingUsers = [createMockUser(name: "Pending")]
        
        // Load pending users
        viewModel.loadPendingUsers()
        
        // Wait for load
        let expectation = XCTestExpectation(description: "Pending users loaded")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 0.5)
        
        // Verify loaded data (mock returns empty array)
        XCTAssertTrue(viewModel.pendingUsers.isEmpty)
    }
    
    // MARK: - User Management Tests
    
    func testApproveUser() {
        // Setup
        let user = createMockUser(name: "New User")
        viewModel.pendingUsers = [user]
        viewModel.users = []
        
        // Approve user
        viewModel.approveUser(user)
        
        // Verify
        XCTAssertFalse(viewModel.pendingUsers.contains { $0.id == user.id })
        XCTAssertTrue(viewModel.users.contains { $0.id == user.id })
    }
    
    func testRejectUser() {
        // Setup
        let user = createMockUser(name: "Rejected User")
        viewModel.pendingUsers = [user]
        
        // Reject user
        viewModel.rejectUser(user)
        
        // Verify
        XCTAssertFalse(viewModel.pendingUsers.contains { $0.id == user.id })
        XCTAssertFalse(viewModel.users.contains { $0.id == user.id })
    }
    
    func testDeleteUser() {
        // Setup
        let user = createMockUser(name: "User to Delete")
        viewModel.users = [user]
        
        // Delete user
        viewModel.deleteUser(user)
        
        // Verify
        XCTAssertFalse(viewModel.users.contains { $0.id == user.id })
    }
    
    // MARK: - Multiple Operations Tests
    
    func testApproveMultipleUsers() {
        // Setup
        let users = (1...3).map { createMockUser(name: "User \($0)") }
        viewModel.pendingUsers = users
        viewModel.users = []
        
        // Approve all users
        users.forEach { viewModel.approveUser($0) }
        
        // Verify
        XCTAssertTrue(viewModel.pendingUsers.isEmpty)
        XCTAssertEqual(viewModel.users.count, 3)
    }
    
    func testMixedOperations() {
        // Setup
        let user1 = createMockUser(name: "User 1")
        let user2 = createMockUser(name: "User 2")
        let user3 = createMockUser(name: "User 3")
        viewModel.pendingUsers = [user1, user2]
        viewModel.users = [user3]
        
        // Mixed operations
        viewModel.approveUser(user1)
        viewModel.rejectUser(user2)
        viewModel.deleteUser(user3)
        
        // Verify
        XCTAssertTrue(viewModel.pendingUsers.isEmpty)
        XCTAssertEqual(viewModel.users.count, 1)
        XCTAssertTrue(viewModel.users.contains { $0.id == user1.id })
    }
    
    // MARK: - Edge Cases
    
    func testApproveNonExistentUser() {
        // Setup
        let user = createMockUser(name: "Non-existent")
        viewModel.pendingUsers = []
        viewModel.users = []
        
        // Try to approve
        viewModel.approveUser(user)
        
        // Verify - should add to users even if not in pending
        XCTAssertTrue(viewModel.users.contains { $0.id == user.id })
    }
    
    func testDeleteNonExistentUser() {
        // Setup
        let user = createMockUser(name: "Non-existent")
        let existingUser = createMockUser(name: "Existing")
        viewModel.users = [existingUser]
        
        // Try to delete
        viewModel.deleteUser(user)
        
        // Verify - existing users should remain
        XCTAssertEqual(viewModel.users.count, 1)
        XCTAssertTrue(viewModel.users.contains { $0.id == existingUser.id })
    }
    
    // MARK: - Error State Tests
    
    func testErrorMessageHandling() {
        // Set error
        viewModel.errorMessage = "Test error"
        XCTAssertNotNil(viewModel.errorMessage)
        XCTAssertEqual(viewModel.errorMessage, "Test error")
        
        // Clear error
        viewModel.errorMessage = nil
        XCTAssertNil(viewModel.errorMessage)
    }
    
    // MARK: - Helper Methods
    
    private func createMockUser(name: String) -> UserResponse {
        let firstName = name.components(separatedBy: " ").first ?? name
        let lastName = name.components(separatedBy: " ").dropFirst().joined(separator: " ")
        
        return UserResponse(
            id: UUID().uuidString,
            email: "\(name.lowercased().replacingOccurrences(of: " ", with: "."))@test.com",
            name: name,
            role: .student,
            firstName: firstName.isEmpty ? nil : firstName,
            lastName: lastName.isEmpty ? nil : lastName,
            isActive: true,
            createdAt: Date(),
            updatedAt: Date()
        )
    }
} 