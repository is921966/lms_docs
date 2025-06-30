import Combine
import Foundation

// MARK: - Competency Mock Service
class CompetencyMockService: ObservableObject {
    static let shared = CompetencyMockService()

    @Published private(set) var competencies: [Competency] = []
    private var cancellables = Set<AnyCancellable>()

    init() {
        loadMockData()
    }

    // MARK: - Mock Data Generation
    private func loadMockData() {
        competencies = [
            // Technical Competencies
            Competency(
                name: "iOS разработка",
                description: "Разработка мобильных приложений для платформы iOS с использованием Swift и SwiftUI",
                category: .technical,
                color: .blue,
                levels: CompetencyLevel.defaultLevels(),
                relatedPositions: ["iOS Developer", "Mobile Lead", "Tech Lead"]
            ),
            Competency(
                name: "Backend разработка",
                description: "Создание серверной части приложений, API, работа с базами данных",
                category: .technical,
                color: .green,
                levels: CompetencyLevel.defaultLevels(),
                relatedPositions: ["Backend Developer", "Full Stack Developer", "Tech Lead"]
            ),
            Competency(
                name: "DevOps",
                description: "Автоматизация процессов разработки, CI/CD, управление инфраструктурой",
                category: .technical,
                color: .orange,
                levels: CompetencyLevel.defaultLevels(),
                relatedPositions: ["DevOps Engineer", "SRE", "Platform Engineer"]
            ),

            // Soft Skills
            Competency(
                name: "Коммуникация",
                description: "Эффективное общение с коллегами, клиентами, презентационные навыки",
                category: .softSkills,
                color: .purple,
                levels: CompetencyLevel.defaultLevels(),
                relatedPositions: ["All Positions"]
            ),
            Competency(
                name: "Работа в команде",
                description: "Способность эффективно работать в команде, взаимопомощь, коллаборация",
                category: .softSkills,
                color: .pink,
                levels: CompetencyLevel.defaultLevels(),
                relatedPositions: ["All Positions"]
            ),

            // Management
            Competency(
                name: "Управление проектами",
                description: "Планирование, организация и контроль проектов, работа с рисками",
                category: .management,
                color: .red,
                levels: CompetencyLevel.defaultLevels(),
                relatedPositions: ["Project Manager", "Product Manager", "Team Lead"]
            ),
            Competency(
                name: "Управление людьми",
                description: "Лидерство, мотивация команды, проведение 1-1, развитие сотрудников",
                category: .management,
                color: .yellow,
                levels: CompetencyLevel.defaultLevels(),
                relatedPositions: ["Team Lead", "Engineering Manager", "Department Head"]
            ),

            // Leadership
            Competency(
                name: "Стратегическое мышление",
                description: "Способность видеть долгосрочную перспективу, принимать стратегические решения",
                category: .leadership,
                color: .purple,
                levels: CompetencyLevel.defaultLevels(),
                relatedPositions: ["CTO", "VP Engineering", "Product Director"]
            ),

            // Innovation
            Competency(
                name: "Инновационность",
                description: "Генерация новых идей, внедрение инноваций, улучшение процессов",
                category: .innovation,
                color: .green,
                levels: CompetencyLevel.defaultLevels(),
                relatedPositions: ["Innovation Manager", "R&D Lead", "Product Manager"]
            ),

            // Sales
            Competency(
                name: "Продажи B2B",
                description: "Навыки продаж корпоративным клиентам, работа с крупными сделками",
                category: .sales,
                color: .orange,
                levels: CompetencyLevel.defaultLevels(),
                relatedPositions: ["Sales Manager", "Account Manager", "Business Development"]
            )
        ]
    }

    // MARK: - CRUD Operations

    // Create
    func createCompetency(_ competency: Competency) {
        competencies.append(competency)
    }

    // Read
    func getCompetency(by id: UUID) -> Competency? {
        competencies.first { $0.id == id }
    }

    func searchCompetencies(query: String) -> [Competency] {
        guard !query.isEmpty else { return competencies }

        return competencies.filter { competency in
            competency.name.localizedCaseInsensitiveContains(query) ||
            competency.description.localizedCaseInsensitiveContains(query) ||
            competency.category.rawValue.localizedCaseInsensitiveContains(query)
        }
    }

    func getCompetencies(by category: CompetencyCategory? = nil, activeOnly: Bool = true) -> [Competency] {
        var filtered = competencies

        if let category = category {
            filtered = filtered.filter { $0.category == category }
        }

        if activeOnly {
            filtered = filtered.filter { $0.isActive }
        }

        return filtered
    }

    // Update
    func updateCompetency(_ competency: Competency) {
        if let index = competencies.firstIndex(where: { $0.id == competency.id }) {
            var updated = competency
            updated.updatedAt = Date()
            competencies[index] = updated
        }
    }

    // Delete
    func deleteCompetency(_ id: UUID) {
        competencies.removeAll { $0.id == id }
    }

    // Deactivate (soft delete)
    func toggleCompetencyStatus(_ id: UUID) {
        if let index = competencies.firstIndex(where: { $0.id == id }) {
            competencies[index].isActive.toggle()
            competencies[index].updatedAt = Date()
        }
    }

    // MARK: - Bulk Operations

    func importCompetencies(_ newCompetencies: [Competency]) {
        competencies.append(contentsOf: newCompetencies)
    }

    func exportCompetencies() -> [Competency] {
        competencies
    }

    // MARK: - Statistics

    var totalCompetencies: Int {
        competencies.count
    }

    var activeCompetencies: Int {
        competencies.filter { $0.isActive }.count
    }

    var competenciesByCategory: [CompetencyCategory: Int] {
        Dictionary(grouping: competencies) { $0.category }
            .mapValues { $0.count }
    }

    // MARK: - Sample Data Helpers

    func generateSampleCompetency() -> Competency {
        let categories = CompetencyCategory.allCases
        let colors = CompetencyColor.allCases

        return Competency(
            name: "Новая компетенция",
            description: "Описание новой компетенции",
            category: categories.randomElement()!,
            color: colors.randomElement()!
        )
    }
}
