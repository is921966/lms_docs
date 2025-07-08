//
//  XAPIModelsTests.swift
//  LMSTests
//
//  Created on Sprint 40 Day 2 - xAPI Models Testing
//

import XCTest
@testable import LMS

final class XAPIModelsTests: XCTestCase {
    
    // MARK: - Actor Tests
    
    func testXAPIActorCreation() {
        // Test with email
        let emailActor = XAPIActor(
            name: "John Doe",
            mbox: "mailto:john.doe@example.com"
        )
        
        XCTAssertEqual(emailActor.name, "John Doe")
        XCTAssertEqual(emailActor.mbox, "mailto:john.doe@example.com")
        
        // Test with account
        let account = XAPIAccount(
            name: "john.doe",
            homePage: "https://lms.example.com"
        )
        let accountActor = XAPIActor(
            name: "John Doe",
            account: account
        )
        
        XCTAssertNotNil(accountActor.account)
        XCTAssertEqual(accountActor.account?.name, "john.doe")
    }
    
    func testXAPIActorGroup() {
        // Groups are represented differently in xAPI Object
        let member1 = XAPIActor(name: "Member 1", mbox: "mailto:member1@example.com")
        let member2 = XAPIActor(name: "Member 2", mbox: "mailto:member2@example.com")
        
        // In real xAPI, groups would be handled through XAPIObject.group
        XCTAssertNotNil(member1)
        XCTAssertNotNil(member2)
    }
    
    // MARK: - Verb Tests
    
    func testPredefinedVerbs() {
        // Test completed verb
        XCTAssertEqual(XAPIVerb.completed.id, "http://adlnet.gov/expapi/verbs/completed")
        XCTAssertEqual(XAPIVerb.completed.display["en-US"], "completed")
        XCTAssertEqual(XAPIVerb.completed.display["ru-RU"], "завершил")
        
        // Test other verbs
        XCTAssertEqual(XAPIVerb.passed.display["en-US"], "passed")
        XCTAssertEqual(XAPIVerb.failed.display["en-US"], "failed")
        XCTAssertEqual(XAPIVerb.attempted.display["en-US"], "attempted")
        XCTAssertEqual(XAPIVerb.launched.display["en-US"], "launched")
    }
    
    func testCustomVerb() {
        let customVerb = XAPIVerb(
            id: "https://example.com/verbs/reviewed",
            display: ["en-US": "reviewed", "ru-RU": "просмотрел"]
        )
        
        XCTAssertEqual(customVerb.id, "https://example.com/verbs/reviewed")
        XCTAssertEqual(customVerb.display["en-US"], "reviewed")
    }
    
    // MARK: - Activity Tests
    
    func testXAPIActivityCreation() {
        let definition = XAPIActivityDefinition(
            name: ["en-US": "Introduction to Swift", "ru-RU": "Введение в Swift"],
            description: ["en-US": "Learn Swift basics"],
            type: "http://adlnet.gov/expapi/activities/course"
        )
        
        let activity = XAPIActivity(
            id: "https://lms.example.com/courses/swift-101",
            definition: definition
        )
        
        XCTAssertEqual(activity.id, "https://lms.example.com/courses/swift-101")
        XCTAssertEqual(activity.definition?.name?["en-US"], "Introduction to Swift")
        XCTAssertEqual(activity.definition?.type, "http://adlnet.gov/expapi/activities/course")
    }
    
    // MARK: - Score Tests
    
    func testXAPIScoreValidation() {
        // Valid score
        let validScore = XAPIScore(scaled: 0.85, raw: 85, min: 0, max: 100)
        XCTAssertTrue(validScore.isValid)
        
        // Edge cases
        let minScore = XAPIScore(scaled: -1.0)
        XCTAssertTrue(minScore.isValid)
        
        let maxScore = XAPIScore(scaled: 1.0)
        XCTAssertTrue(maxScore.isValid)
        
        // Invalid score (out of range)
        let invalidScore1 = XAPIScore(scaled: 1.5)
        XCTAssertFalse(invalidScore1.isValid)
        
        let invalidScore2 = XAPIScore(scaled: -1.5)
        XCTAssertFalse(invalidScore2.isValid)
    }
    
    // MARK: - Result Tests
    
    func testXAPIResultCreation() {
        let score = XAPIScore(scaled: 0.75, raw: 75, min: 0, max: 100)
        let result = XAPIResult(
            score: score,
            success: true,
            completion: true,
            duration: "PT30M" // 30 minutes in ISO 8601
        )
        
        XCTAssertEqual(result.score?.scaled, 0.75)
        XCTAssertTrue(result.success ?? false)
        XCTAssertTrue(result.completion ?? false)
        XCTAssertEqual(result.duration, "PT30M")
    }
    
    // MARK: - Statement Tests
    
    func testXAPIStatementCreation() {
        // Create actor
        let actor = XAPIActor(
            name: "Test User",
            mbox: "mailto:test@example.com"
        )
        
        // Create activity
        let activity = XAPIActivity(
            id: "https://lms.example.com/lessons/lesson-1",
            definition: XAPIActivityDefinition(
                name: ["en-US": "Lesson 1"],
                type: "http://adlnet.gov/expapi/activities/lesson"
            )
        )
        
        // Create result
        let result = XAPIResult(
            score: XAPIScore(scaled: 0.9),
            success: true,
            completion: true
        )
        
        // Create context
        let context = XAPIContext(
            registration: UUID().uuidString,
            language: "en-US"
        )
        
        // Create statement
        let statement = XAPIStatement(
            actor: actor,
            verb: XAPIVerb.completed,
            object: .activity(activity),
            result: result,
            context: context
        )
        
        XCTAssertNotNil(statement.id)
        XCTAssertEqual(statement.actor.name, "Test User")
        XCTAssertEqual(statement.verb.id, XAPIVerb.completed.id)
        XCTAssertNotNil(statement.result)
        XCTAssertNotNil(statement.context)
        // Version is not a property of XAPIStatement
    }
    
    // MARK: - Object Type Tests
    
    func testXAPIObjectTypes() {
        let actor = XAPIActor(name: "Test Actor")
        let activity = XAPIActivity(id: "test-activity", definition: nil)
        let statementRef = XAPIStatementRef(id: UUID())
        
        // Test different object types
        let activityObject = XAPIObject.activity(activity)
        let agentObject = XAPIObject.agent(actor)
        let refObject = XAPIObject.statementRef(statementRef)
        
        // Verify we can create different object types
        switch activityObject {
        case .activity(let act):
            XCTAssertEqual(act.id, "test-activity")
        default:
            XCTFail("Expected activity object")
        }
        
        switch agentObject {
        case .agent(let act):
            XCTAssertEqual(act.name, "Test Actor")
        default:
            XCTFail("Expected agent object")
        }
        
        switch refObject {
        case .statementRef(let ref):
            XCTAssertNotNil(ref.id)
        default:
            XCTFail("Expected statement ref object")
        }
    }
    
    // MARK: - Context Activities Tests
    
    func testContextActivities() {
        let parentActivity = XAPIActivity(id: "parent-course", definition: nil)
        let categoryActivity = XAPIActivity(id: "category-compliance", definition: nil)
        
        let contextActivities = XAPIContextActivities(
            parent: [parentActivity],
            category: [categoryActivity]
        )
        
        XCTAssertEqual(contextActivities.parent?.count, 1)
        XCTAssertEqual(contextActivities.parent?.first?.id, "parent-course")
        XCTAssertEqual(contextActivities.category?.count, 1)
        XCTAssertNil(contextActivities.grouping)
        XCTAssertNil(contextActivities.other)
    }
    
    // MARK: - Attachment Tests
    
    func testXAPIAttachment() {
        let attachment = XAPIAttachment(
            usageType: "http://example.com/attachment/certificate",
            display: ["en-US": "Course Certificate"],
            contentType: "application/pdf",
            length: 1024 * 100, // 100KB
            sha2: "abc123def456"
        )
        
        XCTAssertEqual(attachment.usageType, "http://example.com/attachment/certificate")
        XCTAssertEqual(attachment.display["en-US"], "Course Certificate")
        XCTAssertEqual(attachment.contentType, "application/pdf")
        XCTAssertEqual(attachment.length, 102400)
    }
    
    // MARK: - Codable Tests
    
    func testStatementCodable() throws {
        // Create a complete statement
        let actor = XAPIActor(name: "Test User", mbox: "mailto:test@example.com")
        let activity = XAPIActivity(
            id: "test-activity",
            definition: XAPIActivityDefinition(name: ["en-US": "Test Activity"])
        )
        let statement = XAPIStatement(
            actor: actor,
            verb: XAPIVerb.completed,
            object: .activity(activity)
        )
        
        // Encode
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(statement)
        
        // Decode
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let decodedStatement = try decoder.decode(XAPIStatement.self, from: data)
        
        // Verify
        XCTAssertEqual(decodedStatement.id, statement.id)
        XCTAssertEqual(decodedStatement.actor.name, "Test User")
        XCTAssertEqual(decodedStatement.verb.id, XAPIVerb.completed.id)
    }
} 