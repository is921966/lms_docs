//
//  PaginationModels.swift
//  LMS
//
//  Created by AI Assistant on 04/07/2025.
//

import Foundation

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
