//
//  CourseFilterTests.swift
//  LMSTests
//
//  Testing course filtering functionality
//

import XCTest
@testable import LMS

final class CourseFilterTests: XCTestCase {
    
    var sut: CourseFilterViewModel!
    var mockCourses: [ManagedCourse]!
    
    override func setUp() {
        super.setUp()
        
        // Create test courses with different properties
        mockCourses = [
            ManagedCourse(
                title: "Swift Basics",
                description: "Learn Swift",
                duration: 40,
                status: .draft,
                competencies: [UUID()],
                modules: [createModule()]
            ),
            ManagedCourse(
                title: "Advanced Swift",
                description: "Advanced topics",
                duration: 80,
                status: .published,
                competencies: [UUID(), UUID()],
                modules: [createModule(), createModule()],
                cmi5PackageId: "package123" // Cmi5 course
            ),
            ManagedCourse(
                title: "UIKit Fundamentals",
                description: "UI Development",
                duration: 60,
                status: .published,
                competencies: [],
                modules: []
            ),
            ManagedCourse(
                title: "Archived Course",
                description: "Old content",
                duration: 30,
                status: .archived,
                competencies: [UUID()],
                modules: [createModule()]
            )
        ]
        
        sut = CourseFilterViewModel(courses: mockCourses)
    }
    
    override func tearDown() {
        sut = nil
        mockCourses = nil
        super.tearDown()
    }
    
    // MARK: - Status Filter Tests
    
    func test_filterByStatus_draft_shouldReturnOnlyDraftCourses() {
        // When
        sut.selectedStatus = .draft
        
        // Then
        XCTAssertEqual(sut.filteredCourses.count, 1)
        XCTAssertEqual(sut.filteredCourses.first?.title, "Swift Basics")
    }
    
    func test_filterByStatus_published_shouldReturnOnlyPublishedCourses() {
        // When
        sut.selectedStatus = .published
        
        // Then
        XCTAssertEqual(sut.filteredCourses.count, 2)
        XCTAssertTrue(sut.filteredCourses.allSatisfy { $0.status == .published })
    }
    
    func test_filterByStatus_archived_shouldReturnOnlyArchivedCourses() {
        // When
        sut.selectedStatus = .archived
        
        // Then
        XCTAssertEqual(sut.filteredCourses.count, 1)
        XCTAssertEqual(sut.filteredCourses.first?.title, "Archived Course")
    }
    
    func test_filterByStatus_nil_shouldReturnAllCourses() {
        // When
        sut.selectedStatus = nil
        
        // Then
        XCTAssertEqual(sut.filteredCourses.count, 4)
    }
    
    // MARK: - Type Filter Tests
    
    func test_filterByType_cmi5_shouldReturnOnlyCmi5Courses() {
        // When
        sut.showOnlyCmi5 = true
        
        // Then
        XCTAssertEqual(sut.filteredCourses.count, 1)
        XCTAssertEqual(sut.filteredCourses.first?.title, "Advanced Swift")
        XCTAssertNotNil(sut.filteredCourses.first?.cmi5PackageId)
    }
    
    func test_filterByType_regular_shouldReturnOnlyRegularCourses() {
        // When
        sut.showOnlyRegular = true
        
        // Then
        XCTAssertEqual(sut.filteredCourses.count, 3)
        XCTAssertTrue(sut.filteredCourses.allSatisfy { $0.cmi5PackageId == nil })
    }
    
    // MARK: - Module Filter Tests
    
    func test_filterByModules_withModules_shouldReturnCoursesWithModules() {
        // When
        sut.showOnlyWithModules = true
        
        // Then
        XCTAssertEqual(sut.filteredCourses.count, 3)
        XCTAssertTrue(sut.filteredCourses.allSatisfy { !$0.modules.isEmpty })
    }
    
    func test_filterByModules_withoutModules_shouldReturnCoursesWithoutModules() {
        // When
        sut.showOnlyWithoutModules = true
        
        // Then
        XCTAssertEqual(sut.filteredCourses.count, 1)
        XCTAssertEqual(sut.filteredCourses.first?.title, "UIKit Fundamentals")
        XCTAssertTrue(sut.filteredCourses.first?.modules.isEmpty ?? false)
    }
    
    // MARK: - Competency Filter Tests
    
    func test_filterByCompetencies_withCompetencies_shouldReturnCoursesWithCompetencies() {
        // When
        sut.showOnlyWithCompetencies = true
        
        // Then
        XCTAssertEqual(sut.filteredCourses.count, 3)
        XCTAssertTrue(sut.filteredCourses.allSatisfy { !$0.competencies.isEmpty })
    }
    
    func test_filterByCompetencies_withoutCompetencies_shouldReturnCoursesWithoutCompetencies() {
        // When
        sut.showOnlyWithoutCompetencies = true
        
        // Then
        XCTAssertEqual(sut.filteredCourses.count, 1)
        XCTAssertEqual(sut.filteredCourses.first?.title, "UIKit Fundamentals")
        XCTAssertTrue(sut.filteredCourses.first?.competencies.isEmpty ?? false)
    }
    
    // MARK: - Combined Filter Tests
    
    func test_combinedFilters_statusAndType_shouldApplyBothFilters() {
        // When
        sut.selectedStatus = .published
        sut.showOnlyCmi5 = true
        
        // Then
        XCTAssertEqual(sut.filteredCourses.count, 1)
        XCTAssertEqual(sut.filteredCourses.first?.title, "Advanced Swift")
    }
    
    func test_combinedFilters_allFilters_shouldApplyAllFilters() {
        // When
        sut.selectedStatus = .published
        sut.showOnlyRegular = true
        sut.showOnlyWithModules = true
        sut.showOnlyWithCompetencies = true
        
        // Then
        // Only "Advanced Swift" matches all criteria (but it's Cmi5, so excluded)
        // No courses match all filters
        XCTAssertEqual(sut.filteredCourses.count, 0)
    }
    
    // MARK: - Filter State Tests
    
    func test_hasActiveFilters_withNoFilters_shouldReturnFalse() {
        // Then
        XCTAssertFalse(sut.hasActiveFilters)
    }
    
    func test_hasActiveFilters_withAnyFilter_shouldReturnTrue() {
        // When
        sut.selectedStatus = .draft
        
        // Then
        XCTAssertTrue(sut.hasActiveFilters)
    }
    
    func test_clearFilters_shouldResetAllFilters() {
        // Given
        sut.selectedStatus = .published
        sut.showOnlyCmi5 = true
        sut.showOnlyWithModules = true
        sut.showOnlyWithCompetencies = true
        
        // When
        sut.clearFilters()
        
        // Then
        XCTAssertNil(sut.selectedStatus)
        XCTAssertFalse(sut.showOnlyCmi5)
        XCTAssertFalse(sut.showOnlyRegular)
        XCTAssertFalse(sut.showOnlyWithModules)
        XCTAssertFalse(sut.showOnlyWithoutModules)
        XCTAssertFalse(sut.showOnlyWithCompetencies)
        XCTAssertFalse(sut.showOnlyWithoutCompetencies)
        XCTAssertEqual(sut.filteredCourses.count, 4)
    }
    
    func test_activeFilterCount_shouldReturnCorrectCount() {
        // Given
        sut.selectedStatus = .published
        sut.showOnlyCmi5 = true
        sut.showOnlyWithModules = true
        
        // Then
        XCTAssertEqual(sut.activeFilterCount, 3)
    }
    
    // MARK: - Filter Persistence Tests
    
    func test_saveFilterState_shouldPersistFilters() {
        // Given
        sut.selectedStatus = .published
        sut.showOnlyCmi5 = true
        
        // When
        sut.saveFilterState()
        
        // Then
        // This would test UserDefaults persistence
        XCTAssertTrue(UserDefaults.standard.bool(forKey: "CourseFilter.hasState"))
    }
    
    func test_restoreFilterState_shouldRestoreFilters() {
        // Given
        sut.selectedStatus = .published
        sut.showOnlyCmi5 = true
        sut.saveFilterState()
        
        // Reset filters
        sut.clearFilters()
        XCTAssertNil(sut.selectedStatus)
        
        // When
        sut.restoreFilterState()
        
        // Then
        XCTAssertEqual(sut.selectedStatus, .published)
        XCTAssertTrue(sut.showOnlyCmi5)
    }
    
    // MARK: - Helpers
    
    private func createModule() -> ManagedCourseModule {
        ManagedCourseModule(
            id: UUID(),
            title: "Test Module",
            description: "Test",
            order: 1,
            contentType: .video,
            contentUrl: nil,
            duration: 30
        )
    }
}

// MARK: - Filter State Tests

final class CourseFilterStateTests: XCTestCase {
    
    func test_filterState_encoding_shouldEncodeAllProperties() throws {
        // Given
        let state = CourseFilterState(
            selectedStatus: .published,
            showOnlyCmi5: true,
            showOnlyRegular: false,
            showOnlyWithModules: true,
            showOnlyWithoutModules: false,
            showOnlyWithCompetencies: true,
            showOnlyWithoutCompetencies: false
        )
        
        // When
        let encoded = try JSONEncoder().encode(state)
        let decoded = try JSONDecoder().decode(CourseFilterState.self, from: encoded)
        
        // Then
        XCTAssertEqual(decoded.selectedStatus, .published)
        XCTAssertEqual(decoded.showOnlyCmi5, true)
        XCTAssertEqual(decoded.showOnlyWithModules, true)
        XCTAssertEqual(decoded.showOnlyWithCompetencies, true)
    }
} 