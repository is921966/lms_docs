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
    @State private var showingDocumentPicker = false
    
    let courseId: UUID?
    var onImportComplete: ((Cmi5Package) -> Void)?
    
    // MARK: - Body
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Инструкции
                    instructionsSection
                    
                    // Кнопка выбора файла
                    fileSelectionSection
                    
                    // Информация о загруженном файле
                    if let fileInfo = viewModel.selectedFileInfo {
                        fileInfoSection(fileInfo)
                    }
                    
                    // Прогресс парсинга
                    if viewModel.isProcessing {
                        processingSection()
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
                        warningsSection()
                    }
                }
                .padding()
            }
            .navigationTitle("Импорт Cmi5 пакета")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                toolbarContent
            }
            .fileImporter(
                isPresented: $showingDocumentPicker,
                allowedContentTypes: [.zip, .archive],
                allowsMultipleSelection: false
            ) { result in
                handleFileSelection(result)
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
    
    private var fileSelectionSection: some View {
        VStack(spacing: 16) {
            Button(action: {
                showingDocumentPicker = true
            }) {
                VStack(spacing: 12) {
                    Image(systemName: "folder.badge.plus")
                        .font(.system(size: 48))
                        .foregroundColor(.white)
                    
                    Text("Выбрать файл")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text("Нажмите для выбора ZIP архива")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                }
                .frame(maxWidth: .infinity)
                .frame(height: 150)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.blue, Color.blue.opacity(0.8)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .cornerRadius(12)
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
    
    private func fileInfoSection(_ fileInfo: FileInfo) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "doc.zipper.fill")
                    .font(.title2)
                    .foregroundColor(.blue)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(fileInfo.name)
                        .font(.headline)
                        .lineLimit(1)
                    
                    HStack {
                        Text(fileInfo.formattedSize)
                        Text("•")
                        Text(fileInfo.type)
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button(action: {
                    viewModel.clearSelection()
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
            }
            
            if viewModel.parsedPackage == nil && viewModel.error == nil && !viewModel.isProcessing {
                Button(action: {
                    Task {
                        await viewModel.processSelectedFile()
                    }
                }) {
                    Label("Проверить пакет", systemImage: "checkmark.shield")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private func processingSection() -> some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)
            
            Text(viewModel.processingProgress ?? "Обработка файла...")
                .font(.headline)
            
            Text("Это может занять несколько секунд")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(32)
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
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.red)
                
                Text("Ошибка")
                    .font(.headline)
                    .foregroundColor(.red)
            }
            
            Text(error)
                .font(.callout)
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
            
            Button(action: {
                viewModel.clearError()
            }) {
                Text("Попробовать снова")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .tint(.red)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private func warningsSection() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "exclamationmark.triangle")
                    .foregroundColor(.orange)
                
                Text("Предупреждения")
                    .font(.headline)
                    .foregroundColor(.orange)
            }
            
            ForEach(viewModel.validationWarnings, id: \.self) { warning in
                HStack(alignment: .top) {
                    Text("•")
                    Text(warning)
                        .font(.caption)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
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
    
    private func handleFileSelection(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            if let url = urls.first {
                Task {
                    await viewModel.processFile(at: url)
                }
            }
        case .failure(let error):
            viewModel.error = "Ошибка выбора файла: \(error.localizedDescription)"
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