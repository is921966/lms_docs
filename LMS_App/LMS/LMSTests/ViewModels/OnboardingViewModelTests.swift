//
//  OnboardingViewModelTests.swift
//  LMSTests
//
//  Created on 06/07/2025.
//

import XCTest
import Combine
@testable import LMS

final class OnboardingViewModelTests: XCTestCase {
    
    var viewModel: OnboardingViewModel!
    var mockService: OnboardingMockService!
    var cancellables: Set<AnyCancellable> = []
    
    override func setUp() {
        super.setUp()
        mockService = OnboardingMockService()
        viewModel = OnboardingViewModel(onboardingService: mockService)
        cancellables = []
    }
    
    override func tearDown() {
        viewModel = nil
        mockService = nil
        cancellables.removeAll()
        super.tearDown()
    }
    
    // MARK: - Initialization Tests
    
    func testInitialState() {
        XCTAssertEqual(viewModel.selectedFilter, .all)
        XCTAssertEqual(viewModel.searchText, "")
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
        
        // Wait for initial load
        let expectation = XCTestExpectation(description: "Initial load")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
        
        XCTAssertFalse(viewModel.programs.isEmpty)
        XCTAssertEqual(viewModel.programs.count, viewModel.filteredPrograms.count)
    }
    
    // MARK: - Filtering Tests
    
    func testFilterByStatus() {
        // Wait for initial load
        let loadExpectation = XCTestExpectation(description: "Load complete")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            loadExpectation.fulfill()
        }
        wait(for: [loadExpectation], timeout: 1)
        
        // Test in progress filter
        viewModel.selectedFilter = .inProgress
        XCTAssertTrue(viewModel.filteredPrograms.allSatisfy { $0.status == .inProgress })
        
        // Test not started filter
        viewModel.selectedFilter = .notStarted
        XCTAssertTrue(viewModel.filteredPrograms.allSatisfy { $0.status == .notStarted })
        
        // Test completed filter
        viewModel.selectedFilter = .completed
        XCTAssertTrue(viewModel.filteredPrograms.allSatisfy { $0.status == .completed })
        
        // Test overdue filter
        viewModel.selectedFilter = .overdue
        XCTAssertTrue(viewModel.filteredPrograms.allSatisfy { $0.isOverdue })
        
        // Test all filter
        viewModel.selectedFilter = .all
        XCTAssertEqual(viewModel.filteredPrograms.count, viewModel.programs.count)
    }
    
    func testSearchFiltering() {
        // Wait for initial load
        let loadExpectation = XCTestExpectation(description: "Load complete")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            loadExpectation.fulfill()
        }
        wait(for: [loadExpectation], timeout: 1)
        
        // Set search text
        viewModel.searchText = "Иван"
        
        // Wait for debounce
        let searchExpectation = XCTestExpectation(description: "Search applied")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            searchExpectation.fulfill()
        }
        wait(for: [searchExpectation], timeout: 0.5)
        
        // Verify results
        XCTAssertTrue(viewModel.filteredPrograms.allSatisfy { program in
            program.employeeName.localizedCaseInsensitiveContains("Иван") ||
            program.title.localizedCaseInsensitiveContains("Иван") ||
            program.employeeDepartment.localizedCaseInsensitiveContains("Иван")
        })
    }
    
    func testCombinedFiltering() {
        // Wait for initial load
        let loadExpectation = XCTestExpectation(description: "Load complete")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            loadExpectation.fulfill()
        }
        wait(for: [loadExpectation], timeout: 1)
        
        // Apply filters
        viewModel.selectedFilter = .inProgress
        viewModel.searchText = "IT"
        
        // Wait for debounce
        let filterExpectation = XCTestExpectation(description: "Filters applied")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            filterExpectation.fulfill()
        }
        wait(for: [filterExpectation], timeout: 0.5)
        
        // Verify results
        XCTAssertTrue(viewModel.filteredPrograms.allSatisfy { program in
            program.status == .inProgress &&
            (program.employeeName.localizedCaseInsensitiveContains("IT") ||
             program.title.localizedCaseInsensitiveContains("IT") ||
             program.employeeDepartment.localizedCaseInsensitiveContains("IT"))
        })
    }
    
    // MARK: - Statistics Tests
    
    func testStatistics() {
        // Wait for initial load
        let loadExpectation = XCTestExpectation(description: "Load complete")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            loadExpectation.fulfill()
        }
        wait(for: [loadExpectation], timeout: 1)
        
        // Test counts
        let activeCount = viewModel.programs.filter { $0.status == .inProgress }.count
        let completedCount = viewModel.programs.filter { $0.status == .completed }.count
        
        XCTAssertEqual(viewModel.activePrograms, activeCount)
        XCTAssertEqual(viewModel.completedPrograms, completedCount)
        XCTAssertEqual(viewModel.totalPrograms, viewModel.programs.count)
    }
    
    func testCompletionRate() {
        // Wait for initial load
        let loadExpectation = XCTestExpectation(description: "Load complete")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            loadExpectation.fulfill()
        }
        wait(for: [loadExpectation], timeout: 1)
        
        let expectedRate = Double(viewModel.completedPrograms) / Double(viewModel.programs.count) * 100
        XCTAssertEqual(viewModel.completionRate, expectedRate, accuracy: 0.01)
    }
    
    func testAverageProgress() {
        // Wait for initial load
        let loadExpectation = XCTestExpectation(description: "Load complete")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            loadExpectation.fulfill()
        }
        wait(for: [loadExpectation], timeout: 1)
        
        let totalProgress = viewModel.programs.reduce(0) { $0 + $1.overallProgress }
        let expectedAverage = totalProgress / Double(viewModel.programs.count) * 100
        XCTAssertEqual(viewModel.averageProgress, expectedAverage, accuracy: 0.01)
    }
    
    func testEmptyStatistics() {
        // Clear programs
        mockService.programs = []
        viewModel.loadPrograms()
        
        // Wait for load
        let loadExpectation = XCTestExpectation(description: "Load complete")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            loadExpectation.fulfill()
        }
        wait(for: [loadExpectation], timeout: 1)
        
        XCTAssertEqual(viewModel.completionRate, 0)
        XCTAssertEqual(viewModel.averageProgress, 0)
    }
    
    // MARK: - CRUD Tests
    
    func testUpdateProgram() {
        // Wait for initial load
        let loadExpectation = XCTestExpectation(description: "Load complete")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            loadExpectation.fulfill()
        }
        wait(for: [loadExpectation], timeout: 1)
        
        // Get a program and update it
        guard var program = viewModel.programs.first else {
            XCTFail("No programs available")
            return
        }
        
        program.status = .completed
        viewModel.updateProgram(program)
        
        // Verify update
        let updatedProgram = viewModel.programs.first { $0.id == program.id }
        XCTAssertEqual(updatedProgram?.status, .completed)
    }
    
    func testDeleteProgram() {
        // Wait for initial load
        let loadExpectation = XCTestExpectation(description: "Load complete")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            loadExpectation.fulfill()
        }
        wait(for: [loadExpectation], timeout: 1)
        
        // Get initial count
        let initialCount = viewModel.programs.count
        
        // Delete first program
        guard let program = viewModel.programs.first else {
            XCTFail("No programs available")
            return
        }
        
        viewModel.deleteProgram(program)
        
        // Verify deletion
        XCTAssertEqual(viewModel.programs.count, initialCount - 1)
        XCTAssertFalse(viewModel.programs.contains { $0.id == program.id })
    }
    
    // MARK: - Count Tests
    
    func testCountForFilter() {
        // Wait for initial load
        let loadExpectation = XCTestExpectation(description: "Load complete")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            loadExpectation.fulfill()
        }
        wait(for: [loadExpectation], timeout: 1)
        
        // Test all filter types
        for filter in OnboardingViewModel.FilterType.allCases {
            let count = viewModel.countForFilter(filter)
            
            switch filter {
            case .all:
                XCTAssertEqual(count, viewModel.programs.count)
            case .inProgress:
                XCTAssertEqual(count, viewModel.programs.filter { $0.status == .inProgress }.count)
            case .notStarted:
                XCTAssertEqual(count, viewModel.programs.filter { $0.status == .notStarted }.count)
            case .completed:
                XCTAssertEqual(count, viewModel.programs.filter { $0.status == .completed }.count)
            case .overdue:
                XCTAssertEqual(count, viewModel.programs.filter { $0.isOverdue }.count)
            }
        }
    }
    
    // MARK: - Loading Tests
    
    func testLoadPrograms() {
        // Clear initial programs
        mockService.programs = []
        
        // Start loading
        viewModel.loadPrograms()
        
        // Verify loading state
        XCTAssertTrue(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
        
        // Wait for load to complete
        let loadExpectation = XCTestExpectation(description: "Load complete")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            loadExpectation.fulfill()
        }
        wait(for: [loadExpectation], timeout: 1)
        
        // Verify loading completed
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
    }
    
    // MARK: - Reactive Binding Tests
    
    func testProgramsBinding() {
        // Add new program directly to service
        let newProgram = OnboardingProgram(
            employeeId: "test-123",
            employeeName: "Test User",
            employeeDepartment: "Test Dept",
            employeePosition: "Test Position",
            startDate: Date()
        )
        
        let expectation = XCTestExpectation(description: "Programs updated")
        
        viewModel.$programs
            .dropFirst()
            .sink { programs in
                if programs.contains(where: { $0.id == newProgram.id }) {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        mockService.programs.append(newProgram)
        
        wait(for: [expectation], timeout: 1)
        XCTAssertTrue(viewModel.programs.contains { $0.id == newProgram.id })
    }
    
    func testFilterChangeReactivity() {
        // Wait for initial load
        let loadExpectation = XCTestExpectation(description: "Load complete")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            loadExpectation.fulfill()
        }
        wait(for: [loadExpectation], timeout: 1)
        
        let expectation = XCTestExpectation(description: "Filter applied")
        
        viewModel.$filteredPrograms
            .dropFirst()
            .sink { filteredPrograms in
                if filteredPrograms.allSatisfy({ $0.status == .completed }) {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        viewModel.selectedFilter = .completed
        
        wait(for: [expectation], timeout: 1)
    }
} 