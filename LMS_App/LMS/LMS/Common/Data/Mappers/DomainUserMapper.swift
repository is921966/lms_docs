//
//  DomainUserMapper.swift
//  LMS
//
//  Created by AI Assistant on 02/01/25.
//
//  Copyright © 2025 LMS. All rights reserved.
//

import Foundation

// MARK: - Domain User Mapper

/// Mapper for converting between DomainUser and DTOs
public struct DomainUserMapper {
    
    // MARK: - Domain to DTO
    
    /// Convert DomainUser to UserDTO
    /// - Parameter domain: DomainUser instance
    /// - Returns: UserDTO if conversion successful
    public static func toDTO(from domain: DomainUser) -> UserDTO? {
        let formatter = ISO8601DateFormatter()
        
        return UserDTO(
            id: domain.id,
            email: domain.email,
            firstName: domain.firstName,
            lastName: domain.lastName,
            role: domain.role.rawValue,
            isActive: domain.isActive,
            profileImageUrl: domain.profileImageUrl,
            phoneNumber: domain.phoneNumber,
            department: domain.department,
            position: domain.position,
            createdAt: formatter.string(from: domain.createdAt),
            updatedAt: formatter.string(from: domain.updatedAt),
            lastLoginAt: domain.lastLoginAt.map { formatter.string(from: $0) }
        )
    }
    
    /// Convert DomainUser to UserProfileDTO
    /// - Parameter domain: DomainUser instance
    /// - Returns: UserProfileDTO if conversion successful
    public static func toProfileDTO(from domain: DomainUser) -> UserProfileDTO? {
        return UserProfileDTO(
            id: domain.id,
            firstName: domain.firstName,
            lastName: domain.lastName,
            email: domain.email,
            profileImageUrl: domain.profileImageUrl,
            department: domain.department,
            position: domain.position
        )
    }
    
    // MARK: - DTO to Domain
    
    /// Convert UserDTO to DomainUser
    /// - Parameter dto: UserDTO instance
    /// - Returns: DomainUser if conversion successful
    public static func toDomain(from dto: UserDTO) -> DomainUser? {
        guard let role = DomainUserRole(rawValue: dto.role) else {
            return nil
        }
        
        let formatter = ISO8601DateFormatter()
        
        guard let createdAt = formatter.date(from: dto.createdAt),
              let updatedAt = formatter.date(from: dto.updatedAt) else {
            return nil
        }
        
        let lastLoginAt = dto.lastLoginAt.flatMap { formatter.date(from: $0) }
        
        return DomainUser(
            id: dto.id,
            email: dto.email,
            firstName: dto.firstName,
            lastName: dto.lastName,
            role: role,
            isActive: dto.isActive,
            profileImageUrl: dto.profileImageUrl,
            phoneNumber: dto.phoneNumber,
            department: dto.department,
            position: dto.position,
            lastLoginAt: lastLoginAt,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
    
    /// Convert CreateUserDTO to DomainUser
    /// - Parameter dto: CreateUserDTO instance
    /// - Returns: DomainUser if conversion successful
    public static func createFromDTO(_ dto: CreateUserDTO) -> DomainUser? {
        guard let role = DomainUserRole(rawValue: dto.role) else {
            return nil
        }
        
        return DomainUser(
            id: UUID().uuidString,
            email: dto.email,
            firstName: dto.firstName,
            lastName: dto.lastName,
            role: role,
            isActive: true,
            phoneNumber: dto.phoneNumber,
            department: dto.department,
            position: dto.position
        )
    }
    
    // MARK: - Collection Mapping
    
    /// Convert array of DomainUser to array of UserDTO
    /// - Parameter domains: Array of DomainUser
    /// - Returns: Array of UserDTO
    public static func toDTOs(from domains: [DomainUser]) -> [UserDTO] {
        return domains.compactMap { toDTO(from: $0) }
    }
    
    /// Convert array of UserDTO to array of DomainUser
    /// - Parameter dtos: Array of UserDTO
    /// - Returns: Array of DomainUser
    public static func toDomains(from dtos: [UserDTO]) -> [DomainUser] {
        return dtos.compactMap { toDomain(from: $0) }
    }
    
    /// Convert array of DomainUser to array of UserProfileDTO
    /// - Parameter domains: Array of DomainUser
    /// - Returns: Array of UserProfileDTO
    public static func toProfileDTOs(from domains: [DomainUser]) -> [UserProfileDTO] {
        return domains.compactMap { toProfileDTO(from: $0) }
    }
    
    // MARK: - Safe Mapping with Error Collection
    
    /// Safely convert DTOs to Domain objects, collecting errors
    /// - Parameter dtos: Array of UserDTO
    /// - Returns: Tuple of successfully converted users and mapping errors
    public static func safeToDomains(from dtos: [UserDTO]) -> (users: [DomainUser], errors: [MappingError]) {
        var users: [DomainUser] = []
        var errors: [MappingError] = []
        
        for dto in dtos {
            if let user = toDomain(from: dto) {
                users.append(user)
            } else {
                errors.append(MappingError.invalidData("Failed to convert UserDTO with id: \(dto.id)"))
            }
        }
        
        return (users, errors)
    }
    
    // MARK: - Update Operations
    
    /// Apply UpdateUserDTO to existing DomainUser
    /// - Parameters:
    ///   - user: DomainUser to update (inout)
    ///   - dto: UpdateUserDTO with changes
    /// - Returns: true if any changes were applied
    public static func applyUpdate(to user: inout DomainUser, from dto: UpdateUserDTO) -> Bool {
        var hasChanges = false
        
        if let firstName = dto.firstName, firstName != user.firstName {
            user.firstName = firstName
            hasChanges = true
        }
        
        if let lastName = dto.lastName, lastName != user.lastName {
            user.lastName = lastName
            hasChanges = true
        }
        
        if let phoneNumber = dto.phoneNumber, phoneNumber != user.phoneNumber {
            user.phoneNumber = phoneNumber
            hasChanges = true
        }
        
        if let profileImageUrl = dto.profileImageUrl, profileImageUrl != user.profileImageUrl {
            user.profileImageUrl = profileImageUrl
            hasChanges = true
        }
        
        if let department = dto.department, department != user.department {
            user.department = department
            hasChanges = true
        }
        
        if let position = dto.position, position != user.position {
            user.position = position
            hasChanges = true
        }
        
        if hasChanges {
            user.updatedAt = Date()
        }
        
        return hasChanges
    }
}

// MARK: - UserProfileMapper

/// Specialized mapper for UserProfile operations
public struct UserProfileMapper {
    
    /// Convert DomainUser to UserProfileDTO
    /// - Parameter domain: DomainUser instance
    /// - Returns: UserProfileDTO
    public static func toProfileDTO(from domain: DomainUser) -> UserProfileDTO {
        return UserProfileDTO(
            id: domain.id,
            firstName: domain.firstName,
            lastName: domain.lastName,
            email: domain.email,
            profileImageUrl: domain.profileImageUrl,
            department: domain.department,
            position: domain.position
        )
    }
    
    /// Convert array of DomainUser to array of UserProfileDTO
    /// - Parameter domains: Array of DomainUser
    /// - Returns: Array of UserProfileDTO
    public static func toProfileDTOs(from domains: [DomainUser]) -> [UserProfileDTO] {
        return domains.map { toProfileDTO(from: $0) }
    }
}

// MARK: - CreateUserMapper

/// Specialized mapper for user creation operations
public struct CreateUserMapper {
    
    /// Convert CreateUserDTO to DomainUser with generated ID
    /// - Parameter dto: CreateUserDTO instance
    /// - Returns: DomainUser if conversion successful
    public static func toDomain(from dto: CreateUserDTO) -> DomainUser? {
        guard let role = DomainUserRole(rawValue: dto.role) else {
            return nil
        }
        
        return DomainUser(
            id: UUID().uuidString,
            email: dto.email,
            firstName: dto.firstName,
            lastName: dto.lastName,
            role: role,
            isActive: true,
            phoneNumber: dto.phoneNumber,
            department: dto.department,
            position: dto.position
        )
    }
    
    /// Convert CreateUserDTO to DomainUser with specific ID
    /// - Parameters:
    ///   - dto: CreateUserDTO instance
    ///   - id: Specific ID to use
    /// - Returns: DomainUser if conversion successful
    public static func toDomain(from dto: CreateUserDTO, withId id: String) -> DomainUser? {
        guard let role = DomainUserRole(rawValue: dto.role) else {
            return nil
        }
        
        return DomainUser(
            id: id,
            email: dto.email,
            firstName: dto.firstName,
            lastName: dto.lastName,
            role: role,
            isActive: true,
            phoneNumber: dto.phoneNumber,
            department: dto.department,
            position: dto.position
        )
    }
}

// MARK: - UpdateUserMapper

/// Specialized mapper for user update operations
public struct UpdateUserMapper {
    
    /// Apply UpdateUserDTO to existing DomainUser
    /// - Parameters:
    ///   - domain: DomainUser to update (inout)
    ///   - dto: UpdateUserDTO with changes
    /// - Returns: true if any changes were applied
    public static func applyUpdate(to domain: inout DomainUser, from dto: UpdateUserDTO) -> Bool {
        return DomainUserMapper.applyUpdate(to: &domain, from: dto)
    }
} 