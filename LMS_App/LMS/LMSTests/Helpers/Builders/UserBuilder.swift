//
//  UserBuilder.swift
//  LMSTests
//
//  Created by AI Assistant on 03/07/2025.
//  Sprint 28: Test Quality Improvement
//

import Foundation
@testable import LMS

/// Builder pattern для создания тестовых пользователей
/// Упрощает создание UserResponse с различными конфигурациями
class UserBuilder {
    private var id = UUID().uuidString
    private var email = "test@lms.com"
    private var name = "Test User"
    private var role = "student"
    private var department: String? = nil
    private var isActive = true
    private var avatar: String? = nil
    private var createdAt = Date()
    private var updatedAt = Date()
    
    // MARK: - Basic Properties
    
    func withId(_ id: String) -> UserBuilder {
        self.id = id
        return self
    }
    
    func withEmail(_ email: String) -> UserBuilder {
        self.email = email
        return self
    }
    
    func withName(_ name: String) -> UserBuilder {
        self.name = name
        return self
    }
    
    func withDepartment(_ department: String?) -> UserBuilder {
        self.department = department
        return self
    }
    
    func withAvatar(_ avatar: String) -> UserBuilder {
        self.avatar = avatar
        return self
    }
    
    // MARK: - Role Presets
    
    func asAdmin() -> UserBuilder {
        self.role = "admin"
        self.department = "IT"
        self.email = "admin@lms.com"
        self.name = "Admin User"
        return self
    }
    
    func asStudent() -> UserBuilder {
        self.role = "student"
        self.department = nil
        self.email = "student@lms.com"
        self.name = "Student User"
        return self
    }
    
    func asInstructor() -> UserBuilder {
        self.role = "instructor"
        self.department = "Education"
        self.email = "instructor@lms.com"
        self.name = "Instructor User"
        return self
    }
    
    func asManager() -> UserBuilder {
        self.role = "manager"
        self.department = "HR"
        self.email = "manager@lms.com"
        self.name = "Manager User"
        return self
    }
    
    // MARK: - State Modifiers
    
    func inactive() -> UserBuilder {
        self.isActive = false
        return self
    }
    
    func active() -> UserBuilder {
        self.isActive = true
        return self
    }
    
    func createdDaysAgo(_ days: Int) -> UserBuilder {
        self.createdAt = Calendar.current.date(byAdding: .day, value: -days, to: Date()) ?? Date()
        return self
    }
    
    func updatedDaysAgo(_ days: Int) -> UserBuilder {
        self.updatedAt = Calendar.current.date(byAdding: .day, value: -days, to: Date()) ?? Date()
        return self
    }
    
    // MARK: - Build Method
    
    func build() -> UserResponse {
        return UserResponse(
            id: id,
            email: email,
            name: name,
            role: role,
            department: department,
            isActive: isActive,
            avatar: avatar,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
    
    // MARK: - Convenience Methods
    
    /// Creates multiple users with incremental IDs
    static func createMultiple(count: Int, builder: (UserBuilder) -> UserBuilder = { $0 }) -> [UserResponse] {
        return (1...count).map { index in
            builder(UserBuilder().withId("USER_\(index)")).build()
        }
    }
    
    /// Creates a standard test admin
    static var testAdmin: UserResponse {
        return UserBuilder().asAdmin().build()
    }
    
    /// Creates a standard test student
    static var testStudent: UserResponse {
        return UserBuilder().asStudent().build()
    }
    
    /// Creates a standard test instructor
    static var testInstructor: UserResponse {
        return UserBuilder().asInstructor().build()
    }
} 