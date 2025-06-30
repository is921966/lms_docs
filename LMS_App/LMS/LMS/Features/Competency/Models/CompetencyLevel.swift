import Foundation

// MARK: - Competency Level
struct CompetencyLevel: Identifiable, Codable, Hashable {
    let id: UUID
    let level: Int
    var name: String
    var description: String
    var behaviors: [String] // Observable behaviors for this level

    init(
        id: UUID = UUID(),
        level: Int,
        name: String,
        description: String,
        behaviors: [String] = []
    ) {
        self.id = id
        self.level = level
        self.name = name
        self.description = description
        self.behaviors = behaviors
    }

    // Generate default levels 1-5
    static func defaultLevels() -> [CompetencyLevel] {
        [
            CompetencyLevel(
                level: 1,
                name: "Начальный",
                description: "Базовое понимание концепций, требуется постоянное руководство",
                behaviors: [
                    "Знает основные термины и концепции",
                    "Выполняет простые задачи под руководством",
                    "Требует постоянной поддержки"
                ]
            ),
            CompetencyLevel(
                level: 2,
                name: "Развивающийся",
                description: "Применяет знания в стандартных ситуациях с периодической поддержкой",
                behaviors: [
                    "Понимает основные процессы",
                    "Выполняет типовые задачи самостоятельно",
                    "Иногда требует помощи в сложных ситуациях"
                ]
            ),
            CompetencyLevel(
                level: 3,
                name: "Опытный",
                description: "Уверенно применяет навыки, может помогать другим",
                behaviors: [
                    "Самостоятельно решает стандартные задачи",
                    "Может обучать начинающих",
                    "Предлагает улучшения процессов"
                ]
            ),
            CompetencyLevel(
                level: 4,
                name: "Продвинутый",
                description: "Экспертный уровень, решает сложные задачи, наставничество",
                behaviors: [
                    "Решает нестандартные и сложные задачи",
                    "Является наставником для команды",
                    "Разрабатывает новые подходы и методики"
                ]
            ),
            CompetencyLevel(
                level: 5,
                name: "Эксперт",
                description: "Признанный эксперт, стратегическое видение, инновации",
                behaviors: [
                    "Формирует стратегию развития компетенции",
                    "Признанный эксперт внутри и вне компании",
                    "Создает инновационные решения"
                ]
            )
        ]
    }

    // Get level by number
    static func getLevel(_ number: Int, from levels: [CompetencyLevel]) -> CompetencyLevel? {
        levels.first { $0.level == number }
    }

    // Color for level visualization
    var progressColor: String {
        switch level {
        case 1: return "#EF5350" // Red
        case 2: return "#FFA726" // Orange
        case 3: return "#FFEE58" // Yellow
        case 4: return "#66BB6A" // Green
        case 5: return "#42A5F5" // Blue
        default: return "#BDBDBD" // Gray
        }
    }

    // Progress percentage (for visual representation)
    var progressPercentage: Double {
        Double(level) / 5.0 * 100
    }
}
