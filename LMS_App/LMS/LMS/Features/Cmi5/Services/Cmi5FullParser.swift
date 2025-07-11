//
//  Cmi5FullParser.swift
//  LMS
//
//  Created on Sprint 40 Day 2 - Advanced Cmi5 Parsing
//

import Foundation

/// Расширенный парсер для Cmi5 пакетов с поддержкой блоков
public final class Cmi5FullParser {
    
    // MARK: - Types
    
    /// Структура блока в курсе
    public struct Cmi5Block: Identifiable {
        public let id: String
        public let title: String
        public let description: String?
        public let objectives: [String]
        public let children: [Cmi5CourseNode]
    }
    
    /// Узел в структуре курса (может быть блоком или активностью)
    public enum Cmi5CourseNode {
        case block(Cmi5Block)
        case activity(Cmi5Activity)
    }
    
    /// Расширенная структура курса
    public struct Cmi5ExtendedCourse {
        public let manifest: Cmi5Manifest
        public let structure: [Cmi5CourseNode]
        public let metadata: Cmi5Metadata?
    }
    
    /// Метаданные курса
    public struct Cmi5Metadata {
        public let language: String?
        public let duration: String?
        public let publisher: String?
        public let rights: String?
        public let extensions: [String: String]
    }
    
    // MARK: - Properties
    
    private let fileManager = FileManager.default
    private let maxPackageSize: Int64 = 500 * 1024 * 1024 // 500MB
    
    // MARK: - Public Methods
    
    /// Парсит полный Cmi5 пакет с расширенной информацией
    public func parseFullPackage(from fileURL: URL) async throws -> (package: Cmi5Package, extendedCourse: Cmi5ExtendedCourse) {
        // Валидация файла
        try validateFile(at: fileURL)
        
        // Получаем информацию о файле
        let fileSize = try getFileSize(at: fileURL)
        
        // Создаем временную директорию
        let tempURL = createTempDirectory()
        defer {
            cleanupTempDirectory(tempURL)
        }
        
        // Распаковываем архив
        try await unzipPackage(from: fileURL, to: tempURL)
        
        // Парсим манифест
        let manifestURL = try findManifest(in: tempURL)
        let manifestData = try Data(contentsOf: manifestURL)
        
        // Парсим полную структуру
        let parser = Cmi5XMLParser()
        let parseResult = try parser.parseManifest(manifestData, baseURL: tempURL)
        
        // Создаем пакет
        let package = Cmi5Package(
            packageId: parseResult.manifest.identifier,
            title: parseResult.manifest.title,
            description: parseResult.manifest.description,
            manifest: parseResult.manifest,
            filePath: fileURL.path,
            size: fileSize,
            uploadedBy: UUID(), // TODO: Получить из контекста
            version: parseResult.manifest.version ?? "1.0"
        )
        
        return (package, parseResult.extendedCourse)
    }
    
    /// Валидирует структуру Cmi5 пакета
    public func validatePackageStructure(_ extendedCourse: Cmi5ExtendedCourse) -> ValidationResult {
        var errors: [String] = []
        var warnings: [String] = []
        
        // Валидация базовой информации
        if extendedCourse.manifest.title.isEmpty {
            errors.append("Название курса обязательно")
        }
        
        // Валидация структуры
        let activityCount = countActivities(in: extendedCourse.structure)
        if activityCount == 0 {
            errors.append("Курс должен содержать хотя бы одну активность")
        }
        
        // Проверка глубины вложенности
        let maxDepth = calculateMaxDepth(extendedCourse.structure)
        if maxDepth > 5 {
            warnings.append("Глубина вложенности блоков превышает рекомендуемую (5 уровней)")
        }
        
        // Валидация активностей
        validateActivities(in: extendedCourse.structure, errors: &errors, warnings: &warnings)
        
        return ValidationResult(
            isValid: errors.isEmpty,
            errors: errors,
            warnings: warnings
        )
    }
    
    // MARK: - Private Methods
    
    private func validateFile(at url: URL) throws {
        guard fileManager.fileExists(atPath: url.path) else {
            throw Cmi5Parser.ParsingError.fileNotFound
        }
        
        let fileSize = try getFileSize(at: url)
        guard fileSize <= maxPackageSize else {
            throw Cmi5Parser.ParsingError.invalidPackageFormat
        }
    }
    
    private func getFileSize(at url: URL) throws -> Int64 {
        let attributes = try fileManager.attributesOfItem(atPath: url.path)
        return attributes[.size] as? Int64 ?? 0
    }
    
    private func createTempDirectory() -> URL {
        let tempURL = fileManager.temporaryDirectory.appendingPathComponent("cmi5_\(UUID().uuidString)")
        try? fileManager.createDirectory(at: tempURL, withIntermediateDirectories: true)
        return tempURL
    }
    
    private func cleanupTempDirectory(_ url: URL) {
        try? fileManager.removeItem(at: url)
    }
    
    private func unzipPackage(from source: URL, to destination: URL) async throws {
        // В реальном приложении используется ZIPFoundation
        // Здесь создаем демо-структуру для тестирования
        
        let manifestURL = destination.appendingPathComponent("cmi5.xml")
        let contentURL = destination.appendingPathComponent("content")
        try fileManager.createDirectory(at: contentURL, withIntermediateDirectories: true)
        
        // Создаем расширенный демо-манифест
        let demoManifest = createDemoManifest()
        try demoManifest.write(to: manifestURL, atomically: true, encoding: .utf8)
        
        // Создаем демо-контент
        createDemoContent(at: contentURL)
    }
    
    private func findManifest(in directory: URL) throws -> URL {
        let manifestURL = directory.appendingPathComponent("cmi5.xml")
        guard fileManager.fileExists(atPath: manifestURL.path) else {
            // Попробуем найти в поддиректориях
            let contents = try fileManager.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil)
            for item in contents {
                if item.lastPathComponent == "cmi5.xml" {
                    return item
                }
            }
            throw Cmi5Parser.ParsingError.manifestNotFound
        }
        return manifestURL
    }
    
    private func countActivities(in nodes: [Cmi5CourseNode]) -> Int {
        var count = 0
        for node in nodes {
            switch node {
            case .activity:
                count += 1
            case .block(let block):
                count += countActivities(in: block.children)
            }
        }
        return count
    }
    
    private func calculateMaxDepth(_ nodes: [Cmi5CourseNode], currentDepth: Int = 0) -> Int {
        var maxDepth = currentDepth
        
        for node in nodes {
            switch node {
            case .activity:
                continue
            case .block(let block):
                let blockDepth = calculateMaxDepth(block.children, currentDepth: currentDepth + 1)
                maxDepth = max(maxDepth, blockDepth)
            }
        }
        
        return maxDepth
    }
    
    private func validateActivities(in nodes: [Cmi5CourseNode], errors: inout [String], warnings: inout [String]) {
        for node in nodes {
            switch node {
            case .activity(let activity):
                if activity.launchUrl.isEmpty {
                    errors.append("Активность '\(activity.title)' не имеет URL для запуска")
                }
                if let score = activity.masteryScore {
                    if score < 0 || score > 1 {
                        errors.append("Недопустимый проходной балл для '\(activity.title)': \(score)")
                    }
                }
            case .block(let block):
                if block.title.isEmpty {
                    warnings.append("Блок без названия: \(block.id)")
                }
                validateActivities(in: block.children, errors: &errors, warnings: &warnings)
            }
        }
    }
    
    private func createDemoManifest() -> String {
        return """
        <?xml version="1.0" encoding="UTF-8"?>
        <courseStructure xmlns="https://w3id.org/xapi/profiles/cmi5/v1/CourseStructure.xsd"
                        id="course_sales_training_v2">
            <course id="course_001">
                <title>Тренинг по продажам</title>
                <description>Комплексный курс по технике продаж</description>
                <langstring lang="ru-RU">
                    <metadata>
                        <publisher>Корпоративный университет</publisher>
                        <rights>© 2025 Все права защищены</rights>
                    </metadata>
                </langstring>
                
                <block id="block_basics">
                    <title>Основы продаж</title>
                    <description>Базовые концепции и принципы</description>
                    <objectives>
                        <objective id="obj_1">Понимать психологию покупателя</objective>
                        <objective id="obj_2">Знать этапы продаж</objective>
                    </objectives>
                    
                    <au id="au_intro" launchMethod="OwnWindow" moveOn="Completed">
                        <title>Введение в продажи</title>
                        <description>Основные понятия и определения</description>
                        <url>content/basics/intro/index.html</url>
                        <activityType>http://adlnet.gov/expapi/activities/lesson</activityType>
                        <duration>PT30M</duration>
                    </au>
                    
                    <au id="au_psychology" launchMethod="AnyWindow" moveOn="CompletedAndPassed" masteryScore="0.8">
                        <title>Психология покупателя</title>
                        <description>Понимание потребностей клиента</description>
                        <url>content/basics/psychology/index.html</url>
                        <activityType>http://adlnet.gov/expapi/activities/module</activityType>
                        <duration>PT45M</duration>
                    </au>
                </block>
                
                <block id="block_techniques">
                    <title>Техники продаж</title>
                    <description>Практические методы работы с клиентами</description>
                    
                    <block id="block_cold_calls">
                        <title>Холодные звонки</title>
                        <au id="au_cold_intro" moveOn="Completed">
                            <title>Основы холодных звонков</title>
                            <url>content/techniques/cold/intro.html</url>
                        </au>
                        <au id="au_cold_practice" moveOn="Passed" masteryScore="0.7">
                            <title>Практика холодных звонков</title>
                            <url>content/techniques/cold/practice.html</url>
                            <activityType>http://adlnet.gov/expapi/activities/simulation</activityType>
                        </au>
                    </block>
                    
                    <au id="au_presentation" moveOn="CompletedOrPassed">
                        <title>Презентация продукта</title>
                        <url>content/techniques/presentation/index.html</url>
                    </au>
                </block>
                
                <au id="au_final_test" moveOn="Passed" masteryScore="0.85">
                    <title>Итоговое тестирование</title>
                    <description>Проверка полученных знаний</description>
                    <url>content/test/final.html</url>
                    <activityType>http://adlnet.gov/expapi/activities/assessment</activityType>
                    <duration>PT60M</duration>
                </au>
            </course>
        </courseStructure>
        """
    }
    
    private func createDemoContent(at contentURL: URL) {
        // Создаем структуру папок для демо-контента
        let paths = [
            "basics/intro",
            "basics/psychology",
            "techniques/cold",
            "techniques/presentation",
            "test"
        ]
        
        for path in paths {
            let folderURL = contentURL.appendingPathComponent(path)
            try? fileManager.createDirectory(at: folderURL, withIntermediateDirectories: true)
            
            // Создаем index.html в каждой папке
            let indexHTML = """
            <!DOCTYPE html>
            <html>
            <head>
                <title>Cmi5 Content</title>
                <script src="cmi5.js"></script>
            </head>
            <body>
                <h1>Demo Content: \(path)</h1>
                <p>This is a demo Cmi5 activity.</p>
            </body>
            </html>
            """
            
            let indexURL = folderURL.appendingPathComponent("index.html")
            try? indexHTML.write(to: indexURL, atomically: true, encoding: .utf8)
        }
    }
} 