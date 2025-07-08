//
//  Cmi5ImportView.swift
//  LMS
//
//  Created on Sprint 40 Day 1 - Cmi5 Integration
//

import SwiftUI
import UniformTypeIdentifiers

/// View для импорта Cmi5 пакетов
struct Cmi5ImportView: View {
    @StateObject private var viewModel = Cmi5ImportViewModel()
    @Environment(\.dismiss) private var dismiss
    
    let courseId: UUID?
    var onImportComplete: ((Cmi5Package) -> Void)?
    
    // MARK: - Body
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Инструкции
                    instructionsSection
                    
                    // Зона загрузки файла
                    uploadSection
                    
                    // Информация о загруженном файле
                    if let fileInfo = viewModel.selectedFileInfo {
                        fileInfoSection(fileInfo)
                    }
                    
                    // Прогресс парсинга
                    if viewModel.isProcessing {
                        processingSection
                    }
                    
                    // Результат парсинга
                    if let package = viewModel.parsedPackage {
                        packageInfoSection(package)
                    }
                    
                    // Ошибки
                    if let error = viewModel.error {
                        errorSection(error)
                    }
                    
                    // Предупреждения валидации
                    if !viewModel.validationWarnings.isEmpty {
                        warningsSection
                    }
                }
                .padding()
            }
            .navigationTitle("Импорт Cmi5 пакета")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                toolbarContent
            }
        }
        .onAppear {
            viewModel.courseId = courseId
        }
    }
    
    // MARK: - Sections
    
    private var instructionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Инструкции", systemImage: "info.circle.fill")
                .font(.headline)
                .foregroundColor(.blue)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("• Выберите ZIP архив с Cmi5 пакетом")
                Text("• Файл должен содержать манифест cmi5.xml")
                Text("• Поддерживаются пакеты версии 1.0")
                Text("• Максимальный размер файла: 500 МБ")
            }
            .font(.footnote)
            .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private var uploadSection: some View {
        VStack(spacing: 16) {
            // Drag & Drop зона
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [8]))
                    .foregroundColor(.accentColor)
                    .frame(height: 150)
                
                VStack(spacing: 12) {
                    Image(systemName: "square.and.arrow.up.circle.fill")
                        .font(.system(size: 48))
                        .foregroundColor(.accentColor)
                    
                    Text("Перетащите файл сюда")
                        .font(.headline)
                    
                    Text("или")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Button(action: selectFile) {
                        Label("Выбрать файл", systemImage: "folder")
                            .font(.callout)
                    }
                    .buttonStyle(.bordered)
                }
            }
            .onDrop(of: [.fileURL], isTargeted: nil) { providers in
                handleDrop(providers: providers)
                return true
            }
        }
    }
    
    private func fileInfoSection(_ info: FileInfo) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Информация о файле", systemImage: "doc.fill")
                .font(.headline)
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Название:")
                        .foregroundColor(.secondary)
                    Text(info.name)
                        .fontWeight(.medium)
                }
                
                HStack {
                    Text("Размер:")
                        .foregroundColor(.secondary)
                    Text(info.formattedSize)
                        .fontWeight(.medium)
                }
                
                HStack {
                    Text("Тип:")
                        .foregroundColor(.secondary)
                    Text(info.type)
                        .fontWeight(.medium)
                }
            }
            .font(.callout)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private var processingSection: some View {
        VStack(spacing: 16) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle())
                .scaleEffect(1.5)
            
            Text("Обработка пакета...")
                .font(.headline)
            
            if let progress = viewModel.processingProgress {
                Text(progress)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private func packageInfoSection(_ package: Cmi5Package) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                    .font(.title2)
                
                Text("Пакет успешно обработан")
                    .font(.headline)
                    .foregroundColor(.green)
            }
            
            Divider()
            
            // Информация о пакете
            VStack(alignment: .leading, spacing: 12) {
                Cmi5DetailRow(label: "Название", value: package.title)
                
                Cmi5DetailRow(label: "Версия", value: package.version)
                
                if let description = package.description {
                    Cmi5DetailRow(label: "Описание", value: description)
                }
                
                let activityCount = countActivities(in: package)
                Cmi5DetailRow(label: "Количество активностей", value: "\(activityCount)")
                
                if let courseTitle = package.manifest.course?.title?.first?.value {
                    Cmi5DetailRow(label: "Курс", value: courseTitle)
                }
            }
            
            // Список активностей
            let activities = collectActivities(from: package)
            if !activities.isEmpty {
                Divider()
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Активности:")
                        .font(.headline)
                    
                    ForEach(activities) { activity in
                        ActivityRow(activity: activity)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private func errorSection(_ error: String) -> some View {
        HStack {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.red)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Ошибка")
                    .font(.headline)
                    .foregroundColor(.red)
                
                Text(error)
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
        }
        .padding()
        .background(Color(.systemRed).opacity(0.1))
        .cornerRadius(12)
    }
    
    private var warningsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.orange)
                
                Text("Предупреждения")
                    .font(.headline)
                    .foregroundColor(.orange)
            }
            
            ForEach(viewModel.validationWarnings, id: \.self) { warning in
                Text("• \(warning)")
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemOrange).opacity(0.1))
        .cornerRadius(12)
    }
    
    // MARK: - Toolbar
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            Button("Отмена") {
                dismiss()
            }
        }
        
        ToolbarItem(placement: .navigationBarTrailing) {
            Button("Импортировать") {
                Task {
                    await importPackage()
                }
            }
            .disabled(!viewModel.canImport)
        }
    }
    
    // MARK: - Actions
    
    private func selectFile() {
        // В реальном приложении здесь будет документ пикер
        // Для демонстрации используем заглушку
        viewModel.selectDemoFile()
    }
    
    private func handleDrop(providers: [NSItemProvider]) {
        guard let provider = providers.first else { return }
        
        provider.loadItem(forTypeIdentifier: UTType.fileURL.identifier, options: nil) { item, error in
            guard let url = item as? URL else { return }
            
            DispatchQueue.main.async {
                viewModel.processFile(at: url)
            }
        }
    }
    
    private func importPackage() async {
        await viewModel.importPackage()
        
        if let package = viewModel.importedPackage {
            onImportComplete?(package)
            dismiss()
        }
    }
    
    // MARK: - Helper Methods
    
    private func countActivities(in package: Cmi5Package) -> Int {
        guard let rootBlock = package.manifest.rootBlock else { return 0 }
        
        var count = 0
        
        func countInBlock(_ block: Cmi5Block) {
            count += block.activities.count
            for subBlock in block.blocks {
                countInBlock(subBlock)
            }
        }
        
        countInBlock(rootBlock)
        return count
    }
    
    private func collectActivities(from package: Cmi5Package) -> [Cmi5Activity] {
        guard let rootBlock = package.manifest.rootBlock else { return [] }
        
        var activities: [Cmi5Activity] = []
        
        func collectFromBlock(_ block: Cmi5Block) {
            activities.append(contentsOf: block.activities)
            for subBlock in block.blocks {
                collectFromBlock(subBlock)
            }
        }
        
        collectFromBlock(rootBlock)
        return activities
    }
}

// MARK: - Supporting Views

private struct Cmi5DetailRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label + ":")
                .foregroundColor(.secondary)
            Text(value)
                .fontWeight(.medium)
        }
        .font(.callout)
    }
}

private struct ActivityRow: View {
    let activity: Cmi5Activity
    
    var body: some View {
        HStack {
            Image(systemName: iconForActivityType(activity.activityType))
                .foregroundColor(.accentColor)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(activity.title)
                    .font(.footnote)
                    .fontWeight(.medium)
                
                if let description = activity.description {
                    Text(description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }
            
            Spacer()
            
            if let score = activity.masteryScore {
                Text("\(Int(score * 100))%")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
    
    private func iconForActivityType(_ type: String) -> String {
        if type.contains("assessment") || type.contains("quiz") {
            return "checkmark.square"
        } else if type.contains("video") {
            return "play.rectangle"
        } else if type.contains("document") {
            return "doc.text"
        } else {
            return "book"
        }
    }
}

// MARK: - Preview

struct Cmi5ImportView_Previews: PreviewProvider {
    static var previews: some View {
        Cmi5ImportView(courseId: nil)
    }
} 