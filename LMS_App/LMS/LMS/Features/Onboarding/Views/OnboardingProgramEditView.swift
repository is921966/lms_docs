import SwiftUI

struct OnboardingProgramEditView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var service = OnboardingMockService.shared
    
    let program: OnboardingProgram
    
    @State private var editedProgram: OnboardingProgram
    @State private var showingSaveAlert = false
    @State private var isSaving = false
    
    init(program: OnboardingProgram) {
        self.program = program
        self._editedProgram = State(initialValue: program)
    }
    
    var body: some View {
        NavigationView {
            Form {
                // Employee info (read-only)
                Section {
                    HStack {
                        Text("Сотрудник")
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(editedProgram.employeeName)
                    }
                    
                    HStack {
                        Text("Должность")
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(editedProgram.employeePosition)
                    }
                } header: {
                    Text("Информация о сотруднике")
                }
                
                // Program details
                Section {
                    DatePicker("Дата начала", 
                              selection: Binding(
                                get: { editedProgram.startDate },
                                set: { editedProgram.startDate = $0 }
                              ),
                              displayedComponents: .date)
                    
                    if let endDate = editedProgram.endDate {
                        DatePicker("Дата окончания",
                                  selection: Binding(
                                    get: { endDate },
                                    set: { editedProgram.endDate = $0 }
                                  ),
                                  displayedComponents: .date)
                    }
                    
                    HStack {
                        Text("Наставник")
                            .foregroundColor(.secondary)
                        Spacer()
                        TextField("ID наставника", text: Binding(
                            get: { editedProgram.mentorId },
                            set: { editedProgram.mentorId = $0 }
                        ))
                        .multilineTextAlignment(.trailing)
                    }
                } header: {
                    Text("Детали программы")
                }
                
                // Status
                Section {
                    Picker("Статус", selection: Binding(
                        get: { editedProgram.status },
                        set: { editedProgram.status = $0 }
                    )) {
                        ForEach([OnboardingStatus.notStarted, .inProgress, .completed, .delayed], id: \.self) { status in
                            Text(status.rawValue).tag(status)
                        }
                    }
                } header: {
                    Text("Статус программы")
                }
                
                // Stages
                Section {
                    ForEach(editedProgram.stages.indices, id: \.self) { stageIndex in
                        NavigationLink(destination: StageEditView(
                            stage: $editedProgram.stages[stageIndex],
                            onSave: { updatedStage in
                                editedProgram.stages[stageIndex] = updatedStage
                            }
                        )) {
                            HStack {
                                Text(editedProgram.stages[stageIndex].name)
                                Spacer()
                                Text("\(editedProgram.stages[stageIndex].tasks.filter { $0.isCompleted }.count)/\(editedProgram.stages[stageIndex].tasks.count)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                } header: {
                    Text("Этапы программы")
                } footer: {
                    Text("Нажмите на этап для редактирования задач")
                        .font(.caption)
                }
            }
            .navigationTitle("Редактирование программы")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Сохранить") {
                        saveChanges()
                    }
                    .disabled(isSaving)
                    .bold()
                }
            }
            .alert("Изменения сохранены", isPresented: $showingSaveAlert) {
                Button("OK") {
                    dismiss()
                }
            } message: {
                Text("Программа адаптации успешно обновлена")
            }
            .disabled(isSaving)
            .overlay {
                if isSaving {
                    ZStack {
                        Color.black.opacity(0.3)
                            .ignoresSafeArea()
                        
                        ProgressView("Сохранение...")
                            .padding()
                            .background(Color(.systemBackground))
                            .cornerRadius(10)
                            .shadow(radius: 5)
                    }
                }
            }
        }
    }
    
    private func saveChanges() {
        isSaving = true
        
        // Recalculate progress
        let totalTasks = editedProgram.stages.flatMap { $0.tasks }.count
        let completedTasks = editedProgram.stages.flatMap { $0.tasks }.filter { $0.isCompleted }.count
        editedProgram.progress = totalTasks > 0 ? Double(completedTasks) / Double(totalTasks) : 0
        
        // Update in service
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            service.updateProgram(editedProgram)
            isSaving = false
            showingSaveAlert = true
        }
    }
}

// MARK: - Stage Edit View
struct StageEditView: View {
    @Binding var stage: OnboardingStage
    let onSave: (OnboardingStage) -> Void
    @Environment(\.dismiss) private var dismiss
    
    @State private var editedStage: OnboardingStage
    
    init(stage: Binding<OnboardingStage>, onSave: @escaping (OnboardingStage) -> Void) {
        self._stage = stage
        self.onSave = onSave
        self._editedStage = State(initialValue: stage.wrappedValue)
    }
    
    var body: some View {
        Form {
            Section {
                TextField("Название этапа", text: $editedStage.name)
            } header: {
                Text("Информация об этапе")
            }
            
            Section {
                ForEach(editedStage.tasks.indices, id: \.self) { taskIndex in
                    HStack {
                        Button(action: {
                            editedStage.tasks[taskIndex].isCompleted.toggle()
                            if editedStage.tasks[taskIndex].isCompleted {
                                editedStage.tasks[taskIndex].completedAt = Date()
                            } else {
                                editedStage.tasks[taskIndex].completedAt = nil
                            }
                        }) {
                            Image(systemName: editedStage.tasks[taskIndex].isCompleted ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(editedStage.tasks[taskIndex].isCompleted ? .green : .gray)
                                .font(.title2)
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        VStack(alignment: .leading) {
                            Text(editedStage.tasks[taskIndex].title)
                                .strikethrough(editedStage.tasks[taskIndex].isCompleted)
                            
                            if let dueDate = editedStage.tasks[taskIndex].dueDate {
                                Text("До: \(dueDate, formatter: dateFormatter)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }
            } header: {
                Text("Задачи")
            }
        }
        .navigationTitle("Редактирование этапа")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Готово") {
                    onSave(editedStage)
                    dismiss()
                }
                .bold()
            }
        }
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter
    }
}

// MARK: - Preview
struct OnboardingProgramEditView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingProgramEditView(program: OnboardingProgram.mockPrograms[0])
    }
} 