//
//  RoleManagementViewModelTests.swift
//  LMSTests
//
//  Created on 06/07/2025.
//

import XCTest
import Combine
@testable import LMS

final class RoleManagementViewModelTests: XCTestCase {
    
    var viewModel: RoleManagementViewModel!
    var cancellables: Set<AnyCancellable> = []
    
    override func setUp() {
        super.setUp()
        viewModel = RoleManagementViewModel()
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
        XCTAssertFalse(viewModel.roles.isEmpty)
        XCTAssertFalse(viewModel.roleStatistics.isEmpty)
    }
    
    // MARK: - Loading Tests
    
    func testLoadRoles() {
        // Clear initial data
        viewModel.roles = []
        
        // Start loading
        viewModel.loadRoles()
        XCTAssertTrue(viewModel.isLoading)
        
        // Wait for load
        let expectation = XCTestExpectation(description: "Roles loaded")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
        
        // Verify loaded data
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertEqual(viewModel.roles.count, 4)
        
        // Verify specific roles
        XCTAssertTrue(viewModel.roles.contains { $0.name == "Студент" })
        XCTAssertTrue(viewModel.roles.contains { $0.name == "Преподаватель" })
        XCTAssertTrue(viewModel.roles.contains { $0.name == "Администратор" })
        XCTAssertTrue(viewModel.roles.contains { $0.name == "Супер администратор" })
    }
    
    func testLoadRoleStatistics() {
        // Clear initial data
        viewModel.roleStatistics = []
        
        // Load statistics
        viewModel.loadRoleStatistics()
        
        // Wait for load
        let expectation = XCTestExpectation(description: "Statistics loaded")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 0.5)
        
        // Verify statistics
        XCTAssertEqual(viewModel.roleStatistics.count, 3)
        XCTAssertTrue(viewModel.roleStatistics.contains { $0.roleName == "Студенты" })
        XCTAssertTrue(viewModel.roleStatistics.contains { $0.roleName == "Преподаватели" })
        XCTAssertTrue(viewModel.roleStatistics.contains { $0.roleName == "Администраторы" })
    }
    
    // MARK: - CRUD Tests
    
    func testUpdateRolePermissions() {
        // Wait for initial load
        let loadExpectation = XCTestExpectation(description: "Initial load")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            loadExpectation.fulfill()
        }
        wait(for: [loadExpectation], timeout: 1)
        
        // Get first role
        guard let role = viewModel.roles.first else {
            XCTFail("No roles available")
            return
        }
        
        // Update permissions
        let newPermissions = ["New Permission 1", "New Permission 2"]
        viewModel.updateRolePermissions(role, permissions: newPermissions)
        
        // Verify update
        let updatedRole = viewModel.roles.first { $0.id == role.id }
        XCTAssertEqual(updatedRole?.permissions, newPermissions)
    }
    
    func testCreateRole() {
        // Wait for initial load
        let loadExpectation = XCTestExpectation(description: "Initial load")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            loadExpectation.fulfill()
        }
        wait(for: [loadExpectation], timeout: 1)
        
        let initialCount = viewModel.roles.count
        
        // Create new role
        let roleName = "Test Role"
        let permissions = ["Permission 1", "Permission 2", "Permission 3"]
        viewModel.createRole(name: roleName, permissions: permissions)
        
        // Verify creation
        XCTAssertEqual(viewModel.roles.count, initialCount + 1)
        XCTAssertTrue(viewModel.roles.contains { $0.name == roleName })
        
        let newRole = viewModel.roles.first { $0.name == roleName }
        XCTAssertNotNil(newRole)
        XCTAssertEqual(newRole?.permissions, permissions)
        XCTAssertEqual(newRole?.usersCount, 0)
    }
    
    func testDeleteRole() {
        // Wait for initial load
        let loadExpectation = XCTestExpectation(description: "Initial load")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            loadExpectation.fulfill()
        }
        wait(for: [loadExpectation], timeout: 1)
        
        // Get initial count and role to delete
        let initialCount = viewModel.roles.count
        guard let roleToDelete = viewModel.roles.first else {
            XCTFail("No roles available")
            return
        }
        
        // Delete role
        viewModel.deleteRole(roleToDelete)
        
        // Verify deletion
        XCTAssertEqual(viewModel.roles.count, initialCount - 1)
        XCTAssertFalse(viewModel.roles.contains { $0.id == roleToDelete.id })
    }
    
    // MARK: - Role Data Tests
    
    func testRolePermissions() {
        // Wait for initial load
        let loadExpectation = XCTestExpectation(description: "Initial load")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            loadExpectation.fulfill()
        }
        wait(for: [loadExpectation], timeout: 1)
        
        // Verify student role permissions
        let studentRole = viewModel.roles.first { $0.name == "Студент" }
        XCTAssertNotNil(studentRole)
        XCTAssertEqual(studentRole?.permissions.count, 4)
        XCTAssertTrue(studentRole?.permissions.contains("Просмотр курсов") ?? false)
        
        // Verify teacher role has more permissions
        let teacherRole = viewModel.roles.first { $0.name == "Преподаватель" }
        XCTAssertNotNil(teacherRole)
        XCTAssertEqual(teacherRole?.permissions.count, 5)
        
        // Verify admin has admin permissions
        let adminRole = viewModel.roles.first { $0.name == "Администратор" }
        XCTAssertNotNil(adminRole)
        XCTAssertTrue(adminRole?.permissions.contains("Управление пользователями") ?? false)
    }
    
    func testRoleUserCounts() {
        // Wait for initial load
        let loadExpectation = XCTestExpectation(description: "Initial load")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            loadExpectation.fulfill()
        }
        wait(for: [loadExpectation], timeout: 1)
        
        // Verify user counts
        let studentRole = viewModel.roles.first { $0.name == "Студент" }
        XCTAssertEqual(studentRole?.usersCount, 1234)
        
        let teacherRole = viewModel.roles.first { $0.name == "Преподаватель" }
        XCTAssertEqual(teacherRole?.usersCount, 45)
        
        let adminRole = viewModel.roles.first { $0.name == "Администратор" }
        XCTAssertEqual(adminRole?.usersCount, 5)
        
        let superAdminRole = viewModel.roles.first { $0.name == "Супер администратор" }
        XCTAssertEqual(superAdminRole?.usersCount, 2)
    }
} 