//
//  Cmi5Parser.swift
//  LMS
//
//  Created on Sprint 40 Day 1 - Cmi5 Integration
//

import Foundation

/// Парсер для Cmi5 пакетов
public final class Cmi5Parser {
    
    // MARK: - Error Types
    
    public enum ParsingError: LocalizedError {
        case fileNotFound
        case invalidPackageFormat
        case manifestNotFound
        case invalidManifest
        case xmlParsingError(String)
        case unsupportedVersion
        
        public var errorDescription: String? {
            switch self {
            case .fileNotFound:
                return "Файл пакета не найден"
            case .invalidPackageFormat:
                return "Неверный формат пакета (ожидается ZIP архив)"
            case .manifestNotFound:
                return "Манифест cmi5.xml не найден в пакете"
            case .invalidManifest:
                return "Манифест содержит недопустимые данные"
            case .xmlParsingError(let details):
                return "Ошибка парсинга XML: \(details)"
            case .unsupportedVersion:
                return "Неподдерживаемая версия Cmi5"
            }
        }
    }
    
    // MARK: - Properties
    
    private let fileManager = FileManager.default
    
    // MARK: - Public Methods
    
    /// Парсит Cmi5 пакет из файла
    /// - Parameter fileURL: URL файла пакета
    /// - Returns: Распарсенный Cmi5Package
    /// - Throws: ParsingError если парсинг не удался
    public func parsePackage(from fileURL: URL) async throws -> Cmi5Package {
        let archiveHandler = Cmi5ArchiveHandler()
        
        // Распаковываем архив
        let extraction: Cmi5ArchiveHandler.ExtractionResult
        do {
            extraction = try await archiveHandler.extractArchive(from: fileURL)
        } catch {
            throw ParsingError.invalidPackageFormat
        }
        
        defer {
            // Очищаем временные файлы после парсинга
            archiveHandler.cleanupPackage(packageId: extraction.packageId)
        }
        
        // Читаем манифест
        let manifestData = try Data(contentsOf: extraction.cmi5ManifestPath)
        let manifest = try parseManifest(from: manifestData)
        
        // Парсим активности
        let activities = try parseActivities(from: manifestData, baseURL: extraction.coursePath)
        
        // Вычисляем размер пакета
        let attributes = try fileManager.attributesOfItem(atPath: fileURL.path)
        let fileSize = attributes[.size] as? Int64 ?? 0
        
        // Создаем пакет
        let packageId = UUID()
        let activitiesWithPackageId = activities.map { activity in
            Cmi5Activity(
                id: UUID(),
                packageId: packageId,
                activityId: activity.activityId,
                title: activity.title,
                description: activity.description,
                launchUrl: activity.launchUrl,
                launchMethod: activity.launchMethod,
                moveOn: activity.moveOn,
                masteryScore: activity.masteryScore,
                activityType: activity.activityType,
                duration: activity.duration
            )
        }
        
        return Cmi5Package(
            id: packageId,
            packageId: manifest.identifier,
            title: manifest.title,
            description: manifest.description,
            courseId: nil,
            manifest: manifest,
            filePath: fileURL.path,
            uploadedAt: Date(),
            size: fileSize,
            uploadedBy: UUID(), // Should be current user
            version: manifest.version ?? "1.0",
            isValid: true,
            validationErrors: []
        )
    }
    
    /// Парсит манифест из данных с базовым URL
    public func parseManifest(_ data: Data, baseURL: URL) throws -> Cmi5Manifest {
        return try parseManifest(from: data)
    }
    
    /// Валидирует Cmi5 пакет
    /// - Parameter package: Пакет для валидации
    /// - Returns: Результат валидации
    public func validatePackage(_ package: Cmi5Package) -> ValidationResult {
        var errors: [String] = []
        var warnings: [String] = []
        
        // Проверка манифеста
        if package.manifest.identifier.isEmpty {
            errors.append("Идентификатор манифеста не может быть пустым")
        }
        
        if package.manifest.title.isEmpty {
            errors.append("Название курса не может быть пустым")
        }
        
        // Проверка активностей через блоки
        var activities: [Cmi5Activity] = []
        
        func collectActivities(from block: Cmi5Block) {
            activities.append(contentsOf: block.activities)
            for subBlock in block.blocks {
                collectActivities(from: subBlock)
            }
        }
        
        if let rootBlock = package.manifest.rootBlock {
            collectActivities(from: rootBlock)
        }
        
        if activities.isEmpty {
            warnings.append("Пакет не содержит учебных активностей")
        }
        
        for activity in activities {
            if activity.launchUrl.isEmpty {
                errors.append("Активность '\(activity.title)' не имеет URL для запуска")
            }
            
            if let score = activity.masteryScore, score < 0 || score > 1 {
                errors.append("Активность '\(activity.title)' имеет недопустимый проходной балл: \(score)")
            }
        }
        
        return ValidationResult(
            isValid: errors.isEmpty,
            errors: errors,
            warnings: warnings
        )
    }
    
    // MARK: - Private Methods
    
    private func parseManifest(from data: Data) throws -> Cmi5Manifest {
        let parser = XMLParser(data: data)
        let delegate = Cmi5ManifestParserDelegate()
        parser.delegate = delegate
        
        guard parser.parse() else {
            let error = parser.parserError?.localizedDescription ?? "Unknown error"
            throw ParsingError.xmlParsingError(error)
        }
        
        guard let manifest = delegate.manifest else {
            throw ParsingError.invalidManifest
        }
        
        return manifest
    }
    
    private func parseActivities(from data: Data, baseURL: URL) throws -> [Cmi5Activity] {
        let parser = XMLParser(data: data)
        let delegate = Cmi5ActivitiesParserDelegate(baseURL: baseURL)
        parser.delegate = delegate
        
        guard parser.parse() else {
            let error = parser.parserError?.localizedDescription ?? "Unknown error"
            throw ParsingError.xmlParsingError(error)
        }
        
        return delegate.activities
    }
}

// MARK: - Supporting Types

/// Результат валидации пакета
public struct ValidationResult {
    public let isValid: Bool
    public let errors: [String]
    public let warnings: [String]
}

// MARK: - XML Parser Delegates

/// Делегат для парсинга манифеста
private class Cmi5ManifestParserDelegate: NSObject, XMLParserDelegate {
    var manifest: Cmi5Manifest?
    private var currentElement = ""
    private var currentText = ""
    
    private var identifier = ""
    private var title = ""
    private var manifestDescription: String?
    private var courseId = ""
    private var courseTitle = ""
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        currentElement = elementName
        currentText = ""
        
        if elementName == "courseStructure" {
            identifier = attributeDict["id"] ?? ""
        } else if elementName == "course" {
            courseId = attributeDict["id"] ?? ""
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        currentText += string.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        switch elementName {
        case "title":
            if currentElement == "title" && title.isEmpty {
                title = currentText
            } else if currentElement == "title" && courseTitle.isEmpty {
                courseTitle = currentText
            }
        case "description":
            manifestDescription = currentText
        case "courseStructure":
            manifest = Cmi5Manifest(
                identifier: identifier,
                title: title.isEmpty ? courseTitle : title,
                description: manifestDescription,
                moreInfo: nil,
                vendor: nil,
                course: Cmi5Course(
                    id: courseId,
                    title: courseTitle.isEmpty ? nil : [Cmi5LangString(lang: "en", value: courseTitle)],
                    description: manifestDescription == nil ? nil : [Cmi5LangString(lang: "en", value: manifestDescription!)],
                    auCount: 0, // Will be updated after parsing activities
                    rootBlock: nil // Will be populated from activities structure
                )
            )
        default:
            break
        }
    }
}

/// Делегат для парсинга активностей
private class Cmi5ActivitiesParserDelegate: NSObject, XMLParserDelegate {
    var activities: [Cmi5Activity] = []
    private let baseURL: URL
    private var currentElement = ""
    private var currentText = ""
    
    private var currentActivity: [String: Any] = [:]
    
    init(baseURL: URL) {
        self.baseURL = baseURL
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        currentElement = elementName
        currentText = ""
        
        if elementName == "au" {
            currentActivity = [
                "id": attributeDict["id"] ?? UUID().uuidString,
                "launchMethod": attributeDict["launchMethod"] ?? "AnyWindow",
                "moveOn": attributeDict["moveOn"] ?? "CompletedOrPassed",
                "masteryScore": attributeDict["masteryScore"] as Any
            ]
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        currentText += string.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        switch elementName {
        case "title":
            currentActivity["title"] = currentText
        case "description":
            currentActivity["description"] = currentText
        case "url":
            currentActivity["url"] = currentText
        case "activityType":
            currentActivity["activityType"] = currentText
        case "au":
            // Создаем активность
            let activity = Cmi5Activity(
                id: UUID(),
                packageId: UUID(), // Будет установлен позже
                activityId: currentActivity["id"] as? String ?? "",
                title: currentActivity["title"] as? String ?? "Untitled",
                description: currentActivity["description"] as? String,
                launchUrl: currentActivity["url"] as? String ?? "",
                launchMethod: parseLaunchMethod(currentActivity["launchMethod"] as? String),
                moveOn: parseMoveOn(currentActivity["moveOn"] as? String),
                masteryScore: parseMasteryScore(currentActivity["masteryScore"]),
                activityType: currentActivity["activityType"] as? String ?? "http://adlnet.gov/expapi/activities/module",
                duration: nil
            )
            activities.append(activity)
            currentActivity = [:]
        default:
            break
        }
    }
    
    private func parseLaunchMethod(_ value: String?) -> Cmi5Activity.LaunchMethod {
        switch value {
        case "OwnWindow":
            return .ownWindow
        default:
            return .anyWindow
        }
    }
    
    private func parseMoveOn(_ value: String?) -> Cmi5Activity.MoveOnCriteria {
        switch value {
        case "Passed":
            return .passed
        case "Completed":
            return .completed
        case "CompletedAndPassed":
            return .completedAndPassed
        case "NotApplicable":
            return .notApplicable
        default:
            return .completedOrPassed
        }
    }
    
    private func parseMasteryScore(_ value: Any?) -> Double? {
        if let stringValue = value as? String {
            return Double(stringValue)
        }
        return nil
    }
}

 