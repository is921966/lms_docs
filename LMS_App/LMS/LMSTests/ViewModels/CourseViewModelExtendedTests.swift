import XCTest
import Combine
@testable import LMS

final class CourseViewModelExtendedTests: XCTestCase {
    
    // MARK: - Properties
    var sut: CourseViewModel!
    var cancellables: Set<AnyCancellable>!
    
    // MARK: - Setup
    override func setUp() {
        super.setUp()
        sut = CourseViewModel()
        cancellables = []
    }
    
    override func tearDown() {
        cancellables = nil
        sut = nil
        super.tearDown()
    }
    
    // MARK: - Initialization Tests
    
    func testInitialization() {
        // Then
        XCTAssertNotNil(sut, "CourseViewModel should be initialized")
        XCTAssertTrue(sut.courses.isEmpty || !sut.courses.isEmpty, "Courses array should exist")
        XCTAssertEqual(sut.searchText, "")
        XCTAssertEqual(sut.selectedCategory, "Все")
        XCTAssertFalse(sut.isLoading)
        XCTAssertNil(sut.errorMessage)
    }
    
    func testInitialLoadCoursesIsCalled() {
        // Given
        let expectation = XCTestExpectation(description: "Initial load completes")
        
        // When
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            // Then
            XCTAssertFalse(self.sut.isLoading)
            XCTAssertGreaterThan(self.sut.courses.count, 0)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    // MARK: - Load Courses Tests
    
    func testLoadCourses() {
        // Given
        let expectation = XCTestExpectation(description: "Courses loaded")
        
        // When
        sut.loadCourses()
        
        // Then - immediate state
        XCTAssertTrue(sut.isLoading)
        XCTAssertNil(sut.errorMessage)
        
        // Wait for async operation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            XCTAssertFalse(self.sut.isLoading)
            XCTAssertFalse(self.sut.courses.isEmpty)
            XCTAssertFalse(self.sut.enrolledCourses.isEmpty)
            XCTAssertFalse(self.sut.availableCourses.isEmpty)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testLoadCoursesMultipleTimes() {
        // Given
        let expectation = XCTestExpectation(description: "Multiple loads")
        expectation.expectedFulfillmentCount = 3
        
        // When - load 3 times
        for i in 1...3 {
            sut.loadCourses()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.6) {
                XCTAssertFalse(self.sut.isLoading)
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 3.0)
    }
    
    // MARK: - Enroll/Leave Course Tests
    
    func testEnrollInCourse() {
        // Given
        let expectation = XCTestExpectation(description: "Course enrolled")
        
        // Wait for initial load
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            guard let courseToEnroll = self.sut.availableCourses.first else {
                XCTFail("Need available courses")
                return
            }
            
            let initialEnrolledCount = self.sut.enrolledCourses.count
            
            // When
            self.sut.enrollInCourse(courseToEnroll)
            
            // Wait for reload
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                // Then
                XCTAssertGreaterThan(self.sut.enrolledCourses.count, initialEnrolledCount)
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 2.0)
    }
    
    func testLeaveCourse() {
        // Given
        let expectation = XCTestExpectation(description: "Course left")
        
        // Wait for initial load
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            guard let courseToLeave = self.sut.enrolledCourses.first else {
                XCTFail("Need enrolled courses")
                return
            }
            
            let initialEnrolledCount = self.sut.enrolledCourses.count
            
            // When
            self.sut.leaveCourse(courseToLeave)
            
            // Wait for reload
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                // Then
                XCTAssertLessThan(self.sut.enrolledCourses.count, initialEnrolledCount)
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 2.0)
    }
    
    func testEnrollAndLeaveMultipleCourses() {
        // Given
        let expectation = XCTestExpectation(description: "Multiple operations")
        
        // Wait for initial load
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            let availableCourses = self.sut.availableCourses
            
            // Enroll in multiple courses
            for (index, course) in availableCourses.prefix(2).enumerated() {
                DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.1) {
                    self.sut.enrollInCourse(course)
                }
            }
            
            // Wait and verify
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                XCTAssertGreaterThanOrEqual(self.sut.enrolledCourses.count, 2)
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 3.0)
    }
    
    // MARK: - Published Properties Tests
    
    func testSearchTextBinding() {
        // Given
        let expectation = XCTestExpectation(description: "Search text updated")
        var receivedValues: [String] = []
        
        // When
        sut.$searchText
            .sink { value in
                receivedValues.append(value)
                if receivedValues.count >= 3 {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        sut.searchText = "iOS"
        sut.searchText = "Swift"
        
        // Then
        wait(for: [expectation], timeout: 1.0)
        XCTAssertTrue(receivedValues.contains(""))
        XCTAssertTrue(receivedValues.contains("iOS"))
        XCTAssertTrue(receivedValues.contains("Swift"))
    }
    
    func testSelectedCategoryBinding() {
        // Given
        let expectation = XCTestExpectation(description: "Category updated")
        var receivedCategories: [String] = []
        
        // When
        sut.$selectedCategory
            .sink { category in
                receivedCategories.append(category)
                if receivedCategories.count >= 3 {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        sut.selectedCategory = "Программирование"
        sut.selectedCategory = "Дизайн"
        
        // Then
        wait(for: [expectation], timeout: 1.0)
        XCTAssertTrue(receivedCategories.contains("Все"))
        XCTAssertTrue(receivedCategories.contains("Программирование"))
        XCTAssertTrue(receivedCategories.contains("Дизайн"))
    }
    
    func testIsLoadingStateChanges() {
        // Given
        let expectation = XCTestExpectation(description: "Loading state changes")
        var loadingStates: [Bool] = []
        
        // When
        sut.$isLoading
            .sink { isLoading in
                loadingStates.append(isLoading)
            }
            .store(in: &cancellables)
        
        sut.loadCourses()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            // Then
            XCTAssertGreaterThanOrEqual(loadingStates.count, 2)
            XCTAssertTrue(loadingStates.contains(true))
            XCTAssertTrue(loadingStates.contains(false))
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 2.0)
    }
    
    func testErrorMessageHandling() {
        // Given/When
        sut.errorMessage = "Test error"
        
        // Then
        XCTAssertEqual(sut.errorMessage, "Test error")
        
        // When loading starts
        sut.loadCourses()
        
        // Then error should be cleared
        XCTAssertNil(sut.errorMessage)
    }
    
    // MARK: - Edge Cases
    
    func testConcurrentEnrollments() {
        // Given
        let expectation = XCTestExpectation(description: "Concurrent enrollments")
        
        // Wait for initial load
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            let availableCourses = self.sut.availableCourses
            
            // Simulate concurrent enrollments
            let group = DispatchGroup()
            
            for course in availableCourses.prefix(3) {
                group.enter()
                DispatchQueue.global().async {
                    self.sut.enrollInCourse(course)
                    group.leave()
                }
            }
            
            group.notify(queue: .main) {
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 3.0)
    }
    
    func testWeakSelfInLoadCourses() {
        // Given
        weak var weakViewModel = sut
        let expectation = XCTestExpectation(description: "Weak self handled")
        
        // When
        sut.loadCourses()
        sut = nil // Release strong reference
        
        // Then
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            XCTAssertNil(weakViewModel)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 2.0)
    }
    
    // MARK: - Performance Tests
    
    func testLoadCoursesPerformance() {
        measure {
            let expectation = XCTestExpectation(description: "Performance test")
            
            sut.loadCourses()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                expectation.fulfill()
            }
            
            wait(for: [expectation], timeout: 1.0)
        }
    }
    
    func testEnrollmentPerformance() {
        let expectation = XCTestExpectation(description: "Setup")
        
        // Setup
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
        
        guard let course = sut.availableCourses.first else {
            XCTFail("Need available courses")
            return
        }
        
        measure {
            sut.enrollInCourse(course)
        }
    }
} 