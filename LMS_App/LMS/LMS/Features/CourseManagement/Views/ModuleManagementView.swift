//
//  ModuleManagementView.swift
//  LMS
//
//  Created on Sprint 47 - Module Management
//

import SwiftUI

struct ModuleManagementView: View {
    @Binding var modules: [ManagedCourseModule]
    @Environment(\.dismiss) var dismiss
    @State private var showingAddModule = false
    @State private var editingModule: ManagedCourseModule?
    @State private var isEditMode = false
    
    var body: some View {
        NavigationView {
            VStack {
                if modules.isEmpty {
                    emptyStateView
                } else {
                    modulesList
                }
            }
            .navigationTitle("Управление модулями")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Готово") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack {
                        if !modules.isEmpty {
                            Button(isEditMode ? "Готово" : "Изменить") {
                                withAnimation {
                                    isEditMode.toggle()
                                }
                            }
                        }
                        
                        Button {
                            showingAddModule = true
                        } label: {
                            Image(systemName: "plus")
                        }
                    }
                }
            }
            .sheet(isPresented: $showingAddModule) {
                AddModuleSheet { newModule in
                    withAnimation {
                        modules.append(newModule)
                        reorderModules()
                    }
                }
            }
            .sheet(item: $editingModule) { module in
                EditModuleSheet(module: module) { updatedModule in
                    if let index = modules.firstIndex(where: { $0.id == module.id }) {
                        withAnimation {
                            modules[index] = updatedModule
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Views
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "rectangle.stack.badge.plus")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("Модули не добавлены")
                .font(.title2)
                .fontWeight(.medium)
            
            Text("Добавьте модули для структурирования курса")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button {
                showingAddModule = true
            } label: {
                Label("Добавить модуль", systemImage: "plus.circle.fill")
                    .font(.headline)
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .frame(maxHeight: .infinity)
    }
    
    private var modulesList: some View {
        List {
            ForEach(modules) { module in
                ModuleRowEditView(
                    module: module,
                    onEdit: {
                        editingModule = module
                    },
                    onDelete: {
                        deleteModule(module)
                    }
                )
                .deleteDisabled(!isEditMode)
            }
            .onMove(perform: isEditMode ? moveModules : nil)
            .onDelete(perform: isEditMode ? deleteModules : nil)
        }
        .listStyle(PlainListStyle())
        .environment(\.editMode, isEditMode ? .constant(.active) : .constant(.inactive))
    }
    
    // MARK: - Actions
    
    private func moveModules(from source: IndexSet, to destination: Int) {
        modules.move(fromOffsets: source, toOffset: destination)
        reorderModules()
    }
    
    private func deleteModules(at offsets: IndexSet) {
        modules.remove(atOffsets: offsets)
        reorderModules()
    }
    
    private func deleteModule(_ module: ManagedCourseModule) {
        withAnimation {
            modules.removeAll { $0.id == module.id }
            reorderModules()
        }
    }
    
    private func reorderModules() {
        for (index, _) in modules.enumerated() {
            modules[index].order = index + 1
        }
    }
}

// MARK: - Module Row Edit View

struct ModuleRowEditView: View {
    let module: ManagedCourseModule
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        HStack {
            Image(systemName: module.contentType.icon)
                .foregroundColor(module.contentType.color)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("\(module.order). \(module.title)")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(module.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                
                HStack {
                    Label("\(module.duration) мин", systemImage: "clock")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    
                    if module.contentUrl != nil {
                        Label("Контент загружен", systemImage: "checkmark.circle.fill")
                            .font(.caption2)
                            .foregroundColor(.green)
                    }
                }
            }
            
            Spacer()
            
            Button {
                onEdit()
            } label: {
                Image(systemName: "pencil.circle")
                    .foregroundColor(.blue)
                    .imageScale(.large)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Add Module View

struct AddModuleSheet: View {
    let onSave: (ManagedCourseModule) -> Void
    @Environment(\.dismiss) var dismiss
    
    @State private var title = ""
    @State private var description = ""
    @State private var contentType: ManagedCourseModule.ContentType = .document
    @State private var duration = ""
    @State private var contentUrl = ""
    @State private var showingError = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section("Основная информация") {
                    TextField("Название модуля", text: $title)
                    
                    TextField("Описание", text: $description, axis: .vertical)
                        .lineLimit(2...4)
                }
                
                Section("Тип контента") {
                    Picker("Тип", selection: $contentType) {
                        ForEach([
                            ManagedCourseModule.ContentType.video,
                            .document,
                            .quiz,
                            .cmi5
                        ], id: \.self) { type in
                            Label(type.displayName, systemImage: type.icon)
                                .tag(type)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                Section("Параметры") {
                    HStack {
                        TextField("Длительность", text: $duration)
                            .keyboardType(.numberPad)
                        Text("минут")
                    }
                    
                    if contentType != .quiz {
                        TextField("URL контента (опционально)", text: $contentUrl)
                            .textInputAutocapitalization(.never)
                            .keyboardType(.URL)
                    }
                }
                
                Section {
                    Text("После добавления модуля вы сможете загрузить контент")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
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
                    Button("Сохранить") {
                        saveModule()
                    }
                    .disabled(title.isEmpty || description.isEmpty || duration.isEmpty)
                }
            }
            .alert("Ошибка", isPresented: $showingError) {
                Button("OK") { }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    private func saveModule() {
        guard let durationInt = Int(duration), durationInt > 0 else {
            errorMessage = "Введите корректную длительность"
            showingError = true
            return
        }
        
        let newModule = ManagedCourseModule(
            id: UUID(),
            title: title,
            description: description,
            order: 1, // Will be updated by parent
            contentType: contentType,
            contentUrl: contentUrl.isEmpty ? nil : contentUrl,
            duration: durationInt
        )
        
        onSave(newModule)
        dismiss()
    }
}

// MARK: - Edit Module View

struct EditModuleSheet: View {
    let module: ManagedCourseModule
    let onSave: (ManagedCourseModule) -> Void
    @Environment(\.dismiss) var dismiss
    
    @State private var title: String
    @State private var description: String
    @State private var contentType: ManagedCourseModule.ContentType
    @State private var duration: String
    @State private var contentUrl: String
    @State private var showingError = false
    @State private var errorMessage = ""
    
    init(module: ManagedCourseModule, onSave: @escaping (ManagedCourseModule) -> Void) {
        self.module = module
        self.onSave = onSave
        self._title = State(initialValue: module.title)
        self._description = State(initialValue: module.description)
        self._contentType = State(initialValue: module.contentType)
        self._duration = State(initialValue: String(module.duration))
        self._contentUrl = State(initialValue: module.contentUrl ?? "")
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Основная информация") {
                    TextField("Название модуля", text: $title)
                    
                    TextField("Описание", text: $description, axis: .vertical)
                        .lineLimit(2...4)
                }
                
                Section("Тип контента") {
                    Picker("Тип", selection: $contentType) {
                        ForEach([
                            ManagedCourseModule.ContentType.video,
                            .document,
                            .quiz,
                            .cmi5
                        ], id: \.self) { type in
                            Label(type.displayName, systemImage: type.icon)
                                .tag(type)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                Section("Параметры") {
                    HStack {
                        TextField("Длительность", text: $duration)
                            .keyboardType(.numberPad)
                        Text("минут")
                    }
                    
                    if contentType != .quiz {
                        TextField("URL контента (опционально)", text: $contentUrl)
                            .textInputAutocapitalization(.never)
                            .keyboardType(.URL)
                    }
                }
            }
            .navigationTitle("Редактирование модуля")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Сохранить") {
                        saveModule()
                    }
                    .disabled(title.isEmpty || description.isEmpty || duration.isEmpty)
                }
            }
            .alert("Ошибка", isPresented: $showingError) {
                Button("OK") { }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    private func saveModule() {
        guard let durationInt = Int(duration), durationInt > 0 else {
            errorMessage = "Введите корректную длительность"
            showingError = true
            return
        }
        
        var updatedModule = module
        updatedModule.title = title
        updatedModule.description = description
        updatedModule.contentType = contentType
        updatedModule.duration = durationInt
        updatedModule.contentUrl = contentUrl.isEmpty ? nil : contentUrl
        
        onSave(updatedModule)
        dismiss()
    }
}

// MARK: - Extensions

#Preview {
    ModuleManagementView(modules: .constant([
        ManagedCourseModule(
            id: UUID(),
            title: "Введение в Swift",
            description: "Основные концепции языка",
            order: 1,
            contentType: .video,
            duration: 60
        ),
        ManagedCourseModule(
            id: UUID(),
            title: "Переменные и константы",
            description: "Работа с данными",
            order: 2,
            contentType: .document,
            duration: 30
        )
    ]))
}

// ContentType extensions moved to ModuleManagementViewModel.swift 