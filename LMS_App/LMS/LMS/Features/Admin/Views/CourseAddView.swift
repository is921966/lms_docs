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
        CourseCategory.categories.first { $0.id == selectedCategoryId }
    }
    
    var body: some View {
        NavigationView {
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
                        Text("Выберите категорию").tag(UUID?.none)
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
                    if modules.isEmpty {
                        Text("Добавьте модули к курсу")
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(modules.indices, id: \.self) { index in
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(modules[index].title)
                                        .font(.body)
                                    if let description = modules[index].description {
                                        Text(description)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                            .lineLimit(1)
                                    }
                                    Text("\(modules[index].duration) мин • \(modules[index].lessons.count) уроков")
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                            }
                        }
                        .onDelete(perform: deleteModule)
                    }
                    
                    Button(action: { showingAddModule = true }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("Добавить модуль")
                        }
                        .foregroundColor(.blue)
                    }
                }
                
                // Preview section
                Section("Предпросмотр") {
                    CoursePreviewCard(
                        title: title.isEmpty ? "Название курса" : title,
                        description: description.isEmpty ? "Описание курса" : description,
                        category: selectedCategory,
                        type: selectedType,
                        status: selectedStatus,
                        duration: duration,
                        progress: 0.0
                    )
                }
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
                    .fontWeight(.bold)
                    .disabled(title.isEmpty || description.isEmpty || selectedCategoryId == nil)
                }
            }
            .sheet(isPresented: $showingAddModule) {
                AddModuleView { newModule in
                    var updatedModule = newModule
                    updatedModule.orderIndex = modules.count + 1
                    modules.append(updatedModule)
                }
            }
        }
    }
    
    private func deleteModule(at offsets: IndexSet) {
        modules.remove(atOffsets: offsets)
        // Update order indices
        for i in modules.indices {
            modules[i].orderIndex = i + 1
        }
    }
    
    private func createCourse() {
        let newCourse = Course(
            title: title,
            description: description,
            categoryId: selectedCategoryId,
            status: selectedStatus,
            type: selectedType,
            modules: modules,
            duration: duration,
            estimatedHours: Int(duration.replacingOccurrences(of: " часов", with: "").replacingOccurrences(of: " час", with: "")) ?? 8,
            createdBy: UUID() // For now, just use a new UUID. In real app, would convert user ID
        )
        onAdd(newCourse)
        dismiss()
    }
} 