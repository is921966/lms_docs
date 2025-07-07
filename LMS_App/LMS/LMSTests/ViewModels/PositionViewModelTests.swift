//
//  PositionViewModelTests.swift
//  LMSTests
//
//  Created on 06/07/2025.
//

import XCTest
import Combine
@testable import LMS

@MainActor
final class PositionViewModelTests: XCTestCase {
    
    var viewModel: PositionViewModel!
    var cancellables: Set<AnyCancellable> = []
    
    override func setUp() {
        super.setUp()
        viewModel = PositionViewModel()
        cancellables = []
        
        // Wait for initial load (loadData has 0.5s delay)
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
        XCTAssertFalse(viewModel.positions.isEmpty)
        XCTAssertFalse(viewModel.filteredPositions.isEmpty)
        XCTAssertFalse(viewModel.careerPaths.isEmpty)
        XCTAssertEqual(viewModel.searchText, "")
        XCTAssertNil(viewModel.selectedLevel)
        XCTAssertNil(viewModel.selectedDepartment)
        XCTAssertFalse(viewModel.showInactivePositions)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertFalse(viewModel.showingCreateSheet)
        XCTAssertFalse(viewModel.showingEditSheet)
        XCTAssertNil(viewModel.selectedPosition)
        XCTAssertFalse(viewModel.showingCareerPaths)
    }
    
    // MARK: - Filtering Tests
    
    func testSearchFiltering() {
        // Given
        let expectation = XCTestExpectation(description: "Search filter")
        
        viewModel.$filteredPositions
            .dropFirst()
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        // When
        viewModel.searchText = "Developer"
        
        // Then
        wait(for: [expectation], timeout: 1)
        XCTAssertTrue(viewModel.filteredPositions.allSatisfy { position in
            position.name.localizedCaseInsensitiveContains("Developer")
        })
    }
    
    func testLevelFiltering() {
        // Given
        let expectation = XCTestExpectation(description: "Level filter")
        
        viewModel.$filteredPositions
            .dropFirst()
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        // When
        viewModel.selectedLevel = .senior
        
        // Then
        wait(for: [expectation], timeout: 1)
        XCTAssertTrue(viewModel.filteredPositions.allSatisfy { $0.level == .senior })
    }
    
    func testDepartmentFiltering() {
        // Given
        let expectation = XCTestExpectation(description: "Department filter")
        let department = "Engineering"
        
        viewModel.$filteredPositions
            .dropFirst()
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        // When
        viewModel.selectedDepartment = department
        
        // Then
        wait(for: [expectation], timeout: 1)
        XCTAssertTrue(viewModel.filteredPositions.allSatisfy { $0.department == department })
    }
    
    func testInactivePositionsFiltering() {
        // Create inactive position
        var inactivePosition = Position(
            name: "Inactive Test Position " + UUID().uuidString,
            description: "Test inactive position",
            department: "Test",
            level: .junior,
            competencyRequirements: [],
            employeeCount: 0
        )
        inactivePosition.isActive = false
        
        // Add inactive position
        PositionMockService.shared.createPosition(inactivePosition)
        
        // Wait for service update
        let expectation = XCTestExpectation(description: "Service update")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 0.5)
        
        // When - show only active (default)
        viewModel.showInactivePositions = false
        
        // Wait for filter update
        let expectation2 = XCTestExpectation(description: "Filter update")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            expectation2.fulfill()
        }
        wait(for: [expectation2], timeout: 1)
        
        // Then - should not show inactive
        XCTAssertTrue(viewModel.filteredPositions.allSatisfy { $0.isActive })
        
        // When - show all including inactive
        viewModel.showInactivePositions = true
        
        // Wait for filter update
        let expectation3 = XCTestExpectation(description: "Show all")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            expectation3.fulfill()
        }
        wait(for: [expectation3], timeout: 1)
        
        // Then - should include inactive
        let hasInactive = viewModel.filteredPositions.contains { !$0.isActive }
        XCTAssertTrue(hasInactive, "Should have at least one inactive position when showInactivePositions is true")
        
        // Cleanup
        PositionMockService.shared.deletePosition(inactivePosition.id)
    }
    
    func testCombinedFiltering() {
        // Given
        viewModel.searchText = "Senior"
        viewModel.selectedLevel = .senior
        viewModel.selectedDepartment = "Engineering"
        viewModel.showInactivePositions = false
        
        // Wait for debounce
        let expectation = XCTestExpectation(description: "Combined filter")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
        
        // Then
        XCTAssertTrue(viewModel.filteredPositions.allSatisfy { position in
            position.name.localizedCaseInsensitiveContains("Senior") &&
            position.level == .senior &&
            position.department == "Engineering" &&
            position.isActive
        })
    }
    
    // MARK: - CRUD Tests
    
    func testCreatePosition() {
        // Given
        let uniqueName = "New Test Position " + UUID().uuidString
        let newPosition = Position(
            name: uniqueName,
            description: "Test description",
            department: "Test",
            level: .middle,
            competencyRequirements: [],
            employeeCount: 1
        )
        let initialCount = viewModel.positions.count
        
        // When
        viewModel.createPosition(newPosition)
        
        // Wait for update
        let expectation = XCTestExpectation(description: "Create")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 0.5)
        
        // Then
        XCTAssertEqual(viewModel.positions.count, initialCount + 1)
        XCTAssertTrue(viewModel.positions.contains { $0.name == uniqueName })
        XCTAssertFalse(viewModel.showingCreateSheet)
        
        // Cleanup
        if let created = viewModel.positions.first(where: { $0.name == uniqueName }) {
            PositionMockService.shared.deletePosition(created.id)
        }
    }
    
    func testUpdatePosition() {
        // Given - create a new position to update
        let originalName = "Test Position " + UUID().uuidString
        let testPosition = Position(
            name: originalName,
            description: "Original description",
            department: "Test",
            level: .junior,
            competencyRequirements: [],
            employeeCount: 1
        )
        PositionMockService.shared.createPosition(testPosition)
        
        // Wait for creation
        let expectation1 = XCTestExpectation(description: "Create")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            expectation1.fulfill()
        }
        wait(for: [expectation1], timeout: 0.5)
        
        // Find the created position
        guard let createdPosition = viewModel.positions.first(where: { $0.name == originalName }) else {
            XCTFail("Failed to create test position")
            return
        }
        
        // Update it
        var updatedPosition = createdPosition
        updatedPosition.name = "Updated Title " + UUID().uuidString
        viewModel.selectedPosition = updatedPosition
        viewModel.showingEditSheet = true
        
        // When
        viewModel.updatePosition(updatedPosition)
        
        // Wait for update
        let expectation2 = XCTestExpectation(description: "Update")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            expectation2.fulfill()
        }
        wait(for: [expectation2], timeout: 0.5)
        
        // Then
        XCTAssertTrue(viewModel.positions.contains { $0.name == updatedPosition.name })
        XCTAssertFalse(viewModel.showingEditSheet)
        XCTAssertNil(viewModel.selectedPosition)
        
        // Cleanup
        PositionMockService.shared.deletePosition(createdPosition.id)
    }
    
    func testDeletePosition() {
        // Given - create a position to delete
        let testName = "To Delete " + UUID().uuidString
        let testPosition = Position(
            name: testName,
            description: "Will be deleted",
            department: "Test",
            level: .junior,
            competencyRequirements: [],
            employeeCount: 0
        )
        PositionMockService.shared.createPosition(testPosition)
        
        // Wait for creation
        let expectation1 = XCTestExpectation(description: "Create")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            expectation1.fulfill()
        }
        wait(for: [expectation1], timeout: 0.5)
        
        // Find the created position
        guard let toDelete = viewModel.positions.first(where: { $0.name == testName }) else {
            XCTFail("Failed to create test position")
            return
        }
        
        let countBeforeDelete = viewModel.positions.count
        
        // When
        viewModel.deletePosition(toDelete)
        
        // Wait for deletion
        let expectation2 = XCTestExpectation(description: "Delete")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            expectation2.fulfill()
        }
        wait(for: [expectation2], timeout: 0.5)
        
        // Then
        XCTAssertEqual(viewModel.positions.count, countBeforeDelete - 1)
        XCTAssertFalse(viewModel.positions.contains { $0.id == toDelete.id })
    }
    
    func testTogglePositionStatus() {
        // Given - use first existing position
        guard let position = viewModel.positions.first else {
            XCTFail("No positions available")
            return
        }
        let initialStatus = position.isActive
        
        // When
        viewModel.togglePositionStatus(position)
        
        // Wait for update
        let expectation = XCTestExpectation(description: "Toggle")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 0.5)
        
        // Then
        let updatedPosition = viewModel.positions.first { $0.id == position.id }
        XCTAssertNotNil(updatedPosition)
        XCTAssertEqual(updatedPosition?.isActive, !initialStatus)
        
        // Toggle back to original state
        viewModel.togglePositionStatus(position)
        
        // Wait
        let expectation2 = XCTestExpectation(description: "Toggle back")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            expectation2.fulfill()
        }
        wait(for: [expectation2], timeout: 0.5)
    }
    
    // MARK: - Career Path Tests
    
    func testGetCareerPaths() {
        // Given
        guard let position = viewModel.positions.first else {
            XCTFail("No positions available")
            return
        }
        
        // When
        let paths = viewModel.getCareerPaths(for: position)
        
        // Then
        // Check that if there are paths, they all have correct fromPositionId
        if !paths.isEmpty {
            XCTAssertTrue(paths.allSatisfy { $0.fromPositionId == position.id })
        }
    }
    
    func testGetIncomingCareerPaths() {
        // Given
        guard let position = viewModel.positions.first(where: { $0.level == .senior }) else {
            XCTFail("No senior positions available")
            return
        }
        
        // When
        let incomingPaths = viewModel.getIncomingCareerPaths(for: position)
        
        // Then
        // Check that if there are incoming paths, they all have correct toPositionId
        if !incomingPaths.isEmpty {
            XCTAssertTrue(incomingPaths.allSatisfy { $0.toPositionId == position.id })
        }
    }
    
    func testCreateCareerPath() {
        // Given
        guard let fromPosition = viewModel.positions.first,
              let toPosition = viewModel.positions.last,
              fromPosition.id != toPosition.id else {
            XCTFail("Need at least two different positions")
            return
        }
        
        let uniqueDescription = "Test career path " + UUID().uuidString
        let newPath = CareerPath(
            fromPositionId: fromPosition.id,
            toPositionId: toPosition.id,
            fromPositionName: fromPosition.name,
            toPositionName: toPosition.name,
            estimatedDuration: .years2,
            description: uniqueDescription
        )
        let initialCount = viewModel.careerPaths.count
        
        // When
        viewModel.createCareerPath(newPath)
        
        // Wait for update
        let expectation = XCTestExpectation(description: "Create path")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 0.5)
        
        // Then
        XCTAssertEqual(viewModel.careerPaths.count, initialCount + 1)
        XCTAssertTrue(viewModel.careerPaths.contains { $0.description == uniqueDescription })
    }
    
    // MARK: - UI Action Tests
    
    func testSelectPositionForEdit() {
        // Given
        guard let position = viewModel.positions.first else {
            XCTFail("No positions available")
            return
        }
        
        // When
        viewModel.selectPositionForEdit(position)
        
        // Then
        XCTAssertEqual(viewModel.selectedPosition?.id, position.id)
        XCTAssertTrue(viewModel.showingEditSheet)
    }
    
    func testSelectPositionForCareerPaths() {
        // Given
        guard let position = viewModel.positions.first else {
            XCTFail("No positions available")
            return
        }
        
        // When
        viewModel.selectPositionForCareerPaths(position)
        
        // Then
        XCTAssertEqual(viewModel.selectedPosition?.id, position.id)
        XCTAssertTrue(viewModel.showingCareerPaths)
    }
    
    func testClearFilters() {
        // Given
        viewModel.searchText = "Test"
        viewModel.selectedLevel = .senior
        viewModel.selectedDepartment = "Engineering"
        viewModel.showInactivePositions = true
        
        // When
        viewModel.clearFilters()
        
        // Then
        XCTAssertEqual(viewModel.searchText, "")
        XCTAssertNil(viewModel.selectedLevel)
        XCTAssertNil(viewModel.selectedDepartment)
        XCTAssertFalse(viewModel.showInactivePositions)
    }
    
    // MARK: - Statistics Tests
    
    func testStatistics() {
        // Given/When
        let stats = viewModel.statistics
        
        // Then
        XCTAssertEqual(stats.total, viewModel.positions.count)
        XCTAssertEqual(stats.active, viewModel.positions.filter { $0.isActive }.count)
        XCTAssertEqual(stats.inactive, stats.total - stats.active)
        XCTAssertGreaterThanOrEqual(stats.totalEmployees, 0)
        XCTAssertFalse(stats.departments.isEmpty)
        XCTAssertFalse(stats.byLevel.isEmpty)
    }
    
    func testStatisticsCountForLevel() {
        // Given
        let stats = viewModel.statistics
        
        // When/Then
        for level in PositionLevel.allCases {
            let count = stats.count(for: level)
            let expectedCount = viewModel.positions.filter { $0.level == level }.count
            XCTAssertEqual(count, expectedCount)
        }
    }
    
    // MARK: - Competency Matrix Tests
    
    func testGetCompetencyMatrix() {
        // Given
        guard let position = viewModel.positions.first(where: { !$0.competencyRequirements.isEmpty }) else {
            // If no positions with requirements, create one
            let testPosition = Position(
                name: "Test Position with Requirements",
                description: "Test",
                department: "Test",
                level: .middle,
                competencyRequirements: [
                    CompetencyRequirement(competencyId: UUID(), competencyName: "Test", requiredLevel: 3, isCritical: true),
                    CompetencyRequirement(competencyId: UUID(), competencyName: "Test2", requiredLevel: 2, isCritical: false)
                ],
                employeeCount: 1
            )
            PositionMockService.shared.createPosition(testPosition)
            
            // Wait and retry
            let expectation = XCTestExpectation(description: "Create position")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                expectation.fulfill()
            }
            wait(for: [expectation], timeout: 0.5)
            
            guard let position = viewModel.positions.first(where: { !$0.competencyRequirements.isEmpty }) else {
                XCTFail("No positions with competency requirements")
                return
            }
            
            // When
            let matrix = viewModel.getCompetencyMatrix(for: position)
            
            // Then
            XCTAssertEqual(matrix.position.id, position.id)
            XCTAssertEqual(matrix.requirements.count, position.competencyRequirements.count)
            
            // Check critical requirements are first
            let criticalCount = matrix.criticalRequirements.count
            if criticalCount > 0 {
                let firstCriticalIndex = matrix.requirements.firstIndex { $0.isCritical } ?? 0
                let lastCriticalIndex = matrix.requirements.lastIndex { $0.isCritical } ?? 0
                XCTAssertEqual(lastCriticalIndex - firstCriticalIndex + 1, criticalCount)
            }
            
            return
        }
        
        // When
        let matrix = viewModel.getCompetencyMatrix(for: position)
        
        // Then
        XCTAssertEqual(matrix.position.id, position.id)
        XCTAssertEqual(matrix.requirements.count, position.competencyRequirements.count)
        
        // Check critical requirements are first
        let criticalCount = matrix.criticalRequirements.count
        if criticalCount > 0 {
            let firstCriticalIndex = matrix.requirements.firstIndex { $0.isCritical } ?? 0
            let lastCriticalIndex = matrix.requirements.lastIndex { $0.isCritical } ?? 0
            XCTAssertEqual(lastCriticalIndex - firstCriticalIndex + 1, criticalCount)
        }
    }
    
    func testCompetencyMatrixCriticalRequirements() {
        // Given - create position with requirements
        let testPosition = Position(
            name: "Test Position Critical",
            description: "Test",
            department: "Test",
            level: .senior,
            competencyRequirements: [
                CompetencyRequirement(competencyId: UUID(), competencyName: "Critical1", requiredLevel: 5, isCritical: true),
                CompetencyRequirement(competencyId: UUID(), competencyName: "Critical2", requiredLevel: 4, isCritical: true),
                CompetencyRequirement(competencyId: UUID(), competencyName: "Optional", requiredLevel: 3, isCritical: false)
            ],
            employeeCount: 1
        )
        PositionMockService.shared.createPosition(testPosition)
        
        // Wait for creation
        let expectation = XCTestExpectation(description: "Create position")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 0.5)
        
        guard let position = viewModel.positions.first(where: { $0.name == "Test Position Critical" }) else {
            XCTFail("Failed to create test position")
            return
        }
        
        let matrix = viewModel.getCompetencyMatrix(for: position)
        
        // Then
        let criticalFromPosition = position.competencyRequirements.filter { $0.isCritical }
        XCTAssertEqual(matrix.criticalRequirements.count, criticalFromPosition.count)
        XCTAssertEqual(matrix.criticalRequirements.count, 2)
        XCTAssertTrue(matrix.criticalRequirements.allSatisfy { $0.isCritical })
        
        // Cleanup
        PositionMockService.shared.deletePosition(position.id)
    }
    
    func testCompetencyMatrixAverageLevel() {
        // Given - create position with requirements
        let testPosition = Position(
            name: "Test Position Average",
            description: "Test",
            department: "Test",
            level: .middle,
            competencyRequirements: [
                CompetencyRequirement(competencyId: UUID(), competencyName: "Req1", requiredLevel: 3, isCritical: true),
                CompetencyRequirement(competencyId: UUID(), competencyName: "Req2", requiredLevel: 4, isCritical: false),
                CompetencyRequirement(competencyId: UUID(), competencyName: "Req3", requiredLevel: 5, isCritical: false)
            ],
            employeeCount: 1
        )
        PositionMockService.shared.createPosition(testPosition)
        
        // Wait for creation
        let expectation = XCTestExpectation(description: "Create position")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 0.5)
        
        guard let position = viewModel.positions.first(where: { $0.name == "Test Position Average" }) else {
            XCTFail("Failed to create test position")
            return
        }
        
        let matrix = viewModel.getCompetencyMatrix(for: position)
        
        // When/Then
        let expectedAverage = Double(position.competencyRequirements.reduce(0) { $0 + $1.requiredLevel }) / Double(position.competencyRequirements.count)
        XCTAssertEqual(matrix.averageRequiredLevel, expectedAverage, accuracy: 0.01)
        XCTAssertEqual(matrix.averageRequiredLevel, 4.0, accuracy: 0.01)
        
        // Cleanup
        PositionMockService.shared.deletePosition(position.id)
    }
    
    // MARK: - Loading State Tests
    
    func testLoadData() {
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
        viewModel.loadData()
        
        // Then
        XCTAssertTrue(viewModel.isLoading)
        wait(for: [expectation], timeout: 1)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
    }
} 