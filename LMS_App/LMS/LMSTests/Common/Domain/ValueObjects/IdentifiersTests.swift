//
//  IdentifiersTests.swift
//  LMSTests
//
//  Created by AI Assistant on 01/31/25.
//
//  Copyright © 2025 LMS. All rights reserved.
//

import XCTest
@testable import LMS

final class IdentifiersTests: XCTestCase {
    
    // MARK: - CourseId Tests
    
    func testCourseIdValidation() {
        // Valid IDs
        XCTAssertNotNil(CourseId("COURSE_123"))
        XCTAssertNotNil(CourseId("COURSE_ABC-123_XYZ"))
        XCTAssertNotNil(CourseId("COURSE_verylongidentifier123456789"))
        
        // Invalid IDs
        XCTAssertNil(CourseId(""))
        XCTAssertNil(CourseId("123")) // Missing prefix
        XCTAssertNil(CourseId("LESSON_123")) // Wrong prefix
        XCTAssertNil(CourseId("COURSE_")) // Too short after prefix
        XCTAssertNil(CourseId("COURSE_abc@123")) // Invalid character
        XCTAssertNil(CourseId("COURSE_" + String(repeating: "a", 50))) // Too long
    }
    
    func testCourseIdGeneration() {
        let id1 = CourseId.generate()
        let id2 = CourseId.generate()
        
        // Generated IDs should be valid
        XCTAssertTrue(CourseId.isValid(id1.value))
        XCTAssertTrue(CourseId.isValid(id2.value))
        
        // Generated IDs should be unique
        XCTAssertNotEqual(id1, id2)
        
        // Generated IDs should have correct prefix
        XCTAssertTrue(id1.value.hasPrefix("COURSE_"))
        XCTAssertTrue(id2.value.hasPrefix("COURSE_"))
    }
    
    func testCourseIdEquality() {
        let id1 = CourseId("COURSE_123")!
        let id2 = CourseId("COURSE_123")!
        let id3 = CourseId("COURSE_456")!
        
        XCTAssertEqual(id1, id2)
        XCTAssertNotEqual(id1, id3)
    }
    
    // MARK: - LessonId Tests
    
    func testLessonIdValidation() {
        // Valid IDs
        XCTAssertNotNil(LessonId("LESSON_123"))
        XCTAssertNotNil(LessonId("LESSON_ABC-123_XYZ"))
        
        // Invalid IDs
        XCTAssertNil(LessonId("COURSE_123")) // Wrong prefix
        XCTAssertNil(LessonId("LESSON_")) // Too short
    }
    
    func testLessonIdGeneration() {
        let id = LessonId.generate()
        
        XCTAssertTrue(LessonId.isValid(id.value))
        XCTAssertTrue(id.value.hasPrefix("LESSON_"))
    }
    
    // MARK: - TestId Tests
    
    func testTestIdValidation() {
        // Valid IDs
        XCTAssertNotNil(TestId("TEST_123"))
        XCTAssertNotNil(TestId("TEST_ABC-123_XYZ"))
        
        // Invalid IDs
        XCTAssertNil(TestId("QUIZ_123")) // Wrong prefix
        XCTAssertNil(TestId("TEST_")) // Too short
    }
    
    func testTestIdGeneration() {
        let id = TestId.generate()
        
        XCTAssertTrue(TestId.isValid(id.value))
        XCTAssertTrue(id.value.hasPrefix("TEST_"))
    }
    
    // MARK: - UserId Tests
    
    func testUserIdValidation() {
        // Valid IDs
        XCTAssertNotNil(UserId("USER_123"))
        XCTAssertNotNil(UserId("USER_john-doe-123"))
        
        // Invalid IDs
        XCTAssertNil(UserId("STUDENT_123")) // Wrong prefix
        XCTAssertNil(UserId("USER_")) // Too short
    }
    
    func testUserIdGeneration() {
        let id = UserId.generate()
        
        XCTAssertTrue(UserId.isValid(id.value))
        XCTAssertTrue(id.value.hasPrefix("USER_"))
    }
    
    // MARK: - CompetencyId Tests
    
    func testCompetencyIdValidation() {
        // Valid IDs
        XCTAssertNotNil(CompetencyId("COMP_123"))
        XCTAssertNotNil(CompetencyId("COMP_skill-123"))
        
        // Invalid IDs
        XCTAssertNil(CompetencyId("SKILL_123")) // Wrong prefix
        XCTAssertNil(CompetencyId("COMP_")) // Too short
    }
    
    func testCompetencyIdGeneration() {
        let id = CompetencyId.generate()
        
        XCTAssertTrue(CompetencyId.isValid(id.value))
        XCTAssertTrue(id.value.hasPrefix("COMP_"))
    }
    
    // MARK: - PositionId Tests
    
    func testPositionIdValidation() {
        // Valid IDs
        XCTAssertNotNil(PositionId("POS_123"))
        XCTAssertNotNil(PositionId("POS_manager-123"))
        
        // Invalid IDs
        XCTAssertNil(PositionId("POSITION_123")) // Wrong prefix
        XCTAssertNil(PositionId("POS_")) // Too short
    }
    
    func testPositionIdGeneration() {
        let id = PositionId.generate()
        
        XCTAssertTrue(PositionId.isValid(id.value))
        XCTAssertTrue(id.value.hasPrefix("POS_"))
    }
    
    // MARK: - Cross-Type Tests
    
    func testDifferentIdentifierTypesAreNotEqual() {
        // Even with same value after prefix, different types should not be equal
        let courseId = CourseId("COURSE_123")!
        let lessonId = LessonId("LESSON_123")!
        
        // This should not compile due to type safety
        // XCTAssertNotEqual(courseId, lessonId) // Compilation error - good!
        
        // Values are different due to prefixes
        XCTAssertNotEqual(courseId.value, lessonId.value)
    }
    
    func testIdentifierHashability() {
        let id1 = CourseId("COURSE_123")!
        let id2 = CourseId("COURSE_123")!
        let id3 = CourseId("COURSE_456")!
        
        var set = Set<CourseId>()
        set.insert(id1)
        set.insert(id2)
        set.insert(id3)
        
        // id1 and id2 are equal, so set should contain only 2 elements
        XCTAssertEqual(set.count, 2)
        XCTAssertTrue(set.contains(id1))
        XCTAssertTrue(set.contains(id3))
    }
    
    func testIdentifierCodability() throws {
        let originalId = CourseId("COURSE_123")!
        
        // Encode
        let encoder = JSONEncoder()
        let data = try encoder.encode(originalId)
        
        // Decode
        let decoder = JSONDecoder()
        let decodedId = try decoder.decode(CourseId.self, from: data)
        
        XCTAssertEqual(originalId, decodedId)
    }
} 