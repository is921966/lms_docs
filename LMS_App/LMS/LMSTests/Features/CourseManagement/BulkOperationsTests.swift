//
//  BulkOperationsTests.swift
//  LMSTests
//
//  Testing bulk operations functionality for courses
//

import XCTest
@testable import LMS

final class BulkOperationsTests: XCTestCase {
    
    var viewModel: CourseManagementViewModel!
    var mockService: MockCourseService!
    
    override func setUp() {
        super.setUp()
        
        mockService = MockCourseService()
        viewModel = CourseManagementViewModel(courseService: mockService)
    }
    
    override func tearDown() {
        viewModel = nil
        mockService = nil
        super.tearDown()
    }
    
    // MARK: - Selection Tests
    
    func testSelectCourse() {
        // Given
        let courseId = UUID()
        
        // When
        viewModel.toggleCourseSelection(courseId)
        
        // Then
        XCTAssertTrue(viewModel.selectedCourseIds.contains(courseId))
        XCTAssertEqual(viewModel.selectedCourseIds.count, 1)
    }
    
    func testDeselectCourse() {
        // Given
        let courseId = UUID()
        viewModel.toggleCourseSelection(courseId)
        
        // When
        viewModel.toggleCourseSelection(courseId)
        
        // Then
        XCTAssertFalse(viewModel.selectedCourseIds.contains(courseId))
        XCTAssertEqual(viewModel.selectedCourseIds.count, 0)
    }
    
    func testSelectMultipleCourses() {
        // Given
        let ids = [UUID(), UUID(), UUID()]
        
        // When
        ids.forEach { viewModel.toggleCourseSelection($0) }
        
        // Then
        XCTAssertEqual(viewModel.selectedCourseIds.count, 3)
        ids.forEach { id in
            XCTAssertTrue(viewModel.selectedCourseIds.contains(id))
        }
    }
    
    func testSelectAllCourses() async {
        // Given
        await viewModel.loadCourses()
        let totalCourses = viewModel.courses.count
        
        // When
        viewModel.selectAllCourses()
        
        // Then
        XCTAssertEqual(viewModel.selectedCourseIds.count, totalCourses)
        viewModel.courses.forEach { course in
            XCTAssertTrue(viewModel.selectedCourseIds.contains(course.id))
        }
    }
    
    func testDeselectAllCourses() async {
        // Given
        await viewModel.loadCourses()
        viewModel.selectAllCourses()
        
        // When
        viewModel.deselectAllCourses()
        
        // Then
        XCTAssertEqual(viewModel.selectedCourseIds.count, 0)
    }
    
    // MARK: - Bulk Delete Tests
    
    func testBulkDeleteCourses() async throws {
        // Given
        await viewModel.loadCourses()
        let initialCount = viewModel.courses.count
        let coursesToDelete = Array(viewModel.courses.prefix(2)).map { $0.id }
        coursesToDelete.forEach { viewModel.toggleCourseSelection($0) }
        
        // When
        try await viewModel.bulkDeleteSelectedCourses()
        
        // Then
        XCTAssertEqual(viewModel.courses.count, initialCount - 2)
        coursesToDelete.forEach { id in
            XCTAssertFalse(viewModel.courses.contains { $0.id == id })
        }
        XCTAssertEqual(viewModel.selectedCourseIds.count, 0)
    }
    
    func testBulkDeleteEmptySelection() async {
        // Given - no courses selected
        
        // When/Then
        do {
            try await viewModel.bulkDeleteSelectedCourses()
            XCTFail("Should throw error for empty selection")
        } catch {
            XCTAssertEqual(error.localizedDescription, "Выберите курсы для удаления")
        }
    }
    
    // MARK: - Bulk Archive Tests
    
    func testBulkArchiveCourses() async throws {
        // Given
        await viewModel.loadCourses()
        let draftCourses = viewModel.courses.filter { $0.status == .draft || $0.status == .published }
        let coursesToArchive = Array(draftCourses.prefix(2)).map { $0.id }
        coursesToArchive.forEach { viewModel.toggleCourseSelection($0) }
        
        // When
        try await viewModel.bulkArchiveSelectedCourses()
        
        // Then
        coursesToArchive.forEach { id in
            let course = viewModel.courses.first { $0.id == id }
            XCTAssertEqual(course?.status, .archived)
        }
        XCTAssertEqual(viewModel.selectedCourseIds.count, 0)
    }
    
    func testBulkArchiveAlreadyArchivedCourses() async throws {
        // Given
        await viewModel.loadCourses()
        let archivedCourse = viewModel.courses.first { $0.status == .archived }
        guard let courseId = archivedCourse?.id else {
            XCTFail("No archived course found in test data")
            return
        }
        viewModel.toggleCourseSelection(courseId)
        
        // When
        try await viewModel.bulkArchiveSelectedCourses()
        
        // Then - should remain archived
        let course = viewModel.courses.first { $0.id == courseId }
        XCTAssertEqual(course?.status, .archived)
    }
    
    // MARK: - Bulk Publish Tests
    
    func testBulkPublishCourses() async throws {
        // Given
        await viewModel.loadCourses()
        let draftCourses = viewModel.courses.filter { $0.status == .draft }
        let coursesToPublish = Array(draftCourses.prefix(2)).map { $0.id }
        coursesToPublish.forEach { viewModel.toggleCourseSelection($0) }
        
        // When
        try await viewModel.bulkPublishSelectedCourses()
        
        // Then
        coursesToPublish.forEach { id in
            let course = viewModel.courses.first { $0.id == id }
            XCTAssertEqual(course?.status, .published)
        }
        XCTAssertEqual(viewModel.selectedCourseIds.count, 0)
    }
    
    // MARK: - Bulk Assign Tests
    
    func testBulkAssignToStudents() async throws {
        // Given
        await viewModel.loadCourses()
        let courseIds = Array(viewModel.courses.prefix(2)).map { $0.id }
        courseIds.forEach { viewModel.toggleCourseSelection($0) }
        let studentIds = [UUID(), UUID(), UUID()]
        
        // When
        try await viewModel.bulkAssignSelectedCoursesToStudents(studentIds)
        
        // Then
        // Verify assignment was called for each course
        XCTAssertTrue(viewModel.successMessage?.contains("3 студентам") ?? false)
        XCTAssertEqual(viewModel.selectedCourseIds.count, 0)
    }
    
    // MARK: - UI State Tests
    
    func testBulkOperationsAvailable() {
        // Given
        viewModel.toggleCourseSelection(UUID())
        
        // Then
        XCTAssertTrue(viewModel.isBulkOperationAvailable)
        XCTAssertEqual(viewModel.selectionCount, 1)
    }
    
    func testBulkOperationsNotAvailable() {
        // Given - no selection
        
        // Then
        XCTAssertFalse(viewModel.isBulkOperationAvailable)
        XCTAssertEqual(viewModel.selectionCount, 0)
    }
    
    func testSelectionModeToggle() {
        // Given
        XCTAssertFalse(viewModel.isSelectionMode)
        
        // When
        viewModel.toggleSelectionMode()
        
        // Then
        XCTAssertTrue(viewModel.isSelectionMode)
        
        // When toggle again
        viewModel.toggleSelectionMode()
        
        // Then
        XCTAssertFalse(viewModel.isSelectionMode)
        XCTAssertEqual(viewModel.selectedCourseIds.count, 0) // Should clear selection
    }
} 