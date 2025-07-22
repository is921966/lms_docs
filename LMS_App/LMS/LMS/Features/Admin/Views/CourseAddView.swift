//
//  CourseAddView.swift
//  LMS
//
//  Created on 26/01/2025.
//

import SwiftUI

struct CourseAddView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var title = ""
    @State private var description = ""
    @State private var duration = "8 часов"
    @State private var selectedCategoryId: UUID?
    @State private var selectedType = CourseType.optional
    @State private var selectedStatus = CourseStatus.draft
    @State private var modules: [Module] = []
    @State private var showingAddModule = false

    let onAdd: (Course) -> Void

    var selectedCategory: CourseCategory? {
        // TODO: Implement category selection
        return nil
    }

    var body: some View {
        NavigationView {
            Form {
                basicInfoSection
                categorySection
                moduleSection
            }
            .navigationTitle("Новый курс")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Создать") {
                        createCourse()
                    }
                    .disabled(title.isEmpty || description.isEmpty)
                }
            }
        }
    }
    
    private var basicInfoSection: some View {
        Section("Основная информация") {
            TextField("Название курса", text: $title)
            TextField("Описание", text: $description, axis: .vertical)
                .lineLimit(3...6)
            TextField("Длительность", text: $duration)
        }
    }
    
    private var categorySection: some View {
        Section("Категория и тип") {
            Picker("Категория", selection: $selectedCategoryId) {
                Text("Выберите категорию").tag(UUID?.none)
                // TODO: Add category selection
            }
            
            Picker("Тип курса", selection: $selectedType) {
                Text("Обязательный").tag(CourseType.mandatory)
                Text("Опциональный").tag(CourseType.optional)
                Text("Рекомендуемый").tag(CourseType.recommended)
            }
            
            Picker("Статус", selection: $selectedStatus) {
                Text("Черновик").tag(CourseStatus.draft)
                Text("Опубликован").tag(CourseStatus.published)
                Text("Архив").tag(CourseStatus.archived)
            }
        }
    }
    
    private var moduleSection: some View {
        Section("Модули") {
            ForEach(modules) { module in
                HStack {
                    VStack(alignment: .leading) {
                        Text(module.title)
                            .font(.headline)
                        if !module.description.isEmpty {
                            Text(module.description)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    Spacer()
                    Text("\(module.lessons.count)")
                        .foregroundColor(.secondary)
                }
            }
            .onDelete(perform: deleteModule)
            
            NavigationLink("Добавить модуль") {
                AddModuleView { module in
                    modules.append(module)
                }
            }
        }
    }

    private func deleteModule(at offsets: IndexSet) {
        modules.remove(atOffsets: offsets)
        // Update order indices
        // TODO: Module doesn't have orderIndex property
    }

    private func createCourse() {
        let newCourse = Course(
            title: title,
            description: description,
            categoryId: selectedCategory?.rawValue,
            status: selectedStatus,
            type: selectedType,
            modules: modules,
            duration: duration,
            createdBy: UUID()
        )
        onAdd(newCourse)
        dismiss()
    }
}
