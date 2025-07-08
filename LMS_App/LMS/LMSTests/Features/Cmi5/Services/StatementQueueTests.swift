//
//  StatementQueueTests.swift
//  LMSTests
//
//  Created on Sprint 42 Day 1 - xAPI Statement Queue Management
//

import XCTest
import Combine
@testable import LMS

final class StatementQueueTests: XCTestCase {
    
    private var queue: StatementQueue!
    private var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        queue = StatementQueue()
        cancellables = []
    }
    
    override func tearDown() {
        queue = nil
        cancellables = nil
        super.tearDown()
    }
    
    // MARK: - Basic Operations Tests
    
    func testEnqueue_AddsStatementToQueue() {
        // Given
        let statement = createStatement()
        XCTAssertEqual(queue.count, 0)
        
        // When
        queue.enqueue(statement)
        
        // Then
        XCTAssertEqual(queue.count, 1)
        XCTAssertFalse(queue.isEmpty)
    }
    
    func testDequeue_ReturnsOldestStatement() {
        // Given
        let statement1 = createStatement(verb: .attempted)
        let statement2 = createStatement(verb: .completed)
        let statement3 = createStatement(verb: .passed)
        
        queue.enqueue(statement1)
        queue.enqueue(statement2)
        queue.enqueue(statement3)
        
        // When
        let dequeued = queue.dequeue()
        
        // Then
        XCTAssertNotNil(dequeued)
        XCTAssertEqual(dequeued?.verb.id, statement1.verb.id)
        XCTAssertEqual(queue.count, 2)
    }
    
    func testDequeue_EmptyQueue_ReturnsNil() {
        // Given
        XCTAssertTrue(queue.isEmpty)
        
        // When
        let dequeued = queue.dequeue()
        
        // Then
        XCTAssertNil(dequeued)
    }
    
    // MARK: - Priority Tests
    
    func testEnqueueWithPriority_HighPriorityFirst() {
        // Given
        let normalStatement = createStatement(verb: .attempted)
        let highPriorityStatement = createStatement(verb: .failed)
        
        // When
        queue.enqueue(normalStatement, priority: .normal)
        queue.enqueue(highPriorityStatement, priority: .high)
        
        // Then
        let first = queue.dequeue()
        XCTAssertEqual(first?.verb.id, highPriorityStatement.verb.id)
    }
    
    func testPriorityOrder_HighNormalLow() {
        // Given
        let low = createStatement(verb: .launched)
        let normal = createStatement(verb: .attempted)
        let high = createStatement(verb: .completed)
        
        // When
        queue.enqueue(low, priority: .low)
        queue.enqueue(normal, priority: .normal)
        queue.enqueue(high, priority: .high)
        
        // Then
        XCTAssertEqual(queue.dequeue()?.verb.id, high.verb.id)
        XCTAssertEqual(queue.dequeue()?.verb.id, normal.verb.id)
        XCTAssertEqual(queue.dequeue()?.verb.id, low.verb.id)
    }
    
    // MARK: - Batch Operations Tests
    
    func testEnqueueBatch_AddsAllStatements() {
        // Given
        let statements = [
            createStatement(),
            createStatement(),
            createStatement()
        ]
        
        // When
        queue.enqueueBatch(statements)
        
        // Then
        XCTAssertEqual(queue.count, 3)
    }
    
    func testDequeueBatch_ReturnsRequestedCount() {
        // Given
        for i in 0..<10 {
            queue.enqueue(createStatement())
        }
        
        // When
        let batch = queue.dequeueBatch(count: 5)
        
        // Then
        XCTAssertEqual(batch.count, 5)
        XCTAssertEqual(queue.count, 5)
    }
    
    func testDequeueBatch_FewerThanRequested_ReturnsAll() {
        // Given
        queue.enqueue(createStatement())
        queue.enqueue(createStatement())
        
        // When
        let batch = queue.dequeueBatch(count: 5)
        
        // Then
        XCTAssertEqual(batch.count, 2)
        XCTAssertTrue(queue.isEmpty)
    }
    
    // MARK: - Size Limit Tests
    
    func testMaxSize_RejectsWhenFull() {
        // Given
        let smallQueue = StatementQueue(maxSize: 3)
        
        // When
        let result1 = smallQueue.enqueue(createStatement())
        let result2 = smallQueue.enqueue(createStatement())
        let result3 = smallQueue.enqueue(createStatement())
        let result4 = smallQueue.enqueue(createStatement())
        
        // Then
        XCTAssertTrue(result1)
        XCTAssertTrue(result2)
        XCTAssertTrue(result3)
        XCTAssertFalse(result4)
        XCTAssertEqual(smallQueue.count, 3)
    }
    
    // MARK: - Clear Operations Tests
    
    func testClear_RemovesAllStatements() {
        // Given
        queue.enqueueBatch([
            createStatement(),
            createStatement(),
            createStatement()
        ])
        XCTAssertEqual(queue.count, 3)
        
        // When
        queue.clear()
        
        // Then
        XCTAssertEqual(queue.count, 0)
        XCTAssertTrue(queue.isEmpty)
    }
    
    func testClearPriority_RemovesOnlySpecificPriority() {
        // Given
        queue.enqueue(createStatement(), priority: .high)
        queue.enqueue(createStatement(), priority: .normal)
        queue.enqueue(createStatement(), priority: .low)
        queue.enqueue(createStatement(), priority: .normal)
        
        // When
        queue.clear(priority: .normal)
        
        // Then
        XCTAssertEqual(queue.count, 2)
    }
    
    // MARK: - Peek Operations Tests
    
    func testPeek_ReturnsWithoutRemoving() {
        // Given
        let statement = createStatement()
        queue.enqueue(statement)
        
        // When
        let peeked = queue.peek()
        
        // Then
        XCTAssertNotNil(peeked)
        XCTAssertEqual(peeked?.id, statement.id)
        XCTAssertEqual(queue.count, 1) // Still in queue
    }
    
    func testPeekBatch_ReturnsWithoutRemoving() {
        // Given
        let statements = [
            createStatement(),
            createStatement(),
            createStatement()
        ]
        queue.enqueueBatch(statements)
        
        // When
        let peeked = queue.peekBatch(count: 2)
        
        // Then
        XCTAssertEqual(peeked.count, 2)
        XCTAssertEqual(queue.count, 3) // All still in queue
    }
    
    // MARK: - Publisher Tests
    
    func testQueueChanges_PublishesUpdates() {
        // Given
        let expectation = expectation(description: "Queue change received")
        var receivedChange: StatementQueue.QueueChange?
        
        queue.queueChanges
            .sink { change in
                receivedChange = change
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        // When
        queue.enqueue(createStatement())
        
        // Then
        waitForExpectations(timeout: 1.0)
        XCTAssertNotNil(receivedChange)
        XCTAssertEqual(receivedChange?.type, .enqueued)
        XCTAssertEqual(receivedChange?.count, 1)
    }
    
    // MARK: - Thread Safety Tests
    
    func testConcurrentAccess_ThreadSafe() {
        // Given
        let expectation = expectation(description: "Concurrent operations complete")
        expectation.expectedFulfillmentCount = 100
        
        // When
        DispatchQueue.concurrentPerform(iterations: 100) { index in
            if index % 2 == 0 {
                queue.enqueue(createStatement())
            } else {
                _ = queue.dequeue()
            }
            expectation.fulfill()
        }
        
        // Then
        waitForExpectations(timeout: 5.0)
        // Should complete without crashes
    }
    
    // MARK: - Statistics Tests
    
    func testStatistics_TracksMetrics() {
        // Given
        queue.enqueue(createStatement(), priority: .high)
        queue.enqueue(createStatement(), priority: .normal)
        queue.enqueue(createStatement(), priority: .normal)
        queue.enqueue(createStatement(), priority: .low)
        
        _ = queue.dequeue()
        _ = queue.dequeue()
        
        // When
        let stats = queue.statistics
        
        // Then
        XCTAssertEqual(stats.totalEnqueued, 4)
        XCTAssertEqual(stats.totalDequeued, 2)
        XCTAssertEqual(stats.currentSize, 2)
        XCTAssertEqual(stats.byPriority[.normal], 1)
        XCTAssertEqual(stats.byPriority[.low], 1)
    }
    
    // MARK: - Helper Methods
    
    private func createStatement(verb: XAPIVerb = .completed) -> XAPIStatement {
        return XAPIStatement(
            actor: XAPIActor(
                name: "Test User",
                mbox: "mailto:test@example.com"
            ),
            verb: verb,
            object: .activity(XAPIActivity(
                id: "https://example.com/activity/\(UUID())",
                definition: nil
            ))
        )
    }
} 