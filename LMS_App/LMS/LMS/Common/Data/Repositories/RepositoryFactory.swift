//
//  RepositoryFactory.swift
//  LMS
//
//  Created by AI Assistant on 02/01/25.
//
//  Copyright © 2025 LMS. All rights reserved.
//

import Foundation

// MARK: - Repository Factory Protocol

/// Factory for creating repository instances
public protocol RepositoryFactory {
    /// Create user repository
    func createUserRepository() -> any DomainUserRepositoryProtocol
    
    /// Create course repository (placeholder for future implementation)
    func createCourseRepository() -> any Repository
    
    /// Create repository with custom configuration
    func createRepository<T: Repository>(type: T.Type, configuration: RepositoryConfiguration) -> T?
}

// MARK: - Default Repository Factory

/// Default implementation of RepositoryFactory
/// Uses in-memory repositories for development and testing
public final class DefaultRepositoryFactory: RepositoryFactory {
    
    // MARK: - Properties
    
    private let configuration: RepositoryConfiguration
    private var userRepositoryInstance: (any DomainUserRepositoryProtocol)?
    
    // MARK: - Initialization
    
    public init(configuration: RepositoryConfiguration = .default) {
        self.configuration = configuration
    }
    
    // MARK: - Repository Creation
    
    public func createUserRepository() -> any DomainUserRepositoryProtocol {
        // Singleton pattern for user repository
        if let existingInstance = userRepositoryInstance {
            return existingInstance
        }
        
        let repository = InMemoryDomainUserRepository(configuration: configuration)
        userRepositoryInstance = repository
        return repository
    }
    
    public func createCourseRepository() -> any Repository {
        // Placeholder - will be implemented when CourseRepository is created
        fatalError("CourseRepository not yet implemented")
    }
    
    public func createRepository<T: Repository>(type: T.Type, configuration: RepositoryConfiguration) -> T? {
        // Generic repository creation based on type
        switch type {
        case is InMemoryDomainUserRepository.Type:
            return InMemoryDomainUserRepository(configuration: configuration) as? T
        default:
            return nil
        }
    }
}

// MARK: - Production Repository Factory

/// Production implementation using network-based repositories
public final class ProductionRepositoryFactory: RepositoryFactory {
    
    // MARK: - Properties
    
    private let configuration: RepositoryConfiguration
    private let networkService: RepositoryNetworkService
    private var userRepositoryInstance: (any DomainUserRepositoryProtocol)?
    
    // MARK: - Initialization
    
    public init(
        configuration: RepositoryConfiguration = .default,
        networkService: RepositoryNetworkService
    ) {
        self.configuration = configuration
        self.networkService = networkService
    }
    
    // MARK: - Repository Creation
    
    public func createUserRepository() -> any DomainUserRepositoryProtocol {
        // Singleton pattern for user repository
        if let existingInstance = userRepositoryInstance {
            return existingInstance
        }
        
        // For now, use InMemory repository
        // TODO: Implement NetworkDomainUserRepository when API is ready
        let repository = InMemoryDomainUserRepository(configuration: configuration)
        userRepositoryInstance = repository
        return repository
    }
    
    public func createCourseRepository() -> any Repository {
        // Placeholder - will be implemented when CourseRepository is created
        fatalError("CourseRepository not yet implemented")
    }
    
    public func createRepository<T: Repository>(type: T.Type, configuration: RepositoryConfiguration) -> T? {
        // Generic repository creation based on type
        switch type {
        case is InMemoryDomainUserRepository.Type:
            return InMemoryDomainUserRepository(configuration: configuration) as? T
        default:
            return nil
        }
    }
}

// MARK: - Test Repository Factory

/// Test implementation for unit and integration testing
public final class TestRepositoryFactory: RepositoryFactory {
    
    // MARK: - Properties
    
    private let configuration: RepositoryConfiguration
    private var repositories: [String: Any] = [:]
    
    // MARK: - Initialization
    
    public init(configuration: RepositoryConfiguration = .testConfiguration) {
        self.configuration = configuration
    }
    
    // MARK: - Repository Creation
    
    public func createUserRepository() -> any DomainUserRepositoryProtocol {
        let key = "UserRepository"
        
        if let existingRepository = repositories[key] as? (any DomainUserRepositoryProtocol) {
            return existingRepository
        }
        
        let repository = InMemoryDomainUserRepository(configuration: configuration)
        repositories[key] = repository
        return repository
    }
    
    public func createCourseRepository() -> any Repository {
        // Placeholder - will be implemented when CourseRepository is created
        fatalError("CourseRepository not yet implemented")
    }
    
    public func createRepository<T: Repository>(type: T.Type, configuration: RepositoryConfiguration) -> T? {
        let key = String(describing: type)
        
        if let existingRepository = repositories[key] as? T {
            return existingRepository
        }
        
        switch type {
        case is InMemoryDomainUserRepository.Type:
            let repository = InMemoryDomainUserRepository(configuration: configuration) as? T
            repositories[key] = repository
            return repository
        default:
            return nil
        }
    }
    
    // MARK: - Test Helpers
    
    /// Clear all cached repositories (for testing)
    public func clearRepositories() {
        repositories.removeAll()
    }
    
    /// Get cached repository instance (for testing)
    public func getCachedRepository<T>(type: T.Type) -> T? {
        let key = String(describing: type)
        return repositories[key] as? T
    }
}

// MARK: - Repository Factory Manager

/// Singleton manager for repository factory
public final class RepositoryFactoryManager {
    
    // MARK: - Singleton
    
    public static let shared = RepositoryFactoryManager()
    
    // MARK: - Properties
    
    private var currentFactory: RepositoryFactory
    
    // MARK: - Initialization
    
    private init() {
        // Default to development factory
        self.currentFactory = DefaultRepositoryFactory()
    }
    
    // MARK: - Factory Management
    
    /// Set the repository factory to use
    /// - Parameter factory: The factory instance
    public func setFactory(_ factory: RepositoryFactory) {
        self.currentFactory = factory
    }
    
    /// Get the current repository factory
    /// - Returns: Current factory instance
    public func getFactory() -> RepositoryFactory {
        return currentFactory
    }
    
    /// Configure for development environment
    public func configureForDevelopment() {
        let config = RepositoryConfiguration(
            cacheEnabled: true,
            cacheTTL: 300, // 5 minutes
            maxCacheSize: 1000,
            retryAttempts: 3,
            requestTimeout: 30
        )
        self.currentFactory = DefaultRepositoryFactory(configuration: config)
    }
    
    /// Configure for production environment
    public func configureForProduction(networkService: RepositoryNetworkService) {
        let config = RepositoryConfiguration(
            cacheEnabled: true,
            cacheTTL: 600, // 10 minutes
            maxCacheSize: 5000,
            retryAttempts: 5,
            requestTimeout: 60
        )
        self.currentFactory = ProductionRepositoryFactory(
            configuration: config,
            networkService: networkService
        )
    }
    
    /// Configure for testing environment
    public func configureForTesting() {
        self.currentFactory = TestRepositoryFactory()
    }
}

// MARK: - Repository Configuration Extensions

public extension RepositoryConfiguration {
    /// Configuration optimized for testing
    static let testConfiguration = RepositoryConfiguration(
        cacheEnabled: false, // Disable cache for predictable tests
        cacheTTL: 1,
        maxCacheSize: 100,
        retryAttempts: 1,
        requestTimeout: 5
    )
    
    /// Configuration for development
    static let developmentConfiguration = RepositoryConfiguration(
        cacheEnabled: true,
        cacheTTL: 300, // 5 minutes
        maxCacheSize: 1000,
        retryAttempts: 3,
        requestTimeout: 30
    )
    
    /// Configuration for production
    static let productionConfiguration = RepositoryConfiguration(
        cacheEnabled: true,
        cacheTTL: 600, // 10 minutes
        maxCacheSize: 5000,
        retryAttempts: 5,
        requestTimeout: 60
    )
}

// MARK: - Repository Network Service Protocol (Placeholder)

/// Placeholder protocol for network service
/// Will be implemented when API integration is ready
public protocol RepositoryNetworkService {
    func get<T: Codable>(endpoint: String, type: T.Type) async throws -> T
    func post<T: Codable, U: Codable>(endpoint: String, body: T, responseType: U.Type) async throws -> U
    func put<T: Codable, U: Codable>(endpoint: String, body: T, responseType: U.Type) async throws -> U
    func delete(endpoint: String) async throws
}

// MARK: - Convenience Extensions

public extension RepositoryFactory {
    /// Convenience method to get user repository
    var userRepository: any DomainUserRepositoryProtocol {
        return createUserRepository()
    }
}

public extension RepositoryFactoryManager {
    /// Convenience property to get user repository
    var userRepository: any DomainUserRepositoryProtocol {
        return currentFactory.createUserRepository()
    }
} 