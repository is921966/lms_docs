import Foundation
import Combine

// MARK: - Position Mock Service
class PositionMockService: ObservableObject {
    static let shared = PositionMockService()
    
    @Published private(set) var positions: [Position] = []
    @Published private(set) var careerPaths: [CareerPath] = []
    private let competencyService = CompetencyMockService.shared
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        loadMockData()
    }
    
    // MARK: - Mock Data Generation
    private func loadMockData() {
        // Get competencies for requirements
        let competencies = competencyService.competencies
        
        // Create positions
        positions = [
            // Engineering positions
            Position(
                name: "iOS Developer Junior",
                description: "Разработка мобильных приложений под iOS, базовые задачи",
                department: "Engineering",
                level: .junior,
                competencyRequirements: [
                    CompetencyRequirement(
                        competencyId: competencies.first { $0.name == "iOS разработка" }?.id ?? UUID(),
                        competencyName: "iOS разработка",
                        requiredLevel: 2,
                        isCritical: true
                    ),
                    CompetencyRequirement(
                        competencyId: competencies.first { $0.name == "Работа в команде" }?.id ?? UUID(),
                        competencyName: "Работа в команде",
                        requiredLevel: 2,
                        isCritical: false
                    )
                ],
                employeeCount: 12
            ),
            
            Position(
                name: "iOS Developer Middle",
                description: "Самостоятельная разработка фичей, менторинг джуниоров",
                department: "Engineering",
                level: .middle,
                competencyRequirements: [
                    CompetencyRequirement(
                        competencyId: competencies.first { $0.name == "iOS разработка" }?.id ?? UUID(),
                        competencyName: "iOS разработка",
                        requiredLevel: 3,
                        isCritical: true
                    ),
                    CompetencyRequirement(
                        competencyId: competencies.first { $0.name == "Работа в команде" }?.id ?? UUID(),
                        competencyName: "Работа в команде",
                        requiredLevel: 3,
                        isCritical: false
                    ),
                    CompetencyRequirement(
                        competencyId: competencies.first { $0.name == "Коммуникация" }?.id ?? UUID(),
                        competencyName: "Коммуникация",
                        requiredLevel: 3,
                        isCritical: false
                    )
                ],
                employeeCount: 8
            ),
            
            Position(
                name: "iOS Developer Senior",
                description: "Архитектурные решения, лидерство в проектах",
                department: "Engineering",
                level: .senior,
                competencyRequirements: [
                    CompetencyRequirement(
                        competencyId: competencies.first { $0.name == "iOS разработка" }?.id ?? UUID(),
                        competencyName: "iOS разработка",
                        requiredLevel: 4,
                        isCritical: true
                    ),
                    CompetencyRequirement(
                        competencyId: competencies.first { $0.name == "Управление проектами" }?.id ?? UUID(),
                        competencyName: "Управление проектами",
                        requiredLevel: 3,
                        isCritical: false
                    ),
                    CompetencyRequirement(
                        competencyId: competencies.first { $0.name == "Стратегическое мышление" }?.id ?? UUID(),
                        competencyName: "Стратегическое мышление",
                        requiredLevel: 3,
                        isCritical: false
                    )
                ],
                employeeCount: 4
            ),
            
            Position(
                name: "iOS Team Lead",
                description: "Управление командой iOS разработчиков",
                department: "Engineering",
                level: .lead,
                competencyRequirements: [
                    CompetencyRequirement(
                        competencyId: competencies.first { $0.name == "iOS разработка" }?.id ?? UUID(),
                        competencyName: "iOS разработка",
                        requiredLevel: 4,
                        isCritical: true
                    ),
                    CompetencyRequirement(
                        competencyId: competencies.first { $0.name == "Управление людьми" }?.id ?? UUID(),
                        competencyName: "Управление людьми",
                        requiredLevel: 4,
                        isCritical: true
                    ),
                    CompetencyRequirement(
                        competencyId: competencies.first { $0.name == "Управление проектами" }?.id ?? UUID(),
                        competencyName: "Управление проектами",
                        requiredLevel: 4,
                        isCritical: true
                    )
                ],
                employeeCount: 2
            ),
            
            // Backend positions
            Position(
                name: "Backend Developer Middle",
                description: "Разработка серверной части приложений",
                department: "Engineering",
                level: .middle,
                competencyRequirements: [
                    CompetencyRequirement(
                        competencyId: competencies.first { $0.name == "Backend разработка" }?.id ?? UUID(),
                        competencyName: "Backend разработка",
                        requiredLevel: 3,
                        isCritical: true
                    ),
                    CompetencyRequirement(
                        competencyId: competencies.first { $0.name == "DevOps" }?.id ?? UUID(),
                        competencyName: "DevOps",
                        requiredLevel: 2,
                        isCritical: false
                    )
                ],
                employeeCount: 10
            ),
            
            // Management positions
            Position(
                name: "Product Manager",
                description: "Управление продуктом, работа с требованиями",
                department: "Product",
                level: .middle,
                competencyRequirements: [
                    CompetencyRequirement(
                        competencyId: competencies.first { $0.name == "Управление проектами" }?.id ?? UUID(),
                        competencyName: "Управление проектами",
                        requiredLevel: 4,
                        isCritical: true
                    ),
                    CompetencyRequirement(
                        competencyId: competencies.first { $0.name == "Стратегическое мышление" }?.id ?? UUID(),
                        competencyName: "Стратегическое мышление",
                        requiredLevel: 3,
                        isCritical: true
                    ),
                    CompetencyRequirement(
                        competencyId: competencies.first { $0.name == "Инновационность" }?.id ?? UUID(),
                        competencyName: "Инновационность",
                        requiredLevel: 3,
                        isCritical: false
                    )
                ],
                employeeCount: 5
            ),
            
            Position(
                name: "Engineering Manager",
                description: "Управление инженерными командами",
                department: "Engineering",
                level: .manager,
                competencyRequirements: [
                    CompetencyRequirement(
                        competencyId: competencies.first { $0.name == "Управление людьми" }?.id ?? UUID(),
                        competencyName: "Управление людьми",
                        requiredLevel: 5,
                        isCritical: true
                    ),
                    CompetencyRequirement(
                        competencyId: competencies.first { $0.name == "Стратегическое мышление" }?.id ?? UUID(),
                        competencyName: "Стратегическое мышление",
                        requiredLevel: 4,
                        isCritical: true
                    )
                ],
                employeeCount: 3
            ),
            
            // Sales positions
            Position(
                name: "Sales Manager",
                description: "Продажи корпоративным клиентам",
                department: "Sales",
                level: .middle,
                competencyRequirements: [
                    CompetencyRequirement(
                        competencyId: competencies.first { $0.name == "Продажи B2B" }?.id ?? UUID(),
                        competencyName: "Продажи B2B",
                        requiredLevel: 4,
                        isCritical: true
                    ),
                    CompetencyRequirement(
                        competencyId: competencies.first { $0.name == "Коммуникация" }?.id ?? UUID(),
                        competencyName: "Коммуникация",
                        requiredLevel: 5,
                        isCritical: true
                    )
                ],
                employeeCount: 7
            )
        ]
        
        // Create career paths
        createCareerPaths()
    }
    
    private func createCareerPaths() {
        guard positions.count >= 4 else { return }
        
        let juniorIOS = positions[0]
        let middleIOS = positions[1]
        let seniorIOS = positions[2]
        let leadIOS = positions[3]
        
        careerPaths = [
            // Junior to Middle
            CareerPath(
                fromPositionId: juniorIOS.id,
                toPositionId: middleIOS.id,
                fromPositionName: juniorIOS.name,
                toPositionName: middleIOS.name,
                estimatedDuration: .year1,
                requirements: [
                    CareerPathRequirement(
                        title: "iOS разработка уровень 3",
                        description: "Повысить компетенцию iOS разработка до уровня 3",
                        type: .competency
                    ),
                    CareerPathRequirement(
                        title: "2+ года опыта",
                        description: "Минимум 2 года опыта разработки iOS приложений",
                        type: .experience
                    ),
                    CareerPathRequirement(
                        title: "Успешные проекты",
                        description: "Участие в 3+ успешных проектах",
                        type: .project
                    )
                ],
                description: "Стандартный путь развития iOS разработчика",
                successRate: 0.85
            ),
            
            // Middle to Senior
            CareerPath(
                fromPositionId: middleIOS.id,
                toPositionId: seniorIOS.id,
                fromPositionName: middleIOS.name,
                toPositionName: seniorIOS.name,
                estimatedDuration: .years2,
                requirements: [
                    CareerPathRequirement(
                        title: "iOS разработка уровень 4",
                        description: "Экспертный уровень iOS разработки",
                        type: .competency
                    ),
                    CareerPathRequirement(
                        title: "Архитектурный опыт",
                        description: "Опыт проектирования архитектуры приложений",
                        type: .experience
                    ),
                    CareerPathRequirement(
                        title: "Менторинг",
                        description: "Опыт менторинга junior разработчиков",
                        type: .experience
                    ),
                    CareerPathRequirement(
                        title: "Сертификация Apple",
                        description: "Желательна сертификация Apple Developer",
                        type: .certification
                    )
                ],
                description: "Требует глубоких технических знаний и лидерских качеств",
                successRate: 0.65
            ),
            
            // Senior to Lead
            CareerPath(
                fromPositionId: seniorIOS.id,
                toPositionId: leadIOS.id,
                fromPositionName: seniorIOS.name,
                toPositionName: leadIOS.name,
                estimatedDuration: .years2,
                requirements: [
                    CareerPathRequirement(
                        title: "Управление людьми",
                        description: "Развить навыки управления командой",
                        type: .competency
                    ),
                    CareerPathRequirement(
                        title: "Опыт лидерства",
                        description: "Опыт технического лидерства в проектах",
                        type: .experience
                    ),
                    CareerPathRequirement(
                        title: "Soft skills",
                        description: "Развитые навыки коммуникации и эмпатии",
                        type: .other
                    )
                ],
                description: "Переход от технической роли к управленческой",
                successRate: 0.5
            )
        ]
    }
    
    // MARK: - CRUD Operations
    
    // Positions
    func createPosition(_ position: Position) {
        positions.append(position)
    }
    
    func getPosition(by id: UUID) -> Position? {
        positions.first { $0.id == id }
    }
    
    func updatePosition(_ position: Position) {
        if let index = positions.firstIndex(where: { $0.id == position.id }) {
            var updated = position
            updated.updatedAt = Date()
            positions[index] = updated
        }
    }
    
    func deletePosition(_ id: UUID) {
        positions.removeAll { $0.id == id }
        // Also remove related career paths
        careerPaths.removeAll { $0.fromPositionId == id || $0.toPositionId == id }
    }
    
    // Career Paths
    func createCareerPath(_ path: CareerPath) {
        careerPaths.append(path)
    }
    
    func getCareerPaths(for positionId: UUID) -> [CareerPath] {
        careerPaths.filter { $0.fromPositionId == positionId }
    }
    
    func getIncomingCareerPaths(for positionId: UUID) -> [CareerPath] {
        careerPaths.filter { $0.toPositionId == positionId }
    }
    
    // MARK: - Search and Filter
    
    func searchPositions(query: String) -> [Position] {
        guard !query.isEmpty else { return positions }
        
        return positions.filter { position in
            position.name.localizedCaseInsensitiveContains(query) ||
            position.description.localizedCaseInsensitiveContains(query) ||
            position.department.localizedCaseInsensitiveContains(query)
        }
    }
    
    func getPositions(by level: PositionLevel? = nil, department: String? = nil, activeOnly: Bool = true) -> [Position] {
        var filtered = positions
        
        if let level = level {
            filtered = filtered.filter { $0.level == level }
        }
        
        if let department = department {
            filtered = filtered.filter { $0.department == department }
        }
        
        if activeOnly {
            filtered = filtered.filter { $0.isActive }
        }
        
        return filtered
    }
    
    // MARK: - Statistics
    
    var departments: [String] {
        Array(Set(positions.map { $0.department })).sorted()
    }
    
    var totalEmployees: Int {
        positions.reduce(0) { $0 + $1.employeeCount }
    }
    
    var positionsByLevel: [PositionLevel: Int] {
        Dictionary(grouping: positions, by: { $0.level })
            .mapValues { $0.count }
    }
} 