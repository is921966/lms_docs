//
//  Cmi5ImportViewModel.swift
//  LMS
//
//  Created on Sprint 40 Day 1 - Cmi5 Integration
//

import Foundation
import SwiftUI
import Combine

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
    func processFile(at url: URL) {
        reset()
        
        // Проверяем размер файла
        do {
            let attributes = try FileManager.default.attributesOfItem(atPath: url.path)
            let fileSize = attributes[.size] as? Int64 ?? 0
            
            if fileSize > maxFileSize {
                error = "Файл слишком большой. Максимальный размер: 500 МБ"
                return
            }
            
            selectedFileInfo = FileInfo(
                name: url.lastPathComponent,
                size: fileSize,
                type: "ZIP архив",
                url: url
            )
            
            // Начинаем парсинг
            Task {
                await parsePackage(from: url)
            }
            
        } catch {
            self.error = "Не удалось прочитать файл: \(error.localizedDescription)"
        }
    }
    
    /// Выбирает демо-файл для тестирования
    func selectDemoFile() {
        // Создаем демо пакет для тестирования
        let demoPackage = createDemoPackage()
        parsedPackage = demoPackage
        
        // Валидируем пакет
        let validationResult = parser.validatePackage(demoPackage)
        if !validationResult.isValid {
            error = validationResult.errors.first
        }
        validationWarnings = validationResult.warnings
        
        selectedFileInfo = FileInfo(
            name: "demo-course.zip",
            size: 1024 * 1024 * 5, // 5 MB
            type: "ZIP архив",
            url: URL(fileURLWithPath: "/demo/path")
        )
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
            let importedPackage = Cmi5Package(
                id: package.id,
                courseId: courseId,
                packageName: package.packageName,
                packageVersion: package.packageVersion,
                manifest: package.manifest,
                activities: package.activities,
                uploadedAt: package.uploadedAt,
                uploadedBy: package.uploadedBy,
                fileSize: package.fileSize,
                status: .valid
            )
            
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
            let package = try await parser.parsePackage(from: url)
            
            processingProgress = "Валидация пакета..."
            
            // Валидируем
            let validationResult = parser.validatePackage(package)
            
            await MainActor.run {
                self.parsedPackage = package
                self.validationWarnings = validationResult.warnings
                
                if !validationResult.isValid {
                    self.error = validationResult.errors.joined(separator: "\n")
                }
                
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
            course: Cmi5Course(
                id: "course_001",
                title: "Корпоративная культура ЦУМ",
                description: "Базовый курс для новых сотрудников",
                auCount: activities.count
            )
        )
        
        return Cmi5Package(
            id: UUID(),
            courseId: courseId,
            packageName: manifest.title,
            packageVersion: "1.0.0",
            manifest: manifest,
            activities: activities,
            uploadedAt: Date(),
            uploadedBy: UUID(), // Текущий пользователь
            fileSize: selectedFileInfo?.size ?? 0,
            status: .processing
        )
    }
}

// MARK: - Extensions

// empty() method is defined in Cmi5Models.swift 