//
//  OnboardingViewModelTests.swift
//  LMSTests
//
//  Created on 08/07/2025.
//

import XCTest
import Combine
@testable import LMS

final class OnboardingViewModelTests: XCTestCase {
    
    var viewModel: OnboardingViewModel!
    var mockService: OnboardingMockService!
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        mockService = OnboardingMockService()
        viewModel = OnboardingViewModel(onboardingService: mockService)
        cancellables = Set<AnyCancellable>()
    }
    
    override func tearDown() {
        viewModel = nil
        mockService = nil
        cancellables = nil
        super.tearDown()
    }
    
    // MARK: - Initialization Tests
    
    func testInitialization() {
        // Given
        let expectation = XCTestExpectation(description: "Initial load complete")
        
        // When - already initialized in setUp
        viewModel.$isLoading
            .dropFirst()
            .sink { isLoading in
                if !isLoading {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        // Then
        wait(for: [expectation], timeout: 2)
        XCTAssertEqual(viewModel.selectedFilter, .all)
        XCTAssertEqual(viewModel.searchText, "")
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
    }
    
    func testLoadProgramsOnInit() {
        // Given
        let expectation = XCTestExpectation(description: "Programs loaded")
        
        // When - wait for initial load to complete
        viewModel.$isLoading
            .dropFirst()
            .sink { isLoading in
                if !isLoading {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        // Then
        wait(for: [expectation], timeout: 2)
        XCTAssertFalse(viewModel.programs.isEmpty)
        XCTAssertEqual(viewModel.programs.count, viewModel.filteredPrograms.count)
    }
    
    // MARK: - Statistics Tests
    
    func testActivePrograms() {
        // Given
        let activeCount = mockService.programs.filter { $0.status == .inProgress }.count
        
        // Then
        XCTAssertEqual(viewModel.activePrograms, activeCount)
    }
    
    func testCompletedPrograms() {
        // Given
        let completedCount = mockService.programs.filter { $0.status == .completed }.count
        
        // Then
        XCTAssertEqual(viewModel.completedPrograms, completedCount)
    }
    
    func testTotalPrograms() {
        // Given
        let totalCount = mockService.programs.count
        
        // Then
        XCTAssertEqual(viewModel.totalPrograms, totalCount)
    }
    
    func testCompletionRateWithPrograms() {
        // Given
        let completed = mockService.programs.filter { $0.status == .completed }.count
        let total = mockService.programs.count
        let expectedRate = total > 0 ? Double(completed) / Double(total) * 100 : 0
        
        // Then
        XCTAssertEqual(viewModel.completionRate, expectedRate)
    }
    
    func testCompletionRateWithNoPrograms() {
        // Given
        mockService.programs = []
        viewModel.loadPrograms()
        
        // Then
        XCTAssertEqual(viewModel.completionRate, 0)
    }
    
    func testAverageProgress() {
        // Given
        let programs = mockService.programs
        let expectedAverage = programs.isEmpty ? 0 : 
            programs.reduce(0) { $0 + $1.overallProgress } / Double(programs.count) * 100
        
        // Then
        XCTAssertEqual(viewModel.averageProgress, expectedAverage)
    }
    
    // MARK: - Filter Tests
    
    func testFilterInProgress() {
        // Given
        let expectation = XCTestExpectation(description: "Filter applied")
        
        // When
        viewModel.selectedFilter = .inProgress
        
        viewModel.$filteredPrograms
            .dropFirst()
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        // Then
        wait(for: [expectation], timeout: 1)
        XCTAssertTrue(viewModel.filteredPrograms.allSatisfy { $0.status == .inProgress })
    }
    
    func testFilterNotStarted() {
        // Given
        let expectation = XCTestExpectation(description: "Filter applied")
        
        // When
        viewModel.selectedFilter = .notStarted
        
        viewModel.$filteredPrograms
            .dropFirst()
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        // Then
        wait(for: [expectation], timeout: 1)
        XCTAssertTrue(viewModel.filteredPrograms.allSatisfy { $0.status == .notStarted })
    }
    
    func testFilterCompleted() {
        // Given
        let expectation = XCTestExpectation(description: "Filter applied")
        
        // When
        viewModel.selectedFilter = .completed
        
        viewModel.$filteredPrograms
            .dropFirst()
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        // Then
        wait(for: [expectation], timeout: 1)
        XCTAssertTrue(viewModel.filteredPrograms.allSatisfy { $0.status == .completed })
    }
    
    func testFilterOverdue() {
        // Given
        let expectation = XCTestExpectation(description: "Filter applied")
        
        // When
        viewModel.selectedFilter = .overdue
        
        viewModel.$filteredPrograms
            .dropFirst()
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        // Then
        wait(for: [expectation], timeout: 1)
        XCTAssertTrue(viewModel.filteredPrograms.allSatisfy { $0.isOverdue })
    }
    
    // MARK: - Search Tests
    
    func testSearchByEmployeeName() {
        // Given
        let expectation = XCTestExpectation(description: "Search applied")
        
        // Wait for initial load
        let loadExpectation = XCTestExpectation(description: "Initial load")
        viewModel.$isLoading
            .dropFirst()
            .sink { isLoading in
                if !isLoading {
                    loadExpectation.fulfill()
                }
            }
            .store(in: &cancellables)
        wait(for: [loadExpectation], timeout: 2)
        
        let searchName = mockService.programs.first?.employeeName.prefix(3).lowercased() ?? ""
        
        // When
        viewModel.searchText = String(searchName)
        
        // Wait for debounce + processing
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            expectation.fulfill()
        }
        
        // Then
        wait(for: [expectation], timeout: 2)
        XCTAssertTrue(viewModel.filteredPrograms.allSatisfy { 
            $0.employeeName.lowercased().contains(searchName)
        })
    }
    
    func testSearchByTitle() {
        // Given
        let expectation = XCTestExpectation(description: "Search applied")
        
        // Wait for initial load
        let loadExpectation = XCTestExpectation(description: "Initial load")
        viewModel.$isLoading
            .dropFirst()
            .sink { isLoading in
                if !isLoading {
                    loadExpectation.fulfill()
                }
            }
            .store(in: &cancellables)
        wait(for: [loadExpectation], timeout: 2)
        
        let searchTitle = mockService.programs.first?.title.prefix(3).lowercased() ?? ""
        
        // When
        viewModel.searchText = String(searchTitle)
        
        // Wait for debounce + processing
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            expectation.fulfill()
        }
        
        // Then
        wait(for: [expectation], timeout: 2)
        XCTAssertFalse(viewModel.filteredPrograms.isEmpty)
    }
    
    func testSearchWithNoResults() {
        // Given
        let expectation = XCTestExpectation(description: "Search applied")
        
        // Wait for initial load
        let loadExpectation = XCTestExpectation(description: "Initial load")
        viewModel.$isLoading
            .dropFirst()
            .sink { isLoading in
                if !isLoading {
                    loadExpectation.fulfill()
                }
            }
            .store(in: &cancellables)
        wait(for: [loadExpectation], timeout: 2)
        
        // When
        viewModel.searchText = "XXXXXXXXXXXXXX"
        
        // Wait for debounce + processing
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            expectation.fulfill()
        }
        
        // Then
        wait(for: [expectation], timeout: 2)
        XCTAssertTrue(viewModel.filteredPrograms.isEmpty)
    }
    
    // MARK: - Count Tests
    
    func testCountForFilterAll() {
        let count = viewModel.countForFilter(.all)
        XCTAssertEqual(count, mockService.programs.count)
    }
    
    func testCountForFilterInProgress() {
        let count = viewModel.countForFilter(.inProgress)
        let expectedCount = mockService.programs.filter { $0.status == .inProgress }.count
        XCTAssertEqual(count, expectedCount)
    }
    
    func testCountForFilterNotStarted() {
        let count = viewModel.countForFilter(.notStarted)
        let expectedCount = mockService.programs.filter { $0.status == .notStarted }.count
        XCTAssertEqual(count, expectedCount)
    }
    
    func testCountForFilterCompleted() {
        let count = viewModel.countForFilter(.completed)
        let expectedCount = mockService.programs.filter { $0.status == .completed }.count
        XCTAssertEqual(count, expectedCount)
    }
    
    func testCountForFilterOverdue() {
        let count = viewModel.countForFilter(.overdue)
        let expectedCount = mockService.programs.filter { $0.isOverdue }.count
        XCTAssertEqual(count, expectedCount)
    }
    
    // MARK: - Program Management Tests
    
    func testUpdateProgram() {
        // Given
        guard var program = mockService.programs.first else {
            XCTFail("No programs available")
            return
        }
        program.status = .completed
        
        // When
        viewModel.updateProgram(program)
        
        // Then
        let updatedProgram = mockService.programs.first { $0.id == program.id }
        XCTAssertEqual(updatedProgram?.status, .completed)
    }
    
    func testDeleteProgram() {
        // Given
        let initialCount = mockService.programs.count
        guard let programToDelete = mockService.programs.first else {
            XCTFail("No programs available")
            return
        }
        
        // When
        viewModel.deleteProgram(programToDelete)
        
        // Then
        XCTAssertEqual(mockService.programs.count, initialCount - 1)
        XCTAssertNil(mockService.programs.first { $0.id == programToDelete.id })
    }
    
    // MARK: - Combined Filter and Search Tests
    
    func testFilterAndSearchCombined() {
        // Given
        let expectation = XCTestExpectation(description: "Filter and search applied")
        
        // Wait for initial load
        let loadExpectation = XCTestExpectation(description: "Initial load")
        viewModel.$isLoading
            .dropFirst()
            .sink { isLoading in
                if !isLoading {
                    loadExpectation.fulfill()
                }
            }
            .store(in: &cancellables)
        wait(for: [loadExpectation], timeout: 2)
        
        // When
        viewModel.selectedFilter = .inProgress
        viewModel.searchText = mockService.programs
            .first { $0.status == .inProgress }?
            .employeeName.prefix(3).lowercased() ?? ""
        
        // Wait for debounce + processing
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            expectation.fulfill()
        }
        
        // Then
        wait(for: [expectation], timeout: 2)
        XCTAssertTrue(viewModel.filteredPrograms.allSatisfy { 
            $0.status == .inProgress &&
            $0.employeeName.lowercased().contains(viewModel.searchText)
        })
    }
} 