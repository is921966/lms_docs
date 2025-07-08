//
//  ConflictResolver.swift
//  LMS
//
//  Created on Sprint 42 Day 2 - Conflict Resolution
//

import Foundation

/// Разрешает конфликты при синхронизации xAPI statements
public final class ConflictResolver {
    
    // MARK: - Types
    
    public enum ResolutionStrategy {
        case lastWriteWins
        case merge
        case localPriority
        case remotePriority
    }
    
    public struct ConflictLog {
        public let statementId: String
        public let strategy: ResolutionStrategy
        public let timestamp: Date
        public let localTimestamp: Date?
        public let remoteTimestamp: Date?
    }
    
    // MARK: - Properties
    
    private var conflictLogs: [ConflictLog] = []
    private let maxLogSize = 100
    private let logQueue = DispatchQueue(label: "com.lms.conflictresolver.logs", attributes: .concurrent)
    
    // MARK: - Public Methods
    
    public func resolveConflict(
        local: XAPIStatement,
        remote: XAPIStatement,
        strategy: ResolutionStrategy
    ) -> XAPIStatement {
        
        let resolved: XAPIStatement
        
        switch strategy {
        case .lastWriteWins:
            resolved = resolveByTimestamp(local: local, remote: remote)
            
        case .merge:
            resolved = mergeStatements(local: local, remote: remote)
            
        case .localPriority:
            resolved = local
            
        case .remotePriority:
            resolved = remote
        }
        
        // Log the conflict
        logConflict(
            statementId: local.id ?? "unknown",
            strategy: strategy,
            localTimestamp: local.timestamp,
            remoteTimestamp: remote.timestamp
        )
        
        return resolved
    }
    
    public func resolveBatch(
        _ statements: [XAPIStatement],
        strategy: ResolutionStrategy
    ) -> [XAPIStatement] {
        
        var resolvedMap: [String: (statement: XAPIStatement, index: Int)] = [:]
        
        for (index, statement) in statements.enumerated() {
            guard let id = statement.id else { continue }
            
            if let existing = resolvedMap[id] {
                // Conflict found
                let resolved = resolveConflict(
                    local: existing.statement,
                    remote: statement,
                    strategy: strategy
                )
                
                // Keep the original index for order preservation
                resolvedMap[id] = (resolved, min(existing.index, index))
            } else {
                resolvedMap[id] = (statement, index)
            }
        }
        
        // Sort by original index to preserve order
        return resolvedMap.values
            .sorted { $0.index < $1.index }
            .map { $0.statement }
    }
    
    public func resolveScoreConflict(_ score1: XAPIScore?, _ score2: XAPIScore?) -> XAPIScore {
        // If one is nil, return the other
        guard let s1 = score1 else {
            return score2 ?? XAPIScore()
        }
        guard let s2 = score2 else {
            return s1
        }
        
        // Select the higher score
        let scaled1 = s1.scaled ?? 0
        let scaled2 = s2.scaled ?? 0
        
        if scaled1 >= scaled2 {
            return s1
        } else {
            return s2
        }
    }
    
    public func getConflictLogs() -> [ConflictLog] {
        logQueue.sync {
            conflictLogs
        }
    }
    
    // MARK: - Private Methods
    
    private func resolveByTimestamp(local: XAPIStatement, remote: XAPIStatement) -> XAPIStatement {
        let localTime = local.timestamp ?? Date.distantPast
        let remoteTime = remote.timestamp ?? Date.distantPast
        
        return localTime >= remoteTime ? local : remote
    }
    
    private func mergeStatements(local: XAPIStatement, remote: XAPIStatement) -> XAPIStatement {
        var merged = local
        
        // Merge result
        if let localResult = local.result, let remoteResult = remote.result {
            merged.result = mergeResults(local: localResult, remote: remoteResult)
        } else {
            merged.result = local.result ?? remote.result
        }
        
        // Merge context
        if let localContext = local.context, let remoteContext = remote.context {
            merged.context = mergeContexts(local: localContext, remote: remoteContext)
        } else {
            merged.context = local.context ?? remote.context
        }
        
        // Use latest timestamp
        merged.timestamp = resolveByTimestamp(local: local, remote: remote).timestamp
        
        return merged
    }
    
    private func mergeResults(local: XAPIResult, remote: XAPIResult) -> XAPIResult {
        return XAPIResult(
            score: resolveScoreConflict(local.score, remote.score),
            success: local.success ?? remote.success,
            completion: local.completion ?? remote.completion,
            response: local.response ?? remote.response,
            duration: local.duration ?? remote.duration,
            extensions: mergeExtensions(local.extensions, remote.extensions)
        )
    }
    
    private func mergeContexts(local: XAPIContext, remote: XAPIContext) -> XAPIContext {
        return XAPIContext(
            registration: local.registration ?? remote.registration,
            instructor: local.instructor ?? remote.instructor,
            team: local.team ?? remote.team,
            contextActivities: local.contextActivities ?? remote.contextActivities,
            language: local.language ?? remote.language,
            statement: local.statement ?? remote.statement,
            extensions: mergeExtensions(local.extensions, remote.extensions)
        )
    }
    
    private func mergeExtensions(
        _ local: [String: AnyCodable]?,
        _ remote: [String: AnyCodable]?
    ) -> [String: AnyCodable]? {
        
        guard let localExt = local else { return remote }
        guard let remoteExt = remote else { return local }
        
        // Merge dictionaries, remote values override local for same keys
        var merged = localExt
        for (key, value) in remoteExt {
            merged[key] = value
        }
        
        return merged.isEmpty ? nil : merged
    }
    
    private func logConflict(
        statementId: String,
        strategy: ResolutionStrategy,
        localTimestamp: Date?,
        remoteTimestamp: Date?
    ) {
        let log = ConflictLog(
            statementId: statementId,
            strategy: strategy,
            timestamp: Date(),
            localTimestamp: localTimestamp,
            remoteTimestamp: remoteTimestamp
        )
        
        logQueue.async(flags: .barrier) {
            self.conflictLogs.append(log)
            
            // Limit log size
            if self.conflictLogs.count > self.maxLogSize {
                self.conflictLogs.removeFirst(self.conflictLogs.count - self.maxLogSize)
            }
        }
    }
} 