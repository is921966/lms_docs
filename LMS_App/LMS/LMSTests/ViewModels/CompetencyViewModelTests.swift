//
//  CompetencyViewModelTests.swift
//  LMSTests
//
//  Created on 06/07/2025.
//

import XCTest
import Combine
@testable import LMS

@MainActor
final class CompetencyViewModelTests: XCTestCase {
    
    var viewModel: CompetencyViewModel!
    var cancellables: Set<AnyCancellable> = []
    
    override func setUp() {
        super.setUp()
        viewModel = CompetencyViewModel()
        cancellables = []
        // Mock service loads data automatically in init
    }
    
    override func tearDown() {
        viewModel = nil
        cancellables.removeAll()
        super.tearDown()
    }
    
    // MARK: - Initialization Tests
    
    func testInitialState() {
        // Wait for initial load
        let expectation = XCTestExpectation(description: "Initial load")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 0.5)
        
        XCTAssertFalse(viewModel.competencies.isEmpty)
        XCTAssertFalse(viewModel.filteredCompetencies.isEmpty)
        XCTAssertEqual(viewModel.searchText, "")
        XCTAssertNil(viewModel.selectedCategory)
        XCTAssertFalse(viewModel.showInactiveCompetencies)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertFalse(viewModel.showingCreateSheet)
        XCTAssertFalse(viewModel.showingEditSheet)
        XCTAssertNil(viewModel.selectedCompetency)
        XCTAssertTrue(viewModel.myCompetencies.isEmpty)
        XCTAssertTrue(viewModel.requiredCompetencies.isEmpty)
    }
    
    // MARK: - Filtering Tests
    
    func testSearchFiltering() {
        // Given
        let expectation = XCTestExpectation(description: "Search filter")
        
        viewModel.$filteredCompetencies
            .dropFirst()
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        // When
        viewModel.searchText = "Swift"
        
        // Then
        wait(for: [expectation], timeout: 1)
        XCTAssertTrue(viewModel.filteredCompetencies.allSatisfy { competency in
            competency.name.localizedCaseInsensitiveContains("Swift") ||
            competency.description.localizedCaseInsensitiveContains("Swift")
        })
    }
    
    func testCategoryFiltering() {
        // Given
        let expectation = XCTestExpectation(description: "Category filter")
        
        viewModel.$filteredCompetencies
            .dropFirst()
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        // When
        viewModel.selectedCategory = .technical
        
        // Then
        wait(for: [expectation], timeout: 1)
        XCTAssertTrue(viewModel.filteredCompetencies.allSatisfy { $0.category == .technical })
    }
    
    func testInactiveCompetenciesFiltering() {
        // Given
        let expectation = XCTestExpectation(description: "Inactive filter")
        
        // Create inactive competency
        var inactiveCompetency = Competency(
            name: "Inactive Test",
            description: "Test inactive competency",
            category: .technical,
            color: .gray
        )
        inactiveCompetency.isActive = false
        CompetencyMockService.shared.createCompetency(inactiveCompetency)
        
        viewModel.$filteredCompetencies
            .dropFirst()
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        // When - show only active
        viewModel.showInactiveCompetencies = false
        
        // Then
        wait(for: [expectation], timeout: 1)
        XCTAssertTrue(viewModel.filteredCompetencies.allSatisfy { $0.isActive })
        
        // When - show all
        viewModel.showInactiveCompetencies = true
        wait(for: [expectation], timeout: 1)
        XCTAssertTrue(viewModel.filteredCompetencies.contains { !$0.isActive })
    }
    
    func testCombinedFiltering() {
        // Given
        viewModel.searchText = "ios"
        viewModel.selectedCategory = .technical
        viewModel.showInactiveCompetencies = false
        
        // Wait for debounce
        let expectation = XCTestExpectation(description: "Combined filter")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
        
        // Then
        XCTAssertTrue(viewModel.filteredCompetencies.allSatisfy { competency in
            (competency.name.localizedCaseInsensitiveContains("ios") ||
             competency.description.localizedCaseInsensitiveContains("ios")) &&
            competency.category == .technical &&
            competency.isActive
        })
    }
    
    // MARK: - CRUD Tests
    
    func testCreateCompetency() {
        // Given
        let newCompetency = Competency(
            name: "New Test Competency",
            description: "Test description",
            category: .technical,
            color: .blue
        )
        let initialCount = viewModel.competencies.count
        
        // When
        viewModel.createCompetency(newCompetency)
        
        // Then
        XCTAssertEqual(viewModel.competencies.count, initialCount + 1)
        XCTAssertTrue(viewModel.competencies.contains { $0.id == newCompetency.id })
        XCTAssertFalse(viewModel.showingCreateSheet)
    }
    
    func testUpdateCompetency() {
        // Given
        var competency = viewModel.competencies.first!
        competency.name = "Updated Name"
        viewModel.selectedCompetency = competency
        viewModel.showingEditSheet = true
        
        // When
        viewModel.updateCompetency(competency)
        
        // Then
        XCTAssertTrue(viewModel.competencies.contains { $0.name == "Updated Name" })
        XCTAssertFalse(viewModel.showingEditSheet)
        XCTAssertNil(viewModel.selectedCompetency)
    }
    
    func testDeleteCompetency() {
        // Given
        let competency = viewModel.competencies.first!
        let initialCount = viewModel.competencies.count
        
        // When
        viewModel.deleteCompetency(competency)
        
        // Then
        XCTAssertEqual(viewModel.competencies.count, initialCount - 1)
        XCTAssertFalse(viewModel.competencies.contains { $0.id == competency.id })
        XCTAssertNil(viewModel.errorMessage)
    }
    
    func testToggleCompetencyStatus() {
        // Given
        let competency = viewModel.competencies.first!
        let initialStatus = competency.isActive
        
        // When
        viewModel.toggleCompetencyStatus(competency)
        
        // Then
        let updatedCompetency = viewModel.competencies.first { $0.id == competency.id }
        XCTAssertNotNil(updatedCompetency)
        XCTAssertEqual(updatedCompetency?.isActive, !initialStatus)
    }
    
    // MARK: - UI Action Tests
    
    func testSelectCompetencyForEdit() {
        // Given
        let competency = viewModel.competencies.first!
        
        // When
        viewModel.selectCompetencyForEdit(competency)
        
        // Then
        XCTAssertEqual(viewModel.selectedCompetency?.id, competency.id)
        XCTAssertTrue(viewModel.showingEditSheet)
    }
    
    func testClearFilters() {
        // Given
        viewModel.searchText = "Test"
        viewModel.selectedCategory = .technical
        viewModel.showInactiveCompetencies = true
        
        // When
        viewModel.clearFilters()
        
        // Then
        XCTAssertEqual(viewModel.searchText, "")
        XCTAssertNil(viewModel.selectedCategory)
        XCTAssertFalse(viewModel.showInactiveCompetencies)
    }
    
    // MARK: - Statistics Tests
    
    func testStatistics() {
        // Given/When
        let stats = viewModel.statistics
        
        // Then
        XCTAssertEqual(stats.total, viewModel.competencies.count)
        XCTAssertEqual(stats.active, viewModel.competencies.filter { $0.isActive }.count)
        XCTAssertEqual(stats.inactive, stats.total - stats.active)
        XCTAssertFalse(stats.byCategory.isEmpty)
    }
    
    func testStatisticsCountForCategory() {
        // Given
        let stats = viewModel.statistics
        
        // When/Then
        for category in CompetencyCategory.allCases {
            let count = stats.count(for: category)
            let expectedCount = viewModel.competencies.filter { $0.category == category }.count
            XCTAssertEqual(count, expectedCount)
        }
    }
    
    // MARK: - Export Tests
    
    func testExportCompetencies() {
        // When
        let json = viewModel.exportCompetencies()
        
        // Then
        XCTAssertFalse(json.isEmpty)
        XCTAssertTrue(json.contains("name"))
        XCTAssertTrue(json.contains("category"))
        
        // Verify valid JSON
        if let data = json.data(using: .utf8),
           let decoded = try? JSONDecoder().decode([Competency].self, from: data) {
            XCTAssertEqual(decoded.count, viewModel.filteredCompetencies.count)
        } else {
            XCTFail("Export did not produce valid JSON")
        }
    }
    
    func testExportWithFilters() {
        // Given
        viewModel.selectedCategory = .technical
        
        // Wait for filter
        let expectation = XCTestExpectation(description: "Filter applied")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
        
        // When
        let json = viewModel.exportCompetencies()
        
        // Then
        if let data = json.data(using: .utf8),
           let decoded = try? JSONDecoder().decode([Competency].self, from: data) {
            XCTAssertTrue(decoded.allSatisfy { $0.category == .technical })
        }
    }
    
    // MARK: - Student Methods Tests
    
    func testGetCurrentLevel() {
        // Given
        let competency = viewModel.competencies.first!
        
        // When - competency not in myCompetencies
        let levelForUnknown = viewModel.getCurrentLevel(for: competency)
        
        // Then
        XCTAssertEqual(levelForUnknown, 0)
        
        // When - add to myCompetencies
        viewModel.myCompetencies.append(competency)
        let levelForKnown = viewModel.getCurrentLevel(for: competency)
        
        // Then
        XCTAssertEqual(levelForKnown, competency.currentLevel)
    }
    
    // MARK: - Loading State Tests
    
    func testLoadCompetencies() {
        // Given
        let expectation = XCTestExpectation(description: "Loading complete")
        
        viewModel.$isLoading
            .dropFirst()
            .sink { isLoading in
                if !isLoading {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        // When
        viewModel.loadCompetencies()
        
        // Then
        XCTAssertTrue(viewModel.isLoading)
        wait(for: [expectation], timeout: 1)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
    }
} 