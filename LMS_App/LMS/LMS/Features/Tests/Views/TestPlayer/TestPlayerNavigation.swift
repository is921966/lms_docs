//
//  TestPlayerNavigation.swift
//  LMS
//
//  Created on 26/01/2025.
//

import SwiftUI

struct TestPlayerNavigation: View {
    @ObservedObject var viewModel: TestViewModel
    @Binding var showSubmitAlert: Bool
    let saveAnswer: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            Divider()
            
            HStack(spacing: 20) {
                // Previous button
                Button(action: {
                    saveAnswer()
                    viewModel.previousQuestion()
                }) {
                    Label("Назад", systemImage: "chevron.left")
                }
                .buttonStyle(.bordered)
                .disabled(!viewModel.hasPreviousQuestion)
                
                Spacer()
                
                // Question navigation
                TestQuestionMenu(
                    viewModel: viewModel,
                    saveAnswer: saveAnswer
                )
                
                Spacer()
                
                // Next/Submit button
                if viewModel.isLastQuestion {
                    Button(action: {
                        saveAnswer()
                        showSubmitAlert = true
                    }) {
                        Label("Завершить", systemImage: "checkmark.circle")
                    }
                    .buttonStyle(.borderedProminent)
                } else {
                    Button(action: {
                        saveAnswer()
                        viewModel.nextQuestion()
                    }) {
                        Label("Далее", systemImage: "chevron.right")
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            .padding()
        }
        .background(Color(UIColor.systemBackground))
    }
}

struct TestQuestionMenu: View {
    @ObservedObject var viewModel: TestViewModel
    let saveAnswer: () -> Void
    
    var body: some View {
        Menu {
            ForEach(0..<viewModel.totalQuestions, id: \.self) { index in
                Button(action: {
                    saveAnswer()
                    viewModel.goToQuestion(at: index)
                }) {
                    HStack {
                        Text("Вопрос \(index + 1)")
                        if isQuestionAnswered(at: index) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                        }
                        if isQuestionMarked(at: index) {
                            Image(systemName: "bookmark.fill")
                                .foregroundColor(.orange)
                        }
                    }
                }
            }
        } label: {
            Label("Перейти", systemImage: "list.bullet")
        }
        .buttonStyle(.bordered)
    }
    
    private func isQuestionAnswered(at index: Int) -> Bool {
        guard let attempt = viewModel.currentAttempt,
              index < attempt.questionsOrder.count else { return false }
        let questionId = attempt.questionsOrder[index]
        return attempt.isQuestionAnswered(questionId)
    }
    
    private func isQuestionMarked(at index: Int) -> Bool {
        guard let attempt = viewModel.currentAttempt,
              index < attempt.questionsOrder.count else { return false }
        let questionId = attempt.questionsOrder[index]
        return attempt.isQuestionMarked(questionId)
    }
}
