import Foundation
import SwiftUI

// MARK: - Career Path Model
struct CareerPath: Identifiable, Codable, Hashable {
    let id: UUID
    let fromPositionId: UUID
    let toPositionId: UUID
    var fromPositionName: String // Denormalized
    var toPositionName: String // Denormalized
    var estimatedDuration: CareerPathDuration
    var requirements: [CareerPathRequirement]
    var description: String
    var successRate: Double // 0.0 - 1.0
    
    init(
        id: UUID = UUID(),
        fromPositionId: UUID,
        toPositionId: UUID,
        fromPositionName: String,
        toPositionName: String,
        estimatedDuration: CareerPathDuration,
        requirements: [CareerPathRequirement] = [],
        description: String = "",
        successRate: Double = 0.7
    ) {
        self.id = id
        self.fromPositionId = fromPositionId
        self.toPositionId = toPositionId
        self.fromPositionName = fromPositionName
        self.toPositionName = toPositionName
        self.estimatedDuration = estimatedDuration
        self.requirements = requirements
        self.description = description
        self.successRate = max(0, min(1, successRate))
    }
    
    var difficulty: CareerPathDifficulty {
        switch successRate {
        case 0.8...1.0: return .easy
        case 0.5..<0.8: return .moderate
        case 0..<0.5: return .hard
        default: return .moderate
        }
    }
}

// MARK: - Career Path Duration
enum CareerPathDuration: String, CaseIterable, Codable {
    case months6 = "6 месяцев"
    case year1 = "1 год"
    case years2 = "2 года"
    case years3 = "3 года"
    case years5 = "5 лет"
    case yearsMore = "Более 5 лет"
    
    var months: Int {
        switch self {
        case .months6: return 6
        case .year1: return 12
        case .years2: return 24
        case .years3: return 36
        case .years5: return 60
        case .yearsMore: return 72
        }
    }
}

// MARK: - Career Path Difficulty
enum CareerPathDifficulty: String {
    case easy = "Легкий"
    case moderate = "Средний"
    case hard = "Сложный"
    
    var color: Color {
        switch self {
        case .easy: return .green
        case .moderate: return .orange
        case .hard: return .red
        }
    }
    
    var icon: String {
        switch self {
        case .easy: return "checkmark.circle.fill"
        case .moderate: return "exclamationmark.circle.fill"
        case .hard: return "xmark.circle.fill"
        }
    }
}

// MARK: - Career Path Requirement
struct CareerPathRequirement: Identifiable, Codable, Hashable {
    let id: UUID
    var title: String
    var description: String
    var type: RequirementType
    var isCompleted: Bool
    
    init(
        id: UUID = UUID(),
        title: String,
        description: String = "",
        type: RequirementType,
        isCompleted: Bool = false
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.type = type
        self.isCompleted = isCompleted
    }
}

// MARK: - Requirement Type
enum RequirementType: String, CaseIterable, Codable {
    case competency = "Компетенция"
    case experience = "Опыт"
    case certification = "Сертификация"
    case education = "Образование"
    case project = "Проект"
    case other = "Другое"
    
    var icon: String {
        switch self {
        case .competency: return "star.fill"
        case .experience: return "clock.fill"
        case .certification: return "doc.text.fill"
        case .education: return "graduationcap.fill"
        case .project: return "folder.fill"
        case .other: return "ellipsis.circle.fill"
        }
    }
}

// MARK: - Career Progress
struct CareerProgress: Identifiable {
    let id: UUID
    let employeeId: UUID
    let currentPositionId: UUID
    let targetPositionId: UUID
    let careerPathId: UUID
    var startDate: Date
    var completedRequirements: Set<UUID>
    var notes: String
    
    var progressPercentage: Double {
        guard let careerPath = getCareerPath() else { return 0 }
        let total = careerPath.requirements.count
        guard total > 0 else { return 0 }
        return Double(completedRequirements.count) / Double(total) * 100
    }
    
    private func getCareerPath() -> CareerPath? {
        // This would normally fetch from service
        return nil
    }
} 