//
//  CompetencyProgressCalculatorTests.swift
//  LMSTests
//
//  Created by AI Assistant on 03/07/2025.
//  Sprint 28: Parameterized Tests for Business Logic
//

import XCTest
@testable import LMS

class CompetencyProgressCalculatorTests: XCTestCase {
    
    // MARK: - Parameterized Progress Calculation Tests
    
    func testProgressCalculation() {
        // Test case structure
        struct ProgressTestCase {
            let currentLevel: Int
            let targetLevel: Int
            let completedCourses: [String]
            let requiredCourses: [String]
            let expectedProgress: Double
            let description: String
        }
        
        // Create calculator instance for these tests
        let calculator = TestCompetencyProgressCalculator()
        
        // Comprehensive test scenarios
        let testCases: [ProgressTestCase] = [
            // MARK: Basic Progress Cases
            ProgressTestCase(
                currentLevel: 1,
                targetLevel: 5,
                completedCourses: [],
                requiredCourses: ["C1", "C2", "C3", "C4"],
                expectedProgress: 0.0,
                description: "No progress - no courses completed"
            ),
            ProgressTestCase(
                currentLevel: 1,
                targetLevel: 5,
                completedCourses: ["C1", "C2"],
                requiredCourses: ["C1", "C2", "C3", "C4"],
                expectedProgress: 50.0,
                description: "Half progress - 2 of 4 courses completed"
            ),
            ProgressTestCase(
                currentLevel: 1,
                targetLevel: 5,
                completedCourses: ["C1", "C2", "C3", "C4"],
                requiredCourses: ["C1", "C2", "C3", "C4"],
                expectedProgress: 100.0,
                description: "Full progress - all courses completed"
            ),
            
            // MARK: Level-Based Progress Cases
            ProgressTestCase(
                currentLevel: 3,
                targetLevel: 5,
                completedCourses: [],
                requiredCourses: ["C1", "C2"],
                expectedProgress: 50.0,
                description: "Level progress - 3 of 5 levels achieved"
            ),
            ProgressTestCase(
                currentLevel: 5,
                targetLevel: 5,
                completedCourses: [],
                requiredCourses: [],
                expectedProgress: 100.0,
                description: "Already at target level"
            ),
            ProgressTestCase(
                currentLevel: 7,
                targetLevel: 5,
                completedCourses: [],
                requiredCourses: [],
                expectedProgress: 100.0,
                description: "Exceeded target level"
            ),
            
            // MARK: Combined Progress Cases
            ProgressTestCase(
                currentLevel: 2,
                targetLevel: 4,
                completedCourses: ["C1"],
                requiredCourses: ["C1", "C2"],
                expectedProgress: 75.0,
                description: "Combined progress - level 50% + courses 50% = 75%"
            ),
            ProgressTestCase(
                currentLevel: 1,
                targetLevel: 3,
                completedCourses: ["C1", "C2", "C3"],
                requiredCourses: ["C1", "C2"],
                expectedProgress: 100.0,
                description: "Extra courses don't exceed 100%"
            ),
            
            // MARK: Edge Cases
            ProgressTestCase(
                currentLevel: 0,
                targetLevel: 0,
                completedCourses: [],
                requiredCourses: [],
                expectedProgress: 100.0,
                description: "Zero target level"
            ),
            ProgressTestCase(
                currentLevel: 1,
                targetLevel: 1,
                completedCourses: [],
                requiredCourses: [],
                expectedProgress: 100.0,
                description: "Same current and target level"
            ),
            ProgressTestCase(
                currentLevel: 1,
                targetLevel: 10,
                completedCourses: [],
                requiredCourses: [],
                expectedProgress: 10.0,
                description: "Large level gap with no courses"
            ),
            ProgressTestCase(
                currentLevel: 1,
                targetLevel: 2,
                completedCourses: [],
                requiredCourses: ["C1", "C2", "C3", "C4", "C5", "C6", "C7", "C8", "C9", "C10"],
                expectedProgress: 0.0,
                description: "Many required courses, none completed"
            ),
            
            // MARK: Invalid Input Cases
            ProgressTestCase(
                currentLevel: -1,
                targetLevel: 5,
                completedCourses: [],
                requiredCourses: ["C1"],
                expectedProgress: 0.0,
                description: "Negative current level"
            ),
            ProgressTestCase(
                currentLevel: 1,
                targetLevel: -5,
                completedCourses: [],
                requiredCourses: ["C1"],
                expectedProgress: 100.0,
                description: "Negative target level"
            )
        ]
        
        // Run all test cases
        for testCase in testCases {
            let progress = calculator.calculateProgress(
                currentLevel: testCase.currentLevel,
                targetLevel: testCase.targetLevel,
                completedCourses: Set(testCase.completedCourses),
                requiredCourses: Set(testCase.requiredCourses)
            )
            
            XCTAssertEqual(
                progress,
                testCase.expectedProgress,
                accuracy: 0.01,
                "Failed: \(testCase.description). Expected \(testCase.expectedProgress)%, got \(progress)%"
            )
        }
        
        print("✅ Tested \(testCases.count) progress calculation scenarios")
    }
    
    // MARK: - Weighted Progress Tests
    
    func testWeightedProgressCalculation() {
        let calculator = TestCompetencyProgressCalculator()
        
        struct WeightedTestCase {
            let levelWeight: Double
            let courseWeight: Double
            let currentLevel: Int
            let targetLevel: Int
            let completedCourses: Int
            let totalCourses: Int
            let expectedProgress: Double
            let description: String
        }
        
        let testCases: [WeightedTestCase] = [
            WeightedTestCase(
                levelWeight: 0.5,
                courseWeight: 0.5,
                currentLevel: 2,
                targetLevel: 4,
                completedCourses: 1,
                totalCourses: 2,
                expectedProgress: 50.0,
                description: "Equal weights - 50% level + 50% courses"
            ),
            WeightedTestCase(
                levelWeight: 0.7,
                courseWeight: 0.3,
                currentLevel: 3,
                targetLevel: 5,
                completedCourses: 0,
                totalCourses: 3,
                expectedProgress: 42.0,
                description: "Level-heavy weighting"
            ),
            WeightedTestCase(
                levelWeight: 0.3,
                courseWeight: 0.7,
                currentLevel: 1,
                targetLevel: 3,
                completedCourses: 2,
                totalCourses: 2,
                expectedProgress: 80.0,
                description: "Course-heavy weighting"
            ),
            WeightedTestCase(
                levelWeight: 1.0,
                courseWeight: 0.0,
                currentLevel: 4,
                targetLevel: 10,
                completedCourses: 0,
                totalCourses: 5,
                expectedProgress: 40.0,
                description: "Level only"
            ),
            WeightedTestCase(
                levelWeight: 0.0,
                courseWeight: 1.0,
                currentLevel: 1,
                targetLevel: 10,
                completedCourses: 3,
                totalCourses: 4,
                expectedProgress: 75.0,
                description: "Courses only"
            )
        ]
        
        for testCase in testCases {
            let progress = calculator.calculateWeightedProgress(
                levelWeight: testCase.levelWeight,
                courseWeight: testCase.courseWeight,
                currentLevel: testCase.currentLevel,
                targetLevel: testCase.targetLevel,
                completedCourses: testCase.completedCourses,
                totalCourses: testCase.totalCourses
            )
            
            XCTAssertEqual(
                progress,
                testCase.expectedProgress,
                accuracy: 0.01,
                "Failed: \(testCase.description)"
            )
        }
    }
    
    // MARK: - Performance Test
    
    func testProgressCalculationPerformance() {
        let calculator = TestCompetencyProgressCalculator()
        let largeCourseSet = Set((1...1000).map { "COURSE_\($0)" })
        let completedSubset = Set((1...500).map { "COURSE_\($0)" })
        
        measure {
            for level in 1...10 {
                _ = calculator.calculateProgress(
                    currentLevel: level,
                    targetLevel: 10,
                    completedCourses: completedSubset,
                    requiredCourses: largeCourseSet
                )
            }
        }
    }

    func testBasicProgressCalculation() {
        // Test 0%
        XCTAssertEqual(TestCompetencyProgressCalculator.calculateProgress(completed: 0, total: 10), 0.0)
        
        // Test 50%
        XCTAssertEqual(TestCompetencyProgressCalculator.calculateProgress(completed: 5, total: 10), 50.0)
        
        // Test 100%
        XCTAssertEqual(TestCompetencyProgressCalculator.calculateProgress(completed: 10, total: 10), 100.0)
    }

    func testProgressWithZeroTotal() {
        XCTAssertEqual(TestCompetencyProgressCalculator.calculateProgress(completed: 5, total: 0), 0.0)
    }

    func testProgressBoundaries() {
        // Should not exceed 100%
        XCTAssertEqual(TestCompetencyProgressCalculator.calculateProgress(completed: 15, total: 10), 100.0)
        
        // Should not go below 0%
        XCTAssertEqual(TestCompetencyProgressCalculator.calculateProgress(completed: -5, total: 10), 0.0)
    }

    func testWeightedProgressCalculationWithItems() {
        let items: [(completed: Bool, weight: Double)] = [
            (completed: true, weight: 1.0),
            (completed: false, weight: 2.0),
            (completed: true, weight: 3.0),
            (completed: false, weight: 4.0),
            (completed: true, weight: 5.0)
        ]
        let progress = TestCompetencyProgressCalculator.calculateWeightedProgress(items: items)
        XCTAssertEqual(progress, 60.0, accuracy: 0.01) // (1+3+5)/(1+2+3+4+5) = 9/15 = 60%
    }

    func testWeightedProgressCalculationWithZeroItems() {
        let items: [(completed: Bool, weight: Double)] = []
        XCTAssertEqual(TestCompetencyProgressCalculator.calculateWeightedProgress(items: items), 0.0)
    }

    func testWeightedProgressCalculationWithMixedItems() {
        let items: [(completed: Bool, weight: Double)] = [
            (completed: true, weight: 10.0),
            (completed: true, weight: 20.0),
            (completed: false, weight: 15.0),
            (completed: true, weight: 25.0),
            (completed: false, weight: 30.0)
        ]
        let progress = TestCompetencyProgressCalculator.calculateWeightedProgress(items: items)
        XCTAssertEqual(progress, 55.0, accuracy: 0.01) // (10+20+25)/(10+20+15+25+30) = 55/100 = 55%
    }

    func testLevelCalculation() {
        XCTAssertEqual(TestCompetencyProgressCalculator.calculateLevel(progress: 0), "beginner")
        XCTAssertEqual(TestCompetencyProgressCalculator.calculateLevel(progress: 10), "beginner")
        XCTAssertEqual(TestCompetencyProgressCalculator.calculateLevel(progress: 19.9), "beginner")

        XCTAssertEqual(TestCompetencyProgressCalculator.calculateLevel(progress: 20), "elementary")
        XCTAssertEqual(TestCompetencyProgressCalculator.calculateLevel(progress: 30), "elementary")
        XCTAssertEqual(TestCompetencyProgressCalculator.calculateLevel(progress: 39.9), "elementary")

        XCTAssertEqual(TestCompetencyProgressCalculator.calculateLevel(progress: 40), "intermediate")
        XCTAssertEqual(TestCompetencyProgressCalculator.calculateLevel(progress: 50), "intermediate")
        XCTAssertEqual(TestCompetencyProgressCalculator.calculateLevel(progress: 59.9), "intermediate")

        XCTAssertEqual(TestCompetencyProgressCalculator.calculateLevel(progress: 60), "advanced")
        XCTAssertEqual(TestCompetencyProgressCalculator.calculateLevel(progress: 70), "advanced")
        XCTAssertEqual(TestCompetencyProgressCalculator.calculateLevel(progress: 79.9), "advanced")

        XCTAssertEqual(TestCompetencyProgressCalculator.calculateLevel(progress: 80), "expert")
        XCTAssertEqual(TestCompetencyProgressCalculator.calculateLevel(progress: 90), "expert")
        XCTAssertEqual(TestCompetencyProgressCalculator.calculateLevel(progress: 100), "expert")

        XCTAssertEqual(TestCompetencyProgressCalculator.calculateLevel(progress: -10), "unknown")
        XCTAssertEqual(TestCompetencyProgressCalculator.calculateLevel(progress: 110), "unknown")
    }

    func testTimeEstimation() {
        let estimate = TestCompetencyProgressCalculator.estimateTimeToComplete(
            totalItems: 10,
            completedItems: 5,
            averageTimePerItem: 2.0
        )
        XCTAssertEqual(estimate, 10.0, accuracy: 0.01) // (10-5) * 2.0 = 10.0
    }
} 