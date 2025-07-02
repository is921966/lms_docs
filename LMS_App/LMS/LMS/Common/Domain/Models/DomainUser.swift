//
//  DomainUser.swift
//  LMS
//
//  Created by AI Assistant on 02/01/25.
//
//  Copyright © 2025 LMS. All rights reserved.
//

import Foundation

// MARK: - Domain User Model

/// Domain model for User entity
/// This is the core business entity with all business rules
public struct DomainUser: Identifiable, Equatable, Hashable {
    
    // MARK: - Properties
    
    public let id: String
    public let email: String
    public var firstName: String
    public var lastName: String
    public let role: DomainUserRole
    public var isActive: Bool
    public var profileImageUrl: String?
    public var phoneNumber: String?
    public var department: String?
    public var position: String?
    public var lastLoginAt: Date?
    public let createdAt: Date
    public var updatedAt: Date
    
    // MARK: - Computed Properties
    
    /// Full name combining first and last name
    public var fullName: String {
        return "\(firstName) \(lastName)".trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    /// Initials from first and last name
    public var initials: String {
        let firstInitial = firstName.first?.uppercased() ?? ""
        let lastInitial = lastName.first?.uppercased() ?? ""
        return "\(firstInitial)\(lastInitial)"
    }
    
    /// Check if user has admin privileges
    public var isAdmin: Bool {
        return role == .admin || role == .superAdmin
    }
    
    /// Check if user is recently active (within last 30 days)
    public var isRecentlyActive: Bool {
        guard let lastLogin = lastLoginAt else { return false }
        let thirtyDaysAgo = Calendar.current.date(byAdding: .day, value: -30, to: Date()) ?? Date()
        return lastLogin >= thirtyDaysAgo
    }
    
    // MARK: - Initialization
    
    public init(
        id: String,
        email: String,
        firstName: String,
        lastName: String,
        role: DomainUserRole,
        isActive: Bool = true,
        profileImageUrl: String? = nil,
        phoneNumber: String? = nil,
        department: String? = nil,
        position: String? = nil,
        lastLoginAt: Date? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.email = email
        self.firstName = firstName
        self.lastName = lastName
        self.role = role
        self.isActive = isActive
        self.profileImageUrl = profileImageUrl
        self.phoneNumber = phoneNumber
        self.department = department
        self.position = position
        self.lastLoginAt = lastLoginAt
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    // MARK: - Business Methods
    
    /// Update user's last login time
    public mutating func updateLastLogin() {
        self.lastLoginAt = Date()
        self.updatedAt = Date()
    }
    
    /// Activate the user
    public mutating func activate() {
        self.isActive = true
        self.updatedAt = Date()
    }
    
    /// Deactivate the user
    public mutating func deactivate() {
        self.isActive = false
        self.updatedAt = Date()
    }
    
    /// Update user profile information
    public mutating func updateProfile(
        firstName: String? = nil,
        lastName: String? = nil,
        phoneNumber: String? = nil,
        profileImageUrl: String? = nil,
        department: String? = nil,
        position: String? = nil
    ) {
        if let firstName = firstName {
            self.firstName = firstName
        }
        if let lastName = lastName {
            self.lastName = lastName
        }
        if let phoneNumber = phoneNumber {
            self.phoneNumber = phoneNumber
        }
        if let profileImageUrl = profileImageUrl {
            self.profileImageUrl = profileImageUrl
        }
        if let department = department {
            self.department = department
        }
        if let position = position {
            self.position = position
        }
        self.updatedAt = Date()
    }
    
    /// Check if user can perform admin actions
    public func canPerformAdminActions() -> Bool {
        return isActive && isAdmin
    }
    
    /// Check if user can access specific department data
    public func canAccessDepartment(_ targetDepartment: String) -> Bool {
        // Admins can access all departments
        if isAdmin {
            return true
        }
        
        // Users can access their own department
        return department == targetDepartment
    }
    
    /// Validate user data
    public func validate() -> [String] {
        var errors: [String] = []
        
        if id.isEmpty {
            errors.append("User ID cannot be empty")
        }
        
        if email.isEmpty {
            errors.append("Email cannot be empty")
        } else if !isValidEmail(email) {
            errors.append("Email format is invalid")
        }
        
        if firstName.isEmpty {
            errors.append("First name cannot be empty")
        }
        
        if lastName.isEmpty {
            errors.append("Last name cannot be empty")
        }
        
        if let phone = phoneNumber, !phone.isEmpty, !isValidPhoneNumber(phone) {
            errors.append("Phone number format is invalid")
        }
        
        if let url = profileImageUrl, !url.isEmpty, !isValidURL(url) {
            errors.append("Profile image URL is invalid")
        }
        
        return errors
    }
    
    // MARK: - Private Helpers
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = #"^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: email)
    }
    
    private func isValidPhoneNumber(_ phone: String) -> Bool {
        let phoneRegex = #"^\+?[1-9]\d{1,14}$"#
        return NSPredicate(format: "SELF MATCHES %@", phoneRegex).evaluate(with: phone)
    }
    
    private func isValidURL(_ url: String) -> Bool {
        return URL(string: url) != nil
    }
}

// MARK: - Domain User Role

/// Domain representation of user roles
public enum DomainUserRole: String, CaseIterable, Codable, Hashable {
    case student = "student"
    case teacher = "teacher"
    case admin = "admin"
    case superAdmin = "superAdmin"
    case manager = "manager"
    case hr = "hr"
    
    /// Display name for the role
    public var displayName: String {
        switch self {
        case .student:
            return "Student"
        case .teacher:
            return "Teacher"
        case .admin:
            return "Administrator"
        case .superAdmin:
            return "Super Administrator"
        case .manager:
            return "Manager"
        case .hr:
            return "HR"
        }
    }
    
    /// Check if role has admin privileges
    public var isAdminRole: Bool {
        return self == .admin || self == .superAdmin
    }
    
    /// Check if role can manage users
    public var canManageUsers: Bool {
        return isAdminRole || self == .manager || self == .hr
    }
    
    /// Check if role can create content
    public var canCreateContent: Bool {
        return isAdminRole || self == .teacher
    }
    
    /// Permission level (higher number = more permissions)
    public var permissionLevel: Int {
        switch self {
        case .student:
            return 1
        case .teacher:
            return 2
        case .hr:
            return 2
        case .manager:
            return 3
        case .admin:
            return 4
        case .superAdmin:
            return 5
        }
    }
    
    /// Check if this role has higher or equal permissions than another role
    public func hasPermissionLevel(of otherRole: DomainUserRole) -> Bool {
        return self.permissionLevel >= otherRole.permissionLevel
    }
}

// MARK: - Factory Methods

public extension DomainUser {
    /// Create a new student user
    static func createStudent(
        id: String,
        email: String,
        firstName: String,
        lastName: String,
        department: String? = nil
    ) -> DomainUser {
        return DomainUser(
            id: id,
            email: email,
            firstName: firstName,
            lastName: lastName,
            role: .student,
            department: department
        )
    }
    
    /// Create a new teacher user
    static func createTeacher(
        id: String,
        email: String,
        firstName: String,
        lastName: String,
        department: String? = nil
    ) -> DomainUser {
        return DomainUser(
            id: id,
            email: email,
            firstName: firstName,
            lastName: lastName,
            role: .teacher,
            department: department
        )
    }
    
    /// Create a new admin user
    static func createAdmin(
        id: String,
        email: String,
        firstName: String,
        lastName: String
    ) -> DomainUser {
        return DomainUser(
            id: id,
            email: email,
            firstName: firstName,
            lastName: lastName,
            role: .admin
        )
    }
} 