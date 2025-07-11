//
//  TestBuildersExampleTests.swift
//  LMSTests
//
//  Created by AI Assistant on 03/07/2025.
//  Sprint 28: Examples of Test Builders Usage
//

import XCTest
@testable import LMS

class TestBuildersExampleTests: XCTestCase {
    
    // MARK: - User Builder Examples
    
    func testAdminCanManageAllUsers() {
        // Given - Using builders makes test setup clear and concise
        let admin = UserBuilder().asAdmin().build()
        let student = UserBuilder().asStudent().build()
        let instructor = UserBuilder().asInstructor().build()
        let inactiveUser = UserBuilder().asStudent().inactive().build()
        
        // When
        let authService = AuthService()
        
        // Then
        XCTAssertTrue(authService.canManageUser(admin, target: student))
        XCTAssertTrue(authService.canManageUser(admin, target: instructor))
        XCTAssertTrue(authService.canManageUser(admin, target: inactiveUser))
    }
    
    func testStudentCannotManageOtherUsers() {
        // Given
        let student1 = UserBuilder().asStudent().withId("STU001").build()
        let student2 = UserBuilder().asStudent().withId("STU002").build()
        let instructor = UserBuilder().asInstructor().build()
        
        // When
        let authService = AuthService()
        
        // Then
        XCTAssertFalse(authService.canManageUser(student1, target: student2))
        XCTAssertFalse(authService.canManageUser(student1, target: instructor))
    }
    
    func testInstructorCanManageStudentsInTheirCourses() {
        // Given
        let instructor = UserBuilder()
            .asInstructor()
            .withId("INST001")
            .withName("Dr. Smith")
            .build()
        
        let enrolledStudent = UserBuilder()
            .asStudent()
            .withId("STU001")
            .withName("John Doe")
            .build()
        
        let otherStudent = UserBuilder()
            .asStudent()
            .withId("STU002")
            .withName("Jane Doe")
            .build()
        
        // When - Assume instructor teaches a course with enrolledStudent
        let authService = AuthService()
        authService.setInstructorCourses(instructorId: instructor.id, studentIds: [enrolledStudent.id])
        
        // Then
        XCTAssertTrue(authService.canManageUser(instructor, target: enrolledStudent))
        XCTAssertFalse(authService.canManageUser(instructor, target: otherStudent))
    }
    
    // MARK: - Course Builder Examples
    
    func testStudentCannotEnrollInFullCourse() {
        // Given
        let fullCourse = CourseBuilder()
            .withTitle("Popular iOS Course")
            .asProgrammingCourse()
            .full()
            .build()
        
        let student = UserBuilder().asStudent().build()
        
        // When
        let enrollmentService = CourseEnrollmentService()
        let result = enrollmentService.enroll(student: student, in: fullCourse)
        
        // Then
        XCTAssertFalse(result.success)
        XCTAssertEqual(result.error, .courseFull)
    }
    
    func testStudentCanEnrollInAvailableCourse() {
        // Given
        let availableCourse = CourseBuilder()
            .withTitle("Swift Fundamentals")
            .asProgrammingCourse()
            .beginner()
            .withMaxStudents(30)
            .withCurrentStudents(15)
            .build()
        
        let student = UserBuilder().asStudent().active().build()
        
        // When
        let enrollmentService = CourseEnrollmentService()
        let result = enrollmentService.enroll(student: student, in: availableCourse)
        
        // Then
        XCTAssertTrue(result.success)
        XCTAssertNil(result.error)
    }
    
    func testInactiveStudentCannotEnroll() {
        // Given
        let course = CourseBuilder.beginnerCourse()  // Using factory method instead
        let inactiveStudent = UserBuilder()
            .asStudent()
            .inactive()
            .build()
        
        // When
        let enrollmentService = CourseEnrollmentService()
        let result = enrollmentService.enroll(student: inactiveStudent, in: course)
        
        // Then
        XCTAssertFalse(result.success)
        XCTAssertEqual(result.error, .studentInactive)
    }
    
    // MARK: - Complex Scenarios with Multiple Builders
    
    func testCourseRecommendationBasedOnLevel() {
        // Given - Create users with different experience levels
        let beginnerStudent = UserBuilder()
            .asStudent()
            .withName("Beginner Bob")
            .createdDaysAgo(7)  // New user
            .build()
        
        let intermediateStudent = UserBuilder()
            .asStudent()
            .withName("Intermediate Ivy")
            .createdDaysAgo(90)  // 3 months old
            .build()
        
        let advancedStudent = UserBuilder()
            .asStudent()
            .withName("Advanced Alice")
            .createdDaysAgo(365)  // 1 year old
            .build()
        
        // Create courses of different levels
        let beginnerCourse = CourseBuilder()
            .withTitle("Introduction to Programming")
            .asProgrammingCourse()
            .beginner()
            .build()
        
        let intermediateCourse = CourseBuilder()
            .withTitle("Advanced Swift Patterns")
            .asProgrammingCourse()
            .intermediate()
            .build()
        
        let advancedCourse = CourseBuilder()
            .withTitle("System Architecture")
            .asProgrammingCourse()
            .advanced()
            .build()
        
        // When
        let recommendationService = CourseRecommendationService()
        
        // Then
        XCTAssertTrue(recommendationService.isRecommended(beginnerCourse, for: beginnerStudent))
        XCTAssertFalse(recommendationService.isRecommended(advancedCourse, for: beginnerStudent))
        
        XCTAssertTrue(recommendationService.isRecommended(intermediateCourse, for: intermediateStudent))
        XCTAssertTrue(recommendationService.isRecommended(advancedCourse, for: advancedStudent))
    }
    
    // MARK: - Batch Creation Example
    
    func testBulkUserCreation() {
        // Given - Create multiple users with similar properties
        let students = UserBuilder.createMultiple(count: 10) { builder in
            builder.asStudent()
                .withDepartment("Computer Science")
                .active()
        }
        
        let instructors = UserBuilder.createMultiple(count: 3) { builder in
            builder.asInstructor()
                .withDepartment("Engineering")
        }
        
        // When
        let userService = UserService()
        let importResult = userService.bulkImport(users: students + instructors)
        
        // Then
        XCTAssertEqual(importResult.successCount, 13)
        XCTAssertEqual(importResult.failureCount, 0)
        XCTAssertEqual(importResult.studentCount, 10)
        XCTAssertEqual(importResult.instructorCount, 3)
    }
    
    func testCourseCapacityScenarios() {
        // Given - Create courses with different capacity scenarios
        let courses = [
            CourseBuilder.beginnerCourse(),  // Using factory method
            CourseBuilder.advancedCourse(),   // Using factory method
            CourseBuilder.inactiveCourse(),   // Using factory method
            CourseBuilder().withDuration(100).build()
        ]
        
        // When/Then
        XCTAssertEqual(courses[0].enrollmentPercentage, 0.0)
        XCTAssertTrue(courses[1].availableSeats > 0)
        XCTAssertFalse(courses[2].isActive)
        XCTAssertEqual(courses[3].duration, 100)
    }
    
    // MARK: - Using CourseBuilder
    
    func testCourseBuilderBasicUsage() {
        // Create a simple course
        let course: TestCourse = CourseBuilder()
            .withTitle("iOS Development")
            .withDescription("Learn to build iOS apps")
            .withDuration(40)
            .build()
        
        XCTAssertEqual(course.title, "iOS Development")
        XCTAssertEqual(course.duration, 40)
    }
    
    func testCourseBuilderWithCompetencies() {
        // Create a course with specific competencies
        let course: TestCourse = CourseBuilder()
            .withTitle("Advanced Swift")
            .withLevel("advanced")
            .withCompetencies(["swift-advanced", "ios-architecture", "performance"])
            .withDuration(60)
            .build()
        
        XCTAssertEqual(course.level, "advanced")
        XCTAssertEqual(course.competencies.count, 3)
        XCTAssertTrue(course.competencies.contains("ios-architecture"))
    }
}

// MARK: - Mock Services for Examples
// These would normally be in separate files

extension TestBuildersExampleTests {
    
    class AuthService {
        private var instructorCourses: [String: [String]] = [:]
        
        func canManageUser(_ manager: UserResponse, target: UserResponse) -> Bool {
            // Admin can manage everyone
            if manager.role == .admin {
                return true
            }
            
            // Instructor can manage their students
            if manager.role == .instructor {
                if let studentIds = instructorCourses[manager.id] {
                    return studentIds.contains(target.id)
                }
            }
            
            // Others cannot manage
            return false
        }
        
        func setInstructorCourses(instructorId: String, studentIds: [String]) {
            instructorCourses[instructorId] = studentIds
        }
    }
    
    class CourseEnrollmentService {
        enum EnrollmentError: Equatable {
            case courseFull
            case studentInactive
            case alreadyEnrolled
        }
        
        struct EnrollmentResult {
            let success: Bool
            let error: EnrollmentError?
        }
        
        func enroll(student: UserResponse, in course: TestCourse) -> EnrollmentResult {
            // Check if student is active
            guard student.isActive else {
                return EnrollmentResult(success: false, error: .studentInactive)
            }
            
            // Check if course has space
            guard !course.isFull else {
                return EnrollmentResult(success: false, error: .courseFull)
            }
            
            // Success
            return EnrollmentResult(success: true, error: nil)
        }
    }
    
    class CourseRecommendationService {
        func isRecommended(_ course: TestCourse, for student: UserResponse) -> Bool {
            // Simple logic based on account age
            let accountAge = Calendar.current.dateComponents([.day], from: student.createdAt, to: Date()).day ?? 0
            
            switch course.level {
            case "beginner":
                return accountAge < 30
            case "intermediate":
                return accountAge >= 30 && accountAge < 180
            case "advanced":
                return accountAge >= 180
            default:
                return true
            }
        }
    }
    
    class UserService {
        struct BulkImportResult {
            let successCount: Int
            let failureCount: Int
            let studentCount: Int
            let instructorCount: Int
        }
        
        func bulkImport(users: [UserResponse]) -> BulkImportResult {
            let studentCount = users.filter { $0.role == .student }.count
            let instructorCount = users.filter { $0.role == .instructor }.count
            
            return BulkImportResult(
                successCount: users.count,
                failureCount: 0,
                studentCount: studentCount,
                instructorCount: instructorCount
            )
        }
    }
} 