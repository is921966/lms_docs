//
//  AnswerState.swift
//  LMS
//
//  Created on 26/01/2025.
//

import Foundation

struct AnswerState {
    var selectedAnswers: Set<UUID> = []
    var textAnswer = ""
    var matchingAnswers: [String: String] = [:]
    var orderingAnswer: [String] = []
    var fillInBlanksAnswers: [String: String] = [:]
    var essayAnswer = ""
    
    func toUserAnswer(for question: Question) -> UserAnswer {
        var answer = UserAnswer(questionId: question.id)
        
        switch question.type {
        case .singleChoice, .multipleChoice, .trueFalse:
            answer.selectedOptionIds = Array(selectedAnswers)
        case .textInput:
            answer.textAnswer = textAnswer
        case .matching:
            answer.matchingAnswers = matchingAnswers
        case .ordering:
            answer.orderingAnswer = orderingAnswer
        case .fillInBlanks:
            answer.fillInBlanksAnswers = fillInBlanksAnswers
        case .essay:
            answer.essayAnswer = essayAnswer
        }
        
        return answer
    }
    
    mutating func loadFrom(_ userAnswer: UserAnswer, question: Question) {
        switch question.type {
        case .singleChoice, .multipleChoice, .trueFalse:
            selectedAnswers = Set(userAnswer.selectedOptionIds ?? [])
        case .textInput:
            textAnswer = userAnswer.textAnswer ?? ""
        case .matching:
            matchingAnswers = userAnswer.matchingAnswers ?? [:]
        case .ordering:
            orderingAnswer = userAnswer.orderingAnswer ?? question.correctOrder.shuffled()
        case .fillInBlanks:
            fillInBlanksAnswers = userAnswer.fillInBlanksAnswers ?? [:]
        case .essay:
            essayAnswer = userAnswer.essayAnswer ?? ""
        }
    }
} 