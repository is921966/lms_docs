//
//  CourseViewModelTests.swift
//  LMSTests
//
//  Created on 08/07/2025.
//

import XCTest
import Combine
@testable import LMS

final class CourseViewModelTests: XCTestCase {
    
    var viewModel: CourseViewModel!
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        viewModel = CourseViewModel()
        cancellables = Set<AnyCancellable>()
    }
    
    override func tearDown() {
        viewModel = nil
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
        XCTAssertEqual(viewModel.searchText, "")
        XCTAssertEqual(viewModel.selectedCategory, "Все")
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
    }
    
    func testLoadCoursesOnInit() {
        // Given
        let expectation = XCTestExpectation(description: "Courses loaded")
        
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
        XCTAssertFalse(viewModel.courses.isEmpty)
        XCTAssertFalse(viewModel.enrolledCourses.isEmpty)
        XCTAssertFalse(viewModel.availableCourses.isEmpty)
    }
    
    // MARK: - Loading Tests
    
    func testLoadCoursesSetsLoadingState() {
        // Given
        let expectation = XCTestExpectation(description: "Loading state changes")
        var loadingStates: [Bool] = []
        
        // Wait for initial load
        let initialLoadExpectation = XCTestExpectation(description: "Initial load")
        viewModel.$isLoading
            .dropFirst()
            .sink { isLoading in
                if !isLoading {
                    initialLoadExpectation.fulfill()
                }
            }
            .store(in: &cancellables)
        wait(for: [initialLoadExpectation], timeout: 2)
        
        // When
        viewModel.$isLoading
            .sink { isLoading in
                loadingStates.append(isLoading)
                if loadingStates.count >= 2 {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        viewModel.loadCourses()
        
        // Then
        wait(for: [expectation], timeout: 2)
        XCTAssertTrue(loadingStates.contains(true))
        XCTAssertTrue(loadingStates.contains(false))
    }
    
    func testLoadCoursesLoadsAllTypes() {
        // Given
        let expectation = XCTestExpectation(description: "All course types loaded")
        
        // When
        viewModel.loadCourses()
        
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
        XCTAssertGreaterThan(viewModel.courses.count, 0)
        XCTAssertGreaterThan(viewModel.enrolledCourses.count, 0)
        XCTAssertGreaterThan(viewModel.availableCourses.count, 0)
    }
    
    // MARK: - Enrollment Tests
    
    func testEnrollInCourse() {
        // Given
        let expectation = XCTestExpectation(description: "Course enrolled")
        
        // Wait for initial load
        let initialLoadExpectation = XCTestExpectation(description: "Initial load")
        viewModel.$isLoading
            .dropFirst()
            .sink { isLoading in
                if !isLoading {
                    initialLoadExpectation.fulfill()
                }
            }
            .store(in: &cancellables)
        wait(for: [initialLoadExpectation], timeout: 2)
        
        let initialEnrolledCount = viewModel.enrolledCourses.count
        let initialAvailableCount = viewModel.availableCourses.count
        
        guard let courseToEnroll = viewModel.availableCourses.first else {
            XCTFail("No available courses to enroll")
            return
        }
        
        // When
        viewModel.enrollInCourse(courseToEnroll)
        
        // Wait for enrollment to complete
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            expectation.fulfill()
        }
        
        // Then
        wait(for: [expectation], timeout: 2)
        XCTAssertEqual(viewModel.enrolledCourses.count, initialEnrolledCount + 1)
        XCTAssertEqual(viewModel.availableCourses.count, initialAvailableCount - 1)
    }
    
    func testLeaveCourse() {
        // Given
        let expectation = XCTestExpectation(description: "Course left")
        
        // Wait for initial load
        let initialLoadExpectation = XCTestExpectation(description: "Initial load")
        viewModel.$isLoading
            .dropFirst()
            .sink { isLoading in
                if !isLoading {
                    initialLoadExpectation.fulfill()
                }
            }
            .store(in: &cancellables)
        wait(for: [initialLoadExpectation], timeout: 2)
        
        let initialEnrolledCount = viewModel.enrolledCourses.count
        let initialAvailableCount = viewModel.availableCourses.count
        
        guard let courseToLeave = viewModel.enrolledCourses.first else {
            XCTFail("No enrolled courses to leave")
            return
        }
        
        // When
        viewModel.leaveCourse(courseToLeave)
        
        // Wait for leave to complete
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            expectation.fulfill()
        }
        
        // Then
        wait(for: [expectation], timeout: 2)
        XCTAssertEqual(viewModel.enrolledCourses.count, initialEnrolledCount - 1)
        XCTAssertEqual(viewModel.availableCourses.count, initialAvailableCount + 1)
    }
    
    // MARK: - Properties Tests
    
    func testSearchTextProperty() {
        // Given
        let newSearchText = "Swift"
        
        // When
        viewModel.searchText = newSearchText
        
        // Then
        XCTAssertEqual(viewModel.searchText, newSearchText)
    }
    
    func testSelectedCategoryProperty() {
        // Given
        let newCategory = "Programming"
        
        // When
        viewModel.selectedCategory = newCategory
        
        // Then
        XCTAssertEqual(viewModel.selectedCategory, newCategory)
    }
    
    func testErrorMessageProperty() {
        // Given
        let errorMessage = "Failed to load courses"
        
        // When
        viewModel.errorMessage = errorMessage
        
        // Then
        XCTAssertEqual(viewModel.errorMessage, errorMessage)
    }
    
    // MARK: - Multiple Operations Tests
    
    func testMultipleEnrollments() {
        // Given
        let expectation = XCTestExpectation(description: "Multiple enrollments")
        
        // Wait for initial load
        let initialLoadExpectation = XCTestExpectation(description: "Initial load")
        viewModel.$isLoading
            .dropFirst()
            .sink { isLoading in
                if !isLoading {
                    initialLoadExpectation.fulfill()
                }
            }
            .store(in: &cancellables)
        wait(for: [initialLoadExpectation], timeout: 2)
        
        guard viewModel.availableCourses.count >= 1 else {
            XCTFail("Not enough available courses for test")
            return
        }
        
        let courseToEnroll = viewModel.availableCourses[0]
        let initialEnrolledCount = viewModel.enrolledCourses.count
        
        // When - enroll in course
        viewModel.enrollInCourse(courseToEnroll)
        
        // Wait for enrollment
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            expectation.fulfill()
        }
        
        // Then
        wait(for: [expectation], timeout: 2)
        XCTAssertEqual(viewModel.enrolledCourses.count, initialEnrolledCount + 1)
        XCTAssertTrue(viewModel.enrolledCourses.contains { $0.id == courseToEnroll.id })
    }
} 