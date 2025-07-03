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
    
    /// First name extracted from full name
    var firstName: String {
        let components = name.split(separator: " ")
        return String(components.first ?? "")
    }
    
    /// Last name extracted from full name
    var lastName: String {
        let components = name.split(separator: " ")
        if components.count > 1 {
            return components.dropFirst().joined(separator: " ")
        }
        return ""
    }
    
    /// Middle name for compatibility (always empty)
    var middleName: String? {
        return nil
    }
    
    // MARK: - Role Compatibility
    
    /// Roles array for backward compatibility
    var roles: [String] {
        return [role]
    }
    
    /// Permissions array (derived from role)
    var permissions: [String] {
        switch role.lowercased() {
        case "admin", "superadmin":
            return ["manage_users", "manage_courses", "manage_tests", "view_analytics", "access_courses"]
        case "manager":
            return ["view_analytics", "manage_team", "access_courses"]
        case "student":
            return ["access_courses", "view_progress"]
        default:
            return []
        }
    }
    
    // MARK: - Additional Compatibility
    
    /// Registration date (using createdAt)
    var registrationDate: Date? {
        return createdAt
    }
    
    /// Photo URL (alias for avatar)
    var photo: String? {
        return avatar
    }
    
    // MARK: - Helper Methods
    
    /// Check if user has specific role
    func hasRole(_ roleName: String) -> Bool {
        return role.lowercased() == roleName.lowercased()
    }
    
    /// Check if user has specific permission
    func hasPermission(_ permission: String) -> Bool {
        return permissions.contains(permission)
    }
    
    /// Check if user is admin
    var isAdmin: Bool {
        return role.lowercased() == "admin" || role.lowercased() == "superadmin"
    }
    
    /// Check if user is manager
    var isManager: Bool {
        return role.lowercased() == "manager"
    }
    
    /// Check if user is student
    var isStudent: Bool {
        return role.lowercased() == "student"
    }
    
    /// Position (derived from role or department)
    var position: String? {
        switch role.lowercased() {
        case "admin":
            return "Администратор"
        case "manager":
            return "Руководитель отдела"
        case "student":
            return "Сотрудник"
        default:
            return department
        }
    }
}

// MARK: - Identifiable Conformance

extension UserResponse: Identifiable {
    // id property already exists in UserResponse
} 