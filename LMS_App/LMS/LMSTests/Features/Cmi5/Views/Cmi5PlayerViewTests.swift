//  Cmi5PlayerViewTests.swift
//  LMSTests
//
//  Created by LMS on 17.01.2025.
//

import XCTest
import SwiftUI
@testable import LMS

final class Cmi5PlayerViewTests: XCTestCase {
    
    // MARK: - Properties
    
    var mockActivity: Cmi5Activity!
    var sessionId: String!
    var launchParameters: [String: String]!
    
    // MARK: - Setup
    
    override func setUp() {
        super.setUp()
        
        mockActivity = Cmi5Activity(
            id: "test-activity-1",
            type: "AU",
            title: [Cmi5LangString(lang: "ru", value: "Тестовая активность")],
            description: [Cmi5LangString(lang: "ru", value: "Описание тестовой активности")],
            url: "https://example.com/cmi5/content/test",
            activityType: "http://adlnet.gov/expapi/activities/module",
            launchMethod: "OwnWindow",
            moveOn: "Passed"
        )
        
        sessionId = UUID().uuidString
        
        launchParameters = [
            "lang": "ru",
            "learner_id": "test-user-123",
            "learner_name": "Test User"
        ]
    }
    
    override func tearDown() {
        mockActivity = nil
        sessionId = nil
        launchParameters = nil
        super.tearDown()
    }
    
    // MARK: - Tests
    
    func testCmi5PlayerViewInitialization() {
        // Given
        let playerView = Cmi5PlayerView(
            activity: mockActivity,
            sessionId: sessionId,
            launchParameters: launchParameters
        )
        
        // Then
        XCTAssertNotNil(playerView)
        XCTAssertEqual(playerView.activity.id, "test-activity-1")
        XCTAssertEqual(playerView.sessionId, sessionId)
        XCTAssertEqual(playerView.launchParameters["lang"], "ru")
    }
    
    func testBuildLaunchURL() {
        // Given
        let playerView = Cmi5PlayerView(
            activity: mockActivity,
            sessionId: sessionId,
            launchParameters: launchParameters
        )
        
        // When
        let launchURL = playerView.buildLaunchURLForTesting()
        
        // Then
        XCTAssertNotNil(launchURL)
        XCTAssertTrue(launchURL.absoluteString.contains("https://example.com/cmi5/content/test"))
        XCTAssertTrue(launchURL.absoluteString.contains("session="))
        XCTAssertTrue(launchURL.absoluteString.contains("lang=ru"))
    }
    
    func testStatementHandling() {
        // Given
        var capturedStatement: XAPIStatement?
        let expectation = expectation(description: "Statement callback")
        
        let playerView = Cmi5PlayerView(
            activity: mockActivity,
            sessionId: sessionId,
            launchParameters: launchParameters,
            onStatement: { statement in
                capturedStatement = statement
                expectation.fulfill()
            }
        )
        
        // When
        let testStatement = XAPIStatement(
            id: UUID(),
            actor: XAPIActor(
                objectType: "Agent",
                name: "Test User",
                mbox: "mailto:test@example.com"
            ),
            verb: XAPIVerb(
                id: "http://adlnet.gov/expapi/verbs/completed",
                display: ["en-US": "completed"]
            ),
            object: mockActivity.toXAPIActivity()
        )
        
        playerView.handleStatementForTesting(testStatement)
        
        // Then
        wait(for: [expectation], timeout: 1.0)
        XCTAssertNotNil(capturedStatement)
        XCTAssertEqual(capturedStatement?.verb.id, "http://adlnet.gov/expapi/verbs/completed")
    }
    
    func testCompletionCallback() {
        // Given
        var completionCalled = false
        var completionPassed = false
        let expectation = expectation(description: "Completion callback")
        
        let playerView = Cmi5PlayerView(
            activity: mockActivity,
            sessionId: sessionId,
            launchParameters: launchParameters,
            onCompletion: { passed in
                completionCalled = true
                completionPassed = passed
                expectation.fulfill()
            }
        )
        
        // When - Send completed statement
        let completedStatement = XAPIStatement(
            id: UUID(),
            actor: XAPIActor(
                objectType: "Agent",
                name: "Test User",
                mbox: "mailto:test@example.com"
            ),
            verb: XAPIStatementBuilder.Cmi5Verb.completed,
            object: mockActivity.toXAPIActivity()
        )
        
        playerView.handleStatementForTesting(completedStatement)
        
        // Then
        wait(for: [expectation], timeout: 1.0)
        XCTAssertTrue(completionCalled)
        XCTAssertTrue(completionPassed)
    }
    
    func testFailureCompletion() {
        // Given
        var completionCalled = false
        var completionPassed = true
        let expectation = expectation(description: "Failure callback")
        
        let playerView = Cmi5PlayerView(
            activity: mockActivity,
            sessionId: sessionId,
            launchParameters: launchParameters,
            onCompletion: { passed in
                completionCalled = true
                completionPassed = passed
                expectation.fulfill()
            }
        )
        
        // When - Send failed statement
        let failedStatement = XAPIStatement(
            id: UUID(),
            actor: XAPIActor(
                objectType: "Agent",
                name: "Test User",
                mbox: "mailto:test@example.com"
            ),
            verb: XAPIStatementBuilder.Cmi5Verb.failed,
            object: mockActivity.toXAPIActivity()
        )
        
        playerView.handleStatementForTesting(failedStatement)
        
        // Then
        wait(for: [expectation], timeout: 1.0)
        XCTAssertTrue(completionCalled)
        XCTAssertFalse(completionPassed)
    }
}

// MARK: - Test Extensions

extension Cmi5PlayerView {
    /// Экспортирует buildLaunchURL для тестирования
    func buildLaunchURLForTesting() -> URL {
        var components = URLComponents(string: activity.url)!
        
        // Add launch parameters
        var queryItems = launchParameters.map { URLQueryItem(name: $0.key, value: $0.value) }
        
        // Add session ID
        queryItems.append(URLQueryItem(name: "session", value: sessionId))
        
        // Add mock endpoint and auth
        queryItems.append(URLQueryItem(name: "endpoint", value: "https://lrs.example.com/xapi"))
        queryItems.append(URLQueryItem(name: "auth", value: "mock-auth-token"))
        
        components.queryItems = queryItems
        
        return components.url!
    }
    
    /// Экспортирует handleStatement для тестирования
    func handleStatementForTesting(_ statement: XAPIStatement) {
        // Notify callback
        onStatement?(statement)
        
        // Check for completion
        if statement.verb.id == XAPIStatementBuilder.Cmi5Verb.completed.id ||
           statement.verb.id == XAPIStatementBuilder.Cmi5Verb.passed.id {
            onCompletion?(true)
        } else if statement.verb.id == XAPIStatementBuilder.Cmi5Verb.failed.id {
            onCompletion?(false)
        }
    }
} 