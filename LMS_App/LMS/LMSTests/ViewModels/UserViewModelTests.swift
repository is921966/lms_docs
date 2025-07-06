//
//  UserViewModelTests.swift
//  LMSTests
//
//  Created on 06/07/2025.
//

import XCTest
import Combine
@testable import LMS

// MARK: - Mock User Service for ViewModel Tests
class MockUserServiceForViewModel: UserServiceProtocol {
    var mockUsers: [User] = [
        User(id: UUID(), email: "john.doe@example.com", name: "John Doe", role: .student, avatarURL: nil),
        User(id: UUID(), email: "jane.smith@example.com", name: "Jane Smith", role: .instructor, avatarURL: nil),
        User(id: UUID(), email: "admin@example.com", name: "Admin User", role: .admin, avatarURL: nil),
        User(id: UUID(), email: "super@example.com", name: "Super Admin", role: .superAdmin, avatarURL: nil),
        User(id: UUID(), email: "alice.johnson@example.com", name: "Alice Johnson", role: .student, avatarURL: nil),
        User(id: UUID(), email: "bob.wilson@example.com", name: "Bob Wilson", role: .student, avatarURL: nil),
        User(id: UUID(), email: "carol.davis@example.com", name: "Carol Davis", role: .instructor, avatarURL: nil),
        User(id: UUID(), email: "david.brown@example.com", name: "David Brown", role: .student, avatarURL: nil),
    ]
    
    func fetchUsers() async throws -> [User] {
        return mockUsers
    }
    
    func fetchUser(id: UUID) async throws -> User {
        guard let user = mockUsers.first(where: { $0.id == id }) else {
            throw UserError.notFound
        }
        return user
    }
    
    func createUser(_ user: User) async throws -> User {
        mockUsers.append(user)
        return user
    }
    
    func updateUser(_ user: User) async throws -> User {
        guard let index = mockUsers.firstIndex(where: { $0.id == user.id }) else {
            throw UserError.notFound
        }
        mockUsers[index] = user
        return user
    }
    
    func deleteUser(_ id: UUID) async throws {
        mockUsers.removeAll { $0.id == id }
    }
}

@MainActor
final class UserViewModelTests: XCTestCase {
    
    var viewModel: UserViewModel!
    var mockService: MockUserServiceForViewModel!
    var cancellables: Set<AnyCancellable> = []
    
    override func setUp() async throws {
        try await super.setUp()
        mockService = MockUserServiceForViewModel()
        viewModel = UserViewModel(userService: mockService)
        cancellables = []
    }
    
    override func tearDown() {
        viewModel = nil
        mockService = nil
        cancellables.removeAll()
        super.tearDown()
    }
    
    // MARK: - Initialization Tests
    
    func testInitialState() {
        XCTAssertTrue(viewModel.users.isEmpty)
        XCTAssertTrue(viewModel.filteredUsers.isEmpty)
        XCTAssertEqual(viewModel.searchText, "")
        XCTAssertNil(viewModel.selectedRole)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertTrue(viewModel.selectedUsers.isEmpty)
        XCTAssertFalse(viewModel.isSelectionMode)
    }
    
    // MARK: - Loading Tests
    
    func testLoadUsers() async {
        // Load users
        await viewModel.loadUsers()
        
        // Verify
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertFalse(viewModel.users.isEmpty)
        XCTAssertEqual(viewModel.users.count, viewModel.filteredUsers.count)
        XCTAssertNil(viewModel.errorMessage)
    }
    
    func testRefreshUsers() async {
        // Initial load
        await viewModel.loadUsers()
        let initialCount = viewModel.users.count
        
        // Refresh
        await viewModel.refreshUsers()
        
        // Should have same users
        XCTAssertEqual(viewModel.users.count, initialCount)
        XCTAssertFalse(viewModel.isLoading)
    }
    
    // MARK: - Filtering Tests
    
    func testSearchFiltering() async {
        // Load users
        await viewModel.loadUsers()
        
        // Search by name
        viewModel.searchText = "John"
        
        // Wait for debounce
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        // Verify
        XCTAssertTrue(viewModel.filteredUsers.contains { $0.name.contains("John") })
        XCTAssertFalse(viewModel.filteredUsers.contains { !$0.name.contains("John") && !$0.email.contains("John") })
    }
    
    func testEmailSearchFiltering() async {
        // Load users
        await viewModel.loadUsers()
        
        // Search by email
        viewModel.searchText = "admin@"
        
        // Wait for debounce
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        // Verify
        XCTAssertTrue(viewModel.filteredUsers.contains { $0.email.contains("admin@") })
        XCTAssertEqual(viewModel.filteredUsers.count, 1)
    }
    
    func testRoleFiltering() async {
        // Load users
        await viewModel.loadUsers()
        
        // Filter by role
        viewModel.selectedRole = .student
        
        // Wait for filter to apply
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        // Verify
        XCTAssertTrue(viewModel.filteredUsers.allSatisfy { $0.role == .student })
    }
    
    func testCombinedFiltering() async {
        // Load users
        await viewModel.loadUsers()
        
        // Apply multiple filters
        viewModel.searchText = "John"
        viewModel.selectedRole = .student
        
        // Wait for filters
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        // Verify
        XCTAssertTrue(viewModel.filteredUsers.allSatisfy { 
            $0.name.contains("John") && $0.role == .student
        })
    }
    
    func testClearFilters() async {
        // Load and filter
        await viewModel.loadUsers()
        viewModel.searchText = "Test"
        viewModel.selectedRole = .admin
        
        // Clear filters
        viewModel.searchText = ""
        viewModel.selectedRole = nil
        
        // Wait
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        // Should show all users
        XCTAssertEqual(viewModel.filteredUsers.count, viewModel.users.count)
    }
    
    // MARK: - User Management Tests
    
    func testDeleteUser() async {
        // Load users
        await viewModel.loadUsers()
        let initialCount = viewModel.users.count
        guard let userToDelete = viewModel.users.first else {
            XCTFail("No users to delete")
            return
        }
        
        // Delete user
        await viewModel.deleteUser(userToDelete)
        
        // Verify
        XCTAssertEqual(viewModel.users.count, initialCount - 1)
        XCTAssertFalse(viewModel.users.contains { $0.id == userToDelete.id })
        XCTAssertFalse(viewModel.filteredUsers.contains { $0.id == userToDelete.id })
    }
    
    // MARK: - Selection Tests
    
    func testToggleUserSelection() async {
        // Load users
        await viewModel.loadUsers()
        guard let user = viewModel.users.first else {
            XCTFail("No users available")
            return
        }
        
        // Select user
        viewModel.toggleUserSelection(user)
        XCTAssertTrue(viewModel.selectedUsers.contains(user.id))
        
        // Deselect user
        viewModel.toggleUserSelection(user)
        XCTAssertFalse(viewModel.selectedUsers.contains(user.id))
    }
    
    func testSelectAll() async {
        // Load users
        await viewModel.loadUsers()
        
        // Select all
        viewModel.selectAll()
        
        // Verify
        XCTAssertEqual(viewModel.selectedUsers.count, viewModel.filteredUsers.count)
        XCTAssertTrue(viewModel.filteredUsers.allSatisfy { viewModel.selectedUsers.contains($0.id) })
    }
    
    func testDeselectAll() async {
        // Load users and select all
        await viewModel.loadUsers()
        viewModel.selectAll()
        
        // Deselect all
        viewModel.deselectAll()
        
        // Verify
        XCTAssertTrue(viewModel.selectedUsers.isEmpty)
    }
    
    func testDeleteSelectedUsers() async {
        // Load users
        await viewModel.loadUsers()
        let initialCount = viewModel.users.count
        
        // Select some users
        viewModel.isSelectionMode = true
        let usersToDelete = Array(viewModel.users.prefix(2))
        usersToDelete.forEach { viewModel.toggleUserSelection($0) }
        
        // Delete selected
        await viewModel.deleteSelectedUsers()
        
        // Verify
        XCTAssertEqual(viewModel.users.count, initialCount - 2)
        XCTAssertTrue(viewModel.selectedUsers.isEmpty)
        XCTAssertFalse(viewModel.isSelectionMode)
        usersToDelete.forEach { user in
            XCTAssertFalse(viewModel.users.contains { $0.id == user.id })
        }
    }
    
    // MARK: - Error Handling Tests
    
    func testErrorMessage() {
        // Set error
        viewModel.errorMessage = "Test error"
        XCTAssertEqual(viewModel.errorMessage, "Test error")
        
        // Clear error on load
        Task {
            await viewModel.loadUsers()
        }
        
        // Error should be cleared
        let expectation = XCTestExpectation(description: "Error cleared")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            XCTAssertNil(self.viewModel.errorMessage)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
    }
    
    // MARK: - Selection Mode Tests
    
    func testSelectionMode() {
        // Enable selection mode
        viewModel.isSelectionMode = true
        XCTAssertTrue(viewModel.isSelectionMode)
        
        // Disable selection mode
        viewModel.isSelectionMode = false
        XCTAssertFalse(viewModel.isSelectionMode)
    }
    
    func testSelectionModeWithFilters() async {
        // Load and filter users
        await viewModel.loadUsers()
        viewModel.selectedRole = .student
        
        // Enable selection and select all
        viewModel.isSelectionMode = true
        viewModel.selectAll()
        
        // Verify only filtered users are selected
        let studentCount = viewModel.filteredUsers.filter { $0.role == .student }.count
        XCTAssertEqual(viewModel.selectedUsers.count, studentCount)
    }
} 