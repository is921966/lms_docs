import Foundation

// MARK: - XAPIStatementBuilder

/// Builder для создания xAPI statements согласно спецификации Cmi5
final class XAPIStatementBuilder {
    
    // MARK: - Properties
    
    private var actor: XAPIActor?
    private var verb: XAPIVerb?
    private var object: XAPIObject?
    private var result: XAPIResult?
    private var context: XAPIContext?
    private var timestamp: Date?
    private var stored: Date?
    private var authority: XAPIActor?
    private var attachments: [XAPIAttachment]?
    
    // MARK: - Common Cmi5 Verbs
    
    enum Cmi5Verb {
        static let launched = XAPIVerb(
            id: "http://adlnet.gov/expapi/verbs/launched",
            display: ["en-US": "launched"]
        )
        
        static let initialized = XAPIVerb(
            id: "http://adlnet.gov/expapi/verbs/initialized",
            display: ["en-US": "initialized"]
        )
        
        static let completed = XAPIVerb(
            id: "http://adlnet.gov/expapi/verbs/completed",
            display: ["en-US": "completed"]
        )
        
        static let passed = XAPIVerb(
            id: "http://adlnet.gov/expapi/verbs/passed",
            display: ["en-US": "passed"]
        )
        
        static let failed = XAPIVerb(
            id: "http://adlnet.gov/expapi/verbs/failed",
            display: ["en-US": "failed"]
        )
        
        static let terminated = XAPIVerb(
            id: "http://adlnet.gov/expapi/verbs/terminated",
            display: ["en-US": "terminated"]
        )
        
        static let suspended = XAPIVerb(
            id: "http://adlnet.gov/expapi/verbs/suspended",
            display: ["en-US": "suspended"]
        )
        
        static let resumed = XAPIVerb(
            id: "http://adlnet.gov/expapi/verbs/resumed",
            display: ["en-US": "resumed"]
        )
        
        static let scored = XAPIVerb(
            id: "http://adlnet.gov/expapi/verbs/scored",
            display: ["en-US": "scored"]
        )
        
        static let progressed = XAPIVerb(
            id: "http://adlnet.gov/expapi/verbs/progressed",
            display: ["en-US": "progressed"]
        )
    }
    
    // MARK: - Builder Methods
    
    func setActor(userId: String, name: String? = nil) -> Self {
        self.actor = XAPIActor(
            name: name,
            account: XAPIAccount(
                name: userId,
                homePage: "https://lms.example.com"
            )
        )
        return self
    }
    
    func setActor(_ actor: XAPIActor) -> Self {
        self.actor = actor
        return self
    }
    
    func setVerb(_ verb: XAPIVerb) -> Self {
        self.verb = verb
        return self
    }
    
    func setActivity(id: String, name: String? = nil, description: String? = nil) -> Self {
        var definition: XAPIActivityDefinition?
        
        if name != nil || description != nil {
            definition = XAPIActivityDefinition(
                name: name.map { ["en-US": $0] },
                description: description.map { ["en-US": $0] },
                type: "http://adlnet.gov/expapi/activities/lesson"
            )
        }
        
        self.object = .activity(XAPIActivity(
            id: id,
            definition: definition
        ))
        return self
    }
    
    func setObject(_ object: XAPIObject) -> Self {
        self.object = object
        return self
    }
    
    func setResult(score: XAPIScore? = nil,
                   success: Bool? = nil,
                   completion: Bool? = nil,
                   duration: String? = nil,
                   response: String? = nil) -> Self {
        self.result = XAPIResult(
            score: score,
            success: success,
            completion: completion,
            response: response,
            duration: duration
        )
        return self
    }
    
    func setScore(raw: Double, min: Double = 0, max: Double = 100) -> Self {
        let scaled = (raw - min) / (max - min)
        let score = XAPIScore(scaled: scaled, raw: raw, min: min, max: max)
        
        if self.result != nil {
            self.result?.score = score
        } else {
            self.result = XAPIResult(score: score)
        }
        
        return self
    }
    
    func setContext(registration: String? = nil,
                    instructor: XAPIActor? = nil,
                    language: String? = nil,
                    contextActivities: XAPIContextActivities? = nil) -> Self {
        self.context = XAPIContext(
            registration: registration ?? UUID().uuidString,
            instructor: instructor,
            contextActivities: contextActivities,
            language: language
        )
        return self
    }
    
    func setCmi5Context(sessionId: String, registration: String) -> Self {
        // Add Cmi5 specific context
        let contextActivities = XAPIContextActivities(
            category: [
                XAPIActivity(
                    id: "https://w3id.org/xapi/cmi5/context/categories/cmi5",
                    definition: nil
                )
            ]
        )
        
        self.context = XAPIContext(
            registration: registration,
            contextActivities: contextActivities,
            extensions: [
                "https://w3id.org/xapi/cmi5/context/extensions/sessionid": AnyCodable(sessionId)
            ]
        )
        
        return self
    }
    
    func setTimestamp(_ date: Date = Date()) -> Self {
        self.timestamp = date
        return self
    }
    
    // MARK: - Build Method
    
    func build() throws -> XAPIStatement {
        guard let actor = actor else {
            throw BuilderError.missingActor
        }
        
        guard let verb = verb else {
            throw BuilderError.missingVerb
        }
        
        guard let object = object else {
            throw BuilderError.missingObject
        }
        
        return XAPIStatement(
            id: UUID().uuidString,
            actor: actor,
            verb: verb,
            object: object,
            result: result,
            context: context,
            timestamp: timestamp ?? Date(),
            stored: stored,
            authority: authority,
            attachments: attachments
        )
    }
    
    // MARK: - Convenience Factory Methods
    
    static func launchedStatement(userId: String,
                                  activityId: String,
                                  sessionId: String,
                                  registration: String) throws -> XAPIStatement {
        return try XAPIStatementBuilder()
            .setActor(userId: userId)
            .setVerb(Cmi5Verb.launched)
            .setActivity(id: activityId)
            .setCmi5Context(sessionId: sessionId, registration: registration)
            .setTimestamp()
            .build()
    }
    
    static func initializedStatement(userId: String,
                                     activityId: String,
                                     sessionId: String,
                                     registration: String) throws -> XAPIStatement {
        return try XAPIStatementBuilder()
            .setActor(userId: userId)
            .setVerb(Cmi5Verb.initialized)
            .setActivity(id: activityId)
            .setCmi5Context(sessionId: sessionId, registration: registration)
            .setTimestamp()
            .build()
    }
    
    static func completedStatement(userId: String,
                                   activityId: String,
                                   sessionId: String,
                                   registration: String,
                                   duration: String? = nil) throws -> XAPIStatement {
        return try XAPIStatementBuilder()
            .setActor(userId: userId)
            .setVerb(Cmi5Verb.completed)
            .setActivity(id: activityId)
            .setResult(completion: true, duration: duration)
            .setCmi5Context(sessionId: sessionId, registration: registration)
            .setTimestamp()
            .build()
    }
    
    static func passedStatement(userId: String,
                                activityId: String,
                                sessionId: String,
                                registration: String,
                                score: Double,
                                duration: String? = nil) throws -> XAPIStatement {
        return try XAPIStatementBuilder()
            .setActor(userId: userId)
            .setVerb(Cmi5Verb.passed)
            .setActivity(id: activityId)
            .setScore(raw: score)
            .setResult(success: true, completion: true, duration: duration)
            .setCmi5Context(sessionId: sessionId, registration: registration)
            .setTimestamp()
            .build()
    }
    
    static func failedStatement(userId: String,
                                activityId: String,
                                sessionId: String,
                                registration: String,
                                score: Double,
                                duration: String? = nil) throws -> XAPIStatement {
        return try XAPIStatementBuilder()
            .setActor(userId: userId)
            .setVerb(Cmi5Verb.failed)
            .setActivity(id: activityId)
            .setScore(raw: score)
            .setResult(success: false, completion: true, duration: duration)
            .setCmi5Context(sessionId: sessionId, registration: registration)
            .setTimestamp()
            .build()
    }
    
    static func terminatedStatement(userId: String,
                                    activityId: String,
                                    sessionId: String,
                                    registration: String,
                                    duration: String? = nil) throws -> XAPIStatement {
        return try XAPIStatementBuilder()
            .setActor(userId: userId)
            .setVerb(Cmi5Verb.terminated)
            .setActivity(id: activityId)
            .setResult(duration: duration)
            .setCmi5Context(sessionId: sessionId, registration: registration)
            .setTimestamp()
            .build()
    }
    
    // MARK: - Error Types
    
    enum BuilderError: LocalizedError {
        case missingActor
        case missingVerb
        case missingObject
        
        var errorDescription: String? {
            switch self {
            case .missingActor:
                return "Actor is required for xAPI statement"
            case .missingVerb:
                return "Verb is required for xAPI statement"
            case .missingObject:
                return "Object is required for xAPI statement"
            }
        }
    }
}

// MARK: - Duration Helper

extension XAPIStatementBuilder {
    /// Converts seconds to ISO 8601 duration format
    static func durationString(seconds: TimeInterval) -> String {
        let hours = Int(seconds) / 3600
        let minutes = Int(seconds) % 3600 / 60
        let secs = Int(seconds) % 60
        
        var duration = "PT"
        if hours > 0 {
            duration += "\(hours)H"
        }
        if minutes > 0 {
            duration += "\(minutes)M"
        }
        if secs > 0 || (hours == 0 && minutes == 0) {
            duration += "\(secs)S"
        }
        
        return duration
    }
} 