//
//  TestPlayerView.swift
//  LMS
//
//  Created on 26/01/2025.
//

import SwiftUI

struct TestPlayerView: View {
    let test: Test
    @ObservedObject var viewModel: TestViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showExitAlert = false
    @State private var showSubmitAlert = false
    @State private var showTimeWarning = false
    @State private var answerState = AnswerState()
    
    var body: some View {
        NavigationView {
            if viewModel.currentQuestion != nil && viewModel.currentAttempt != nil {
                VStack(spacing: 0) {
                    // Progress and timer
                    TestPlayerHeader(
                        viewModel: viewModel,
                        isTimeRunningOut: isTimeRunningOut
                    )
                    
                    // Question content
                    ScrollView {
                        VStack(alignment: .leading, spacing: 20) {
                            TestQuestionView(
                                question: viewModel.currentQuestion!,
                                points: Int(viewModel.currentQuestion!.points)
                            )
                            
                            TestAnswerView(
                                question: viewModel.currentQuestion!,
                                answerState: $answerState
                            )
                        }
                        .padding()
                    }
                    
                    // Navigation controls
                    TestPlayerNavigation(
                        viewModel: viewModel,
                        showSubmitAlert: $showSubmitAlert,
                        saveAnswer: saveCurrentAnswer
                    )
                }
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Выход") {
                            showExitAlert = true
                        }
                    }
                    
                    ToolbarItem(placement: .navigationBarTrailing) {
                        TestBookmarkButton(viewModel: viewModel)
                    }
                }
                .alert("Выйти из теста?", isPresented: $showExitAlert) {
                    Button("Отмена", role: .cancel) { }
                    Button("Сохранить и выйти", role: .destructive) {
                        saveCurrentAnswer()
                        dismiss()
                    }
                    Button("Выйти без сохранения", role: .destructive) {
                        dismiss()
                    }
                }
                .alert("Завершить тест?", isPresented: $showSubmitAlert) {
                    Button("Отмена", role: .cancel) { }
                    Button("Завершить", role: .destructive) {
                        saveCurrentAnswer()
                        viewModel.submitTest()
                        dismiss()
                    }
                } message: {
                    Text("Вы уверены, что хотите завершить тест? После отправки изменить ответы будет невозможно.")
                }
            } else {
                TestLoadingView()
            }
        }
        .onAppear {
            loadCurrentAnswer()
        }
        .onChange(of: viewModel.currentQuestion) { _ in
            loadCurrentAnswer()
        }
    }
    
    private var isTimeRunningOut: Bool {
        guard let remaining = viewModel.currentAttempt?.remainingTimeSeconds else { return false }
        return remaining < 300 // менее 5 минут
    }
    
    private func saveCurrentAnswer() {
        guard let question = viewModel.currentQuestion else { return }
        let answer = answerState.toUserAnswer(for: question)
        viewModel.saveCurrentAnswer(answer)
    }
    
    private func loadCurrentAnswer() {
        guard let question = viewModel.currentQuestion else { return }
        
        // Reset answer state
        answerState = AnswerState()
        
        // Initialize with default values for ordering
        if question.type == .ordering {
            answerState.orderingAnswer = question.correctOrder.shuffled()
        }
        
        // Load saved answer if exists
        if let savedAnswer = viewModel.getCurrentAnswer() {
            answerState.loadFrom(savedAnswer, question: question)
        }
    }
}

// MARK: - Preview

struct TestPlayerView_Previews: PreviewProvider {
    static var previews: some View {
        let service = TestMockService()
        let viewModel = TestViewModel(service: service)
        if let test = service.tests.first {
            viewModel.startTest(test)
        }
        return TestPlayerView(test: service.tests.first!, viewModel: viewModel)
    }
} 