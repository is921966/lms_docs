//
//  InMemoryDomainUserRepository.swift
//  LMS
//
//  Created by AI Assistant on 02/01/25.
//
//  Copyright © 2025 LMS. All rights reserved.
//

import Foundation
import Combine

/// In-memory implementation of DomainUserRepository for testing and development
public final class InMemoryDomainUserRepository: BaseDomainUserRepository {
    
    // MARK: - Properties
    
    private var users: [String: DomainUser] = [:]
    private let dataQueue = DispatchQueue(label: "inMemoryDomainUserRepository.data", attributes: .concurrent)
    
    // MARK: - Initialization
    
    public override init(configuration: RepositoryConfiguration = .default) {
        super.init(configuration: configuration)
        initializeWithMockData()
    }
    
    // MARK: - Repository Implementation
    
    public override func findById(_ id: String) async throws -> DomainUser? {
        // Check cache first
        if let cachedUser = getCachedUser(id) {
            return cachedUser
        }
        
        // Get from memory
        let user = dataQueue.sync {
            users[id]
        }
        
        // Cache if found
        if let user = user {
            setCachedUser(user)
        }
        
        return user
    }
    
    public override func findAll() async throws -> [DomainUser] {
        return dataQueue.sync {
            Array(users.values)
        }
    }
    
    public override func save(_ entity: DomainUser) async throws -> DomainUser {
        try validateUser(entity)
        
        let isNew = dataQueue.sync {
            users[entity.id] == nil
        }
        
        let savedUser = dataQueue.sync(flags: .barrier) {
            users[entity.id] = entity
            return entity
        }
        
        // Update cache
        setCachedUser(savedUser)
        
        // Notify change
        let change: RepositoryChange<DomainUser> = isNew ? .created(savedUser) : .updated(savedUser)
        notifyChange(change)
        
        return savedUser
    }
    
    public override func deleteById(_ id: String) async throws -> Bool {
        let deletedUser = dataQueue.sync(flags: .barrier) {
            users.removeValue(forKey: id)
        }
        
        if let user = deletedUser {
            // Clear cache
            await clearCache(for: id)
            
            // Notify change
            notifyChange(.deleted(user))
            return true
        }
        
        return false
    }
    
    // MARK: - Mock Data Initialization
    
    private func initializeWithMockData() {
        let mockUsers = createMockUsers()
        
        dataQueue.sync(flags: .barrier) {
            for user in mockUsers {
                users[user.id] = user
            }
        }
    }
    
    private func createMockUsers() -> [DomainUser] {
        let roles: [DomainUserRole] = [.student, .teacher, .admin, .manager]
        let departments = ["Engineering", "Marketing", "Sales", "HR", "Finance"]
        let positions = ["Developer", "Designer", "Manager", "Analyst", "Specialist"]
        
        var mockUsers: [DomainUser] = []
        
        for i in 1...20 {
            let user = DomainUser(
                id: "USER_\(String(format: "%03d", i))",
                email: "user\(i)@example.com",
                firstName: "User",
                lastName: "\(i)",
                role: roles[i % roles.count],
                isActive: i % 10 != 0, // Every 10th user is inactive
                phoneNumber: "+7999\(String(format: "%07d", i))",
                department: departments[i % departments.count],
                position: positions[i % positions.count],
                lastLoginAt: i % 3 == 0 ? Date().addingTimeInterval(-TimeInterval.random(in: 0...86400*7)) : nil
            )
            mockUsers.append(user)
        }
        
        return mockUsers
    }
    
    // MARK: - Test Helpers
    
    /// Clear all data (for testing)
    public func clearAllData() async {
        dataQueue.sync(flags: .barrier) {
            users.removeAll()
        }
        await clearCache()
    }
    
    /// Add test user (for testing)
    public func addTestUser(_ user: DomainUser) async {
        dataQueue.sync(flags: .barrier) {
            users[user.id] = user
        }
    }
    
    /// Get user count (for testing)
    public func getUserCount() async -> Int {
        return dataQueue.sync {
            users.count
        }
    }
} 