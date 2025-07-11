//
//  TestViewModelTests.swift
//  LMSTests
//
//  Created on 06/07/2025.
//

import XCTest
import Combine
@testable import LMS

@MainActor
final class TestViewModelTests: XCTestCase {
    
    var viewModel: TestViewModel!
    var cancellables: Set<AnyCancellable> = []
    
    override func setUp() {
        super.setUp()
        viewModel = TestViewModel()
        cancellables = []
    }
    
    override func tearDown() {
        viewModel.cleanup()
        viewModel = nil
        cancellables.removeAll()
        super.tearDown()
    }
    
    // MARK: - Initialization Tests
    
    func testInitialState() {
        XCTAssertNil(viewModel.selectedTest)
        XCTAssertNil(viewModel.currentAttempt)
        XCTAssertNil(viewModel.currentQuestion)
        XCTAssertNil(viewModel.timer)
        XCTAssertEqual(viewModel.searchText, "")
        XCTAssertNil(viewModel.selectedType)
        XCTAssertNil(viewModel.selectedDifficulty)
        XCTAssertNil(viewModel.selectedStatus)
        XCTAssertFalse(viewModel.showOnlyAvailable)
        XCTAssertEqual(viewModel.selectedFilter, "Все")
        XCTAssertEqual(viewModel.sortOption, .dateCreated)
        XCTAssertFalse(viewModel.isAscending)
        XCTAssertTrue(viewModel.assignedTests.isEmpty)
        XCTAssertTrue(viewModel.completedTests.isEmpty)
        XCTAssertTrue(viewModel.practiceTests.isEmpty)
    }
    
    // MARK: - Filtering Tests
    
    func testSearchFiltering() {
        // Given
        let test1 = Test.mockQuiz()
        let test2 = Test.mockExam()
        TestMockService.shared.tests = [test1, test2]
        
        // When
        viewModel.searchText = "Quiz"
        
        // Then
        XCTAssertEqual(viewModel.filteredTests.count, 1)
        XCTAssertEqual(viewModel.filteredTests.first?.title, test1.title)
    }
    
    func testTypeFiltering() {
        // Given
        let quiz = Test.mockQuiz()
        let exam = Test.mockExam()
        TestMockService.shared.tests = [quiz, exam]
        
        // When
        viewModel.selectedType = .quiz
        
        // Then
        XCTAssertEqual(viewModel.filteredTests.count, 1)
        XCTAssertEqual(viewModel.filteredTests.first?.type, .quiz)
    }
    
    func testDifficultyFiltering() {
        // Given
        var easyTest = Test.mockQuiz()
        easyTest.difficulty = .easy
        var hardTest = Test.mockQuiz()
        hardTest.difficulty = .hard
        TestMockService.shared.tests = [easyTest, hardTest]
        
        // When
        viewModel.selectedDifficulty = .easy
        
        // Then
        XCTAssertEqual(viewModel.filteredTests.count, 1)
        XCTAssertEqual(viewModel.filteredTests.first?.difficulty, .easy)
    }
    
    func testStatusFiltering() {
        // Given
        var draftTest = Test.mockQuiz()
        draftTest.status = .draft
        var publishedTest = Test.mockQuiz()
        publishedTest.status = .published
        TestMockService.shared.tests = [draftTest, publishedTest]
        
        // When
        viewModel.selectedStatus = .published
        
        // Then
        XCTAssertEqual(viewModel.filteredTests.count, 1)
        XCTAssertEqual(viewModel.filteredTests.first?.status, .published)
    }
    
    func testShowOnlyAvailableFiltering() {
        // Given
        var availableTest = Test.mockQuiz()
        availableTest.status = .published
        var unavailableTest = Test.mockQuiz()
        unavailableTest.status = .draft
        TestMockService.shared.tests = [availableTest, unavailableTest]
        
        // When
        viewModel.showOnlyAvailable = true
        
        // Then
        XCTAssertEqual(viewModel.filteredTests.count, 1)
        XCTAssertTrue(viewModel.filteredTests.first?.isPublished ?? false)
    }
    
    func testCombinedFiltering() {
        // Given
        var test1 = Test.mockQuiz()
        test1.difficulty = .easy
        test1.status = .published
        
        var test2 = Test.mockQuiz()
        test2.difficulty = .hard
        test2.status = .published
        
        var test3 = Test.mockExam()
        test3.difficulty = .easy
        test3.status = .draft
        
        TestMockService.shared.tests = [test1, test2, test3]
        
        // When
        viewModel.selectedType = .quiz
        viewModel.selectedDifficulty = .easy
        viewModel.selectedStatus = .published
        
        // Then
        XCTAssertEqual(viewModel.filteredTests.count, 1)
        XCTAssertEqual(viewModel.filteredTests.first?.id, test1.id)
    }
    
    // MARK: - Test Management Tests
    
    func testSelectTest() {
        // Given
        let test = Test.mockQuiz()
        
        // When
        viewModel.selectTest(test)
        
        // Then
        XCTAssertEqual(viewModel.selectedTest?.id, test.id)
    }
    
    func testAddTest() {
        // Given
        let test = Test.mockQuiz()
        TestMockService.shared.tests = []
        
        // When
        viewModel.addTest(test)
        
        // Then
        XCTAssertEqual(TestMockService.shared.tests.count, 1)
        XCTAssertEqual(TestMockService.shared.tests.first?.id, test.id)
    }
    
    // MARK: - Test Execution Tests
    
    func testStartTest() {
        // Given
        let test = Test.mockQuiz()
        TestMockService.shared.tests = [test]
        
        // When
        viewModel.startTest(test)
        
        // Then
        XCTAssertNotNil(viewModel.currentAttempt)
        XCTAssertNotNil(viewModel.currentQuestion)
        XCTAssertEqual(viewModel.currentAttempt?.testId, test.id)
        XCTAssertEqual(viewModel.currentAttempt?.userId, viewModel.currentUserId)
        XCTAssertNotNil(viewModel.timer)
    }
    
    func testStartTestWithMaxAttemptsReached() {
        // Given
        var test = Test.mockQuiz()
        test.attemptsAllowed = 1
        TestMockService.shared.tests = [test]
        
        // Create existing attempt
        _ = TestMockService.shared.startTest(testId: test.id, userId: viewModel.currentUserId)
        _ = TestMockService.shared.submitTest(attemptId: TestMockService.shared.attempts.first!.id)
        
        // When
        viewModel.startTest(test)
        
        // Then
        XCTAssertNil(viewModel.currentAttempt)
        XCTAssertNil(viewModel.currentQuestion)
    }
    
    func testResumeTest() {
        // Given
        let test = Test.mockQuiz()
        TestMockService.shared.tests = [test]
        let attempt = TestMockService.shared.startTest(testId: test.id, userId: viewModel.currentUserId)!
        
        // When
        viewModel.resumeTest(attempt)
        
        // Then
        XCTAssertEqual(viewModel.currentAttempt?.id, attempt.id)
        XCTAssertNotNil(viewModel.currentQuestion)
        XCTAssertNotNil(viewModel.timer)
    }
    
    // MARK: - Navigation Tests
    
    func testNextQuestion() {
        // Given
        let test = Test.mockQuiz()
        TestMockService.shared.tests = [test]
        viewModel.startTest(test)
        let firstQuestionId = viewModel.currentQuestion?.id
        
        // When
        viewModel.nextQuestion()
        
        // Then
        XCTAssertNotEqual(viewModel.currentQuestion?.id, firstQuestionId)
        XCTAssertEqual(viewModel.currentQuestionIndex, 1)
    }
    
    func testPreviousQuestion() {
        // Given
        let test = Test.mockQuiz()
        TestMockService.shared.tests = [test]
        viewModel.startTest(test)
        viewModel.nextQuestion()
        let secondQuestionId = viewModel.currentQuestion?.id
        
        // When
        viewModel.previousQuestion()
        
        // Then
        XCTAssertNotEqual(viewModel.currentQuestion?.id, secondQuestionId)
        XCTAssertEqual(viewModel.currentQuestionIndex, 0)
    }
    
    func testGoToQuestion() {
        // Given
        let test = Test.mockQuiz()
        TestMockService.shared.tests = [test]
        viewModel.startTest(test)
        
        // When
        viewModel.goToQuestion(at: 2)
        
        // Then
        XCTAssertEqual(viewModel.currentQuestionIndex, 2)
    }
    
    func testIsLastQuestion() {
        // Given
        let test = Test.mockQuiz()
        TestMockService.shared.tests = [test]
        viewModel.startTest(test)
        
        // When
        while viewModel.hasNextQuestion {
            viewModel.nextQuestion()
        }
        
        // Then
        XCTAssertTrue(viewModel.isLastQuestion)
        XCTAssertFalse(viewModel.hasNextQuestion)
    }
    
    // MARK: - Answer Management Tests
    
    func testSaveCurrentAnswer() {
        // Given
        let test = Test.mockQuiz()
        TestMockService.shared.tests = [test]
        viewModel.startTest(test)
        let question = viewModel.currentQuestion!
        let firstOptionId = question.options.first?.id ?? UUID()
        let answer = UserAnswer(
            questionId: question.id,
            selectedOptionIds: [firstOptionId],
            textAnswer: nil,
            matchingAnswers: nil,
            orderingAnswer: nil,
            fillInBlanksAnswers: nil,
            essayAnswer: nil
        )
        
        // When
        viewModel.saveCurrentAnswer(answer)
        
        // Then
        let savedAnswer = viewModel.getCurrentAnswer()
        XCTAssertNotNil(savedAnswer)
        XCTAssertEqual(savedAnswer?.questionId, answer.questionId)
        XCTAssertEqual(savedAnswer?.selectedOptionIds, answer.selectedOptionIds)
    }
    
    func testMarkUnmarkQuestion() {
        // Given
        let test = Test.mockQuiz()
        TestMockService.shared.tests = [test]
        viewModel.startTest(test)
        
        // When - Mark
        viewModel.markCurrentQuestion()
        
        // Then
        XCTAssertTrue(viewModel.isCurrentQuestionMarked())
        
        // When - Unmark
        viewModel.unmarkCurrentQuestion()
        
        // Then
        XCTAssertFalse(viewModel.isCurrentQuestionMarked())
    }
    
    // MARK: - Test Submission Tests
    
    func testSubmitTest() {
        // Given
        let test = Test.mockQuiz()
        TestMockService.shared.tests = [test]
        viewModel.startTest(test)
        
        // Answer all questions
        for i in 0..<test.questions.count {
            let question = test.questions[i]
            let firstOptionId = question.options.first?.id ?? UUID()
            let answer = UserAnswer(
                questionId: question.id,
                selectedOptionIds: [firstOptionId],
                textAnswer: nil,
                matchingAnswers: nil,
                orderingAnswer: nil,
                fillInBlanksAnswers: nil,
                essayAnswer: nil
            )
            viewModel.saveCurrentAnswer(answer)
            if viewModel.hasNextQuestion {
                viewModel.nextQuestion()
            }
        }
        
        // When
        viewModel.submitTest()
        
        // Then
        XCTAssertNil(viewModel.currentAttempt)
        XCTAssertNil(viewModel.currentQuestion)
        XCTAssertNil(viewModel.timer)
    }
    
    // MARK: - Timer Tests
    
    func testTimerExpiration() {
        // Given
        var test = Test.mockQuiz()
        test.timeLimit = 1 // 1 second
        TestMockService.shared.tests = [test]
        viewModel.startTest(test)
        
        let expectation = XCTestExpectation(description: "Timer expiration")
        
        // Then
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            XCTAssertNil(self.viewModel.currentAttempt)
            XCTAssertNil(self.viewModel.timer)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 3)
    }
    
    // MARK: - Statistics Tests
    
    func testGetTestStatistics() {
        // Given
        let test = Test.mockQuiz()
        TestMockService.shared.tests = [test]
        
        // Create some results
        for _ in 0..<3 {
            let attempt = TestMockService.shared.startTest(testId: test.id, userId: viewModel.currentUserId)!
            _ = TestMockService.shared.submitTest(attemptId: attempt.id)
        }
        
        // When
        let stats = viewModel.getTestStatistics(test)
        
        // Then
        XCTAssertEqual(stats.attempts, 3)
        XCTAssertGreaterThan(stats.avgScore, 0)
        XCTAssertGreaterThanOrEqual(stats.passRate, 0)
        XCTAssertLessThanOrEqual(stats.passRate, 1)
    }
    
    func testCanRetakeTest() {
        // Given
        var test = Test.mockQuiz()
        test.attemptsAllowed = 2
        TestMockService.shared.tests = [test]
        
        // When - No attempts
        XCTAssertTrue(viewModel.canRetakeTest(test))
        
        // Create one attempt
        let attempt = TestMockService.shared.startTest(testId: test.id, userId: viewModel.currentUserId)!
        _ = TestMockService.shared.submitTest(attemptId: attempt.id)
        
        // When - One attempt
        XCTAssertTrue(viewModel.canRetakeTest(test))
        
        // Create second attempt
        let attempt2 = TestMockService.shared.startTest(testId: test.id, userId: viewModel.currentUserId)!
        _ = TestMockService.shared.submitTest(attemptId: attempt2.id)
        
        // When - Max attempts reached
        XCTAssertFalse(viewModel.canRetakeTest(test))
    }
    
    // MARK: - Student Methods Tests
    
    func testLoadTests() {
        // Given
        let publishedTest = Test.mockQuiz()
        var draftTest = Test.mockQuiz()
        draftTest.status = .draft
        var practiceTest = Test.mockExam()
        practiceTest.type = .practice
        
        TestMockService.shared.tests = [publishedTest, draftTest, practiceTest]
        
        // When
        viewModel.loadTests()
        
        // Then
        XCTAssertFalse(viewModel.assignedTests.isEmpty)
        XCTAssertTrue(viewModel.completedTests.isEmpty) // No completed tests yet
        XCTAssertEqual(viewModel.practiceTests.count, 1)
        XCTAssertEqual(viewModel.practiceTests.first?.type, .practice)
    }
    
    // MARK: - Computed Properties Tests
    
    func testTestsGroupedByType() {
        // Given
        let quiz = Test.mockQuiz()
        let exam = Test.mockExam()
        var practice = Test.mockQuiz()
        practice.type = .practice
        
        TestMockService.shared.tests = [quiz, exam, practice]
        
        // When
        let grouped = viewModel.testsGroupedByType
        
        // Then
        XCTAssertEqual(grouped.count, 3)
        XCTAssertEqual(grouped[.quiz]?.count, 1)
        XCTAssertEqual(grouped[.exam]?.count, 1)
        XCTAssertEqual(grouped[.practice]?.count, 1)
    }
    
    func testUserResults() {
        // Given
        let test = Test.mockQuiz()
        TestMockService.shared.tests = [test]
        
        // Create and submit attempt
        let attempt = TestMockService.shared.startTest(testId: test.id, userId: viewModel.currentUserId)!
        _ = TestMockService.shared.submitTest(attemptId: attempt.id)
        
        // When
        let results = viewModel.userResults
        
        // Then
        XCTAssertFalse(results.isEmpty)
        XCTAssertEqual(results.first?.userId, viewModel.currentUserId)
    }
} 