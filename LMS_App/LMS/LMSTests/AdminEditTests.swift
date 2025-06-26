//
//  AdminEditTests.swift
//  LMSTests
//
//  Created on 26/01/2025.
//

import XCTest
@testable import LMS

final class AdminEditTests: XCTestCase {
    
    var testService: TestMockService!
    var courseService: CourseMockService!
    
    override func setUpWithError() throws {
        testService = TestMockService()
        courseService = CourseMockService()
    }
    
    override func tearDownWithError() throws {
        testService = nil
        courseService = nil
    }
    
    func testTestServiceSavesChanges() throws {
        // Given
        let originalTest = testService.tests.first!
        let originalTitle = originalTest.title
        let newTitle = "Updated Test Title"
        let newPassingScore = 85.0
        
        // When
        if let testIndex = testService.tests.firstIndex(where: { $0.id == originalTest.id }) {
            testService.tests[testIndex] = Test(
                id: originalTest.id,
                title: newTitle,
                description: originalTest.description,
                type: originalTest.type,
                status: originalTest.status,
                difficulty: originalTest.difficulty,
                questions: originalTest.questions,
                timeLimit: originalTest.timeLimit,
                attemptsAllowed: originalTest.attemptsAllowed,
                passingScore: newPassingScore,
                createdBy: originalTest.createdBy,
                createdAt: originalTest.createdAt,
                updatedAt: Date()
            )
        }
        
        // Then
        let updatedTest = testService.tests.first(where: { $0.id == originalTest.id })
        XCTAssertNotNil(updatedTest)
        XCTAssertEqual(updatedTest?.title, newTitle)
        XCTAssertNotEqual(updatedTest?.title, originalTitle)
        XCTAssertEqual(updatedTest?.passingScore, newPassingScore)
    }
    
    func testCourseServiceSavesChanges() throws {
        // Given
        let originalCourses = Course.mockCourses
        guard let firstCourse = originalCourses.first else {
            XCTFail("No mock courses available")
            return
        }
        
        let originalTitle = firstCourse.title
        let newTitle = "Updated Course Title"
        let newDescription = "Updated description"
        
        // When
        if let courseIndex = Course.mockCourses.firstIndex(where: { $0.id == firstCourse.id }) {
            Course.mockCourses[courseIndex] = Course(
                title: newTitle,
                description: newDescription,
                progress: firstCourse.progress,
                icon: firstCourse.icon,
                color: firstCourse.color,
                duration: firstCourse.duration,
                modules: firstCourse.modules
            )
        }
        
        // Then
        let updatedCourse = Course.mockCourses.first(where: { $0.title == newTitle })
        XCTAssertNotNil(updatedCourse)
        XCTAssertEqual(updatedCourse?.title, newTitle)
        XCTAssertEqual(updatedCourse?.description, newDescription)
        XCTAssertNotEqual(updatedCourse?.title, originalTitle)
    }
    
    func testAddingNewTest() throws {
        // Given
        let initialCount = testService.tests.count
        let newTest = Test(
            title: "New Test",
            description: "New test description",
            type: .quiz,
            difficulty: .easy,
            questions: [],
            passingScore: 70.0,
            createdBy: "Admin"
        )
        
        // When
        testService.tests.append(newTest)
        
        // Then
        XCTAssertEqual(testService.tests.count, initialCount + 1)
        XCTAssertTrue(testService.tests.contains(where: { $0.title == "New Test" }))
    }
    
    func testAddingNewCourse() throws {
        // Given
        let initialCount = Course.mockCourses.count
        let newCourse = Course(
            title: "New Course",
            description: "New course description",
            progress: 0.0,
            icon: "book.fill",
            color: .blue,
            duration: "4 часа",
            modules: []
        )
        
        // When
        Course.mockCourses.append(newCourse)
        
        // Then
        XCTAssertEqual(Course.mockCourses.count, initialCount + 1)
        XCTAssertTrue(Course.mockCourses.contains(where: { $0.title == "New Course" }))
    }
}

// Mock service for courses
class CourseMockService {
    var courses = Course.mockCourses
} 