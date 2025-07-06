//
//  PositionViewModelTests.swift
//  LMSTests
//
//  Created on 09/07/2025.
//

import XCTest
import Combine
@testable import LMS

final class PositionViewModelTests: XCTestCase {
    private var sut: PositionViewModel!
    private var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        sut = PositionViewModel()
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
        XCTAssertNotNil(sut.positions)
        XCTAssertNotNil(sut.filteredPositions)
        XCTAssertNotNil(sut.careerPaths)
        XCTAssertEqual(sut.searchText, "")
        XCTAssertNil(sut.selectedLevel)
        XCTAssertNil(sut.selectedDepartment)
        XCTAssertFalse(sut.showInactivePositions)
        XCTAssertTrue(sut.isLoading) // Loading starts in init
        XCTAssertNil(sut.errorMessage)
        XCTAssertFalse(sut.showingCreateSheet)
        XCTAssertFalse(sut.showingEditSheet)
        XCTAssertNil(sut.selectedPosition)
        XCTAssertFalse(sut.showingCareerPaths)
        
        // Wait for mock data to be loaded
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            // Mock data should be loaded
            XCTAssertGreaterThan(self.sut.positions.count, 0)
            XCTAssertEqual(self.sut.positions.count, self.sut.filteredPositions.count)
            XCTAssertGreaterThan(self.sut.careerPaths.count, 0)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    // MARK: - Loading Tests
    
    func testLoadData() {
        let expectation = XCTestExpectation(description: "Data loads")
        
        // Initial loading state
        XCTAssertTrue(sut.isLoading)
        XCTAssertNil(sut.errorMessage)
        
        // Wait for loading to complete
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            // Loading should be complete
            XCTAssertFalse(self.sut.isLoading)
            XCTAssertNil(self.sut.errorMessage)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    // MARK: - Filtering Tests
    
    func testSearchFiltering() {
        let expectation = XCTestExpectation(description: "Search filter applies")
        
        // Wait for initial data load
        waitForInitialLoad()
        
        let initialCount = sut.filteredPositions.count
        
        // Apply search filter
        sut.searchText = "developer"
        
        // Wait for debounce and filter to apply
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            // Should filter positions
            XCTAssertLessThan(self.sut.filteredPositions.count, initialCount)
            XCTAssertTrue(self.sut.filteredPositions.allSatisfy { position in
                position.name.localizedCaseInsensitiveContains("developer") ||
                position.description.localizedCaseInsensitiveContains("developer") ||
                position.department.localizedCaseInsensitiveContains("developer")
            })
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testLevelFiltering() {
        let expectation = XCTestExpectation(description: "Level filter applies")
        
        // Wait for initial data load
        waitForInitialLoad()
        
        // Apply level filter
        sut.selectedLevel = .middle
        
        // Wait for debounce and filter to apply
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            // All filtered positions should be middle level
            XCTAssertTrue(self.sut.filteredPositions.allSatisfy { $0.level == .middle })
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testDepartmentFiltering() {
        let expectation = XCTestExpectation(description: "Department filter applies")
        
        // Wait for initial data load
        waitForInitialLoad()
        
        // Get first department from statistics
        guard let firstDepartment = sut.statistics.departments.first else {
            XCTFail("No departments available")
            return
        }
        
        // Apply department filter
        sut.selectedDepartment = firstDepartment
        
        // Wait for debounce and filter to apply
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            // All filtered positions should be from selected department
            XCTAssertTrue(self.sut.filteredPositions.allSatisfy { $0.department == firstDepartment })
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testInactiveFiltering() {
        let expectation = XCTestExpectation(description: "Inactive filter applies")
        
        // Wait for initial data load
        waitForInitialLoad()
        
        // By default, should show only active positions
        XCTAssertTrue(sut.filteredPositions.allSatisfy { $0.isActive })
        
        // Show inactive positions
        sut.showInactivePositions = true
        
        // Wait for debounce and filter to apply
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            // Should now include inactive positions if any exist
            if self.sut.positions.contains(where: { !$0.isActive }) {
                XCTAssertTrue(self.sut.filteredPositions.contains { !$0.isActive })
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testCombinedFiltering() {
        let expectation = XCTestExpectation(description: "Combined filters apply")
        
        // Wait for initial data load
        waitForInitialLoad()
        
        // Apply multiple filters
        sut.selectedLevel = .senior
        sut.selectedDepartment = "Engineering"
        sut.showInactivePositions = false
        
        // Wait for debounce and filter to apply
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            // All filtered positions should match all criteria
            XCTAssertTrue(self.sut.filteredPositions.allSatisfy { position in
                position.level == .senior &&
                position.department == "Engineering" &&
                position.isActive
            })
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testSortingByLevel() {
        let expectation = XCTestExpectation(description: "Positions sorted by level")
        
        // Wait for initial data load
        waitForInitialLoad()
        
        // Apply a filter that returns multiple positions
        sut.showInactivePositions = true
        
        // Wait for filter to apply
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            // Check if positions are sorted by level
            for i in 0..<(self.sut.filteredPositions.count - 1) {
                let current = self.sut.filteredPositions[i]
                let next = self.sut.filteredPositions[i + 1]
                XCTAssertLessThanOrEqual(current.level.sortOrder, next.level.sortOrder)
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    // MARK: - CRUD Operations Tests
    
    func testCreatePosition() {
        let expectation = XCTestExpectation(description: "Position created")
        
        // Wait for initial data load
        waitForInitialLoad()
        
        let newPosition = Position(
            name: "Test Position",
            description: "Test Description",
            department: "Test Department",
            level: .middle,
            competencyRequirements: []
        )
        
        let initialCount = sut.positions.count
        
        // Create position
        sut.createPosition(newPosition)
        
        // Should close create sheet immediately
        XCTAssertFalse(sut.showingCreateSheet)
        
        // Wait for update to propagate
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            // Should add position
            XCTAssertEqual(self.sut.positions.count, initialCount + 1)
            XCTAssertTrue(self.sut.positions.contains { $0.name == "Test Position" })
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testUpdatePosition() {
        let expectation = XCTestExpectation(description: "Position updated")
        
        // Wait for initial data load
        waitForInitialLoad()
        
        // Get first position
        guard let firstPosition = sut.positions.first else {
            XCTFail("No positions available")
            return
        }
        
        // Update it
        var updatedPosition = firstPosition
        updatedPosition.name = "Updated Name"
        updatedPosition.description = "Updated Description"
        
        sut.updatePosition(updatedPosition)
        
        // Should close edit sheet immediately
        XCTAssertFalse(sut.showingEditSheet)
        XCTAssertNil(sut.selectedPosition)
        
        // Wait for update to propagate
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            // Should update the position
            if let updated = self.sut.positions.first(where: { $0.id == firstPosition.id }) {
                XCTAssertEqual(updated.name, "Updated Name")
                XCTAssertEqual(updated.description, "Updated Description")
            } else {
                XCTFail("Position not found after update")
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testDeletePosition() {
        let expectation = XCTestExpectation(description: "Position deleted")
        
        // Wait for initial data load
        waitForInitialLoad()
        
        guard let positionToDelete = sut.positions.first else {
            XCTFail("No positions available")
            return
        }
        
        let initialCount = sut.positions.count
        
        // Delete position
        sut.deletePosition(positionToDelete)
        
        // Wait for update to propagate
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            // Should remove position
            XCTAssertEqual(self.sut.positions.count, initialCount - 1)
            XCTAssertFalse(self.sut.positions.contains { $0.id == positionToDelete.id })
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testTogglePositionStatus() {
        let expectation = XCTestExpectation(description: "Status toggled")
        
        // Wait for initial data load
        waitForInitialLoad()
        
        guard let position = sut.positions.first else {
            XCTFail("No positions available")
            return
        }
        
        let initialStatus = position.isActive
        
        // Toggle status
        sut.togglePositionStatus(position)
        
        // Wait for update to propagate
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            // Status should be toggled
            if let updated = self.sut.positions.first(where: { $0.id == position.id }) {
                XCTAssertEqual(updated.isActive, !initialStatus)
            } else {
                XCTFail("Position not found after toggle")
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    // MARK: - Career Path Tests
    
    func testGetCareerPaths() {
        // Wait for initial data load
        waitForInitialLoad()
        
        guard let position = sut.positions.first else {
            XCTFail("No positions available")
            return
        }
        
        let paths = sut.getCareerPaths(for: position)
        
        // Should return career paths for the position
        XCTAssertNotNil(paths)
        // Career paths should originate from this position
        for path in paths {
            XCTAssertEqual(path.fromPositionId, position.id)
        }
    }
    
    func testGetIncomingCareerPaths() {
        // Wait for initial data load
        waitForInitialLoad()
        
        guard let position = sut.positions.first else {
            XCTFail("No positions available")
            return
        }
        
        let incomingPaths = sut.getIncomingCareerPaths(for: position)
        
        // Should return incoming career paths for the position
        XCTAssertNotNil(incomingPaths)
        // Incoming paths should lead to this position
        for path in incomingPaths {
            XCTAssertEqual(path.toPositionId, position.id)
        }
    }
    
    func testCreateCareerPath() {
        let expectation = XCTestExpectation(description: "Career path created")
        
        // Wait for initial data load
        waitForInitialLoad()
        
        guard let fromPosition = sut.positions.first,
              let toPosition = sut.positions.last,
              fromPosition.id != toPosition.id else {
            XCTFail("Need at least two positions")
            return
        }
        
        let newPath = CareerPath(
            fromPositionId: fromPosition.id,
            toPositionId: toPosition.id,
            fromPositionName: fromPosition.name,
            toPositionName: toPosition.name,
            estimatedDuration: .year1,
            description: "Test career path"
        )
        
        let initialCount = sut.careerPaths.count
        
        // Create career path
        sut.createCareerPath(newPath)
        
        // Wait for update to propagate
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            // Should add career path
            XCTAssertEqual(self.sut.careerPaths.count, initialCount + 1)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    // MARK: - UI Actions Tests
    
    func testSelectPositionForEdit() {
        // Wait for initial data load
        waitForInitialLoad()
        
        guard let position = sut.positions.first else {
            XCTFail("No positions available")
            return
        }
        
        // Select for edit
        sut.selectPositionForEdit(position)
        
        // Should set selected position and show edit sheet
        XCTAssertEqual(sut.selectedPosition?.id, position.id)
        XCTAssertTrue(sut.showingEditSheet)
    }
    
    func testSelectPositionForCareerPaths() {
        // Wait for initial data load
        waitForInitialLoad()
        
        guard let position = sut.positions.first else {
            XCTFail("No positions available")
            return
        }
        
        // Select for career paths
        sut.selectPositionForCareerPaths(position)
        
        // Should set selected position and show career paths
        XCTAssertEqual(sut.selectedPosition?.id, position.id)
        XCTAssertTrue(sut.showingCareerPaths)
    }
    
    func testClearFilters() {
        // Set some filters
        sut.searchText = "test"
        sut.selectedLevel = .senior
        sut.selectedDepartment = "Engineering"
        sut.showInactivePositions = true
        
        // Clear filters
        sut.clearFilters()
        
        // All filters should be reset
        XCTAssertEqual(sut.searchText, "")
        XCTAssertNil(sut.selectedLevel)
        XCTAssertNil(sut.selectedDepartment)
        XCTAssertFalse(sut.showInactivePositions)
    }
    
    // MARK: - Statistics Tests
    
    func testStatistics() {
        // Wait for initial data load
        waitForInitialLoad()
        
        let stats = sut.statistics
        
        // Should return valid statistics
        XCTAssertEqual(stats.total, sut.positions.count)
        XCTAssertEqual(stats.active, sut.positions.filter { $0.isActive }.count)
        XCTAssertEqual(stats.inactive, stats.total - stats.active)
        XCTAssertGreaterThan(stats.totalEmployees, 0)
        XCTAssertFalse(stats.byLevel.isEmpty)
        XCTAssertFalse(stats.departments.isEmpty)
        
        // Test count for level
        if let firstLevel = stats.byLevel.keys.first {
            let count = stats.count(for: firstLevel)
            XCTAssertEqual(count, stats.byLevel[firstLevel])
        }
    }
    
    // MARK: - Competency Matrix Tests
    
    func testGetCompetencyMatrix() {
        // Wait for initial data load
        waitForInitialLoad()
        
        // Find a position with competency requirements
        guard let position = sut.positions.first(where: { !$0.competencyRequirements.isEmpty }) else {
            XCTSkip("No positions with competency requirements available")
            return
        }
        
        let matrix = sut.getCompetencyMatrix(for: position)
        
        // Should return valid matrix
        XCTAssertEqual(matrix.position.id, position.id)
        XCTAssertEqual(matrix.requirements.count, position.competencyRequirements.count)
        
        // Requirements should be sorted (critical first, then by level)
        for i in 0..<(matrix.requirements.count - 1) {
            let current = matrix.requirements[i]
            let next = matrix.requirements[i + 1]
            
            if current.isCritical != next.isCritical {
                XCTAssertTrue(current.isCritical)
            } else if current.isCritical == next.isCritical {
                XCTAssertGreaterThanOrEqual(current.requiredLevel, next.requiredLevel)
            }
        }
        
        // Test critical and optional requirements
        let criticalCount = position.competencyRequirements.filter { $0.isCritical }.count
        let optionalCount = position.competencyRequirements.filter { !$0.isCritical }.count
        
        XCTAssertEqual(matrix.criticalRequirements.count, criticalCount)
        XCTAssertEqual(matrix.optionalRequirements.count, optionalCount)
        
        // Test average level calculation
        if !matrix.requirements.isEmpty {
            let expectedAverage = Double(matrix.requirements.reduce(0) { $0 + $1.requiredLevel }) / Double(matrix.requirements.count)
            XCTAssertEqual(matrix.averageRequiredLevel, expectedAverage, accuracy: 0.01)
        }
    }
    
    func testCompetencyMatrixEmptyRequirements() {
        // Create position without requirements
        let position = Position(
            name: "Test",
            description: "Test",
            department: "Test",
            level: .junior,
            competencyRequirements: []
        )
        
        let matrix = sut.getCompetencyMatrix(for: position)
        
        // Should handle empty requirements gracefully
        XCTAssertTrue(matrix.requirements.isEmpty)
        XCTAssertTrue(matrix.criticalRequirements.isEmpty)
        XCTAssertTrue(matrix.optionalRequirements.isEmpty)
        XCTAssertEqual(matrix.averageRequiredLevel, 0.0)
    }
    
    // MARK: - Helper Methods
    
    private func waitForInitialLoad() {
        let expectation = XCTestExpectation(description: "Initial load")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 0.5)
    }
} 