//
//  UserResponse+Compatibility.swift
//  LMS
//
//  Created by AI Assistant on 04/07/2025.
//
//  This extension provides backward compatibility for UserResponse
//  to support legacy code that expects firstName/lastName and roles array

import Foundation

extension UserResponse {
    
    // MARK: - Name Compatibility
    
    /// Full name for display
    var fullName: String {
        return name
    }
    
    // firstName and lastName are now direct properties in UserResponse
    // No need to extract from full name anymore
    
    // MARK: - Role Compatibility
    
    /// Roles array for backward compatibility
    var roles: [String] {
        return [role.rawValue]
    }
    
    // permissions are now direct property in UserResponse
    
    // MARK: - Additional Compatibility
    
    /// Registration date (using createdAt)
    var registrationDate: Date? {
        return createdAt
    }
    
    /// Photo URL (alias for avatar)
    var photo: String? {
        return avatarURL
    }
    
    // MARK: - Helper Methods
    
    /// Check if user has specific role
    func hasRole(_ roleName: String) -> Bool {
        return role.rawValue.lowercased() == roleName.lowercased()
    }
    
    /// Check if user has specific permission
    func hasPermission(_ permission: String) -> Bool {
        return permissions.contains(permission) || role.permissions.contains(permission)
    }
    
    /// Check if user is admin
    var isAdmin: Bool {
        return role == .admin || role == .superAdmin
    }
    
    /// Check if user is manager
    var isManager: Bool {
        return role == .manager
    }
    
    /// Check if user is student
    var isStudent: Bool {
        return role == .student
    }
    
    // position is now a direct property in UserResponse
}

// MARK: - Identifiable Conformance

extension UserResponse: Identifiable {
    // id property already exists in UserResponse
} 