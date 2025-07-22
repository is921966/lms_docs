//
//  EditCourseView.swift
//  LMS
//
//  Created on Sprint 40 - Course Management Enhancement
//

import SwiftUI

struct EditCourseView: View {
    let course: ManagedCourse
    let onSave: (ManagedCourse) -> Void
    
    @Environment(\.dismiss) var dismiss
    @State private var title: String
    @State private var description: String
    @State private var duration: String
    @State private var status: ManagedCourseStatus
    @State private var showingError = false
    @State private var errorMessage = ""
    @State private var modules: [ManagedCourseModule]
    @State private var showingModuleManagement = false
    @State private var showingCompetencyBinding = false
    @State private var competencies: [UUID]
    
    init(course: ManagedCourse, onSave: @escaping (ManagedCourse) -> Void) {
        self.course = course
        self.onSave = onSave
        self._title = State(initialValue: course.title)
        self._description = State(initialValue: course.description)
        self._duration = State(initialValue: String(course.duration))
        self._status = State(initialValue: course.status)
        self._modules = State(initialValue: course.modules)
        self._competencies = State(initialValue: course.competencies)
    }
    
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
                
                Section("Дополнительная информация") {
                    if course.cmi5PackageId != nil {
                        HStack {
                            Label("Cmi5 курс", systemImage: "cube.box.fill")
                                .foregroundColor(.blue)
                            Spacer()
                            Text("Импортирован")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    HStack {
                        Text("Создан")
                        Spacer()
                        Text(course.createdAt.formatted(date: .abbreviated, time: .shortened))
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Изменен")
                        Spacer()
                        Text(course.updatedAt.formatted(date: .abbreviated, time: .shortened))
                            .foregroundColor(.secondary)
                    }
                }
                
                Section("Модули") {
                    if modules.isEmpty {
                        Text("Модули не добавлены")
                            .foregroundColor(.secondary)
                    } else {
                        Text("\(modules.count) модулей")
                    }
                    
                    Button("Управление модулями") {
                        showingModuleManagement = true
                    }
                    .accessibilityIdentifier("manageModulesButton")
                }
                
                Section("Компетенции") {
                    if competencies.isEmpty {
                        Text("Компетенции не привязаны")
                            .foregroundColor(.secondary)
                    } else {
                        Text("\(competencies.count) компетенций привязано")
                    }
                    
                    Button("Управление компетенциями") {
                        showingCompetencyBinding = true
                    }
                    .accessibilityIdentifier("manageCompetenciesButton")
                }
            }
            .navigationTitle("Редактирование курса")
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
        .sheet(isPresented: $showingModuleManagement) {
            ModuleManagementView(modules: $modules)
        }
        .sheet(isPresented: $showingCompetencyBinding) {
            var tempCourse = course
            tempCourse.competencies = competencies
            return CompetencyBindingView(course: tempCourse) { updatedCourse in
                competencies = updatedCourse.competencies
            }
        }
    }
    
    private func saveCourse() {
        guard let durationInt = Int(duration), durationInt > 0 else {
            errorMessage = "Введите корректную продолжительность"
            showingError = true
            return
        }
        
        var updatedCourse = course
        updatedCourse.title = title
        updatedCourse.description = description
        updatedCourse.duration = durationInt
        updatedCourse.status = status
        updatedCourse.modules = modules
        updatedCourse.competencies = competencies
        updatedCourse.updatedAt = Date()
        
        onSave(updatedCourse)
        dismiss()
    }
}

#Preview {
    EditCourseView(
        course: ManagedCourse(
            title: "Тестовый курс",
            description: "Описание тестового курса",
            duration: 40,
            status: .draft
        )
    ) { _ in }
} 