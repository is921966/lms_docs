//
//  OfflineStatementStoreTests.swift
//  LMSTests
//
//  Created on Sprint 42 Day 2 - Offline Support
//

import XCTest
import CoreData
import Combine
@testable import LMS

final class OfflineStatementStoreTests: XCTestCase {
    
    private var store: OfflineStatementStore!
    private var container: NSPersistentContainer!
    private var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        
        // Setup in-memory Core Data for testing
        container = NSPersistentContainer(name: "LMSDataModel")
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        container.persistentStoreDescriptions = [description]
        
        container.loadPersistentStores { _, error in
            XCTAssertNil(error)
        }
        
        store = OfflineStatementStore(container: container)
        cancellables = []
    }
    
    override func tearDown() {
        store = nil
        container = nil
        cancellables = nil
        super.tearDown()
    }
    
    // MARK: - Save Tests
    
    func testSaveStatement_Success() async throws {
        // Given
        let statement = createStatement()
        
        // When
        try await store.save(statement)
        
        // Then
        let pending = try await store.getAllPending()
        XCTAssertEqual(pending.count, 1)
        XCTAssertEqual(pending.first?.statementId, statement.id)
    }
    
    func testSaveStatement_WithPriority() async throws {
        // Given
        let statement = createStatement()
        
        // When
        try await store.save(statement, priority: .high)
        
        // Then
        let pending = try await store.getAllPending()
        XCTAssertEqual(pending.first?.priority, .high)
    }
    
    func testSaveMultipleStatements_PreservesOrder() async throws {
        // Given
        let statements = [
            createStatement(verb: .launched),
            createStatement(verb: .attempted),
            createStatement(verb: .completed)
        ]
        
        // When
        for statement in statements {
            try await store.save(statement)
        }
        
        // Then
        let pending = try await store.getAllPending()
        XCTAssertEqual(pending.count, 3)
        XCTAssertEqual(pending[0].statement.verb.id, statements[0].verb.id)
        XCTAssertEqual(pending[1].statement.verb.id, statements[1].verb.id)
        XCTAssertEqual(pending[2].statement.verb.id, statements[2].verb.id)
    }
    
    // MARK: - Retrieval Tests
    
    func testGetAllPending_EmptyStore_ReturnsEmpty() async throws {
        // When
        let pending = try await store.getAllPending()
        
        // Then
        XCTAssertTrue(pending.isEmpty)
    }
    
    func testGetPendingByPriority_ReturnsInOrder() async throws {
        // Given
        try await store.save(createStatement(), priority: .low)
        try await store.save(createStatement(), priority: .high)
        try await store.save(createStatement(), priority: .normal)
        
        // When
        let pending = try await store.getPendingByPriority()
        
        // Then
        XCTAssertEqual(pending.count, 3)
        XCTAssertEqual(pending[0].priority, .high)
        XCTAssertEqual(pending[1].priority, .normal)
        XCTAssertEqual(pending[2].priority, .low)
    }
    
    func testGetPendingCount() async throws {
        // Given
        try await store.save(createStatement())
        try await store.save(createStatement())
        
        // When
        let count = try await store.getPendingCount()
        
        // Then
        XCTAssertEqual(count, 2)
    }
    
    // MARK: - Update Tests
    
    func testMarkAsSynced_Success() async throws {
        // Given
        let statement = createStatement()
        try await store.save(statement)
        
        // When
        try await store.markAsSynced(statementId: statement.id!)
        
        // Then
        let pending = try await store.getAllPending()
        XCTAssertTrue(pending.isEmpty)
        
        let synced = try await store.getSyncedCount()
        XCTAssertEqual(synced, 1)
    }
    
    func testMarkAsFailed_IncrementsRetryCount() async throws {
        // Given
        let statement = createStatement()
        try await store.save(statement)
        
        // When
        let error = NSError(domain: "Test", code: 500, userInfo: nil)
        try await store.markAsFailed(statementId: statement.id!, error: error)
        
        // Then
        let pending = try await store.getAllPending()
        XCTAssertEqual(pending.first?.retryCount, 1)
        XCTAssertEqual(pending.first?.lastError, error.localizedDescription)
    }
    
    func testUpdateSyncStatus() async throws {
        // Given
        let statement = createStatement()
        try await store.save(statement)
        
        // When
        try await store.updateSyncStatus(statementId: statement.id!, status: .syncing)
        
        // Then
        let pending = try await store.getAllPending()
        XCTAssertEqual(pending.first?.syncStatus, .syncing)
    }
    
    // MARK: - Delete Tests
    
    func testDeleteStatement() async throws {
        // Given
        let statement = createStatement()
        try await store.save(statement)
        
        // When
        try await store.delete(statementId: statement.id!)
        
        // Then
        let pending = try await store.getAllPending()
        XCTAssertTrue(pending.isEmpty)
    }
    
    func testDeleteAllPending() async throws {
        // Given
        try await store.save(createStatement())
        try await store.save(createStatement())
        try await store.save(createStatement())
        
        // When
        try await store.deleteAllPending()
        
        // Then
        let count = try await store.getPendingCount()
        XCTAssertEqual(count, 0)
    }
    
    func testDeleteOldSynced_RemovesOlderThan30Days() async throws {
        // Given
        let oldStatement = createStatement()
        try await store.save(oldStatement)
        try await store.markAsSynced(statementId: oldStatement.id!)
        
        // Manually update the syncedAt date to 31 days ago
        let context = container.viewContext
        let request = NSFetchRequest<NSManagedObject>(entityName: "PendingStatement")
        request.predicate = NSPredicate(format: "id == %@", oldStatement.id! as CVarArg)
        
        if let entity = try context.fetch(request).first {
            entity.setValue(Date().addingTimeInterval(-31 * 24 * 60 * 60), forKey: "syncedAt")
            try context.save()
        }
        
        // When
        try await store.deleteOldSynced(olderThan: 30)
        
        // Then
        let synced = try await store.getSyncedCount()
        XCTAssertEqual(synced, 0)
    }
    
    // MARK: - Batch Operations Tests
    
    func testBatchSave() async throws {
        // Given
        let statements = [
            createStatement(),
            createStatement(),
            createStatement()
        ]
        
        // When
        try await store.batchSave(statements)
        
        // Then
        let count = try await store.getPendingCount()
        XCTAssertEqual(count, 3)
    }
    
    func testGetBatch_ReturnsRequestedCount() async throws {
        // Given
        for _ in 0..<10 {
            try await store.save(createStatement())
        }
        
        // When
        let batch = try await store.getBatch(limit: 5)
        
        // Then
        XCTAssertEqual(batch.count, 5)
    }
    
    // MARK: - Publisher Tests
    
    func testPendingCountPublisher() {
        // Given
        let expectation = expectation(description: "Count updated")
        var receivedCounts: [Int] = []
        
        store.pendingCountPublisher
            .sink { count in
                receivedCounts.append(count)
                if receivedCounts.count == 2 {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        // When
        Task {
            try await store.save(createStatement())
            try await store.save(createStatement())
        }
        
        // Then
        waitForExpectations(timeout: 2.0)
        XCTAssertEqual(receivedCounts, [1, 2])
    }
    
    // MARK: - Error Handling Tests
    
    func testSaveInvalidStatement_ThrowsError() async {
        // Given
        var statement = createStatement()
        statement.id = nil // Invalid - no ID
        
        // When/Then
        do {
            try await store.save(statement)
            XCTFail("Expected error")
        } catch {
            XCTAssertTrue(error is OfflineStatementStore.StoreError)
        }
    }
    
    // MARK: - Performance Tests
    
    func testPerformanceSave1000Statements() {
        measure {
            let expectation = expectation(description: "Save completed")
            
            Task {
                for _ in 0..<1000 {
                    try await store.save(createStatement())
                }
                expectation.fulfill()
            }
            
            wait(for: [expectation], timeout: 10.0)
        }
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