//
//  CourseEditView.swift
//  LMS
//
//  Created on 26/01/2025.
//

import SwiftUI

struct CourseEditView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var course: Course
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

    init(course: Course) {
        self._course = State(initialValue: course)
        self._title = State(initialValue: course.title)
        self._description = State(initialValue: course.description)
        self._duration = State(initialValue: course.duration)
        self._selectedCategoryId = State(initialValue: course.categoryId)
        self._selectedType = State(initialValue: course.type)
        self._selectedStatus = State(initialValue: course.status)
        self._modules = State(initialValue: course.modules)
        
        print("CourseEditView initialized with course: \(course.title)")
    }

    var selectedCategory: CourseCategory? {
        CourseCategory.categories.first { $0.id == selectedCategoryId }
    }

    var body: some View {
        VStack {
            // Debug header
            Text("DEBUG: CourseEditView")
                .font(.caption)
                .foregroundColor(.red)
                .padding(.top)
            
            Form {
                // Basic info section
                Section("Основная информация") {
                    TextField("Название курса", text: $title)

                    TextField("Описание", text: $description, axis: .vertical)
                        .lineLimit(3...6)

                    TextField("Длительность", text: $duration)
                }

                // Category and type section
                Section("Категория и тип") {
                    Picker("Категория", selection: $selectedCategoryId) {
                        Text("Не выбрана").tag(UUID?.none)
                        ForEach(CourseCategory.categories) { category in
                            Label(category.name, systemImage: category.icon)
                                .tag(category.id as UUID?)
                        }
                    }

                    Picker("Тип курса", selection: $selectedType) {
                        ForEach(CourseType.allCases, id: \.self) { type in
                            Label(type.rawValue, systemImage: type.icon)
                                .tag(type)
                        }
                    }

                    Picker("Статус", selection: $selectedStatus) {
                        ForEach(CourseStatus.allCases, id: \.self) { status in
                            HStack {
                                Circle()
                                    .fill(status.color)
                                    .frame(width: 12, height: 12)
                                Text(status.rawValue)
                            }
                            .tag(status)
                        }
                    }
                }

                // Modules section
                Section("Модули курса") {
                    ForEach($modules) { $module in
                        ModuleEditRow(module: $module)
                    }
                    .onDelete(perform: deleteModule)

                    Button(action: { showingAddModule = true }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("Добавить модуль")
                        }
                        .foregroundColor(.blue)
                    }
                }

                // Materials section
                Section("Материалы") {
                    Text("Материалов в курсе: \(course.materials.count)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    Button(action: { showingMaterialsManagement = true }) {
                        HStack {
                            Image(systemName: "paperclip.circle.fill")
                            Text("Управление материалами")
                        }
                        .foregroundColor(.blue)
                    }
                }

                // Competencies section
                Section("Компетенции") {
                    if !course.competencyIds.isEmpty {
                        Text("Связано компетенций: \(course.competencyIds.count)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    } else {
                        Text("Компетенции не назначены")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }

                    Button(action: { showingCompetencyLink = true }) {
                        HStack {
                            Image(systemName: "link.circle.fill")
                            Text("Управление компетенциями")
                        }
                        .foregroundColor(.blue)
                    }
                }

                // Positions section
                Section("Должности") {
                    if !course.positionIds.isEmpty {
                        Text("Рекомендовано для должностей: \(course.positionIds.count)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    } else {
                        Text("Должности не указаны")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }

                    Button(action: { showingPositionLink = true }) {
                        HStack {
                            Image(systemName: "person.badge.shield.checkmark")
                            Text("Управление должностями")
                        }
                        .foregroundColor(.blue)
                    }
                }

                // Test section
                Section("Итоговый тест") {
                    if course.testId != nil {
                        Text("Тест назначен")
                            .font(.subheadline)
                            .foregroundColor(.green)
                    } else {
                        Text("Тест не назначен")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }

                    Button(action: { showingTestLink = true }) {
                        HStack {
                            Image(systemName: "doc.badge.gearshape")
                            Text("Управление тестом")
                        }
                        .foregroundColor(.blue)
                    }
                }

                // Preview section
                Section("Предпросмотр") {
                    CoursePreviewCard(
                        title: title,
                        description: description,
                        category: selectedCategory,
                        type: selectedType,
                        status: selectedStatus,
                        duration: duration,
                        progress: course.progress
                    )
                }
            }
        }
        .navigationTitle("Редактирование курса")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Отмена") {
                    dismiss()
                }
            }

            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Сохранить") {
                    saveCourse()
                }
                .fontWeight(.bold)
            }
        }
        .sheet(isPresented: $showingAddModule) {
            AddModuleView { newModule in
                modules.append(newModule)
            }
        }
        .sheet(isPresented: $showingCompetencyLink) {
            CourseCompetencyLinkView(course: $course)
        }
        .sheet(isPresented: $showingPositionLink) {
            CoursePositionLinkView(course: $course)
        }
        .sheet(isPresented: $showingTestLink) {
            CourseTestLinkView(course: $course)
        }
        .sheet(isPresented: $showingMaterialsManagement) {
            CourseMaterialsView(course: $course)
        }
        .alert("Изменения сохранены", isPresented: $showingSaveAlert) {
            Button("OK") {
                dismiss()
            }
        } message: {
            Text("Курс успешно обновлен")
        }
        .onAppear {
            print("CourseEditView appeared with course: \(course.title)")
        }
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
            updatedCourse.categoryId = selectedCategoryId
            updatedCourse.type = selectedType
            updatedCourse.status = selectedStatus
            updatedCourse.modules = modules
            updatedCourse.updatedAt = Date()

            Course.mockCourses[courseIndex] = updatedCourse
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
                    module.title = editedTitle
                    module.description = editedDescription.isEmpty ? nil : editedDescription
                    isEditing = false
                }
                .foregroundColor(.blue)
            } else {
                VStack(alignment: .leading) {
                    Text(module.title)
                        .font(.body)
                    if let description = module.description {
                        Text(description)
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
                            description: description.isEmpty ? nil : description,
                            orderIndex: 0, // Will be set properly when added
                            lessons: []
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
                    Image(systemName: category.icon)
                        .font(.system(size: 40))
                        .foregroundColor(category.color)
                        .frame(width: 60, height: 60)
                        .background(category.color.opacity(0.1))
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
                                .fill(status.color)
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
                        Label(type.rawValue, systemImage: type.icon)
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
                            .fill(category?.color ?? .blue)
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
            categoryId: CourseCategory.categories.first?.id,
            status: .published,
            type: .mandatory,
            modules: [
                Module(
                    title: "Модуль 1",
                    description: "Первый модуль",
                    orderIndex: 0,
                    lessons: []
                )
            ],
            duration: "8 часов",
            createdBy: UUID()
        ))
    }
}
