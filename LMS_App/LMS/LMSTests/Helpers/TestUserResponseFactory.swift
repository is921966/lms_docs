//
//  TestUserResponseFactory.swift
//  LMSTests
//
//  Created by LMS Team on 13.01.2025.
//

import Foundation
@testable import LMS

/// Factory for creating test UserResponse objects
enum TestUserResponseFactory {
    
    /// Create a user with custom parameters
    static func createUser(
        id: String = UUID().uuidString,
        email: String = "test@example.com",
        name: String = "Test User",
        role: UserRole = .student,
        isActive: Bool = true,
        createdAt: Date = Date()
    ) -> UserResponse {
        return UserResponse(
            id: id,
            email: email,
            name: name,
            role: role,
            isActive: isActive,
            createdAt: createdAt
        )
    }
    
    /// Create a student user
    static func createStudent(
        id: String = UUID().uuidString,
        name: String = "Student User"
    ) -> UserResponse {
        return createUser(
            id: id,
            email: "student@test.com",
            name: name,
            role: .student
        )
    }
    
    /// Create an instructor user
    static func createInstructor(
        id: String = UUID().uuidString,
        name: String = "Instructor User"
    ) -> UserResponse {
        return createUser(
            id: id,
            email: "instructor@test.com",
            name: name,
            role: .instructor
        )
    }
    
    /// Create an admin user
    static func createAdmin(
        id: String = UUID().uuidString,
        name: String = "Admin User"
    ) -> UserResponse {
        return createUser(
            id: id,
            email: "admin@test.com",
            name: name,
            role: .admin
        )
    }
    
    /// Create a manager user
    static func createManager(
        id: String = UUID().uuidString,
        name: String = "Manager User"
    ) -> UserResponse {
        return createUser(
            id: id,
            email: "manager@test.com",
            name: name,
            role: .manager
        )
    }
} 