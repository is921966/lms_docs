import Foundation

// MARK: - Request Models

struct CompetencyFilters: Encodable {
    let category: String?
    let type: String?
    let search: String?
    let isActive: Bool?
}

struct CreateCompetencyRequest: Encodable {
    let name: String
    let description: String
    let category: String
    let type: String
    let levels: [CreateCompetencyLevelRequest]
}

struct CreateCompetencyLevelRequest: Encodable {
    let level: Int
    let name: String
    let description: String
    let criteria: [String]
}

struct UpdateCompetencyRequest: Encodable {
    let name: String?
    let description: String?
    let category: String?
    let type: String?
    let isActive: Bool?
}

struct CompetencyAssignmentRequest: Encodable {
    let competencyId: String
    let userId: String
    let targetLevel: Int
    let deadline: Date?
}

// MARK: - Response Models

struct CompetenciesResponse: Decodable {
    let competencies: [CompetencyResponse]
    let pagination: PaginationResponse
}

struct CompetencyResponse: Decodable {
    let id: String
    var name: String
    var description: String
    let category: CompetencyCategoryResponse
    let type: String
    let levels: [CompetencyLevelResponse]
    var isActive: Bool
    let createdAt: Date
    var updatedAt: Date
}

struct CompetencyCategoryResponse: Decodable {
    let id: String
    let name: String
    let description: String
}

struct CompetencyLevelResponse: Decodable {
    let id: String
    let level: Int
    let name: String
    let description: String
    let criteria: [String]
}

struct UserCompetencyResponse: Decodable {
    let id: String
    let competency: CompetencyResponse
    let currentLevel: Int
    let targetLevel: Int
    let progress: Double
    let assessments: [CompetencyAssessmentResponse]
    let deadline: Date?
}

struct CompetencyAssessmentResponse: Decodable {
    let id: String
    let level: Int
    let score: Double
    let assessedBy: String
    let assessedAt: Date
    let comments: String?
}

// MARK: - Pagination

struct PaginationResponse: Decodable {
    let page: Int
    let limit: Int
    let total: Int
    let totalPages: Int
}

// MARK: - Empty Response

struct EmptyResponse: Decodable {} 