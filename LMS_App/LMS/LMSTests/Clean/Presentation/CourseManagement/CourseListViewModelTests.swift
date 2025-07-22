import XCTest
import Combine
@testable import LMS

// MARK: - Mock Classes

class MockFetchCoursesUseCase: FetchCoursesUseCaseProtocol {
    var shouldReturnError = false
    var coursesToReturn: [CourseEntity] = []
    var fetchCallCount = 0
    
    func execute() async throws -> [CourseEntity] {
        fetchCallCount += 1
        
        if shouldReturnError {
            throw NSError(domain: "TestError", code: 1, userInfo: nil)
        }
        
        return coursesToReturn
    }
}

// MARK: - Tests

final class CourseListViewModelTests: XCTestCase {
    var sut: CourseListViewModel!
    var mockUseCase: MockFetchCoursesUseCase!
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        mockUseCase = MockFetchCoursesUseCase()
        sut = CourseListViewModel(fetchCoursesUseCase: mockUseCase)
        cancellables = []
    }
    
    override func tearDown() {
        cancellables = nil
        sut = nil
        mockUseCase = nil
        super.tearDown()
    }
    
    // MARK: - Initial State Tests
    
    func testInitialState() {
        XCTAssertTrue(sut.courses.isEmpty)
        XCTAssertTrue(sut.filteredCourses.isEmpty)
        XCTAssertFalse(sut.isLoading)
        XCTAssertNil(sut.error)
        XCTAssertEqual(sut.searchText, "")
    }
    
    // MARK: - Loading Courses Tests
    
    func testLoadCoursesSuccess() async {
        // Given
        let expectedCourses = [
            CourseEntity(
                id: "1",
                title: "Swift Basics",
                description: "Learn Swift",
                modules: [],
                instructor: InstructorEntity(id: "1", name: "John Doe", bio: "Expert"),
                duration: 120,
                thumbnailURL: nil,
                isCmi5: false,
                cmi5PackageId: nil
            ),
            CourseEntity(
                id: "2",
                title: "iOS Advanced",
                description: "Advanced iOS",
                modules: [],
                instructor: InstructorEntity(id: "2", name: "Jane Doe", bio: "Professional"),
                duration: 180,
                thumbnailURL: nil,
                isCmi5: true,
                cmi5PackageId: "package-1"
            )
        ]
        mockUseCase.coursesToReturn = expectedCourses
        
        // When
        await sut.loadCourses()
        
        // Then
        XCTAssertEqual(mockUseCase.fetchCallCount, 1)
        XCTAssertEqual(sut.courses.count, 2)
        XCTAssertEqual(sut.filteredCourses.count, 2)
        XCTAssertFalse(sut.isLoading)
        XCTAssertNil(sut.error)
    }
    
    func testLoadCoursesFailure() async {
        // Given
        mockUseCase.shouldReturnError = true
        
        // When
        await sut.loadCourses()
        
        // Then
        XCTAssertEqual(mockUseCase.fetchCallCount, 1)
        XCTAssertTrue(sut.courses.isEmpty)
        XCTAssertTrue(sut.filteredCourses.isEmpty)
        XCTAssertFalse(sut.isLoading)
        XCTAssertNotNil(sut.error)
    }
    
    func testLoadingStateChanges() {
        // Given
        var loadingStates: [Bool] = []
        
        sut.$isLoading
            .sink { loadingStates.append($0) }
            .store(in: &cancellables)
        
        // When
        Task {
            await sut.loadCourses()
        }
        
        // Then
        // Wait for async operation
        let expectation = expectation(description: "Loading states captured")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            XCTAssertEqual(loadingStates.first, false) // Initial state
            XCTAssertTrue(loadingStates.contains(true)) // Loading started
            XCTAssertEqual(loadingStates.last, false) // Loading finished
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    // MARK: - Search Tests
    
    func testSearchFiltersCourses() {
        // Given
        sut.courses = [
            CourseEntity(
                id: "1",
                title: "Swift Basics",
                description: "Learn Swift",
                modules: [],
                instructor: InstructorEntity(id: "1", name: "John Doe", bio: "Expert"),
                duration: 120,
                thumbnailURL: nil,
                isCmi5: false,
                cmi5PackageId: nil
            ),
            CourseEntity(
                id: "2",
                title: "iOS Advanced",
                description: "Advanced iOS",
                modules: [],
                instructor: InstructorEntity(id: "2", name: "Jane Doe", bio: "Professional"),
                duration: 180,
                thumbnailURL: nil,
                isCmi5: true,
                cmi5PackageId: "package-1"
            )
        ]
        
        // When
        sut.searchText = "Swift"
        
        // Then
        XCTAssertEqual(sut.filteredCourses.count, 1)
        XCTAssertEqual(sut.filteredCourses.first?.title, "Swift Basics")
    }
    
    func testSearchByDescription() {
        // Given
        sut.courses = [
            CourseEntity(
                id: "1",
                title: "Course 1",
                description: "Learn Swift",
                modules: [],
                instructor: InstructorEntity(id: "1", name: "John", bio: "Expert"),
                duration: 120,
                thumbnailURL: nil,
                isCmi5: false,
                cmi5PackageId: nil
            ),
            CourseEntity(
                id: "2",
                title: "Course 2",
                description: "Learn Kotlin",
                modules: [],
                instructor: InstructorEntity(id: "2", name: "Jane", bio: "Professional"),
                duration: 180,
                thumbnailURL: nil,
                isCmi5: false,
                cmi5PackageId: nil
            )
        ]
        
        // When
        sut.searchText = "Kotlin"
        
        // Then
        XCTAssertEqual(sut.filteredCourses.count, 1)
        XCTAssertEqual(sut.filteredCourses.first?.title, "Course 2")
    }
    
    func testSearchCaseInsensitive() {
        // Given
        sut.courses = [
            CourseEntity(
                id: "1",
                title: "SWIFT BASICS",
                description: "Learn",
                modules: [],
                instructor: InstructorEntity(id: "1", name: "John", bio: "Expert"),
                duration: 120,
                thumbnailURL: nil,
                isCmi5: false,
                cmi5PackageId: nil
            )
        ]
        
        // When
        sut.searchText = "swift"
        
        // Then
        XCTAssertEqual(sut.filteredCourses.count, 1)
    }
    
    func testEmptySearchShowsAllCourses() {
        // Given
        let courses = [
            CourseEntity(
                id: "1",
                title: "Course 1",
                description: "Description 1",
                modules: [],
                instructor: InstructorEntity(id: "1", name: "John", bio: "Expert"),
                duration: 120,
                thumbnailURL: nil,
                isCmi5: false,
                cmi5PackageId: nil
            ),
            CourseEntity(
                id: "2",
                title: "Course 2",
                description: "Description 2",
                modules: [],
                instructor: InstructorEntity(id: "2", name: "Jane", bio: "Professional"),
                duration: 180,
                thumbnailURL: nil,
                isCmi5: false,
                cmi5PackageId: nil
            )
        ]
        sut.courses = courses
        sut.searchText = "test"
        
        // When
        sut.searchText = ""
        
        // Then
        XCTAssertEqual(sut.filteredCourses.count, courses.count)
    }
    
    // MARK: - Refresh Tests
    
    func testRefreshReloadsCourses() async {
        // Given
        mockUseCase.coursesToReturn = [
            CourseEntity(
                id: "1",
                title: "Course 1",
                description: "Description",
                modules: [],
                instructor: InstructorEntity(id: "1", name: "John", bio: "Expert"),
                duration: 120,
                thumbnailURL: nil,
                isCmi5: false,
                cmi5PackageId: nil
            )
        ]
        
        // When
        await sut.refresh()
        
        // Then
        XCTAssertEqual(mockUseCase.fetchCallCount, 1)
        XCTAssertEqual(sut.courses.count, 1)
    }
    
    // MARK: - Combine Publishers Tests
    
    func testCourseSelectionPublisher() {
        // Given
        let course = CourseEntity(
            id: "1",
            title: "Test Course",
            description: "Description",
            modules: [],
            instructor: InstructorEntity(id: "1", name: "John", bio: "Expert"),
            duration: 120,
            thumbnailURL: nil,
            isCmi5: false,
            cmi5PackageId: nil
        )
        
        var selectedCourse: CourseEntity?
        sut.courseSelected
            .sink { selectedCourse = $0 }
            .store(in: &cancellables)
        
        // When
        sut.selectCourse(course)
        
        // Then
        XCTAssertEqual(selectedCourse?.id, course.id)
    }
} 