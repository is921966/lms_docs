//
//  AuthMapper.swift
//  LMS
//
//  Created by AI Assistant on 30/06/25.
//
//  Copyright © 2025 LMS. All rights reserved.
//

import Foundation

// MARK: - Auth Mapper

/// Mapper for converting between Auth DTOs and domain models
public struct AuthMapper {
    
    // MARK: - DTO to Domain
    
    /// Convert LoginResponseDTO to DomainUser
    /// - Parameter dto: LoginResponseDTO instance
    /// - Returns: DomainUser if conversion successful
    public static func toDomainUser(from dto: LoginResponseDTO) -> DomainUser? {
        return DomainUserMapper.toDomain(from: UserDTO(
            id: dto.user.id,
            email: dto.user.email,
            firstName: dto.user.firstName,
            lastName: dto.user.lastName,
            role: dto.user.role,
            department: nil, // Not available in auth response
            position: nil,   // Not available in auth response
            phoneNumber: nil, // Not available in auth response
            isActive: dto.user.isActive,
            profileImageUrl: dto.user.profileImageUrl,
            lastLoginAt: nil, // Will be updated separately
            createdAt: Date().ISO8601Format(), // Current date as fallback
            updatedAt: Date().ISO8601Format()  // Current date as fallback
        ))
    }
    
    /// Convert AuthUserProfileDTO to DomainUser
    /// - Parameter dto: AuthUserProfileDTO instance
    /// - Returns: DomainUser if conversion successful
    public static func toDomainUser(from dto: AuthUserProfileDTO) -> DomainUser? {
        return DomainUserMapper.toDomain(from: UserDTO(
            id: dto.id,
            email: dto.email,
            firstName: dto.firstName,
            lastName: dto.lastName,
            role: dto.role,
            department: nil,
            position: nil,
            phoneNumber: nil,
            isActive: dto.isActive,
            profileImageUrl: dto.profileImageUrl,
            lastLoginAt: nil,
            createdAt: Date().ISO8601Format(),
            updatedAt: Date().ISO8601Format()
        ))
    }
    
    /// Convert TokensDTO to TokenManager format
    /// - Parameter dto: TokensDTO instance
    /// - Returns: Tuple of access and refresh tokens
    public static func toTokens(from dto: TokensDTO) -> (accessToken: String, refreshToken: String) {
        return (accessToken: dto.accessToken, refreshToken: dto.refreshToken)
    }
    
    /// Convert TokenResponseDTO to TokenManager format
    /// - Parameter dto: TokenResponseDTO instance
    /// - Returns: Tuple of access and refresh tokens
    public static func toTokens(from dto: TokenResponseDTO) -> (accessToken: String, refreshToken: String) {
        return (accessToken: dto.accessToken, refreshToken: dto.refreshToken)
    }
    
    /// Convert AuthStatusDTO to authentication state
    /// - Parameter dto: AuthStatusDTO instance
    /// - Returns: Tuple of authentication status and user
    public static func toAuthState(from dto: AuthStatusDTO) -> (isAuthenticated: Bool, user: DomainUser?) {
        let user = dto.user.flatMap { userProfileDTO in
            DomainUserMapper.toDomain(from: UserDTO(
                id: userProfileDTO.id,
                email: userProfileDTO.email,
                firstName: userProfileDTO.firstName,
                lastName: userProfileDTO.lastName,
                role: "student", // Default role
                isActive: true,
                profileImageUrl: userProfileDTO.profileImageUrl,
                phoneNumber: nil,
                department: userProfileDTO.department,
                position: userProfileDTO.position,
                createdAt: ISO8601DateFormatter().string(from: Date()),
                updatedAt: ISO8601DateFormatter().string(from: Date()),
                lastLoginAt: nil
            ))
        }
        
        return (isAuthenticated: dto.isAuthenticated, user: user)
    }
    
    // MARK: - Domain to DTO
    
    /// Convert DomainUser to AuthUserProfileDTO
    /// - Parameter user: DomainUser instance
    /// - Returns: AuthUserProfileDTO
    public static func toAuthUserProfileDTO(from user: DomainUser) -> AuthUserProfileDTO {
        return AuthUserProfileDTO(
            id: user.id,
            email: user.email,
            firstName: user.firstName,
            lastName: user.lastName,
            role: user.role.rawValue,
            isActive: user.isActive,
            profileImageUrl: user.profileImageUrl
        )
    }
    
    /// Create LoginRequestDTO from credentials
    /// - Parameters:
    ///   - email: User email
    ///   - password: User password
    ///   - rememberMe: Remember me flag
    ///   - deviceId: Optional device ID
    /// - Returns: LoginRequestDTO
    public static func createLoginRequest(
        email: String,
        password: String,
        rememberMe: Bool = false,
        deviceId: String? = nil
    ) -> LoginRequestDTO {
        return LoginRequestDTO(
            email: email,
            password: password,
            rememberMe: rememberMe,
            deviceId: deviceId
        )
    }
    
    /// Create RefreshTokenRequestDTO from token
    /// - Parameters:
    ///   - refreshToken: Refresh token
    ///   - deviceId: Optional device ID
    /// - Returns: RefreshTokenRequestDTO
    public static func createRefreshRequest(
        refreshToken: String,
        deviceId: String? = nil
    ) -> RefreshTokenRequestDTO {
        return RefreshTokenRequestDTO(
            refreshToken: refreshToken,
            deviceId: deviceId
        )
    }
    
    /// Create LogoutRequestDTO
    /// - Parameters:
    ///   - deviceId: Optional device ID
    ///   - logoutAllDevices: Logout all devices flag
    /// - Returns: LogoutRequestDTO
    public static func createLogoutRequest(
        deviceId: String? = nil,
        logoutAllDevices: Bool = false
    ) -> LogoutRequestDTO {
        return LogoutRequestDTO(
            deviceId: deviceId,
            logoutAllDevices: logoutAllDevices
        )
    }
    
    /// Create AuthStatusDTO from current state
    /// - Parameters:
    ///   - isAuthenticated: Authentication status
    ///   - user: Current user (optional)
    ///   - tokenExpiresAt: Token expiry date (optional)
    ///   - needsRefresh: Needs refresh flag
    /// - Returns: AuthStatusDTO
    public static func createAuthStatus(
        isAuthenticated: Bool,
        user: DomainUser? = nil,
        tokenExpiresAt: Date? = nil,
        needsRefresh: Bool = false
    ) -> AuthStatusDTO {
        let userProfileDTO = user.flatMap { DomainUserMapper.toProfileDTO(from: $0) }
        let expiresAtString = tokenExpiresAt.map { ISO8601DateFormatter().string(from: $0) }
        
        return AuthStatusDTO(
            isAuthenticated: isAuthenticated,
            user: userProfileDTO,
            tokenExpiresAt: expiresAtString,
            needsRefresh: needsRefresh
        )
    }
    
    // MARK: - Validation Helpers
    
    /// Validate login credentials
    /// - Parameters:
    ///   - email: Email to validate
    ///   - password: Password to validate
    /// - Returns: Array of validation errors
    public static func validateCredentials(email: String, password: String) -> [String] {
        let loginRequest = createLoginRequest(email: email, password: password)
        return loginRequest.validationErrors()
    }
    
    /// Validate refresh token
    /// - Parameter refreshToken: Token to validate
    /// - Returns: Array of validation errors
    public static func validateRefreshToken(_ refreshToken: String) -> [String] {
        let refreshRequest = createRefreshRequest(refreshToken: refreshToken)
        return refreshRequest.validationErrors()
    }
    
    // MARK: - Error Mapping
    
    /// Map authentication errors to user-friendly messages
    /// - Parameter error: Error to map
    /// - Returns: User-friendly error message
    public static func mapAuthError(_ error: Error) -> String {
        if let networkError = error as? NetworkError {
            switch networkError {
            case .unauthorized:
                return "Invalid email or password"
            case .forbidden:
                return "Account is disabled or suspended"
            case .notFound:
                return "User account not found"
            case .timeout:
                return "Login request timed out. Please try again"
            case .noConnection:
                return "No internet connection. Please check your network"
            default:
                return "Login failed. Please try again"
            }
        }
        
        return "An unexpected error occurred. Please try again"
    }
    
    // MARK: - Token Utilities
    
    /// Check if token is expired based on expiresAt date
    /// - Parameter expiresAtString: ISO 8601 date string
    /// - Returns: True if token is expired
    public static func isTokenExpired(_ expiresAtString: String) -> Bool {
        guard let expiresAt = ISO8601DateFormatter().date(from: expiresAtString) else {
            return true // Invalid date format means expired
        }
        
        return Date() >= expiresAt
    }
    
    /// Calculate remaining token time in seconds
    /// - Parameter expiresAtString: ISO 8601 date string
    /// - Returns: Remaining seconds or 0 if expired
    public static func remainingTokenTime(_ expiresAtString: String) -> TimeInterval {
        guard let expiresAt = ISO8601DateFormatter().date(from: expiresAtString) else {
            return 0
        }
        
        let remaining = expiresAt.timeIntervalSince(Date())
        return max(0, remaining)
    }
    
    /// Check if token needs refresh (expires in less than 5 minutes)
    /// - Parameter expiresAtString: ISO 8601 date string
    /// - Returns: True if token needs refresh
    public static func needsTokenRefresh(_ expiresAtString: String) -> Bool {
        let remaining = remainingTokenTime(expiresAtString)
        return remaining > 0 && remaining < 300 // Less than 5 minutes
    }
}

// MARK: - Auth Response Mapper

/// Specialized mapper for authentication responses
public struct AuthResponseMapper {
    
    /// Map successful login response
    /// - Parameter dto: LoginResponseDTO
    /// - Returns: Tuple of user, tokens, and expiry
    public static func mapLoginSuccess(from dto: LoginResponseDTO) -> (user: DomainUser?, tokens: (String, String), expiresAt: Date?) {
        let user = AuthMapper.toDomainUser(from: dto)
        let tokens = AuthMapper.toTokens(from: dto.tokens)
        let expiresAt = ISO8601DateFormatter().date(from: dto.expiresAt)
        
        return (user: user, tokens: tokens, expiresAt: expiresAt)
    }
    
    /// Map token refresh response
    /// - Parameter dto: TokenResponseDTO
    /// - Returns: Tuple of tokens and expiry
    public static func mapTokenRefresh(from dto: TokenResponseDTO) -> (tokens: (String, String), expiresAt: Date?) {
        let tokens = AuthMapper.toTokens(from: dto)
        let expiresAt = ISO8601DateFormatter().date(from: dto.expiresAt)
        
        return (tokens: tokens, expiresAt: expiresAt)
    }
} 