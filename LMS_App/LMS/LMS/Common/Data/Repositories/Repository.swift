//
//  Repository.swift
//  LMS
//
//  Created by AI Assistant on 02/01/25.
//
//  Copyright © 2025 LMS. All rights reserved.
//

import Foundation
import Combine

// MARK: - Pagination Request

/// Request parameters for pagination
public struct PaginationRequest {
    public let page: Int
    public let pageSize: Int
    public let sortBy: String?
    public let sortDirection: SortDirection
    
    public init(
        page: Int = 1,
        pageSize: Int = 20,
        sortBy: String? = nil,
        sortDirection: SortDirection = .ascending
    ) {
        self.page = max(1, page) // Ensure page is at least 1
        self.pageSize = max(1, min(100, pageSize)) // Limit between 1 and 100
        self.sortBy = sortBy
        self.sortDirection = sortDirection
    }
    
    /// Calculate offset for database queries
    public var offset: Int {
        (page - 1) * pageSize
    }
    
    /// Create next page request
    public func nextPage() -> PaginationRequest {
        return PaginationRequest(
            page: page + 1,
            pageSize: pageSize,
            sortBy: sortBy,
            sortDirection: sortDirection
        )
    }
    
    /// Create previous page request
    public func previousPage() -> PaginationRequest {
        return PaginationRequest(
            page: max(1, page - 1),
            pageSize: pageSize,
            sortBy: sortBy,
            sortDirection: sortDirection
        )
    }
}

/// Sort direction for pagination
public enum SortDirection: String, CaseIterable {
    case ascending = "asc"
    case descending = "desc"
    
    public var isAscending: Bool {
        return self == .ascending
    }
}

// MARK: - Base Repository Protocol

/// Base protocol for all repositories
/// Provides common CRUD operations with async/await support
public protocol Repository {
    associatedtype Entity
    associatedtype ID: Hashable
    
    /// Find entity by ID
    /// - Parameter id: Entity identifier
    /// - Returns: Entity if found, nil otherwise
    func findById(_ id: ID) async throws -> Entity?
    
    /// Find all entities
    /// - Returns: Array of all entities
    func findAll() async throws -> [Entity]
    
    /// Save entity (create or update)
    /// - Parameter entity: Entity to save
    /// - Returns: Saved entity with updated metadata
    func save(_ entity: Entity) async throws -> Entity
    
    /// Delete entity by ID
    /// - Parameter id: Entity identifier
    /// - Returns: true if deleted, false if not found
    func deleteById(_ id: ID) async throws -> Bool
    
    /// Check if entity exists
    /// - Parameter id: Entity identifier
    /// - Returns: true if exists, false otherwise
    func exists(_ id: ID) async throws -> Bool
    
    /// Count total entities
    /// - Returns: Total number of entities
    func count() async throws -> Int
}

// MARK: - Paginated Repository Protocol

/// Repository with pagination support
public protocol PaginatedRepository: Repository {
    /// Find entities with pagination
    /// - Parameter pagination: Pagination request parameters
    /// - Returns: Paginated result
    func findAll(pagination: PaginationRequest) async throws -> PaginatedResult<Entity>
    
    /// Find entities with pagination (legacy method)
    /// - Parameters:
    ///   - page: Page number (1-based)
    ///   - pageSize: Number of items per page
    /// - Returns: Paginated result
    func findAll(page: Int, pageSize: Int) async throws -> PaginatedResult<Entity>
}

// MARK: - Searchable Repository Protocol

/// Repository with search capabilities
public protocol SearchableRepository: Repository {
    /// Search entities by query
    /// - Parameter query: Search query string
    /// - Returns: Array of matching entities
    func search(_ query: String) async throws -> [Entity]
    
    /// Search entities with pagination
    /// - Parameters:
    ///   - query: Search query string
    ///   - pagination: Pagination request parameters
    /// - Returns: Paginated search results
    func search(_ query: String, pagination: PaginationRequest) async throws -> PaginatedResult<Entity>
    
    /// Search entities with pagination (legacy method)
    /// - Parameters:
    ///   - query: Search query string
    ///   - page: Page number (1-based)
    ///   - pageSize: Number of items per page
    /// - Returns: Paginated search results
    func search(_ query: String, page: Int, pageSize: Int) async throws -> PaginatedResult<Entity>
}

// MARK: - Cached Repository Protocol

/// Repository with caching support
public protocol CachedRepository: Repository {
    /// Clear all cache
    func clearCache() async
    
    /// Clear cache for specific entity
    /// - Parameter id: Entity identifier
    func clearCache(for id: ID) async
    
    /// Refresh cache for entity
    /// - Parameter id: Entity identifier
    func refreshCache(for id: ID) async throws -> Entity?
}

// MARK: - Observable Repository Protocol

/// Repository with reactive updates
public protocol ObservableRepository: Repository {
    /// Publisher for entity changes
    var entityChanges: AnyPublisher<RepositoryChange<Entity>, Never> { get }
    
    /// Publisher for specific entity changes
    /// - Parameter id: Entity identifier
    /// - Returns: Publisher for entity updates
    func observeEntity(_ id: ID) -> AnyPublisher<Entity?, Never>
}

// MARK: - Repository Change Event

/// Represents a change in repository
public enum RepositoryChange<Entity> {
    case created(Entity)
    case updated(Entity)
    case deleted(Entity)
    
    /// The entity that changed
    public var entity: Entity {
        switch self {
        case .created(let entity), .updated(let entity), .deleted(let entity):
            return entity
        }
    }
    
    /// The type of change
    public var changeType: ChangeType {
        switch self {
        case .created: return .create
        case .updated: return .update
        case .deleted: return .delete
        }
    }
}

/// Type of repository change
public enum ChangeType {
    case create
    case update
    case delete
}

// MARK: - Paginated Result

/// Result container for paginated queries
public struct PaginatedResult<Entity> {
    public let items: [Entity]
    public let totalCount: Int
    public let page: Int
    public let pageSize: Int
    public let totalPages: Int
    public let hasNextPage: Bool
    public let hasPreviousPage: Bool
    
    public init(items: [Entity], totalCount: Int, page: Int, pageSize: Int) {
        self.items = items
        self.totalCount = totalCount
        self.page = page
        self.pageSize = pageSize
        self.totalPages = (totalCount + pageSize - 1) / pageSize
        self.hasNextPage = page < totalPages
        self.hasPreviousPage = page > 1
    }
    
    /// Create from pagination request
    public init(items: [Entity], totalCount: Int, pagination: PaginationRequest) {
        self.init(items: items, totalCount: totalCount, page: pagination.page, pageSize: pagination.pageSize)
    }
}

// MARK: - Repository Errors

/// Errors that can occur in repository operations
public enum RepositoryError: Error, LocalizedError {
    case notFound(String)
    case invalidData(String)
    case networkError(Error)
    case cacheError(String)
    case validationError([String])
    case unknownError(String)
    
    public var errorDescription: String? {
        switch self {
        case .notFound(let message):
            return "Not found: \(message)"
        case .invalidData(let message):
            return "Invalid data: \(message)"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .cacheError(let message):
            return "Cache error: \(message)"
        case .validationError(let errors):
            return "Validation error: \(errors.joined(separator: ", "))"
        case .unknownError(let message):
            return "Unknown error: \(message)"
        }
    }
}

// MARK: - Repository Configuration

/// Configuration for repository implementations
public struct RepositoryConfiguration {
    public let cacheEnabled: Bool
    public let cacheTTL: TimeInterval
    public let maxCacheSize: Int
    public let retryAttempts: Int
    public let requestTimeout: TimeInterval
    
    public init(
        cacheEnabled: Bool = true,
        cacheTTL: TimeInterval = 300, // 5 minutes
        maxCacheSize: Int = 1000,
        retryAttempts: Int = 3,
        requestTimeout: TimeInterval = 30
    ) {
        self.cacheEnabled = cacheEnabled
        self.cacheTTL = cacheTTL
        self.maxCacheSize = maxCacheSize
        self.retryAttempts = retryAttempts
        self.requestTimeout = requestTimeout
    }
    
    public static let `default` = RepositoryConfiguration()
}

// MARK: - Cache Entry

/// Internal cache entry with TTL
internal struct CacheEntry<T> {
    let value: T
    let timestamp: Date
    let ttl: TimeInterval
    
    var isExpired: Bool {
        Date().timeIntervalSince(timestamp) > ttl
    }
    
    init(value: T, ttl: TimeInterval) {
        self.value = value
        self.timestamp = Date()
        self.ttl = ttl
    }
}

// MARK: - Repository Factory Protocol (moved to RepositoryFactory.swift) 