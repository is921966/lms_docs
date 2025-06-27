import SwiftUI

struct NewEmployeeOnboardingView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var onboardingService = OnboardingMockService.shared
    @ObservedObject var userService = UserMockService.shared
    
    @State private var selectedEmployee: Employee?
    @State private var selectedTemplate: OnboardingTemplate?
    @State private var startDate = Date()
    @State private var mentorId: String = ""
    @State private var showingEmployeePicker = false
    @State private var showingTemplatePicker = false
    @State private var customStages: [OnboardingTemplateStage] = []
    @State private var showingSuccessAlert = false
    @State private var isCreating = false
    
    // Search states
    @State private var employeeSearchText = ""
    @State private var templateSearchText = ""
    
    var filteredEmployees: [Employee] {
        let employees = userService.getUsers()
        if employeeSearchText.isEmpty {
            return employees
        }
        return employees.filter { user in
            user.fullName.localizedCaseInsensitiveContains(employeeSearchText) ||
            user.email.localizedCaseInsensitiveContains(employeeSearchText)
        }
    }
    
    var filteredTemplates: [OnboardingTemplate] {
        let templates = onboardingService.getTemplates()
        if templateSearchText.isEmpty {
            return templates
        }
        return templates.filter { template in
            template.name.localizedCaseInsensitiveContains(templateSearchText) ||
            template.position.localizedCaseInsensitiveContains(templateSearchText)
        }
    }
    
    var body: some View {
        NavigationView {
            Form {
                employeeSection
                templateSection
                programDetailsSection
                if selectedTemplate != nil {
                    stagesSection
                }
            }
            .navigationTitle("Новая программа адаптации")
            .navigationBarTitleDisplayMode(.large)
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
                    .disabled(!isFormValid)
                    .bold()
                }
            }
            .sheet(isPresented: $showingEmployeePicker) {
                employeePickerSheet
            }
            .sheet(isPresented: $showingTemplatePicker) {
                templatePickerSheet
            }
            .alert("Программа создана", isPresented: $showingSuccessAlert) {
                Button("OK") {
                    dismiss()
                }
            } message: {
                Text("Программа адаптации успешно создана для \(selectedEmployee?.fullName ?? "")")
            }
            .disabled(isCreating)
            .overlay {
                if isCreating {
                    ZStack {
                        Color.black.opacity(0.3)
                            .ignoresSafeArea()
                        
                        ProgressView("Создание программы...")
                            .padding()
                            .background(Color(.systemBackground))
                            .cornerRadius(10)
                            .shadow(radius: 5)
                    }
                }
            }
        }
    }
    
    // MARK: - Sections
    
    private var employeeSection: some View {
        Section {
            if let employee = selectedEmployee {
                HStack {
                    Image(systemName: "person.circle.fill")
                        .font(.largeTitle)
                        .foregroundColor(.blue)
                    
                    VStack(alignment: .leading) {
                        Text(employee.fullName)
                            .font(.headline)
                        Text(employee.position)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(employee.email)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Button("Изменить") {
                        showingEmployeePicker = true
                    }
                    .font(.caption)
                }
                .padding(.vertical, 8)
            } else {
                Button(action: { showingEmployeePicker = true }) {
                    HStack {
                        Image(systemName: "person.badge.plus")
                            .foregroundColor(.blue)
                        Text("Выбрать сотрудника")
                            .foregroundColor(.primary)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.secondary)
                            .font(.caption)
                    }
                }
            }
        } header: {
            Text("Сотрудник")
        }
    }
    
    private var templateSection: some View {
        Section {
            if let template = selectedTemplate {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "doc.text.fill")
                            .foregroundColor(.green)
                        Text(template.name)
                            .font(.headline)
                        Spacer()
                        Button("Изменить") {
                            showingTemplatePicker = true
                        }
                        .font(.caption)
                    }
                    
                    Text("Позиция: \(template.position)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("\(template.stages.count) этапов, ~\(template.durationDays) дней")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 4)
            } else {
                Button(action: { showingTemplatePicker = true }) {
                    HStack {
                        Image(systemName: "doc.badge.plus")
                            .foregroundColor(.green)
                        Text("Выбрать шаблон")
                            .foregroundColor(.primary)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.secondary)
                            .font(.caption)
                    }
                }
            }
        } header: {
            Text("Шаблон программы")
        }
    }
    
    private var programDetailsSection: some View {
        Section {
            DatePicker("Дата начала", selection: $startDate, displayedComponents: .date)
            
            HStack {
                Image(systemName: "person.2.fill")
                    .foregroundColor(.orange)
                TextField("ID наставника", text: $mentorId)
                    .textFieldStyle(.roundedBorder)
            }
        } header: {
            Text("Детали программы")
        } footer: {
            Text("Программа начнется в указанную дату. Наставник будет получать уведомления о прогрессе.")
                .font(.caption)
        }
    }
    
    private var stagesSection: some View {
        Section {
            ForEach(customStages.indices, id: \.self) { index in
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Этап \(index + 1)")
                            .font(.headline)
                        Spacer()
                        Text("День \(customStages[index].dayOffset)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    TextField("Название этапа", text: $customStages[index].name)
                        .textFieldStyle(.roundedBorder)
                    
                    Text("\(customStages[index].tasks.count) задач")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 4)
            }
        } header: {
            HStack {
                Text("Этапы программы")
                Spacer()
                Button("Сбросить") {
                    if let template = selectedTemplate {
                        customStages = template.stages
                    }
                }
                .font(.caption)
            }
        } footer: {
            Text("Вы можете изменить названия этапов. Задачи будут скопированы из шаблона.")
                .font(.caption)
        }
    }
    
    // MARK: - Sheets
    
    private var employeePickerSheet: some View {
        NavigationView {
            List {
                ForEach(filteredEmployees) { employee in
                    Button(action: {
                        selectedEmployee = employee
                        showingEmployeePicker = false
                    }) {
                        HStack {
                            Image(systemName: "person.circle.fill")
                                .font(.largeTitle)
                                .foregroundColor(.blue)
                            
                            VStack(alignment: .leading) {
                                Text(employee.fullName)
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                Text(employee.position)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text(employee.email)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            if selectedEmployee?.id == employee.id {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.blue)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .searchable(text: $employeeSearchText, prompt: "Поиск сотрудников")
            .navigationTitle("Выбор сотрудника")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Готово") {
                        showingEmployeePicker = false
                    }
                }
            }
        }
    }
    
    private var templatePickerSheet: some View {
        NavigationView {
            List {
                ForEach(filteredTemplates) { template in
                    Button(action: {
                        selectedTemplate = template
                        customStages = template.stages
                        showingTemplatePicker = false
                    }) {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "doc.text.fill")
                                    .foregroundColor(.green)
                                Text(template.name)
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                Spacer()
                                if selectedTemplate?.id == template.id {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.blue)
                                }
                            }
                            
                            Text("Позиция: \(template.position)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            HStack {
                                Label("\(template.stages.count) этапов", systemImage: "list.bullet")
                                Label("~\(template.durationDays) дней", systemImage: "calendar")
                            }
                            .font(.caption)
                            .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .searchable(text: $templateSearchText, prompt: "Поиск шаблонов")
            .navigationTitle("Выбор шаблона")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Готово") {
                        showingTemplatePicker = false
                    }
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private var isFormValid: Bool {
        selectedEmployee != nil && selectedTemplate != nil && !mentorId.isEmpty
    }
    
    private func createProgram() {
        guard let employee = selectedEmployee,
              let template = selectedTemplate else { return }
        
        isCreating = true
        
        // Simulate API call
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            // Create stages from template
            let stages = customStages.enumerated().map { index, templateStage in
                OnboardingStage(
                    id: UUID().uuidString,
                    name: templateStage.name,
                    dayOffset: templateStage.dayOffset,
                    tasks: templateStage.tasks.map { taskTemplate in
                        OnboardingTask(
                            id: UUID().uuidString,
                            title: taskTemplate.title,
                            description: taskTemplate.description,
                            type: taskTemplate.type,
                            isCompleted: false,
                            completedAt: nil,
                            dueDate: Calendar.current.date(
                                byAdding: .day,
                                value: templateStage.dayOffset + taskTemplate.dayOffset,
                                to: startDate
                            ),
                            courseId: taskTemplate.courseId,
                            testId: taskTemplate.testId,
                            documentUrl: taskTemplate.documentUrl,
                            meetingId: taskTemplate.meetingId
                        )
                    }
                )
            }
            
            // Create new program
            let newProgram = OnboardingProgram(
                id: UUID().uuidString,
                employeeId: employee.id,
                employeeName: employee.fullName,
                employeePosition: employee.position,
                employeePhotoUrl: nil,
                templateId: template.id,
                templateName: template.name,
                startDate: startDate,
                endDate: Calendar.current.date(
                    byAdding: .day,
                    value: template.durationDays,
                    to: startDate
                ),
                status: .notStarted,
                progress: 0.0,
                mentorId: mentorId,
                mentorName: "Наставник",
                stages: stages,
                createdAt: Date(),
                updatedAt: Date()
            )
            
            // Add to service
            onboardingService.addProgram(newProgram)
            
            isCreating = false
            showingSuccessAlert = true
        }
    }
}

// MARK: - Preview

struct NewEmployeeOnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        NewEmployeeOnboardingView()
    }
} 