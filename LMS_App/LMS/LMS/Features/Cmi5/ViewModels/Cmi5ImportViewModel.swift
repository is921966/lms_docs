//
//  Cmi5ImportViewModel.swift
//  LMS
//
//  Created on Sprint 40 Day 1 - Cmi5 Integration
//

import Foundation
import SwiftUI
import Combine

/// Ошибки валидации
enum ValidationError: LocalizedError {
    case fileAccessDenied
    case fileTooLarge(size: Int64, maxSize: Int64)
    case invalidFormat
    case missingManifest
    
    var errorDescription: String? {
        switch self {
        case .fileAccessDenied:
            return "Нет доступа к файлу. Пожалуйста, выберите файл заново."
        case .fileTooLarge(let size, let maxSize):
            let formatter = ByteCountFormatter()
            formatter.countStyle = .file
            let sizeStr = formatter.string(fromByteCount: size)
            let maxSizeStr = formatter.string(fromByteCount: maxSize)
            return "Файл слишком большой (\(sizeStr)). Максимальный размер: \(maxSizeStr)"
        case .invalidFormat:
            return "Неверный формат файла. Ожидается ZIP архив с Cmi5 пакетом."
        case .missingManifest:
            return "В архиве отсутствует файл манифеста cmi5.xml"
        }
    }
}

/// Информация о файле
struct FileInfo {
    let name: String
    let size: Int64
    let type: String
    let url: URL
    
    var formattedSize: String {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        return formatter.string(fromByteCount: size)
    }
}

/// ViewModel для импорта Cmi5 пакетов
@MainActor
final class Cmi5ImportViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var selectedFileInfo: FileInfo?
    @Published var isProcessing = false
    @Published var processingProgress: String?
    @Published var parsedPackage: Cmi5Package?
    @Published var importedPackage: Cmi5Package?
    @Published var error: String?
    @Published var validationWarnings: [String] = []
    
    // MARK: - Properties
    
    var courseId: UUID?
    private let parser = Cmi5Parser()
    private let cmi5Service = Cmi5Service.shared // Используем shared instance
    private let maxFileSize: Int64 = 500 * 1024 * 1024 // 500 MB
    
    // MARK: - Computed Properties
    
    var canImport: Bool {
        parsedPackage != nil && 
        !isProcessing && 
        error == nil &&
        parsedPackage?.isValid == true
    }
    
    // MARK: - Public Methods
    
    /// Обрабатывает выбранный файл
    func processFile(at url: URL) async {
        await MainActor.run {
            self.error = nil
            self.validationWarnings = []
            self.isProcessing = true
            self.processingProgress = "Чтение файла..."
        }
        
        do {
            // Получаем доступ к файлу
            guard url.startAccessingSecurityScopedResource() else {
                throw ValidationError.fileAccessDenied
            }
            defer { url.stopAccessingSecurityScopedResource() }
            
            // Получаем информацию о файле
            let attributes = try FileManager.default.attributesOfItem(atPath: url.path)
            let fileSize = attributes[.size] as? Int64 ?? 0
            
            // Проверяем размер файла
            if fileSize > maxFileSize {
                throw ValidationError.fileTooLarge(size: fileSize, maxSize: maxFileSize)
            }
            
            // Создаем FileInfo
            let fileInfo = FileInfo(
                name: url.lastPathComponent,
                size: fileSize,
                type: "ZIP Archive",
                url: url
            )
            
            await MainActor.run {
                self.selectedFileInfo = fileInfo
                self.processingProgress = "Проверка архива..."
            }
            
            // Парсим пакет
            let parseResult = try await parser.parsePackage(from: url)
            
            await MainActor.run {
                self.parsedPackage = parseResult
                self.validationWarnings = []
                self.isProcessing = false
                self.processingProgress = nil
            }
            
        } catch {
            await MainActor.run {
                self.error = error.localizedDescription
                self.isProcessing = false
                self.processingProgress = nil
            }
        }
    }
    
    /// Обрабатывает уже выбранный файл
    func processSelectedFile() async {
        guard let fileInfo = selectedFileInfo else { return }
        await processFile(at: fileInfo.url)
    }
    
    /// Очищает выбранный файл
    func clearSelection() {
        selectedFileInfo = nil
        parsedPackage = nil
        error = nil
        validationWarnings = []
    }
    
    /// Очищает ошибку
    func clearError() {
        error = nil
    }
    
    // MARK: - File Processing
    
    /// Process selected file
    func processFile(_ url: URL) async {
        selectedFileInfo = FileInfo(
            name: url.lastPathComponent,
            size: (try? FileManager.default.attributesOfItem(atPath: url.path)[.size] as? Int64) ?? 0,
            type: "ZIP Archive",
            url: url
        )
        
        isProcessing = true
        processingProgress = "Обработка файла..."
        
        do {
            let parseResult = try await parser.parsePackage(from: url)
            parsedPackage = parseResult
            processingProgress = "Файл успешно обработан"
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.isProcessing = false
                self.processingProgress = nil
            }
        } catch {
            self.error = "Ошибка парсинга: \(error.localizedDescription)"
            isProcessing = false
            processingProgress = nil
        }
    }
    
    // MARK: - Demo Functions
    
    /// Load demo course by filename
    func loadDemoCourse(_ demoCourse: DemoCourse) {
        print("🎯 Cmi5ImportViewModel: Loading demo course: \(demoCourse.name)")
        
        // Пробуем несколько способов получить файл
        var demoFileURL: URL?
        
        // 1. Сначала пробуем получить из Documents (если скопирован)
        if let documentsURL = DemoCourseManager.shared.getDocumentsURL(for: demoCourse) {
            print("✅ Demo course found in Documents: \(documentsURL.path)")
            demoFileURL = documentsURL
        }
        // 2. Если не найден в Documents, пробуем из bundle
        else if let bundleURL = DemoCourseManager.shared.getBundleURL(for: demoCourse) {
            print("✅ Demo course found in bundle: \(bundleURL.path)")
            demoFileURL = bundleURL
        }
        // 3. Если все еще не найден, создаем временный файл для тестирования
        else if let tempURL = DemoCourseManager.shared.createTemporaryDemoCourse(for: demoCourse) {
            print("⚠️ Using temporary demo course: \(tempURL.path)")
            demoFileURL = tempURL
        }
        
        guard let fileURL = demoFileURL else {
            print("❌ Demo course file not found anywhere: \(demoCourse.filename)")
            error = "Demo course file not found"
            return
        }
        
        // Process the file
        selectedFileInfo = FileInfo(
            name: "\(demoCourse.filename).zip",
            size: (try? FileManager.default.attributesOfItem(atPath: fileURL.path)[.size] as? Int64) ?? 0,
            type: "ZIP Archive",
            url: fileURL
        )
        
        Task {
            await processFile(fileURL)
        }
    }
    
    /// Select demo file for testing (deprecated - use loadDemoCourse instead)
    func selectDemoFile() {
        // For backward compatibility, load the AI Fluency course
        if let aiCourse = DemoCourse.allCourses.first {
            loadDemoCourse(aiCourse)
        }
    }
    
    /// Импортирует пакет в систему
    func importPackage() async {
        guard let package = parsedPackage,
              let fileInfo = selectedFileInfo else { 
            print("🔍 CMI5 VM: Import cancelled - no package or file info")
            return 
        }
        
        print("🔍 CMI5 VM: Starting import of package: \(package.title)")
        isProcessing = true
        processingProgress = "Сохранение пакета..."
        
        do {
            // Используем реальный сервис для импорта
            print("🔍 CMI5 VM: Calling cmi5Service.importPackage()...")
            let result = try await cmi5Service.importPackage(
                from: fileInfo.url,
                courseId: courseId,
                uploadedBy: UUID() // В реальном приложении это будет ID текущего пользователя
            )
            
            print("🔍 CMI5 VM: Import successful! Package ID: \(result.package.id)")
            self.importedPackage = result.package
            processingProgress = "Импорт завершен!"
            
            // Показываем предупреждения, если есть
            if !result.warnings.isEmpty {
                print("🔍 CMI5 VM: Import warnings: \(result.warnings)")
                self.validationWarnings = result.warnings
            }
            
        } catch {
            print("🔍 CMI5 VM: Import failed: \(error)")
            self.error = "Ошибка импорта: \(error.localizedDescription)"
        }
        
        isProcessing = false
    }
    
    // MARK: - Private Methods
    
    private func reset() {
        selectedFileInfo = nil
        parsedPackage = nil
        importedPackage = nil
        error = nil
        validationWarnings = []
        processingProgress = nil
    }
    
    private func parsePackage(from url: URL) async {
        isProcessing = true
        processingProgress = "Распаковка архива..."
        
        do {
            // Парсим пакет
            let parseResult = try await parser.parsePackage(from: url)
            
            await MainActor.run {
                self.parsedPackage = parseResult
                self.validationWarnings = []
                self.isProcessing = false
                self.processingProgress = nil
            }
            
        } catch {
            await MainActor.run {
                if let parsingError = error as? Cmi5Parser.ParsingError {
                    self.error = parsingError.errorDescription
                } else {
                    self.error = "Ошибка парсинга: \(error.localizedDescription)"
                }
                self.isProcessing = false
                self.processingProgress = nil
            }
        }
    }
    
    /// Создает демо-пакет для тестирования
    private func createDemoPackage() -> Cmi5Package {
        let activities = [
            Cmi5Activity(
                id: UUID(),
                packageId: UUID(),
                activityId: "module_1",
                title: "Введение в корпоративную культуру",
                description: "Базовый модуль о ценностях и принципах компании",
                launchUrl: "content/module1/index.html",
                launchMethod: .anyWindow,
                moveOn: .completedOrPassed,
                masteryScore: 0.8,
                activityType: "http://adlnet.gov/expapi/activities/module",
                duration: "PT30M" // 30 минут
            ),
            Cmi5Activity(
                id: UUID(),
                packageId: UUID(),
                activityId: "quiz_1",
                title: "Тест: Корпоративные ценности",
                description: "Проверка знаний корпоративных ценностей",
                launchUrl: "content/quiz1/index.html",
                launchMethod: .ownWindow,
                moveOn: .passed,
                masteryScore: 0.75,
                activityType: "http://adlnet.gov/expapi/activities/assessment",
                duration: "PT15M" // 15 минут
            ),
            Cmi5Activity(
                id: UUID(),
                packageId: UUID(),
                activityId: "video_1",
                title: "Видео: История компании",
                description: "Документальный фильм об истории развития компании",
                launchUrl: "content/video1/index.html",
                launchMethod: .anyWindow,
                moveOn: .completed,
                masteryScore: nil,
                activityType: "http://adlnet.gov/expapi/activities/media",
                duration: "PT45M" // 45 минут
            )
        ]
        
        // Создаем блок с активностями
        let rootBlock = Cmi5Block(
            id: "block_main",
            title: [Cmi5LangString(lang: "ru", value: "Основные модули")],
            activities: activities
        )
        
        let course = Cmi5Course(
            id: "course_001",
            title: [Cmi5LangString(lang: "ru", value: "Корпоративная культура ЦУМ")],
            description: [Cmi5LangString(lang: "ru", value: "Базовый курс для новых сотрудников")],
            auCount: activities.count,
            rootBlock: rootBlock
        )
        
        let manifest = Cmi5Manifest(
            identifier: "course_corporate_culture_v1",
            title: "Корпоративная культура ЦУМ",
            description: "Базовый курс для новых сотрудников о корпоративной культуре",
            moreInfo: "https://lms.tsum.ru/courses/corporate-culture",
            vendor: Cmi5Vendor(
                name: "ЦУМ Learning & Development",
                contact: "learning@tsum.ru",
                url: "https://lms.tsum.ru"
            ),
            version: "1.0.0",
            course: course
        )
        
        return Cmi5Package(
            packageId: manifest.identifier,
            title: manifest.title,
            description: manifest.description,
            courseId: courseId,
            manifest: manifest,
            filePath: "/demo/package.zip",
            size: selectedFileInfo?.size ?? 0,
            uploadedBy: UUID() // Текущий пользователь
        )
    }
}

// MARK: - Extensions

// empty() method is defined in Cmi5Models.swift 