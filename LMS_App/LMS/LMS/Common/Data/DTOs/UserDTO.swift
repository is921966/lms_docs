//
//  UserDTO.swift
//  LMS
//
//  Created by AI Assistant on 02/01/25.
//
//  Copyright © 2025 LMS. All rights reserved.
//

import Foundation

// MARK: - User DTO

/// Data Transfer Object for User entity
public struct UserDTO: DataTransferObject {
    public let id: String
    public let email: String
    public let firstName: String
    public let lastName: String
    public let role: String
    public let isActive: Bool
    public let profileImageUrl: String?
    public let phoneNumber: String?
    public let department: String?
    public let position: String?
    public let createdAt: String // ISO 8601 date string
    public let updatedAt: String // ISO 8601 date string
    public let lastLoginAt: String? // ISO 8601 date string
    
    public init(
        id: String,
        email: String,
        firstName: String,
        lastName: String,
        role: String,
        isActive: Bool = true,
        profileImageUrl: String? = nil,
        phoneNumber: String? = nil,
        department: String? = nil,
        position: String? = nil,
        createdAt: String,
        updatedAt: String,
        lastLoginAt: String? = nil
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
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.lastLoginAt = lastLoginAt
    }
    
    public func validationErrors() -> [String] {
        var errors: [String] = []
        
        // ID validation
        if id.isEmpty {
            errors.append("User ID cannot be empty")
        }
        
        // Email validation
        if email.isEmpty {
            errors.append("Email cannot be empty")
        } else if !isValidEmail(email) {
            errors.append("Email format is invalid")
        }
        
        // Name validation
        if firstName.isEmpty {
            errors.append("First name cannot be empty")
        }
        
        if lastName.isEmpty {
            errors.append("Last name cannot be empty")
        }
        
        // Role validation
        let validRoles = ["student", "teacher", "admin", "manager"]
        if !validRoles.contains(role.lowercased()) {
            errors.append("Invalid role: \(role). Must be one of: \(validRoles.joined(separator: ", "))")
        }
        
        // Phone number validation
        if let phone = phoneNumber, !phone.isEmpty, !isValidPhoneNumber(phone) {
            errors.append("Phone number format is invalid")
        }
        
        // URL validation
        if let imageUrl = profileImageUrl, !imageUrl.isEmpty, !isValidURL(imageUrl) {
            errors.append("Profile image URL is invalid")
        }
        
        // Date validation
        if !isValidISO8601Date(createdAt) {
            errors.append("Created date format is invalid")
        }
        
        if !isValidISO8601Date(updatedAt) {
            errors.append("Updated date format is invalid")
        }
        
        if let lastLogin = lastLoginAt, !isValidISO8601Date(lastLogin) {
            errors.append("Last login date format is invalid")
        }
        
        return errors
    }
    
    // MARK: - Private Validation Methods
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    private func isValidPhoneNumber(_ phone: String) -> Bool {
        let phoneRegex = "^\\+?[0-9]{10,15}$"
        let phonePredicate = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
        return phonePredicate.evaluate(with: phone.components(separatedBy: CharacterSet.decimalDigits.inverted).joined())
    }
    
    private func isValidURL(_ urlString: String) -> Bool {
        guard let url = URL(string: urlString) else { return false }
        return url.scheme == "http" || url.scheme == "https"
    }
    
    private func isValidISO8601Date(_ dateString: String) -> Bool {
        let formatter = ISO8601DateFormatter()
        return formatter.date(from: dateString) != nil
    }
}

// MARK: - User Profile DTO

/// Simplified DTO for user profile information
public struct UserProfileDTO: DataTransferObject {
    public let id: String
    public let firstName: String
    public let lastName: String
    public let email: String
    public let profileImageUrl: String?
    public let department: String?
    public let position: String?
    
    public init(
        id: String,
        firstName: String,
        lastName: String,
        email: String,
        profileImageUrl: String? = nil,
        department: String? = nil,
        position: String? = nil
    ) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.profileImageUrl = profileImageUrl
        self.department = department
        self.position = position
    }
    
    public func validationErrors() -> [String] {
        var errors: [String] = []
        
        if id.isEmpty {
            errors.append("User ID cannot be empty")
        }
        
        if firstName.isEmpty {
            errors.append("First name cannot be empty")
        }
        
        if lastName.isEmpty {
            errors.append("Last name cannot be empty")
        }
        
        if email.isEmpty {
            errors.append("Email cannot be empty")
        }
        
        return errors
    }
}

// MARK: - User Creation DTO

/// DTO for creating new users
public struct CreateUserDTO: DataTransferObject {
    public let email: String
    public let firstName: String
    public let lastName: String
    public let role: String
    public let phoneNumber: String?
    public let department: String?
    public let position: String?
    public let password: String?
    
    public init(
        email: String,
        firstName: String,
        lastName: String,
        role: String,
        phoneNumber: String? = nil,
        department: String? = nil,
        position: String? = nil,
        password: String? = nil
    ) {
        self.email = email
        self.firstName = firstName
        self.lastName = lastName
        self.role = role
        self.phoneNumber = phoneNumber
        self.department = department
        self.position = position
        self.password = password
    }
    
    public func validationErrors() -> [String] {
        var errors: [String] = []
        
        if email.isEmpty {
            errors.append("Email cannot be empty")
        }
        
        if firstName.isEmpty {
            errors.append("First name cannot be empty")
        }
        
        if lastName.isEmpty {
            errors.append("Last name cannot be empty")
        }
        
        if role.isEmpty {
            errors.append("Role cannot be empty")
        }
        
        // Password validation (if provided)
        if let pwd = password, !pwd.isEmpty {
            if pwd.count < 8 {
                errors.append("Password must be at least 8 characters long")
            }
        }
        
        return errors
    }
}

// MARK: - User Update DTO

/// DTO for updating user information
public struct UpdateUserDTO: DataTransferObject {
    public let firstName: String?
    public let lastName: String?
    public let phoneNumber: String?
    public let department: String?
    public let position: String?
    public let profileImageUrl: String?
    public let isActive: Bool?
    
    public init(
        firstName: String? = nil,
        lastName: String? = nil,
        phoneNumber: String? = nil,
        department: String? = nil,
        position: String? = nil,
        profileImageUrl: String? = nil,
        isActive: Bool? = nil
    ) {
        self.firstName = firstName
        self.lastName = lastName
        self.phoneNumber = phoneNumber
        self.department = department
        self.position = position
        self.profileImageUrl = profileImageUrl
        self.isActive = isActive
    }
    
    public func validationErrors() -> [String] {
        var errors: [String] = []
        
        // Validate only non-nil fields
        if let firstName = firstName, firstName.isEmpty {
            errors.append("First name cannot be empty")
        }
        
        if let lastName = lastName, lastName.isEmpty {
            errors.append("Last name cannot be empty")
        }
        
        if let phone = phoneNumber, !phone.isEmpty {
            let phoneRegex = "^\\+?[0-9]{10,15}$"
            let phonePredicate = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
            let cleanPhone = phone.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
            if !phonePredicate.evaluate(with: cleanPhone) {
                errors.append("Phone number format is invalid")
            }
        }
        
        if let imageUrl = profileImageUrl, !imageUrl.isEmpty {
            guard let url = URL(string: imageUrl) else {
                errors.append("Profile image URL is invalid")
                return errors
            }
            if url.scheme != "http" && url.scheme != "https" {
                errors.append("Profile image URL must use HTTP or HTTPS")
            }
        }
        
        return errors
    }
} 