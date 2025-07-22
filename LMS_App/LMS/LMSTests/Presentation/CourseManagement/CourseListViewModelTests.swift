//
//  CourseListViewModelTests.swift
//  LMSTests
//
//  Created by AI Assistant on 2025-07-17.
//

import XCTest
import Combine
@testable import LMS

@MainActor
final class CourseListViewModelTests: XCTestCase {
    
    // MARK: - Properties
    
    private var sut: CourseListViewModel!
    private var mockUseCase: MockFetchCoursesUseCase!
    private var cancellables: Set<AnyCancellable>!
    
    // MARK: - Setup
    
    override func setUp() {
        super.setUp()
        mockUseCase = MockFetchCoursesUseCase()
        sut = CourseListViewModel(fetchCoursesUseCase: mockUseCase)
        cancellables = []
    }
    
    override func tearDown() {
        sut = nil
        mockUseCase = nil
        cancellables = nil
        super.tearDown()
    }
    
    // MARK: - Tests
    
    func test_loadCourses_success_updatesCourses() async {
        // Given
        let expectedCourses = CourseEntity.testData
        mockUseCase.coursesToReturn = expectedCourses
        
        // When
        sut.loadCourses()
        
        // Wait for async operation
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 second
        
        // Then
        XCTAssertEqual(sut.courses, expectedCourses)
        XCTAssertEqual(sut.filteredCourses, expectedCourses)
        XCTAssertFalse(sut.isLoading)
        XCTAssertNil(sut.error)
    }
    
    func test_loadCourses_failure_setsError() async {
        // Given
        let expectedError = NetworkError.invalidResponse
        mockUseCase.errorToThrow = expectedError
        
        // When
        sut.loadCourses()
        
        // Wait for async operation
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        // Then
        XCTAssertTrue(sut.courses.isEmpty)
        XCTAssertNotNil(sut.error)
        XCTAssertFalse(sut.isLoading)
    }
    
    func test_searchText_filtersCourses() {
        // Given
        sut.courses = CourseEntity.testData
        sut.filteredCourses = CourseEntity.testData
        
        // When
        sut.searchText = "Swift"
        
        // Wait for debounce
        let expectation = XCTestExpectation(description: "Filter applied")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
        
        // Then
        XCTAssertTrue(sut.filteredCourses.contains { $0.title.contains("Swift") })
        XCTAssertFalse(sut.filteredCourses.contains { !$0.title.contains("Swift") && !$0.description.contains("Swift") })
    }
    
    func test_filter_cmi5_showsOnlyCmi5Courses() {
        // Given
        sut.courses = CourseEntity.testData
        sut.filteredCourses = CourseEntity.testData
        
        // When
        sut.selectedFilter = .cmi5
        
        // Wait for filter to apply
        let expectation = XCTestExpectation(description: "Filter applied")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
        
        // Then
        XCTAssertTrue(sut.filteredCourses.allSatisfy { $0.isCmi5 })
    }
    
    func test_isEmpty_whenNoCoursesAndNotLoading_returnsTrue() {
        // Given
        sut.courses = []
        sut.filteredCourses = []
        
        // Then
        XCTAssertTrue(sut.isEmpty)
    }
    
    func test_emptyMessage_withSearchText_returnsSearchMessage() {
        // Given
        sut.searchText = "Python"
        sut.filteredCourses = []
        
        // Then
        XCTAssertEqual(sut.emptyMessage, "Курсы по запросу «Python» не найдены")
    }
}

// MARK: - Mock

private final class MockFetchCoursesUseCase: FetchCoursesUseCaseProtocol {
    var coursesToReturn: [CourseEntity] = []
    var errorToThrow: Error?
    var executeCallCount = 0
    
    func execute() async throws -> [CourseEntity] {
        executeCallCount += 1
        
        if let error = errorToThrow {
            throw error
        }
        
        return coursesToReturn
    }
    
    func execute(page: Int, pageSize: Int) async throws -> PaginatedResponse<CourseEntity> {
        PaginatedResponse(
            items: coursesToReturn,
            currentPage: page,
            totalPages: 1,
            totalItems: coursesToReturn.count,
            hasNextPage: false,
            hasPreviousPage: false
        )
    }
    
    func execute(searchQuery: String) async throws -> [CourseEntity] {
        coursesToReturn.filter {
            $0.title.localizedCaseInsensitiveContains(searchQuery) ||
            $0.description.localizedCaseInsensitiveContains(searchQuery)
        }
    }
}

// MARK: - Test Data

private extension CourseEntity {
    static var testData: [CourseEntity] {
        [
            CourseEntity(
                id: "1",
                title: "Основы Swift",
                description: "Изучите основы языка Swift",
                modules: [],
                instructor: InstructorEntity(id: "1", name: "Иван Иванов"),
                duration: 3600,
                isCmi5: false,
                status: .published,
                category: nil,
                level: .beginner,
                enrolledCount: 0,
                rating: nil,
                tags: []
            ),
            CourseEntity(
                id: "2",
                title: "AI Fluency",
                description: "Основы искусственного интеллекта",
                modules: [],
                instructor: InstructorEntity(id: "2", name: "Анна Петрова"),
                duration: 7200,
                isCmi5: true,
                status: .published,
                category: nil,
                level: .intermediate,
                enrolledCount: 0,
                rating: nil,
                tags: []
            ),
            CourseEntity(
                id: "3",
                title: "iOS Architecture",
                description: "Архитектура iOS приложений",
                modules: [],
                instructor: InstructorEntity(id: "3", name: "Петр Сидоров"),
                duration: 5400,
                isCmi5: false,
                status: .published,
                category: nil,
                level: .advanced,
                enrolledCount: 0,
                rating: nil,
                tags: []
            )
        ]
    }
}

// MARK: - Network Error

private enum NetworkError: LocalizedError {
    case invalidResponse
    
    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Invalid response from server"
        }
    }
} 