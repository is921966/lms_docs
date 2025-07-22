//
//  Cmi5ImportView.swift
//  LMS
//
//  Created on 28/06/2025.
//

import SwiftUI

struct Cmi5ImportView: View {
    @StateObject private var viewModel = Cmi5ImportViewModel()
    @Environment(\.dismiss) private var dismiss
    @State private var showingFileImporter = false
    @State private var showingImportSuccess = false
    @State private var showingDemoSelector = false
    @State private var selectedDemoCourse: DemoCourse?
    
    let courseId: UUID?
    let onImportComplete: ((Cmi5Package) -> Void)?
    
    // MARK: - Body
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 30) {
                    headerSection
                    actionButtonsSection
                    contentSection
                    errorSection
                }
                .padding(.bottom, 20)
            }
            .navigationTitle("Импорт Cmi5")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Закрыть") {
                        dismiss()
                    }
                }
            }
            .fileImporter(
                isPresented: $showingFileImporter,
                allowedContentTypes: [.zip, .archive],
                allowsMultipleSelection: false
            ) { result in
                handleFileSelection(result)
            }
            .sheet(isPresented: $showingDemoSelector) {
                DemoCourseSelectorView(selectedCourse: $selectedDemoCourse)
            }
            .alert("Импорт завершен", isPresented: $showingImportSuccess) {
                Button("ОК", role: .cancel) {
                    print("🎯 Cmi5ImportView: Alert OK button pressed")
                    if let package = viewModel.importedPackage {
                        print("🎯 Cmi5ImportView: Calling onImportComplete with package: \(package.title)")
                        onImportComplete?(package)
                        dismiss()
                    }
                }
            } message: {
                Text("Курс успешно импортирован.")
            }
        }
        .onChange(of: selectedDemoCourse) { newCourse in
            if let course = newCourse {
                viewModel.loadDemoCourse(course)
            }
        }
        .onAppear {
            viewModel.courseId = courseId
        }
    }
    
    // MARK: - View Sections
    
    private var headerSection: some View {
        VStack(spacing: 10) {
            Image(systemName: "square.and.arrow.down.on.square")
                .font(.system(size: 60))
                .foregroundColor(.accentColor)
            
            Text("Импорт Cmi5 курсов")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Загрузите Cmi5 пакет (.zip) для добавления в систему")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding(.top, 20)
    }
    
    private var actionButtonsSection: some View {
        VStack(spacing: 15) {
            Button(action: {
                showingFileImporter = true
            }) {
                HStack {
                    Image(systemName: "folder")
                    Text("Выбрать файл")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.accentColor)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            
            Button(action: {
                showingDemoSelector = true
            }) {
                HStack {
                    Image(systemName: "play.circle")
                    Text("Демо курсы")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.orange)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
        }
        .padding(.horizontal)
    }
    
    @ViewBuilder
    private var contentSection: some View {
        if viewModel.isProcessing {
            ProgressView(viewModel.processingProgress ?? "Обработка...")
                .padding()
        }
        
        if let fileInfo = viewModel.selectedFileInfo {
            FileInfoView(fileInfo: fileInfo)
                .padding(.horizontal)
        }
        
        if let package = viewModel.parsedPackage {
            ParsedPackageView(package: package)
                .padding(.horizontal)
        }
        
        if viewModel.parsedPackage != nil {
            Button(action: {
                print("🎯 Cmi5ImportView: Import button pressed")
                Task {
                    await viewModel.importPackage()
                    print("🎯 Cmi5ImportView: Import completed, importedPackage: \(viewModel.importedPackage?.title ?? "nil")")
                    if viewModel.importedPackage != nil {
                        print("🎯 Cmi5ImportView: Showing success alert")
                        showingImportSuccess = true
                    }
                }
            }) {
                HStack {
                    Image(systemName: "square.and.arrow.down")
                    Text("Импортировать курс")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .padding(.horizontal)
            .disabled(viewModel.isProcessing)
        }
    }
    
    @ViewBuilder
    private var errorSection: some View {
        if let error = viewModel.error {
            ErrorSection(error: error)
                .padding(.horizontal)
        }
        
        if !viewModel.validationWarnings.isEmpty {
            WarningsSection(warnings: viewModel.validationWarnings)
                .padding(.horizontal)
        }
    }
    
    // MARK: - Private Methods
    
    private func handleFileSelection(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            if let url = urls.first {
                Task {
                    await viewModel.processFile(url)
                }
            }
        case .failure(let error):
            viewModel.error = "Ошибка выбора файла: \(error.localizedDescription)"
        }
    }
}

// MARK: - Preview
struct Cmi5ImportView_Previews: PreviewProvider {
    static var previews: some View {
        Cmi5ImportView(courseId: nil) { _ in }
    }
}

// MARK: - Supporting Views

struct FileInfoView: View {
    let fileInfo: FileInfo
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "doc.zipper")
                    .foregroundColor(.accentColor)
                
                VStack(alignment: .leading) {
                    Text(fileInfo.name)
                        .font(.headline)
                    Text("Размер: \(ByteCountFormatter.string(fromByteCount: Int64(fileInfo.size), countStyle: .file))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
            }
            .padding()
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(10)
        }
    }
}

struct ParsedPackageView: View {
    let package: Cmi5Package
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Информация о курсе")
                .font(.headline)
            
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text("Название:")
                        .foregroundColor(.secondary)
                    Text(package.manifest.title)
                        .fontWeight(.medium)
                }
                
                if let description = package.manifest.description {
                    HStack(alignment: .top) {
                        Text("Описание:")
                            .foregroundColor(.secondary)
                        Text(description)
                    }
                }
                
                HStack {
                    Text("Версия:")
                        .foregroundColor(.secondary)
                    Text(package.manifest.version ?? "1.0")
                }
                
                if !package.activities.isEmpty {
                    HStack {
                        Text("Активности:")
                            .foregroundColor(.secondary)
                        Text("\(package.activities.count)")
                            .fontWeight(.medium)
                    }
                }
            }
            .padding()
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(10)
        }
    }
}

struct ErrorSection: View {
    let error: String
    
    var body: some View {
        HStack {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.red)
            
            Text(error)
                .font(.footnote)
                .foregroundColor(.red)
            
            Spacer()
        }
        .padding()
        .background(Color.red.opacity(0.1))
        .cornerRadius(10)
    }
}

struct WarningsSection: View {
    let warnings: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "exclamationmark.triangle")
                    .foregroundColor(.orange)
                Text("Предупреждения валидации")
                    .font(.headline)
            }
            
            ForEach(warnings, id: \.self) { warning in
                Text("• \(warning)")
                    .font(.footnote)
                    .foregroundColor(.orange)
            }
        }
        .padding()
        .background(Color.orange.opacity(0.1))
        .cornerRadius(10)
    }
} 