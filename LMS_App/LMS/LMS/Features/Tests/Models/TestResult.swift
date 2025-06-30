//
//  TestResult.swift
//  LMS
//
//  Created on 26/01/2025.
//

import Foundation
import SwiftUI

struct TestResult: Identifiable, Codable {
    let id: UUID
    let attemptId: UUID
    let testId: UUID
    let userId: String

    // Overall results
    var totalScore: Double
    var maxScore: Double
    var percentage: Double
    var isPassed: Bool
    var passingScore: Double

    // Detailed results by question
    var questionResults: [QuestionResult]

    // Time statistics
    var totalTimeSeconds: Int
    var averageTimePerQuestion: Int

    // Analysis
    var strengthCompetencies: [String] // Компетенции с высокими результатами
    var weaknessCompetencies: [String] // Компетенции для улучшения
    var recommendedCourses: [String] // Рекомендуемые курсы
    var certificateId: String? // ID сертификата, если выдан

    // Metadata
    var completedAt: Date
    var gradedAt: Date?
    var gradedBy: String?

    init(
        id: UUID = UUID(),
        attemptId: UUID,
        testId: UUID,
        userId: String,
        totalScore: Double,
        maxScore: Double,
        percentage: Double,
        isPassed: Bool,
        passingScore: Double,
        questionResults: [QuestionResult],
        totalTimeSeconds: Int,
        averageTimePerQuestion: Int,
        strengthCompetencies: [String] = [],
        weaknessCompetencies: [String] = [],
        recommendedCourses: [String] = [],
        certificateId: String? = nil,
        completedAt: Date = Date(),
        gradedAt: Date? = nil,
        gradedBy: String? = nil
    ) {
        self.id = id
        self.attemptId = attemptId
        self.testId = testId
        self.userId = userId
        self.totalScore = totalScore
        self.maxScore = maxScore
        self.percentage = percentage
        self.isPassed = isPassed
        self.passingScore = passingScore
        self.questionResults = questionResults
        self.totalTimeSeconds = totalTimeSeconds
        self.averageTimePerQuestion = averageTimePerQuestion
        self.strengthCompetencies = strengthCompetencies
        self.weaknessCompetencies = weaknessCompetencies
        self.recommendedCourses = recommendedCourses
        self.certificateId = certificateId
        self.completedAt = completedAt
        self.gradedAt = gradedAt
        self.gradedBy = gradedBy
    }

    // Computed properties
    var scoreText: String {
        String(format: "%.1f / %.1f", totalScore, maxScore)
    }

    var percentageText: String {
        String(format: "%.1f%%", percentage)
    }

    var resultColor: Color {
        isPassed ? .green : .red
    }

    var resultIcon: String {
        isPassed ? "checkmark.circle.fill" : "xmark.circle.fill"
    }

    var resultText: String {
        isPassed ? "Тест пройден" : "Тест не пройден"
    }

    var formattedTime: String {
        let hours = totalTimeSeconds / 3_600
        let minutes = (totalTimeSeconds % 3_600) / 60
        let seconds = totalTimeSeconds % 60

        if hours > 0 {
            return String(format: "%d ч %d мин %d сек", hours, minutes, seconds)
        } else if minutes > 0 {
            return String(format: "%d мин %d сек", minutes, seconds)
        } else {
            return String(format: "%d сек", seconds)
        }
    }

    var correctAnswersCount: Int {
        questionResults.filter { $0.isCorrect ?? false }.count
    }

    var incorrectAnswersCount: Int {
        questionResults.filter { $0.isCorrect == false }.count
    }

    var pendingReviewCount: Int {
        questionResults.filter { $0.isCorrect == nil }.count
    }

    var questionsByType: [QuestionType: [QuestionResult]] {
        Dictionary(grouping: questionResults, by: { $0.questionType })
    }

    var scoreByType: [QuestionType: Double] {
        var scores: [QuestionType: Double] = [:]
        for (type, results) in questionsByType {
            let earned = results.reduce(0) { $0 + $1.earnedScore }
            let max = results.reduce(0) { $0 + $1.maxScore }
            scores[type] = max > 0 ? (earned / max) * 100 : 0
        }
        return scores
    }

    var hasCertificate: Bool {
        certificateId != nil
    }
}

struct QuestionResult: Identifiable, Codable {
    let id: UUID
    let questionId: UUID
    let questionText: String
    let questionType: QuestionType

    // Answer details
    var userAnswer: UserAnswer
    var isCorrect: Bool?
    var earnedScore: Double
    var maxScore: Double
    var feedback: String?
    var correctAnswer: String?

    // Time
    var timeSpentSeconds: Int

    // Competencies
    var relatedCompetencies: [String]

    init(
        id: UUID = UUID(),
        questionId: UUID,
        questionText: String,
        questionType: QuestionType,
        userAnswer: UserAnswer,
        isCorrect: Bool?,
        earnedScore: Double,
        maxScore: Double,
        feedback: String? = nil,
        correctAnswer: String? = nil,
        timeSpentSeconds: Int = 0,
        relatedCompetencies: [String] = []
    ) {
        self.id = id
        self.questionId = questionId
        self.questionText = questionText
        self.questionType = questionType
        self.userAnswer = userAnswer
        self.isCorrect = isCorrect
        self.earnedScore = earnedScore
        self.maxScore = maxScore
        self.feedback = feedback
        self.correctAnswer = correctAnswer
        self.timeSpentSeconds = timeSpentSeconds
        self.relatedCompetencies = relatedCompetencies
    }

    // Computed properties
    var percentage: Double {
        maxScore > 0 ? (earnedScore / maxScore) * 100 : 0
    }

    var scoreText: String {
        String(format: "%.1f / %.1f", earnedScore, maxScore)
    }

    var resultColor: Color {
        guard let correct = isCorrect else { return .orange }
        return correct ? .green : .red
    }

    var resultIcon: String {
        guard let correct = isCorrect else { return "questionmark.circle" }
        return correct ? "checkmark.circle" : "xmark.circle"
    }
}

// Analytics helper
struct TestAnalytics {
    let results: [TestResult]

    var averageScore: Double {
        guard !results.isEmpty else { return 0 }
        return results.reduce(0) { $0 + $1.percentage } / Double(results.count)
    }

    var passRate: Double {
        guard !results.isEmpty else { return 0 }
        let passed = results.filter { $0.isPassed }.count
        return (Double(passed) / Double(results.count)) * 100
    }

    var averageTime: Int {
        guard !results.isEmpty else { return 0 }
        return results.reduce(0) { $0 + $1.totalTimeSeconds } / results.count
    }

    var mostDifficultQuestions: [UUID] {
        var questionStats: [UUID: (correct: Int, total: Int)] = [:]

        for result in results {
            for question in result.questionResults {
                var stat = questionStats[question.questionId] ?? (0, 0)
                stat.total += 1
                if question.isCorrect == true {
                    stat.correct += 1
                }
                questionStats[question.questionId] = stat
            }
        }

        return questionStats
            .filter { $0.value.total >= 5 } // Минимум 5 попыток
            .sorted {
                let rate1 = Double($0.value.correct) / Double($0.value.total)
                let rate2 = Double($1.value.correct) / Double($1.value.total)
                return rate1 < rate2
            }
            .prefix(10)
            .map { $0.key }
    }
}
