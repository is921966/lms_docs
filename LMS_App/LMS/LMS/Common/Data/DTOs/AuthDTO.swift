//
//  AuthDTO.swift
//  LMS
//
//  Created by AI Assistant on 30/06/25.
//
//  Copyright © 2025 LMS. All rights reserved.
//

import Foundation

// MARK: - Validation Helpers

/// Email validation helper
private func isValidEmail(_ email: String) -> Bool {
    let emailRegex = "^[A-Z0-9._%+-]+@[A-Z0-9.-]+\\.[A-Z]{2,}$"
    let emailPredicate = NSPredicate(format: "SELF MATCHES[c] %@", emailRegex)
    return emailPredicate.evaluate(with: email)
}

/// ISO8601 date validation helper
private func isValidISO8601Date(_ dateString: String) -> Bool {
    let formatter = ISO8601DateFormatter()
    return formatter.date(from: dateString) != nil
}

// MARK: - Login DTO

/// DTO for user login requests
public struct LoginRequestDTO: DataTransferObject, Codable {
    public let email: String
    public let password: String
    public let rememberMe: Bool
    public let deviceId: String?
    
    public init(
        email: String,
        password: String,
        rememberMe: Bool = false,
        deviceId: String? = nil
    ) {
        self.email = email
        self.password = password
        self.rememberMe = rememberMe
        self.deviceId = deviceId
    }
    
    public func validationErrors() -> [String] {
        var errors: [String] = []
        
        // Email validation
        if email.isEmpty {
            errors.append("Email is required")
        } else if !isValidEmail(email) {
            errors.append("Email format is invalid")
        }
        
        // Password validation
        if password.isEmpty {
            errors.append("Password is required")
        } else if password.count < 6 {
            errors.append("Password must be at least 6 characters")
        }
        
        return errors
    }
}

// MARK: - Auth User Profile DTO (for login response)

/// Simplified user profile for authentication responses
public struct AuthUserProfileDTO: DataTransferObject, Codable {
    public let id: String
    public let email: String
    public let firstName: String
    public let lastName: String
    public let role: String
    public let isActive: Bool
    public let profileImageUrl: String?
    
    public init(
        id: String,
        email: String,
        firstName: String,
        lastName: String,
        role: String,
        isActive: Bool,
        profileImageUrl: String? = nil
    ) {
        self.id = id
        self.email = email
        self.firstName = firstName
        self.lastName = lastName
        self.role = role
        self.isActive = isActive
        self.profileImageUrl = profileImageUrl
    }
    
    public func validationErrors() -> [String] {
        var errors: [String] = []
        
        if id.isEmpty {
            errors.append("User ID is required")
        }
        
        if email.isEmpty {
            errors.append("Email is required")
        }
        
        if firstName.isEmpty {
            errors.append("First name is required")
        }
        
        if lastName.isEmpty {
            errors.append("Last name is required")
        }
        
        if role.isEmpty {
            errors.append("Role is required")
        }
        
        return errors
    }
}

// MARK: - Login Response DTO

/// DTO for login response
public struct LoginResponseDTO: DataTransferObject, Codable {
    public let accessToken: String
    public let refreshToken: String
    public let expiresAt: String // ISO8601 format
    public let tokenType: String
    public let user: AuthUserProfileDTO
    
    public init(
        accessToken: String,
        refreshToken: String,
        expiresAt: String,
        tokenType: String = "Bearer",
        user: AuthUserProfileDTO
    ) {
        self.accessToken = accessToken
        self.refreshToken = refreshToken
        self.expiresAt = expiresAt
        self.tokenType = tokenType
        self.user = user
    }
    
    public func validationErrors() -> [String] {
        var errors: [String] = []
        
        if accessToken.isEmpty {
            errors.append("Access token is required")
        }
        
        if refreshToken.isEmpty {
            errors.append("Refresh token is required")
        }
        
        if expiresAt.isEmpty {
            errors.append("Token expiry date is required")
        } else if !isValidISO8601Date(expiresAt) {
            errors.append("Token expiry date must be in ISO8601 format")
        }
        
        if tokenType.isEmpty {
            errors.append("Token type is required")
        }
        
        // Validate nested user profile
        errors.append(contentsOf: user.validationErrors())
        
        return errors
    }
}

// MARK: - Token Refresh DTO

/// DTO for token refresh requests
public struct TokenRefreshRequestDTO: DataTransferObject, Codable {
    public let refreshToken: String
    public let deviceId: String?
    
    public init(refreshToken: String, deviceId: String? = nil) {
        self.refreshToken = refreshToken
        self.deviceId = deviceId
    }
    
    public func validationErrors() -> [String] {
        var errors: [String] = []
        
        if refreshToken.isEmpty {
            errors.append("Refresh token is required")
        }
        
        return errors
    }
}

/// DTO for token refresh response
public struct TokenRefreshResponseDTO: DataTransferObject, Codable {
    public let accessToken: String
    public let refreshToken: String
    public let expiresAt: String // ISO8601 format
    public let tokenType: String
    
    public init(
        accessToken: String,
        refreshToken: String,
        expiresAt: String,
        tokenType: String = "Bearer"
    ) {
        self.accessToken = accessToken
        self.refreshToken = refreshToken
        self.expiresAt = expiresAt
        self.tokenType = tokenType
    }
    
    public func validationErrors() -> [String] {
        var errors: [String] = []
        
        if accessToken.isEmpty {
            errors.append("Access token is required")
        }
        
        if refreshToken.isEmpty {
            errors.append("Refresh token is required")
        }
        
        if expiresAt.isEmpty {
            errors.append("Token expiry date is required")
        } else if !isValidISO8601Date(expiresAt) {
            errors.append("Token expiry date must be in ISO8601 format")
        }
        
        if tokenType.isEmpty {
            errors.append("Token type is required")
        }
        
        return errors
    }
}

// MARK: - Auth Status DTO

/// DTO for authentication status
public struct AuthStatusDTO: DataTransferObject, Codable {
    public let isAuthenticated: Bool
    public let user: AuthUserProfileDTO?
    public let tokenExpiresAt: String? // ISO8601 format
    public let lastLoginAt: String? // ISO8601 format
    
    public init(
        isAuthenticated: Bool,
        user: AuthUserProfileDTO? = nil,
        tokenExpiresAt: String? = nil,
        lastLoginAt: String? = nil
    ) {
        self.isAuthenticated = isAuthenticated
        self.user = user
        self.tokenExpiresAt = tokenExpiresAt
        self.lastLoginAt = lastLoginAt
    }
    
    public func validationErrors() -> [String] {
        var errors: [String] = []
        
        // If authenticated, user should be present
        if isAuthenticated && user == nil {
            errors.append("User profile is required when authenticated")
        }
        
        // Validate token expiry format if present
        if let expiresAt = tokenExpiresAt, !isValidISO8601Date(expiresAt) {
            errors.append("Token expiry date must be in ISO8601 format")
        }
        
        // Validate last login format if present
        if let lastLogin = lastLoginAt, !isValidISO8601Date(lastLogin) {
            errors.append("Last login date must be in ISO8601 format")
        }
        
        // Validate nested user profile if present
        if let user = user {
            errors.append(contentsOf: user.validationErrors())
        }
        
        return errors
    }
}

// MARK: - Logout DTO

/// DTO for logout requests
public struct LogoutRequestDTO: DataTransferObject, Codable {
    public let refreshToken: String?
    public let deviceId: String?
    public let logoutAllDevices: Bool
    
    public init(
        refreshToken: String? = nil,
        deviceId: String? = nil,
        logoutAllDevices: Bool = false
    ) {
        self.refreshToken = refreshToken
        self.deviceId = deviceId
        self.logoutAllDevices = logoutAllDevices
    }
    
    public func validationErrors() -> [String] {
        // No required fields for logout
        return []
    }
}

// MARK: - Helper Extensions

extension LoginRequestDTO: Encodable {}
extension LoginResponseDTO: Decodable {}
extension TokensDTO: Codable {}
extension RefreshTokenRequestDTO: Encodable {}
extension TokenResponseDTO: Decodable {}
extension LogoutRequestDTO: Encodable {}
extension AuthStatusDTO: Codable {} 