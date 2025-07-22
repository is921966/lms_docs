import SwiftUI

struct CreateCourseView: View {
    @ObservedObject var viewModel: CourseManagementViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var title = ""
    @State private var description = ""
    @State private var duration = ""
    @State private var status: ManagedCourseStatus = .draft
    @State private var showingError = false
    @State private var errorMessage = ""
    @State private var modules: [ManagedCourseModule] = []
    @State private var showingModuleManagement = false
    @State private var competencies: [UUID] = []
    @State private var showingCompetencyBinding = false
    
    var body: some View {
        NavigationView {
            Form {
                Section("Основная информация") {
                    TextField("Название курса", text: $title)
                        .accessibilityIdentifier("courseTitleField")
                    
                    TextField("Описание", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                        .accessibilityIdentifier("courseDescriptionField")
                    
                    HStack {
                        TextField("Продолжительность", text: $duration)
                            .keyboardType(.numberPad)
                            .accessibilityIdentifier("courseDurationField")
                        Text("часов")
                    }
                }
                
                Section("Статус") {
                    Picker("Статус", selection: $status) {
                        ForEach(ManagedCourseStatus.allCases, id: \.self) { status in
                            Text(status.displayName).tag(status)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .accessibilityIdentifier("courseStatusPicker")
                }
                
                Section("Модули") {
                    if modules.isEmpty {
                        Text("Модули не добавлены")
                            .foregroundColor(.secondary)
                    } else {
                        Text("\(modules.count) модулей добавлено")
                    }
                    
                    Button("Добавить модуль") {
                        showingModuleManagement = true
                    }
                    .accessibilityIdentifier("addModuleButton")
                }
                
                Section("Компетенции") {
                    if competencies.isEmpty {
                        Text("Компетенции не привязаны")
                            .foregroundColor(.secondary)
                    } else {
                        Text("\(competencies.count) компетенций выбрано")
                    }
                    
                    Button("Привязать компетенции") {
                        showingCompetencyBinding = true
                    }
                    .accessibilityIdentifier("bindCompetenciesButton")
                }
            }
            .navigationTitle("Новый курс")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        dismiss()
                    }
                    .accessibilityIdentifier("cancelButton")
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Сохранить") {
                        createCourse()
                    }
                    .disabled(title.isEmpty || description.isEmpty || duration.isEmpty)
                    .accessibilityIdentifier("saveCourseButton")
                }
            }
            .alert("Ошибка", isPresented: $showingError) {
                Button("OK") { }
            } message: {
                Text(errorMessage)
            }
        }
        .sheet(isPresented: $showingModuleManagement) {
            ModuleManagementView(modules: $modules)
        }
        .sheet(isPresented: $showingCompetencyBinding) {
            let tempCourse = ManagedCourse(
                title: "Временный курс",
                description: "",
                duration: 1,
                status: .draft,
                competencies: competencies
            )
            CompetencyBindingView(course: tempCourse) { updatedCourse in
                competencies = updatedCourse.competencies
            }
        }
    }
    
    private func createCourse() {
        guard !title.isEmpty else {
            errorMessage = "Введите название курса"
            showingError = true
            return
        }
        
        guard !description.isEmpty else {
            errorMessage = "Введите описание курса"
            showingError = true
            return
        }
        
        guard let durationInt = Int(duration), durationInt > 0 else {
            errorMessage = "Введите корректную продолжительность"
            showingError = true
            return
        }
        
        Task {
            do {
                let newCourse = try await viewModel.createCourse(
                    title: title,
                    description: description,
                    duration: durationInt
                )
                
                // Update the created course with additional properties
                var updatedCourse = newCourse
                updatedCourse.status = status
                updatedCourse.competencies = competencies
                updatedCourse.modules = modules
                
                _ = try await viewModel.updateCourse(updatedCourse)
                
                dismiss()
            } catch {
                errorMessage = error.localizedDescription
                showingError = true
            }
        }
    }
}

#Preview {
    CreateCourseView(viewModel: CourseManagementViewModel())
} 