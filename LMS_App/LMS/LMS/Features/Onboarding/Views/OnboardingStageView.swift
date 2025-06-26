//
//  OnboardingStageView.swift
//  LMS
//
//  Created on 27/01/2025.
//

import SwiftUI

struct OnboardingStageView: View {
    let stage: OnboardingStage
    let program: OnboardingProgram
    @State private var tasks: [OnboardingTask] = []
    @State private var selectedTask: OnboardingTask?
    @State private var showingTaskDetail = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Stage header
                StageHeaderView(stage: stage)
                
                // Tasks list
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(tasks) { task in
                            TaskCardView(task: task) { updatedTask in
                                updateTask(updatedTask)
                            } onTap: {
                                selectedTask = task
                                showingTaskDetail = true
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Этап \(stage.order)")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Готово") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                tasks = stage.tasks
            }
            .sheet(item: $selectedTask) { task in
                OnboardingTaskDetailView(
                    task: task,
                    program: program
                ) { updatedTask in
                    updateTask(updatedTask)
                }
            }
        }
    }
    
    private func updateTask(_ updatedTask: OnboardingTask) {
        if let index = tasks.firstIndex(where: { $0.id == updatedTask.id }) {
            tasks[index] = updatedTask
        }
    }
}

// MARK: - Stage Header
struct StageHeaderView: View {
    let stage: OnboardingStage
    
    var body: some View {
        VStack(spacing: 16) {
            // Icon and title
            VStack(spacing: 12) {
                Image(systemName: stage.icon)
                    .font(.system(size: 40))
                    .foregroundColor(.blue)
                
                Text(stage.title)
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text(stage.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            // Progress and stats
            HStack(spacing: 30) {
                VStack(spacing: 4) {
                    Text("\(stage.completedTasks)")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                    Text("Выполнено")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                VStack(spacing: 4) {
                    Text("\(stage.tasks.count - stage.completedTasks)")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.orange)
                    Text("Осталось")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                VStack(spacing: 4) {
                    Text("\(stage.duration)")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                    Text("Дней")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            // Progress bar
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Прогресс этапа")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text("\(Int(stage.progress * 100))%")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
                }
                
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 10)
                        
                        RoundedRectangle(cornerRadius: 6)
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.green, Color.green.opacity(0.8)]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geometry.size.width * stage.progress, height: 10)
                    }
                }
                .frame(height: 10)
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 20)
        .background(Color(.systemGray6))
    }
}

// MARK: - Task Card
struct TaskCardView: View {
    let task: OnboardingTask
    let onUpdate: (OnboardingTask) -> Void
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // Icon
                ZStack {
                    Circle()
                        .fill(task.iconColor.opacity(0.2))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: task.icon)
                        .font(.system(size: 20))
                        .foregroundColor(task.iconColor)
                }
                
                // Content
                VStack(alignment: .leading, spacing: 6) {
                    Text(task.title)
                        .font(.headline)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.leading)
                    
                    Text(task.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                    
                    // Additional info
                    HStack(spacing: 12) {
                        Label(task.type.rawValue, systemImage: getTypeIcon())
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        if let dueDate = task.dueDate {
                            Label(formatDueDate(dueDate), systemImage: "calendar")
                                .font(.caption)
                                .foregroundColor(isOverdue(dueDate) ? .red : .secondary)
                        }
                        
                        if !task.isRequired {
                            Text("Опционально")
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(Color.orange.opacity(0.2))
                                .foregroundColor(.orange)
                                .cornerRadius(10)
                        }
                    }
                }
                
                Spacer()
                
                // Completion button
                Button(action: {
                    var updatedTask = task
                    updatedTask.isCompleted.toggle()
                    if updatedTask.isCompleted {
                        updatedTask.completedAt = Date()
                    } else {
                        updatedTask.completedAt = nil
                    }
                    onUpdate(updatedTask)
                }) {
                    Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                        .font(.title2)
                        .foregroundColor(task.isCompleted ? .green : .gray)
                }
                .buttonStyle(BorderlessButtonStyle())
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 1)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func getTypeIcon() -> String {
        switch task.type {
        case .course: return "book.closed"
        case .test: return "doc.text"
        case .document: return "doc"
        case .meeting: return "person.2"
        case .task: return "checkmark.square"
        case .checklist: return "checklist"        case .feedback: return "bubble.left.and.bubble.right"
        }
    }
    
    private func formatDueDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM"
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter.string(from: date)
    }
    
    private func isOverdue(_ date: Date) -> Bool {
        date < Date() && !task.isCompleted
    }
}

// MARK: - Task Detail View
struct OnboardingTaskDetailView: View {
    let task: OnboardingTask
    let program: OnboardingProgram
    let onUpdate: (OnboardingTask) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var updatedTask: OnboardingTask
    
    init(task: OnboardingTask, program: OnboardingProgram, onUpdate: @escaping (OnboardingTask) -> Void) {
        self.task = task
        self.program = program
        self.onUpdate = onUpdate
        self._updatedTask = State(initialValue: task)
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Header
                    VStack(alignment: .center, spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(task.iconColor.opacity(0.2))
                                .frame(width: 80, height: 80)
                            
                            Image(systemName: task.icon)
                                .font(.system(size: 40))
                                .foregroundColor(task.iconColor)
                        }
                        
                        Text(task.title)
                            .font(.title2)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                        
                        Text(task.type.rawValue)
                            .font(.subheadline)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 6)
                            .background(task.iconColor.opacity(0.2))
                            .foregroundColor(task.iconColor)
                            .cornerRadius(15)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    
                    // Description
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Описание")
                            .font(.headline)
                        
                        Text(task.description)
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal)
                    
                    // Details
                    VStack(alignment: .leading, spacing: 16) {
                        if let dueDate = task.dueDate {
                            DetailRow(
                                icon: "calendar",
                                title: "Срок выполнения",
                                value: formatFullDate(dueDate),
                                color: isOverdue(dueDate) ? .red : .primary
                            )
                        }
                        
                        DetailRow(
                            icon: "exclamationmark.triangle",
                            title: "Обязательность",
                            value: task.isRequired ? "Обязательная" : "Опциональная",
                            color: task.isRequired ? .red : .orange
                        )
                        
                        if task.isCompleted, let completedAt = task.completedAt {
                            DetailRow(
                                icon: "checkmark.circle.fill",
                                title: "Выполнено",
                                value: formatFullDate(completedAt),
                                color: .green
                            )
                        }
                    }
                    .padding(.horizontal)
                    
                    // Action buttons based on type
                    VStack(spacing: 12) {
                        if task.type == .course, task.courseId != nil {
                            NavigationLink(destination: EmptyView()) {
                                ActionButton(
                                    title: "Открыть курс",
                                    icon: "book.closed.fill",
                                    color: .blue
                                )
                            }
                        }
                        
                        if task.type == .test, task.testId != nil {
                            NavigationLink(destination: EmptyView()) {
                                ActionButton(
                                    title: "Пройти тест",
                                    icon: "doc.text.fill",
                                    color: .purple
                                )
                            }
                        }
                        
                        if task.type == .document, task.documentUrl != nil {
                            Button(action: {}) {
                                ActionButton(
                                    title: "Открыть документ",
                                    icon: "doc.fill",
                                    color: .orange
                                )
                            }
                        }
                        
                        // Complete/Uncomplete button
                        Button(action: toggleCompletion) {
                            ActionButton(
                                title: updatedTask.isCompleted ? "Отменить выполнение" : "Отметить выполненным",
                                icon: updatedTask.isCompleted ? "xmark.circle.fill" : "checkmark.circle.fill",
                                color: updatedTask.isCompleted ? .gray : .green
                            )
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .navigationTitle("Детали задачи")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Готово") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func toggleCompletion() {
        updatedTask.isCompleted.toggle()
        if updatedTask.isCompleted {
            updatedTask.completedAt = Date()
        } else {
            updatedTask.completedAt = nil
        }
        onUpdate(updatedTask)
    }
    
    private func formatFullDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM yyyy"
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter.string(from: date)
    }
    
    private func isOverdue(_ date: Date) -> Bool {
        date < Date() && !updatedTask.isCompleted
    }
}

// MARK: - Detail Row
struct DetailRow: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(color)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(value)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(color)
            }
            
            Spacer()
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

// MARK: - Action Button
struct ActionButton: View {
    let title: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 20))
            
            Text(title)
                .fontWeight(.medium)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14))
                .foregroundColor(.gray)
        }
        .foregroundColor(color)
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(12)
    }
}

#Preview {
    OnboardingStageView(
        stage: OnboardingProgram.createMockStages()[1],
        program: OnboardingProgram.createMockPrograms()[0]
    )
} 