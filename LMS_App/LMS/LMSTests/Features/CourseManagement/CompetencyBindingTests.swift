//
//  CompetencyBindingTests.swift
//  LMSTests
//
//  Testing competency binding functionality for courses
//

import XCTest
@testable import LMS

final class CompetencyBindingTests: XCTestCase {
    
    var sut: CompetencyBindingViewModel!
    var mockCourse: ManagedCourse!
    var mockCompetencies: [Competency]!
    var mockCompetencyService: MockCompetencyServiceForBinding!
    
    override func setUp() {
        super.setUp()
        
        mockCourse = ManagedCourse(
            title: "Test Course",
            description: "Test Description",
            duration: 40,
            status: .draft,
            competencies: [UUID()]
        )
        
        mockCompetencies = [
            Competency(
                id: UUID(),
                name: "Swift Programming",
                description: "iOS development with Swift",
                currentLevel: 3,
                requiredLevel: 3
            ),
            Competency(
                id: UUID(),
                name: "UIKit Framework",
                description: "Building iOS interfaces",
                currentLevel: 2,
                requiredLevel: 3
            ),
            Competency(
                id: UUID(),
                name: "Core Data",
                description: "Data persistence",
                currentLevel: 3,
                requiredLevel: 4
            )
        ]
        
        mockCompetencyService = MockCompetencyServiceForBinding()
        mockCompetencyService.mockCompetencies = mockCompetencies
        
        sut = CompetencyBindingViewModel(
            course: mockCourse,
            competencyService: mockCompetencyService
        )
    }
    
    override func tearDown() {
        sut = nil
        mockCourse = nil
        mockCompetencies = nil
        mockCompetencyService = nil
        super.tearDown()
    }
    
    // MARK: - Loading Competencies
    
    func test_loadCompetencies_shouldFetchFromService() async {
        // When
        await sut.loadCompetencies()
        
        // Then
        XCTAssertEqual(sut.availableCompetencies.count, 3)
        XCTAssertEqual(sut.availableCompetencies[0].name, "Swift Programming")
        XCTAssertFalse(sut.isLoading)
    }
    
    func test_loadCompetencies_withError_shouldSetErrorMessage() async {
        // Given
        mockCompetencyService.shouldReturnError = true
        
        // When
        await sut.loadCompetencies()
        
        // Then
        XCTAssertNotNil(sut.errorMessage)
        XCTAssertTrue(sut.availableCompetencies.isEmpty)
        XCTAssertFalse(sut.isLoading)
    }
    
    // MARK: - Selection Tests
    
    func test_selectCompetency_shouldAddToSelected() {
        // Given
        let competency = mockCompetencies[0]
        
        // When
        sut.toggleCompetency(competency)
        
        // Then
        XCTAssertTrue(sut.selectedCompetencies.contains(competency.id))
        XCTAssertEqual(sut.selectedCompetencies.count, 1)
    }
    
    func test_deselectCompetency_shouldRemoveFromSelected() {
        // Given
        let competency = mockCompetencies[0]
        sut.selectedCompetencies.insert(competency.id)
        
        // When
        sut.toggleCompetency(competency)
        
        // Then
        XCTAssertFalse(sut.selectedCompetencies.contains(competency.id))
        XCTAssertEqual(sut.selectedCompetencies.count, 0)
    }
    
    func test_isSelected_shouldReturnCorrectState() {
        // Given
        let competency = mockCompetencies[0]
        sut.selectedCompetencies.insert(competency.id)
        
        // Then
        XCTAssertTrue(sut.isSelected(competency))
        XCTAssertFalse(sut.isSelected(mockCompetencies[1]))
    }
    
    // MARK: - Search Tests
    
    func test_searchCompetencies_withMatchingText_shouldFilterResults() async {
        // Given
        await sut.loadCompetencies()
        
        // When
        sut.searchText = "Swift"
        
        // Then
        XCTAssertEqual(sut.filteredCompetencies.count, 1)
        XCTAssertEqual(sut.filteredCompetencies[0].name, "Swift Programming")
    }
    
    func test_searchCompetencies_withEmptyText_shouldShowAll() async {
        // Given
        await sut.loadCompetencies()
        
        // When
        sut.searchText = ""
        
        // Then
        XCTAssertEqual(sut.filteredCompetencies.count, 3)
    }
    
    func test_searchCompetencies_caseInsensitive_shouldMatch() async {
        // Given
        await sut.loadCompetencies()
        
        // When
        sut.searchText = "SWIFT"
        
        // Then
        XCTAssertEqual(sut.filteredCompetencies.count, 1)
    }
    
    // MARK: - Save Tests
    
    func test_saveCompetencies_shouldUpdateCourse() async {
        // Given
        let competency1 = mockCompetencies[0]
        let competency2 = mockCompetencies[1]
        sut.toggleCompetency(competency1)
        sut.toggleCompetency(competency2)
        
        // When
        let updatedCourse = await sut.saveCompetencies()
        
        // Then
        XCTAssertEqual(updatedCourse.competencies.count, 2)
        XCTAssertTrue(updatedCourse.competencies.contains(competency1.id))
        XCTAssertTrue(updatedCourse.competencies.contains(competency2.id))
    }
    
    func test_saveCompetencies_withNoSelection_shouldClearCompetencies() async {
        // Given - No competencies selected
        
        // When
        let updatedCourse = await sut.saveCompetencies()
        
        // Then
        XCTAssertTrue(updatedCourse.competencies.isEmpty)
    }
    
    // MARK: - Level Filter Tests
    
    func test_filterByLevel_shouldShowOnlyMatchingLevel() async {
        // Given
        await sut.loadCompetencies()
        
        // When
        sut.selectedLevel = 3
        
        // Then
        XCTAssertEqual(sut.filteredCompetencies.count, 2) // Swift and Core Data have currentLevel 3
        XCTAssertTrue(sut.filteredCompetencies.allSatisfy { $0.currentLevel == 3 })
    }
    
    func test_filterByLevel_withNilLevel_shouldShowAll() async {
        // Given
        await sut.loadCompetencies()
        
        // When
        sut.selectedLevel = nil
        
        // Then
        XCTAssertEqual(sut.filteredCompetencies.count, 3)
    }
    
    // MARK: - Competency Details
    
    func test_competencyDetails_shouldProvideFormattedInfo() {
        // Given
        let competency = mockCompetencies[0]
        
        // When
        let details = sut.getCompetencyDetails(competency)
        
        // Then
        XCTAssertTrue(details.contains("Текущий уровень: 3"))
        XCTAssertTrue(details.contains(competency.description))
    }
}

// MARK: - Mock Competency Service for Tests

class MockCompetencyServiceForBinding: CompetencyServiceProtocol {
    var mockCompetencies: [Competency] = []
    var shouldReturnError = false
    
    func getCompetencies(page: Int, limit: Int, filters: CompetencyFilters?) async throws -> CompetenciesResponse {
        if shouldReturnError {
            throw NSError(domain: "Test", code: 1, userInfo: [NSLocalizedDescriptionKey: "Test error"])
        }
        
        // Convert local Competency models to CompetencyResponse
        let responses = mockCompetencies.map { competency in
            CompetencyResponse(
                id: competency.id.uuidString,
                name: competency.name,
                description: competency.description,
                category: CompetencyCategoryResponse(id: "1", name: "Test", description: "Test"),
                type: "technical",
                levels: [],
                isActive: competency.isActive,
                createdAt: competency.createdAt,
                updatedAt: competency.updatedAt
            )
        }
        
        return CompetenciesResponse(
            competencies: responses,
            pagination: PaginationInfo(
                page: page,
                limit: limit,
                total: mockCompetencies.count,
                totalPages: 1
            )
        )
    }
    
    func getCompetency(id: String) async throws -> CompetencyResponse {
        guard let competency = mockCompetencies.first(where: { $0.id.uuidString == id }) else {
            throw NSError(domain: "Test", code: 404)
        }
        return CompetencyResponse(
            id: competency.id.uuidString,
            name: competency.name,
            description: competency.description,
            category: CompetencyCategoryResponse(id: "1", name: "Test", description: "Test"),
            type: "technical",
            levels: [],
            isActive: competency.isActive,
            createdAt: competency.createdAt,
            updatedAt: competency.updatedAt
        )
    }
    
    func createCompetency(_ competency: CreateCompetencyRequest) async throws -> CompetencyResponse {
        throw NSError(domain: "Test", code: 501) // Not implemented for tests
    }
    
    func updateCompetency(id: String, competency: UpdateCompetencyRequest) async throws -> CompetencyResponse {
        throw NSError(domain: "Test", code: 501) // Not implemented for tests
    }
    
    func deleteCompetency(id: String) async throws {
        mockCompetencies.removeAll { $0.id.uuidString == id }
    }
    
    func getCategories() async throws -> [CompetencyCategoryResponse] {
        return []
    }
    
    func getCompetencyLevels(competencyId: String) async throws -> [CompetencyLevelResponse] {
        return []
    }
    
    func getUserCompetencies(userId: String) async throws -> [UserCompetencyResponse] {
        return []
    }
    
    func assignCompetency(_ assignment: CompetencyAssignmentRequest) async throws -> UserCompetencyResponse {
        throw NSError(domain: "Test", code: 501) // Not implemented for tests
    }
}

// MARK: - View Tests

final class CompetencyBindingViewTests: XCTestCase {
    
    func test_emptyState_shouldShowWhenNoCompetencies() {
        // Given
        let viewModel = CompetencyBindingViewModel(
            course: ManagedCourse(
                title: "Test",
                description: "Test",
                duration: 1,
                status: .draft
            ),
            competencyService: MockCompetencyServiceForBinding()
        )
        
        // When
        let view = CompetencyBindingView(viewModel: viewModel) { _ in }
        
        // Then
        // This would be tested with UI testing
        // Verify empty state is shown when no competencies
    }
} 