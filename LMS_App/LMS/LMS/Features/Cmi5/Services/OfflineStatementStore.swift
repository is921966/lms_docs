//
//  OfflineStatementStore.swift
//  LMS
//
//  Created on Sprint 42 Day 2 - Offline Support
//

import Foundation
import CoreData
import Combine

/// Протокол для хранилища офлайн statements
public protocol OfflineStatementStoreProtocol {
    func save(_ statement: XAPIStatement, priority: OfflineStatementStore.Priority) async throws
    func getAllPending() async throws -> [OfflineStatementStore.PendingStatement]
    func getBatch(limit: Int) async throws -> [OfflineStatementStore.PendingStatement]
    func markAsSynced(statementId: String) async throws
    func markAsFailed(statementId: String, error: Error) async throws
    var pendingCountPublisher: AnyPublisher<Int, Never> { get }
}

/// Хранилище для офлайн xAPI statements
public final class OfflineStatementStore {
    
    // MARK: - Types
    
    public enum StoreError: LocalizedError {
        case invalidStatement
        case saveFailure(Error)
        case fetchFailure(Error)
        case notFound
        case corruptedData
        
        public var errorDescription: String? {
            switch self {
            case .invalidStatement:
                return "Invalid statement: missing required fields"
            case .saveFailure(let error):
                return "Failed to save statement: \(error.localizedDescription)"
            case .fetchFailure(let error):
                return "Failed to fetch statements: \(error.localizedDescription)"
            case .notFound:
                return "Statement not found"
            case .corruptedData:
                return "Corrupted data in storage"
            }
        }
    }
    
    public enum SyncStatus: String {
        case pending = "pending"
        case syncing = "syncing"
        case synced = "synced"
        case failed = "failed"
    }
    
    public enum Priority: Int16, Comparable {
        case low = 0
        case normal = 1
        case high = 2
        
        public static func < (lhs: Priority, rhs: Priority) -> Bool {
            lhs.rawValue < rhs.rawValue
        }
    }
    
    public struct PendingStatement {
        public let statementId: String
        public let statement: XAPIStatement
        public let priority: Priority
        public let createdAt: Date
        public let syncStatus: SyncStatus
        public let retryCount: Int
        public let lastError: String?
    }
    
    // MARK: - Properties
    
    private let container: NSPersistentContainer
    private let backgroundContext: NSManagedObjectContext
    
    // Publishers
    private let pendingCountSubject = CurrentValueSubject<Int, Never>(0)
    public var pendingCountPublisher: AnyPublisher<Int, Never> {
        pendingCountSubject.eraseToAnyPublisher()
    }
    
    // MARK: - Initialization
    
    public init(container: NSPersistentContainer) {
        self.container = container
        self.backgroundContext = container.newBackgroundContext()
        
        // Initial count update
        Task {
            await updatePendingCount()
        }
    }
    
    // MARK: - Save Operations
    
    public func save(_ statement: XAPIStatement, priority: Priority = .normal) async throws {
        guard let statementId = statement.id else {
            throw StoreError.invalidStatement
        }
        
        let encodedStatement = try encodeStatement(statement)
        
        return try await withCheckedThrowingContinuation { continuation in
            backgroundContext.perform { [weak self] in
                guard let self = self else { 
                    continuation.resume(throwing: StoreError.saveFailure(NSError(domain: "OfflineStore", code: 0)))
                    return
                }
                
                let entity = NSEntityDescription.entity(forEntityName: "PendingStatement", in: self.backgroundContext)!
                let pendingStatement = NSManagedObject(entity: entity, insertInto: self.backgroundContext)
                
                // Set properties
                pendingStatement.setValue(statementId, forKey: "id")
                pendingStatement.setValue(encodedStatement, forKey: "statementJSON")
                pendingStatement.setValue(priority.rawValue, forKey: "priority")
                pendingStatement.setValue(Date(), forKey: "createdAt")
                pendingStatement.setValue(SyncStatus.pending.rawValue, forKey: "syncStatus")
                pendingStatement.setValue(0, forKey: "retryCount")
                
                do {
                    try self.backgroundContext.save()
                    Task {
                        await self.updatePendingCount()
                    }
                    continuation.resume()
                } catch {
                    continuation.resume(throwing: StoreError.saveFailure(error))
                }
            }
        }
    }
    
    public func batchSave(_ statements: [XAPIStatement], priority: Priority = .normal) async throws {
        let encodedStatements = try statements.compactMap { statement -> (String, String)? in
            guard let id = statement.id else { return nil }
            return (id, try encodeStatement(statement))
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            backgroundContext.perform { [weak self] in
                guard let self = self else {
                    continuation.resume(throwing: StoreError.saveFailure(NSError(domain: "OfflineStore", code: 0)))
                    return
                }
                
                for (statementId, encodedStatement) in encodedStatements {
                    let entity = NSEntityDescription.entity(forEntityName: "PendingStatement", in: self.backgroundContext)!
                    let pendingStatement = NSManagedObject(entity: entity, insertInto: self.backgroundContext)
                    
                    pendingStatement.setValue(statementId, forKey: "id")
                    pendingStatement.setValue(encodedStatement, forKey: "statementJSON")
                    pendingStatement.setValue(priority.rawValue, forKey: "priority")
                    pendingStatement.setValue(Date(), forKey: "createdAt")
                    pendingStatement.setValue(SyncStatus.pending.rawValue, forKey: "syncStatus")
                    pendingStatement.setValue(0, forKey: "retryCount")
                }
                
                do {
                    try self.backgroundContext.save()
                    Task {
                        await self.updatePendingCount()
                    }
                    continuation.resume()
                } catch {
                    continuation.resume(throwing: StoreError.saveFailure(error))
                }
            }
        }
    }
    
    // MARK: - Retrieval Operations
    
    public func getAllPending() async throws -> [PendingStatement] {
        return try await withCheckedThrowingContinuation { continuation in
            backgroundContext.perform { [weak self] in
                guard let self = self else {
                    continuation.resume(throwing: StoreError.fetchFailure(NSError(domain: "OfflineStore", code: 0)))
                    return
                }
                
                let request = NSFetchRequest<NSManagedObject>(entityName: "PendingStatement")
                request.predicate = NSPredicate(format: "syncStatus != %@", SyncStatus.synced.rawValue)
                request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: true)]
                
                do {
                    let results = try self.backgroundContext.fetch(request)
                    let pendingStatements = try results.compactMap { try self.convertToPendingStatement($0) }
                    continuation.resume(returning: pendingStatements)
                } catch {
                    continuation.resume(throwing: StoreError.fetchFailure(error))
                }
            }
        }
    }
    
    public func getPendingByPriority() async throws -> [PendingStatement] {
        return try await withCheckedThrowingContinuation { continuation in
            backgroundContext.perform { [weak self] in
                guard let self = self else {
                    continuation.resume(throwing: StoreError.fetchFailure(NSError(domain: "OfflineStore", code: 0)))
                    return
                }
                
                let request = NSFetchRequest<NSManagedObject>(entityName: "PendingStatement")
                request.predicate = NSPredicate(format: "syncStatus != %@", SyncStatus.synced.rawValue)
                request.sortDescriptors = [
                    NSSortDescriptor(key: "priority", ascending: false),
                    NSSortDescriptor(key: "createdAt", ascending: true)
                ]
                
                do {
                    let results = try self.backgroundContext.fetch(request)
                    let pendingStatements = try results.compactMap { try self.convertToPendingStatement($0) }
                    continuation.resume(returning: pendingStatements)
                } catch {
                    continuation.resume(throwing: StoreError.fetchFailure(error))
                }
            }
        }
    }
    
    public func getBatch(limit: Int) async throws -> [PendingStatement] {
        return try await withCheckedThrowingContinuation { continuation in
            backgroundContext.perform { [weak self] in
                guard let self = self else {
                    continuation.resume(throwing: StoreError.fetchFailure(NSError(domain: "OfflineStore", code: 0)))
                    return
                }
                
                let request = NSFetchRequest<NSManagedObject>(entityName: "PendingStatement")
                request.predicate = NSPredicate(format: "syncStatus == %@", SyncStatus.pending.rawValue)
                request.sortDescriptors = [
                    NSSortDescriptor(key: "priority", ascending: false),
                    NSSortDescriptor(key: "createdAt", ascending: true)
                ]
                request.fetchLimit = limit
                
                do {
                    let results = try self.backgroundContext.fetch(request)
                    let pendingStatements = try results.compactMap { try self.convertToPendingStatement($0) }
                    continuation.resume(returning: pendingStatements)
                } catch {
                    continuation.resume(throwing: StoreError.fetchFailure(error))
                }
            }
        }
    }
    
    public func getPendingCount() async throws -> Int {
        return try await withCheckedThrowingContinuation { continuation in
            backgroundContext.perform { [weak self] in
                guard let self = self else {
                    continuation.resume(throwing: StoreError.fetchFailure(NSError(domain: "OfflineStore", code: 0)))
                    return
                }
                
                let request = NSFetchRequest<NSManagedObject>(entityName: "PendingStatement")
                request.predicate = NSPredicate(format: "syncStatus != %@", SyncStatus.synced.rawValue)
                
                do {
                    let count = try self.backgroundContext.count(for: request)
                    continuation.resume(returning: count)
                } catch {
                    continuation.resume(throwing: StoreError.fetchFailure(error))
                }
            }
        }
    }
    
    public func getSyncedCount() async throws -> Int {
        return try await withCheckedThrowingContinuation { continuation in
            backgroundContext.perform { [weak self] in
                guard let self = self else {
                    continuation.resume(throwing: StoreError.fetchFailure(NSError(domain: "OfflineStore", code: 0)))
                    return
                }
                
                let request = NSFetchRequest<NSManagedObject>(entityName: "PendingStatement")
                request.predicate = NSPredicate(format: "syncStatus == %@", SyncStatus.synced.rawValue)
                
                do {
                    let count = try self.backgroundContext.count(for: request)
                    continuation.resume(returning: count)
                } catch {
                    continuation.resume(throwing: StoreError.fetchFailure(error))
                }
            }
        }
    }
    
    // MARK: - Update Operations
    
    public func markAsSynced(statementId: String) async throws {
        try await updateStatement(id: statementId) { entity in
            entity.setValue(SyncStatus.synced.rawValue, forKey: "syncStatus")
            entity.setValue(Date(), forKey: "syncedAt")
        }
    }
    
    public func markAsFailed(statementId: String, error: Error) async throws {
        try await updateStatement(id: statementId) { entity in
            entity.setValue(SyncStatus.failed.rawValue, forKey: "syncStatus")
            let currentRetryCount = entity.value(forKey: "retryCount") as? Int16 ?? 0
            entity.setValue(currentRetryCount + 1, forKey: "retryCount")
            entity.setValue(error.localizedDescription, forKey: "lastError")
        }
    }
    
    public func updateSyncStatus(statementId: String, status: SyncStatus) async throws {
        try await updateStatement(id: statementId) { entity in
            entity.setValue(status.rawValue, forKey: "syncStatus")
        }
    }
    
    // MARK: - Delete Operations
    
    public func delete(statementId: String) async throws {
        return try await withCheckedThrowingContinuation { continuation in
            backgroundContext.perform { [weak self] in
                guard let self = self else {
                    continuation.resume(throwing: StoreError.saveFailure(NSError(domain: "OfflineStore", code: 0)))
                    return
                }
                
                let request = NSFetchRequest<NSManagedObject>(entityName: "PendingStatement")
                request.predicate = NSPredicate(format: "id == %@", statementId)
                
                do {
                    let results = try self.backgroundContext.fetch(request)
                    for object in results {
                        self.backgroundContext.delete(object)
                    }
                    try self.backgroundContext.save()
                    Task {
                        await self.updatePendingCount()
                    }
                    continuation.resume()
                } catch {
                    continuation.resume(throwing: StoreError.saveFailure(error))
                }
            }
        }
    }
    
    public func deleteAllPending() async throws {
        return try await withCheckedThrowingContinuation { continuation in
            backgroundContext.perform { [weak self] in
                guard let self = self else {
                    continuation.resume(throwing: StoreError.saveFailure(NSError(domain: "OfflineStore", code: 0)))
                    return
                }
                
                let request = NSFetchRequest<NSManagedObject>(entityName: "PendingStatement")
                request.predicate = NSPredicate(format: "syncStatus != %@", SyncStatus.synced.rawValue)
                
                do {
                    let results = try self.backgroundContext.fetch(request)
                    for object in results {
                        self.backgroundContext.delete(object)
                    }
                    try self.backgroundContext.save()
                    Task {
                        await self.updatePendingCount()
                    }
                    continuation.resume()
                } catch {
                    continuation.resume(throwing: StoreError.saveFailure(error))
                }
            }
        }
    }
    
    public func deleteOldSynced(olderThan days: Int) async throws {
        return try await withCheckedThrowingContinuation { continuation in
            backgroundContext.perform { [weak self] in
                guard let self = self else {
                    continuation.resume(throwing: StoreError.saveFailure(NSError(domain: "OfflineStore", code: 0)))
                    return
                }
                
                let request = NSFetchRequest<NSManagedObject>(entityName: "PendingStatement")
                let cutoffDate = Date().addingTimeInterval(-Double(days) * 24 * 60 * 60)
                request.predicate = NSPredicate(
                    format: "syncStatus == %@ AND syncedAt < %@",
                    SyncStatus.synced.rawValue,
                    cutoffDate as NSDate
                )
                
                do {
                    let results = try self.backgroundContext.fetch(request)
                    for object in results {
                        self.backgroundContext.delete(object)
                    }
                    try self.backgroundContext.save()
                    continuation.resume()
                } catch {
                    continuation.resume(throwing: StoreError.saveFailure(error))
                }
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func updateStatement(id: String, update: @escaping (NSManagedObject) -> Void) async throws {
        return try await withCheckedThrowingContinuation { continuation in
            backgroundContext.perform { [weak self] in
                guard let self = self else {
                    continuation.resume(throwing: StoreError.saveFailure(NSError(domain: "OfflineStore", code: 0)))
                    return
                }
                
                let request = NSFetchRequest<NSManagedObject>(entityName: "PendingStatement")
                request.predicate = NSPredicate(format: "id == %@", id)
                
                do {
                    guard let entity = try self.backgroundContext.fetch(request).first else {
                        continuation.resume(throwing: StoreError.notFound)
                        return
                    }
                    
                    update(entity)
                    try self.backgroundContext.save()
                    Task {
                        await self.updatePendingCount()
                    }
                    continuation.resume()
                } catch {
                    continuation.resume(throwing: StoreError.saveFailure(error))
                }
            }
        }
    }
    
    private func updatePendingCount() async {
        if let count = try? await getPendingCount() {
            pendingCountSubject.send(count)
        }
    }
    
    private func encodeStatement(_ statement: XAPIStatement) throws -> String {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(statement)
        return String(data: data, encoding: .utf8) ?? ""
    }
    
    private func decodeStatement(_ json: String) throws -> XAPIStatement {
        guard let data = json.data(using: .utf8) else {
            throw StoreError.corruptedData
        }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(XAPIStatement.self, from: data)
    }
    
    private func convertToPendingStatement(_ entity: NSManagedObject) throws -> PendingStatement {
        guard let id = entity.value(forKey: "id") as? String,
              let json = entity.value(forKey: "statementJSON") as? String,
              let priorityRaw = entity.value(forKey: "priority") as? Int16,
              let priority = Priority(rawValue: priorityRaw),
              let createdAt = entity.value(forKey: "createdAt") as? Date,
              let statusRaw = entity.value(forKey: "syncStatus") as? String,
              let status = SyncStatus(rawValue: statusRaw),
              let retryCount = entity.value(forKey: "retryCount") as? Int16 else {
            throw StoreError.corruptedData
        }
        
        let statement = try decodeStatement(json)
        let lastError = entity.value(forKey: "lastError") as? String
        
        return PendingStatement(
            statementId: id,
            statement: statement,
            priority: priority,
            createdAt: createdAt,
            syncStatus: status,
            retryCount: Int(retryCount),
            lastError: lastError
        )
    }
}

// MARK: - OfflineStatementStoreProtocol Conformance

extension OfflineStatementStore: OfflineStatementStoreProtocol {
    // All required methods are already implemented above
}
