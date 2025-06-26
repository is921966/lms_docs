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
    @State private var selectedAnswers: Set<UUID> = []
    @State private var textAnswer = ""
    @State private var matchingAnswers: [String: String] = [:]
    @State private var orderingAnswer: [String] = []
    @State private var fillInBlanksAnswers: [String: String] = [:]
    @State private var essayAnswer = ""
    
    var body: some View {
        NavigationView {
            if viewModel.currentQuestion != nil && viewModel.currentAttempt != nil {
                VStack(spacing: 0) {
                    // Progress and timer
                    headerView
                    
                    // Question content
                    ScrollView {
                        VStack(alignment: .leading, spacing: 20) {
                            questionView
                            answerView
                        }
                        .padding()
                    }
                    
                    // Navigation controls
                    navigationView
                }
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Выход") {
                            showExitAlert = true
                        }
                    }
                    
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: toggleMark) {
                            Image(systemName: viewModel.isCurrentQuestionMarked() ? "bookmark.fill" : "bookmark")
                                .foregroundColor(.orange)
                        }
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
                loadingView
            }
        }
        .onAppear {
            loadCurrentAnswer()
        }
        .onChange(of: viewModel.currentQuestion) { _ in
            loadCurrentAnswer()
        }
    }
    
    // MARK: - Header View
    
    private var headerView: some View {
        VStack(spacing: 0) {
            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 4)
                    
                    Rectangle()
                        .fill(Color.blue)
                        .frame(width: geometry.size.width * viewModel.currentAttempt!.progress, height: 4)
                }
            }
            .frame(height: 4)
            
            HStack {
                // Question counter
                Text("Вопрос \(viewModel.currentQuestionIndex + 1) из \(viewModel.totalQuestions)")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Spacer()
                
                // Timer
                if let remainingTime = viewModel.currentAttempt?.formattedRemainingTime {
                    HStack(spacing: 4) {
                        Image(systemName: "timer")
                            .foregroundColor(isTimeRunningOut ? .red : .blue)
                        Text(remainingTime)
                            .foregroundColor(isTimeRunningOut ? .red : .primary)
                            .fontWeight(.medium)
                    }
                    .font(.subheadline)
                }
            }
            .padding()
            .background(Color(UIColor.secondarySystemGroupedBackground))
        }
    }
    
    private var isTimeRunningOut: Bool {
        guard let remaining = viewModel.currentAttempt?.remainingTimeSeconds else { return false }
        return remaining < 300 // менее 5 минут
    }
    
    // MARK: - Question View
    
    private var questionView: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Question type badge
            HStack {
                Image(systemName: viewModel.currentQuestion!.type.icon)
                Text(viewModel.currentQuestion!.type.rawValue)
            }
            .font(.caption)
            .foregroundColor(.white)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(Color.blue)
            .cornerRadius(8)
            
            // Question text
            Text(viewModel.currentQuestion!.text)
                .font(.title3)
                .fontWeight(.semibold)
            
            // Question image if exists
            if let imageUrl = viewModel.currentQuestion?.imageUrl {
                // В реальном приложении загружать изображение
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 200)
                    .cornerRadius(12)
                    .overlay(
                        Text("Изображение")
                            .foregroundColor(.gray)
                    )
            }
            
            // Points
            HStack {
                Image(systemName: "star.fill")
                    .foregroundColor(.orange)
                Text("\(Int(viewModel.currentQuestion!.points)) баллов")
                    .foregroundColor(.secondary)
            }
            .font(.caption)
            
            // Hint if available
            if let hint = viewModel.currentQuestion?.hint {
                HStack {
                    Image(systemName: "lightbulb")
                        .foregroundColor(.yellow)
                    Text(hint)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color.yellow.opacity(0.1))
                .cornerRadius(8)
            }
        }
    }
    
    // MARK: - Answer View
    
    private var answerView: some View {
        Group {
            switch viewModel.currentQuestion?.type {
            case .singleChoice, .trueFalse:
                singleChoiceView
            case .multipleChoice:
                multipleChoiceView
            case .textInput:
                textInputView
            case .matching:
                matchingView
            case .ordering:
                orderingView
            case .fillInBlanks:
                fillInBlanksView
            case .essay:
                essayView
            default:
                EmptyView()
            }
        }
    }
    
    private var singleChoiceView: some View {
        VStack(spacing: 12) {
            ForEach(viewModel.currentQuestion!.options) { option in
                AnswerOptionView(
                    option: option,
                    isSelected: selectedAnswers.contains(option.id),
                    isSingleChoice: true
                ) {
                    selectedAnswers = [option.id]
                }
            }
        }
    }
    
    private var multipleChoiceView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Выберите все правильные ответы")
                .font(.caption)
                .foregroundColor(.secondary)
            
            ForEach(viewModel.currentQuestion!.options) { option in
                AnswerOptionView(
                    option: option,
                    isSelected: selectedAnswers.contains(option.id),
                    isSingleChoice: false
                ) {
                    if selectedAnswers.contains(option.id) {
                        selectedAnswers.remove(option.id)
                    } else {
                        selectedAnswers.insert(option.id)
                    }
                }
            }
        }
    }
    
    private var textInputView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Введите ответ")
                .font(.caption)
                .foregroundColor(.secondary)
            
            TextField("Ваш ответ", text: $textAnswer)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .font(.body)
        }
    }
    
    private var matchingView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Сопоставьте элементы")
                .font(.caption)
                .foregroundColor(.secondary)
            
            ForEach(viewModel.currentQuestion!.matchingPairs) { pair in
                HStack {
                    Text(pair.left)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(8)
                    
                    Image(systemName: "arrow.right")
                        .foregroundColor(.gray)
                    
                    Menu {
                        ForEach(viewModel.currentQuestion!.matchingPairs.map { $0.right }.shuffled(), id: \.self) { right in
                            Button(right) {
                                matchingAnswers[pair.left] = right
                            }
                        }
                    } label: {
                        Text(matchingAnswers[pair.left] ?? "Выберите")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                    }
                }
            }
        }
    }
    
    private var orderingView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Расположите в правильном порядке")
                .font(.caption)
                .foregroundColor(.secondary)
            
            // В реальном приложении использовать drag and drop
            ForEach(Array(orderingAnswer.enumerated()), id: \.offset) { index, item in
                HStack {
                    Text("\(index + 1).")
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
                    
                    Text(item)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    VStack(spacing: 4) {
                        if index > 0 {
                            Button(action: { moveUp(index: index) }) {
                                Image(systemName: "chevron.up")
                                    .foregroundColor(.blue)
                            }
                        }
                        
                        if index < orderingAnswer.count - 1 {
                            Button(action: { moveDown(index: index) }) {
                                Image(systemName: "chevron.down")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
            }
        }
    }
    
    private var fillInBlanksView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Заполните пропуски")
                .font(.caption)
                .foregroundColor(.secondary)
            
            if let textWithBlanks = viewModel.currentQuestion?.textWithBlanks {
                // Простая версия - показываем текст и поля ввода отдельно
                Text(textWithBlanks)
                    .font(.body)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                
                ForEach(Array(viewModel.currentQuestion!.blanksAnswers.keys.sorted()), id: \.self) { blankId in
                    HStack {
                        Text("[\(blankId)]:")
                            .fontWeight(.semibold)
                        
                        TextField("Введите ответ", text: Binding(
                            get: { fillInBlanksAnswers[blankId] ?? "" },
                            set: { fillInBlanksAnswers[blankId] = $0 }
                        ))
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                }
            }
        }
    }
    
    private var essayView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Напишите развернутый ответ")
                .font(.caption)
                .foregroundColor(.secondary)
            
            TextEditor(text: $essayAnswer)
                .frame(minHeight: 200)
                .padding(8)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
        }
    }
    
    // MARK: - Navigation View
    
    private var navigationView: some View {
        VStack(spacing: 0) {
            Divider()
            
            HStack(spacing: 20) {
                // Previous button
                Button(action: {
                    saveCurrentAnswer()
                    viewModel.previousQuestion()
                }) {
                    Label("Назад", systemImage: "chevron.left")
                }
                .buttonStyle(.bordered)
                .disabled(!viewModel.hasPreviousQuestion)
                
                Spacer()
                
                // Question navigation
                Menu {
                    ForEach(0..<viewModel.totalQuestions, id: \.self) { index in
                        Button(action: {
                            saveCurrentAnswer()
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
                
                Spacer()
                
                // Next/Submit button
                if viewModel.isLastQuestion {
                    Button(action: {
                        saveCurrentAnswer()
                        showSubmitAlert = true
                    }) {
                        Label("Завершить", systemImage: "checkmark.circle")
                    }
                    .buttonStyle(.borderedProminent)
                } else {
                    Button(action: {
                        saveCurrentAnswer()
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
    
    // MARK: - Loading View
    
    private var loadingView: some View {
        VStack {
            ProgressView()
            Text("Загрузка теста...")
                .foregroundColor(.secondary)
        }
    }
    
    // MARK: - Helper Methods
    
    private func toggleMark() {
        if viewModel.isCurrentQuestionMarked() {
            viewModel.unmarkCurrentQuestion()
        } else {
            viewModel.markCurrentQuestion()
        }
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
    
    private func moveUp(index: Int) {
        guard index > 0 else { return }
        orderingAnswer.swapAt(index, index - 1)
    }
    
    private func moveDown(index: Int) {
        guard index < orderingAnswer.count - 1 else { return }
        orderingAnswer.swapAt(index, index + 1)
    }
    
    private func saveCurrentAnswer() {
        guard let question = viewModel.currentQuestion else { return }
        
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
        
        viewModel.saveCurrentAnswer(answer)
    }
    
    private func loadCurrentAnswer() {
        guard let question = viewModel.currentQuestion else { return }
        
        // Reset all answer states
        selectedAnswers = []
        textAnswer = ""
        matchingAnswers = [:]
        orderingAnswer = question.correctOrder.shuffled()
        fillInBlanksAnswers = [:]
        essayAnswer = ""
        
        // Load saved answer if exists
        if let savedAnswer = viewModel.getCurrentAnswer() {
            switch question.type {
            case .singleChoice, .multipleChoice, .trueFalse:
                selectedAnswers = Set(savedAnswer.selectedOptionIds ?? [])
            case .textInput:
                textAnswer = savedAnswer.textAnswer ?? ""
            case .matching:
                matchingAnswers = savedAnswer.matchingAnswers ?? [:]
            case .ordering:
                orderingAnswer = savedAnswer.orderingAnswer ?? question.correctOrder.shuffled()
            case .fillInBlanks:
                fillInBlanksAnswers = savedAnswer.fillInBlanksAnswers ?? [:]
            case .essay:
                essayAnswer = savedAnswer.essayAnswer ?? ""
            }
        }
    }
}

// MARK: - Answer Option View

struct AnswerOptionView: View {
    let option: AnswerOption
    let isSelected: Bool
    let isSingleChoice: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: isSelected
                      ? (isSingleChoice ? "circle.fill" : "checkmark.square.fill")
                      : (isSingleChoice ? "circle" : "square"))
                    .foregroundColor(isSelected ? .blue : .gray)
                    .font(.title3)
                
                Text(option.text)
                    .font(.body)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                if let imageUrl = option.imageUrl {
                    // В реальном приложении загружать изображение
                    Image(systemName: "photo")
                        .foregroundColor(.gray)
                }
            }
            .padding()
            .background(isSelected ? Color.blue.opacity(0.1) : Color.gray.opacity(0.1))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
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