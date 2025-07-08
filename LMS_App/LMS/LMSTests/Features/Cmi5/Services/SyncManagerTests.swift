//
//  SyncManagerTests.swift
//  LMSTests
//
//  Created on Sprint 42 Day 2 - Sync Management
//

import XCTest
import Network
import Combine
@testable import LMS

final class SyncManagerTests: XCTestCase {
    
    private var syncManager: SyncManager!
    private var mockStore: MockOfflineStore!
    private var mockProcessor: MockStatementProcessor!
    private var mockNetworkMonitor: MockNetworkMonitor!
    private var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        
        mockStore = MockOfflineStore()
        mockProcessor = MockStatementProcessor()
        mockNetworkMonitor = MockNetworkMonitor()
        
        syncManager = SyncManager(
            store: mockStore,
            processor: mockProcessor,
            networkMonitor: mockNetworkMonitor
        )
        
        cancellables = []
    }
    
    override func tearDown() {
        syncManager = nil
        mockStore = nil
        mockProcessor = nil
        mockNetworkMonitor = nil
        cancellables = nil
        super.tearDown()
    }
    
    // MARK: - Initialization Tests
    
    func testInit_StartsMonitoringNetwork() {
        // Then
        XCTAssertTrue(mockNetworkMonitor.isMonitoring)
    }
    
    func testInit_SchedulesBackgroundSync() {
        // Then
        XCTAssertTrue(syncManager.isBackgroundSyncEnabled)
    }
    
    // MARK: - Network Change Tests
    
    func testNetworkBecomesAvailable_TriggersSync() {
        // Given
        let expectation = expectation(description: "Sync triggered")
        mockStore.pendingStatements = [createPendingStatement()]
        
        syncManager.syncStatusPublisher
            .filter { $0 == .syncing }
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        // When
        mockNetworkMonitor.simulateNetworkChange(isAvailable: true)
        
        // Then
        waitForExpectations(timeout: 2.0)
    }
    
    func testNetworkBecomesUnavailable_StopsSync() {
        // Given
        syncManager.startManualSync()
        
        // When
        mockNetworkMonitor.simulateNetworkChange(isAvailable: false)
        
        // Then
        XCTAssertEqual(syncManager.syncStatus, .waiting)
    }
    
    // MARK: - Manual Sync Tests
    
    func testStartManualSync_WithNetwork_Success() async {
        // Given
        mockNetworkMonitor.isNetworkAvailable = true
        let statements = [
            createPendingStatement(),
            createPendingStatement(),
            createPendingStatement()
        ]
        mockStore.pendingStatements = statements
        
        // When
        await syncManager.startManualSync()
        
        // Then
        XCTAssertEqual(mockProcessor.processedStatements.count, 3)
        XCTAssertEqual(mockStore.syncedStatementIds.count, 3)
        XCTAssertEqual(syncManager.syncStatus, .idle)
    }
    
    func testStartManualSync_WithoutNetwork_Fails() async {
        // Given
        mockNetworkMonitor.isNetworkAvailable = false
        
        // When
        await syncManager.startManualSync()
        
        // Then
        XCTAssertEqual(syncManager.syncStatus, .waiting)
        XCTAssertTrue(mockProcessor.processedStatements.isEmpty)
    }
    
    func testStartManualSync_PartialFailure_RetriesLater() async {
        // Given
        mockNetworkMonitor.isNetworkAvailable = true
        let statements = [
            createPendingStatement(id: "1"),
            createPendingStatement(id: "2"),
            createPendingStatement(id: "3")
        ]
        mockStore.pendingStatements = statements
        mockProcessor.shouldFailIds = ["2"] // Middle one fails
        
        // When
        await syncManager.startManualSync()
        
        // Then
        XCTAssertEqual(mockStore.syncedStatementIds.count, 2)
        XCTAssertEqual(mockStore.failedStatementIds.count, 1)
        XCTAssertTrue(mockStore.failedStatementIds.contains("2"))
    }
    
    // MARK: - Background Sync Tests
    
    func testBackgroundSync_ProcessesBatches() async {
        // Given
        mockNetworkMonitor.isNetworkAvailable = true
        for _ in 0..<25 {
            mockStore.pendingStatements.append(createPendingStatement())
        }
        
        // When
        await syncManager.performBackgroundSync()
        
        // Then
        // Should process in batches of 10
        XCTAssertEqual(mockProcessor.processedBatches.count, 3)
        XCTAssertEqual(mockProcessor.processedBatches[0].count, 10)
        XCTAssertEqual(mockProcessor.processedBatches[1].count, 10)
        XCTAssertEqual(mockProcessor.processedBatches[2].count, 5)
    }
    
    func testBackgroundSync_RespectsEnergyEfficiency() async {
        // Given
        mockNetworkMonitor.isNetworkAvailable = true
        mockStore.pendingStatements = Array(repeating: createPendingStatement(), count: 100)
        syncManager.setLowPowerMode(true)
        
        // When
        await syncManager.performBackgroundSync()
        
        // Then
        // In low power mode, should process smaller batches
        XCTAssertEqual(mockProcessor.processedBatches.first?.count, 5)
    }
    
    // MARK: - Conflict Resolution Tests
    
    func testConflictResolution_LastWriteWins() async {
        // Given
        let statement1 = createPendingStatement(id: "conflict", timestamp: Date())
        let statement2 = createPendingStatement(id: "conflict", timestamp: Date().addingTimeInterval(60))
        
        mockStore.pendingStatements = [statement1, statement2]
        
        // When
        await syncManager.startManualSync()
        
        // Then
        XCTAssertEqual(mockProcessor.processedStatements.count, 1)
        XCTAssertEqual(mockProcessor.processedStatements.first?.statement.timestamp, statement2.statement.timestamp)
    }
    
    // MARK: - Progress Tracking Tests
    
    func testSyncProgress_UpdatesDuringSync() {
        // Given
        let expectation = expectation(description: "Progress updates")
        var progressValues: [Double] = []
        
        mockStore.pendingStatements = Array(repeating: createPendingStatement(), count: 10)
        
        syncManager.progressPublisher
            .sink { progress in
                progressValues.append(progress)
                if progress >= 1.0 {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        // When
        Task {
            await syncManager.startManualSync()
        }
        
        // Then
        waitForExpectations(timeout: 2.0)
        XCTAssertGreaterThan(progressValues.count, 2)
        XCTAssertEqual(progressValues.last, 1.0)
    }
    
    // MARK: - Statistics Tests
    
    func testSyncStatistics_TracksMetrics() async {
        // Given
        mockNetworkMonitor.isNetworkAvailable = true
        mockStore.pendingStatements = [
            createPendingStatement(),
            createPendingStatement(),
            createPendingStatement()
        ]
        mockProcessor.shouldFailIds = ["2"]
        
        // When
        await syncManager.startManualSync()
        let stats = syncManager.statistics
        
        // Then
        XCTAssertEqual(stats.totalSynced, 2)
        XCTAssertEqual(stats.totalFailed, 1)
        XCTAssertEqual(stats.successRate, 0.67, accuracy: 0.01)
        XCTAssertNotNil(stats.lastSyncDate)
    }
    
    // MARK: - Retry Logic Tests
    
    func testRetryFailedStatements_AfterDelay() async {
        // Given
        let failedStatement = createPendingStatement(id: "retry-me")
        mockStore.failedStatements = [failedStatement]
        mockProcessor.shouldFailIds = [] // Will succeed on retry
        
        // When
        await syncManager.retryFailedStatements()
        
        // Then
        XCTAssertTrue(mockStore.syncedStatementIds.contains("retry-me"))
        XCTAssertTrue(mockStore.failedStatements.isEmpty)
    }
    
    func testExponentialBackoff_IncreasesDelay() {
        // Given
        let retryDelays = [
            syncManager.calculateRetryDelay(attempt: 1),
            syncManager.calculateRetryDelay(attempt: 2),
            syncManager.calculateRetryDelay(attempt: 3)
        ]
        
        // Then
        XCTAssertEqual(retryDelays[0], 1.0)
        XCTAssertEqual(retryDelays[1], 2.0)
        XCTAssertEqual(retryDelays[2], 4.0)
    }
    
    // MARK: - Cancellation Tests
    
    func testCancelSync_StopsProcessing() async {
        // Given
        mockStore.pendingStatements = Array(repeating: createPendingStatement(), count: 100)
        
        // When
        Task {
            await syncManager.startManualSync()
        }
        
        // Cancel after short delay
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 second
        syncManager.cancelCurrentSync()
        
        // Then
        XCTAssertLessThan(mockProcessor.processedStatements.count, 100)
        XCTAssertEqual(syncManager.syncStatus, .idle)
    }
    
    // MARK: - Helper Methods
    
    private func createPendingStatement(
        id: String = UUID().uuidString,
        timestamp: Date = Date()
    ) -> OfflineStatementStore.PendingStatement {
        var statement = XAPIStatement(
            actor: XAPIActor(name: "Test", mbox: "mailto:test@example.com"),
            verb: XAPIVerb.completed,
            object: .activity(XAPIActivity(id: "test-activity", definition: nil))
        )
        statement.id = id
        statement.timestamp = timestamp
        
        return OfflineStatementStore.PendingStatement(
            statementId: id,
            statement: statement,
            priority: .normal,
            createdAt: Date(),
            syncStatus: .pending,
            retryCount: 0,
            lastError: nil
        )
    }
}

// MARK: - Mock Classes

class MockOfflineStore: OfflineStatementStoreProtocol {
    var pendingStatements: [OfflineStatementStore.PendingStatement] = []
    var failedStatements: [OfflineStatementStore.PendingStatement] = []
    var syncedStatementIds: Set<String> = []
    var failedStatementIds: Set<String> = []
    
    func getAllPending() async throws -> [OfflineStatementStore.PendingStatement] {
        return pendingStatements
    }
    
    func markAsSynced(statementId: String) async throws {
        syncedStatementIds.insert(statementId)
        pendingStatements.removeAll { $0.statementId == statementId }
    }
    
    func markAsFailed(statementId: String, error: Error) async throws {
        failedStatementIds.insert(statementId)
    }
    
    func getBatch(limit: Int) async throws -> [OfflineStatementStore.PendingStatement] {
        return Array(pendingStatements.prefix(limit))
    }
}

class MockStatementProcessor: StatementProcessorProtocol {
    var processedStatements: [OfflineStatementStore.PendingStatement] = []
    var processedBatches: [[OfflineStatementStore.PendingStatement]] = []
    var shouldFailIds: Set<String> = []
    
    func processStatement(_ statement: XAPIStatement) async throws -> String {
        let pendingStatement = OfflineStatementStore.PendingStatement(
            statementId: statement.id!,
            statement: statement,
            priority: .normal,
            createdAt: Date(),
            syncStatus: .pending,
            retryCount: 0,
            lastError: nil
        )
        
        if shouldFailIds.contains(statement.id!) {
            throw NSError(domain: "Test", code: 500, userInfo: nil)
        }
        
        processedStatements.append(pendingStatement)
        return statement.id!
    }
    
    func processBatch(_ batch: [OfflineStatementStore.PendingStatement]) async throws {
        processedBatches.append(batch)
        for pending in batch {
            try await processStatement(pending.statement)
        }
    }
}

class MockNetworkMonitor: NetworkMonitorProtocol {
    var isNetworkAvailable = true
    var isMonitoring = true
    private let networkStatusSubject = PassthroughSubject<Bool, Never>()
    
    var networkStatusPublisher: AnyPublisher<Bool, Never> {
        networkStatusSubject.eraseToAnyPublisher()
    }
    
    func simulateNetworkChange(isAvailable: Bool) {
        isNetworkAvailable = isAvailable
        networkStatusSubject.send(isAvailable)
    }
} 