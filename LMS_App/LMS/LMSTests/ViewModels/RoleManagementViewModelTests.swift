//
//  RoleManagementViewModelTests.swift
//  LMSTests
//
//  Created on 10/07/2025.
//

import XCTest
import Combine
@testable import LMS

final class RoleManagementViewModelTests: XCTestCase {
    private var sut: RoleManagementViewModel!
    private var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        sut = RoleManagementViewModel()
        cancellables = Set<AnyCancellable>()
    }
    
    override func tearDown() {
        cancellables = nil
        sut = nil
        super.tearDown()
    }
    
    // MARK: - Initialization Tests
    
    func testInitialization() {
        // Check initial state - ViewModel loads data on init
        XCTAssertNotNil(sut.roles)
        XCTAssertNotNil(sut.roleStatistics)
        // isLoading might be true due to auto-load in init
        // so we just check that errorMessage is nil
        XCTAssertNil(sut.errorMessage)
    }
    
    func testInitialDataLoad() {
        // Given initial state
        let expectation = XCTestExpectation(description: "Data loads on init")
        
        // When - wait for async operations
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            // Then - data should be loaded
            XCTAssertGreaterThan(self.sut.roles.count, 0)
            XCTAssertGreaterThan(self.sut.roleStatistics.count, 0)
            XCTAssertFalse(self.sut.isLoading)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    // MARK: - Load Tests
    
    func testLoadRoles() {
        // Given
        let expectation = XCTestExpectation(description: "Roles loaded")
        sut.roles = [] // Clear existing
        
        // When
        sut.loadRoles()
        
        // Then - should start loading
        XCTAssertTrue(sut.isLoading)
        
        // Wait for completion
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            // Should finish loading with mock data
            XCTAssertFalse(self.sut.isLoading)
            XCTAssertEqual(self.sut.roles.count, 4) // Mock returns 4 roles
            
            // Verify mock roles
            let roleNames = self.sut.roles.map { $0.name }
            XCTAssertTrue(roleNames.contains("Студент"))
            XCTAssertTrue(roleNames.contains("Преподаватель"))
            XCTAssertTrue(roleNames.contains("Администратор"))
            XCTAssertTrue(roleNames.contains("Супер администратор"))
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testLoadRoleStatistics() {
        // Given
        let expectation = XCTestExpectation(description: "Role statistics loaded")
        sut.roleStatistics = [] // Clear existing
        
        // When
        sut.loadRoleStatistics()
        
        // Wait for completion
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            // Should have loaded statistics
            XCTAssertEqual(self.sut.roleStatistics.count, 3) // Mock returns 3 stats
            
            // Verify mock statistics
            let statNames = self.sut.roleStatistics.map { $0.roleName }
            XCTAssertTrue(statNames.contains("Студенты"))
            XCTAssertTrue(statNames.contains("Преподаватели"))
            XCTAssertTrue(statNames.contains("Администраторы"))
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    // MARK: - Role Management Tests
    
    func testUpdateRolePermissions() {
        // Given
        let testRole = createMockRole(name: "Test Role")
        sut.roles = [testRole]
        let newPermissions = ["Read", "Write", "Delete"]
        
        // When
        sut.updateRolePermissions(testRole, permissions: newPermissions)
        
        // Then
        if let updatedRole = sut.roles.first(where: { $0.id == testRole.id }) {
            XCTAssertEqual(updatedRole.permissions, newPermissions)
        } else {
            XCTFail("Role not found after update")
        }
    }
    
    func testCreateRole() {
        // Given
        let initialCount = sut.roles.count
        let roleName = "New Role"
        let permissions = ["Permission 1", "Permission 2"]
        
        // When
        sut.createRole(name: roleName, permissions: permissions)
        
        // Then
        XCTAssertEqual(sut.roles.count, initialCount + 1)
        
        if let newRole = sut.roles.last {
            XCTAssertEqual(newRole.name, roleName)
            XCTAssertEqual(newRole.permissions, permissions)
            XCTAssertEqual(newRole.usersCount, 0)
        } else {
            XCTFail("New role not found")
        }
    }
    
    func testDeleteRole() {
        // Given
        let role1 = createMockRole(name: "Role 1")
        let role2 = createMockRole(name: "Role 2")
        let role3 = createMockRole(name: "Role 3")
        sut.roles = [role1, role2, role3]
        
        // When
        sut.deleteRole(role2)
        
        // Then
        XCTAssertEqual(sut.roles.count, 2)
        XCTAssertFalse(sut.roles.contains { $0.id == role2.id })
        XCTAssertTrue(sut.roles.contains { $0.id == role1.id })
        XCTAssertTrue(sut.roles.contains { $0.id == role3.id })
    }
    
    // MARK: - Multiple Operations Tests
    
    func testCreateMultipleRoles() {
        // Given
        let initialCount = sut.roles.count
        
        // When
        for i in 1...5 {
            sut.createRole(
                name: "Role \(i)",
                permissions: ["Permission \(i)"]
            )
        }
        
        // Then
        XCTAssertEqual(sut.roles.count, initialCount + 5)
    }
    
    func testUpdateMultipleRoles() {
        // Given
        let roles = (1...3).map { createMockRole(name: "Role \($0)") }
        sut.roles = roles
        let newPermissions = ["Updated Permission"]
        
        // When
        roles.forEach { role in
            sut.updateRolePermissions(role, permissions: newPermissions)
        }
        
        // Then
        sut.roles.forEach { role in
            XCTAssertEqual(role.permissions, newPermissions)
        }
    }
    
    func testDeleteAllRoles() {
        // Given
        let roles = (1...5).map { createMockRole(name: "Role \($0)") }
        sut.roles = roles
        
        // When
        roles.forEach { sut.deleteRole($0) }
        
        // Then
        XCTAssertTrue(sut.roles.isEmpty)
    }
    
    // MARK: - Edge Cases Tests
    
    func testUpdateNonExistentRole() {
        // Given
        let nonExistentRole = createMockRole(name: "Non-existent")
        let existingRole = createMockRole(name: "Existing")
        sut.roles = [existingRole]
        
        // When
        sut.updateRolePermissions(nonExistentRole, permissions: ["New Permission"])
        
        // Then - should not affect existing roles
        XCTAssertEqual(sut.roles.count, 1)
        XCTAssertEqual(sut.roles.first?.name, "Existing")
    }
    
    func testDeleteNonExistentRole() {
        // Given
        let nonExistentRole = createMockRole(name: "Non-existent")
        let existingRole = createMockRole(name: "Existing")
        sut.roles = [existingRole]
        
        // When
        sut.deleteRole(nonExistentRole)
        
        // Then - should not affect existing roles
        XCTAssertEqual(sut.roles.count, 1)
        XCTAssertTrue(sut.roles.contains { $0.id == existingRole.id })
    }
    
    func testCreateRoleWithEmptyName() {
        // Given
        let initialCount = sut.roles.count
        
        // When
        sut.createRole(name: "", permissions: ["Permission"])
        
        // Then - should still create (no validation in current implementation)
        XCTAssertEqual(sut.roles.count, initialCount + 1)
    }
    
    func testCreateRoleWithEmptyPermissions() {
        // Given
        let initialCount = sut.roles.count
        
        // When
        sut.createRole(name: "Empty Permissions Role", permissions: [])
        
        // Then
        XCTAssertEqual(sut.roles.count, initialCount + 1)
        
        if let newRole = sut.roles.last {
            XCTAssertTrue(newRole.permissions.isEmpty)
        }
    }
    
    // MARK: - Mock Data Verification Tests
    
    func testMockDataContent() {
        // Given - wait for initial load
        let expectation = XCTestExpectation(description: "Mock data loaded")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            // Verify Student role
            if let studentRole = self.sut.roles.first(where: { $0.name == "Студент" }) {
                XCTAssertEqual(studentRole.permissions.count, 4)
                XCTAssertEqual(studentRole.usersCount, 1_234)
                XCTAssertTrue(studentRole.permissions.contains("Просмотр курсов"))
            } else {
                XCTFail("Student role not found")
            }
            
            // Verify Administrator role
            if let adminRole = self.sut.roles.first(where: { $0.name == "Администратор" }) {
                XCTAssertEqual(adminRole.permissions.count, 5)
                XCTAssertEqual(adminRole.usersCount, 5)
                XCTAssertTrue(adminRole.permissions.contains("Управление пользователями"))
            } else {
                XCTFail("Administrator role not found")
            }
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testMockStatisticsContent() {
        // Given - wait for initial load
        let expectation = XCTestExpectation(description: "Mock statistics loaded")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            // Verify statistics
            let totalCount = self.sut.roleStatistics.reduce(0) { $0 + $1.count }
            XCTAssertEqual(totalCount, 1_286) // 1234 + 45 + 7
            
            if let studentStat = self.sut.roleStatistics.first(where: { $0.roleName == "Студенты" }) {
                XCTAssertEqual(studentStat.count, 1_234)
            }
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    // MARK: - Error State Tests
    
    func testErrorMessageHandling() {
        // Given
        sut.errorMessage = nil
        
        // When - set error
        sut.errorMessage = "Test error"
        
        // Then
        XCTAssertNotNil(sut.errorMessage)
        XCTAssertEqual(sut.errorMessage, "Test error")
        
        // When - clear error
        sut.errorMessage = nil
        
        // Then
        XCTAssertNil(sut.errorMessage)
    }
    
    // MARK: - Helper Methods
    
    private func createMockRole(
        name: String,
        permissions: [String] = ["Default Permission"],
        usersCount: Int = 0
    ) -> Role {
        Role(
            name: name,
            permissions: permissions,
            usersCount: usersCount
        )
    }
} 