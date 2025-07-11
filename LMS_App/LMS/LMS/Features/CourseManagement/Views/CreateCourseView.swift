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
                    Button("Добавить модуль") {
                        // TODO: Implement module addition
                    }
                    .accessibilityIdentifier("addModuleButton")
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
                        saveCourse()
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
    }
    
    private func saveCourse() {
        guard let durationInt = Int(duration), durationInt > 0 else {
            errorMessage = "Введите корректную продолжительность"
            showingError = true
            return
        }
        
        let newCourse = ManagedCourse(
            title: title,
            description: description,
            duration: durationInt,
            status: status
        )
        
        viewModel.createCourse(newCourse)
        dismiss()
    }
}

#Preview {
    CreateCourseView(viewModel: CourseManagementViewModel())
} 