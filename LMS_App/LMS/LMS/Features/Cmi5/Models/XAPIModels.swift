//
//  XAPIModels.swift
//  LMS
//
//  Created on Sprint 40 Day 2 - xAPI Integration
//

import Foundation

// MARK: - xAPI Statement

/// Представляет xAPI Statement - основную единицу данных в xAPI
public struct XAPIStatement: Codable, Identifiable {
    public var id: String?
    public let actor: XAPIActor
    public let verb: XAPIVerb
    public let object: XAPIObject
    public var result: XAPIResult?
    public var context: XAPIContext?
    public var timestamp: Date?
    public var stored: Date?
    public var authority: XAPIActor?
    public var attachments: [XAPIAttachment]?
    
    public init(
        id: String? = nil,
        actor: XAPIActor,
        verb: XAPIVerb,
        object: XAPIObject,
        result: XAPIResult? = nil,
        context: XAPIContext? = nil,
        timestamp: Date? = nil,
        stored: Date? = nil,
        authority: XAPIActor? = nil,
        attachments: [XAPIAttachment]? = nil
    ) {
        self.id = id ?? UUID().uuidString
        self.actor = actor
        self.verb = verb
        self.object = object
        self.result = result
        self.context = context
        self.timestamp = timestamp ?? Date()
        self.stored = stored
        self.authority = authority
        self.attachments = attachments
    }
}

// MARK: - xAPI Actor

/// Представляет актора (пользователя) в xAPI
public struct XAPIActor: Codable {
    public let name: String?
    public let mbox: String?
    public let mbox_sha1sum: String?
    public let openid: String?
    public let account: XAPIAccount?
    
    public init(
        name: String? = nil,
        mbox: String? = nil,
        mbox_sha1sum: String? = nil,
        openid: String? = nil,
        account: XAPIAccount? = nil
    ) {
        self.name = name
        self.mbox = mbox
        self.mbox_sha1sum = mbox_sha1sum
        self.openid = openid
        self.account = account
    }
    
    private enum CodingKeys: String, CodingKey {
        case name
        case mbox
        case mbox_sha1sum = "mbox_sha1sum"
        case openid
        case account
    }
}

/// Аккаунт пользователя в системе
public struct XAPIAccount: Codable {
    public let name: String
    public let homePage: String
    
    public init(name: String, homePage: String) {
        self.name = name
        self.homePage = homePage
    }
}

// MARK: - xAPI Verb

/// Представляет действие в xAPI
public struct XAPIVerb: Codable {
    public let id: String
    public let display: [String: String]
    
    public init(id: String, display: [String: String]) {
        self.id = id
        self.display = display
    }
    
    // Предопределенные глаголы
    public static let completed = XAPIVerb(
        id: "http://adlnet.gov/expapi/verbs/completed",
        display: ["en-US": "completed", "ru-RU": "завершил"]
    )
    
    public static let passed = XAPIVerb(
        id: "http://adlnet.gov/expapi/verbs/passed",
        display: ["en-US": "passed", "ru-RU": "прошел"]
    )
    
    public static let failed = XAPIVerb(
        id: "http://adlnet.gov/expapi/verbs/failed",
        display: ["en-US": "failed", "ru-RU": "провалил"]
    )
    
    public static let attempted = XAPIVerb(
        id: "http://adlnet.gov/expapi/verbs/attempted",
        display: ["en-US": "attempted", "ru-RU": "попытался"]
    )
    
    public static let launched = XAPIVerb(
        id: "http://adlnet.gov/expapi/verbs/launched",
        display: ["en-US": "launched", "ru-RU": "запустил"]
    )
    
    public static let terminated = XAPIVerb(
        id: "http://adlnet.gov/expapi/verbs/terminated",
        display: ["en-US": "terminated", "ru-RU": "завершил"]
    )
    
    public static let suspended = XAPIVerb(
        id: "http://adlnet.gov/expapi/verbs/suspended",
        display: ["en-US": "suspended", "ru-RU": "приостановил"]
    )
    
    public static let resumed = XAPIVerb(
        id: "http://adlnet.gov/expapi/verbs/resumed",
        display: ["en-US": "resumed", "ru-RU": "возобновил"]
    )
}

// MARK: - xAPI Object

/// Представляет объект действия в xAPI
public enum XAPIObject: Codable {
    case activity(XAPIActivity)
    case agent(XAPIActor)
    case group(XAPIActor)
    case statementRef(XAPIStatementRef)
    case subStatement(XAPISubStatement)
    
    private enum CodingKeys: String, CodingKey {
        case objectType
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let objectType = try container.decodeIfPresent(String.self, forKey: .objectType)
        
        switch objectType {
        case "Agent":
            self = .agent(try XAPIActor(from: decoder))
        case "Group":
            self = .group(try XAPIActor(from: decoder))
        case "StatementRef":
            self = .statementRef(try XAPIStatementRef(from: decoder))
        case "SubStatement":
            self = .subStatement(try XAPISubStatement(from: decoder))
        default:
            self = .activity(try XAPIActivity(from: decoder))
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        switch self {
        case .activity(let activity):
            try activity.encode(to: encoder)
        case .agent(let actor), .group(let actor):
            try actor.encode(to: encoder)
        case .statementRef(let ref):
            try ref.encode(to: encoder)
        case .subStatement(let sub):
            try sub.encode(to: encoder)
        }
    }
}

/// Активность в xAPI (курс, урок, тест и т.д.)
public struct XAPIActivity: Codable {
    public let objectType: String = "Activity"
    public let id: String
    public let definition: XAPIActivityDefinition?
    
    public init(id: String, definition: XAPIActivityDefinition?) {
        self.id = id
        self.definition = definition
    }
}

/// Определение активности
public struct XAPIActivityDefinition: Codable {
    public let name: [String: String]?
    public let description: [String: String]?
    public let type: String?
    public let moreInfo: String?
    public let extensions: [String: AnyCodable]?
    
    public init(
        name: [String: String]? = nil,
        description: [String: String]? = nil,
        type: String? = nil,
        moreInfo: String? = nil,
        extensions: [String: AnyCodable]? = nil
    ) {
        self.name = name
        self.description = description
        self.type = type
        self.moreInfo = moreInfo
        self.extensions = extensions
    }
}

/// Ссылка на другой statement
public struct XAPIStatementRef: Codable {
    public let objectType: String
    public let id: UUID
    
    public init(id: UUID) {
        self.objectType = "StatementRef"
        self.id = id
    }
}

/// Вложенный statement
public struct XAPISubStatement: Codable {
    public let objectType: String
    public let actor: XAPIActor
    public let verb: XAPIVerb
    public let object: XAPIActivity // Changed from XAPIObject to avoid recursion
    
    public init(actor: XAPIActor, verb: XAPIVerb, object: XAPIActivity) {
        self.objectType = "SubStatement"
        self.actor = actor
        self.verb = verb
        self.object = object
    }
}

// MARK: - xAPI Result

/// Результат действия
public struct XAPIResult: Codable {
    public var score: XAPIScore?
    public var success: Bool?
    public var completion: Bool?
    public var response: String?
    public var duration: String? // ISO 8601 Duration
    public var extensions: [String: AnyCodable]?
    
    public init(
        score: XAPIScore? = nil,
        success: Bool? = nil,
        completion: Bool? = nil,
        response: String? = nil,
        duration: String? = nil,
        extensions: [String: AnyCodable]? = nil
    ) {
        self.score = score
        self.success = success
        self.completion = completion
        self.response = response
        self.duration = duration
        self.extensions = extensions
    }
}

/// Оценка
public struct XAPIScore: Codable {
    public let scaled: Double? // -1.0 to 1.0
    public let raw: Double?
    public let min: Double?
    public let max: Double?
    
    public init(scaled: Double? = nil, raw: Double? = nil, min: Double? = nil, max: Double? = nil) {
        self.scaled = scaled
        self.raw = raw
        self.min = min
        self.max = max
    }
    
    // Validation
    public var isValid: Bool {
        if let scaled = scaled, (scaled < -1.0 || scaled > 1.0) {
            return false
        }
        if let raw = raw, let min = min, let max = max {
            return raw >= min && raw <= max && min < max
        }
        return true
    }
}

// MARK: - xAPI Context

/// Контекст выполнения действия
public struct XAPIContext: Codable {
    public var registration: String?
    public var instructor: XAPIActor?
    public var team: XAPIActor?
    public var contextActivities: XAPIContextActivities?
    public var language: String?
    public var statement: XAPIStatementRef?
    public var extensions: [String: AnyCodable]?
    
    public init(
        registration: String? = nil,
        instructor: XAPIActor? = nil,
        team: XAPIActor? = nil,
        contextActivities: XAPIContextActivities? = nil,
        language: String? = nil,
        statement: XAPIStatementRef? = nil,
        extensions: [String: AnyCodable]? = nil
    ) {
        self.registration = registration
        self.instructor = instructor
        self.team = team
        self.contextActivities = contextActivities
        self.language = language
        self.statement = statement
        self.extensions = extensions
    }
}

/// Контекстные активности
public struct XAPIContextActivities: Codable {
    public let parent: [XAPIActivity]?
    public let grouping: [XAPIActivity]?
    public let category: [XAPIActivity]?
    public let other: [XAPIActivity]?
    
    public init(
        parent: [XAPIActivity]? = nil,
        grouping: [XAPIActivity]? = nil,
        category: [XAPIActivity]? = nil,
        other: [XAPIActivity]? = nil
    ) {
        self.parent = parent
        self.grouping = grouping
        self.category = category
        self.other = other
    }
}

// MARK: - xAPI Attachment

/// Вложение в statement
public struct XAPIAttachment: Codable {
    public let usageType: String
    public let display: [String: String]
    public let description: [String: String]?
    public let contentType: String
    public let length: Int
    public let sha2: String
    public let fileUrl: String?
    
    public init(
        usageType: String,
        display: [String: String],
        description: [String: String]? = nil,
        contentType: String,
        length: Int,
        sha2: String,
        fileUrl: String? = nil
    ) {
        self.usageType = usageType
        self.display = display
        self.description = description
        self.contentType = contentType
        self.length = length
        self.sha2 = sha2
        self.fileUrl = fileUrl
    }
} 