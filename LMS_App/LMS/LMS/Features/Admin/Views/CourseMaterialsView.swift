//
//  CourseMaterialsView.swift
//  LMS
//
//  Created on 26/01/2025.
//

import SwiftUI
import PhotosUI

struct CourseMaterialsView: View {
    @Binding var course: Course
    @State private var showingAddMaterial = false
    @State private var selectedMaterial: CourseMaterial?
    @State private var showingDeleteAlert = false
    @State private var materialToDelete: CourseMaterial?
    
    var body: some View {
        NavigationView {
            List {
                // Course materials
                Section("Материалы курса") {
                    if course.materials.isEmpty {
                        Text("Материалы не добавлены")
                            .foregroundColor(.secondary)
                            .italic()
                    } else {
                        ForEach(course.materials) { material in
                            MaterialRow(material: material) {
                                selectedMaterial = material
                            } onDelete: {
                                materialToDelete = material
                                showingDeleteAlert = true
                            }
                        }
                    }
                    
                    Button(action: { showingAddMaterial = true }) {
                        Label("Добавить материал", systemImage: "plus.circle.fill")
                            .foregroundColor(.blue)
                    }
                }
                
                // Module materials
                ForEach(course.modules.indices, id: \.self) { moduleIndex in
                    Section("Модуль: \(course.modules[moduleIndex].title)") {
                        if course.modules[moduleIndex].materials.isEmpty {
                            Text("Материалы не добавлены")
                                .foregroundColor(.secondary)
                                .italic()
                        } else {
                            ForEach(course.modules[moduleIndex].materials) { material in
                                MaterialRow(material: material) {
                                    selectedMaterial = material
                                } onDelete: {
                                    // Remove from module
                                    course.modules[moduleIndex].materials.removeAll { $0.id == material.id }
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Материалы курса")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingAddMaterial) {
                AddMaterialView { newMaterial in
                    course.materials.append(newMaterial)
                }
            }
            .sheet(item: $selectedMaterial) { material in
                MaterialDetailView(material: material)
            }
            .alert("Удалить материал?", isPresented: $showingDeleteAlert) {
                Button("Отмена", role: .cancel) { }
                Button("Удалить", role: .destructive) {
                    if let material = materialToDelete {
                        course.materials.removeAll { $0.id == material.id }
                    }
                }
            } message: {
                if let material = materialToDelete {
                    Text("Вы уверены, что хотите удалить материал \"\(material.title)\"?")
                }
            }
        }
    }
}

// Material row component
struct MaterialRow: View {
    let material: CourseMaterial
    let onTap: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        HStack {
            Image(systemName: material.type.icon)
                .font(.title2)
                .foregroundColor(materialColor)
                .frame(width: 40, height: 40)
                .background(materialColor.opacity(0.1))
                .cornerRadius(10)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(material.title)
                    .font(.body)
                    .lineLimit(1)
                
                HStack {
                    Text(material.type.rawValue)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    if let size = material.fileSize {
                        Text("• \(formatFileSize(size))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    if let duration = material.duration {
                        Text("• \(duration) мин")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Spacer()
            
            Button(action: onDelete) {
                Image(systemName: "trash")
                    .foregroundColor(.red)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .contentShape(Rectangle())
        .onTapGesture {
            onTap()
        }
    }
    
    private var materialColor: Color {
        switch material.type {
        case .video: return .blue
        case .presentation: return .orange
        case .document: return .green
        case .link: return .purple
        case .archive: return .gray
        }
    }
    
    private func formatFileSize(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        return formatter.string(fromByteCount: bytes)
    }
}

// Add material view
struct AddMaterialView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var title = ""
    @State private var selectedType: CourseMaterial.MaterialType = .document
    @State private var url = ""
    @State private var duration = ""
    @State private var selectedItem: PhotosPickerItem?
    @State private var showingFilePicker = false
    
    let onAdd: (CourseMaterial) -> Void
    
    var body: some View {
        NavigationView {
            Form {
                Section("Основная информация") {
                    TextField("Название материала", text: $title)
                    
                    Picker("Тип материала", selection: $selectedType) {
                        ForEach(CourseMaterial.MaterialType.allCases, id: \.self) { type in
                            Label(type.rawValue, systemImage: type.icon)
                                .tag(type)
                        }
                    }
                }
                
                Section("Файл или ссылка") {
                    if selectedType == .link {
                        TextField("URL ссылки", text: $url)
                            .keyboardType(.URL)
                            .autocapitalization(.none)
                    } else {
                        Button(action: { showingFilePicker = true }) {
                            HStack {
                                Image(systemName: "doc.badge.plus")
                                Text("Выбрать файл")
                                Spacer()
                                if !url.isEmpty {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                }
                            }
                        }
                        
                        if !url.isEmpty {
                            Text(url)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                if selectedType == .video {
                    Section("Дополнительно") {
                        TextField("Длительность (минуты)", text: $duration)
                            .keyboardType(.numberPad)
                    }
                }
                
                Section("Поддерживаемые форматы") {
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(CourseMaterial.MaterialType.allCases, id: \.self) { type in
                            HStack {
                                Image(systemName: type.icon)
                                    .foregroundColor(colorForType(type))
                                    .frame(width: 20)
                                
                                Text(type.rawValue)
                                    .font(.subheadline)
                                
                                Spacer()
                                
                                if !type.acceptedExtensions.isEmpty {
                                    Text(type.acceptedExtensions.joined(separator: ", "))
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Новый материал")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Добавить") {
                        let newMaterial = CourseMaterial(
                            title: title,
                            type: selectedType,
                            url: url.isEmpty ? nil : url,
                            fileSize: nil, // Would be calculated from actual file
                            duration: Int(duration),
                            uploadedAt: Date()
                        )
                        onAdd(newMaterial)
                        dismiss()
                    }
                    .disabled(title.isEmpty || (selectedType != .link && url.isEmpty))
                }
            }
            .fileImporter(
                isPresented: $showingFilePicker,
                allowedContentTypes: contentTypesForMaterialType(selectedType),
                allowsMultipleSelection: false
            ) { result in
                switch result {
                case .success(let urls):
                    if let url = urls.first {
                        self.url = url.lastPathComponent
                        // In real app, would upload file and get URL
                    }
                case .failure(let error):
                    print("Error selecting file: \(error)")
                }
            }
        }
    }
    
    private func colorForType(_ type: CourseMaterial.MaterialType) -> Color {
        switch type {
        case .video: return .blue
        case .presentation: return .orange
        case .document: return .green
        case .link: return .purple
        case .archive: return .gray
        }
    }
    
    private func contentTypesForMaterialType(_ type: CourseMaterial.MaterialType) -> [UTType] {
        switch type {
        case .video:
            return [.movie, .mpeg4Movie, .quickTimeMovie]
        case .presentation:
            return [.presentation, .pdf]
        case .document:
            return [.pdf, .text, .plainText]
        case .link:
            return []
        case .archive:
            return [.archive, .zip]
        }
    }
}

// Material detail view
struct MaterialDetailView: View {
    let material: CourseMaterial
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Material icon
                Image(systemName: material.type.icon)
                    .font(.system(size: 80))
                    .foregroundColor(materialColor)
                    .frame(width: 120, height: 120)
                    .background(materialColor.opacity(0.1))
                    .cornerRadius(30)
                
                // Material info
                VStack(spacing: 12) {
                    Text(material.title)
                        .font(.title2)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                    
                    Label(material.type.rawValue, systemImage: material.type.icon)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    if let url = material.url {
                        Text(url)
                            .font(.caption)
                            .foregroundColor(.blue)
                            .lineLimit(2)
                            .multilineTextAlignment(.center)
                    }
                    
                    HStack(spacing: 20) {
                        if let size = material.fileSize {
                            VStack {
                                Text("Размер")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text(formatFileSize(size))
                                    .font(.body)
                                    .fontWeight(.medium)
                            }
                        }
                        
                        if let duration = material.duration {
                            VStack {
                                Text("Длительность")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text("\(duration) мин")
                                    .font(.body)
                                    .fontWeight(.medium)
                            }
                        }
                        
                        VStack {
                            Text("Загружено")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(material.uploadedAt.formatted(date: .abbreviated, time: .omitted))
                                .font(.body)
                                .fontWeight(.medium)
                        }
                    }
                }
                .padding()
                
                Spacer()
                
                // Actions
                VStack(spacing: 12) {
                    if material.type != .link {
                        Button(action: {}) {
                            Label("Скачать", systemImage: "arrow.down.circle.fill")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(materialColor)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }
                    }
                    
                    if material.url != nil {
                        Button(action: {}) {
                            Label("Открыть", systemImage: "arrow.up.forward.square")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }
                    }
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Закрыть") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private var materialColor: Color {
        switch material.type {
        case .video: return .blue
        case .presentation: return .orange
        case .document: return .green
        case .link: return .purple
        case .archive: return .gray
        }
    }
    
    private func formatFileSize(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        return formatter.string(fromByteCount: bytes)
    }
}

#Preview {
    CourseMaterialsView(course: .constant(Course.mockCourses[0]))
} 