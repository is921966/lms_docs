//
//  DataTransferObject.swift
//  LMS
//
//  Created by AI Assistant on 02/01/25.
//
//  Copyright © 2025 LMS. All rights reserved.
//

import Foundation

// MARK: - Base DTO Protocol

/// Base protocol for all Data Transfer Objects
/// DTOs are used for API communication and data serialization
public protocol DataTransferObject: Codable, Equatable {
    /// Validates the DTO data integrity
    /// - Returns: true if DTO is valid, false otherwise
    func isValid() -> Bool
    
    /// Returns validation errors if any
    /// - Returns: Array of validation error messages
    func validationErrors() -> [String]
}

public extension DataTransferObject {
    /// Default validation - always valid
    func isValid() -> Bool {
        return validationErrors().isEmpty
    }
    
    /// Default implementation - no errors
    func validationErrors() -> [String] {
        return []
    }
}

// MARK: - Mappable Protocol

/// Protocol for objects that can be mapped between Domain and DTO layers
public protocol Mappable {
    associatedtype DomainType
    associatedtype DTOType: DataTransferObject
    
    /// Maps from Domain model to DTO
    /// - Parameter domain: Domain model instance
    /// - Returns: DTO instance or nil if mapping fails
    static func toDTO(from domain: DomainType) -> DTOType?
    
    /// Maps from DTO to Domain model
    /// - Parameter dto: DTO instance
    /// - Returns: Domain model instance or nil if mapping fails
    static func toDomain(from dto: DTOType) -> DomainType?
}

// MARK: - API Response Wrapper

/// Generic wrapper for API responses
public struct APIResponse<T: DataTransferObject>: DataTransferObject {
    public let data: T?
    public let success: Bool
    public let message: String?
    public let errorCode: String?
    public let timestamp: Date
    public let requestId: String?
    
    public init(
        data: T? = nil,
        success: Bool,
        message: String? = nil,
        errorCode: String? = nil,
        timestamp: Date = Date(),
        requestId: String? = nil
    ) {
        self.data = data
        self.success = success
        self.message = message
        self.errorCode = errorCode
        self.timestamp = timestamp
        self.requestId = requestId
    }
    
    public func validationErrors() -> [String] {
        var errors: [String] = []
        
        if !success && errorCode == nil {
            errors.append("Error response must have error code")
        }
        
        if let data = data, !data.isValid() {
            errors.append("Response data is invalid: \(data.validationErrors().joined(separator: ", "))")
        }
        
        return errors
    }
}

// MARK: - Collection Response

/// Wrapper for paginated API responses
public struct CollectionResponse<T: DataTransferObject>: DataTransferObject {
    public let items: [T]
    public let totalCount: Int
    public let page: Int
    public let pageSize: Int
    public let hasNextPage: Bool
    public let hasPreviousPage: Bool
    
    public init(
        items: [T],
        totalCount: Int,
        page: Int,
        pageSize: Int
    ) {
        self.items = items
        self.totalCount = totalCount
        self.page = page
        self.pageSize = pageSize
        self.hasNextPage = (page * pageSize) < totalCount
        self.hasPreviousPage = page > 1
    }
    
    public func validationErrors() -> [String] {
        var errors: [String] = []
        
        if page < 1 {
            errors.append("Page must be greater than 0")
        }
        
        if pageSize < 1 {
            errors.append("Page size must be greater than 0")
        }
        
        if totalCount < 0 {
            errors.append("Total count cannot be negative")
        }
        
        if items.count > pageSize {
            errors.append("Items count cannot exceed page size")
        }
        
        // Validate all items
        for (index, item) in items.enumerated() {
            if !item.isValid() {
                errors.append("Item at index \(index) is invalid: \(item.validationErrors().joined(separator: ", "))")
            }
        }
        
        return errors
    }
}

// MARK: - DTO Error Response

/// Standard error response structure for DTOs
public struct DTOErrorResponse: DataTransferObject {
    public let code: String
    public let message: String
    public let details: [String]?
    public let timestamp: Date
    public let path: String?
    
    public init(
        code: String,
        message: String,
        details: [String]? = nil,
        timestamp: Date = Date(),
        path: String? = nil
    ) {
        self.code = code
        self.message = message
        self.details = details
        self.timestamp = timestamp
        self.path = path
    }
    
    public func validationErrors() -> [String] {
        var errors: [String] = []
        
        if code.isEmpty {
            errors.append("Error code cannot be empty")
        }
        
        if message.isEmpty {
            errors.append("Error message cannot be empty")
        }
        
        return errors
    }
}

// MARK: - Mapping Utilities

/// Utility class for common mapping operations
public final class MappingUtilities {
    
    /// Maps array of domain objects to DTOs
    /// - Parameter domains: Array of domain objects
    /// - Parameter mapper: Mapping function
    /// - Returns: Array of DTOs, excluding failed mappings
    public static func mapToDTO<Domain, DTO: DataTransferObject>(
        _ domains: [Domain],
        using mapper: (Domain) -> DTO?
    ) -> [DTO] {
        return domains.compactMap(mapper)
    }
    
    /// Maps array of DTOs to domain objects
    /// - Parameter dtos: Array of DTOs
    /// - Parameter mapper: Mapping function
    /// - Returns: Array of domain objects, excluding failed mappings
    public static func mapToDomain<DTO: DataTransferObject, Domain>(
        _ dtos: [DTO],
        using mapper: (DTO) -> Domain?
    ) -> [Domain] {
        return dtos.compactMap(mapper)
    }
    
    /// Safe mapping with error collection
    /// - Parameter items: Items to map
    /// - Parameter mapper: Mapping function that can throw
    /// - Returns: Tuple of successful mappings and errors
    public static func safeMap<Input, Output>(
        _ items: [Input],
        using mapper: (Input) throws -> Output
    ) -> (results: [Output], errors: [Error]) {
        var results: [Output] = []
        var errors: [Error] = []
        
        for item in items {
            do {
                let result = try mapper(item)
                results.append(result)
            } catch {
                errors.append(error)
            }
        }
        
        return (results, errors)
    }
}

// MARK: - Mapping Errors

/// Errors that can occur during mapping
public enum MappingError: Error, LocalizedError {
    case invalidData(String)
    case missingRequiredField(String)
    case invalidFormat(String)
    case validationFailed([String])
    case conversionFailed(String)
    
    public var errorDescription: String? {
        switch self {
        case .invalidData(let message):
            return "Invalid data: \(message)"
        case .missingRequiredField(let field):
            return "Missing required field: \(field)"
        case .invalidFormat(let field):
            return "Invalid format for field: \(field)"
        case .validationFailed(let errors):
            return "Validation failed: \(errors.joined(separator: ", "))"
        case .conversionFailed(let message):
            return "Conversion failed: \(message)"
        }
    }
} 