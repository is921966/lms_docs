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
        // Given
        let expectation = XCTestExpectation(description: "Inactive filter")
        
        // Create inactive position
        var inactivePosition = Position(
            name: "Inactive Test Position",
            description: "Test inactive position",
            department: "Test",
            level: .junior,
            competencyRequirements: [],
            employeeCount: 0
        )
        inactivePosition.isActive = false
        PositionMockService.shared.createPosition(inactivePosition)
        
        viewModel.$filteredPositions
            .dropFirst()
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        // When - show only active
        viewModel.showInactivePositions = false
        
        // Then
        wait(for: [expectation], timeout: 1)
        XCTAssertTrue(viewModel.filteredPositions.allSatisfy { $0.isActive })
        
        // When - show all
        viewModel.showInactivePositions = true
        wait(for: [expectation], timeout: 1)
        XCTAssertTrue(viewModel.filteredPositions.contains { !$0.isActive })
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
        let newPosition = Position(
            name: "New Test Position",
            description: "Test description",
            department: "Test",
            level: .middle,
            competencyRequirements: [],
            employeeCount: 1
        )
        let initialCount = viewModel.positions.count
        
        // When
        viewModel.createPosition(newPosition)
        
        // Then
        XCTAssertEqual(viewModel.positions.count, initialCount + 1)
        XCTAssertTrue(viewModel.positions.contains { $0.id == newPosition.id })
        XCTAssertFalse(viewModel.showingCreateSheet)
    }
    
    func testUpdatePosition() {
        // Given
        var position = viewModel.positions.first!
        position.name = "Updated Title"
        viewModel.selectedPosition = position
        viewModel.showingEditSheet = true
        
        // When
        viewModel.updatePosition(position)
        
        // Then
        XCTAssertTrue(viewModel.positions.contains { $0.name == "Updated Title" })
        XCTAssertFalse(viewModel.showingEditSheet)
        XCTAssertNil(viewModel.selectedPosition)
    }
    
    func testDeletePosition() {
        // Given
        let position = viewModel.positions.first!
        let initialCount = viewModel.positions.count
        
        // When
        viewModel.deletePosition(position)
        
        // Then
        XCTAssertEqual(viewModel.positions.count, initialCount - 1)
        XCTAssertFalse(viewModel.positions.contains { $0.id == position.id })
    }
    
    func testTogglePositionStatus() {
        // Given
        let position = viewModel.positions.first!
        let initialStatus = position.isActive
        
        // When
        viewModel.togglePositionStatus(position)
        
        // Then
        let updatedPosition = viewModel.positions.first { $0.id == position.id }
        XCTAssertNotNil(updatedPosition)
        XCTAssertEqual(updatedPosition?.isActive, !initialStatus)
    }
    
    // MARK: - Career Path Tests
    
    func testGetCareerPaths() {
        // Given
        let position = viewModel.positions.first!
        
        // When
        let paths = viewModel.getCareerPaths(for: position)
        
        // Then
        XCTAssertFalse(paths.isEmpty)
        XCTAssertTrue(paths.allSatisfy { $0.fromPositionId == position.id })
    }
    
    func testGetIncomingCareerPaths() {
        // Given
        let position = viewModel.positions.first { $0.level == .senior }!
        
        // When
        let incomingPaths = viewModel.getIncomingCareerPaths(for: position)
        
        // Then
        XCTAssertTrue(incomingPaths.allSatisfy { $0.toPositionId == position.id })
    }
    
    func testCreateCareerPath() {
        // Given
        let fromPosition = viewModel.positions.first!
        let toPosition = viewModel.positions.last!
        let newPath = CareerPath(
            fromPositionId: fromPosition.id,
            toPositionId: toPosition.id,
            fromPositionName: fromPosition.name,
            toPositionName: toPosition.name,
            estimatedDuration: .years2,
            description: "Test career path"
        )
        let initialCount = viewModel.careerPaths.count
        
        // When
        viewModel.createCareerPath(newPath)
        
        // Then
        XCTAssertEqual(viewModel.careerPaths.count, initialCount + 1)
    }
    
    // MARK: - UI Action Tests
    
    func testSelectPositionForEdit() {
        // Given
        let position = viewModel.positions.first!
        
        // When
        viewModel.selectPositionForEdit(position)
        
        // Then
        XCTAssertEqual(viewModel.selectedPosition?.id, position.id)
        XCTAssertTrue(viewModel.showingEditSheet)
    }
    
    func testSelectPositionForCareerPaths() {
        // Given
        let position = viewModel.positions.first!
        
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
        XCTAssertGreaterThan(stats.totalEmployees, 0)
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
        let position = viewModel.positions.first { !$0.competencyRequirements.isEmpty }!
        
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
        // Given
        let position = viewModel.positions.first { !$0.competencyRequirements.isEmpty }!
        let matrix = viewModel.getCompetencyMatrix(for: position)
        
        // Then
        let criticalFromPosition = position.competencyRequirements.filter { $0.isCritical }
        XCTAssertEqual(matrix.criticalRequirements.count, criticalFromPosition.count)
        XCTAssertTrue(matrix.criticalRequirements.allSatisfy { $0.isCritical })
    }
    
    func testCompetencyMatrixAverageLevel() {
        // Given
        let position = viewModel.positions.first { !$0.competencyRequirements.isEmpty }!
        let matrix = viewModel.getCompetencyMatrix(for: position)
        
        // When/Then
        let expectedAverage = Double(position.competencyRequirements.reduce(0) { $0 + $1.requiredLevel }) / Double(position.competencyRequirements.count)
        XCTAssertEqual(matrix.averageRequiredLevel, expectedAverage, accuracy: 0.01)
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