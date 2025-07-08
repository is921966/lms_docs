//
//  LRSServiceTests.swift
//  LMSTests
//
//  Created on Sprint 40 Day 4
//

import XCTest
@testable import LMS

final class LRSServiceTests: XCTestCase {
    
    private var sut: MockLRSService!
    
    override func setUp() {
        super.setUp()
        sut = MockLRSService()
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    // MARK: - Send Statement Tests
    
    func testSendStatement_ShouldAssignID_WhenNotProvided() async throws {
        // Given
        let statement = XAPIStatement(
            actor: XAPIActor(name: "Test User"),
            verb: XAPIVerb.completed,
            object: .activity(XAPIActivity(id: "test-activity", definition: nil))
        )
        
        // When
        let statementId = try await sut.sendStatement(statement)
        
        // Then
        XCTAssertFalse(statementId.isEmpty)
    }
    
    func testSendStatement_ShouldUseProvidedID() async throws {
        // Given
        let providedId = "test-statement-id"
        var statement = XAPIStatement(
            id: providedId,
            actor: XAPIActor(name: "Test User"),
            verb: XAPIVerb.completed,
            object: .activity(XAPIActivity(id: "test-activity", definition: nil))
        )
        
        // When
        let statementId = try await sut.sendStatement(statement)
        
        // Then
        XCTAssertEqual(statementId, providedId)
    }
    
    // MARK: - Get Statements Tests
    
    func testGetStatements_ShouldFilterByActivityId() async throws {
        // Given
        let targetActivityId = "target-activity"
        let otherActivityId = "other-activity"
        
        let targetStatement = XAPIStatement(
            actor: XAPIActor(name: "Test User"),
            verb: XAPIVerb.completed,
            object: .activity(XAPIActivity(id: targetActivityId, definition: nil))
        )
        
        let otherStatement = XAPIStatement(
            actor: XAPIActor(name: "Test User"),
            verb: XAPIVerb.attempted,
            object: .activity(XAPIActivity(id: otherActivityId, definition: nil))
        )
        
        _ = try await sut.sendStatement(targetStatement)
        _ = try await sut.sendStatement(otherStatement)
        
        // When
        let statements = try await sut.getStatements(
            activityId: targetActivityId,
            userId: nil,
            limit: 10
        )
        
        // Then
        XCTAssertEqual(statements.count, 1)
        if case .activity(let activity) = statements[0].object {
            XCTAssertEqual(activity.id, targetActivityId)
        } else {
            XCTFail("Expected activity object")
        }
    }
    
    func testGetStatements_ShouldRespectLimit() async throws {
        // Given
        let activityId = "test-activity"
        
        for i in 0..<5 {
            let statement = XAPIStatement(
                actor: XAPIActor(name: "User \(i)"),
                verb: XAPIVerb.completed,
                object: .activity(XAPIActivity(id: activityId, definition: nil))
            )
            _ = try await sut.sendStatement(statement)
        }
        
        // When
        let statements = try await sut.getStatements(
            activityId: activityId,
            userId: nil,
            limit: 3
        )
        
        // Then
        XCTAssertEqual(statements.count, 3)
    }
    
    // MARK: - State Management Tests
    
    func testSetAndGetState_ShouldStoreAndRetrieveValue() async throws {
        // Given
        let activityId = "test-activity"
        let userId = "test-user"
        let stateId = "bookmark"
        let stateValue: [String: Any] = [
            "location": "page-42",
            "timestamp": Date().timeIntervalSince1970
        ]
        
        // When
        try await sut.setState(
            activityId: activityId,
            userId: userId,
            stateId: stateId,
            value: stateValue
        )
        
        let retrievedState = try await sut.getState(
            activityId: activityId,
            userId: userId,
            stateId: stateId
        )
        
        // Then
        XCTAssertNotNil(retrievedState)
        XCTAssertEqual(retrievedState?["location"] as? String, "page-42")
    }
    
    func testDeleteState_ShouldRemoveState() async throws {
        // Given
        let activityId = "test-activity"
        let userId = "test-user"
        let stateId = "bookmark"
        let stateValue: [String: Any] = ["location": "page-42"]
        
        try await sut.setState(
            activityId: activityId,
            userId: userId,
            stateId: stateId,
            value: stateValue
        )
        
        // When
        try await sut.deleteState(
            activityId: activityId,
            userId: userId,
            stateId: stateId
        )
        
        let retrievedState = try await sut.getState(
            activityId: activityId,
            userId: userId,
            stateId: stateId
        )
        
        // Then
        XCTAssertNil(retrievedState)
    }
    
    // MARK: - Session Management Tests
    
    func testCreateSession_ShouldReturnValidSession() async throws {
        // Given
        let activityId = "test-activity"
        let userId = "test-user"
        
        // When
        let session = try await sut.createSession(
            activityId: activityId,
            userId: userId
        )
        
        // Then
        XCTAssertFalse(session.sessionId.isEmpty)
        XCTAssertFalse(session.authToken.isEmpty)
        XCTAssertFalse(session.endpoint.isEmpty)
        XCTAssertFalse(session.registration.isEmpty)
        XCTAssertEqual(session.actorMbox, "mailto:\(userId)@lms.com")
        XCTAssertFalse(session.isExpired)
    }
    
    func testSession_ShouldBeExpired_AfterExpirationTime() async throws {
        // Given
        let session = LRSSession(
            sessionId: "test-session",
            authToken: "test-token",
            endpoint: "https://lrs.example.com",
            registration: "test-registration",
            actorMbox: "mailto:test@lms.com",
            expiresAt: Date().addingTimeInterval(-1) // 1 second ago
        )
        
        // Then
        XCTAssertTrue(session.isExpired)
    }
    
    func testSession_AuthHeader_ShouldBeProperlyFormatted() async throws {
        // Given
        let token = "test-auth-token"
        let session = LRSSession(
            sessionId: "test-session",
            authToken: token,
            endpoint: "https://lrs.example.com",
            registration: "test-registration",
            actorMbox: "mailto:test@lms.com",
            expiresAt: Date().addingTimeInterval(3600)
        )
        
        // Then
        XCTAssertEqual(session.authHeader, "Bearer \(token)")
    }
} 