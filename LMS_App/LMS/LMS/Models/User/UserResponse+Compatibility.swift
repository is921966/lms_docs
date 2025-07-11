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
    
    // firstName and lastName are direct properties in UserResponse
    // These computed properties provide the logic for extracting from name when needed
    
    /// Get effective first name - from firstName property or extracted from name
    var effectiveFirstName: String {
        if let firstName = self.firstName, !firstName.isEmpty {
            return firstName
        }
        // Extract from name field
        let trimmedName = name.trimmingCharacters(in: .whitespaces)
        let components = trimmedName.components(separatedBy: .whitespaces).filter { !$0.isEmpty }
        return components.first ?? ""
    }
    
    /// Get effective last name - from lastName property or extracted from name
    var effectiveLastName: String {
        if let lastName = self.lastName, !lastName.isEmpty {
            return lastName
        }
        // Extract from name field
        let trimmedName = name.trimmingCharacters(in: .whitespaces)
        let components = trimmedName.components(separatedBy: .whitespaces).filter { !$0.isEmpty }
        if components.count > 1 {
            return components.dropFirst().joined(separator: " ")
        }
        return ""
    }
    
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