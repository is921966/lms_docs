import Foundation

// MARK: - CompetencyServiceProtocol

protocol CompetencyServiceProtocol {
    func getCompetencies(page: Int, limit: Int, filters: CompetencyFilters?) async throws -> CompetenciesResponse
    func getCompetency(id: String) async throws -> CompetencyResponse
    func createCompetency(_ competency: CreateCompetencyRequest) async throws -> CompetencyResponse
    func updateCompetency(id: String, competency: UpdateCompetencyRequest) async throws -> CompetencyResponse
    func deleteCompetency(id: String) async throws
    func getCategories() async throws -> [CompetencyCategoryResponse]
    func getCompetencyLevels(competencyId: String) async throws -> [CompetencyLevelResponse]
    func getUserCompetencies(userId: String) async throws -> [UserCompetencyResponse]
    func assignCompetency(_ assignment: CompetencyAssignmentRequest) async throws -> UserCompetencyResponse
}

// MARK: - CompetencyService

final class CompetencyService: CompetencyServiceProtocol {
    private let apiClient: APIClient
    
    init(apiClient: APIClient = .shared) {
        self.apiClient = apiClient
    }
    
    func getCompetencies(page: Int = 1, limit: Int = 20, filters: CompetencyFilters? = nil) async throws -> CompetenciesResponse {
        return try await apiClient.request(CompetencyEndpoint.getCompetencies(page: page, limit: limit, filters: filters))
    }
    
    func getCompetency(id: String) async throws -> CompetencyResponse {
        return try await apiClient.request(CompetencyEndpoint.getCompetency(id: id))
    }
    
    func createCompetency(_ competency: CreateCompetencyRequest) async throws -> CompetencyResponse {
        return try await apiClient.request(CompetencyEndpoint.createCompetency(competency: competency))
    }
    
    func updateCompetency(id: String, competency: UpdateCompetencyRequest) async throws -> CompetencyResponse {
        return try await apiClient.request(CompetencyEndpoint.updateCompetency(id: id, competency: competency))
    }
    
    func deleteCompetency(id: String) async throws {
        let _: EmptyResponse = try await apiClient.request(CompetencyEndpoint.deleteCompetency(id: id))
    }
    
    func getCategories() async throws -> [CompetencyCategoryResponse] {
        struct CategoriesWrapper: Decodable {
            let categories: [CompetencyCategoryResponse]
        }
        let wrapper: CategoriesWrapper = try await apiClient.request(CompetencyEndpoint.getCategories)
        return wrapper.categories
    }
    
    func getCompetencyLevels(competencyId: String) async throws -> [CompetencyLevelResponse] {
        struct LevelsWrapper: Decodable {
            let levels: [CompetencyLevelResponse]
        }
        let wrapper: LevelsWrapper = try await apiClient.request(CompetencyEndpoint.getCompetencyLevels(competencyId: competencyId))
        return wrapper.levels
    }
    
    func getUserCompetencies(userId: String) async throws -> [UserCompetencyResponse] {
        struct UserCompetenciesWrapper: Decodable {
            let competencies: [UserCompetencyResponse]
        }
        let wrapper: UserCompetenciesWrapper = try await apiClient.request(CompetencyEndpoint.getUserCompetencies(userId: userId))
        return wrapper.competencies
    }
    
    func assignCompetency(_ assignment: CompetencyAssignmentRequest) async throws -> UserCompetencyResponse {
        return try await apiClient.request(CompetencyEndpoint.assignCompetency(assignment: assignment))
    }
}

// MARK: - MockCompetencyService

final class MockCompetencyService: CompetencyServiceProtocol {
    var mockCompetencies: [CompetencyResponse] = []
    var mockCategories: [CompetencyCategoryResponse] = []
    var mockUserCompetencies: [UserCompetencyResponse] = []
    var shouldThrowError = false
    var error: Error = APIError.unknown(statusCode: 500)
    
    init() {
        setupMockData()
    }
    
    private func setupMockData() {
        // Mock categories
        mockCategories = [
            CompetencyCategoryResponse(id: "1", name: "Технические навыки", description: "Навыки работы с технологиями"),
            CompetencyCategoryResponse(id: "2", name: "Soft Skills", description: "Межличностные навыки"),
            CompetencyCategoryResponse(id: "3", name: "Управленческие навыки", description: "Навыки управления и лидерства")
        ]
        
        // Mock competencies
        mockCompetencies = [
            CompetencyResponse(
                id: "1",
                name: "Swift Development",
                description: "Разработка на Swift",
                category: mockCategories[0],
                type: "technical",
                levels: [
                    CompetencyLevelResponse(id: "1", level: 1, name: "Начинающий", description: "Базовые знания Swift", criteria: ["Знает синтаксис", "Может писать простые функции"]),
                    CompetencyLevelResponse(id: "2", level: 2, name: "Средний", description: "Уверенные знания Swift", criteria: ["Понимает ООП", "Работает с async/await"]),
                    CompetencyLevelResponse(id: "3", level: 3, name: "Продвинутый", description: "Экспертные знания Swift", criteria: ["Знает advanced patterns", "Оптимизирует производительность"])
                ],
                isActive: true,
                createdAt: Date(),
                updatedAt: Date()
            ),
            CompetencyResponse(
                id: "2",
                name: "Коммуникация",
                description: "Навыки эффективной коммуникации",
                category: mockCategories[1],
                type: "soft",
                levels: [
                    CompetencyLevelResponse(id: "4", level: 1, name: "Базовый", description: "Базовые навыки общения", criteria: ["Ясно выражает мысли", "Слушает собеседника"]),
                    CompetencyLevelResponse(id: "5", level: 2, name: "Развитый", description: "Хорошие навыки общения", criteria: ["Проводит презентации", "Ведет переговоры"])
                ],
                isActive: true,
                createdAt: Date(),
                updatedAt: Date()
            )
        ]
    }
    
    func getCompetencies(page: Int, limit: Int, filters: CompetencyFilters?) async throws -> CompetenciesResponse {
        if shouldThrowError { throw error }
        
        var filteredCompetencies = mockCompetencies
        
        if let filters = filters {
            if let category = filters.category {
                filteredCompetencies = filteredCompetencies.filter { $0.category.id == category }
            }
            if let type = filters.type {
                filteredCompetencies = filteredCompetencies.filter { $0.type == type }
            }
            if let search = filters.search {
                filteredCompetencies = filteredCompetencies.filter {
                    $0.name.localizedCaseInsensitiveContains(search) ||
                    $0.description.localizedCaseInsensitiveContains(search)
                }
            }
        }
        
        let startIndex = (page - 1) * limit
        let endIndex = min(startIndex + limit, filteredCompetencies.count)
        let pageCompetencies = Array(filteredCompetencies[startIndex..<endIndex])
        
        return CompetenciesResponse(
            competencies: pageCompetencies,
            pagination: PaginationResponse(
                page: page,
                limit: limit,
                total: filteredCompetencies.count,
                totalPages: (filteredCompetencies.count + limit - 1) / limit
            )
        )
    }
    
    func getCompetency(id: String) async throws -> CompetencyResponse {
        if shouldThrowError { throw error }
        
        guard let competency = mockCompetencies.first(where: { $0.id == id }) else {
            throw APIError.notFound
        }
        return competency
    }
    
    func createCompetency(_ competency: CreateCompetencyRequest) async throws -> CompetencyResponse {
        if shouldThrowError { throw error }
        
        let newCompetency = CompetencyResponse(
            id: UUID().uuidString,
            name: competency.name,
            description: competency.description,
            category: mockCategories.first(where: { $0.id == competency.category }) ?? mockCategories[0],
            type: competency.type,
            levels: competency.levels.enumerated().map { index, level in
                CompetencyLevelResponse(
                    id: UUID().uuidString,
                    level: level.level,
                    name: level.name,
                    description: level.description,
                    criteria: level.criteria
                )
            },
            isActive: true,
            createdAt: Date(),
            updatedAt: Date()
        )
        mockCompetencies.append(newCompetency)
        return newCompetency
    }
    
    func updateCompetency(id: String, competency: UpdateCompetencyRequest) async throws -> CompetencyResponse {
        if shouldThrowError { throw error }
        
        guard let index = mockCompetencies.firstIndex(where: { $0.id == id }) else {
            throw APIError.notFound
        }
        
        var updatedCompetency = mockCompetencies[index]
        if let name = competency.name { updatedCompetency.name = name }
        if let description = competency.description { updatedCompetency.description = description }
        if let isActive = competency.isActive { updatedCompetency.isActive = isActive }
        updatedCompetency.updatedAt = Date()
        
        mockCompetencies[index] = updatedCompetency
        return updatedCompetency
    }
    
    func deleteCompetency(id: String) async throws {
        if shouldThrowError { throw error }
        
        guard let index = mockCompetencies.firstIndex(where: { $0.id == id }) else {
            throw APIError.notFound
        }
        mockCompetencies.remove(at: index)
    }
    
    func getCategories() async throws -> [CompetencyCategoryResponse] {
        if shouldThrowError { throw error }
        return mockCategories
    }
    
    func getCompetencyLevels(competencyId: String) async throws -> [CompetencyLevelResponse] {
        if shouldThrowError { throw error }
        
        guard let competency = mockCompetencies.first(where: { $0.id == competencyId }) else {
            throw APIError.notFound
        }
        return competency.levels
    }
    
    func getUserCompetencies(userId: String) async throws -> [UserCompetencyResponse] {
        if shouldThrowError { throw error }
        return mockUserCompetencies
    }
    
    func assignCompetency(_ assignment: CompetencyAssignmentRequest) async throws -> UserCompetencyResponse {
        if shouldThrowError { throw error }
        
        guard let competency = mockCompetencies.first(where: { $0.id == assignment.competencyId }) else {
            throw APIError.notFound
        }
        
        let userCompetency = UserCompetencyResponse(
            id: UUID().uuidString,
            competency: competency,
            currentLevel: 0,
            targetLevel: assignment.targetLevel,
            progress: 0.0,
            assessments: [],
            deadline: assignment.deadline
        )
        mockUserCompetencies.append(userCompetency)
        return userCompetency
    }
} 