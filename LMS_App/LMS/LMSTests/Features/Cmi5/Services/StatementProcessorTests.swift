//
//  StatementProcessorTests.swift
//  LMSTests
//
//  Created on Sprint 42 Day 1 - xAPI Statement Processing
//

import XCTest
import Combine
@testable import LMS

final class StatementProcessorTests: XCTestCase {
    
    private var processor: StatementProcessor!
    private var mockLRSService: MockLRSService!
    private var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        mockLRSService = MockLRSService()
        processor = StatementProcessor(lrsService: mockLRSService)
        cancellables = []
    }
    
    override func tearDown() {
        processor = nil
        mockLRSService = nil
        cancellables = nil
        super.tearDown()
    }
    
    // MARK: - Statement Validation Tests
    
    func testValidateStatement_ValidStatement_ReturnsTrue() {
        // Given
        let statement = createValidStatement()
        
        // When
        let result = processor.validateStatement(statement)
        
        // Then
        XCTAssertTrue(result.isValid)
        XCTAssertTrue(result.errors.isEmpty)
    }
    
    func testValidateStatement_MissingActor_ReturnsFalse() {
        // Given
        let statement = XAPIStatement(
            actor: XAPIActor(name: nil, mbox: nil), // Invalid actor
            verb: XAPIVerb.completed,
            object: .activity(createActivity())
        )
        
        // When
        let result = processor.validateStatement(statement)
        
        // Then
        XCTAssertFalse(result.isValid)
        XCTAssertTrue(result.errors.contains(.missingActor))
    }
    
    func testValidateStatement_InvalidScore_ReturnsFalse() {
        // Given
        var statement = createValidStatement()
        statement.result = XAPIResult(
            score: XAPIScore(scaled: 1.5) // Invalid: > 1.0
        )
        
        // When
        let result = processor.validateStatement(statement)
        
        // Then
        XCTAssertFalse(result.isValid)
        XCTAssertTrue(result.errors.contains(.invalidScore))
    }
    
    // MARK: - Statement Processing Tests
    
    func testProcessStatement_ValidStatement_SendsToLRS() async throws {
        // Given
        let statement = createValidStatement()
        
        // When
        let statementId = try await processor.processStatement(statement)
        
        // Then
        XCTAssertNotNil(statementId)
        XCTAssertEqual(mockLRSService.sentStatements.count, 1)
        XCTAssertEqual(mockLRSService.sentStatements.first?.id, statementId)
    }
    
    func testProcessStatement_InvalidStatement_ThrowsError() async {
        // Given
        let invalidStatement = XAPIStatement(
            actor: XAPIActor(name: nil, mbox: nil),
            verb: XAPIVerb.completed,
            object: .activity(createActivity())
        )
        
        // When/Then
        do {
            _ = try await processor.processStatement(invalidStatement)
            XCTFail("Expected error to be thrown")
        } catch StatementProcessor.ProcessingError.validationFailed {
            // Expected
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    // MARK: - Batch Processing Tests
    
    func testProcessBatch_MultipleStatements_ProcessesAll() async throws {
        // Given
        let statements = [
            createValidStatement(),
            createValidStatement(),
            createValidStatement()
        ]
        
        // When
        let results = try await processor.processBatch(statements)
        
        // Then
        XCTAssertEqual(results.count, 3)
        XCTAssertEqual(results.successful.count, 3)
        XCTAssertEqual(results.failed.count, 0)
        XCTAssertEqual(mockLRSService.sentStatements.count, 3)
    }
    
    func testProcessBatch_MixedValidInvalid_ProcessesOnlyValid() async throws {
        // Given
        let statements = [
            createValidStatement(),
            XAPIStatement(
                actor: XAPIActor(name: nil, mbox: nil),
                verb: XAPIVerb.completed,
                object: .activity(createActivity())
            ),
            createValidStatement()
        ]
        
        // When
        let results = try await processor.processBatch(statements)
        
        // Then
        XCTAssertEqual(results.successful.count, 2)
        XCTAssertEqual(results.failed.count, 1)
        XCTAssertEqual(mockLRSService.sentStatements.count, 2)
    }
    
    // MARK: - Queue Management Tests
    
    func testQueueStatement_AddsToQueue() {
        // Given
        let statement = createValidStatement()
        XCTAssertEqual(processor.queuedStatements.count, 0)
        
        // When
        processor.queueStatement(statement)
        
        // Then
        XCTAssertEqual(processor.queuedStatements.count, 1)
    }
    
    func testProcessQueue_ProcessesAllQueued() async throws {
        // Given
        processor.queueStatement(createValidStatement())
        processor.queueStatement(createValidStatement())
        processor.queueStatement(createValidStatement())
        
        // When
        let processedCount = try await processor.processQueue()
        
        // Then
        XCTAssertEqual(processedCount, 3)
        XCTAssertEqual(processor.queuedStatements.count, 0)
        XCTAssertEqual(mockLRSService.sentStatements.count, 3)
    }
    
    // MARK: - Retry Mechanism Tests
    
    func testProcessWithRetry_FailsThenSucceeds() async throws {
        // Given
        mockLRSService.shouldFailNextCalls = 2
        let statement = createValidStatement()
        
        // When
        let statementId = try await processor.processWithRetry(statement, maxAttempts: 3)
        
        // Then
        XCTAssertNotNil(statementId)
        XCTAssertEqual(mockLRSService.sendAttempts, 3)
    }
    
    func testProcessWithRetry_ExceedsMaxAttempts_ThrowsError() async {
        // Given
        mockLRSService.shouldFailNextCalls = 5
        let statement = createValidStatement()
        
        // When/Then
        do {
            _ = try await processor.processWithRetry(statement, maxAttempts: 3)
            XCTFail("Expected error to be thrown")
        } catch StatementProcessor.ProcessingError.maxRetriesExceeded {
            // Expected
            XCTAssertEqual(mockLRSService.sendAttempts, 3)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    // MARK: - Deduplication Tests
    
    func testDeduplicateStatements_RemovesDuplicates() {
        // Given
        let statement1 = createValidStatement()
        let statement2 = statement1 // Same statement
        let statement3 = createValidStatement() // Different statement
        
        let statements = [statement1, statement2, statement3]
        
        // When
        let deduplicated = processor.deduplicateStatements(statements)
        
        // Then
        XCTAssertEqual(deduplicated.count, 2)
    }
    
    // MARK: - Real-time Updates Tests
    
    func testStatementProcessed_PublishesUpdate() {
        // Given
        let expectation = expectation(description: "Statement update received")
        var receivedUpdate: StatementUpdate?
        
        processor.statementUpdates
            .sink { update in
                receivedUpdate = update
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        // When
        let statement = createValidStatement()
        processor.publishUpdate(StatementUpdate(
            statement: statement,
            status: .processed,
            timestamp: Date()
        ))
        
        // Then
        waitForExpectations(timeout: 1.0)
        XCTAssertNotNil(receivedUpdate)
        XCTAssertEqual(receivedUpdate?.status, .processed)
    }
    
    // MARK: - Progress Integration Tests
    
    func testUpdateCourseProgress_AfterStatementProcessed() async throws {
        // Given
        let courseId = UUID()
        let statement = createStatementForCourse(courseId: courseId)
        
        // When
        _ = try await processor.processStatement(statement)
        
        // Then
        let progressUpdate = processor.lastProgressUpdate
        XCTAssertNotNil(progressUpdate)
        XCTAssertEqual(progressUpdate?.courseId, courseId)
    }
    
    // MARK: - Helper Methods
    
    private func createValidStatement() -> XAPIStatement {
        return XAPIStatement(
            actor: XAPIActor(
                name: "Test User",
                mbox: "mailto:test@example.com"
            ),
            verb: XAPIVerb.completed,
            object: .activity(createActivity()),
            result: XAPIResult(
                score: XAPIScore(scaled: 0.95),
                success: true,
                completion: true
            )
        )
    }
    
    private func createActivity() -> XAPIActivity {
        return XAPIActivity(
            id: "https://example.com/activity/\(UUID())",
            definition: XAPIActivityDefinition(
                name: ["en-US": "Test Activity"],
                type: "http://adlnet.gov/expapi/activities/module"
            )
        )
    }
    
    private func createStatementForCourse(courseId: UUID) -> XAPIStatement {
        var statement = createValidStatement()
        statement.context = XAPIContext(
            extensions: [
                "https://example.com/courseId": AnyCodable(courseId.uuidString)
            ]
        )
        return statement
    }
} 