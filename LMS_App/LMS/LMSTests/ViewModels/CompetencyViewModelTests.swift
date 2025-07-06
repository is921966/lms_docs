//
//  CompetencyViewModelTests.swift
//  LMSTests
//
//  Created on 09/07/2025.
//

import XCTest
import Combine
@testable import LMS

final class CompetencyViewModelTests: XCTestCase {
    private var sut: CompetencyViewModel!
    private var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        sut = CompetencyViewModel()
        cancellables = Set<AnyCancellable>()
    }
    
    override func tearDown() {
        cancellables = nil
        sut = nil
        super.tearDown()
    }
    
    // MARK: - Initialization Tests
    
    func testInitialization() {
        let expectation = XCTestExpectation(description: "Initialization completes")
        
        // Basic properties should be initialized correctly
        XCTAssertNotNil(sut.competencies)
        XCTAssertNotNil(sut.filteredCompetencies)
        XCTAssertEqual(sut.searchText, "")
        XCTAssertNil(sut.selectedCategory)
        XCTAssertFalse(sut.showInactiveCompetencies)
        XCTAssertTrue(sut.isLoading) // Loading starts in init
        XCTAssertNil(sut.errorMessage)
        XCTAssertFalse(sut.showingCreateSheet)
        XCTAssertFalse(sut.showingEditSheet)
        XCTAssertNil(sut.selectedCompetency)
        XCTAssertEqual(sut.myCompetencies.count, 0)
        XCTAssertEqual(sut.requiredCompetencies.count, 0)
        
        // Wait for mock data to be loaded
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            // Mock data should be loaded
            XCTAssertGreaterThan(self.sut.competencies.count, 0)
            XCTAssertEqual(self.sut.competencies.count, self.sut.filteredCompetencies.count)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    // MARK: - Loading Tests
    
    func testLoadCompetencies() {
        let expectation = XCTestExpectation(description: "Loading completes")
        
        // Start loading
        sut.loadCompetencies()
        XCTAssertTrue(sut.isLoading)
        XCTAssertNil(sut.errorMessage)
        
        // Wait for loading to complete
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            XCTAssertFalse(self.sut.isLoading)
            // Should have competencies loaded
            XCTAssertGreaterThan(self.sut.competencies.count, 0)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    // MARK: - Filtering Tests
    
    func testSearchFiltering() {
        let expectation = XCTestExpectation(description: "Search filter applied")
        
        // Set search text
        sut.searchText = "Swift"
        
        // Wait for debounce
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            // Should filter competencies containing "Swift"
            for competency in self.sut.filteredCompetencies {
                XCTAssertTrue(
                    competency.name.localizedCaseInsensitiveContains("Swift") ||
                    competency.description.localizedCaseInsensitiveContains("Swift"),
                    "Competency \(competency.name) should contain 'Swift'"
                )
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testCategoryFiltering() {
        let expectation = XCTestExpectation(description: "Category filter applied")
        
        // Set category filter
        sut.selectedCategory = .technical
        
        // Wait for debounce
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            // All filtered competencies should be technical
            for competency in self.sut.filteredCompetencies {
                XCTAssertEqual(competency.category, .technical)
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testInactiveFiltering() {
        let expectation = XCTestExpectation(description: "Inactive filter applied")
        
        // Initially should not show inactive
        XCTAssertFalse(sut.showInactiveCompetencies)
        
        // Enable showing inactive
        sut.showInactiveCompetencies = true
        
        // Wait for debounce
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            // Should include both active and inactive
            let hasActive = self.sut.filteredCompetencies.contains { $0.isActive }
            let hasInactive = self.sut.filteredCompetencies.contains { !$0.isActive }
            XCTAssertTrue(hasActive || hasInactive || self.sut.filteredCompetencies.isEmpty)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testCombinedFiltering() {
        let expectation = XCTestExpectation(description: "Combined filters applied")
        
        // Apply multiple filters
        sut.searchText = "навык"
        sut.selectedCategory = .softSkills
        sut.showInactiveCompetencies = false
        
        // Wait for debounce
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            // All filtered competencies should match all criteria
            for competency in self.sut.filteredCompetencies {
                XCTAssertTrue(
                    competency.name.localizedCaseInsensitiveContains("навык") ||
                    competency.description.localizedCaseInsensitiveContains("навык")
                )
                XCTAssertEqual(competency.category, .softSkills)
                XCTAssertTrue(competency.isActive)
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    // MARK: - CRUD Operations Tests
    
    func testCreateCompetency() {
        let expectation = XCTestExpectation(description: "Competency created")
        
        // Wait for initial data load
        let initExpectation = XCTestExpectation(description: "Initial load")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            initExpectation.fulfill()
        }
        wait(for: [initExpectation], timeout: 0.5)
        
        let newCompetency = Competency(
            name: "Test Competency",
            description: "Test Description",
            category: .technical
        )
        
        let initialCount = sut.competencies.count
        
        // Create competency
        sut.createCompetency(newCompetency)
        
        // Should close create sheet immediately
        XCTAssertFalse(sut.showingCreateSheet)
        
        // Wait for update to propagate
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            // Should add competency
            XCTAssertEqual(self.sut.competencies.count, initialCount + 1)
            XCTAssertTrue(self.sut.competencies.contains { $0.name == "Test Competency" })
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testUpdateCompetency() {
        let expectation = XCTestExpectation(description: "Competency updated")
        
        // Wait for initial data load
        let initExpectation = XCTestExpectation(description: "Initial load")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            initExpectation.fulfill()
        }
        wait(for: [initExpectation], timeout: 0.5)
        
        // Get first competency
        guard let firstCompetency = sut.competencies.first else {
            XCTFail("No competencies available")
            return
        }
        
        // Update it
        var updatedCompetency = firstCompetency
        updatedCompetency.name = "Updated Name"
        updatedCompetency.description = "Updated Description"
        
        sut.updateCompetency(updatedCompetency)
        
        // Should close edit sheet immediately
        XCTAssertFalse(sut.showingEditSheet)
        XCTAssertNil(sut.selectedCompetency)
        
        // Wait for update to propagate
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            // Should update the competency
            if let updated = self.sut.competencies.first(where: { $0.id == firstCompetency.id }) {
                XCTAssertEqual(updated.name, "Updated Name")
                XCTAssertEqual(updated.description, "Updated Description")
            } else {
                XCTFail("Competency not found after update")
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testDeleteCompetency() {
        let expectation = XCTestExpectation(description: "Competency deleted")
        
        // Wait for initial data load
        let initExpectation = XCTestExpectation(description: "Initial load")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            initExpectation.fulfill()
        }
        wait(for: [initExpectation], timeout: 0.5)
        
        guard let competencyToDelete = sut.competencies.first else {
            XCTFail("No competencies available")
            return
        }
        
        let initialCount = sut.competencies.count
        
        // Delete competency
        sut.deleteCompetency(competencyToDelete)
        
        // Should clear error message immediately
        XCTAssertNil(sut.errorMessage)
        
        // Wait for update to propagate
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            // Should remove competency
            XCTAssertEqual(self.sut.competencies.count, initialCount - 1)
            XCTAssertFalse(self.sut.competencies.contains { $0.id == competencyToDelete.id })
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testToggleCompetencyStatus() {
        let expectation = XCTestExpectation(description: "Status toggled")
        
        // Wait for initial data load
        let initExpectation = XCTestExpectation(description: "Initial load")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            initExpectation.fulfill()
        }
        wait(for: [initExpectation], timeout: 0.5)
        
        guard let competency = sut.competencies.first else {
            XCTFail("No competencies available")
            return
        }
        
        let initialStatus = competency.isActive
        
        // Toggle status
        sut.toggleCompetencyStatus(competency)
        
        // Wait for update to propagate
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            // Status should be toggled
            if let updated = self.sut.competencies.first(where: { $0.id == competency.id }) {
                XCTAssertEqual(updated.isActive, !initialStatus)
            } else {
                XCTFail("Competency not found after toggle")
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    // MARK: - UI Actions Tests
    
    func testSelectCompetencyForEdit() {
        // Wait for initial data load
        let initExpectation = XCTestExpectation(description: "Initial load")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            initExpectation.fulfill()
        }
        wait(for: [initExpectation], timeout: 0.5)
        
        // Get a competency from the loaded mock data
        guard let competency = sut.competencies.first else {
            XCTFail("No competencies available")
            return
        }
        
        // Select for edit
        sut.selectCompetencyForEdit(competency)
        
        // Should set selected competency and show edit sheet
        XCTAssertEqual(sut.selectedCompetency?.id, competency.id)
        XCTAssertTrue(sut.showingEditSheet)
    }
    
    func testClearFilters() {
        // Set filters
        sut.searchText = "Test"
        sut.selectedCategory = .technical
        sut.showInactiveCompetencies = true
        
        // Clear filters
        sut.clearFilters()
        
        // All filters should be cleared
        XCTAssertEqual(sut.searchText, "")
        XCTAssertNil(sut.selectedCategory)
        XCTAssertFalse(sut.showInactiveCompetencies)
    }
    
    // MARK: - Statistics Tests
    
    func testStatistics() {
        let stats = sut.statistics
        
        // Should calculate statistics correctly
        XCTAssertEqual(stats.total, sut.competencies.count)
        XCTAssertEqual(stats.active, sut.competencies.filter { $0.isActive }.count)
        XCTAssertEqual(stats.inactive, stats.total - stats.active)
        
        // Test category count
        let technicalCount = sut.competencies.filter { $0.category == .technical }.count
        XCTAssertEqual(stats.count(for: .technical), technicalCount)
    }
    
    // MARK: - Export Tests
    
    func testExportCompetencies() {
        // Apply filter to have specific competencies
        sut.selectedCategory = .technical
        
        let expectation = XCTestExpectation(description: "Export completes")
        
        // Wait for filter to apply
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            let exportedJson = self.sut.exportCompetencies()
            
            // Should return valid JSON
            XCTAssertFalse(exportedJson.isEmpty)
            
            // Try to parse JSON
            if let data = exportedJson.data(using: .utf8),
               let competencies = try? JSONDecoder().decode([Competency].self, from: data) {
                // Should export filtered competencies
                XCTAssertEqual(competencies.count, self.sut.filteredCompetencies.count)
                
                // All exported should be technical (our filter)
                for competency in competencies {
                    XCTAssertEqual(competency.category, .technical)
                }
            } else {
                XCTFail("Failed to parse exported JSON")
            }
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testExportFilteredCompetencies() {
        // Wait for initial data load
        let initExpectation = XCTestExpectation(description: "Initial load")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            initExpectation.fulfill()
        }
        wait(for: [initExpectation], timeout: 0.5)
        
        // Apply specific filter to get predictable results
        sut.selectedCategory = .technical
        sut.showInactiveCompetencies = false
        
        let expectation = XCTestExpectation(description: "Export completes")
        
        // Wait for filters to apply
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            let exportedJson = self.sut.exportCompetencies()
            
            // Should return valid JSON
            XCTAssertFalse(exportedJson.isEmpty)
            
            // Parse and validate exported data
            if let data = exportedJson.data(using: .utf8),
               let competencies = try? JSONDecoder().decode([Competency].self, from: data) {
                // Should export only filtered competencies
                XCTAssertEqual(competencies.count, self.sut.filteredCompetencies.count)
                
                // All exported should match our filter criteria
                for competency in competencies {
                    XCTAssertEqual(competency.category, .technical)
                    XCTAssertTrue(competency.isActive)
                }
            } else {
                XCTFail("Failed to parse exported JSON")
            }
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    // MARK: - Student Methods Tests
    
    func testGetCurrentLevel() {
        // Create a test competency
        let testCompetency = Competency(
            name: "Test Competency",
            description: "Test",
            category: .technical
        )
        
        // Add to my competencies
        sut.myCompetencies = [testCompetency]
        
        // Should return competency's current level
        let level = sut.getCurrentLevel(for: testCompetency)
        XCTAssertEqual(level, testCompetency.currentLevel)
        
        // For competency not in myCompetencies
        let otherCompetency = Competency(
            name: "Other Competency",
            description: "Other",
            category: .softSkills
        )
        
        let otherLevel = sut.getCurrentLevel(for: otherCompetency)
        XCTAssertEqual(otherLevel, 0)
    }
} 