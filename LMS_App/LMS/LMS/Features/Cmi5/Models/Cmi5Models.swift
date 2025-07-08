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
    public let packageId: String
    public let title: String
    public let description: String?
    public var courseId: UUID?
    public let manifest: Cmi5Manifest
    public let filePath: String
    public let uploadedAt: Date
    public let size: Int64
    public var uploadedBy: UUID
    public let version: String
    public let isValid: Bool
    public let validationErrors: [String]
    
    public init(
        id: UUID = UUID(),
        packageId: String,
        title: String,
        description: String? = nil,
        courseId: UUID? = nil,
        manifest: Cmi5Manifest,
        filePath: String,
        uploadedAt: Date = Date(),
        size: Int64,
        uploadedBy: UUID,
        version: String = "1.0",
        isValid: Bool = true,
        validationErrors: [String] = []
    ) {
        self.id = id
        self.packageId = packageId
        self.title = title
        self.description = description
        self.courseId = courseId
        self.manifest = manifest
        self.filePath = filePath
        self.uploadedAt = uploadedAt
        self.size = size
        self.uploadedBy = uploadedBy
        self.version = version
        self.isValid = isValid
        self.validationErrors = validationErrors
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