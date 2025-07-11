import Foundation
import SwiftUI

// MARK: - Competency Model
struct Competency: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var description: String
    var category: CompetencyCategory
    var color: CompetencyColor
    var levels: [CompetencyLevel]
    var isActive: Bool
    var relatedPositions: [String] // Position IDs
    var createdAt: Date
    var updatedAt: Date

    // Numeric properties for levels and statistics
    var currentLevel: Int = 1
    var requiredLevel: Int = 3
    var usageCount: Int = 0
    var coursesCount: Int = 0

    // Recommended courses for improving this competency
    var recommendedCourses: [String]?

    // Computed properties
    var maxLevel: Int {
        levels.count
    }

    var colorHex: String {
        color.hex
    }

    var swiftUIColor: Color {
        Color(hex: color.hex)
    }

    // Initialize with defaults
    init(
        id: UUID = UUID(),
        name: String,
        description: String = "",
        category: CompetencyCategory = .technical,
        color: CompetencyColor = .blue,
        levels: [CompetencyLevel] = CompetencyLevel.defaultLevels(),
        isActive: Bool = true,
        relatedPositions: [String] = [],
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.category = category
        self.color = color
        self.levels = levels
        self.isActive = isActive
        self.relatedPositions = relatedPositions
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

// MARK: - Competency Category
enum CompetencyCategory: String, CaseIterable, Codable {
    case technical = "Технические"
    case softSkills = "Soft Skills"
    case management = "Управление"
    case leadership = "Лидерство"
    case innovation = "Инновации"
    case sales = "Продажи"
    case other = "Другое"

    var icon: String {
        switch self {
        case .technical: return "gearshape.2"
        case .softSkills: return "person.2.circle"
        case .management: return "person.3"
        case .leadership: return "star.circle"
        case .innovation: return "lightbulb"
        case .sales: return "chart.line.uptrend.xyaxis"
        case .other: return "folder"
        }
    }
}

// MARK: - Competency Color
enum CompetencyColor: String, CaseIterable, Codable {
    case blue = "blue"
    case green = "green"
    case red = "red"
    case purple = "purple"
    case orange = "orange"
    case pink = "pink"
    case yellow = "yellow"
    case gray = "gray"

    var hex: String {
        switch self {
        case .blue: return "#2196F3"
        case .green: return "#4CAF50"
        case .red: return "#F44336"
        case .purple: return "#9C27B0"
        case .orange: return "#FF9800"
        case .pink: return "#E91E63"
        case .yellow: return "#FFC107"
        case .gray: return "#9E9E9E"
        }
    }

    var name: String {
        switch self {
        case .blue: return "Синий"
        case .green: return "Зеленый"
        case .red: return "Красный"
        case .purple: return "Фиолетовый"
        case .orange: return "Оранжевый"
        case .pink: return "Розовый"
        case .yellow: return "Желтый"
        case .gray: return "Серый"
        }
    }

    var swiftUIColor: Color {
        Color(hex: hex)
    }
}

// Color extension moved to PerplexityTheme.swift to avoid duplication
