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
    public let id: UUID
    public let actor: XAPIActor
    public let verb: XAPIVerb
    public let object: XAPIObject
    public let result: XAPIResult?
    public let context: XAPIContext?
    public let timestamp: Date
    public let stored: Date?
    public let authority: XAPIActor?
    public let version: String?
    public let attachments: [XAPIAttachment]?
    
    public init(
        id: UUID = UUID(),
        actor: XAPIActor,
        verb: XAPIVerb,
        object: XAPIObject,
        result: XAPIResult? = nil,
        context: XAPIContext? = nil,
        timestamp: Date = Date(),
        stored: Date? = nil,
        authority: XAPIActor? = nil,
        version: String? = "1.0.3",
        attachments: [XAPIAttachment]? = nil
    ) {
        self.id = id
        self.actor = actor
        self.verb = verb
        self.object = object
        self.result = result
        self.context = context
        self.timestamp = timestamp
        self.stored = stored
        self.authority = authority
        self.version = version
        self.attachments = attachments
    }
}

// MARK: - xAPI Actor

/// Представляет актора (пользователя) в xAPI
public struct XAPIActor: Codable {
    public let objectType: String?
    public let name: String?
    public let mbox: String?
    public let mbox_sha1sum: String?
    public let openid: String?
    public let account: XAPIAccount?
    public let member: [XAPIActor]? // For groups
    
    public init(
        objectType: String? = "Agent",
        name: String? = nil,
        mbox: String? = nil,
        mbox_sha1sum: String? = nil,
        openid: String? = nil,
        account: XAPIAccount? = nil,
        member: [XAPIActor]? = nil
    ) {
        self.objectType = objectType
        self.name = name
        self.mbox = mbox
        self.mbox_sha1sum = mbox_sha1sum
        self.openid = openid
        self.account = account
        self.member = member
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
    public let objectType: String?
    public let id: String
    public let definition: XAPIActivityDefinition?
    
    public init(
        objectType: String? = "Activity",
        id: String,
        definition: XAPIActivityDefinition? = nil
    ) {
        self.objectType = objectType
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
    public let score: XAPIScore?
    public let success: Bool?
    public let completion: Bool?
    public let response: String?
    public let duration: String? // ISO 8601 Duration
    public let extensions: [String: AnyCodable]?
    
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
    
    public init(
        scaled: Double? = nil,
        raw: Double? = nil,
        min: Double? = nil,
        max: Double? = nil
    ) {
        self.scaled = scaled
        self.raw = raw
        self.min = min
        self.max = max
    }
    
    /// Валидация scaled значения
    public var isValid: Bool {
        guard let scaled = scaled else { return true }
        return scaled >= -1.0 && scaled <= 1.0
    }
}

// MARK: - xAPI Context

/// Контекст выполнения действия
public struct XAPIContext: Codable {
    public let registration: UUID?
    public let instructor: XAPIActor?
    public let team: XAPIActor?
    public let contextActivities: XAPIContextActivities?
    public let revision: String?
    public let platform: String?
    public let language: String?
    public let statement: XAPIStatementRef?
    public let extensions: [String: AnyCodable]?
    
    public init(
        registration: UUID? = nil,
        instructor: XAPIActor? = nil,
        team: XAPIActor? = nil,
        contextActivities: XAPIContextActivities? = nil,
        revision: String? = nil,
        platform: String? = nil,
        language: String? = nil,
        statement: XAPIStatementRef? = nil,
        extensions: [String: AnyCodable]? = nil
    ) {
        self.registration = registration
        self.instructor = instructor
        self.team = team
        self.contextActivities = contextActivities
        self.revision = revision
        self.platform = platform
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

// MARK: - Helper Type for Extensions

/// Тип для хранения произвольных расширений
public struct AnyCodable: Codable {
    public let value: Any
    
    public init(_ value: Any) {
        self.value = value
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if container.decodeNil() {
            self.value = NSNull()
        } else if let bool = try? container.decode(Bool.self) {
            self.value = bool
        } else if let int = try? container.decode(Int.self) {
            self.value = int
        } else if let double = try? container.decode(Double.self) {
            self.value = double
        } else if let string = try? container.decode(String.self) {
            self.value = string
        } else if let array = try? container.decode([AnyCodable].self) {
            self.value = array.map { $0.value }
        } else if let dictionary = try? container.decode([String: AnyCodable].self) {
            self.value = dictionary.mapValues { $0.value }
        } else {
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Cannot decode AnyCodable"
            )
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        
        switch value {
        case is NSNull:
            try container.encodeNil()
        case let bool as Bool:
            try container.encode(bool)
        case let int as Int:
            try container.encode(int)
        case let double as Double:
            try container.encode(double)
        case let string as String:
            try container.encode(string)
        case let array as [Any]:
            try container.encode(array.map { AnyCodable($0) })
        case let dictionary as [String: Any]:
            try container.encode(dictionary.mapValues { AnyCodable($0) })
        default:
            throw EncodingError.invalidValue(
                value,
                EncodingError.Context(
                    codingPath: [],
                    debugDescription: "Cannot encode AnyCodable"
                )
            )
        }
    }
} 