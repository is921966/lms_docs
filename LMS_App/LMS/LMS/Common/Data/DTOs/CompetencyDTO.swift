//
//  CompetencyDTO.swift
//  LMS
//
//  Created on 06/01/2025.
//

import Foundation

// MARK: - Competency DTO

public struct CompetencyDTO: Codable {
    public let id: String
    public let name: String
    public let description: String
    public let level: String
    public let category: String
    public let isActive: Bool
    
    public init(
        id: String,
        name: String,
        description: String,
        level: String,
        category: String,
        isActive: Bool = true
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.level = level
        self.category = category
        self.isActive = isActive
    }
}

// MARK: - Competency List Response

public struct CompetencyListResponse: Codable {
    public let competencies: [CompetencyDTO]
    public let total: Int
    public let page: Int
    public let limit: Int
    
    public init(
        competencies: [CompetencyDTO],
        total: Int,
        page: Int,
        limit: Int
    ) {
        self.competencies = competencies
        self.total = total
        self.page = page
        self.limit = limit
    }
} 