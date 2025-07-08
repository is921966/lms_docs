//
//  PaginationModels.swift
//  LMS
//
//  Created on Sprint 41 - Pagination Models
//

import Foundation

/// Request parameters for pagination
public struct PaginationRequest: Codable, Equatable {
    public let page: Int
    public let limit: Int
    
    /// Alias for limit to match Repository.swift expectations
    public var pageSize: Int { limit }
    
    /// Computed offset for pagination
    public var offset: Int { (page - 1) * limit }
    
    public init(page: Int = 1, limit: Int = 20) {
        self.page = max(1, page)
        self.limit = max(1, min(100, limit))
    }
}

// MARK: - Paginated Response
public struct PaginatedResponse<T: Codable>: Codable {
    public let items: [T]
    public let currentPage: Int
    public let totalPages: Int
    public let totalItems: Int
    
    public init(items: [T], currentPage: Int, totalPages: Int, totalItems: Int) {
        self.items = items
        self.currentPage = currentPage
        self.totalPages = totalPages
        self.totalItems = totalItems
    }
    
    public var hasNextPage: Bool {
        return currentPage < totalPages
    }
    
    public var hasPreviousPage: Bool {
        return currentPage > 1
    }
}

/// Non-generic pagination info for simple responses
public struct PaginationInfo: Decodable {
    public let page: Int
    public let limit: Int
    public let total: Int
    public let totalPages: Int
    
    enum CodingKeys: String, CodingKey {
        case page
        case limit
        case total
        case totalPages = "total_pages"
    }
}
