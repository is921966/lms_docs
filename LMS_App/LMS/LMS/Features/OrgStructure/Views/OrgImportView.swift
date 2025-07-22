import SwiftUI
import UniformTypeIdentifiers

struct OrgImportView: View {
    @StateObject private var service = OrgStructureService.shared
    @State private var importMode: ImportMode = .merge
    @State private var isImporting = false
    @State private var importResult: OrgStructureService.ImportResult?
    @State private var errorMessage = ""
    @State private var showError = false
    @State private var showingFilePicker = false
    @State private var showingActivityView = false
    @State private var templateURL: URL?
    @State private var showSuccess = false
    @State private var successMessage = ""
    @Environment(\.dismiss) private var dismiss
    
    enum ImportMode: String, CaseIterable {
        case merge = "Добавить к существующим"
        case replace = "Заменить все данные"
        
        var icon: String {
            switch self {
            case .merge: return "plus.circle"
            case .replace: return "arrow.clockwise"
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Instructions
                instructionsSection
                
                // Import mode selector
                importModeSection
                
                // Buttons
                HStack(spacing: 20) {
                    Button(action: downloadTemplate) {
                        Label("Скачать шаблон CSV", systemImage: "arrow.down.doc")
                    }
                    .buttonStyle(.borderedProminent)
                    
                    Button(action: { showingFilePicker = true }) {
                        Label("Выбрать файл", systemImage: "doc.badge.plus")
                    }
                    .buttonStyle(.bordered)
                    .disabled(isImporting)
                }
                
                // Result section
                if let result = importResult {
                    resultSection(result)
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Импорт данных")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingFilePicker) {
                DocumentPicker(
                    supportedTypes: [.commaSeparatedText],
                    onPick: handleFilePicked
                )
            }
            .alert("Ошибка", isPresented: $showError) {
                Button("OK") { }
            } message: {
                Text(errorMessage)
            }
            .alert("Успешно", isPresented: $showSuccess) {
                Button("OK") { }
            } message: {
                Text(successMessage)
            }
            .sheet(isPresented: $showingActivityView) {
                if let url = templateURL {
                    ActivityViewController(activityItems: [url])
                        .onAppear {
                            print("📤 ActivityViewController appeared with URL: \(url)")
                        }
                } else {
                    // Запасной вариант - показываем сообщение об ошибке
                    VStack(spacing: 20) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 50))
                            .foregroundColor(.orange)
                        
                        Text("Ошибка экспорта")
                            .font(.headline)
                        
                        Text("Не удалось подготовить файл для экспорта")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        Button("Закрыть") {
                            showingActivityView = false
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding()
                    .onAppear {
                        print("⚠️ ActivityViewController appeared without URL!")
                    }
                }
            }
            .overlay {
                if isImporting {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                    
                    ProgressView("Импортирование...")
                        .padding()
                        .background(.regularMaterial)
                        .cornerRadius(10)
                }
            }
        }
    }
    
    // MARK: - Sections
    
    private var instructionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Инструкция по импорту", systemImage: "info.circle")
                .font(.headline)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("1. Скачайте шаблон CSV файла")
                Text("2. Заполните данные в любой программе (Excel, Numbers, Google Sheets)")
                Text("3. Сохраните как CSV (разделитель - запятая)")
                Text("4. Загрузите заполненный файл")
            }
            .font(.subheadline)
            .foregroundColor(.secondary)
            
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.orange)
                Text("Колонка «Вышестоящий Код» обязательна для построения иерархии")
                    .font(.caption)
                    .foregroundColor(.blue)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(Color.blue.opacity(0.1))
            .cornerRadius(8)
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(12)
    }
    
    private var importModeSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Режим импорта")
                .font(.headline)
            
            ForEach(ImportMode.allCases, id: \.self) { mode in
                HStack {
                    Image(systemName: mode == importMode ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(mode == importMode ? .accentColor : .secondary)
                    
                    Label(mode.rawValue, systemImage: mode.icon)
                        .foregroundColor(.primary)
                    
                    Spacer()
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    importMode = mode
                }
                .padding(.vertical, 4)
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(12)
    }
    
    private func resultSection(_ result: OrgStructureService.ImportResult) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Результат импорта", systemImage: "checkmark.circle.fill")
                .font(.headline)
                .foregroundColor(.green)
            
            VStack(spacing: 8) {
                HStack {
                    Text("Подразделений добавлено:")
                    Spacer()
                    Text("\(result.departmentsAdded)")
                        .fontWeight(.bold)
                }
                
                HStack {
                    Text("Подразделений обновлено:")
                    Spacer()
                    Text("\(result.departmentsUpdated)")
                        .fontWeight(.bold)
                }
                
                HStack {
                    Text("Сотрудников добавлено:")
                    Spacer()
                    Text("\(result.employeesAdded)")
                        .fontWeight(.bold)
                }
                
                HStack {
                    Text("Сотрудников обновлено:")
                    Spacer()
                    Text("\(result.employeesUpdated)")
                        .fontWeight(.bold)
                }
            }
            .font(.subheadline)
            .padding()
            .background(Color.green.opacity(0.1))
            .cornerRadius(12)
            
            if !result.errors.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Label("Ошибки (\(result.errors.count))", systemImage: "exclamationmark.triangle")
                        .font(.headline)
                        .foregroundColor(.red)
                    
                    ForEach(Array(result.errors.prefix(5).enumerated()), id: \.offset) { _, error in
                        Text("• \(error)")
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                    
                    if result.errors.count > 5 {
                        Text("... и еще \(result.errors.count - 5)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
                .background(Color.red.opacity(0.1))
                .cornerRadius(12)
            }
        }
    }
    
    // MARK: - Actions
    
    private func handleFilePicked(_ url: URL) {
        Task {
            await performImport(from: url)
        }
    }
    
    @MainActor
    private func performImport(from url: URL) async {
        isImporting = true
        defer { isImporting = false }
        
        do {
            // Start accessing the security-scoped resource
            let gotAccess = url.startAccessingSecurityScopedResource()
            defer {
                if gotAccess {
                    url.stopAccessingSecurityScopedResource()
                }
            }
            
            // Parse CSV file
            let parser = CSVParser()
            let parsedData = try parser.parseFile(at: url)
            
            // Import data
            let result = try await service.importFromCSV(
                departments: parsedData.departments.map { dept in
                    OrgStructureService.DepartmentImport(
                        code: dept.code,
                        parentCode: dept.parentCode,
                        name: dept.name
                    )
                },
                employees: parsedData.employees.map { emp in
                    OrgStructureService.EmployeeImport(
                        tabNumber: emp.tabNumber,
                        name: emp.name,
                        position: emp.position,
                        departmentCode: emp.departmentCode,
                        email: emp.email,
                        phone: emp.phone
                    )
                },
                mode: importMode == .replace ? .replace : .merge
            )
            
            importResult = result
            
            // Auto-dismiss if successful and no errors
            if result.errors.isEmpty {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    dismiss()
                }
            }
        } catch let error as CSVParser.ParsingError {
            errorMessage = error.localizedDescription
            showError = true
        } catch {
            errorMessage = "Ошибка импорта: \(error.localizedDescription)"
            showError = true
        }
    }
    
    private func downloadTemplate() {
        print("📥 downloadTemplate() called")
        print("📱 Running on: \(UIDevice.current.name)")
        
        // Создаем лог-файл для диагностики
        let logMessage = "📥 downloadTemplate() called at \(Date())\n"
        writeLog(logMessage)
        
        do {
            #if targetEnvironment(simulator)
            print("📱 Simulator path selected")
            writeLog("📱 Simulator path selected\n")
            
            // На симуляторе сохраняем в Documents и показываем полный путь
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            
            // Создаем уникальное имя файла с временной меткой
            let timestamp = DateFormatter.localizedString(from: Date(), dateStyle: .short, timeStyle: .medium)
                .replacingOccurrences(of: "/", with: "-")
                .replacingOccurrences(of: ":", with: "-")
                .replacingOccurrences(of: " ", with: "_")
            
            let destinationURL = documentsURL.appendingPathComponent("org_structure_template_\(timestamp).csv")
            print("📄 Destination URL: \(destinationURL.path)")
            writeLog("📄 Destination URL: \(destinationURL.path)\n")
            
            let parser = CSVParser()
            print("🔨 Parser created, calling createTemplateFileAt...")
            writeLog("🔨 Parser created, calling createTemplateFileAt...\n")
            try parser.createTemplateFileAt(url: destinationURL)
            
            print("✅ Template created successfully!")
            writeLog("✅ Template created successfully!\n")
            
            // Проверяем, что файл действительно создан
            if FileManager.default.fileExists(atPath: destinationURL.path) {
                print("✅ File exists at path!")
                let attributes = try? FileManager.default.attributesOfItem(atPath: destinationURL.path)
                if let size = attributes?[.size] as? Int64 {
                    print("📊 File size: \(size) bytes")
                }
                
                // Копируем путь в буфер обмена для удобства
                UIPasteboard.general.string = destinationURL.path
            }
            
            // Получаем путь к контейнеру приложения для более понятных инструкций
            let appPath = documentsURL.deletingLastPathComponent().path
            
            successMessage = """
            ✅ Шаблон CSV сохранен!
            
            📄 Файл: org_structure_template_\(timestamp).csv
            
            📋 Путь скопирован в буфер обмена!
            
            🔍 Как найти файл:
            1. Откройте Finder
            2. Нажмите Cmd+Shift+G
            3. Вставьте путь из буфера обмена
            
            💡 Альтернативный способ:
            Xcode → Window → Devices → iPhone 16 → LMS → Show Container → Files → Documents
            """
            
            writeLog("Setting showSuccess = true\n")
            // Добавляем небольшую задержку для корректного показа алерта
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                showSuccess = true
            }
            #else
            print("📱 Device path selected")
            writeLog("📱 Device path selected\n")
            
            // На реальном устройстве используем стандартный Share Sheet
            if let templateData = service.createTemplate() {
                print("📊 Template data created: \(templateData.count) bytes")
                writeLog("📊 Template data created: \(templateData.count) bytes\n")
                
                // Создаем временный файл для Share Sheet
                let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("org_structure_template.csv")
                try templateData.write(to: tempURL)
                
                print("✅ Temp file created at: \(tempURL.path)")
                writeLog("✅ Temp file created at: \(tempURL.path)\n")
                
                // Проверяем файл
                if FileManager.default.fileExists(atPath: tempURL.path) {
                    print("✅ File exists!")
                    let attributes = try? FileManager.default.attributesOfItem(atPath: tempURL.path)
                    if let size = attributes?[.size] as? Int64 {
                        print("📊 File size: \(size) bytes")
                    }
                }
                
                self.templateURL = tempURL
                
                // Показываем share sheet с задержкой
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    print("🎯 Showing activity view...")
                    self.showingActivityView = true
                }
            } else {
                print("❌ Failed to create template data")
                writeLog("❌ Failed to create template data\n")
                errorMessage = "Не удалось создать шаблон"
                showError = true
            }
            #endif
            
        } catch {
            print("❌ Error: \(error)")
            writeLog("❌ Error: \(error)\n")
            errorMessage = "Ошибка создания шаблона: \(error.localizedDescription)"
            showError = true
        }
    }
    
    private func writeLog(_ message: String) {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let logFileURL = documentsURL.appendingPathComponent("org_import_log.txt")
        
        do {
            if FileManager.default.fileExists(atPath: logFileURL.path) {
                let fileHandle = try FileHandle(forWritingTo: logFileURL)
                fileHandle.seekToEndOfFile()
                if let data = message.data(using: .utf8) {
                    fileHandle.write(data)
                }
                fileHandle.closeFile()
            } else {
                try message.write(to: logFileURL, atomically: true, encoding: .utf8)
            }
        } catch {
            print("Failed to write log: \(error)")
        }
    }
}

// MARK: - Document Picker

struct DocumentPicker: UIViewControllerRepresentable {
    let supportedTypes: [UTType]
    let onPick: (URL) -> Void
    
    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: supportedTypes)
        picker.delegate = context.coordinator
        picker.allowsMultipleSelection = false
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIDocumentPickerDelegate {
        let parent: DocumentPicker
        
        init(_ parent: DocumentPicker) {
            self.parent = parent
        }
        
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            guard let url = urls.first else { return }
            parent.onPick(url)
        }
    }
}

// MARK: - UTType Extension

extension UTType {
    static let csv = UTType(filenameExtension: "csv") ?? .commaSeparatedText
}

// MARK: - Activity View Controller

struct ActivityViewController: UIViewControllerRepresentable {
    let activityItems: [Any]
    let applicationActivities: [UIActivity]? = nil
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: applicationActivities
        )
        
        controller.excludedActivityTypes = [
            .assignToContact,
            .addToReadingList,
            .postToFacebook,
            .postToTwitter,
            .postToWeibo,
            .postToVimeo,
            .postToTencentWeibo
        ]
        
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
        // Для iPad настраиваем popover
        if let popover = uiViewController.popoverPresentationController {
            // Получаем главное окно
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first {
                popover.sourceView = window
                popover.sourceRect = CGRect(x: window.bounds.midX, y: window.bounds.midY, width: 0, height: 0)
                popover.permittedArrowDirections = []
            }
        }
    }
}

// MARK: - Preview

struct OrgImportView_Previews: PreviewProvider {
    static var previews: some View {
        OrgImportView()
    }
} 