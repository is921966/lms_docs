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
    @State private var selectedIcon: String
    @State private var selectedColor: Color
    @State private var modules: [Module]
    @State private var showingAddModule = false
    @State private var showingSaveAlert = false
    
    let icons = ["cart.fill", "tag.fill", "creditcard.fill", "eye.fill", "star.fill", "book.fill", "graduationcap.fill", "briefcase.fill"]
    let colors: [Color] = [.blue, .green, .orange, .purple, .yellow, .red, .pink, .indigo]
    
    init(course: Course) {
        self._course = State(initialValue: course)
        self._title = State(initialValue: course.title)
        self._description = State(initialValue: course.description)
        self._duration = State(initialValue: course.duration)
        self._selectedIcon = State(initialValue: course.icon)
        self._selectedColor = State(initialValue: course.color)
        self._modules = State(initialValue: course.modules)
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
                
                // Visual section
                Section("Оформление") {
                    // Icon picker
                    VStack(alignment: .leading) {
                        Text("Иконка")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 15) {
                                ForEach(icons, id: \.self) { icon in
                                    Button(action: { selectedIcon = icon }) {
                                        Image(systemName: icon)
                                            .font(.title2)
                                            .frame(width: 50, height: 50)
                                            .background(selectedIcon == icon ? selectedColor.opacity(0.2) : Color.gray.opacity(0.1))
                                            .foregroundColor(selectedIcon == icon ? selectedColor : .primary)
                                            .cornerRadius(10)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 10)
                                                    .stroke(selectedIcon == icon ? selectedColor : Color.clear, lineWidth: 2)
                                            )
                                    }
                                }
                            }
                        }
                    }
                    
                    // Color picker
                    VStack(alignment: .leading) {
                        Text("Цвет")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 15) {
                                ForEach(colors, id: \.self) { color in
                                    Button(action: { selectedColor = color }) {
                                        Circle()
                                            .fill(color)
                                            .frame(width: 40, height: 40)
                                            .overlay(
                                                Circle()
                                                    .stroke(Color.primary, lineWidth: selectedColor == color ? 3 : 0)
                                            )
                                    }
                                }
                            }
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
                
                // Preview section
                Section("Предпросмотр") {
                    CoursePreviewCard(
                        title: title,
                        description: description,
                        icon: selectedIcon,
                        color: selectedColor,
                        duration: duration,
                        progress: course.progress
                    )
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
            .alert("Изменения сохранены", isPresented: $showingSaveAlert) {
                Button("OK") {
                    dismiss()
                }
            } message: {
                Text("Курс успешно обновлен")
            }
        }
    }
    
    private func deleteModule(at offsets: IndexSet) {
        modules.remove(atOffsets: offsets)
    }
    
    private func saveCourse() {
        // Here you would save to backend
        // For now, just show success alert
        showingSaveAlert = true
    }
}

// Module edit row
struct ModuleEditRow: View {
    @Binding var module: Module
    @State private var isEditing = false
    @State private var editedTitle: String
    @State private var editedDuration: String
    
    init(module: Binding<Module>) {
        self._module = module
        self._editedTitle = State(initialValue: module.wrappedValue.title)
        self._editedDuration = State(initialValue: module.wrappedValue.duration)
    }
    
    var body: some View {
        HStack {
            if isEditing {
                VStack(alignment: .leading) {
                    TextField("Название модуля", text: $editedTitle)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    TextField("Длительность", text: $editedDuration)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                Button("Готово") {
                    // Create new module with updated values
                    module = Module(
                        title: editedTitle,
                        duration: editedDuration,
                        isCompleted: module.isCompleted
                    )
                    isEditing = false
                }
                .foregroundColor(.blue)
            } else {
                VStack(alignment: .leading) {
                    Text(module.title)
                        .font(.body)
                    Text(module.duration)
                        .font(.caption)
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
    @State private var duration = ""
    let onAdd: (Module) -> Void
    
    var body: some View {
        NavigationView {
            Form {
                TextField("Название модуля", text: $title)
                TextField("Длительность (например: 30 мин)", text: $duration)
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
                            duration: duration,
                            isCompleted: false
                        )
                        onAdd(newModule)
                        dismiss()
                    }
                    .disabled(title.isEmpty || duration.isEmpty)
                }
            }
        }
    }
}

// Course preview card
struct CoursePreviewCard: View {
    let title: String
    let description: String
    let icon: String
    let color: Color
    let duration: String
    let progress: Double
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .font(.system(size: 40))
                .foregroundColor(color)
                .frame(width: 60, height: 60)
                .background(color.opacity(0.1))
                .cornerRadius(15)
            
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.headline)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                
                HStack {
                    Text("\(Int(progress * 100))% завершено")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text(duration)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(15)
    }
} 