//
//  CourseEditView.swift
//  LMS
//
//  Created on 26/01/2025.
//

import SwiftUI

struct CourseEditView: View {
    @State private var course: Course
    @Environment(\.dismiss) private var dismiss
    
    @State private var title: String
    @State private var description: String
    @State private var duration: String
    @State private var selectedCategoryId: UUID?
    @State private var selectedType: CourseType
    @State private var selectedStatus: CourseStatus
    @State private var modules: [Module]
    
    @State private var showingAddModule = false
    @State private var showingSaveAlert = false
    @State private var showingCompetencyLink = false
    @State private var showingPositionLink = false
    @State private var showingTestLink = false
    @State private var showingMaterialsManagement = false
    
    private var hasChanges: Bool {
        title != course.title ||
        description != course.description ||
        duration != course.duration ||
        selectedType != course.type ||
        selectedStatus != course.status ||
        modules.count != course.modules.count
    }

    init(course: Course) {
        self._course = State(initialValue: course)
        self._title = State(initialValue: course.title)
        self._description = State(initialValue: course.description)
        self._duration = State(initialValue: course.duration)
        self._selectedCategoryId = State(initialValue: UUID()) // TODO: Convert categoryId to UUID
        self._selectedType = State(initialValue: course.type)
        self._selectedStatus = State(initialValue: course.status)
        self._modules = State(initialValue: course.modules)
        
        print("CourseEditView initialized with course: \(course.title)")
    }

    var selectedCategory: CourseCategory? {
        // TODO: Implement category selection
        return nil
    }

    var body: some View {
        VStack {
            // Preview section
            coursePreviewHeader
            
            ScrollView {
                VStack(spacing: 20) {
                    basicInfoSection
                    categoryTypeSection
                    modulesSection
                }
                .padding()
            }
            
            // Save button
            saveButton
        }
        .navigationTitle("Редактировать курс")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Сохранить изменения?", isPresented: $showingSaveAlert) {
            Button("Отмена", role: .cancel) { }
            Button("Сохранить") {
                saveCourse()
            }
        } message: {
            Text("Вы уверены, что хотите сохранить изменения?")
        }
    }
    
    private var coursePreviewHeader: some View {
        VStack(spacing: 15) {
            // Course icon and info
            HStack(spacing: 20) {
                Image(systemName: "book.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.blue)
                    .frame(width: 60, height: 60)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(15)
                
                VStack(alignment: .leading, spacing: 5) {
                    Text(title.isEmpty ? "Название курса" : title)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    HStack {
                        Text(selectedStatus.rawValue)
                            .font(.caption)
                        
                        Circle()
                            .fill(Color.blue)
                            .frame(width: 8, height: 8)
                        
                        Text(selectedType.rawValue)
                            .font(.caption)
                    }
                    .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            
            // Progress stats
            HStack(spacing: 30) {
                VStack {
                    Text("\(modules.count)")
                        .font(.title2)
                        .fontWeight(.bold)
                    Text("Модулей")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                VStack {
                    Text(duration)
                        .font(.title2)
                        .fontWeight(.bold)
                    Text("Длительность")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
    }
    
    private var basicInfoSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Основная информация")
                .font(.headline)
            
            VStack(alignment: .leading, spacing: 10) {
                Text("Название")
                    .font(.caption)
                    .foregroundColor(.secondary)
                TextField("Название курса", text: $title)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Text("Описание")
                    .font(.caption)
                    .foregroundColor(.secondary)
                TextField("Описание курса", text: $description, axis: .vertical)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .lineLimit(3...6)
                
                Text("Длительность")
                    .font(.caption)
                    .foregroundColor(.secondary)
                TextField("Длительность", text: $duration)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.05), radius: 5)
    }
    
    private var categoryTypeSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Категория и тип")
                .font(.headline)
            
            VStack(spacing: 15) {
                Picker("Категория", selection: $selectedCategoryId) {
                    Text("Выберите категорию").tag(UUID?.none)
                }
                
                Picker("Тип курса", selection: $selectedType) {
                    ForEach(CourseType.allCases, id: \.self) { type in
                        Text(type.rawValue).tag(type)
                    }
                }
                
                Picker("Статус", selection: $selectedStatus) {
                    ForEach(CourseStatus.allCases, id: \.self) { status in
                        HStack {
                            Circle()
                                .fill(Color.blue) // TODO: Add proper status color
                                .frame(width: 8, height: 8)
                            Text(status.rawValue)
                        }
                        .tag(status)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.05), radius: 5)
    }
    
    private var modulesSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Text("Модули курса")
                    .font(.headline)
                
                Spacer()
                
                Text("\(modules.count)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color(.systemGray5))
                    .cornerRadius(10)
            }
            
            VStack(spacing: 10) {
                ForEach(modules) { module in
                    ModuleEditRow(module: .constant(module))
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.05), radius: 5)
    }
    
    private var saveButton: some View {
        Button(action: { showingSaveAlert = true }) {
            Text("Сохранить изменения")
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(hasChanges ? Color.blue : Color.gray)
                .cornerRadius(10)
        }
        .disabled(!hasChanges)
        .padding()
    }

    private func deleteModule(at offsets: IndexSet) {
        modules.remove(atOffsets: offsets)
    }

    private func saveCourse() {
        // Обновляем курс в сервисе
        if let courseIndex = Course.mockCourses.firstIndex(where: { $0.id == course.id }) {
            var updatedCourse = course
            updatedCourse.title = title
            updatedCourse.description = description
            updatedCourse.duration = duration
            updatedCourse.categoryId = selectedCategory?.rawValue
            updatedCourse.type = selectedType
            updatedCourse.status = selectedStatus
            updatedCourse.modules = modules
            updatedCourse.updatedAt = Date()

            // TODO: Update course in data store
            // Course.mockCourses[courseIndex] = updatedCourse
        }

        // В реальном приложении здесь будет вызов API
        // await courseService.updateCourse(course)

        showingSaveAlert = true
    }
}

// Module edit row
struct ModuleEditRow: View {
    @Binding var module: Module
    @State private var isEditing = false
    @State private var editedTitle: String
    @State private var editedDescription: String

    init(module: Binding<Module>) {
        self._module = module
        self._editedTitle = State(initialValue: module.wrappedValue.title)
        self._editedDescription = State(initialValue: module.wrappedValue.description ?? "")
    }

    var body: some View {
        HStack {
            if isEditing {
                VStack(alignment: .leading) {
                    TextField("Название модуля", text: $editedTitle)
                        .textFieldStyle(RoundedBorderTextFieldStyle())

                    TextField("Описание (необязательно)", text: $editedDescription)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }

                Button("Готово") {
                    // TODO: Update module with new values
                    // Module properties are immutable
                    isEditing = false
                }
                .foregroundColor(.blue)
            } else {
                VStack(alignment: .leading) {
                    Text(module.title)
                        .font(.body)
                    if !module.description.isEmpty {
                        Text(module.description)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Text("\(module.duration) мин • \(module.lessons.count) уроков")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }

                Spacer()

                Button(action: { isEditing = true }) {
                    Image(systemName: "pencil")
                        .foregroundColor(.blue)
                }
            }
        }
    }
}

// Add module view
struct AddModuleView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var title = ""
    @State private var description = ""
    let onAdd: (Module) -> Void

    var body: some View {
        NavigationView {
            Form {
                TextField("Название модуля", text: $title)
                TextField("Описание (необязательно)", text: $description, axis: .vertical)
                    .lineLimit(2...4)
            }
            .navigationTitle("Новый модуль")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Добавить") {
                        let newModule = Module(
                            title: title,
                            description: description.isEmpty ? "" : description,
                            lessons: [],
                            duration: 0,
                            order: 0
                        )
                        onAdd(newModule)
                        dismiss()
                    }
                    .disabled(title.isEmpty)
                }
            }
        }
    }
}

// Course preview card
struct CoursePreviewCard: View {
    let title: String
    let description: String
    let category: CourseCategory?
    let type: CourseType
    let status: CourseStatus
    let duration: String
    let progress: Double

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                if let category = category {
                    Image(systemName: "book.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.blue)
                        .frame(width: 60, height: 60)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(15)
                } else {
                    Image(systemName: "book.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.gray)
                        .frame(width: 60, height: 60)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(15)
                }

                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(title)
                            .font(.headline)

                        Spacer()

                        HStack(spacing: 4) {
                            Circle()
                                .fill(Color.blue) // TODO: Add proper status color
                                .frame(width: 8, height: 8)
                            Text(status.rawValue)
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }

                    Text(description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)

                    HStack {
                        Label(type.rawValue, systemImage: "book.fill")
                            .font(.caption2)
                            .foregroundColor(.secondary)

                        Spacer()

                        Text(duration)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }

            if progress > 0 {
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 4)

                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color.blue)
                            .frame(width: geometry.size.width * progress, height: 4)
                    }
                }
                .frame(height: 4)

                Text("\(Int(progress * 100))% завершено")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(15)
    }
}

#Preview {
    NavigationView {
        CourseEditView(course: Course(
            title: "Тестовый курс",
            description: "Описание тестового курса",
            categoryId: CourseCategory.business.rawValue,
            status: .published,
            type: .mandatory,
            modules: [
                Module(
                    title: "Модуль 1",
                    description: "Первый модуль",
                    lessons: []
                )
            ],
            duration: "8 часов",
            createdBy: UUID()
        ))
    }
}
