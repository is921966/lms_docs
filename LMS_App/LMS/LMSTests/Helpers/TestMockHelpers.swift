//
//  TestMockHelpers.swift
//  LMSTests
//
//  Created on 06/07/2025.
//

import Foundation
@testable import LMS

extension Test {
    static func mockQuiz() -> Test {
        Test(
            id: UUID(),
            title: "Quiz: iOS Fundamentals",
            description: "Test your knowledge of iOS development basics",
            type: .quiz,
            status: .published,
            difficulty: .medium,
            questions: [
                Question.mockMultipleChoice(),
                Question.mockMultipleChoice(),
                Question.mockMultipleChoice(),
                Question.mockTrueFalse(),
                Question.mockTrueFalse()
            ],
            shuffleQuestions: true,
            questionsPerAttempt: nil,
            timeLimit: 30,
            attemptsAllowed: 3,
            passingScore: 70.0,
            showCorrectAnswers: true,
            showResultsImmediately: true,
            courseId: "course-1",
            lessonId: "lesson-1",
            competencyIds: ["comp-1", "comp-2"],
            positionIds: ["pos-1"],
            createdBy: "admin-1",
            createdAt: Date().addingTimeInterval(-86400 * 7),
            updatedAt: Date().addingTimeInterval(-86400),
            publishedAt: Date().addingTimeInterval(-86400),
            totalAttempts: 25,
            averageScore: 78.5,
            passRate: 0.72
        )
    }
    
    static func mockExam() -> Test {
        Test(
            id: UUID(),
            title: "Final Exam: Advanced iOS",
            description: "Comprehensive exam covering all advanced iOS topics",
            type: .exam,
            status: .published,
            difficulty: .hard,
            questions: [
                Question.mockMultipleChoice(),
                Question.mockMultipleChoice(),
                Question.mockMultipleChoice(),
                Question.mockTrueFalse(),
                Question.mockTrueFalse(),
                Question.mockTextAnswer(),
                Question.mockTextAnswer(),
                Question.mockCodeAnswer()
            ],
            shuffleQuestions: false,
            questionsPerAttempt: nil,
            timeLimit: 90,
            attemptsAllowed: 1,
            passingScore: 80.0,
            showCorrectAnswers: false,
            showResultsImmediately: false,
            courseId: "course-2",
            lessonId: nil,
            competencyIds: ["comp-3", "comp-4", "comp-5"],
            positionIds: ["pos-2", "pos-3"],
            createdBy: "admin-1",
            createdAt: Date().addingTimeInterval(-86400 * 14),
            updatedAt: Date().addingTimeInterval(-86400 * 2),
            publishedAt: Date().addingTimeInterval(-86400 * 2),
            totalAttempts: 15,
            averageScore: 82.3,
            passRate: 0.67
        )
    }
}

// Extension for Question mocks
extension Question {
    static func mockMultipleChoice() -> Question {
        Question(
            id: UUID(),
            text: "Which of the following is a reference type in Swift?",
            type: .multipleChoice,
            points: 10.0,
            explanation: "Classes are reference types in Swift, while structs and enums are value types.",
            hint: "Think about memory management",
            imageUrl: nil,
            options: [
                AnswerOption(text: "Struct", isCorrect: false),
                AnswerOption(text: "Enum", isCorrect: false),
                AnswerOption(text: "Class", isCorrect: true),
                AnswerOption(text: "Protocol", isCorrect: false)
            ],
            acceptedAnswers: [],
            caseSensitive: false,
            matchingPairs: [],
            correctOrder: [],
            textWithBlanks: nil,
            blanksAnswers: [:],
            isRequired: true,
            shuffleOptions: true,
            attachments: []
        )
    }
    
    static func mockTrueFalse() -> Question {
        Question(
            id: UUID(),
            text: "Swift uses Automatic Reference Counting (ARC) for memory management.",
            type: .trueFalse,
            points: 5.0,
            explanation: "Swift does use ARC to track and manage your app's memory usage.",
            hint: nil,
            imageUrl: nil,
            options: [
                AnswerOption(text: "True", isCorrect: true),
                AnswerOption(text: "False", isCorrect: false)
            ],
            acceptedAnswers: [],
            caseSensitive: false,
            matchingPairs: [],
            correctOrder: [],
            textWithBlanks: nil,
            blanksAnswers: [:],
            isRequired: true,
            shuffleOptions: false,
            attachments: []
        )
    }
    
    static func mockTextAnswer() -> Question {
        Question(
            id: UUID(),
            text: "What is the main difference between a struct and a class in Swift?",
            type: .textInput,
            points: 15.0,
            explanation: "Structs are value types while classes are reference types.",
            hint: "Think about how they are stored in memory",
            imageUrl: nil,
            options: [],
            acceptedAnswers: [
                "Structs are value types, classes are reference types",
                "Struct is value type, class is reference type",
                "Value type vs reference type"
            ],
            caseSensitive: false,
            matchingPairs: [],
            correctOrder: [],
            textWithBlanks: nil,
            blanksAnswers: [:],
            isRequired: true,
            shuffleOptions: false,
            attachments: []
        )
    }
    
    static func mockCodeAnswer() -> Question {
        Question(
            id: UUID(),
            text: "Write a function that reverses an array of integers without using the built-in reverse() method.",
            type: .essay,
            points: 20.0,
            explanation: "One solution is to use two pointers and swap elements from both ends.",
            hint: "Consider using two pointers approach",
            imageUrl: nil,
            options: [],
            acceptedAnswers: [],
            caseSensitive: false,
            matchingPairs: [],
            correctOrder: [],
            textWithBlanks: nil,
            blanksAnswers: [:],
            isRequired: true,
            shuffleOptions: false,
            attachments: []
        )
    }
} 