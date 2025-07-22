//
//  CourseDuplicationTests.swift
//  LMSTests
//
//  Testing course duplication functionality
//

import XCTest
@testable import LMS

final class CourseDuplicationTests: XCTestCase {
    
    var mockCourseService: MockCourseService!
    var originalCourse: ManagedCourse!
    
    override func setUp() {
        super.setUp()
        
        mockCourseService = MockCourseService()
        
        // Create original course with all properties
        originalCourse = ManagedCourse(
            id: UUID(),
            title: "Original Course",
            description: "This is the original course",
            duration: 40,
            status: .published,
            competencies: [UUID(), UUID()],
            modules: [
                ManagedCourseModule(
                    id: UUID(),
                    title: "Module 1",
                    description: "First module",
                    order: 1,
                    contentType: .video,
                    contentUrl: "https://example.com/video1",
                    duration: 30
                ),
                ManagedCourseModule(
                    id: UUID(),
                    title: "Module 2",
                    description: "Second module",
                    order: 2,
                    contentType: .document,
                    contentUrl: "https://example.com/doc1",
                    duration: 60
                )
            ],
            createdAt: Date().addingTimeInterval(-86400), // Yesterday
            updatedAt: Date().addingTimeInterval(-3600), // 1 hour ago
            cmi5PackageId: UUID()
        )
        
        // Add original course to service
        mockCourseService.courses.append(originalCourse)
    }
    
    override func tearDown() {
        mockCourseService = nil
        originalCourse = nil
        super.tearDown()
    }
    
    // MARK: - Duplication Tests
    
    func test_duplicateCourse_shouldCreateNewCourseWithNewId() async throws {
        // When
        let duplicatedCourse = try await mockCourseService.duplicateCourse(originalCourse.id)
        
        // Then
        XCTAssertNotEqual(duplicatedCourse.id, originalCourse.id)
        XCTAssertEqual(mockCourseService.courses.count, 2)
    }
    
    func test_duplicateCourse_shouldAppendCopyToTitle() async throws {
        // When
        let duplicatedCourse = try await mockCourseService.duplicateCourse(originalCourse.id)
        
        // Then
        XCTAssertEqual(duplicatedCourse.title, "Original Course (копия)")
    }
    
    func test_duplicateCourse_withExistingCopy_shouldIncrementCopyNumber() async throws {
        // Given - create first copy
        _ = try await mockCourseService.duplicateCourse(originalCourse.id)
        
        // When - create second copy
        let secondCopy = try await mockCourseService.duplicateCourse(originalCourse.id)
        
        // Then
        XCTAssertEqual(secondCopy.title, "Original Course (копия 2)")
        XCTAssertEqual(mockCourseService.courses.count, 3)
    }
    
    func test_duplicateCourse_shouldResetStatusToDraft() async throws {
        // When
        let duplicatedCourse = try await mockCourseService.duplicateCourse(originalCourse.id)
        
        // Then
        XCTAssertEqual(duplicatedCourse.status, .draft)
        XCTAssertEqual(originalCourse.status, .published) // Original unchanged
    }
    
    func test_duplicateCourse_shouldCopyAllProperties() async throws {
        // When
        let duplicatedCourse = try await mockCourseService.duplicateCourse(originalCourse.id)
        
        // Then
        XCTAssertEqual(duplicatedCourse.description, originalCourse.description)
        XCTAssertEqual(duplicatedCourse.duration, originalCourse.duration)
        XCTAssertEqual(duplicatedCourse.competencies, originalCourse.competencies)
        XCTAssertEqual(duplicatedCourse.cmi5PackageId, originalCourse.cmi5PackageId)
    }
    
    func test_duplicateCourse_shouldDuplicateModulesWithNewIds() async throws {
        // When
        let duplicatedCourse = try await mockCourseService.duplicateCourse(originalCourse.id)
        
        // Then
        XCTAssertEqual(duplicatedCourse.modules.count, originalCourse.modules.count)
        
        // Check each module
        for (index, duplicatedModule) in duplicatedCourse.modules.enumerated() {
            let originalModule = originalCourse.modules[index]
            
            // New ID but same content
            XCTAssertNotEqual(duplicatedModule.id, originalModule.id)
            XCTAssertEqual(duplicatedModule.title, originalModule.title)
            XCTAssertEqual(duplicatedModule.description, originalModule.description)
            XCTAssertEqual(duplicatedModule.order, originalModule.order)
            XCTAssertEqual(duplicatedModule.contentType, originalModule.contentType)
            XCTAssertEqual(duplicatedModule.contentUrl, originalModule.contentUrl)
            XCTAssertEqual(duplicatedModule.duration, originalModule.duration)
        }
    }
    
    func test_duplicateCourse_shouldUpdateTimestamps() async throws {
        // Given
        let beforeDuplication = Date()
        
        // When
        let duplicatedCourse = try await mockCourseService.duplicateCourse(originalCourse.id)
        
        // Then
        XCTAssertGreaterThanOrEqual(duplicatedCourse.createdAt, beforeDuplication)
        XCTAssertGreaterThanOrEqual(duplicatedCourse.updatedAt, beforeDuplication)
        XCTAssertEqual(duplicatedCourse.createdAt, duplicatedCourse.updatedAt)
    }
    
    func test_duplicateCourse_withNonexistentId_shouldThrowError() async {
        // Given
        let nonexistentId = UUID()
        
        // When/Then
        do {
            _ = try await mockCourseService.duplicateCourse(nonexistentId)
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertEqual(error as? CourseError, .courseNotFound)
        }
    }
    
    func test_duplicateCourse_shouldPreserveOriginalCourse() async throws {
        // Given
        let originalTitle = originalCourse.title
        let originalStatus = originalCourse.status
        let originalCreatedAt = originalCourse.createdAt
        
        // When
        _ = try await mockCourseService.duplicateCourse(originalCourse.id)
        
        // Then - original course unchanged
        let original = mockCourseService.courses.first { $0.id == originalCourse.id }
        XCTAssertNotNil(original)
        XCTAssertEqual(original?.title, originalTitle)
        XCTAssertEqual(original?.status, originalStatus)
        XCTAssertEqual(original?.createdAt, originalCreatedAt)
    }
    
    // MARK: - UI Integration Tests
    
    func test_duplicateButton_shouldBeAvailableInMenu() {
        // This would be tested in UI tests
        // Checking that duplicate option exists in course detail menu
    }
}

// MARK: - CourseManagementViewModel Tests

final class CourseManagementViewModelDuplicationTests: XCTestCase {
    
    var viewModel: CourseManagementViewModel!
    var mockService: MockCourseService!
    
    override func setUp() {
        super.setUp()
        mockService = MockCourseService()
        viewModel = CourseManagementViewModel(courseService: mockService)
        
        // Add test course
        let course = ManagedCourse(
            title: "Test Course",
            description: "Test",
            duration: 30,
            status: .published
        )
        mockService.courses.append(course)
        viewModel.loadCourses()
    }
    
    func test_duplicateCourse_shouldAddNewCourseToList() async throws {
        // Given
        let originalCourse = viewModel.courses.first!
        let originalCount = viewModel.courses.count
        
        // When
        try await viewModel.duplicateCourse(originalCourse.id)
        
        // Then
        XCTAssertEqual(viewModel.courses.count, originalCount + 1)
        XCTAssertTrue(viewModel.courses.contains { $0.title == "Test Course (копия)" })
    }
    
    func test_duplicateCourse_shouldShowSuccessMessage() async throws {
        // Given
        let originalCourse = viewModel.courses.first!
        
        // When
        try await viewModel.duplicateCourse(originalCourse.id)
        
        // Then
        XCTAssertNotNil(viewModel.successMessage)
        XCTAssertTrue(viewModel.successMessage?.contains("успешно дублирован") ?? false)
    }
    
    func test_duplicateCourse_withError_shouldShowErrorMessage() async {
        // Given
        let nonexistentId = UUID()
        
        // When
        do {
            try await viewModel.duplicateCourse(nonexistentId)
        } catch {
            // Expected
        }
        
        // Then
        XCTAssertNotNil(viewModel.errorMessage)
    }
} 