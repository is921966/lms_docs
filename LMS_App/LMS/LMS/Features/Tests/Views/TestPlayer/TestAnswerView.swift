//
//  TestAnswerView.swift
//  LMS
//
//  Created on 26/01/2025.
//

import SwiftUI

struct TestAnswerView: View {
    let question: Question
    @Binding var answerState: AnswerState

    var body: some View {
        Group {
            switch question.type {
            case .singleChoice, .trueFalse:
                SingleChoiceAnswerView(
                    options: question.options,
                    selectedAnswers: $answerState.selectedAnswers
                )
            case .multipleChoice:
                MultipleChoiceAnswerView(
                    options: question.options,
                    selectedAnswers: $answerState.selectedAnswers
                )
            case .textInput:
                TextInputAnswerView(
                    textAnswer: $answerState.textAnswer
                )
            case .matching:
                MatchingAnswerView(
                    matchingPairs: question.matchingPairs,
                    matchingAnswers: $answerState.matchingAnswers
                )
            case .ordering:
                OrderingAnswerView(
                    orderingAnswer: $answerState.orderingAnswer
                )
            case .fillInBlanks:
                FillInBlanksAnswerView(
                    textWithBlanks: question.textWithBlanks ?? "",
                    blanksAnswers: question.blanksAnswers,
                    fillInBlanksAnswers: $answerState.fillInBlanksAnswers
                )
                FillInBlanksAnswerView(
                    textWithBlanks: question.textWithBlanks ?? "",
                    blanksAnswers: [:],
                    fillInBlanksAnswers: $answerState.fillInBlanksAnswers
                )
            case .essay:
                EssayAnswerView(
                    essayAnswer: $answerState.essayAnswer
                )
            }
        }
    }
}
