//
//  CommonModels.swift
//  LMS
//
//  Created by AI Assistant on 03/07/2025.
//

import Foundation

/// Empty response for API calls that don't return data
public struct EmptyResponse: Decodable, Equatable {
    public init() {}
}

/// Generic pagination response
public struct PaginationResponse<T: Decodable>: Decodable {
    public let data: [T]
    public let currentPage: Int
    public let lastPage: Int
    public let perPage: Int
    public let total: Int
    
    enum CodingKeys: String, CodingKey {
        case data
        case currentPage = "current_page"
        case lastPage = "last_page"
        case perPage = "per_page"
        case total
    }
}

/// Generic error response
public struct ErrorResponse: Decodable, LocalizedError {
    public let message: String
    public let errors: [String: [String]]?
    
    public var errorDescription: String? {
        return message
    }
} 