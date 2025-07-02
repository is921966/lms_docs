//
//  DomainUserRepository.swift
//  LMS
//
//  Created by AI Assistant on 02/01/25.
//
//  Copyright © 2025 LMS. All rights reserved.
//

import Foundation
import Combine

// MARK: - Domain User Repository Protocol

/// Repository protocol for DomainUser entities
public protocol DomainUserRepositoryProtocol: 
    Repository, 
    PaginatedRepository, 
    SearchableRepository, 
    CachedRepository, 
    ObservableRepository 
where Entity == DomainUser, ID == String {
    
    // MARK: - User-specific operations
    
    /// Find user by email
    /// - Parameter email: User email address
    /// - Returns: User if found, nil otherwise
    func findByEmail(_ email: String) async throws -> DomainUser?
    
    /// Find users by role
    /// - Parameter role: User role
    /// - Returns: Array of users with specified role
    func findByRole(_ role: DomainUserRole) async throws -> [DomainUser]
    
    /// Find users by department
    /// - Parameter department: Department name
    /// - Returns: Array of users in department
    func findByDepartment(_ department: String) async throws -> [DomainUser]
    
    /// Find active users
    /// - Returns: Array of active users
    func findActiveUsers() async throws -> [DomainUser]
    
    /// Create new user
    /// - Parameter createUserDTO: User creation data
    /// - Returns: Created user
    func createUser(_ createUserDTO: CreateUserDTO) async throws -> DomainUser
    
    /// Update user
    /// - Parameters:
    ///   - id: User ID
    ///   - updateUserDTO: Update data
    /// - Returns: Updated user
    func updateUser(_ id: String, with updateUserDTO: UpdateUserDTO) async throws -> DomainUser
    
    /// Activate/deactivate user
    /// - Parameters:
    ///   - id: User ID
    ///   - isActive: New active status
    /// - Returns: Updated user
    func setUserActive(_ id: String, isActive: Bool) async throws -> DomainUser
    
    /// Update user last login time
    /// - Parameter id: User ID
    /// - Returns: Updated user
    func updateLastLogin(_ id: String) async throws -> DomainUser
    
    /// Check if email is available
    /// - Parameter email: Email to check
    /// - Returns: true if available, false if taken
    func isEmailAvailable(_ email: String) async throws -> Bool
    
    /// Get user profile (simplified data)
    /// - Parameter id: User ID
    /// - Returns: User profile DTO
    func getUserProfile(_ id: String) async throws -> UserProfileDTO?
    
    // MARK: - Batch operations
    
    /// Create multiple users
    /// - Parameter createUserDTOs: Array of user creation data
    /// - Returns: Array of created users
    func createUsers(_ createUserDTOs: [CreateUserDTO]) async throws -> [DomainUser]
    
    /// Update multiple users
    /// - Parameter updates: Dictionary of user ID to update data
    /// - Returns: Array of updated users
    func updateUsers(_ updates: [String: UpdateUserDTO]) async throws -> [DomainUser]
    
    /// Delete multiple users
    /// - Parameter ids: Array of user IDs
    /// - Returns: Number of deleted users
    func deleteUsers(_ ids: [String]) async throws -> Int
    
    // MARK: - Statistics
    
    /// Get user count by role
    /// - Returns: Dictionary of role to count
    func getUserCountByRole() async throws -> [DomainUserRole: Int]
    
    /// Get user count by department
    /// - Returns: Dictionary of department to count
    func getUserCountByDepartment() async throws -> [String: Int]
    
    /// Get recently active users
    /// - Parameter days: Number of days to look back
    /// - Returns: Array of recently active users
    func getRecentlyActiveUsers(days: Int) async throws -> [DomainUser]
}

// MARK: - Base Domain User Repository Implementation

/// Base implementation for DomainUser repositories with common functionality
open class BaseDomainUserRepository: DomainUserRepositoryProtocol {
    
    // MARK: - Properties
    
    internal let configuration: RepositoryConfiguration
    internal var cache: [String: CacheEntry<DomainUser>] = [:]
    internal let cacheQueue = DispatchQueue(label: "userRepository.cache", attributes: .concurrent)
    internal let changeSubject = PassthroughSubject<RepositoryChange<DomainUser>, Never>()
    
    // MARK: - Initialization
    
    public init(configuration: RepositoryConfiguration = .default) {
        self.configuration = configuration
    }
    
    // MARK: - Observable Repository
    
    public var entityChanges: AnyPublisher<RepositoryChange<DomainUser>, Never> {
        changeSubject.eraseToAnyPublisher()
    }
    
    public func observeEntity(_ id: String) -> AnyPublisher<DomainUser?, Never> {
        entityChanges
            .filter { change in
                switch change {
                case .created(let user), .updated(let user), .deleted(let user):
                    return user.id == id
                }
            }
            .map { change in
                switch change {
                case .created(let user), .updated(let user):
                    return user
                case .deleted:
                    return nil
                }
            }
            .eraseToAnyPublisher()
    }
    
    // MARK: - Cache Management
    
    public func clearCache() async {
        await cacheQueue.sync(flags: .barrier) {
            cache.removeAll()
        }
    }
    
    public func clearCache(for id: String) async {
        await cacheQueue.sync(flags: .barrier) {
            cache.removeValue(forKey: id)
        }
    }
    
    public func refreshCache(for id: String) async throws -> DomainUser? {
        await clearCache(for: id)
        return try await findById(id)
    }
    
    // MARK: - Cache Helpers
    
    internal func getCachedUser(_ id: String) -> DomainUser? {
        guard configuration.cacheEnabled else { return nil }
        
        return cacheQueue.sync {
            guard let entry = cache[id], !entry.isExpired else {
                cache.removeValue(forKey: id)
                return nil
            }
            return entry.value
        }
    }
    
    internal func setCachedUser(_ user: DomainUser) {
        guard configuration.cacheEnabled else { return }
        
        cacheQueue.sync(flags: .barrier) {
            let entry = CacheEntry(value: user, ttl: configuration.cacheTTL)
            cache[user.id] = entry
            
            // Cleanup expired entries if cache is too large
            if cache.count > configuration.maxCacheSize {
                cleanupExpiredEntries()
            }
        }
    }
    
    private func cleanupExpiredEntries() {
        let expiredKeys = cache.compactMap { key, entry in
            entry.isExpired ? key : nil
        }
        
        for key in expiredKeys {
            cache.removeValue(forKey: key)
        }
    }
    
    // MARK: - Change Notification
    
    internal func notifyChange(_ change: RepositoryChange<DomainUser>) {
        changeSubject.send(change)
    }
    
    // MARK: - Validation Helpers
    
    internal func validateUser(_ user: DomainUser) throws {
        let errors = user.validate()
        if !errors.isEmpty {
            throw RepositoryError.validationError(errors)
        }
    }
    
    // MARK: - Abstract Methods (to be implemented by subclasses)
    
    open func findById(_ id: String) async throws -> DomainUser? {
        fatalError("findById must be implemented by subclass")
    }
    
    open func findAll() async throws -> [DomainUser] {
        fatalError("findAll must be implemented by subclass")
    }
    
    open func save(_ entity: DomainUser) async throws -> DomainUser {
        fatalError("save must be implemented by subclass")
    }
    
    open func deleteById(_ id: String) async throws -> Bool {
        fatalError("deleteById must be implemented by subclass")
    }
    
    open func exists(_ id: String) async throws -> Bool {
        let user = try await findById(id)
        return user != nil
    }
    
    open func count() async throws -> Int {
        let users = try await findAll()
        return users.count
    }
    
    // MARK: - Pagination support
    
    open func findAll(pagination: PaginationRequest) async throws -> PaginatedResult<DomainUser> {
        let allUsers = try await findAll()
        let totalCount = allUsers.count
        let startIndex = pagination.offset
        let endIndex = min(startIndex + pagination.pageSize, totalCount)
        
        guard startIndex < totalCount else {
            return PaginatedResult(items: [], totalCount: totalCount, pagination: pagination)
        }
        
        let items = Array(allUsers[startIndex..<endIndex])
        return PaginatedResult(items: items, totalCount: totalCount, pagination: pagination)
    }
    
    open func findAll(page: Int, pageSize: Int) async throws -> PaginatedResult<DomainUser> {
        let pagination = PaginationRequest(page: page, pageSize: pageSize)
        return try await findAll(pagination: pagination)
    }
    
    // MARK: - Search support
    
    open func search(_ query: String, pagination: PaginationRequest) async throws -> PaginatedResult<DomainUser> {
        let searchResults = try await search(query)
        let totalCount = searchResults.count
        let startIndex = pagination.offset
        let endIndex = min(startIndex + pagination.pageSize, totalCount)
        
        guard startIndex < totalCount else {
            return PaginatedResult(items: [], totalCount: totalCount, pagination: pagination)
        }
        
        let items = Array(searchResults[startIndex..<endIndex])
        return PaginatedResult(items: items, totalCount: totalCount, pagination: pagination)
    }
    
    open func search(_ query: String) async throws -> [DomainUser] {
        let users = try await findAll()
        let lowercaseQuery = query.lowercased()
        
        return users.filter { user in
            user.firstName.lowercased().contains(lowercaseQuery) ||
            user.lastName.lowercased().contains(lowercaseQuery) ||
            user.email.lowercased().contains(lowercaseQuery) ||
            (user.department?.lowercased().contains(lowercaseQuery) ?? false)
        }
    }
    
    open func search(_ query: String, page: Int, pageSize: Int) async throws -> PaginatedResult<DomainUser> {
        let pagination = PaginationRequest(page: page, pageSize: pageSize)
        return try await search(query, pagination: pagination)
    }
    
    // MARK: - Default implementations for user-specific operations
    
    open func findByEmail(_ email: String) async throws -> DomainUser? {
        let users = try await findAll()
        return users.first { $0.email == email }
    }
    
    open func findByRole(_ role: DomainUserRole) async throws -> [DomainUser] {
        let users = try await findAll()
        return users.filter { $0.role == role }
    }
    
    open func findByDepartment(_ department: String) async throws -> [DomainUser] {
        let users = try await findAll()
        return users.filter { $0.department == department }
    }
    
    open func findActiveUsers() async throws -> [DomainUser] {
        let users = try await findAll()
        return users.filter { $0.isActive }
    }
    
    open func isEmailAvailable(_ email: String) async throws -> Bool {
        let user = try await findByEmail(email)
        return user == nil
    }
    
    open func getUserProfile(_ id: String) async throws -> UserProfileDTO? {
        guard let user = try await findById(id) else { return nil }
        return UserProfileMapper.toProfileDTO(from: user)
    }
    
    // MARK: - Default implementations for CRUD operations
    
    open func createUser(_ createUserDTO: CreateUserDTO) async throws -> DomainUser {
        guard createUserDTO.isValid() else {
            throw RepositoryError.validationError(createUserDTO.validationErrors())
        }
        
        // Check if email is available
        let emailTaken = try await !isEmailAvailable(createUserDTO.email)
        if emailTaken {
            throw RepositoryError.invalidData("Email \(createUserDTO.email) is already taken")
        }
        
        // Create user from DTO
        guard let user = CreateUserMapper.toDomain(from: createUserDTO) else {
            throw RepositoryError.invalidData("Failed to create user from DTO")
        }
        
        return try await save(user)
    }
    
    open func updateUser(_ id: String, with updateUserDTO: UpdateUserDTO) async throws -> DomainUser {
        guard updateUserDTO.isValid() else {
            throw RepositoryError.validationError(updateUserDTO.validationErrors())
        }
        
        guard var user = try await findById(id) else {
            throw RepositoryError.notFound("User with id \(id) not found")
        }
        
        // Apply updates
        let hasChanges = UpdateUserMapper.applyUpdate(to: &user, from: updateUserDTO)
        
        if hasChanges {
            return try await save(user)
        } else {
            return user
        }
    }
    
    open func setUserActive(_ id: String, isActive: Bool) async throws -> DomainUser {
        guard var user = try await findById(id) else {
            throw RepositoryError.notFound("User with id \(id) not found")
        }
        
        if isActive {
            user.activate()
        } else {
            user.deactivate()
        }
        
        return try await save(user)
    }
    
    open func updateLastLogin(_ id: String) async throws -> DomainUser {
        guard var user = try await findById(id) else {
            throw RepositoryError.notFound("User with id \(id) not found")
        }
        
        user.updateLastLogin()
        return try await save(user)
    }
    
    // MARK: - Default implementations for batch operations
    
    open func createUsers(_ createUserDTOs: [CreateUserDTO]) async throws -> [DomainUser] {
        var createdUsers: [DomainUser] = []
        
        for dto in createUserDTOs {
            do {
                let user = try await createUser(dto)
                createdUsers.append(user)
            } catch {
                // Continue with other users, collect errors if needed
                print("Failed to create user: \(error)")
            }
        }
        
        return createdUsers
    }
    
    open func updateUsers(_ updates: [String: UpdateUserDTO]) async throws -> [DomainUser] {
        var updatedUsers: [DomainUser] = []
        
        for (id, dto) in updates {
            do {
                let user = try await updateUser(id, with: dto)
                updatedUsers.append(user)
            } catch {
                // Continue with other users
                print("Failed to update user \(id): \(error)")
            }
        }
        
        return updatedUsers
    }
    
    open func deleteUsers(_ ids: [String]) async throws -> Int {
        var deletedCount = 0
        
        for id in ids {
            do {
                if try await deleteById(id) {
                    deletedCount += 1
                }
            } catch {
                // Continue with other users
                print("Failed to delete user \(id): \(error)")
            }
        }
        
        return deletedCount
    }
    
    // MARK: - Default implementations for statistics
    
    open func getUserCountByRole() async throws -> [DomainUserRole: Int] {
        let users = try await findAll()
        var counts: [DomainUserRole: Int] = [:]
        
        for role in DomainUserRole.allCases {
            counts[role] = users.filter { $0.role == role }.count
        }
        
        return counts
    }
    
    open func getUserCountByDepartment() async throws -> [String: Int] {
        let users = try await findAll()
        var counts: [String: Int] = [:]
        
        for user in users {
            if let department = user.department {
                counts[department, default: 0] += 1
            }
        }
        
        return counts
    }
    
    open func getRecentlyActiveUsers(days: Int) async throws -> [DomainUser] {
        let users = try await findAll()
        let cutoffDate = Calendar.current.date(byAdding: .day, value: -days, to: Date()) ?? Date()
        
        return users.filter { user in
            guard let lastLogin = user.lastLoginAt else { return false }
            return lastLogin >= cutoffDate
        }
    }
} 