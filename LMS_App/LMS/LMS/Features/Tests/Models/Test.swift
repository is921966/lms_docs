//
//  Test.swift
//  LMS
//
//  Created on 26/01/2025.
//

import Foundation
import SwiftUI

enum TestType: String, CaseIterable, Codable {
    case quiz = "Викторина"
    case exam = "Экзамен"
    case assessment = "Оценка знаний"
    case practice = "Практика"
    case certification = "Сертификация"
    
    var icon: String {
        switch self {
        case .quiz: return "questionmark.circle"
        case .exam: return "doc.text.magnifyingglass"
        case .assessment: return "checkmark.seal"
        case .practice: return "pencil.and.outline"
        case .certification: return "seal"
        }
    }
    
    var color: Color {
        switch self {
        case .quiz: return .blue
        case .exam: return .red
        case .assessment: return .orange
        case .practice: return .green
        case .certification: return .purple
        }
    }
}

enum TestStatus: String, CaseIterable, Codable {
    case draft = "Черновик"
    case published = "Опубликован"
    case archived = "В архиве"
    
    var color: Color {
        switch self {
        case .draft: return .gray
        case .published: return .green
        case .archived: return .orange
        }
    }
}

enum TestDifficulty: String, CaseIterable, Codable {
    case easy = "Легкий"
    case medium = "Средний"
    case hard = "Сложный"
    case expert = "Экспертный"
    
    var color: Color {
        switch self {
        case .easy: return .green
        case .medium: return .blue
        case .hard: return .orange
        case .expert: return .red
        }
    }
    
    var icon: String {
        switch self {
        case .easy: return "1.circle"
        case .medium: return "2.circle"
        case .hard: return "3.circle"
        case .expert: return "star.circle"
        }
    }
}

struct Test: Identifiable, Codable {
    let id: UUID
    var title: String
    var description: String
    var type: TestType
    var status: TestStatus
    var difficulty: TestDifficulty
    
    // Content
    var questions: [Question]
    var shuffleQuestions: Bool
    var questionsPerAttempt: Int? // nil = все вопросы
    
    // Settings
    var timeLimit: Int? // в минутах, nil = без ограничения
    var attemptsAllowed: Int? // nil = неограниченно
    var passingScore: Double // в процентах (0-100)
    var showCorrectAnswers: Bool
    var showResultsImmediately: Bool
    
    // Relations
    var courseId: String? // Связь с курсом
    var lessonId: String? // Связь с уроком
    var competencyIds: [String] // Связанные компетенции
    var positionIds: [String] // Для каких должностей
    
    // Metadata
    var createdBy: String
    var createdAt: Date
    var updatedAt: Date
    var publishedAt: Date?
    
    // Statistics
    var totalAttempts: Int
    var averageScore: Double
    var passRate: Double
    
    init(
        id: UUID = UUID(),
        title: String,
        description: String,
        type: TestType = .quiz,
        status: TestStatus = .draft,
        difficulty: TestDifficulty = .medium,
        questions: [Question] = [],
        shuffleQuestions: Bool = false,
        questionsPerAttempt: Int? = nil,
        timeLimit: Int? = nil,
        attemptsAllowed: Int? = nil,
        passingScore: Double = 70.0,
        showCorrectAnswers: Bool = true,
        showResultsImmediately: Bool = true,
        courseId: String? = nil,
        lessonId: String? = nil,
        competencyIds: [String] = [],
        positionIds: [String] = [],
        createdBy: String,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        publishedAt: Date? = nil,
        totalAttempts: Int = 0,
        averageScore: Double = 0.0,
        passRate: Double = 0.0
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.type = type
        self.status = status
        self.difficulty = difficulty
        self.questions = questions
        self.shuffleQuestions = shuffleQuestions
        self.questionsPerAttempt = questionsPerAttempt
        self.timeLimit = timeLimit
        self.attemptsAllowed = attemptsAllowed
        self.passingScore = passingScore
        self.showCorrectAnswers = showCorrectAnswers
        self.showResultsImmediately = showResultsImmediately
        self.courseId = courseId
        self.lessonId = lessonId
        self.competencyIds = competencyIds
        self.positionIds = positionIds
        self.createdBy = createdBy
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.publishedAt = publishedAt
        self.totalAttempts = totalAttempts
        self.averageScore = averageScore
        self.passRate = passRate
    }
    
    // Computed properties
    var totalQuestions: Int {
        questions.count
    }
    
    var totalPoints: Double {
        questions.reduce(0) { $0 + $1.points }
    }
    
    var estimatedTime: String {
        if let limit = timeLimit {
            return "\(limit) мин"
        } else {
            // Оценка времени: 1-2 минуты на вопрос
            let minutes = totalQuestions * 2
            return "~\(minutes) мин"
        }
    }
    
    var isPublished: Bool {
        status == .published
    }
    
    var canBeTaken: Bool {
        isPublished && !questions.isEmpty
    }
} 