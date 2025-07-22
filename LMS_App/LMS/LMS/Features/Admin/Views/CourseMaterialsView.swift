//
//  CourseMaterialsView.swift
//  LMS
//
//  Created on 26/01/2025.
//

import PhotosUI
import SwiftUI

struct CourseMaterialsView: View {
    @Binding var course: Course
    @State private var materials: [CourseMaterial] = []
    @State private var showingAddMaterial = false
    @State private var selectedMaterial: CourseMaterial?
    @State private var showingDeleteAlert = false
    @State private var materialToDelete: CourseMaterial?

    var body: some View {
        NavigationView {
            List {
                materialsSection
                addMaterialSection
            }
            .navigationTitle("Материалы курса")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Готово") {
                        // Dismiss view
                    }
                }
            }
        }
        .sheet(isPresented: $showingAddMaterial) {
            AddMaterialView { newMaterial in
                materials.append(newMaterial)
            }
        }
        .sheet(item: $selectedMaterial) { material in
            MaterialDetailView(material: material)
        }
        .alert("Удалить материал?", isPresented: $showingDeleteAlert) {
            Button("Отмена", role: .cancel) { }
            Button("Удалить", role: .destructive) {
                if let material = materialToDelete {
                    materials.removeAll { $0.id == material.id }
                }
            }
        } message: {
            if let material = materialToDelete {
                Text("Вы действительно хотите удалить \(material.title)?")
            }
        }
    }
    
    private var materialsSection: some View {
        Section("Материалы курса") {
            if materials.isEmpty {
                Text("Материалы не добавлены")
                    .foregroundColor(.secondary)
                    .italic()
            } else {
                ForEach(materials) { material in
                    MaterialRow(material: material) {
                        selectedMaterial = material
                    }
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            materialToDelete = material
                            showingDeleteAlert = true
                        } label: {
                            Label("Удалить", systemImage: "trash")
                        }
                    }
                }
            }
        }
    }
    
    private var addMaterialSection: some View {
        Section {
            Button(action: { showingAddMaterial = true }) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(.blue)
                    Text("Добавить материал")
                }
            }
        }
    }
}

// Material row component
struct MaterialRow: View {
    let material: CourseMaterial
    let onTap: () -> Void

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

                    // TODO: Add file size when available

                    // TODO: Add duration when available
                    if false {
                        Text("• -- мин")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }

            Spacer()

            Button(action: {}) {
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
        case .pdf: return .red
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
    @State private var description = ""
    @State private var selectedType = CourseMaterial.MaterialType.document
    @State private var showingFilePicker = false
    @State private var url = ""

    let onAdd: (CourseMaterial) -> Void

    var body: some View {
        NavigationView {
            Form {
                basicInfoSection
                materialTypeSection
                actionSection
            }
            .navigationTitle("Добавить материал")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Добавить") {
                        addMaterial()
                    }
                    .disabled(title.isEmpty)
                }
            }
        }
        .fileImporter(
            isPresented: $showingFilePicker,
            allowedContentTypes: contentTypesForMaterialType(selectedType),
            allowsMultipleSelection: false
        ) { result in
            handleFileImport(result)
        }
    }
    
    private var basicInfoSection: some View {
        Section("Основная информация") {
            TextField("Название", text: $title)
            TextField("Описание (необязательно)", text: $description)
        }
    }
    
    private var materialTypeSection: some View {
        Section("Тип материала") {
            Picker("Тип", selection: $selectedType) {
                ForEach(CourseMaterial.MaterialType.allCases, id: \.self) { type in
                    Label(type.rawValue, systemImage: iconForMaterialType(type))
                        .tag(type)
                }
            }
        }
    }
    
    private var actionSection: some View {
        Section {
            if selectedType == .link {
                TextField("URL адрес", text: $url)
                    .keyboardType(.URL)
                    .autocapitalization(.none)
            } else {
                Button(action: { showingFilePicker = true }) {
                    HStack {
                        Image(systemName: "doc.badge.plus")
                        Text("Выбрать файл")
                    }
                }
            }
        }
    }

    private func addMaterial() {
        let newMaterial = CourseMaterial(
            id: UUID().uuidString,
            title: title,
            type: selectedType,
            url: url.isEmpty ? nil : url,
            description: description.isEmpty ? nil : description,
            size: nil,
            uploadedAt: Date()
        )
        onAdd(newMaterial)
        dismiss()
    }

    private func handleFileImport(_ result: Result<[URL], Error>) {
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

    private func iconForMaterialType(_ type: CourseMaterial.MaterialType) -> String {
        switch type {
        case .video: return "video.slash"
        case .presentation: return "doc.text.image"
        case .document: return "doc.text"
        case .link: return "link"
        case .pdf: return "doc.text.magnifyingglass"
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
        case .pdf:
            return [.pdf]
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
                        // TODO: Add file size when available
                        if false {
                            VStack {
                                Text("Размер")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text("--")
                                    .font(.body)
                                    .fontWeight(.medium)
                            }
                        }

                        // TODO: Add duration when available
                        if false {
                            VStack {
                                Text("Длительность")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text("-- мин")
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
        case .pdf: return .red
        }
    }

    private func formatFileSize(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        return formatter.string(fromByteCount: bytes)
    }
}

#Preview {
    NavigationView {
        CourseMaterialsView(course: .constant(Course.mockCourses[0]))
    }
}
