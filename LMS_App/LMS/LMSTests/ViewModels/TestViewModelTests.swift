//
//  TestViewModelTests.swift
//  LMSTests
//
//  Created on 09/07/2025.
//

import XCTest
import Combine
@testable import LMS

@MainActor
final class TestViewModelTests: XCTestCase {
    private var sut: TestViewModel!
    private var cancellables: Set<AnyCancellable>!
    
    override func setUp() async throws {
        try await super.setUp()
        sut = TestViewModel()
        cancellables = Set<AnyCancellable>()
    }
    
    override func tearDown() async throws {
        cancellables = nil
        sut.cleanup()
        sut = nil
        try await super.tearDown()
    }
    
    // MARK: - Initialization Tests
    
    func testInitialization() {
        // Check initial state
        XCTAssertEqual(sut.searchText, "")
        XCTAssertNil(sut.selectedType)
        XCTAssertNil(sut.selectedDifficulty)
        XCTAssertNil(sut.selectedStatus)
        XCTAssertFalse(sut.showOnlyAvailable)
        XCTAssertNil(sut.selectedTest)
        XCTAssertNil(sut.currentAttempt)
        XCTAssertNil(sut.currentQuestion)
        XCTAssertNil(sut.timer)
        XCTAssertEqual(sut.selectedFilter, "Все")
        XCTAssertEqual(sut.sortOption, .dateCreated)
        XCTAssertFalse(sut.isAscending)
    }
    
    // MARK: - Filtering Tests
    
    func testSearchFiltering() {
        // Given
        sut.searchText = "iOS"
        
        // When
        let filtered = sut.filteredTests
        
        // Then
        XCTAssertTrue(filtered.allSatisfy { test in
            test.title.localizedCaseInsensitiveContains("iOS") ||
            test.description.localizedCaseInsensitiveContains("iOS")
        })
    }
    
    func testTypeFiltering() {
        // Given
        sut.selectedType = .assessment
        
        // When
        let filtered = sut.filteredTests
        
        // Then
        XCTAssertTrue(filtered.allSatisfy { $0.type == .assessment })
    }
    
    func testDifficultyFiltering() {
        // Given
        sut.selectedDifficulty = .easy
        
        // When
        let filtered = sut.filteredTests
        
        // Then
        XCTAssertTrue(filtered.allSatisfy { $0.difficulty == .easy })
    }
    
    func testStatusFiltering() {
        // Given
        sut.selectedStatus = .published
        
        // When
        let filtered = sut.filteredTests
        
        // Then
        XCTAssertTrue(filtered.allSatisfy { $0.status == .published })
    }
    
    func testAvailableFiltering() {
        // Given
        sut.showOnlyAvailable = true
        
        // When
        let filtered = sut.filteredTests
        
        // Then
        XCTAssertTrue(filtered.allSatisfy { $0.isPublished && $0.canBeTaken })
    }
    
    func testCombinedFiltering() {
        // Given
        sut.selectedType = .quiz
        sut.selectedDifficulty = .medium
        sut.showOnlyAvailable = true
        
        // When
        let filtered = sut.filteredTests
        
        // Then
        XCTAssertTrue(filtered.allSatisfy { test in
            test.type == .quiz &&
            test.difficulty == .medium &&
            test.isPublished &&
            test.canBeTaken
        })
    }
    
    // MARK: - Grouping Tests
    
    func testTestsGroupedByType() {
        // When
        let grouped = sut.testsGroupedByType
        
        // Then
        for (type, tests) in grouped {
            XCTAssertTrue(tests.allSatisfy { $0.type == type })
        }
    }
    
    // MARK: - Test Management Tests
    
    func testSelectTest() {
        // Given
        let mockTest = createMockTest()
        
        // When
        sut.selectTest(mockTest)
        
        // Then
        XCTAssertEqual(sut.selectedTest?.id, mockTest.id)
    }
    
    func testAddTest() {
        // Given
        let newTest = createMockTest()
        
        // When
        sut.addTest(newTest)
        
        // Then
        // Should add test to service
        XCTAssertTrue(sut.filteredTests.contains { $0.id == newTest.id })
    }
    
    func testStartTest() {
        // Given
        let mockTest = createMockTestWithQuestions()
        sut.addTest(mockTest) // Add test to service first
        
        // When
        sut.startTest(mockTest)
        
        // Then
        XCTAssertNotNil(sut.currentAttempt)
        XCTAssertEqual(sut.currentAttempt?.testId, mockTest.id)
        XCTAssertNotNil(sut.currentQuestion)
        XCTAssertNotNil(sut.timer)
    }
    
    func testResumeTest() {
        // Given
        let mockTest = createMockTestWithQuestions()
        sut.addTest(mockTest) // Add test to service first
        sut.startTest(mockTest)
        guard let attempt = sut.currentAttempt else {
            XCTFail("No current attempt")
            return
        }
        
        // Clear current state
        sut.currentAttempt = nil
        sut.currentQuestion = nil
        
        // When
        sut.resumeTest(attempt)
        
        // Then
        XCTAssertNotNil(sut.currentAttempt)
        XCTAssertEqual(sut.currentAttempt?.id, attempt.id)
        XCTAssertNotNil(sut.currentQuestion)
        XCTAssertNotNil(sut.timer)
    }
    
    // MARK: - Question Navigation Tests
    
    func testNextQuestion() {
        // Given
        let mockTest = createMockTestWithQuestions()
        sut.addTest(mockTest) // Add test to service first
        sut.startTest(mockTest)
        let firstQuestionId = sut.currentQuestion?.id
        
        // When
        sut.nextQuestion()
        
        // Then
        XCTAssertNotEqual(sut.currentQuestion?.id, firstQuestionId)
        XCTAssertEqual(sut.currentQuestionIndex, 1)
    }
    
    func testPreviousQuestion() {
        // Given
        let mockTest = createMockTestWithQuestions()
        sut.addTest(mockTest) // Add test to service first
        sut.startTest(mockTest)
        sut.nextQuestion() // Go to second question
        let secondQuestionId = sut.currentQuestion?.id
        
        // When
        sut.previousQuestion()
        
        // Then
        XCTAssertNotEqual(sut.currentQuestion?.id, secondQuestionId)
        XCTAssertEqual(sut.currentQuestionIndex, 0)
    }
    
    func testGoToQuestion() {
        // Given
        let mockTest = createMockTestWithQuestions()
        sut.addTest(mockTest) // Add test to service first
        sut.startTest(mockTest)
        
        // When
        sut.goToQuestion(at: 2)
        
        // Then
        XCTAssertEqual(sut.currentQuestionIndex, 2)
    }
    
    func testIsLastQuestion() {
        // Given
        let mockTest = createMockTestWithQuestions()
        sut.addTest(mockTest) // Add test to service first
        sut.startTest(mockTest)
        
        // When - go to last question
        while sut.hasNextQuestion {
            sut.nextQuestion()
        }
        
        // Then
        XCTAssertTrue(sut.isLastQuestion)
        XCTAssertFalse(sut.hasNextQuestion)
    }
    
    // MARK: - Answer Management Tests
    
    func testSaveCurrentAnswer() {
        // Given
        let mockTest = createMockTestWithQuestions()
        sut.addTest(mockTest) // Add test to service first
        sut.startTest(mockTest)
        
        guard let questionId = sut.currentQuestion?.id,
              let firstOption = sut.currentQuestion?.options.first else {
            XCTFail("No current question or options")
            return
        }
        
        let answer = UserAnswer(
            questionId: questionId,
            selectedOptionIds: [firstOption.id],
            textAnswer: nil
        )
        
        // When
        sut.saveCurrentAnswer(answer)
        
        // Then
        let savedAnswer = sut.getCurrentAnswer()
        XCTAssertNotNil(savedAnswer)
        XCTAssertEqual(savedAnswer?.questionId, questionId)
        XCTAssertEqual(savedAnswer?.selectedOptionIds, [firstOption.id])
    }
    
    func testMarkUnmarkQuestion() {
        // Given
        let mockTest = createMockTestWithQuestions()
        sut.addTest(mockTest) // Add test to service first
        sut.startTest(mockTest)
        
        // When - mark
        sut.markCurrentQuestion()
        
        // Then
        XCTAssertTrue(sut.isCurrentQuestionMarked())
        
        // When - unmark
        sut.unmarkCurrentQuestion()
        
        // Then
        XCTAssertFalse(sut.isCurrentQuestionMarked())
    }
    
    // MARK: - Test Submission Tests
    
    func testSubmitTest() {
        // Given
        let mockTest = createMockTestWithQuestions()
        sut.addTest(mockTest) // Add test to service first
        sut.startTest(mockTest)
        
        // Answer some questions
        if let questionId = sut.currentQuestion?.id,
           let firstOption = sut.currentQuestion?.options.first {
            let answer = UserAnswer(
                questionId: questionId,
                selectedOptionIds: [firstOption.id],
                textAnswer: nil
            )
            sut.saveCurrentAnswer(answer)
        }
        
        // When
        sut.submitTest()
        
        // Then
        XCTAssertNil(sut.currentAttempt)
        XCTAssertNil(sut.currentQuestion)
        XCTAssertNil(sut.timer)
    }
    
    // MARK: - Statistics Tests
    
    func testGetTestStatistics() {
        // Given
        let mockTest = createMockTest()
        
        // When
        let stats = sut.getTestStatistics(mockTest)
        
        // Then
        XCTAssertGreaterThanOrEqual(stats.attempts, 0)
        XCTAssertGreaterThanOrEqual(stats.avgScore, 0)
        XCTAssertLessThanOrEqual(stats.avgScore, 100)
        XCTAssertGreaterThanOrEqual(stats.passRate, 0)
        XCTAssertLessThanOrEqual(stats.passRate, 1)
    }
    
    func testCanRetakeTest() {
        // Given - test with limited attempts
        let limitedTest = Test(
            title: "Limited Test",
            description: "Test with limited attempts",
            type: .exam,
            attemptsAllowed: 3,
            createdBy: "test-user"
        )
        
        // When/Then - should allow retake initially
        XCTAssertTrue(sut.canRetakeTest(limitedTest))
        
        // Given - test with unlimited attempts
        let unlimitedTest = Test(
            title: "Unlimited Test",
            description: "Test with unlimited attempts",
            type: .practice,
            attemptsAllowed: nil,
            createdBy: "test-user"
        )
        
        // When/Then - should always allow retake
        XCTAssertTrue(sut.canRetakeTest(unlimitedTest))
    }
    
    // MARK: - Student Methods Tests
    
    func testLoadTests() {
        // When
        sut.loadTests()
        
        // Then
        // Should categorize tests correctly
        XCTAssertTrue(sut.assignedTests.allSatisfy { test in
            test.status == .published && test.canBeTaken
        })
        
        XCTAssertTrue(sut.practiceTests.allSatisfy { test in
            test.type == .practice && test.status == .published
        })
    }
    
    func testUserResults() {
        // When
        let results = sut.userResults
        
        // Then
        XCTAssertNotNil(results)
        // All results should belong to current user
        XCTAssertTrue(results.allSatisfy { $0.userId == sut.currentUserId })
    }
    
    // MARK: - Cleanup Tests
    
    func testCleanup() {
        // Given
        let mockTest = createMockTestWithQuestions()
        sut.addTest(mockTest) // Add test to service first
        sut.startTest(mockTest)
        
        // When
        sut.cleanup()
        
        // Then
        XCTAssertNil(sut.timer)
    }
    
    // MARK: - Helper Methods
    
    private func createMockTest() -> Test {
        Test(
            title: "Mock Test",
            description: "Test for unit testing",
            type: .quiz,
            status: .published,
            difficulty: .medium,
            timeLimit: 30,
            attemptsAllowed: 3,
            passingScore: 70,
            createdBy: "test-user"
        )
    }
    
    private func createMockTestWithQuestions() -> Test {
        var test = createMockTest()
        
        test.questions = [
            Question(
                text: "Question 1",
                type: .singleChoice,
                points: 10,
                options: [
                    AnswerOption(text: "Option A", isCorrect: true),
                    AnswerOption(text: "Option B", isCorrect: false)
                ]
            ),
            Question(
                text: "Question 2",
                type: .multipleChoice,
                points: 20,
                options: [
                    AnswerOption(text: "Option A", isCorrect: true),
                    AnswerOption(text: "Option B", isCorrect: true),
                    AnswerOption(text: "Option C", isCorrect: false)
                ]
            ),
            Question(
                text: "Question 3",
                type: .essay,
                points: 30,
                acceptedAnswers: ["Expected answer"]
            )
        ]
        
        return test
    }
} 