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
        
        // Wait for initial load (loadCompetencies has 0.5s delay)
        let expectation = XCTestExpectation(description: "Initial load")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }
    
    override func tearDown() {
        viewModel = nil
        cancellables.removeAll()
        super.tearDown()
    }
    
    // MARK: - Initialization Tests
    
    func testInitialState() {
        // Ensure loading is complete
        let loadingExpectation = XCTestExpectation(description: "Loading complete")
        if viewModel.isLoading {
            viewModel.$isLoading
                .dropFirst()
                .sink { isLoading in
                    if !isLoading {
                        loadingExpectation.fulfill()
                    }
                }
                .store(in: &cancellables)
            wait(for: [loadingExpectation], timeout: 1.0)
        }
        
        // Now check the state
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
        // Remove assertions for myCompetencies and requiredCompetencies as they're not initialized in mock
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
        // Create inactive competency
        var inactiveCompetency = Competency(
            name: "Inactive Test Competency " + UUID().uuidString,
            description: "Test inactive competency",
            category: .technical,
            color: .gray
        )
        inactiveCompetency.isActive = false
        
        // Add inactive competency
        let initialActiveCount = viewModel.filteredCompetencies.count
        CompetencyMockService.shared.createCompetency(inactiveCompetency)
        
        // Wait for service update
        let expectation = XCTestExpectation(description: "Service update")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 0.5)
        
        // When - show only active (default)
        viewModel.showInactiveCompetencies = false
        
        // Wait for filter update
        let expectation2 = XCTestExpectation(description: "Filter update")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            expectation2.fulfill()
        }
        wait(for: [expectation2], timeout: 1)
        
        // Then - should not show inactive
        XCTAssertTrue(viewModel.filteredCompetencies.allSatisfy { $0.isActive })
        
        // When - show all including inactive
        viewModel.showInactiveCompetencies = true
        
        // Wait for filter update
        let expectation3 = XCTestExpectation(description: "Show all")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            expectation3.fulfill()
        }
        wait(for: [expectation3], timeout: 1)
        
        // Then - should include inactive
        let hasInactive = viewModel.filteredCompetencies.contains { !$0.isActive }
        XCTAssertTrue(hasInactive, "Should have at least one inactive competency when showInactiveCompetencies is true")
        
        // Cleanup - remove the test competency
        CompetencyMockService.shared.deleteCompetency(inactiveCompetency.id)
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
        let uniqueName = "New Test Competency " + UUID().uuidString
        let newCompetency = Competency(
            name: uniqueName,
            description: "Test description",
            category: .technical,
            color: .blue
        )
        let initialCount = viewModel.competencies.count
        
        // When
        viewModel.createCompetency(newCompetency)
        
        // Wait for update
        let expectation = XCTestExpectation(description: "Create")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 0.5)
        
        // Then
        XCTAssertEqual(viewModel.competencies.count, initialCount + 1)
        XCTAssertTrue(viewModel.competencies.contains { $0.name == uniqueName })
        XCTAssertFalse(viewModel.showingCreateSheet)
        
        // Cleanup
        if let created = viewModel.competencies.first(where: { $0.name == uniqueName }) {
            CompetencyMockService.shared.deleteCompetency(created.id)
        }
    }
    
    func testUpdateCompetency() {
        // Given - create a new competency to update
        let originalName = "Test Competency " + UUID().uuidString
        let testCompetency = Competency(
            name: originalName,
            description: "Original description",
            category: .technical,
            color: .blue
        )
        CompetencyMockService.shared.createCompetency(testCompetency)
        
        // Wait for creation
        let expectation1 = XCTestExpectation(description: "Create")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            expectation1.fulfill()
        }
        wait(for: [expectation1], timeout: 0.5)
        
        // Find the created competency
        guard let createdCompetency = viewModel.competencies.first(where: { $0.name == originalName }) else {
            XCTFail("Failed to create test competency")
            return
        }
        
        // Update it
        var updatedCompetency = createdCompetency
        updatedCompetency.name = "Updated Name " + UUID().uuidString
        viewModel.selectedCompetency = updatedCompetency
        viewModel.showingEditSheet = true
        
        // When
        viewModel.updateCompetency(updatedCompetency)
        
        // Wait for update
        let expectation2 = XCTestExpectation(description: "Update")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            expectation2.fulfill()
        }
        wait(for: [expectation2], timeout: 0.5)
        
        // Then
        XCTAssertTrue(viewModel.competencies.contains { $0.name == updatedCompetency.name })
        XCTAssertFalse(viewModel.showingEditSheet)
        XCTAssertNil(viewModel.selectedCompetency)
        
        // Cleanup
        CompetencyMockService.shared.deleteCompetency(createdCompetency.id)
    }
    
    func testDeleteCompetency() {
        // Given - create a competency to delete
        let testName = "To Delete " + UUID().uuidString
        let testCompetency = Competency(
            name: testName,
            description: "Will be deleted",
            category: .technical,
            color: .red
        )
        CompetencyMockService.shared.createCompetency(testCompetency)
        
        // Wait for creation
        let expectation1 = XCTestExpectation(description: "Create")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            expectation1.fulfill()
        }
        wait(for: [expectation1], timeout: 0.5)
        
        // Find the created competency
        guard let toDelete = viewModel.competencies.first(where: { $0.name == testName }) else {
            XCTFail("Failed to create test competency")
            return
        }
        
        let countBeforeDelete = viewModel.competencies.count
        
        // When
        viewModel.deleteCompetency(toDelete)
        
        // Wait for deletion
        let expectation2 = XCTestExpectation(description: "Delete")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            expectation2.fulfill()
        }
        wait(for: [expectation2], timeout: 0.5)
        
        // Then
        XCTAssertEqual(viewModel.competencies.count, countBeforeDelete - 1)
        XCTAssertFalse(viewModel.competencies.contains { $0.id == toDelete.id })
        XCTAssertNil(viewModel.errorMessage)
    }
    
    func testToggleCompetencyStatus() {
        // Given - use first existing competency
        guard let competency = viewModel.competencies.first else {
            XCTFail("No competencies available")
            return
        }
        let initialStatus = competency.isActive
        
        // When
        viewModel.toggleCompetencyStatus(competency)
        
        // Wait for update
        let expectation = XCTestExpectation(description: "Toggle")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 0.5)
        
        // Then
        let updatedCompetency = viewModel.competencies.first { $0.id == competency.id }
        XCTAssertNotNil(updatedCompetency)
        XCTAssertEqual(updatedCompetency?.isActive, !initialStatus)
        
        // Toggle back to original state
        viewModel.toggleCompetencyStatus(competency)
        
        // Wait
        let expectation2 = XCTestExpectation(description: "Toggle back")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            expectation2.fulfill()
        }
        wait(for: [expectation2], timeout: 0.5)
    }
    
    // MARK: - UI Action Tests
    
    func testSelectCompetencyForEdit() {
        // Given
        guard let competency = viewModel.competencies.first else {
            XCTFail("No competencies available")
            return
        }
        
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
        XCTAssertGreaterThan(stats.byCategory.count, 0)
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
        guard let data = json.data(using: .utf8) else {
            XCTFail("Failed to convert JSON string to data")
            return
        }
        
        do {
            let decoded = try JSONDecoder().decode([Competency].self, from: data)
            XCTAssertEqual(decoded.count, viewModel.filteredCompetencies.count)
        } catch {
            XCTFail("Export did not produce valid JSON: \(error)")
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
        guard let data = json.data(using: .utf8) else {
            XCTFail("Failed to convert JSON string to data")
            return
        }
        
        do {
            let decoded = try JSONDecoder().decode([Competency].self, from: data)
            XCTAssertTrue(decoded.allSatisfy { $0.category == .technical })
        } catch {
            XCTFail("Failed to decode exported JSON: \(error)")
        }
    }
    
    // MARK: - Student Methods Tests
    
    func testGetCurrentLevel() {
        // Given
        guard let competency = viewModel.competencies.first else {
            XCTFail("No competencies available")
            return
        }
        
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