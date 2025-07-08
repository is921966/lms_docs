//
//  XAPIStatementBuilderTests.swift
//  LMSTests
//
//  Created on Sprint 40 Day 4
//

import XCTest
@testable import LMS

final class XAPIStatementBuilderTests: XCTestCase {
    
    // MARK: - Basic Builder Tests
    
    func testBuild_ShouldThrowError_WhenActorMissing() throws {
        // Given
        let builder = XAPIStatementBuilder()
            .setVerb(.completed)
            .setActivity(id: "test-activity")
        
        // When/Then
        XCTAssertThrowsError(try builder.build()) { error in
            XCTAssertEqual(error as? XAPIStatementBuilder.BuilderError, .missingActor)
        }
    }
    
    func testBuild_ShouldThrowError_WhenVerbMissing() throws {
        // Given
        let builder = XAPIStatementBuilder()
            .setActor(userId: "test-user")
            .setActivity(id: "test-activity")
        
        // When/Then
        XCTAssertThrowsError(try builder.build()) { error in
            XCTAssertEqual(error as? XAPIStatementBuilder.BuilderError, .missingVerb)
        }
    }
    
    func testBuild_ShouldThrowError_WhenObjectMissing() throws {
        // Given
        let builder = XAPIStatementBuilder()
            .setActor(userId: "test-user")
            .setVerb(.completed)
        
        // When/Then
        XCTAssertThrowsError(try builder.build()) { error in
            XCTAssertEqual(error as? XAPIStatementBuilder.BuilderError, .missingObject)
        }
    }
    
    func testBuild_ShouldCreateValidStatement_WithMinimalData() throws {
        // Given
        let builder = XAPIStatementBuilder()
            .setActor(userId: "test-user")
            .setVerb(.completed)
            .setActivity(id: "test-activity")
        
        // When
        let statement = try builder.build()
        
        // Then
        XCTAssertNotNil(statement.id)
        XCTAssertNotNil(statement.timestamp)
        XCTAssertEqual(statement.verb.id, XAPIVerb.completed.id)
        
        if case .activity(let activity) = statement.object {
            XCTAssertEqual(activity.id, "test-activity")
        } else {
            XCTFail("Expected activity object")
        }
    }
    
    // MARK: - Actor Tests
    
    func testSetActor_ShouldCreateActorWithAccount() throws {
        // Given
        let userId = "test-user"
        let name = "Test User"
        
        // When
        let statement = try XAPIStatementBuilder()
            .setActor(userId: userId, name: name)
            .setVerb(.completed)
            .setActivity(id: "test-activity")
            .build()
        
        // Then
        XCTAssertEqual(statement.actor.name, name)
        XCTAssertEqual(statement.actor.account?.name, userId)
        XCTAssertEqual(statement.actor.account?.homePage, "https://lms.example.com")
    }
    
    // MARK: - Result Tests
    
    func testSetScore_ShouldCalculateScaledValue() throws {
        // Given
        let raw = 85.0
        let min = 0.0
        let max = 100.0
        
        // When
        let statement = try XAPIStatementBuilder()
            .setActor(userId: "test-user")
            .setVerb(.completed)
            .setActivity(id: "test-activity")
            .setScore(raw: raw, min: min, max: max)
            .build()
        
        // Then
        XCTAssertNotNil(statement.result)
        XCTAssertEqual(statement.result?.score?.raw, raw)
        XCTAssertEqual(statement.result?.score?.min, min)
        XCTAssertEqual(statement.result?.score?.max, max)
        XCTAssertEqual(statement.result?.score?.scaled, 0.85)
    }
    
    func testSetResult_ShouldSetAllFields() throws {
        // Given
        let score = XAPIScore(scaled: 0.9, raw: 90, min: 0, max: 100)
        let duration = "PT1H30M"
        
        // When
        let statement = try XAPIStatementBuilder()
            .setActor(userId: "test-user")
            .setVerb(.completed)
            .setActivity(id: "test-activity")
            .setResult(
                score: score,
                success: true,
                completion: true,
                duration: duration,
                response: "User response"
            )
            .build()
        
        // Then
        XCTAssertNotNil(statement.result)
        XCTAssertEqual(statement.result?.score?.raw, 90)
        XCTAssertEqual(statement.result?.success, true)
        XCTAssertEqual(statement.result?.completion, true)
        XCTAssertEqual(statement.result?.duration, duration)
        XCTAssertEqual(statement.result?.response, "User response")
    }
    
    // MARK: - Context Tests
    
    func testSetCmi5Context_ShouldAddRequiredExtensions() throws {
        // Given
        let sessionId = "test-session"
        let registration = "test-registration"
        
        // When
        let statement = try XAPIStatementBuilder()
            .setActor(userId: "test-user")
            .setVerb(.launched)
            .setActivity(id: "test-activity")
            .setCmi5Context(sessionId: sessionId, registration: registration)
            .build()
        
        // Then
        XCTAssertNotNil(statement.context)
        XCTAssertEqual(statement.context?.registration, registration)
        XCTAssertNotNil(statement.context?.contextActivities?.category)
        XCTAssertEqual(
            statement.context?.contextActivities?.category?.first?.id,
            "https://w3id.org/xapi/cmi5/context/categories/cmi5"
        )
        XCTAssertNotNil(statement.context?.extensions)
    }
    
    // MARK: - Factory Method Tests
    
    func testLaunchedStatement_ShouldCreateProperStatement() throws {
        // Given
        let userId = "test-user"
        let activityId = "test-activity"
        let sessionId = "test-session"
        let registration = "test-registration"
        
        // When
        let statement = try XAPIStatementBuilder.launchedStatement(
            userId: userId,
            activityId: activityId,
            sessionId: sessionId,
            registration: registration
        )
        
        // Then
        XCTAssertEqual(statement.verb.id, XAPIStatementBuilder.Cmi5Verb.launched.id)
        XCTAssertNotNil(statement.context)
        XCTAssertEqual(statement.context?.registration, registration)
    }
    
    func testPassedStatement_ShouldIncludeScoreAndSuccess() throws {
        // Given
        let score = 95.0
        let duration = "PT45M"
        
        // When
        let statement = try XAPIStatementBuilder.passedStatement(
            userId: "test-user",
            activityId: "test-activity",
            sessionId: "test-session",
            registration: "test-registration",
            score: score,
            duration: duration
        )
        
        // Then
        XCTAssertEqual(statement.verb.id, XAPIStatementBuilder.Cmi5Verb.passed.id)
        XCTAssertEqual(statement.result?.score?.raw, score)
        XCTAssertEqual(statement.result?.success, true)
        XCTAssertEqual(statement.result?.completion, true)
        XCTAssertEqual(statement.result?.duration, duration)
    }
    
    func testFailedStatement_ShouldHaveSuccessFalse() throws {
        // Given
        let score = 45.0
        
        // When
        let statement = try XAPIStatementBuilder.failedStatement(
            userId: "test-user",
            activityId: "test-activity",
            sessionId: "test-session",
            registration: "test-registration",
            score: score
        )
        
        // Then
        XCTAssertEqual(statement.verb.id, XAPIStatementBuilder.Cmi5Verb.failed.id)
        XCTAssertEqual(statement.result?.score?.raw, score)
        XCTAssertEqual(statement.result?.success, false)
        XCTAssertEqual(statement.result?.completion, true)
    }
    
    // MARK: - Duration Helper Tests
    
    func testDurationString_ShouldFormatCorrectly() {
        // Test cases
        XCTAssertEqual(XAPIStatementBuilder.durationString(seconds: 0), "PT0S")
        XCTAssertEqual(XAPIStatementBuilder.durationString(seconds: 45), "PT45S")
        XCTAssertEqual(XAPIStatementBuilder.durationString(seconds: 90), "PT1M30S")
        XCTAssertEqual(XAPIStatementBuilder.durationString(seconds: 3600), "PT1H")
        XCTAssertEqual(XAPIStatementBuilder.durationString(seconds: 3665), "PT1H1M5S")
        XCTAssertEqual(XAPIStatementBuilder.durationString(seconds: 7200), "PT2H")
    }
} 