import Foundation
import SwiftUI

// MARK: - Position Model
struct Position: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var description: String
    var department: String
    var level: PositionLevel
    var competencyRequirements: [CompetencyRequirement]
    var careerPaths: [CareerPath]
    var isActive: Bool
    var employeeCount: Int
    var createdAt: Date
    var updatedAt: Date

    // Computed properties
    var requiredCompetenciesCount: Int {
        competencyRequirements.count
    }

    var totalRequiredScore: Int {
        competencyRequirements.reduce(0) { $0 + $1.requiredLevel }
    }

    var averageRequiredLevel: Double {
        guard !competencyRequirements.isEmpty else { return 0 }
        return Double(totalRequiredScore) / Double(competencyRequirements.count)
    }

    // Initialize with defaults
    init(
        id: UUID = UUID(),
        name: String,
        description: String = "",
        department: String,
        level: PositionLevel = .junior,
        competencyRequirements: [CompetencyRequirement] = [],
        careerPaths: [CareerPath] = [],
        isActive: Bool = true,
        employeeCount: Int = 0,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.department = department
        self.level = level
        self.competencyRequirements = competencyRequirements
        self.careerPaths = careerPaths
        self.isActive = isActive
        self.employeeCount = employeeCount
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

// MARK: - Position Level
enum PositionLevel: String, CaseIterable, Codable {
    case intern = "Стажер"
    case junior = "Junior"
    case middle = "Middle"
    case senior = "Senior"
    case lead = "Lead"
    case principal = "Principal"
    case manager = "Manager"
    case director = "Director"

    var icon: String {
        switch self {
        case .intern: return "studentdesk"
        case .junior: return "person.fill"
        case .middle: return "person.2.fill"
        case .senior: return "star.fill"
        case .lead: return "star.circle.fill"
        case .principal: return "crown.fill"
        case .manager: return "person.3.fill"
        case .director: return "building.2.fill"
        }
    }

    var color: Color {
        switch self {
        case .intern: return .gray
        case .junior: return .green
        case .middle: return .blue
        case .senior: return .purple
        case .lead: return .orange
        case .principal: return .red
        case .manager: return .indigo
        case .director: return .pink
        }
    }

    var sortOrder: Int {
        switch self {
        case .intern: return 0
        case .junior: return 1
        case .middle: return 2
        case .senior: return 3
        case .lead: return 4
        case .principal: return 5
        case .manager: return 6
        case .director: return 7
        }
    }
}

// MARK: - Competency Requirement
struct CompetencyRequirement: Identifiable, Codable, Hashable {
    let id: UUID
    let competencyId: UUID
    var competencyName: String // Denormalized for display
    var requiredLevel: Int
    var isCritical: Bool // Must-have vs nice-to-have

    init(
        id: UUID = UUID(),
        competencyId: UUID,
        competencyName: String,
        requiredLevel: Int,
        isCritical: Bool = false
    ) {
        self.id = id
        self.competencyId = competencyId
        self.competencyName = competencyName
        self.requiredLevel = requiredLevel
        self.isCritical = isCritical
    }
}
