//
//  Cmi5ArchiveHandler.swift
//  LMS
//
//  Created on 24.06.2025.
//

import Foundation
import UniformTypeIdentifiers
import ZIPFoundation

/// Обработчик ZIP архивов для Cmi5 пакетов
public class Cmi5ArchiveHandler {
    
    // MARK: - Types
    
    public enum ArchiveError: LocalizedError {
        case invalidArchive
        case extractionFailed(String)
        case fileTooLarge(maxSize: Int64)
        case unsupportedFormat
        case fileNotFound(String)
        case temporaryDirectoryError
        
        public var errorDescription: String? {
            switch self {
            case .invalidArchive:
                return "Недействительный архив. Убедитесь, что файл является корректным ZIP архивом."
            case .extractionFailed(let reason):
                return "Ошибка распаковки: \(reason)"
            case .fileTooLarge(let maxSize):
                let sizeMB = maxSize / 1024 / 1024
                return "Файл слишком большой. Максимальный размер: \(sizeMB) МБ"
            case .unsupportedFormat:
                return "Неподдерживаемый формат файла"
            case .fileNotFound(let filename):
                return "Файл не найден: \(filename)"
            case .temporaryDirectoryError:
                return "Ошибка создания временной директории"
            }
        }
    }
    
    public struct ExtractionResult {
        public let packageId: String
        public let extractedPath: URL
        public let cmi5ManifestPath: URL
        public let coursePath: URL
        public let extractedFiles: [String]
    }
    
    // MARK: - Properties
    
    private let fileManager = FileManager.default
    private let tempDirectory: URL
    private let maxArchiveSize: Int64 = 100 * 1024 * 1024 // 100 MB
    
    // MARK: - Initialization
    
    public init() {
        self.tempDirectory = fileManager.temporaryDirectory
            .appendingPathComponent("cmi5_packages", isDirectory: true)
        
        // Создаем директорию если её нет
        try? fileManager.createDirectory(at: tempDirectory, withIntermediateDirectories: true)
    }
    
    // MARK: - Public Methods
    
    /// Валидирует архив без распаковки
    public func validateArchive(at url: URL) throws {
        print("🔍 [Cmi5ArchiveHandler] Validating archive at: \(url.path)")
        
        // Проверяем существование файла
        guard fileManager.fileExists(atPath: url.path) else {
            print("❌ [Cmi5ArchiveHandler] File does not exist at path: \(url.path)")
            throw ArchiveError.invalidArchive
        }
        
        // Проверяем размер
        let attributes = try fileManager.attributesOfItem(atPath: url.path)
        let fileSize = attributes[.size] as? Int64 ?? 0
        print("📏 [Cmi5ArchiveHandler] File size: \(fileSize) bytes")
        
        if fileSize > maxArchiveSize {
            print("❌ [Cmi5ArchiveHandler] File too large: \(fileSize) > \(maxArchiveSize)")
            throw ArchiveError.fileTooLarge(maxSize: maxArchiveSize)
        }
        
        // Проверяем доступ к файлу
        let hasSecurityScope = url.startAccessingSecurityScopedResource()
        defer { 
            if hasSecurityScope {
                url.stopAccessingSecurityScopedResource()
            }
        }
        
        if !hasSecurityScope {
            print("⚠️ [Cmi5ArchiveHandler] Could not access security scoped resource - continuing without it")
        }
        
        // Проверяем, что это действительно ZIP файл
        do {
            // Дополнительная диагностика - проверяем сигнатуру файла
            let fileHandle = try FileHandle(forReadingFrom: url)
            let signature = fileHandle.readData(ofLength: 4)
            fileHandle.closeFile()
            
            // ZIP файлы начинаются с PK (0x504B)
            if signature.count >= 2 {
                let bytes = [UInt8](signature)
                print("📋 [Cmi5ArchiveHandler] File signature: \(bytes.map { String(format: "%02X", $0) }.joined())")
                if bytes[0] != 0x50 || bytes[1] != 0x4B {
                    print("❌ [Cmi5ArchiveHandler] Invalid ZIP signature (expected PK/504B)")
                }
            }
            
            guard let archive = Archive(url: url, accessMode: .read) else {
                print("❌ [Cmi5ArchiveHandler] Could not open as ZIP archive")
                throw ArchiveError.invalidArchive
            }
            
            // Проверяем содержимое архива
            var entryCount = 0
            var entries: [String] = []
            for entry in archive {
                entryCount += 1
                if entries.count < 5 {
                    entries.append(entry.path)
                }
            }
            
            print("📦 [Cmi5ArchiveHandler] Archive entries count: \(entryCount)")
            if entryCount == 0 {
                print("❌ [Cmi5ArchiveHandler] Archive is empty")
                throw ArchiveError.invalidArchive
            }
            
            // Выводим первые несколько файлов для диагностики
            for path in entries {
                print("   - \(path)")
            }
            
            print("✅ [Cmi5ArchiveHandler] Archive is valid ZIP file with \(entryCount) entries")
        } catch {
            print("❌ [Cmi5ArchiveHandler] Archive validation failed: \(error)")
            print("   Error type: \(type(of: error))")
            print("   Error description: \(error.localizedDescription)")
            throw ArchiveError.invalidArchive
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
        
        // Распаковываем архив с использованием ZIPFoundation
        do {
            let hasSecurityScope = url.startAccessingSecurityScopedResource()
            defer { 
                if hasSecurityScope {
                    url.stopAccessingSecurityScopedResource()
                }
            }
            
            if !hasSecurityScope {
                print("⚠️ [Cmi5ArchiveHandler] Could not access security scoped resource - attempting extraction anyway")
            }
            
            try fileManager.unzipItem(at: url, to: extractionPath)
        } catch {
            // Очищаем временную директорию в случае ошибки
            try? fileManager.removeItem(at: extractionPath)
            throw ArchiveError.extractionFailed(error.localizedDescription)
        }
        
        // Ищем cmi5.xml файл
        let cmi5ManifestPath = try findCmi5Manifest(in: extractionPath)
        
        // Определяем корневую директорию курса
        let coursePath = cmi5ManifestPath.deletingLastPathComponent()
        
        // Собираем список всех извлеченных файлов
        let extractedFiles = try listExtractedFiles(at: extractionPath)
        
        return ExtractionResult(
            packageId: packageId,
            extractedPath: extractionPath,
            cmi5ManifestPath: cmi5ManifestPath,
            coursePath: coursePath,
            extractedFiles: extractedFiles
        )
    }
    
    /// Очищает временные файлы для указанного пакета
    public func cleanupPackage(packageId: String) {
        let packagePath = tempDirectory.appendingPathComponent(packageId)
        try? fileManager.removeItem(at: packagePath)
    }
    
    /// Очищает все временные файлы
    public func cleanupAll() {
        try? fileManager.removeItem(at: tempDirectory)
        try? fileManager.createDirectory(at: tempDirectory, withIntermediateDirectories: true)
    }
    
    // MARK: - Private Methods
    
    private func findCmi5Manifest(in directory: URL) throws -> URL {
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
        
        throw ArchiveError.fileNotFound("cmi5.xml")
    }
    
    private func listExtractedFiles(at directory: URL) throws -> [String] {
        var files: [String] = []
        
        let enumerator = fileManager.enumerator(
            at: directory,
            includingPropertiesForKeys: [.isRegularFileKey],
            options: [.skipsHiddenFiles]
        )
        
        while let fileURL = enumerator?.nextObject() as? URL {
            let relativePath = fileURL.path.replacingOccurrences(
                of: directory.path + "/",
                with: ""
            )
            files.append(relativePath)
        }
        
        return files
    }
    
    /// Создает временный демо-пакет для тестирования
    public func createDemoPackage() async throws -> URL {
        let demoPackageId = "demo-\(UUID().uuidString)"
        let demoPath = tempDirectory.appendingPathComponent(demoPackageId, isDirectory: true)
        
        // Создаем структуру директорий
        try fileManager.createDirectory(at: demoPath, withIntermediateDirectories: true)
        
        // Создаем cmi5.xml с правильной структурой
        let cmi5Content = """
        <?xml version="1.0" encoding="utf-8"?>
        <courseStructure xmlns="https://w3id.org/xapi/profiles/cmi5/v1/coursestructure.xsd" id="demo-course-001">
            <title>Демонстрационный курс</title>
            <description>Пример Cmi5 курса для тестирования</description>
            <course id="demo-course">
                <title>Демонстрационный курс</title>
                <description>Пример Cmi5 курса для тестирования</description>
                <au id="demo-activity" moveOn="Passed" launchMethod="OwnWindow">
                    <title>Вводный урок</title>
                    <description>Первый урок демонстрационного курса</description>
                    <url>index.html</url>
                </au>
            </course>
        </courseStructure>
        """
        
        let cmi5Path = demoPath.appendingPathComponent("cmi5.xml")
        try cmi5Content.write(to: cmi5Path, atomically: true, encoding: .utf8)
        
        // Создаем index.html
        let indexContent = """
        <!DOCTYPE html>
        <html>
        <head>
            <title>Демонстрационный курс</title>
            <meta charset="utf-8">
            <style>
                body { 
                    font-family: -apple-system, system-ui; 
                    padding: 20px;
                    max-width: 800px;
                    margin: 0 auto;
                }
                h1 { color: #333; }
                .button {
                    background-color: #007AFF;
                    color: white;
                    padding: 10px 20px;
                    border: none;
                    border-radius: 8px;
                    font-size: 16px;
                    cursor: pointer;
                    margin-top: 20px;
                }
                .button:hover {
                    background-color: #0051D5;
                }
            </style>
        </head>
        <body>
            <h1>Добро пожаловать в демонстрационный курс!</h1>
            <p>Это пример Cmi5 курса для тестирования функциональности импорта.</p>
            <p>В реальном курсе здесь будет образовательный контент, интерактивные элементы и система отслеживания прогресса.</p>
            <button class="button" onclick="alert('Урок завершен! В реальном курсе здесь будет отправка xAPI statement.')">Завершить урок</button>
        </body>
        </html>
        """
        
        let indexPath = demoPath.appendingPathComponent("index.html")
        try indexContent.write(to: indexPath, atomically: true, encoding: .utf8)
        
        // Создаем ZIP архив
        let zipPath = tempDirectory.appendingPathComponent("\(demoPackageId).zip")
        try fileManager.zipItem(at: demoPath, to: zipPath)
        
        // Очищаем временную папку
        try fileManager.removeItem(at: demoPath)
        
        return zipPath
    }
} 