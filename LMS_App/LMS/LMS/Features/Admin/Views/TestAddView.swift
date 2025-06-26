//
//  TestAddView.swift
//  LMS
//
//  Created on 26/01/2025.
//

import SwiftUI

struct TestAddView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var title = ""
    @State private var description = ""
    @State private var selectedType = TestType.quiz
    @State private var selectedDifficulty = TestDifficulty.medium
    @State private var timeLimit: Int? = 30
    @State private var passingScore = 60
    @State private var maxAttempts = 3
    @State private var questions: [Question] = []
    @State private var showingAddQuestion = false
    
    let onAdd: (Test) -> Void
    
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
                        TextField("", value: $maxAttempts, format: .number)
                            .keyboardType(.numberPad)
                            .frame(width: 60)
                            .multilineTextAlignment(.trailing)
                    }
                }
                
                // Questions section
                Section("Вопросы (\(questions.count))") {
                    if questions.isEmpty {
                        Text("Добавьте вопросы к тесту")
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(questions) { question in
                            QuestionRow(question: question)
                        }
                        .onDelete(perform: deleteQuestion)
                    }
                    
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
                        title: title.isEmpty ? "Название теста" : title,
                        description: description.isEmpty ? "Описание теста" : description,
                        type: selectedType,
                        difficulty: selectedDifficulty,
                        questionCount: questions.count,
                        timeLimit: timeLimit
                    )
                }
            }
            .navigationTitle("Новый тест")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Создать") {
                        createTest()
                    }
                    .fontWeight(.bold)
                    .disabled(title.isEmpty || description.isEmpty || questions.isEmpty)
                }
            }
            .sheet(isPresented: $showingAddQuestion) {
                AddQuestionView { newQuestion in
                    questions.append(newQuestion)
                }
            }
        }
    }
    
    private func deleteQuestion(at offsets: IndexSet) {
        questions.remove(atOffsets: offsets)
    }
    
    private func createTest() {
        let newTest = Test(
            title: title,
            description: description,
            type: selectedType,
            status: .draft,
            difficulty: selectedDifficulty,
            questions: questions,
            timeLimit: timeLimit,
            attemptsAllowed: maxAttempts,
            passingScore: Double(passingScore),
            createdBy: "Admin"
        )
        onAdd(newTest)
        dismiss()
    }
} 