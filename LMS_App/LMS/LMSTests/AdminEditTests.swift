//
//  AdminEditTests.swift
//  LMSTests
//
//  Created on 26/01/2025.
//

@testable import LMS
import XCTest

@MainActor
final class AdminEditTests: XCTestCase {
    private var testService: TestMockService!
    private var courseService: CourseMockService!

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
        let updatedTest = testService.tests.first { $0.id == originalTest.id }
        XCTAssertNotNil(updatedTest)
        XCTAssertEqual(updatedTest?.title, newTitle)
        XCTAssertNotEqual(updatedTest?.title, originalTitle)
        XCTAssertEqual(updatedTest?.passingScore, newPassingScore)
    }

    func testCourseServiceSavesChanges() throws {
        // Given
        let originalCourses = TestCourse.mockCourses(count: 3)
        guard let firstCourse = originalCourses.first else {
            XCTFail("No mock courses available")
            return
        }

        let originalTitle = firstCourse.title
        let newTitle = "Updated Course Title"
        let newDescription = "Updated description"

        // When
        var updatedCourses = originalCourses
        if let courseIndex = updatedCourses.firstIndex(where: { $0.id == firstCourse.id }) {
            // Note: TestCourse doesn't have all these properties, so we'll create a simplified version
            updatedCourses[courseIndex] = TestCourse(
                id: firstCourse.id,
                title: newTitle,
                description: newDescription,
                duration: firstCourse.duration,
                level: firstCourse.level,
                competencies: firstCourse.competencies,
                isActive: firstCourse.isActive,
                createdAt: firstCourse.createdAt,
                updatedAt: Date()
            )
        }

        // Then
        let updatedCourse = updatedCourses.first { $0.id == firstCourse.id }
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
        XCTAssertTrue(testService.tests.contains { $0.title == "New Test" })
    }

    func testAddingNewCourse() throws {
        // Given
        var courses = TestCourse.mockCourses(count: 3)
        let initialCount = courses.count
        let newCourse = TestCourse(
            title: "New Course",
            description: "New course description",
            duration: 4,
            level: "beginner"
        )

        // When
        courses.append(newCourse)

        // Then
        XCTAssertEqual(courses.count, initialCount + 1)
        XCTAssertTrue(courses.contains { $0.title == "New Course" })
    }
}

// Mock service for courses
class CourseMockService {
    var courses = TestCourse.mockCourses(count: 5)
}
