//
//  CreateProgramFromTemplateView.swift
//  LMS
//
//  Created on 27/01/2025.
//

import SwiftUI

struct CreateProgramFromTemplateView: View {
    let template: OnboardingTemplate
    @Environment(\.dismiss) private var dismiss
    
    // Employee selection
    @State private var selectedEmployee: User?
    @State private var searchText = ""
    @State private var showingEmployeeSelection = false
    
    // Program details
    @State private var programTitle = ""
    @State private var programDescription = ""
    @State private var startDate = Date()
    @State private var targetEndDate = Date()
    
    // Manager selection
    @State private var selectedManager: User?
    @State private var showingManagerSelection = false
    
    // Customization
    @State private var customizedStages: [OnboardingTemplateStage] = []
    @State private var showingSuccess = false
    
    init(template: OnboardingTemplate) {
        self.template = template
        self._programTitle = State(initialValue: template.title)
        self._programDescription = State(initialValue: template.description)
        self._targetEndDate = State(initialValue: Date().addingTimeInterval(Double(template.duration) * 24 * 60 * 60))
        self._customizedStages = State(initialValue: template.stages)
    }
    
    var body: some View {
        NavigationView {
            Form {
                // Employee Section
                Section(header: Text("Сотрудник")) {
                    Button(action: { showingEmployeeSelection = true }) {
                        HStack {
                            if let employee = selectedEmployee {
                                HStack {
                                    Image(systemName: "person.circle.fill")
                                        .font(.title2)
                                        .foregroundColor(.gray)
                                    
                                    VStack(alignment: .leading) {
                                        Text("\(employee.firstName) \(employee.lastName)")
                                            .foregroundColor(.primary)
                                        Text(employee.email)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                            } else {
                                HStack {
                                    Image(systemName: "person.badge.plus")
                                        .foregroundColor(.blue)
                                    Text("Выбрать сотрудника")
                                        .foregroundColor(.blue)
                                }
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                }
                
                // Program Details Section
                Section(header: Text("Детали программы")) {
                    TextField("Название программы", text: $programTitle)
                    
                    TextField("Описание", text: $programDescription, axis: .vertical)
                        .lineLimit(3...5)
                    
                    DatePicker("Дата начала", selection: $startDate, displayedComponents: .date)
                    
                    DatePicker("Планируемая дата завершения", selection: $targetEndDate, displayedComponents: .date)
                    
                    HStack {
                        Text("Длительность")
                        Spacer()
                        Text("\(daysBetween(startDate, targetEndDate)) дней")
                            .foregroundColor(.secondary)
                    }
                }
                
                // Manager Section
                Section(header: Text("Руководитель")) {
                    Button(action: { showingManagerSelection = true }) {
                        HStack {
                            if let manager = selectedManager {
                                HStack {
                                    Image(systemName: "person.circle.fill")
                                        .font(.title2)
                                        .foregroundColor(.gray)
                                    
                                    VStack(alignment: .leading) {
                                        Text("\(manager.firstName) \(manager.lastName)")
                                            .foregroundColor(.primary)
                                        Text(manager.email)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                            } else {
                                HStack {
                                    Image(systemName: "person.2.badge.gearshape")
                                        .foregroundColor(.blue)
                                    Text("Выбрать руководителя")
                                        .foregroundColor(.blue)
                                }
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                }
                
                // Stages Section
                Section(header: Text("Этапы программы (\(customizedStages.count))")) {
                    ForEach(customizedStages) { stage in
                        NavigationLink(destination: CustomizeStageView(stage: stage) { updatedStage in
                            updateStage(updatedStage)
                        }) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Этап \(stage.orderIndex): \(stage.title)")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                    
                                    HStack {
                                        Label("\(stage.duration) дн.", systemImage: "calendar")
                                        Text("•")
                                        Label("\(stage.taskTemplates.count) задач", systemImage: "checkmark.square")
                                    }
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                            }
                        }
                    }
                }
            }
            .navigationTitle("Новая программа")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Создать") {
                        createProgram()
                    }
                    .fontWeight(.semibold)
                    .disabled(!isValidForm)
                }
            }
            .sheet(isPresented: $showingEmployeeSelection) {
                EmployeeSelectionView(selectedEmployee: $selectedEmployee)
            }
            .sheet(isPresented: $showingManagerSelection) {
                ManagerSelectionView(selectedManager: $selectedManager)
            }
            .alert("Программа создана", isPresented: $showingSuccess) {
                Button("OK") {
                    dismiss()
                }
            } message: {
                Text("Программа онбординга для \(selectedEmployee?.firstName ?? "") успешно создана")
            }
        }
    }
    
    private var isValidForm: Bool {
        selectedEmployee != nil &&
        selectedManager != nil &&
        !programTitle.isEmpty &&
        !programDescription.isEmpty &&
        targetEndDate > startDate
    }
    
    private func daysBetween(_ start: Date, _ end: Date) -> Int {
        let calendar = Calendar.current
        let days = calendar.dateComponents([.day], from: start, to: end).day ?? 0
        return max(0, days)
    }
    
    private func updateStage(_ updatedStage: OnboardingTemplateStage) {
        if let index = customizedStages.firstIndex(where: { $0.id == updatedStage.id }) {
            customizedStages[index] = updatedStage
        }
    }
    
    private func createProgram() {
        guard let employee = selectedEmployee,
              let manager = selectedManager else { return }
        
        let newProgram = OnboardingMockService.shared.createProgram(
            from: template,
            employee: employee,
            manager: manager,
            title: programTitle,
            description: programDescription,
            startDate: startDate,
            targetEndDate: targetEndDate,
            customizedStages: customizedStages
        )
        
        showingSuccess = true
    }
}

// MARK: - Employee Selection View
struct EmployeeSelectionView: View {
    @Binding var selectedEmployee: User?
    @State private var searchText = ""
    @State private var employees: [User] = []
    @Environment(\.dismiss) private var dismiss
    
    var filteredEmployees: [User] {
        if searchText.isEmpty {
            return employees
        }
        return employees.filter { employee in
            let fullName = "\(employee.firstName) \(employee.lastName)"
            return fullName.localizedCaseInsensitiveContains(searchText) ||
                   (employee.email?.localizedCaseInsensitiveContains(searchText) ?? false)
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    TextField("Поиск сотрудников", text: $searchText)
                }
                .padding(10)
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding()
                
                // Employee list
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(filteredEmployees) { employee in
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("\(employee.firstName) \(employee.lastName)")
                                        .font(.headline)
                                    Text(employee.email ?? "")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                if selectedEmployee?.id == employee.id {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.blue)
                                }
                            }
                            .padding()
                            .background(Color(UIColor.secondarySystemGroupedBackground))
                            .cornerRadius(10)
                            .onTapGesture {
                                selectedEmployee = employee
                                dismiss()
                            }
                        }
                    }
                }
            }
            .navigationTitle("Выбор сотрудника")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Отмена") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                loadEmployees()
            }
        }
    }
    
    private func loadEmployees() {
        employees = MockAuthService.shared.getAllUsers().filter { user in
            user.role != "admin" && user.role != "manager"
        }
    }
}

// MARK: - Manager Selection View
struct ManagerSelectionView: View {
    @Binding var selectedManager: User?
    @State private var managers: [User] = []
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List(managers) { manager in
                Button(action: {
                    selectedManager = manager
                    dismiss()
                }) {
                    HStack {
                        Image(systemName: "person.circle.fill")
                            .font(.title2)
                            .foregroundColor(.gray)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("\(manager.firstName) \(manager.lastName)")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.primary)
                            
                            if let email = manager.email {
                                Text(email)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        Spacer()
                        
                        if manager.id == selectedManager?.id {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.blue)
                        }
                    }
                }
            }
            .listStyle(PlainListStyle())
            .navigationTitle("Выбор руководителя")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Отмена") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                loadManagers()
            }
        }
    }
    
    private func loadManagers() {
        managers = MockAuthService.shared.getAllUsers().filter { user in
            user.role == "manager" || user.role == "admin"
        }
    }
}

// MARK: - Customize Stage View
struct CustomizeStageView: View {
    let stage: OnboardingTemplateStage
    let onSave: (OnboardingTemplateStage) -> Void
    
    @State private var customizedStage: OnboardingTemplateStage
    @State private var stageTitle: String
    @State private var stageDescription: String
    @State private var stageDuration: Int
    @Environment(\.dismiss) private var dismiss
    
    init(stage: OnboardingTemplateStage, onSave: @escaping (OnboardingTemplateStage) -> Void) {
        self.stage = stage
        self.onSave = onSave
        self._customizedStage = State(initialValue: stage)
        self._stageTitle = State(initialValue: stage.title)
        self._stageDescription = State(initialValue: stage.description)
        self._stageDuration = State(initialValue: stage.duration)
    }
    
    var body: some View {
        Form {
            Section(header: Text("Информация об этапе")) {
                TextField("Название этапа", text: $stageTitle)
                
                TextField("Описание", text: $stageDescription, axis: .vertical)
                    .lineLimit(2...4)
                
                Stepper("Длительность: \(stageDuration) дн.", value: $stageDuration, in: 1...90)
            }
            
            Section(header: Text("Задачи этапа (\(customizedStage.taskTemplates.count))")) {
                ForEach(customizedStage.taskTemplates) { task in
                    HStack {
                        Image(systemName: getTaskIcon(task.type))
                            .foregroundColor(getTaskColor(task.type))
                            .frame(width: 30)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(task.title)
                                .font(.subheadline)
                            
                            Text(task.description)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                        }
                        
                        Spacer()
                        
                        Toggle("", isOn: .constant(true))
                            .labelsHidden()
                    }
                }
            }
        }
        .navigationTitle("Настройка этапа")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Сохранить") {
                    saveChanges()
                }
                .fontWeight(.semibold)
            }
        }
    }
    
    private func getTaskIcon(_ type: TaskType) -> String {
        switch type {
        case .course: return "book.closed.fill"
        case .test: return "doc.text.fill"
        case .document: return "doc.fill"
        case .meeting: return "person.2.fill"
        case .task: return "checkmark.square.fill"
        case .feedback: return "bubble.left.and.bubble.right.fill"
        }
    }
    
    private func getTaskColor(_ type: TaskType) -> Color {
        switch type {
        case .course: return .blue
        case .test: return .purple
        case .document: return .orange
        case .meeting: return .green
        case .task: return .gray
        case .feedback: return .pink
        }
    }
    
    private func saveChanges() {
        var updatedStage = customizedStage
        updatedStage.title = stageTitle
        updatedStage.description = stageDescription
        updatedStage.duration = stageDuration
        onSave(updatedStage)
        dismiss()
    }
}

#Preview {
    CreateProgramFromTemplateView(template: OnboardingTemplate.mockTemplates[0])
}
