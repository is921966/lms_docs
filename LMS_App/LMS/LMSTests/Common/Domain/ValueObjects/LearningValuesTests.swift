//
//  LearningValuesTests.swift
//  LMSTests
//
//  Created by AI Assistant on 01/31/25.
//
//  Copyright © 2025 LMS. All rights reserved.
//

import XCTest
@testable import LMS

final class LearningValuesTests: XCTestCase {
    
    // MARK: - CourseProgress Tests
    
    func testCourseProgressValidation() {
        // Valid progress values
        XCTAssertNotNil(CourseProgress(0.0))
        XCTAssertNotNil(CourseProgress(50.0))
        XCTAssertNotNil(CourseProgress(100.0))
        XCTAssertNotNil(CourseProgress(33.33))
        
        // Invalid progress values
        XCTAssertNil(CourseProgress(-1.0))
        XCTAssertNil(CourseProgress(101.0))
        XCTAssertNil(CourseProgress(150.0))
    }
    
    func testCourseProgressCreation() {
        // From percentage
        let progress1 = CourseProgress.percentage(75.0)
        XCTAssertEqual(progress1?.value, 75.0)
        
        // From fraction
        let progress2 = CourseProgress.fraction(0.5)
        XCTAssertEqual(progress2?.value, 50.0)
        
        let progress3 = CourseProgress.fraction(0.333)
        XCTAssertEqual(progress3?.value ?? 0, 33.3, accuracy: 0.01)
    }
    
    func testCourseProgressFormatting() {
        let progress1 = CourseProgress(75.5)!
        XCTAssertEqual(progress1.formatted, "76%")
        
        let progress2 = CourseProgress(33.33)!
        XCTAssertEqual(progress2.formatted, "33%")
        
        let progress3 = CourseProgress(100.0)!
        XCTAssertEqual(progress3.formatted, "100%")
    }
    
    func testCourseProgressStatus() {
        let notStarted = CourseProgress(0.0)!
        XCTAssertFalse(notStarted.hasStarted)
        XCTAssertFalse(notStarted.isInProgress)
        XCTAssertFalse(notStarted.isCompleted)
        
        let inProgress = CourseProgress(50.0)!
        XCTAssertTrue(inProgress.hasStarted)
        XCTAssertTrue(inProgress.isInProgress)
        XCTAssertFalse(inProgress.isCompleted)
        
        let completed = CourseProgress(100.0)!
        XCTAssertTrue(completed.hasStarted)
        XCTAssertFalse(completed.isInProgress)
        XCTAssertTrue(completed.isCompleted)
    }
    
    func testCourseProgressFraction() {
        let progress = CourseProgress(75.0)!
        XCTAssertEqual(progress.fraction, 0.75, accuracy: 0.001)
    }
    
    // MARK: - CompetencyLevel Tests
    
    func testCompetencyLevelOrdering() {
        XCTAssertTrue(CompetencyLevelValue.expert.isHigherThan(.advanced))
        XCTAssertTrue(CompetencyLevelValue.advanced.isHigherThan(.intermediate))
        XCTAssertTrue(CompetencyLevelValue.intermediate.isHigherThan(.beginner))
        XCTAssertTrue(CompetencyLevelValue.beginner.isHigherThan(.novice))
        
        XCTAssertFalse(CompetencyLevelValue.novice.isHigherThan(.beginner))
        XCTAssertFalse(CompetencyLevelValue.intermediate.isHigherThan(.intermediate))
    }
    
    func testCompetencyLevelNumericValues() {
        XCTAssertEqual(CompetencyLevelValue.novice.numericValue, 1)
        XCTAssertEqual(CompetencyLevelValue.beginner.numericValue, 2)
        XCTAssertEqual(CompetencyLevelValue.intermediate.numericValue, 3)
        XCTAssertEqual(CompetencyLevelValue.advanced.numericValue, 4)
        XCTAssertEqual(CompetencyLevelValue.expert.numericValue, 5)
    }
    
    func testCompetencyLevelProgression() {
        XCTAssertEqual(CompetencyLevelValue.novice.nextLevel, .beginner)
        XCTAssertEqual(CompetencyLevelValue.beginner.nextLevel, .intermediate)
        XCTAssertEqual(CompetencyLevelValue.intermediate.nextLevel, .advanced)
        XCTAssertEqual(CompetencyLevelValue.advanced.nextLevel, .expert)
        XCTAssertNil(CompetencyLevelValue.expert.nextLevel)
    }
    
    func testCompetencyLevelDisplayNames() {
        XCTAssertEqual(CompetencyLevelValue.novice.displayName, "Новичок")
        XCTAssertEqual(CompetencyLevelValue.beginner.displayName, "Начинающий")
        XCTAssertEqual(CompetencyLevelValue.intermediate.displayName, "Средний")
        XCTAssertEqual(CompetencyLevelValue.advanced.displayName, "Продвинутый")
        XCTAssertEqual(CompetencyLevelValue.expert.displayName, "Эксперт")
    }
    
    func testCompetencyLevelRequiredProgress() {
        XCTAssertEqual(CompetencyLevelValue.novice.requiredProgress, 0.0)
        XCTAssertEqual(CompetencyLevelValue.beginner.requiredProgress, 20.0)
        XCTAssertEqual(CompetencyLevelValue.intermediate.requiredProgress, 40.0)
        XCTAssertEqual(CompetencyLevelValue.advanced.requiredProgress, 70.0)
        XCTAssertEqual(CompetencyLevelValue.expert.requiredProgress, 90.0)
    }
    
    // MARK: - CourseDuration Tests
    
    func testCourseDurationValidation() {
        // Valid durations
        XCTAssertNotNil(CourseDuration(1))
        XCTAssertNotNil(CourseDuration(60))
        XCTAssertNotNil(CourseDuration(1440)) // 1 day
        XCTAssertNotNil(CourseDuration(10080)) // 1 week
        
        // Invalid durations
        XCTAssertNil(CourseDuration(0))
        XCTAssertNil(CourseDuration(-10))
        XCTAssertNil(CourseDuration(10081)) // Over 1 week
    }
    
    func testCourseDurationCreation() {
        // From hours
        let duration1 = CourseDuration.hours(2)
        XCTAssertEqual(duration1?.value, 120)
        
        // From days
        let duration2 = CourseDuration.days(3)
        XCTAssertEqual(duration2?.value, 4320)
    }
    
    func testCourseDurationConversions() {
        let duration = CourseDuration(150)! // 2.5 hours
        XCTAssertEqual(duration.hours, 2.5, accuracy: 0.01)
        XCTAssertEqual(duration.days, 0.104, accuracy: 0.001)
    }
    
    func testCourseDurationFormatting() {
        // Minutes only
        let duration1 = CourseDuration(45)!
        XCTAssertEqual(duration1.formatted, "45 мин")
        
        // Hours only
        let duration2 = CourseDuration(120)!
        XCTAssertEqual(duration2.formatted, "2 ч")
        
        // Hours and minutes
        let duration3 = CourseDuration(150)!
        XCTAssertEqual(duration3.formatted, "2 ч 30 мин")
        
        // Days only
        let duration4 = CourseDuration(1440)!
        XCTAssertEqual(duration4.formatted, "1 дн")
        
        // Days and hours
        let duration5 = CourseDuration(1560)!
        XCTAssertEqual(duration5.formatted, "1 дн 2 ч")
    }
    
    // MARK: - TestScore Tests
    
    func testTestScoreValidation() {
        // Valid scores
        XCTAssertNotNil(TestScore(0))
        XCTAssertNotNil(TestScore(50))
        XCTAssertNotNil(TestScore(100))
        
        // Invalid scores
        XCTAssertNil(TestScore(-1))
        XCTAssertNil(TestScore(101))
    }
    
    func testTestScorePassing() {
        let score1 = TestScore(85)!
        XCTAssertTrue(score1.isPassing()) // Default threshold 80%
        XCTAssertTrue(score1.isPassing(threshold: 80))
        XCTAssertFalse(score1.isPassing(threshold: 90))
        
        let score2 = TestScore(75)!
        XCTAssertFalse(score2.isPassing()) // Below default 80%
        XCTAssertTrue(score2.isPassing(threshold: 70))
    }
    
    func testTestScoreGrades() {
        XCTAssertEqual(TestScore(95)!.grade, "A")
        XCTAssertEqual(TestScore(90)!.grade, "A")
        XCTAssertEqual(TestScore(85)!.grade, "B")
        XCTAssertEqual(TestScore(80)!.grade, "B")
        XCTAssertEqual(TestScore(75)!.grade, "C")
        XCTAssertEqual(TestScore(70)!.grade, "C")
        XCTAssertEqual(TestScore(65)!.grade, "D")
        XCTAssertEqual(TestScore(60)!.grade, "D")
        XCTAssertEqual(TestScore(55)!.grade, "F")
        XCTAssertEqual(TestScore(0)!.grade, "F")
    }
    
    func testTestScoreFormatting() {
        let score = TestScore(87)!
        XCTAssertEqual(score.formatted, "87%")
    }
    
    // MARK: - EnrollmentStatus Tests
    
    func testEnrollmentStatusAccess() {
        XCTAssertFalse(EnrollmentStatus.pending.allowsAccess)
        XCTAssertTrue(EnrollmentStatus.active.allowsAccess)
        XCTAssertTrue(EnrollmentStatus.completed.allowsAccess)
        XCTAssertFalse(EnrollmentStatus.cancelled.allowsAccess)
        XCTAssertFalse(EnrollmentStatus.expired.allowsAccess)
    }
    
    func testEnrollmentStatusDisplayNames() {
        XCTAssertEqual(EnrollmentStatus.pending.displayName, "Ожидает одобрения")
        XCTAssertEqual(EnrollmentStatus.active.displayName, "Активен")
        XCTAssertEqual(EnrollmentStatus.completed.displayName, "Завершен")
        XCTAssertEqual(EnrollmentStatus.cancelled.displayName, "Отменен")
        XCTAssertEqual(EnrollmentStatus.expired.displayName, "Истек")
    }
    
    func testEnrollmentStatusCodability() throws {
        let originalStatus = EnrollmentStatus.active
        
        // Encode
        let encoder = JSONEncoder()
        let data = try encoder.encode(originalStatus)
        
        // Decode
        let decoder = JSONDecoder()
        let decodedStatus = try decoder.decode(EnrollmentStatus.self, from: data)
        
        XCTAssertEqual(originalStatus, decodedStatus)
    }
    
    // MARK: - Percentage Tests
    
    func testPercentageValidation() {
        // Valid percentages
        XCTAssertNotNil(Percentage(0.0))
        XCTAssertNotNil(Percentage(50.0))
        XCTAssertNotNil(Percentage(100.0))
        
        // Invalid percentages
        XCTAssertNil(Percentage(-1.0))
        XCTAssertNil(Percentage(101.0))
    }
    
    func testPercentageStatus() {
        let empty = Percentage(0.0)!
        XCTAssertTrue(empty.isEmpty)
        XCTAssertFalse(empty.isComplete)
        
        let partial = Percentage(50.0)!
        XCTAssertFalse(partial.isEmpty)
        XCTAssertFalse(partial.isComplete)
        
        let complete = Percentage(100.0)!
        XCTAssertFalse(complete.isEmpty)
        XCTAssertTrue(complete.isComplete)
    }
    
    func testPercentageFormatting() {
        let percentage = Percentage(75.4)!
        XCTAssertEqual(percentage.formatted, "75%")
    }
} 