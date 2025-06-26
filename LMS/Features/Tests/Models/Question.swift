//
//  Question.swift
//  LMS
//
//  Created on 26/01/2025.
//

import Foundation
import SwiftUI

enum QuestionType: String, CaseIterable, Codable {
    case singleChoice = "Одиночный выбор"
    case multipleChoice = "Множественный выбор"
    case trueFalse = "Правда/Ложь"
    case textInput = "Текстовый ввод"
    case matching = "Сопоставление"
    case ordering = "Упорядочивание"
    case fillInBlanks = "Заполнить пропуски"
    case essay = "Эссе"
    
    var icon: String {
        switch self {
        case .singleChoice: return "circle"
        case .multipleChoice: return "square"
        case .trueFalse: return "checkmark.circle"
        case .textInput: return "text.cursor"
        case .matching: return "arrow.left.and.right"
        case .ordering: return "arrow.up.arrow.down"
        case .fillInBlanks: return "text.badge.plus"
        case .essay: return "doc.text"
        }
    }
    
    var requiresManualCheck: Bool {
        switch self {
        case .essay, .textInput:
            return true
        default:
            return false
        }
    }
}

struct Question: Identifiable, Codable {
    let id: UUID
    var text: String
    var type: QuestionType
    var points: Double
    var explanation: String? // Объяснение правильного ответа
    var hint: String? // Подсказка
    var imageUrl: String? // Изображение к вопросу
    
    // Варианты ответов (для выбора)
    var options: [AnswerOption]
    
    // Для текстовых ответов
    var acceptedAnswers: [String] // Принимаемые варианты ответа
    var caseSensitive: Bool
    
    // Для сопоставления
    var matchingPairs: [MatchingPair]
    
    // Для упорядочивания
    var correctOrder: [String]
    
    // Для заполнения пропусков
    var textWithBlanks: String? // Текст с маркерами [blank1], [blank2]
    var blanksAnswers: [String: [String]] // blank1: ["ответ1", "ответ2"]
    
    // Metadata
    var isRequired: Bool
    var shuffleOptions: Bool
    var attachments: [String] // URLs to attachments
    
    init(
        id: UUID = UUID(),
        text: String,
        type: QuestionType,
        points: Double = 1.0,
        explanation: String? = nil,
        hint: String? = nil,
        imageUrl: String? = nil,
        options: [AnswerOption] = [],
        acceptedAnswers: [String] = [],
        caseSensitive: Bool = false,
        matchingPairs: [MatchingPair] = [],
        correctOrder: [String] = [],
        textWithBlanks: String? = nil,
        blanksAnswers: [String: [String]] = [:],
        isRequired: Bool = true,
        shuffleOptions: Bool = true,
        attachments: [String] = []
    ) {
        self.id = id
        self.text = text
        self.type = type
        self.points = points
        self.explanation = explanation
        self.hint = hint
        self.imageUrl = imageUrl
        self.options = options
        self.acceptedAnswers = acceptedAnswers
        self.caseSensitive = caseSensitive
        self.matchingPairs = matchingPairs
        self.correctOrder = correctOrder
        self.textWithBlanks = textWithBlanks
        self.blanksAnswers = blanksAnswers
        self.isRequired = isRequired
        self.shuffleOptions = shuffleOptions
        self.attachments = attachments
    }
    
    // Проверка ответа
    func checkAnswer(_ userAnswer: UserAnswer) -> AnswerCheckResult {
        switch type {
        case .singleChoice, .multipleChoice, .trueFalse:
            return checkChoiceAnswer(userAnswer)
        case .textInput:
            return checkTextAnswer(userAnswer)
        case .matching:
            return checkMatchingAnswer(userAnswer)
        case .ordering:
            return checkOrderingAnswer(userAnswer)
        case .fillInBlanks:
            return checkFillInBlanksAnswer(userAnswer)
        case .essay:
            // Эссе требует ручной проверки
            return AnswerCheckResult(isCorrect: nil, score: 0, feedback: "Требует проверки преподавателем")
        }
    }
    
    private func checkChoiceAnswer(_ userAnswer: UserAnswer) -> AnswerCheckResult {
        guard let selectedIds = userAnswer.selectedOptionIds else {
            return AnswerCheckResult(isCorrect: false, score: 0, feedback: "Не выбран ответ")
        }
        
        let correctIds = options.filter { $0.isCorrect }.map { $0.id }
        let isCorrect = Set(selectedIds) == Set(correctIds)
        let score = isCorrect ? points : 0
        
        return AnswerCheckResult(
            isCorrect: isCorrect,
            score: score,
            feedback: isCorrect ? "Правильно!" : "Неправильно",
            correctAnswer: options.filter { $0.isCorrect }.map { $0.text }.joined(separator: ", ")
        )
    }
    
    private func checkTextAnswer(_ userAnswer: UserAnswer) -> AnswerCheckResult {
        guard let text = userAnswer.textAnswer else {
            return AnswerCheckResult(isCorrect: false, score: 0, feedback: "Не введен ответ")
        }
        
        let isCorrect = acceptedAnswers.contains { answer in
            caseSensitive ? text == answer : text.lowercased() == answer.lowercased()
        }
        
        let score = isCorrect ? points : 0
        
        return AnswerCheckResult(
            isCorrect: isCorrect,
            score: score,
            feedback: isCorrect ? "Правильно!" : "Неправильно",
            correctAnswer: acceptedAnswers.first
        )
    }
    
    private func checkMatchingAnswer(_ userAnswer: UserAnswer) -> AnswerCheckResult {
        guard let matches = userAnswer.matchingAnswers else {
            return AnswerCheckResult(isCorrect: false, score: 0, feedback: "Не выполнено сопоставление")
        }
        
        var correctCount = 0
        for pair in matchingPairs {
            if matches[pair.left] == pair.right {
                correctCount += 1
            }
        }
        
        let isCorrect = correctCount == matchingPairs.count
        let score = points * (Double(correctCount) / Double(matchingPairs.count))
        
        return AnswerCheckResult(
            isCorrect: isCorrect,
            score: score,
            feedback: "Правильных сопоставлений: \(correctCount) из \(matchingPairs.count)"
        )
    }
    
    private func checkOrderingAnswer(_ userAnswer: UserAnswer) -> AnswerCheckResult {
        guard let order = userAnswer.orderingAnswer else {
            return AnswerCheckResult(isCorrect: false, score: 0, feedback: "Не выполнено упорядочивание")
        }
        
        let isCorrect = order == correctOrder
        let score = isCorrect ? points : 0
        
        return AnswerCheckResult(
            isCorrect: isCorrect,
            score: score,
            feedback: isCorrect ? "Правильный порядок!" : "Неправильный порядок"
        )
    }
    
    private func checkFillInBlanksAnswer(_ userAnswer: UserAnswer) -> AnswerCheckResult {
        guard let blanks = userAnswer.fillInBlanksAnswers else {
            return AnswerCheckResult(isCorrect: false, score: 0, feedback: "Не заполнены пропуски")
        }
        
        var correctCount = 0
        var totalBlanks = 0
        
        for (blankId, acceptedValues) in blanksAnswers {
            totalBlanks += 1
            if let userValue = blanks[blankId] {
                let isBlankCorrect = acceptedValues.contains { answer in
                    caseSensitive ? userValue == answer : userValue.lowercased() == answer.lowercased()
                }
                if isBlankCorrect {
                    correctCount += 1
                }
            }
        }
        
        let isCorrect = correctCount == totalBlanks
        let score = points * (Double(correctCount) / Double(totalBlanks))
        
        return AnswerCheckResult(
            isCorrect: isCorrect,
            score: score,
            feedback: "Правильных пропусков: \(correctCount) из \(totalBlanks)"
        )
    }
}

struct AnswerOption: Identifiable, Codable {
    let id: UUID
    var text: String
    var isCorrect: Bool
    var imageUrl: String?
    
    init(
        id: UUID = UUID(),
        text: String,
        isCorrect: Bool = false,
        imageUrl: String? = nil
    ) {
        self.id = id
        self.text = text
        self.isCorrect = isCorrect
        self.imageUrl = imageUrl
    }
}

struct MatchingPair: Codable {
    let id: UUID
    var left: String
    var right: String
    
    init(
        id: UUID = UUID(),
        left: String,
        right: String
    ) {
        self.id = id
        self.left = left
        self.right = right
    }
}

struct UserAnswer: Codable {
    let questionId: UUID
    var selectedOptionIds: [UUID]? // Для выбора
    var textAnswer: String? // Для текста
    var matchingAnswers: [String: String]? // Для сопоставления
    var orderingAnswer: [String]? // Для упорядочивания
    var fillInBlanksAnswers: [String: String]? // Для пропусков
    var essayAnswer: String? // Для эссе
}

struct AnswerCheckResult {
    let isCorrect: Bool?
    let score: Double
    let feedback: String
    let correctAnswer: String?
    
    init(
        isCorrect: Bool?,
        score: Double,
        feedback: String,
        correctAnswer: String? = nil
    ) {
        self.isCorrect = isCorrect
        self.score = score
        self.feedback = feedback
        self.correctAnswer = correctAnswer
    }
} 