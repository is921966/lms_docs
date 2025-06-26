//
//  TestEditView.swift
//  LMS
//
//  Created on 26/01/2025.
//

import SwiftUI

struct TestEditView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var test: Test
    @State private var title: String
    @State private var description: String
    @State private var selectedType: TestType
    @State private var selectedDifficulty: TestDifficulty
    @State private var timeLimit: Int?
    @State private var passingScore: Int
    @State private var maxAttempts: Int?
    @State private var showingAddQuestion = false
    @State private var questions: [Question] = []
    @State private var showingSaveAlert = false
    
    init(test: Test) {
        self._test = State(initialValue: test)
        self._title = State(initialValue: test.title)
        self._description = State(initialValue: test.description)
        self._selectedType = State(initialValue: test.type)
        self._selectedDifficulty = State(initialValue: test.difficulty)
        self._timeLimit = State(initialValue: test.timeLimit)
        self._passingScore = State(initialValue: Int(test.passingScore))
        self._maxAttempts = State(initialValue: test.attemptsAllowed)
        self._questions = State(initialValue: test.questions)
    }
    
    var body: some View {
        NavigationView {
            Form {
                // Basic info section
                Section("Основная информация") {
                    TextField("Название теста", text: $title)
                    
                    TextField("Описание", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                    
                    Picker("Тип теста", selection: $selectedType) {
                        ForEach(TestType.allCases, id: \.self) { type in
                            Label(type.rawValue, systemImage: type.icon)
                                .tag(type)
                        }
                    }
                    
                    Picker("Сложность", selection: $selectedDifficulty) {
                        ForEach(TestDifficulty.allCases, id: \.self) { difficulty in
                            Label(difficulty.rawValue, systemImage: difficulty.icon)
                                .tag(difficulty)
                        }
                    }
                }
                
                // Settings section
                Section("Настройки") {
                    HStack {
                        Text("Ограничение времени")
                        Spacer()
                        TextField("минут", value: $timeLimit, format: .number)
                            .keyboardType(.numberPad)
                            .frame(width: 80)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    HStack {
                        Text("Проходной балл")
                        Spacer()
                        TextField("%", value: $passingScore, format: .number)
                            .keyboardType(.numberPad)
                            .frame(width: 60)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    HStack {
                        Text("Макс. попыток")
                        Spacer()
                        TextField("неогр.", value: $maxAttempts, format: .number)
                            .keyboardType(.numberPad)
                            .frame(width: 80)
                            .multilineTextAlignment(.trailing)
                    }
                }
                
                // Questions section
                Section("Вопросы (\(questions.count))") {
                    ForEach(questions) { question in
                        QuestionRow(question: question)
                    }
                    .onDelete(perform: deleteQuestion)
                    
                    Button(action: { showingAddQuestion = true }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("Добавить вопрос")
                        }
                        .foregroundColor(.blue)
                    }
                }
                
                // Preview section
                Section("Предпросмотр") {
                    TestPreviewCard(
                        title: title,
                        description: description,
                        type: selectedType,
                        difficulty: selectedDifficulty,
                        questionCount: questions.count,
                        timeLimit: timeLimit
                    )
                }
            }
            .navigationTitle("Редактирование теста")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Сохранить") {
                        saveTest()
                    }
                    .fontWeight(.bold)
                }
            }
            .sheet(isPresented: $showingAddQuestion) {
                AddQuestionView { newQuestion in
                    questions.append(newQuestion)
                }
            }
            .alert("Изменения сохранены", isPresented: $showingSaveAlert) {
                Button("OK") {
                    dismiss()
                }
            } message: {
                Text("Тест успешно обновлен")
            }
        }
    }
    
    private func deleteQuestion(at offsets: IndexSet) {
        questions.remove(atOffsets: offsets)
    }
    
    private func saveTest() {
        // Here you would save to backend
        // For now, just show success alert
        showingSaveAlert = true
    }
}

// Question row
struct QuestionRow: View {
    let question: Question
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(question.text)
                .font(.body)
                .lineLimit(2)
            
            HStack {
                Image(systemName: question.type.icon)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(question.type.rawValue)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("\(question.points) баллов")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}

// Add question view
struct AddQuestionView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var questionText = ""
    @State private var selectedType = QuestionType.singleChoice
    @State private var points = 1
    @State private var options: [String] = ["", "", "", ""]
    @State private var correctAnswer = 0
    
    let onAdd: (Question) -> Void
    
    var body: some View {
        NavigationView {
            Form {
                Section("Вопрос") {
                    TextField("Текст вопроса", text: $questionText, axis: .vertical)
                        .lineLimit(3...10)
                    
                    Picker("Тип вопроса", selection: $selectedType) {
                        ForEach(QuestionType.allCases, id: \.self) { type in
                            Label(type.rawValue, systemImage: type.icon)
                                .tag(type)
                        }
                    }
                    
                    Stepper("Баллы: \(points)", value: $points, in: 1...10)
                }
                
                if selectedType == .singleChoice || selectedType == .multipleChoice {
                    Section("Варианты ответов") {
                        ForEach(0..<4) { index in
                            HStack {
                                if selectedType == .singleChoice {
                                    Image(systemName: correctAnswer == index ? "checkmark.circle.fill" : "circle")
                                        .foregroundColor(correctAnswer == index ? .green : .gray)
                                        .onTapGesture {
                                            correctAnswer = index
                                        }
                                } else {
                                    Image(systemName: "square")
                                        .foregroundColor(.gray)
                                }
                                
                                TextField("Вариант \(index + 1)", text: $options[index])
                            }
                        }
                    }
                }
            }
            .navigationTitle("Новый вопрос")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Добавить") {
                        let answerOptions = options.enumerated().compactMap { index, text in
                            text.isEmpty ? nil : AnswerOption(
                                text: text,
                                isCorrect: selectedType == .singleChoice ? index == correctAnswer : false
                            )
                        }
                        
                        let newQuestion = Question(
                            text: questionText,
                            type: selectedType,
                            points: Double(points),
                            options: answerOptions
                        )
                        onAdd(newQuestion)
                        dismiss()
                    }
                    .disabled(questionText.isEmpty)
                }
            }
        }
    }
}

// Test preview card
struct TestPreviewCard: View {
    let title: String
    let description: String
    let type: TestType
    let difficulty: TestDifficulty
    let questionCount: Int
    let timeLimit: Int?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: type.icon)
                    .font(.title2)
                    .foregroundColor(type.color)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                    
                    HStack(spacing: 8) {
                        Label(difficulty.rawValue, systemImage: difficulty.icon)
                            .font(.caption)
                            .foregroundColor(difficulty.color)
                        
                        Label("\(questionCount) вопросов", systemImage: "questionmark.circle")
                            .font(.caption)
                            .foregroundColor(.gray)
                        
                        if let timeLimit = timeLimit {
                            Label("\(timeLimit) мин", systemImage: "timer")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                }
                
                Spacer()
            }
            
            Text(description)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(2)
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
    }
} 