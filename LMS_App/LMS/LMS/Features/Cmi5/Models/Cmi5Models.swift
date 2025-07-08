//
//  Cmi5Models.swift
//  LMS
//
//  Created on Sprint 40 Day 1 - Cmi5 Integration
//

import Foundation

// MARK: - Cmi5Package

/// Представляет импортированный Cmi5 пакет
public struct Cmi5Package: Identifiable, Codable {
    public let id: UUID
    public let courseId: UUID?
    public let packageName: String
    public let packageVersion: String?
    public let manifest: Cmi5Manifest
    public let activities: [Cmi5Activity]
    public let uploadedAt: Date
    public let uploadedBy: UUID
    public let fileSize: Int64
    public var status: PackageStatus
    
    public enum PackageStatus: String, Codable, CaseIterable {
        case processing = "processing"
        case valid = "valid"
        case invalid = "invalid"
        case archived = "archived"
        
        var localizedName: String {
            switch self {
            case .processing: return "Обрабатывается"
            case .valid: return "Валидный"
            case .invalid: return "Невалидный"
            case .archived: return "В архиве"
            }
        }
    }
    
    /// Форматированный размер файла
    public var formattedFileSize: String {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        // Форматируем в байтах сначала
        let bytes = Double(fileSize)
        
        // Ручное форматирование для консистентности
        switch bytes {
        case 0..<1024:
            return "\(Int(bytes)) B"
        case 1024..<(1024 * 1024):
            let kb = bytes / 1024
            if kb.truncatingRemainder(dividingBy: 1) == 0 {
                return "\(Int(kb)) KB"
            } else {
                return String(format: "%.1f KB", kb)
            }
        case (1024 * 1024)..<(1024 * 1024 * 1024):
            let mb = bytes / (1024 * 1024)
            if mb.truncatingRemainder(dividingBy: 1) == 0 {
                return "\(Int(mb)) MB"
            } else {
                return String(format: "%.1f MB", mb)
            }
        default:
            let gb = bytes / (1024 * 1024 * 1024)
            if gb.truncatingRemainder(dividingBy: 1) == 0 {
                return "\(Int(gb)) GB"
            } else {
                return String(format: "%.1f GB", gb)
            }
        }
    }
    
    /// Проверка валидности пакета
    public var isValid: Bool {
        return status == .valid && 
               !packageName.isEmpty && 
               fileSize > 0 &&
               !activities.isEmpty &&
               !manifest.identifier.isEmpty
    }
    
    /// Ошибки валидации
    public func validationErrors() -> [String]? {
        var errors: [String] = []
        
        if packageName.isEmpty {
            errors.append("Имя пакета не может быть пустым")
        }
        
        if fileSize <= 0 {
            errors.append("Размер файла должен быть больше 0")
        }
        
        if activities.isEmpty && status == .valid {
            errors.append("Валидный пакет должен содержать активности")
        }
        
        if manifest.identifier.isEmpty {
            errors.append("Идентификатор манифеста не может быть пустым")
        }
        
        return errors.isEmpty ? nil : errors
    }
    
    /// Инициализатор для тестов и создания
    public init(
        id: UUID = UUID(),
        courseId: UUID? = nil,
        packageName: String,
        packageVersion: String? = nil,
        manifest: Cmi5Manifest,
        activities: [Cmi5Activity] = [],
        uploadedAt: Date = Date(),
        uploadedBy: UUID,
        fileSize: Int64,
        status: PackageStatus = .processing
    ) {
        self.id = id
        self.courseId = courseId
        self.packageName = packageName
        self.packageVersion = packageVersion
        self.manifest = manifest
        self.activities = activities
        self.uploadedAt = uploadedAt
        self.uploadedBy = uploadedBy
        self.fileSize = fileSize
        self.status = status
    }
}

// MARK: - Cmi5Activity

/// Отдельная учебная активность в Cmi5 пакете
public struct Cmi5Activity: Identifiable, Codable {
    public let id: UUID
    public let packageId: UUID
    public let activityId: String
    public let title: String
    public let description: String?
    public let launchUrl: String
    public let launchMethod: LaunchMethod
    public let moveOn: MoveOnCriteria
    public let masteryScore: Double?
    public let activityType: String
    public let duration: String? // ISO 8601
    
    public enum LaunchMethod: String, Codable, CaseIterable {
        case ownWindow = "OwnWindow"
        case anyWindow = "AnyWindow"
        
        var localizedName: String {
            switch self {
            case .ownWindow: return "В отдельном окне"
            case .anyWindow: return "В любом окне"
            }
        }
    }
    
    public enum MoveOnCriteria: String, Codable, CaseIterable {
        case passed = "Passed"
        case completed = "Completed"
        case completedAndPassed = "CompletedAndPassed"
        case completedOrPassed = "CompletedOrPassed"
        case notApplicable = "NotApplicable"
        
        var localizedName: String {
            switch self {
            case .passed: return "Пройдено"
            case .completed: return "Завершено"
            case .completedAndPassed: return "Завершено и пройдено"
            case .completedOrPassed: return "Завершено или пройдено"
            case .notApplicable: return "Не применимо"
            }
        }
    }
    
    /// Инициализатор для тестов и создания
    public init(
        id: UUID = UUID(),
        packageId: UUID,
        activityId: String,
        title: String,
        description: String? = nil,
        launchUrl: String,
        launchMethod: LaunchMethod,
        moveOn: MoveOnCriteria,
        masteryScore: Double? = nil,
        activityType: String,
        duration: String? = nil
    ) {
        self.id = id
        self.packageId = packageId
        self.activityId = activityId
        self.title = title
        self.description = description
        self.launchUrl = launchUrl
        self.launchMethod = launchMethod
        self.moveOn = moveOn
        self.masteryScore = masteryScore
        self.activityType = activityType
        self.duration = duration
    }
}

// MARK: - Cmi5Manifest

/// Манифест Cmi5 пакета
public struct Cmi5Manifest: Codable {
    public let identifier: String
    public let title: String
    public let description: String?
    public let moreInfo: String?
    public let vendor: Cmi5Vendor?
    public let version: String?
    public var course: Cmi5Course
    
    public init(
        identifier: String,
        title: String,
        description: String? = nil,
        moreInfo: String? = nil,
        vendor: Cmi5Vendor? = nil,
        version: String? = nil,
        course: Cmi5Course
    ) {
        self.identifier = identifier
        self.title = title
        self.description = description
        self.moreInfo = moreInfo
        self.vendor = vendor
        self.version = version
        self.course = course
    }
}

// MARK: - Cmi5Course

/// Курс в манифесте Cmi5
public struct Cmi5Course: Codable {
    public let id: String
    public let title: String
    public let description: String?
    public var auCount: Int // Assignable Units count
    
    public init(
        id: String,
        title: String,
        description: String? = nil,
        auCount: Int
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.auCount = auCount
    }
}

// MARK: - Cmi5Vendor

/// Информация о поставщике контента
public struct Cmi5Vendor: Codable {
    public let name: String
    public let contact: String?
    public let url: String?
    
    public init(
        name: String,
        contact: String? = nil,
        url: String? = nil
    ) {
        self.name = name
        self.contact = contact
        self.url = url
    }
}

// MARK: - Helper Extensions

/// Расширение для создания пустого манифеста
public extension Cmi5Manifest {
    static func empty() -> Cmi5Manifest {
        return Cmi5Manifest(
            identifier: "",
            title: "",
            description: nil,
            moreInfo: nil,
            vendor: nil,
            version: nil,
            course: Cmi5Course(
                id: "",
                title: "",
                description: nil,
                auCount: 0
            )
        )
    }
}

// MARK: - Note about xAPI Models

// xAPI models (Actor, Verb, Object, Statement, etc.) are defined in XAPIModels.swift
// This file only contains Cmi5-specific models 