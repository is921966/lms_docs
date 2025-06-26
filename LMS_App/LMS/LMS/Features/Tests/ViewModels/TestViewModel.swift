//
//  TestViewModel.swift
//  LMS
//
//  Created on 26/01/2025.
//

import Foundation
import SwiftUI
import Combine

@MainActor
class TestViewModel: ObservableObject {
    @Published var service: TestMockService
    @Published var selectedTest: Test?
    @Published var currentAttempt: TestAttempt?
    @Published var currentQuestion: Question?
    @Published var timer: Timer?
    
    // Filters
    @Published var searchText = ""
    @Published var selectedType: TestType?
    @Published var selectedDifficulty: TestDifficulty?
    @Published var selectedStatus: TestStatus?
    @Published var showOnlyAvailable = false
    
    // Current user (в реальном приложении из AuthService)
    let currentUserId = "current-user"
    
    init() {
        self.service = TestMockService()
    }
    
    init(service: TestMockService) {
        self.service = service
    }
    
    // MARK: - Computed Properties
    
    var filteredTests: [Test] {
        service.tests.filter { test in
            // Search filter
            let matchesSearch = searchText.isEmpty ||
                test.title.localizedCaseInsensitiveContains(searchText) ||
                test.description.localizedCaseInsensitiveContains(searchText)
            
            // Type filter
            let matchesType = selectedType == nil || test.type == selectedType
            
            // Difficulty filter
            let matchesDifficulty = selectedDifficulty == nil || test.difficulty == selectedDifficulty
            
            // Status filter
            let matchesStatus = selectedStatus == nil || test.status == selectedStatus
            
            // Available filter
            let isAvailable = !showOnlyAvailable || (test.isPublished && test.canBeTaken)
            
            return matchesSearch && matchesType && matchesDifficulty && matchesStatus && isAvailable
        }
    }
    
    var testsGroupedByType: [TestType: [Test]] {
        Dictionary(grouping: filteredTests, by: { $0.type })
    }
    
    var userResults: [TestResult] {
        service.getUserResults(userId: currentUserId)
    }
    
    var currentQuestionIndex: Int {
        guard let attempt = currentAttempt,
              let question = currentQuestion else { return 0 }
        return attempt.questionsOrder.firstIndex(of: question.id) ?? 0
    }
    
    var totalQuestions: Int {
        currentAttempt?.totalQuestionsCount ?? 0
    }
    
    var isLastQuestion: Bool {
        currentQuestionIndex >= totalQuestions - 1
    }
    
    var hasNextQuestion: Bool {
        currentQuestionIndex < totalQuestions - 1
    }
    
    var hasPreviousQuestion: Bool {
        currentQuestionIndex > 0
    }
    
    // MARK: - Test Management
    
    func selectTest(_ test: Test) {
        selectedTest = test
    }
    
    func addTest(_ test: Test) {
        service.tests.append(test)
    }
    
    func startTest(_ test: Test) {
        guard let attempt = service.startTest(testId: test.id, userId: currentUserId) else {
            // Показать ошибку - превышен лимит попыток
            return
        }
        
        currentAttempt = attempt
        loadFirstQuestion()
        startTimer()
    }
    
    func resumeTest(_ attempt: TestAttempt) {
        guard attempt.canResume else { return }
        currentAttempt = attempt
        loadQuestion(at: attempt.currentQuestionIndex)
        startTimer()
    }
    
    // MARK: - Question Navigation
    
    private func loadFirstQuestion() {
        guard let attempt = currentAttempt,
              let firstQuestionId = attempt.questionsOrder.first,
              let test = service.getTest(by: attempt.testId),
              let question = test.questions.first(where: { $0.id == firstQuestionId }) else { return }
        
        currentQuestion = question
    }
    
    private func loadQuestion(at index: Int) {
        guard let attempt = currentAttempt,
              index >= 0 && index < attempt.questionsOrder.count,
              let test = service.getTest(by: attempt.testId),
              let question = test.questions.first(where: { $0.id == attempt.questionsOrder[index] }) else { return }
        
        currentQuestion = question
    }
    
    func nextQuestion() {
        guard hasNextQuestion else { return }
        loadQuestion(at: currentQuestionIndex + 1)
    }
    
    func previousQuestion() {
        guard hasPreviousQuestion else { return }
        loadQuestion(at: currentQuestionIndex - 1)
    }
    
    func goToQuestion(at index: Int) {
        loadQuestion(at: index)
    }
    
    // MARK: - Answer Management
    
    func saveCurrentAnswer(_ answer: UserAnswer) {
        guard let attemptId = currentAttempt?.id else { return }
        service.saveAnswer(attemptId: attemptId, answer: answer)
    }
    
    func markCurrentQuestion() {
        guard let attemptId = currentAttempt?.id,
              let questionId = currentQuestion?.id else { return }
        
        if let index = service.attempts.firstIndex(where: { $0.id == attemptId }) {
            service.attempts[index].markQuestion(questionId)
        }
    }
    
    func unmarkCurrentQuestion() {
        guard let attemptId = currentAttempt?.id,
              let questionId = currentQuestion?.id else { return }
        
        if let index = service.attempts.firstIndex(where: { $0.id == attemptId }) {
            service.attempts[index].unmarkQuestion(questionId)
        }
    }
    
    func isCurrentQuestionMarked() -> Bool {
        guard let attempt = currentAttempt,
              let questionId = currentQuestion?.id else { return false }
        return attempt.isQuestionMarked(questionId)
    }
    
    func getCurrentAnswer() -> UserAnswer? {
        guard let attempt = currentAttempt,
              let questionId = currentQuestion?.id else { return nil }
        return attempt.getAnswer(for: questionId)
    }
    
    // MARK: - Test Submission
    
    func submitTest() {
        guard let attemptId = currentAttempt?.id else { return }
        stopTimer()
        
        if let result = service.submitTest(attemptId: attemptId) {
            // Переход к результатам
            currentAttempt = nil
            currentQuestion = nil
            // В реальном приложении показать экран с результатами
        }
    }
    
    // MARK: - Timer Management
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.updateTimer()
            }
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func updateTimer() {
        guard let attemptId = currentAttempt?.id,
              let index = service.attempts.firstIndex(where: { $0.id == attemptId }) else {
            stopTimer()
            return
        }
        
        var attempt = service.attempts[index]
        attempt.timeSpentSeconds += 1
        
        if let remaining = attempt.remainingTimeSeconds {
            attempt.remainingTimeSeconds = max(0, remaining - 1)
            
            if attempt.remainingTimeSeconds == 0 {
                // Время истекло - автоматическая отправка
                submitTest()
                return
            }
        }
        
        service.attempts[index] = attempt
        currentAttempt = attempt
    }
    
    // MARK: - Statistics
    
    func getTestStatistics(_ test: Test) -> (attempts: Int, avgScore: Double, passRate: Double) {
        let results = service.getTestResults(testId: test.id)
        let userAttempts = service.getUserAttempts(userId: currentUserId, testId: test.id)
        
        let analytics = TestAnalytics(results: results)
        
        return (
            attempts: userAttempts.count,
            avgScore: analytics.averageScore,
            passRate: analytics.passRate
        )
    }
    
    func getUserTestResult(_ test: Test) -> TestResult? {
        userResults.filter { $0.testId == test.id }
            .sorted { $0.completedAt > $1.completedAt }
            .first
    }
    
    func canRetakeTest(_ test: Test) -> Bool {
        let attempts = service.getUserAttempts(userId: currentUserId, testId: test.id)
        
        if let maxAttempts = test.attemptsAllowed {
            return attempts.count < maxAttempts
        }
        
        return true // Неограниченные попытки
    }
    
    // MARK: - Cleanup
    
    func cleanup() {
        stopTimer()
    }
} 