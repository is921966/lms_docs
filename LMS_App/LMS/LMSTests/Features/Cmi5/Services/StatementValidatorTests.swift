//
//  StatementValidatorTests.swift
//  LMSTests
//
//  Created on Sprint 42 Day 1 - xAPI Statement Validation
//

import XCTest
@testable import LMS

final class StatementValidatorTests: XCTestCase {
    
    private var validator: StatementValidator!
    
    override func setUp() {
        super.setUp()
        validator = StatementValidator()
    }
    
    override func tearDown() {
        validator = nil
        super.tearDown()
    }
    
    // MARK: - Actor Validation Tests
    
    func testValidateActor_ValidMbox_Success() {
        // Given
        let actor = XAPIActor(
            name: "Test User",
            mbox: "mailto:test@example.com"
        )
        
        // When
        let result = validator.validateActor(actor)
        
        // Then
        XCTAssertTrue(result.isValid)
        XCTAssertTrue(result.errors.isEmpty)
    }
    
    func testValidateActor_InvalidMboxFormat_Failure() {
        // Given
        let actor = XAPIActor(
            name: "Test User",
            mbox: "invalid-email" // Missing mailto:
        )
        
        // When
        let result = validator.validateActor(actor)
        
        // Then
        XCTAssertFalse(result.isValid)
        XCTAssertTrue(result.errors.contains(.invalidMboxFormat))
    }
    
    func testValidateActor_NoIdentifier_Failure() {
        // Given
        let actor = XAPIActor(name: "Test User") // No identifier
        
        // When
        let result = validator.validateActor(actor)
        
        // Then
        XCTAssertFalse(result.isValid)
        XCTAssertTrue(result.errors.contains(.missingActorIdentifier))
    }
    
    func testValidateActor_ValidAccount_Success() {
        // Given
        let actor = XAPIActor(
            name: "Test User",
            account: XAPIAccount(
                name: "user123",
                homePage: "https://example.com"
            )
        )
        
        // When
        let result = validator.validateActor(actor)
        
        // Then
        XCTAssertTrue(result.isValid)
    }
    
    // MARK: - Verb Validation Tests
    
    func testValidateVerb_StandardVerb_Success() {
        // Given
        let verb = XAPIVerb.completed
        
        // When
        let result = validator.validateVerb(verb)
        
        // Then
        XCTAssertTrue(result.isValid)
    }
    
    func testValidateVerb_InvalidIRI_Failure() {
        // Given
        let verb = XAPIVerb(
            id: "not-a-valid-iri",
            display: ["en-US": "Invalid"]
        )
        
        // When
        let result = validator.validateVerb(verb)
        
        // Then
        XCTAssertFalse(result.isValid)
        XCTAssertTrue(result.errors.contains(.invalidVerbIRI))
    }
    
    func testValidateVerb_MissingDisplay_Warning() {
        // Given
        let verb = XAPIVerb(
            id: "http://example.com/verbs/custom",
            display: [:] // Empty display
        )
        
        // When
        let result = validator.validateVerb(verb)
        
        // Then
        XCTAssertTrue(result.isValid) // Still valid but with warning
        XCTAssertTrue(result.warnings.contains(.missingVerbDisplay))
    }
    
    // MARK: - Object Validation Tests
    
    func testValidateObject_ValidActivity_Success() {
        // Given
        let activity = XAPIActivity(
            id: "https://example.com/activities/test",
            definition: XAPIActivityDefinition(
                name: ["en-US": "Test Activity"],
                type: "http://adlnet.gov/expapi/activities/module"
            )
        )
        let object = XAPIObject.activity(activity)
        
        // When
        let result = validator.validateObject(object)
        
        // Then
        XCTAssertTrue(result.isValid)
    }
    
    func testValidateObject_InvalidActivityIRI_Failure() {
        // Given
        let activity = XAPIActivity(
            id: "not-a-valid-iri",
            definition: nil
        )
        let object = XAPIObject.activity(activity)
        
        // When
        let result = validator.validateObject(object)
        
        // Then
        XCTAssertFalse(result.isValid)
        XCTAssertTrue(result.errors.contains(.invalidActivityIRI))
    }
    
    // MARK: - Result Validation Tests
    
    func testValidateResult_ValidScore_Success() {
        // Given
        let result = XAPIResult(
            score: XAPIScore(
                scaled: 0.95,
                raw: 95,
                min: 0,
                max: 100
            ),
            success: true,
            completion: true
        )
        
        // When
        let validationResult = validator.validateResult(result)
        
        // Then
        XCTAssertTrue(validationResult.isValid)
    }
    
    func testValidateResult_InvalidScaledScore_Failure() {
        // Given
        let result = XAPIResult(
            score: XAPIScore(scaled: 1.5) // > 1.0
        )
        
        // When
        let validationResult = validator.validateResult(result)
        
        // Then
        XCTAssertFalse(validationResult.isValid)
        XCTAssertTrue(validationResult.errors.contains(.invalidScaledScore))
    }
    
    func testValidateResult_InvalidRawScore_Failure() {
        // Given
        let result = XAPIResult(
            score: XAPIScore(
                raw: 110,
                min: 0,
                max: 100 // raw > max
            )
        )
        
        // When
        let validationResult = validator.validateResult(result)
        
        // Then
        XCTAssertFalse(validationResult.isValid)
        XCTAssertTrue(validationResult.errors.contains(.invalidRawScore))
    }
    
    func testValidateResult_InvalidDuration_Failure() {
        // Given
        let result = XAPIResult(
            duration: "invalid-duration"
        )
        
        // When
        let validationResult = validator.validateResult(result)
        
        // Then
        XCTAssertFalse(validationResult.isValid)
        XCTAssertTrue(validationResult.errors.contains(.invalidDurationFormat))
    }
    
    // MARK: - Context Validation Tests
    
    func testValidateContext_ValidContext_Success() {
        // Given
        let context = XAPIContext(
            registration: UUID().uuidString,
            language: "en-US",
            contextActivities: XAPIContextActivities(
                parent: [createActivity()],
                grouping: [createActivity()]
            )
        )
        
        // When
        let result = validator.validateContext(context)
        
        // Then
        XCTAssertTrue(result.isValid)
    }
    
    func testValidateContext_InvalidLanguageCode_Failure() {
        // Given
        let context = XAPIContext(
            language: "english" // Should be ISO code
        )
        
        // When
        let result = validator.validateContext(context)
        
        // Then
        XCTAssertFalse(result.isValid)
        XCTAssertTrue(result.errors.contains(.invalidLanguageCode))
    }
    
    // MARK: - Full Statement Validation Tests
    
    func testValidateStatement_CompleteValid_Success() {
        // Given
        let statement = XAPIStatement(
            actor: XAPIActor(
                name: "Test User",
                mbox: "mailto:test@example.com"
            ),
            verb: XAPIVerb.completed,
            object: .activity(createActivity()),
            result: XAPIResult(
                score: XAPIScore(scaled: 0.95),
                success: true,
                completion: true,
                duration: "PT30M"
            ),
            context: XAPIContext(
                registration: UUID().uuidString,
                language: "en-US"
            )
        )
        
        // When
        let result = validator.validateStatement(statement)
        
        // Then
        XCTAssertTrue(result.isValid)
        XCTAssertTrue(result.errors.isEmpty)
    }
    
    func testValidateStatement_MultipleErrors_AllReported() {
        // Given
        let statement = XAPIStatement(
            actor: XAPIActor(name: "No ID"), // Missing identifier
            verb: XAPIVerb(
                id: "invalid-verb", // Invalid IRI
                display: [:]
            ),
            object: .activity(XAPIActivity(
                id: "invalid-activity", // Invalid IRI
                definition: nil
            )),
            result: XAPIResult(
                score: XAPIScore(scaled: 2.0), // Invalid score
                duration: "not-a-duration" // Invalid duration
            )
        )
        
        // When
        let result = validator.validateStatement(statement)
        
        // Then
        XCTAssertFalse(result.isValid)
        XCTAssertEqual(result.errors.count, 5)
        XCTAssertTrue(result.errors.contains(.missingActorIdentifier))
        XCTAssertTrue(result.errors.contains(.invalidVerbIRI))
        XCTAssertTrue(result.errors.contains(.invalidActivityIRI))
        XCTAssertTrue(result.errors.contains(.invalidScaledScore))
        XCTAssertTrue(result.errors.contains(.invalidDurationFormat))
    }
    
    // MARK: - Timestamp Validation Tests
    
    func testValidateStatement_FutureTimestamp_Failure() {
        // Given
        var statement = createValidStatement()
        statement.timestamp = Date().addingTimeInterval(3600) // 1 hour in future
        
        // When
        let result = validator.validateStatement(statement)
        
        // Then
        XCTAssertFalse(result.isValid)
        XCTAssertTrue(result.errors.contains(.futureTimestamp))
    }
    
    // MARK: - Cmi5 Specific Validation Tests
    
    func testValidateCmi5Statement_RequiredContext_Success() {
        // Given
        let statement = createCmi5Statement()
        
        // When
        let result = validator.validateCmi5Statement(statement)
        
        // Then
        XCTAssertTrue(result.isValid)
    }
    
    func testValidateCmi5Statement_MissingRegistration_Failure() {
        // Given
        var statement = createCmi5Statement()
        statement.context = XAPIContext() // No registration
        
        // When
        let result = validator.validateCmi5Statement(statement)
        
        // Then
        XCTAssertFalse(result.isValid)
        XCTAssertTrue(result.errors.contains(.missingCmi5Registration))
    }
    
    // MARK: - Helper Methods
    
    private func createValidStatement() -> XAPIStatement {
        return XAPIStatement(
            actor: XAPIActor(
                name: "Test User",
                mbox: "mailto:test@example.com"
            ),
            verb: XAPIVerb.completed,
            object: .activity(createActivity())
        )
    }
    
    private func createActivity() -> XAPIActivity {
        return XAPIActivity(
            id: "https://example.com/activities/\(UUID())",
            definition: XAPIActivityDefinition(
                name: ["en-US": "Test Activity"],
                type: "http://adlnet.gov/expapi/activities/module"
            )
        )
    }
    
    private func createCmi5Statement() -> XAPIStatement {
        return XAPIStatement(
            actor: XAPIActor(
                name: "Test User",
                mbox: "mailto:test@example.com"
            ),
            verb: XAPIVerb.launched,
            object: .activity(createActivity()),
            context: XAPIContext(
                registration: UUID().uuidString,
                contextActivities: XAPIContextActivities(
                    category: [XAPIActivity(
                        id: "https://w3id.org/xapi/cmi5/context/categories/cmi5",
                        definition: nil
                    )]
                )
            )
        )
    }
} 