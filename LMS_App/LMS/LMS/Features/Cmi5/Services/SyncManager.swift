//
//  SyncManager.swift
//  LMS
//
//  Created on Sprint 42 Day 2 - Sync Management
//

import Foundation
import Network
import Combine
import BackgroundTasks

// MARK: - Protocols

public protocol StatementProcessorProtocol {
    func processStatement(_ statement: XAPIStatement) async throws -> String
    func processBatch(_ batch: [OfflineStatementStore.PendingStatement]) async throws
}

public protocol NetworkMonitorProtocol {
    var isNetworkAvailable: Bool { get }
    var networkStatusPublisher: AnyPublisher<Bool, Never> { get }
}

// MARK: - Sync Manager

/// Менеджер для синхронизации офлайн xAPI statements
public final class SyncManager {
    
    // MARK: - Types
    
    public enum SyncStatus: Equatable {
        case idle
        case syncing
        case waiting // Waiting for network
        case failed(Error)
        
        public static func == (lhs: SyncStatus, rhs: SyncStatus) -> Bool {
            switch (lhs, rhs) {
            case (.idle, .idle), (.syncing, .syncing), (.waiting, .waiting):
                return true
            case (.failed, .failed):
                return true // Consider all errors equal for simplicity
            default:
                return false
            }
        }
    }
    
    public struct SyncStatistics {
        public let totalSynced: Int
        public let totalFailed: Int
        public let successRate: Double
        public let lastSyncDate: Date?
        public let averageSyncTime: TimeInterval
    }
    
    // MARK: - Properties
    
    private let store: OfflineStatementStoreProtocol
    private let processor: StatementProcessorProtocol
    private let networkMonitor: NetworkMonitorProtocol
    
    // Sync configuration
    private let batchSize = 10
    private let lowPowerBatchSize = 5
    private let maxRetryAttempts = 3
    private let backgroundSyncInterval: TimeInterval = 300 // 5 minutes
    
    // State
    @Published public private(set) var syncStatus: SyncStatus = .idle
    @Published public private(set) var progress: Double = 0.0
    @Published public private(set) var statistics = SyncStatistics(
        totalSynced: 0,
        totalFailed: 0,
        successRate: 1.0,
        lastSyncDate: nil,
        averageSyncTime: 0
    )
    
    private var isLowPowerMode = false
    private var currentSyncTask: Task<Void, Never>?
    private var cancellables = Set<AnyCancellable>()
    
    // Background task
    private let backgroundTaskIdentifier = "com.lms.sync.statements"
    public private(set) var isBackgroundSyncEnabled = false
    
    // Publishers
    public var syncStatusPublisher: AnyPublisher<SyncStatus, Never> {
        $syncStatus.eraseToAnyPublisher()
    }
    
    public var progressPublisher: AnyPublisher<Double, Never> {
        $progress.eraseToAnyPublisher()
    }
    
    // MARK: - Initialization
    
    public init(
        store: OfflineStatementStoreProtocol,
        processor: StatementProcessorProtocol,
        networkMonitor: NetworkMonitorProtocol
    ) {
        self.store = store
        self.processor = processor
        self.networkMonitor = networkMonitor
        
        setupNetworkMonitoring()
        registerBackgroundTask()
    }
    
    // MARK: - Public Methods
    
    public func startManualSync() async {
        guard networkMonitor.isNetworkAvailable else {
            syncStatus = .waiting
            return
        }
        
        await performSync()
    }
    
    public func cancelCurrentSync() {
        currentSyncTask?.cancel()
        syncStatus = .idle
        progress = 0.0
    }
    
    public func retryFailedStatements() async {
        guard networkMonitor.isNetworkAvailable else { return }
        
        // Implementation would retry failed statements
        // For now, just trigger a regular sync
        await performSync()
    }
    
    public func setLowPowerMode(_ enabled: Bool) {
        isLowPowerMode = enabled
    }
    
    public func calculateRetryDelay(attempt: Int) -> TimeInterval {
        // Exponential backoff: 1s, 2s, 4s, 8s...
        return pow(2.0, Double(attempt - 1))
    }
    
    // MARK: - Background Sync
    
    public func performBackgroundSync() async {
        guard networkMonitor.isNetworkAvailable else { return }
        
        let batchSize = isLowPowerMode ? lowPowerBatchSize : self.batchSize
        
        do {
            var hasMore = true
            while hasMore {
                let batch = try await store.getBatch(limit: batchSize)
                if batch.isEmpty {
                    hasMore = false
                    break
                }
                
                try await processor.processBatch(batch)
                
                // Mark as synced
                for statement in batch {
                    try await store.markAsSynced(statementId: statement.statementId)
                }
            }
        } catch {
            print("Background sync error: \(error)")
        }
    }
    
    // MARK: - Private Methods
    
    private func setupNetworkMonitoring() {
        networkMonitor.networkStatusPublisher
            .sink { [weak self] isAvailable in
                if isAvailable && self?.syncStatus == .waiting {
                    Task {
                        await self?.performSync()
                    }
                }
            }
            .store(in: &cancellables)
    }
    
    private func registerBackgroundTask() {
        BGTaskScheduler.shared.register(
            forTaskWithIdentifier: backgroundTaskIdentifier,
            using: nil
        ) { [weak self] task in
            guard let self = self else { return }
            
            Task {
                await self.performBackgroundSync()
                task.setTaskCompleted(success: true)
            }
        }
        
        scheduleBackgroundSync()
        isBackgroundSyncEnabled = true
    }
    
    private func scheduleBackgroundSync() {
        let request = BGProcessingTaskRequest(identifier: backgroundTaskIdentifier)
        request.earliestBeginDate = Date(timeIntervalSinceNow: backgroundSyncInterval)
        request.requiresNetworkConnectivity = true
        request.requiresExternalPower = false
        
        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            print("Failed to schedule background sync: \(error)")
        }
    }
    
    private func performSync() async {
        syncStatus = .syncing
        progress = 0.0
        
        let startTime = Date()
        var syncedCount = 0
        var failedCount = 0
        
        currentSyncTask = Task {
            do {
                let pendingStatements = try await store.getAllPending()
                let total = pendingStatements.count
                
                // Remove duplicates (conflict resolution)
                let uniqueStatements = resolveDuplicates(pendingStatements)
                
                for (index, pendingStatement) in uniqueStatements.enumerated() {
                    // Check for cancellation
                    if Task.isCancelled { break }
                    
                    do {
                        _ = try await processor.processStatement(pendingStatement.statement)
                        try await store.markAsSynced(statementId: pendingStatement.statementId)
                        syncedCount += 1
                    } catch {
                        try await store.markAsFailed(statementId: pendingStatement.statementId, error: error)
                        failedCount += 1
                    }
                    
                    // Update progress
                    progress = Double(index + 1) / Double(total)
                }
                
                // Update statistics
                updateStatistics(
                    synced: syncedCount,
                    failed: failedCount,
                    duration: Date().timeIntervalSince(startTime)
                )
                
                syncStatus = .idle
                progress = 1.0
                
                // Schedule next background sync
                scheduleBackgroundSync()
                
            } catch {
                syncStatus = .failed(error)
            }
        }
        
        await currentSyncTask?.value
    }
    
    private func resolveDuplicates(_ statements: [OfflineStatementStore.PendingStatement]) -> [OfflineStatementStore.PendingStatement] {
        // Last-write-wins strategy
        var uniqueMap: [String: OfflineStatementStore.PendingStatement] = [:]
        
        for statement in statements {
            if let existing = uniqueMap[statement.statementId] {
                // Keep the one with later timestamp
                if (statement.statement.timestamp ?? Date()) > (existing.statement.timestamp ?? Date()) {
                    uniqueMap[statement.statementId] = statement
                }
            } else {
                uniqueMap[statement.statementId] = statement
            }
        }
        
        return Array(uniqueMap.values)
    }
    
    private func updateStatistics(synced: Int, failed: Int, duration: TimeInterval) {
        let total = statistics.totalSynced + statistics.totalFailed + synced + failed
        let newTotalSynced = statistics.totalSynced + synced
        let newTotalFailed = statistics.totalFailed + failed
        
        let successRate = total > 0 ? Double(newTotalSynced) / Double(total) : 1.0
        
        // Calculate average sync time
        let previousTotal = statistics.totalSynced + statistics.totalFailed
        let newAverage: TimeInterval
        if previousTotal > 0 {
            let totalTime = statistics.averageSyncTime * Double(previousTotal) + duration
            newAverage = totalTime / Double(total)
        } else {
            newAverage = duration
        }
        
        statistics = SyncStatistics(
            totalSynced: newTotalSynced,
            totalFailed: newTotalFailed,
            successRate: successRate,
            lastSyncDate: Date(),
            averageSyncTime: newAverage
        )
    }
}

// MARK: - Default Network Monitor

extension SyncManager {
    /// Default network monitor using NWPathMonitor
    public class DefaultNetworkMonitor: NetworkMonitorProtocol {
        private let monitor = NWPathMonitor()
        private let queue = DispatchQueue(label: "com.lms.networkmonitor")
        
        @Published private var _isNetworkAvailable = false
        public var isNetworkAvailable: Bool {
            _isNetworkAvailable
        }
        
        public var networkStatusPublisher: AnyPublisher<Bool, Never> {
            $_isNetworkAvailable.eraseToAnyPublisher()
        }
        
        init() {
            monitor.pathUpdateHandler = { [weak self] path in
                self?._isNetworkAvailable = path.status == .satisfied
            }
            monitor.start(queue: queue)
        }
        
        deinit {
            monitor.cancel()
        }
    }
} 