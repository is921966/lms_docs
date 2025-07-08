//
//  Cmi5ArchiveHandler.swift
//  LMS
//
//  Created on Sprint 40 Day 3 - ZIP Archive Support
//

import Foundation
import UniformTypeIdentifiers

/// Обработчик архивов Cmi5 пакетов
public final class Cmi5ArchiveHandler {
    
    // MARK: - Types
    
    /// Ошибки при работе с архивом
    public enum ArchiveError: LocalizedError {
        case invalidArchive
        case manifestNotFound
        case invalidManifest(String)
        case extractionFailed(String)
        case fileTooLarge(maxSize: Int64)
        case unsupportedFormat
        case invalidStructure(String)
        
        public var errorDescription: String? {
            switch self {
            case .invalidArchive:
                return "Недействительный архив. Убедитесь, что файл является корректным ZIP архивом."
            case .manifestNotFound:
                return "Манифест cmi5.xml не найден в архиве."
            case .invalidManifest(let details):
                return "Недействительный манифест: \(details)"
            case .extractionFailed(let reason):
                return "Не удалось распаковать архив: \(reason)"
            case .fileTooLarge(let maxSize):
                return "Файл слишком большой. Максимальный размер: \(maxSize / 1024 / 1024) МБ"
            case .unsupportedFormat:
                return "Неподдерживаемый формат архива. Поддерживается только ZIP."
            case .invalidStructure(let details):
                return "Недействительная структура архива: \(details)"
            }
        }
    }
    
    /// Результат распаковки архива
    public struct ExtractionResult {
        public let manifestURL: URL
        public let contentURL: URL
        public let packageSize: Int64
        public let fileCount: Int
        public let extractedPath: URL
    }
    
    // MARK: - Properties
    
    private let fileManager = FileManager.default
    private let maxArchiveSize: Int64 = 500 * 1024 * 1024 // 500 MB
    private let tempDirectory: URL
    
    // MARK: - Initialization
    
    public init() {
        self.tempDirectory = fileManager.temporaryDirectory
            .appendingPathComponent("cmi5_packages", isDirectory: true)
        
        // Создаем временную директорию если нужно
        try? fileManager.createDirectory(at: tempDirectory, withIntermediateDirectories: true)
    }
    
    // MARK: - Public Methods
    
    /// Валидирует архив без распаковки
    public func validateArchive(at url: URL) throws {
        // Проверяем существование файла
        guard fileManager.fileExists(atPath: url.path) else {
            throw ArchiveError.invalidArchive
        }
        
        // Проверяем размер
        let attributes = try fileManager.attributesOfItem(atPath: url.path)
        let fileSize = attributes[.size] as? Int64 ?? 0
        
        if fileSize > maxArchiveSize {
            throw ArchiveError.fileTooLarge(maxSize: maxArchiveSize)
        }
        
        // Проверяем формат (должен быть ZIP)
        let type = try url.resourceValues(forKeys: [.contentTypeKey]).contentType
        guard type == .zip || url.pathExtension.lowercased() == "zip" else {
            throw ArchiveError.unsupportedFormat
        }
    }
    
    /// Распаковывает архив и возвращает пути к ключевым файлам
    public func extractArchive(from url: URL) async throws -> ExtractionResult {
        // Валидируем архив
        try validateArchive(at: url)
        
        // Создаем уникальную директорию для распаковки
        let packageId = UUID().uuidString
        let extractionPath = tempDirectory.appendingPathComponent(packageId, isDirectory: true)
        
        try fileManager.createDirectory(at: extractionPath, withIntermediateDirectories: true)
        
        // Распаковываем архив используя Process (unzip)
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/unzip")
        process.arguments = ["-q", "-o", url.path, "-d", extractionPath.path]
        
        let pipe = Pipe()
        process.standardError = pipe
        
        try process.run()
        process.waitUntilExit()
        
        if process.terminationStatus != 0 {
            // Читаем ошибку
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            let errorString = String(data: data, encoding: .utf8) ?? "Unknown error"
            
            // Удаляем временную папку
            try? fileManager.removeItem(at: extractionPath)
            
            throw ArchiveError.extractionFailed(errorString)
        }
        
        // Ищем манифест
        let manifestURL = try findManifest(in: extractionPath)
        
        // Определяем директорию с контентом
        let contentURL = manifestURL.deletingLastPathComponent()
        
        // Считаем файлы и размер
        let fileCount = try countFiles(in: extractionPath)
        let packageSize = try calculateSize(of: extractionPath)
        
        return ExtractionResult(
            manifestURL: manifestURL,
            contentURL: contentURL,
            packageSize: packageSize,
            fileCount: fileCount,
            extractedPath: extractionPath
        )
    }
    
    /// Очищает временные файлы пакета
    public func cleanupPackage(at path: URL) {
        try? fileManager.removeItem(at: path)
    }
    
    /// Очищает все временные файлы
    public func cleanupAll() {
        try? fileManager.removeItem(at: tempDirectory)
        try? fileManager.createDirectory(at: tempDirectory, withIntermediateDirectories: true)
    }
    
    /// Копирует распакованный пакет в постоянное хранилище
    public func moveToStorage(from tempPath: URL, to storagePath: URL) throws {
        // Создаем директорию если нужно
        let parentDir = storagePath.deletingLastPathComponent()
        try fileManager.createDirectory(at: parentDir, withIntermediateDirectories: true)
        
        // Перемещаем файлы
        if fileManager.fileExists(atPath: storagePath.path) {
            try fileManager.removeItem(at: storagePath)
        }
        
        try fileManager.moveItem(at: tempPath, to: storagePath)
    }
    
    // MARK: - Private Methods
    
    private func findManifest(in directory: URL) throws -> URL {
        let enumerator = fileManager.enumerator(
            at: directory,
            includingPropertiesForKeys: [.isRegularFileKey],
            options: [.skipsHiddenFiles]
        )
        
        while let fileURL = enumerator?.nextObject() as? URL {
            if fileURL.lastPathComponent.lowercased() == "cmi5.xml" {
                return fileURL
            }
        }
        
        throw ArchiveError.manifestNotFound
    }
    
    private func countFiles(in directory: URL) throws -> Int {
        let enumerator = fileManager.enumerator(
            at: directory,
            includingPropertiesForKeys: [.isRegularFileKey],
            options: [.skipsHiddenFiles]
        )
        
        var count = 0
        while let fileURL = enumerator?.nextObject() as? URL {
            let resourceValues = try fileURL.resourceValues(forKeys: [.isRegularFileKey])
            if resourceValues.isRegularFile == true {
                count += 1
            }
        }
        
        return count
    }
    
    private func calculateSize(of directory: URL) throws -> Int64 {
        let enumerator = fileManager.enumerator(
            at: directory,
            includingPropertiesForKeys: [.fileSizeKey, .isRegularFileKey],
            options: [.skipsHiddenFiles]
        )
        
        var totalSize: Int64 = 0
        while let fileURL = enumerator?.nextObject() as? URL {
            let resourceValues = try fileURL.resourceValues(forKeys: [.fileSizeKey, .isRegularFileKey])
            if resourceValues.isRegularFile == true {
                totalSize += Int64(resourceValues.fileSize ?? 0)
            }
        }
        
        return totalSize
    }
}

// MARK: - Archive Validation

extension Cmi5ArchiveHandler {
    
    /// Структура валидации архива
    public struct ValidationResult {
        public let isValid: Bool
        public let errors: [String]
        public let warnings: [String]
        public let structure: ArchiveStructure?
    }
    
    /// Структура архива
    public struct ArchiveStructure {
        public let hasManifest: Bool
        public let hasContent: Bool
        public let contentFolders: [String]
        public let manifestLocation: String?
        public let estimatedActivities: Int
    }
    
    /// Выполняет полную валидацию архива
    public func performFullValidation(at url: URL) async throws -> ValidationResult {
        var errors: [String] = []
        var warnings: [String] = []
        
        // Базовая валидация
        do {
            try validateArchive(at: url)
        } catch {
            errors.append(error.localizedDescription)
            return ValidationResult(isValid: false, errors: errors, warnings: warnings, structure: nil)
        }
        
        // Распаковываем для детальной проверки
        let extraction: ExtractionResult
        do {
            extraction = try await extractArchive(from: url)
        } catch {
            errors.append("Не удалось распаковать архив: \(error.localizedDescription)")
            return ValidationResult(isValid: false, errors: errors, warnings: warnings, structure: nil)
        }
        
        defer {
            cleanupPackage(at: extraction.extractedPath)
        }
        
        // Проверяем структуру
        let structure = try analyzeStructure(at: extraction.extractedPath)
        
        // Валидация структуры
        if !structure.hasManifest {
            errors.append("Манифест cmi5.xml не найден")
        }
        
        if !structure.hasContent {
            warnings.append("Не найдена папка с контентом")
        }
        
        if structure.contentFolders.isEmpty {
            warnings.append("Не найдены папки с активностями")
        }
        
        // Проверяем манифест
        if structure.hasManifest {
            do {
                let manifestData = try Data(contentsOf: extraction.manifestURL)
                let parser = Cmi5Parser()
                _ = try parser.parseManifest(manifestData, baseURL: extraction.contentURL)
            } catch {
                errors.append("Ошибка парсинга манифеста: \(error.localizedDescription)")
            }
        }
        
        return ValidationResult(
            isValid: errors.isEmpty,
            errors: errors,
            warnings: warnings,
            structure: structure
        )
    }
    
    private func analyzeStructure(at path: URL) throws -> ArchiveStructure {
        var hasManifest = false
        var manifestLocation: String?
        var contentFolders: [String] = []
        var hasContent = false
        
        let enumerator = fileManager.enumerator(
            at: path,
            includingPropertiesForKeys: [.isDirectoryKey, .isRegularFileKey],
            options: [.skipsHiddenFiles]
        )
        
        while let fileURL = enumerator?.nextObject() as? URL {
            let resourceValues = try fileURL.resourceValues(forKeys: [.isDirectoryKey, .isRegularFileKey])
            
            // Проверяем манифест
            if fileURL.lastPathComponent.lowercased() == "cmi5.xml" {
                hasManifest = true
                manifestLocation = fileURL.path.replacingOccurrences(of: path.path + "/", with: "")
            }
            
            // Проверяем папки контента
            if resourceValues.isDirectory == true {
                let folderName = fileURL.lastPathComponent.lowercased()
                if folderName == "content" || folderName == "contents" {
                    hasContent = true
                    
                    // Ищем подпапки в content
                    let contentEnumerator = fileManager.enumerator(
                        at: fileURL,
                        includingPropertiesForKeys: [.isDirectoryKey],
                        options: [.skipsHiddenFiles, .skipsSubdirectoryDescendants]
                    )
                    
                    while let subURL = contentEnumerator?.nextObject() as? URL {
                        let subResourceValues = try subURL.resourceValues(forKeys: [.isDirectoryKey])
                        if subResourceValues.isDirectory == true {
                            contentFolders.append(subURL.lastPathComponent)
                        }
                    }
                }
            }
        }
        
        return ArchiveStructure(
            hasManifest: hasManifest,
            hasContent: hasContent,
            contentFolders: contentFolders,
            manifestLocation: manifestLocation,
            estimatedActivities: contentFolders.count
        )
    }
} 