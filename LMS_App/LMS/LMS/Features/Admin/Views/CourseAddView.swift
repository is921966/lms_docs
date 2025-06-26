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
    @State private var duration = "1 час"
    @State private var selectedIcon = "book.fill"
    @State private var selectedColor = Color.blue
    @State private var modules: [Module] = []
    @State private var showingAddModule = false
    
    let onAdd: (Course) -> Void
    let icons = ["cart.fill", "tag.fill", "creditcard.fill", "eye.fill", "star.fill", "book.fill", "graduationcap.fill", "briefcase.fill"]
    let colors: [Color] = [.blue, .green, .orange, .purple, .yellow, .red, .pink, .indigo]
    
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
                    if modules.isEmpty {
                        Text("Добавьте модули к курсу")
                            .foregroundColor(.secondary)
                    } else {
                        ForEach($modules) { $module in
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(module.title)
                                        .font(.body)
                                    Text(module.duration)
                                        .font(.caption)
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
                        icon: selectedIcon,
                        color: selectedColor,
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
                    .disabled(title.isEmpty || description.isEmpty)
                }
            }
            .sheet(isPresented: $showingAddModule) {
                AddModuleView { newModule in
                    modules.append(newModule)
                }
            }
        }
    }
    
    private func deleteModule(at offsets: IndexSet) {
        modules.remove(atOffsets: offsets)
    }
    
    private func createCourse() {
        let newCourse = Course(
            title: title,
            description: description,
            progress: 0.0,
            icon: selectedIcon,
            color: selectedColor,
            duration: duration,
            modules: modules
        )
        onAdd(newCourse)
        dismiss()
    }
} 