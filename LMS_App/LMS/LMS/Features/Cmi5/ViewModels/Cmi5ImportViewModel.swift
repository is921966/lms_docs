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
    
    /// Выбирает демо файл для тестирования
    func selectDemoFile() {
        // Эмулируем выбор файла для демо
        let demoUrl = URL(fileURLWithPath: "/demo/sample-cmi5.zip")
        let demoFileInfo = FileInfo(
            name: "sample-cmi5-course.zip",
            size: 25 * 1024 * 1024, // 25 MB
            type: "ZIP Archive",
            url: demoUrl
        )
        
        selectedFileInfo = demoFileInfo
        
        // Эмулируем парсинг
        Task {
            isProcessing = true
            processingProgress = "Обработка демо пакета..."
            
            try? await Task.sleep(nanoseconds: 2_000_000_000) // 2 секунды
            
            // Создаем демо пакет
            let demoManifest = Cmi5Manifest(
                identifier: "demo-course-001",
                title: "Демо курс Cmi5",
                description: "Пример Cmi5 курса для тестирования",
                version: "1.0",
                course: nil
            )
            
            parsedPackage = Cmi5Package(
                packageId: demoManifest.identifier,
                title: demoManifest.title,
                description: demoManifest.description,
                courseId: courseId,
                manifest: demoManifest,
                filePath: "/demo/sample-cmi5",
                size: demoFileInfo.size,
                uploadedBy: UUID(),
                version: demoManifest.version ?? "1.0",
                isValid: true,
                validationErrors: []
            )
            
            isProcessing = false
            processingProgress = nil
        }
    }
    
    /// Импортирует пакет в систему
    func importPackage() async {
        guard let package = parsedPackage else { return }
        
        isProcessing = true
        processingProgress = "Сохранение пакета..."
        
        do {
            // Симуляция сохранения
            try await Task.sleep(nanoseconds: 1_000_000_000) // 1 секунда
            
            processingProgress = "Создание активностей..."
            try await Task.sleep(nanoseconds: 500_000_000) // 0.5 секунды
            
            processingProgress = "Привязка к курсу..."
            try await Task.sleep(nanoseconds: 500_000_000) // 0.5 секунды
            
            // Создаем новый пакет с обновленными данными
            var importedPackage = package
            importedPackage.courseId = courseId
            
            self.importedPackage = importedPackage
            processingProgress = "Импорт завершен!"
            
        } catch {
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