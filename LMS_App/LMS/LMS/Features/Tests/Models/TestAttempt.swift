//
//  TestAttempt.swift
//  LMS
//
//  Created on 26/01/2025.
//

import Foundation
import SwiftUI

enum AttemptStatus: String, CaseIterable, Codable {
    case notStarted = "Не начат"
    case inProgress = "В процессе"
    case completed = "Завершен"
    case submitted = "Отправлен"
    case graded = "Оценен"
    case abandoned = "Прерван"
    
    var color: Color {
        switch self {
        case .notStarted: return .gray
        case .inProgress: return .blue
        case .completed: return .green
        case .submitted: return .orange
        case .graded: return .purple
        case .abandoned: return .red
        }
    }
    
    var icon: String {
        switch self {
        case .notStarted: return "circle"
        case .inProgress: return "timer"
        case .completed: return "checkmark.circle"
        case .submitted: return "paperplane"
        case .graded: return "checkmark.seal"
        case .abandoned: return "xmark.circle"
        }
    }
}

struct TestAttempt: Identifiable, Codable {
    let id: UUID
    let testId: UUID
    let userId: String
    var attemptNumber: Int
    
    // Status
    var status: AttemptStatus
    
    // Timing
    var startedAt: Date?
    var completedAt: Date?
    var timeSpentSeconds: Int
    var remainingTimeSeconds: Int? // Для тестов с ограничением времени
    
    // Content
    var questionsOrder: [UUID] // Порядок вопросов для этой попытки
    var currentQuestionIndex: Int
    var answers: [UserAnswer]
    var markedQuestions: Set<UUID> // Помеченные вопросы
    
    // Results
    var totalScore: Double?
    var maxScore: Double?
    var percentage: Double?
    var isPassed: Bool?
    var gradedBy: String? // Кто проверил (для ручной проверки)
    var gradedAt: Date?
    var feedback: String? // Общий комментарий
    
    init(
        id: UUID = UUID(),
        testId: UUID,
        userId: String,
        attemptNumber: Int = 1,
        status: AttemptStatus = .notStarted,
        startedAt: Date? = nil,
        completedAt: Date? = nil,
        timeSpentSeconds: Int = 0,
        remainingTimeSeconds: Int? = nil,
        questionsOrder: [UUID] = [],
        currentQuestionIndex: Int = 0,
        answers: [UserAnswer] = [],
        markedQuestions: Set<UUID> = [],
        totalScore: Double? = nil,
        maxScore: Double? = nil,
        percentage: Double? = nil,
        isPassed: Bool? = nil,
        gradedBy: String? = nil,
        gradedAt: Date? = nil,
        feedback: String? = nil
    ) {
        self.id = id
        self.testId = testId
        self.userId = userId
        self.attemptNumber = attemptNumber
        self.status = status
        self.startedAt = startedAt
        self.completedAt = completedAt
        self.timeSpentSeconds = timeSpentSeconds
        self.remainingTimeSeconds = remainingTimeSeconds
        self.questionsOrder = questionsOrder
        self.currentQuestionIndex = currentQuestionIndex
        self.answers = answers
        self.markedQuestions = markedQuestions
        self.totalScore = totalScore
        self.maxScore = maxScore
        self.percentage = percentage
        self.isPassed = isPassed
        self.gradedBy = gradedBy
        self.gradedAt = gradedAt
        self.feedback = feedback
    }
    
    // Computed properties
    var isActive: Bool {
        status == .inProgress
    }
    
    var isFinished: Bool {
        status == .completed || status == .submitted || status == .graded
    }
    
    var canResume: Bool {
        status == .inProgress && remainingTimeSeconds ?? 1 > 0
    }
    
    var answeredQuestionsCount: Int {
        answers.count
    }
    
    var totalQuestionsCount: Int {
        questionsOrder.count
    }
    
    var progress: Double {
        guard totalQuestionsCount > 0 else { return 0 }
        return Double(answeredQuestionsCount) / Double(totalQuestionsCount)
    }
    
    var formattedTimeSpent: String {
        let hours = timeSpentSeconds / 3600
        let minutes = (timeSpentSeconds % 3600) / 60
        let seconds = timeSpentSeconds % 60
        
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%d:%02d", minutes, seconds)
        }
    }
    
    var formattedRemainingTime: String? {
        guard let remaining = remainingTimeSeconds else { return nil }
        let minutes = remaining / 60
        let seconds = remaining % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    var scoreText: String? {
        guard let score = totalScore, let max = maxScore else { return nil }
        return String(format: "%.1f / %.1f", score, max)
    }
    
    var percentageText: String? {
        guard let percentage = percentage else { return nil }
        return String(format: "%.1f%%", percentage)
    }
    
    // Methods
    mutating func start(with questionsOrder: [UUID], timeLimit: Int?) {
        self.status = .inProgress
        self.startedAt = Date()
        self.questionsOrder = questionsOrder
        self.remainingTimeSeconds = timeLimit.map { $0 * 60 }
    }
    
    mutating func saveAnswer(_ answer: UserAnswer) {
        // Удаляем старый ответ на этот вопрос, если есть
        answers.removeAll { $0.questionId == answer.questionId }
        answers.append(answer)
    }
    
    mutating func markQuestion(_ questionId: UUID) {
        markedQuestions.insert(questionId)
    }
    
    mutating func unmarkQuestion(_ questionId: UUID) {
        markedQuestions.remove(questionId)
    }
    
    mutating func updateTime(elapsed: Int, remaining: Int?) {
        self.timeSpentSeconds = elapsed
        self.remainingTimeSeconds = remaining
    }
    
    mutating func complete() {
        self.status = .completed
        self.completedAt = Date()
    }
    
    mutating func submit() {
        self.status = .submitted
        if completedAt == nil {
            self.completedAt = Date()
        }
    }
    
    mutating func abandon() {
        self.status = .abandoned
        self.completedAt = Date()
    }
    
    mutating func grade(score: Double, maxScore: Double, isPassed: Bool, gradedBy: String, feedback: String?) {
        self.status = .graded
        self.totalScore = score
        self.maxScore = maxScore
        self.percentage = (score / maxScore) * 100
        self.isPassed = isPassed
        self.gradedBy = gradedBy
        self.gradedAt = Date()
        self.feedback = feedback
    }
    
    func getAnswer(for questionId: UUID) -> UserAnswer? {
        answers.first { $0.questionId == questionId }
    }
    
    func isQuestionAnswered(_ questionId: UUID) -> Bool {
        answers.contains { $0.questionId == questionId }
    }
    
    func isQuestionMarked(_ questionId: UUID) -> Bool {
        markedQuestions.contains(questionId)
    }
} 