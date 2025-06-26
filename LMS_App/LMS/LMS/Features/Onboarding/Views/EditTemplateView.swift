import SwiftUI

struct EditTemplateView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var onboardingService = OnboardingMockService.shared
    
    let template: OnboardingTemplate
    @State private var name: String
    @State private var description: String
    @State private var durationDays: Int
    @State private var stages: [OnboardingTemplateStage]
    @State private var showingAddStage = false
    @State private var editingStage: OnboardingTemplateStage?
    @State private var showingSaveConfirmation = false
    
    init(template: OnboardingTemplate) {
        self.template = template
        _name = State(initialValue: template.name)
        _description = State(initialValue: template.description)
        _durationDays = State(initialValue: template.durationDays)
        _stages = State(initialValue: template.stages)
    }
    
    var body: some View {
        NavigationView {
            Form {
                // Basic info
                Section("Основная информация") {
                    TextField("Название шаблона", text: $name)
                    
                    VStack(alignment: .leading) {
                        Text("Описание")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        TextEditor(text: $description)
                            .frame(minHeight: 80)
                    }
                    
                    Stepper("Длительность: \(durationDays) дней", value: $durationDays, in: 1...365)
                }
                
                // Stages
                Section("Этапы программы") {
                    ForEach($stages) { $stage in
                        StageRow(stage: stage) {
                            editingStage = stage
                        }
                    }
                    .onDelete(perform: deleteStage)
                    .onMove(perform: moveStage)
                    
                    Button(action: { showingAddStage = true }) {
                        Label("Добавить этап", systemImage: "plus.circle.fill")
                            .foregroundColor(.blue)
                    }
                }
                
                // Preview
                Section("Предпросмотр") {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Всего задач: \(totalTasksCount)")
                            .font(.subheadline)
                        
                        Text("Примерное время выполнения: \(estimatedCompletionTime)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Редактировать шаблон")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Сохранить") {
                        showingSaveConfirmation = true
                    }
                    .disabled(name.isEmpty || stages.isEmpty)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
            }
        }
        .sheet(isPresented: $showingAddStage) {
            AddStageView { newStage in
                stages.append(newStage)
            }
        }
        .sheet(item: $editingStage) { stage in
            EditStageView(stage: stage) { updatedStage in
                if let index = stages.firstIndex(where: { $0.id == stage.id }) {
                    stages[index] = updatedStage
                }
            }
        }
        .alert("Сохранить изменения?", isPresented: $showingSaveConfirmation) {
            Button("Отмена", role: .cancel) { }
            Button("Сохранить") {
                saveTemplate()
                dismiss()
            }
        } message: {
            Text("Изменения будут применены ко всем новым программам, созданным на основе этого шаблона")
        }
    }
    
    private var totalTasksCount: Int {
        stages.reduce(0) { $0 + $1.tasks.count }
    }
    
    private var estimatedCompletionTime: String {
        let totalHours = stages.reduce(0) { sum, stage in
            sum + stage.tasks.reduce(0) { $0 + ($1.estimatedHours ?? 0) }
        }
        
        if totalHours < 8 {
            return "\(totalHours) часов"
        } else {
            let days = totalHours / 8
            let hours = totalHours % 8
            return "\(days) дней \(hours) часов"
        }
    }
    
    private func deleteStage(at offsets: IndexSet) {
        stages.remove(atOffsets: offsets)
    }
    
    private func moveStage(from source: IndexSet, to destination: Int) {
        stages.move(fromOffsets: source, toOffset: destination)
        // Update order
        for (index, _) in stages.enumerated() {
            stages[index].order = index + 1
        }
    }
    
    private func saveTemplate() {
        var updatedTemplate = template
        updatedTemplate.name = name
        updatedTemplate.description = description
        updatedTemplate.durationDays = durationDays
        updatedTemplate.stages = stages
        
        onboardingService.updateTemplate(updatedTemplate)
    }
}

// MARK: - Stage Row
struct StageRow: View {
    let stage: OnboardingTemplateStage
    let onEdit: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Label(stage.name, systemImage: "flag.fill")
                    .font(.headline)
                
                Spacer()
                
                Text("\(stage.tasks.count) задач")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
            }
            
            Text("Длительность: \(stage.durationDays) дней")
                .font(.caption)
                .foregroundColor(.secondary)
            
            if !stage.description.isEmpty {
                Text(stage.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
        .onTapGesture {
            onEdit()
        }
    }
}

// MARK: - Add Stage View
struct AddStageView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var description = ""
    @State private var durationDays = 7
    
    let onAdd: (OnboardingTemplateStage) -> Void
    
    var body: some View {
        NavigationView {
            Form {
                Section("Информация об этапе") {
                    TextField("Название этапа", text: $name)
                    
                    VStack(alignment: .leading) {
                        Text("Описание")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        TextEditor(text: $description)
                            .frame(minHeight: 80)
                    }
                    
                    Stepper("Длительность: \(durationDays) дней", value: $durationDays, in: 1...90)
                }
            }
            .navigationTitle("Новый этап")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Добавить") {
                        let newStage = OnboardingTemplateStage(
                            name: name,
                            description: description,
                            order: 0, // Will be updated
                            durationDays: durationDays,
                            tasks: []
                        )
                        onAdd(newStage)
                        dismiss()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
}

// MARK: - Edit Stage View
struct EditStageView: View {
    @Environment(\.dismiss) private var dismiss
    
    let stage: OnboardingTemplateStage
    @State private var name: String
    @State private var description: String
    @State private var durationDays: Int
    @State private var tasks: [OnboardingTemplateTask]
    @State private var showingAddTask = false
    @State private var editingTask: OnboardingTemplateTask?
    
    let onSave: (OnboardingTemplateStage) -> Void
    
    init(stage: OnboardingTemplateStage, onSave: @escaping (OnboardingTemplateStage) -> Void) {
        self.stage = stage
        self.onSave = onSave
        _name = State(initialValue: stage.name)
        _description = State(initialValue: stage.description)
        _durationDays = State(initialValue: stage.durationDays)
        _tasks = State(initialValue: stage.tasks)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Информация об этапе") {
                    TextField("Название этапа", text: $name)
                    
                    VStack(alignment: .leading) {
                        Text("Описание")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        TextEditor(text: $description)
                            .frame(minHeight: 80)
                    }
                    
                    Stepper("Длительность: \(durationDays) дней", value: $durationDays, in: 1...90)
                }
                
                Section("Задачи этапа") {
                    ForEach($tasks) { $task in
                        TaskRow(task: task) {
                            editingTask = task
                        }
                    }
                    .onDelete(perform: deleteTask)
                    .onMove(perform: moveTask)
                    
                    Button(action: { showingAddTask = true }) {
                        Label("Добавить задачу", systemImage: "plus.circle.fill")
                            .foregroundColor(.blue)
                    }
                }
            }
            .navigationTitle("Редактировать этап")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Сохранить") {
                        var updatedStage = stage
                        updatedStage.name = name
                        updatedStage.description = description
                        updatedStage.durationDays = durationDays
                        updatedStage.tasks = tasks
                        onSave(updatedStage)
                        dismiss()
                    }
                    .disabled(name.isEmpty)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
            }
        }
        .sheet(isPresented: $showingAddTask) {
            AddTaskView { newTask in
                tasks.append(newTask)
            }
        }
        .sheet(item: $editingTask) { task in
            EditTaskView(task: task) { updatedTask in
                if let index = tasks.firstIndex(where: { $0.id == task.id }) {
                    tasks[index] = updatedTask
                }
            }
        }
    }
    
    private func deleteTask(at offsets: IndexSet) {
        tasks.remove(atOffsets: offsets)
    }
    
    private func moveTask(from source: IndexSet, to destination: Int) {
        tasks.move(fromOffsets: source, toOffset: destination)
        // Update order
        for (index, _) in tasks.enumerated() {
            tasks[index].order = index + 1
        }
    }
}

// MARK: - Task Row
struct TaskRow: View {
    let task: OnboardingTemplateTask
    let onEdit: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Image(systemName: task.type.icon)
                    .foregroundColor(task.type.color)
                
                Text(task.title)
                    .font(.subheadline)
                
                Spacer()
                
                if let hours = task.estimatedHours {
                    Text("\(hours)ч")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Text(task.description)
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(1)
        }
        .padding(.vertical, 2)
        .contentShape(Rectangle())
        .onTapGesture {
            onEdit()
        }
    }
}

#Preview {
    EditTemplateView(template: OnboardingTemplate.mockTemplates[0])
} 