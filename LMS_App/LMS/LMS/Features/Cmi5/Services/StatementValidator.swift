//
//  StatementValidator.swift
//  LMS
//
//  Created on Sprint 42 Day 1 - xAPI Statement Validation
//

import Foundation

/// Валидатор для xAPI statements согласно спецификации
public final class StatementValidator {
    
    // MARK: - Types
    
    public enum ValidationError: String, CaseIterable {
        // Actor errors
        case missingActorIdentifier = "Actor must have at least one identifier"
        case invalidMboxFormat = "Mbox must be in mailto: format"
        case invalidMboxHash = "Mbox SHA1 hash must be valid"
        case invalidOpenID = "OpenID must be a valid IRI"
        case invalidAccountHomePage = "Account homepage must be a valid IRI"
        
        // Verb errors
        case invalidVerbIRI = "Verb ID must be a valid IRI"
        case missingVerbDisplay = "Verb should have display name"
        
        // Object errors
        case invalidActivityIRI = "Activity ID must be a valid IRI"
        case invalidActivityType = "Activity type must be a valid IRI"
        
        // Result errors
        case invalidScaledScore = "Scaled score must be between -1.0 and 1.0"
        case invalidRawScore = "Raw score must be between min and max"
        case invalidMinMaxScore = "Min score must be less than max score"
        case invalidDurationFormat = "Duration must be in ISO 8601 format"
        
        // Context errors
        case invalidLanguageCode = "Language must be a valid ISO code"
        case invalidRegistration = "Registration must be a valid UUID"
        
        // Statement errors
        case futureTimestamp = "Statement timestamp cannot be in the future"
        case invalidStatementId = "Statement ID must be a valid UUID"
        
        // Cmi5 specific
        case missingCmi5Registration = "Cmi5 statements must have registration"
        case missingCmi5Category = "Cmi5 statements must have category"
        case invalidCmi5Verb = "Invalid verb for Cmi5 context"
    }
    
    public enum ValidationWarning: String {
        case missingVerbDisplay = "Verb display name is recommended"
        case missingActivityDefinition = "Activity definition is recommended"
        case missingResultDuration = "Duration is recommended for completed statements"
        case deprecatedField = "Field is deprecated in latest specification"
    }
    
    public struct ValidationResult {
        public let isValid: Bool
        public let errors: [ValidationError]
        public let warnings: [ValidationWarning]
        
        public static let valid = ValidationResult(
            isValid: true,
            errors: [],
            warnings: []
        )
    }
    
    // MARK: - Constants
    
    private let validLanguageCodePattern = #"^[a-z]{2,3}(-[A-Z]{2})?$"#
    private let validIRIPattern = #"^https?://[\w\-._~:/?#[\]@!$&'()*+,;=.]+$"#
    private let validUUIDPattern = #"^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$"#
    private let validISO8601DurationPattern = #"^P(?:\d+Y)?(?:\d+M)?(?:\d+D)?(?:T(?:\d+H)?(?:\d+M)?(?:\d+(?:\.\d+)?S)?)?$"#
    
    // MARK: - Public Methods
    
    public func validateStatement(_ statement: XAPIStatement) -> ValidationResult {
        var errors: [ValidationError] = []
        var warnings: [ValidationWarning] = []
        
        // Validate components
        let actorResult = validateActor(statement.actor)
        errors.append(contentsOf: actorResult.errors)
        warnings.append(contentsOf: actorResult.warnings)
        
        let verbResult = validateVerb(statement.verb)
        errors.append(contentsOf: verbResult.errors)
        warnings.append(contentsOf: verbResult.warnings)
        
        let objectResult = validateObject(statement.object)
        errors.append(contentsOf: objectResult.errors)
        warnings.append(contentsOf: objectResult.warnings)
        
        if let result = statement.result {
            let resultResult = validateResult(result)
            errors.append(contentsOf: resultResult.errors)
            warnings.append(contentsOf: resultResult.warnings)
        }
        
        if let context = statement.context {
            let contextResult = validateContext(context)
            errors.append(contentsOf: contextResult.errors)
            warnings.append(contentsOf: contextResult.warnings)
        }
        
        // Validate statement-level rules
        if let id = statement.id, !isValidUUID(id) {
            errors.append(.invalidStatementId)
        }
        
        if let timestamp = statement.timestamp, timestamp > Date() {
            errors.append(.futureTimestamp)
        }
        
        // Add warnings for best practices
        if statement.verb.id == XAPIVerb.completed.id && statement.result?.duration == nil {
            warnings.append(.missingResultDuration)
        }
        
        return ValidationResult(
            isValid: errors.isEmpty,
            errors: errors,
            warnings: warnings
        )
    }
    
    public func validateCmi5Statement(_ statement: XAPIStatement) -> ValidationResult {
        var result = validateStatement(statement)
        var errors = result.errors
        
        // Cmi5 specific validation
        guard let context = statement.context else {
            errors.append(.missingCmi5Registration)
            return ValidationResult(isValid: false, errors: errors, warnings: result.warnings)
        }
        
        if context.registration == nil {
            errors.append(.missingCmi5Registration)
        }
        
        // Check for cmi5 category
        let hasCmi5Category = context.contextActivities?.category?.contains { activity in
            activity.id == "https://w3id.org/xapi/cmi5/context/categories/cmi5"
        } ?? false
        
        if !hasCmi5Category {
            errors.append(.missingCmi5Category)
        }
        
        // Validate allowed verbs for cmi5
        let allowedCmi5Verbs = [
            "http://adlnet.gov/expapi/verbs/launched",
            "http://adlnet.gov/expapi/verbs/initialized",
            "http://adlnet.gov/expapi/verbs/completed",
            "http://adlnet.gov/expapi/verbs/passed",
            "http://adlnet.gov/expapi/verbs/failed",
            "http://adlnet.gov/expapi/verbs/abandoned",
            "http://adlnet.gov/expapi/verbs/waived",
            "http://adlnet.gov/expapi/verbs/terminated",
            "http://adlnet.gov/expapi/verbs/satisfied"
        ]
        
        if !allowedCmi5Verbs.contains(statement.verb.id) {
            errors.append(.invalidCmi5Verb)
        }
        
        return ValidationResult(
            isValid: errors.isEmpty,
            errors: errors,
            warnings: result.warnings
        )
    }
    
    // MARK: - Component Validation
    
    public func validateActor(_ actor: XAPIActor) -> ValidationResult {
        var errors: [ValidationError] = []
        
        // Must have at least one identifier
        let hasIdentifier = actor.mbox != nil ||
                           actor.mbox_sha1sum != nil ||
                           actor.openid != nil ||
                           actor.account != nil
        
        if !hasIdentifier {
            errors.append(.missingActorIdentifier)
        }
        
        // Validate mbox format
        if let mbox = actor.mbox {
            if !mbox.hasPrefix("mailto:") || !mbox.contains("@") {
                errors.append(.invalidMboxFormat)
            }
        }
        
        // Validate mbox_sha1sum
        if let hash = actor.mbox_sha1sum {
            if hash.count != 40 || !hash.allSatisfy({ $0.isHexDigit }) {
                errors.append(.invalidMboxHash)
            }
        }
        
        // Validate openid
        if let openid = actor.openid {
            if !isValidIRI(openid) {
                errors.append(.invalidOpenID)
            }
        }
        
        // Validate account
        if let account = actor.account {
            if !isValidIRI(account.homePage) {
                errors.append(.invalidAccountHomePage)
            }
        }
        
        return ValidationResult(
            isValid: errors.isEmpty,
            errors: errors,
            warnings: []
        )
    }
    
    public func validateVerb(_ verb: XAPIVerb) -> ValidationResult {
        var errors: [ValidationError] = []
        var warnings: [ValidationWarning] = []
        
        // Validate IRI
        if !isValidIRI(verb.id) {
            errors.append(.invalidVerbIRI)
        }
        
        // Check display
        if verb.display.isEmpty {
            warnings.append(.missingVerbDisplay)
        }
        
        return ValidationResult(
            isValid: errors.isEmpty,
            errors: errors,
            warnings: warnings
        )
    }
    
    public func validateObject(_ object: XAPIObject) -> ValidationResult {
        switch object {
        case .activity(let activity):
            return validateActivity(activity)
        case .agent(let actor), .group(let actor):
            return validateActor(actor)
        case .statementRef(let ref):
            return validateStatementRef(ref)
        case .subStatement(let sub):
            return validateSubStatement(sub)
        }
    }
    
    public func validateResult(_ result: XAPIResult) -> ValidationResult {
        var errors: [ValidationError] = []
        
        // Validate score
        if let score = result.score {
            let scoreErrors = validateScore(score)
            errors.append(contentsOf: scoreErrors)
        }
        
        // Validate duration
        if let duration = result.duration {
            if !isValidISO8601Duration(duration) {
                errors.append(.invalidDurationFormat)
            }
        }
        
        return ValidationResult(
            isValid: errors.isEmpty,
            errors: errors,
            warnings: []
        )
    }
    
    public func validateContext(_ context: XAPIContext) -> ValidationResult {
        var errors: [ValidationError] = []
        
        // Validate registration
        if let registration = context.registration {
            if !isValidUUID(registration) {
                errors.append(.invalidRegistration)
            }
        }
        
        // Validate language
        if let language = context.language {
            if !isValidLanguageCode(language) {
                errors.append(.invalidLanguageCode)
            }
        }
        
        // Validate context activities
        if let activities = context.contextActivities {
            let activityArrays = [
                activities.parent,
                activities.grouping,
                activities.category,
                activities.other
            ].compactMap { $0 }
            
            for array in activityArrays {
                for activity in array {
                    let result = validateActivity(activity)
                    errors.append(contentsOf: result.errors)
                }
            }
        }
        
        return ValidationResult(
            isValid: errors.isEmpty,
            errors: errors,
            warnings: []
        )
    }
    
    // MARK: - Private Validation Methods
    
    private func validateActivity(_ activity: XAPIActivity) -> ValidationResult {
        var errors: [ValidationError] = []
        var warnings: [ValidationWarning] = []
        
        // Validate IRI
        if !isValidIRI(activity.id) {
            errors.append(.invalidActivityIRI)
        }
        
        // Validate definition
        if let definition = activity.definition {
            if let type = definition.type, !isValidIRI(type) {
                errors.append(.invalidActivityType)
            }
            
            if definition.name == nil || definition.name?.isEmpty == true {
                warnings.append(.missingActivityDefinition)
            }
        } else {
            warnings.append(.missingActivityDefinition)
        }
        
        return ValidationResult(
            isValid: errors.isEmpty,
            errors: errors,
            warnings: warnings
        )
    }
    
    private func validateScore(_ score: XAPIScore) -> [ValidationError] {
        var errors: [ValidationError] = []
        
        // Validate scaled
        if let scaled = score.scaled {
            if scaled < -1.0 || scaled > 1.0 {
                errors.append(.invalidScaledScore)
            }
        }
        
        // Validate raw vs min/max
        if let raw = score.raw {
            if let min = score.min, raw < min {
                errors.append(.invalidRawScore)
            }
            if let max = score.max, raw > max {
                errors.append(.invalidRawScore)
            }
        }
        
        // Validate min < max
        if let min = score.min, let max = score.max, min >= max {
            errors.append(.invalidMinMaxScore)
        }
        
        return errors
    }
    
    private func validateStatementRef(_ ref: XAPIStatementRef) -> ValidationResult {
        var errors: [ValidationError] = []
        
        if !isValidUUID(ref.id.uuidString) {
            errors.append(.invalidStatementId)
        }
        
        return ValidationResult(
            isValid: errors.isEmpty,
            errors: errors,
            warnings: []
        )
    }
    
    private func validateSubStatement(_ sub: XAPISubStatement) -> ValidationResult {
        // Simplified validation for sub-statements
        var errors: [ValidationError] = []
        
        let actorResult = validateActor(sub.actor)
        errors.append(contentsOf: actorResult.errors)
        
        let verbResult = validateVerb(sub.verb)
        errors.append(contentsOf: verbResult.errors)
        
        let activityResult = validateActivity(sub.object)
        errors.append(contentsOf: activityResult.errors)
        
        return ValidationResult(
            isValid: errors.isEmpty,
            errors: errors,
            warnings: []
        )
    }
    
    // MARK: - Validation Helpers
    
    private func isValidIRI(_ string: String) -> Bool {
        return string.range(of: validIRIPattern, options: .regularExpression) != nil
    }
    
    private func isValidUUID(_ string: String) -> Bool {
        return string.range(of: validUUIDPattern, options: .regularExpression) != nil
    }
    
    private func isValidLanguageCode(_ code: String) -> Bool {
        return code.range(of: validLanguageCodePattern, options: .regularExpression) != nil
    }
    
    private func isValidISO8601Duration(_ duration: String) -> Bool {
        return duration.range(of: validISO8601DurationPattern, options: .regularExpression) != nil
    }
} 