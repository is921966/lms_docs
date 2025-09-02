import SwiftUI
import UniformTypeIdentifiers

struct ScormManagementView: View {
    @StateObject private var viewModel = ScormViewModel()
    @State private var showingFilePicker = false
    @State private var showingAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var selectedScormPackage: ScormPackage?
    @State private var showingPackageDetail = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header
                headerSection
                
                // Import Button
                importSection
                
                // SCORM Packages List
                if !viewModel.packages.isEmpty {
                    packagesSection
                } else {
                    emptyStateView
                }
            }
            .padding()
        }
        .navigationTitle("SCORM Контент")
        .navigationBarTitleDisplayMode(.large)
        .fileImporter(
            isPresented: $showingFilePicker,
            allowedContentTypes: [UTType(filenameExtension: "zip")!],
            allowsMultipleSelection: false
        ) { result in
            handleFileImport(result)
        }
        .alert(alertTitle, isPresented: $showingAlert) {
            Button("OK") { }
        } message: {
            Text(alertMessage)
        }
        .sheet(item: $selectedScormPackage) { package in
            NavigationStack {
                ScormPackageDetailView(package: package)
            }
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "doc.badge.gearshape")
                    .font(.largeTitle)
                    .foregroundColor(.indigo)
                
                VStack(alignment: .leading) {
                    Text("Импорт SCORM курсов")
                        .font(.headline)
                    Text("Последняя версия SCORM 2004")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            
            Text("Загружайте курсы в формате SCORM 2004 (4th Edition) для использования в системе обучения")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color.indigo.opacity(0.1))
        .cornerRadius(12)
    }
    
    // MARK: - Import Section
    private var importSection: some View {
        Button(action: {
            showingFilePicker = true
        }) {
            HStack {
                Image(systemName: "square.and.arrow.down")
                    .font(.title2)
                
                VStack(alignment: .leading) {
                    Text("Импортировать SCORM пакет")
                        .font(.headline)
                    Text("Выберите ZIP файл с курсом")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(12)
        }
    }
    
    // MARK: - Packages Section
    private var packagesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Загруженные SCORM пакеты")
                .font(.headline)
                .padding(.horizontal)
            
            ForEach(viewModel.packages) { package in
                ScormPackageRow(package: package) {
                    selectedScormPackage = package
                }
            }
        }
    }
    
    // MARK: - Empty State
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "doc.zipper")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text("Нет загруженных SCORM пакетов")
                .font(.title3)
                .fontWeight(.medium)
            
            Text("Нажмите кнопку выше, чтобы импортировать ваш первый SCORM курс")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding(.vertical, 40)
    }
    
    // MARK: - File Import Handler
    private func handleFileImport(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            guard let url = urls.first else { return }
            
            viewModel.importScormPackage(from: url) { success, message in
                alertTitle = success ? "Успешно" : "Ошибка"
                alertMessage = message
                showingAlert = true
            }
            
        case .failure(let error):
            alertTitle = "Ошибка"
            alertMessage = "Не удалось выбрать файл: \(error.localizedDescription)"
            showingAlert = true
        }
    }
}

// MARK: - SCORM Package Row
struct ScormPackageRow: View {
    let package: ScormPackage
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: "doc.fill")
                    .font(.title2)
                    .foregroundColor(.indigo)
                    .frame(width: 50)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(package.title)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    HStack {
                        Label("\(package.version)", systemImage: "number")
                        Spacer()
                        Label(package.formattedSize, systemImage: "doc")
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Image(systemName: "chevron.right")
                        .foregroundColor(.secondary)
                    
                    Text(package.formattedDate)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
            .padding(.horizontal)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - SCORM Package Detail View
struct ScormPackageDetailView: View {
    let package: ScormPackage
    @Environment(\.dismiss) private var dismiss
    @State private var showingCourseCreation = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Package Info
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "doc.fill")
                            .font(.largeTitle)
                            .foregroundColor(.indigo)
                        
                        VStack(alignment: .leading) {
                            Text(package.title)
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Text("SCORM \(package.version)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                    }
                    
                    if let description = package.description {
                        Text(description)
                            .font(.body)
                            .foregroundColor(.secondary)
                            .padding(.top, 8)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                
                // Metadata
                VStack(alignment: .leading, spacing: 16) {
                    Text("Информация о пакете")
                        .font(.headline)
                    
                    MetadataRow(label: "Версия SCORM", value: package.version)
                    MetadataRow(label: "Размер", value: package.formattedSize)
                    MetadataRow(label: "Дата загрузки", value: package.formattedDate)
                    MetadataRow(label: "Организация", value: package.organization ?? "Не указана")
                    MetadataRow(label: "Количество SCO", value: "\(package.scoCount)")
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                
                // Actions
                VStack(spacing: 12) {
                    Button(action: {
                        showingCourseCreation = true
                    }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("Создать курс из SCORM пакета")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    
                    Button(action: {
                        // Preview action
                    }) {
                        HStack {
                            Image(systemName: "play.circle")
                            Text("Предпросмотр")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(.systemGray5))
                        .foregroundColor(.primary)
                        .cornerRadius(12)
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Детали пакета")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Закрыть") {
                    dismiss()
                }
            }
        }
        .sheet(isPresented: $showingCourseCreation) {
            NavigationStack {
                CreateCourseFromScormView(package: package)
            }
        }
    }
}

// MARK: - Metadata Row
struct MetadataRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.medium)
        }
    }
}

// MARK: - Create Course From SCORM View
struct CreateCourseFromScormView: View {
    let package: ScormPackage
    @Environment(\.dismiss) private var dismiss
    @State private var courseName = ""
    @State private var courseDescription = ""
    @State private var selectedCategory = "general"
    
    var body: some View {
        Form {
            Section("Информация о курсе") {
                TextField("Название курса", text: $courseName)
                
                TextField("Описание", text: $courseDescription, axis: .vertical)
                    .lineLimit(3...6)
                
                Picker("Категория", selection: $selectedCategory) {
                    Text("Общие").tag("general")
                    Text("Технические").tag("technical")
                    Text("Продажи").tag("sales")
                    Text("Менеджмент").tag("management")
                }
            }
            
            Section("Источник") {
                HStack {
                    Image(systemName: "doc.fill")
                        .foregroundColor(.indigo)
                    VStack(alignment: .leading) {
                        Text(package.title)
                            .font(.headline)
                        Text("SCORM \(package.version)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .navigationTitle("Создание курса")
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
                .disabled(courseName.isEmpty)
            }
        }
        .onAppear {
            courseName = package.title
            courseDescription = package.description ?? ""
        }
    }
    
    private func createCourse() {
        // TODO: Implement course creation logic
        dismiss()
    }
}

#Preview {
    NavigationStack {
        ScormManagementView()
    }
} 