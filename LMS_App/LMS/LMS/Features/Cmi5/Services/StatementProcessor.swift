//
//  StatementProcessor.swift
//  LMS
//
//  Created on Sprint 42 Day 1 - xAPI Statement Processing
//

import Foundation
import Combine

/// Процессор для обработки и валидации xAPI statements
public final class StatementProcessor {
    
    // MARK: - Types
    
    public enum ProcessingError: LocalizedError {
        case validationFailed(errors: [ValidationError])
        case sendFailed(Error)
        case maxRetriesExceeded
        case queueFull
        
        public var errorDescription: String? {
            switch self {
            case .validationFailed(let errors):
                return "Validation failed: \(errors.map { $0.rawValue }.joined(separator: ", "))"
            case .sendFailed(let error):
                return "Failed to send statement: \(error.localizedDescription)"
            case .maxRetriesExceeded:
                return "Maximum retry attempts exceeded"
            case .queueFull:
                return "Statement queue is full"
            }
        }
    }
    
    public enum ValidationError: String, CaseIterable {
        case missingActor = "Missing or invalid actor"
        case invalidScore = "Invalid score value"
        case missingObject = "Missing statement object"
        case invalidVerb = "Invalid verb"
        case invalidTimestamp = "Invalid timestamp"
        case invalidDuration = "Invalid duration format"
    }
    
    public struct ValidationResult {
        public let isValid: Bool
        public let errors: [ValidationError]
    }
    
    public struct BatchResult {
        public let count: Int
        public let successful: [String]
        public let failed: [(XAPIStatement, Error)]
    }
    
    public struct StatementUpdate {
        public let statement: XAPIStatement
        public let status: ProcessingStatus
        public let timestamp: Date
    }
    
    public enum ProcessingStatus {
        case queued
        case processing
        case processed
        case failed(Error)
    }
    
    public struct ProgressUpdate {
        public let courseId: UUID
        public let progress: Double
        public let timestamp: Date
    }
    
    // MARK: - Properties
    
    private let lrsService: LRSServiceProtocol
    private let queue = DispatchQueue(label: "com.lms.statementprocessor", attributes: .concurrent)
    private let maxQueueSize = 1000
    
    private var _queuedStatements: [XAPIStatement] = []
    public var queuedStatements: [XAPIStatement] {
        queue.sync { _queuedStatements }
    }
    
    public let statementUpdates = PassthroughSubject<StatementUpdate, Never>()
    public private(set) var lastProgressUpdate: ProgressUpdate?
    
    // For testing
    internal var sentStatements: [XAPIStatement] = []
    
    // MARK: - Initialization
    
    public init(lrsService: LRSServiceProtocol) {
        self.lrsService = lrsService
    }
    
    // MARK: - Validation
    
    public func validateStatement(_ statement: XAPIStatement) -> ValidationResult {
        var errors: [ValidationError] = []
        
        // Validate actor
        if statement.actor.mbox == nil && 
           statement.actor.mbox_sha1sum == nil && 
           statement.actor.openid == nil && 
           statement.actor.account == nil {
            errors.append(.missingActor)
        }
        
        // Validate score if present
        if let score = statement.result?.score,
           let scaled = score.scaled,
           (scaled < -1.0 || scaled > 1.0) {
            errors.append(.invalidScore)
        }
        
        // Validate timestamp
        if let timestamp = statement.timestamp,
           timestamp > Date() {
            errors.append(.invalidTimestamp)
        }
        
        // Validate duration format
        if let duration = statement.result?.duration,
           !isValidISO8601Duration(duration) {
            errors.append(.invalidDuration)
        }
        
        return ValidationResult(
            isValid: errors.isEmpty,
            errors: errors
        )
    }
    
    // MARK: - Processing
    
    public func processStatement(_ statement: XAPIStatement) async throws -> String {
        // Validate first
        let validation = validateStatement(statement)
        if !validation.isValid {
            throw ProcessingError.validationFailed(errors: validation.errors)
        }
        
        // Update status
        publishUpdate(StatementUpdate(
            statement: statement,
            status: .processing,
            timestamp: Date()
        ))
        
        do {
            // Send to LRS
            let statementId = try await lrsService.sendStatement(statement)
            
            // Track for testing
            sentStatements.append(statement)
            
            // Update progress if applicable
            updateProgressIfNeeded(for: statement)
            
            // Update status
            publishUpdate(StatementUpdate(
                statement: statement,
                status: .processed,
                timestamp: Date()
            ))
            
            return statementId
        } catch {
            // Update status
            publishUpdate(StatementUpdate(
                statement: statement,
                status: .failed(error),
                timestamp: Date()
            ))
            
            throw ProcessingError.sendFailed(error)
        }
    }
    
    // MARK: - Batch Processing
    
    public func processBatch(_ statements: [XAPIStatement]) async throws -> BatchResult {
        var successful: [String] = []
        var failed: [(XAPIStatement, Error)] = []
        
        await withTaskGroup(of: (XAPIStatement, Result<String, Error>).self) { group in
            for statement in statements {
                group.addTask { [weak self] in
                    do {
                        let id = try await self?.processStatement(statement) ?? ""
                        return (statement, .success(id))
                    } catch {
                        return (statement, .failure(error))
                    }
                }
            }
            
            for await (statement, result) in group {
                switch result {
                case .success(let id):
                    successful.append(id)
                case .failure(let error):
                    failed.append((statement, error))
                }
            }
        }
        
        return BatchResult(
            count: statements.count,
            successful: successful,
            failed: failed
        )
    }
    
    // MARK: - Queue Management
    
    public func queueStatement(_ statement: XAPIStatement) {
        queue.async(flags: .barrier) { [weak self] in
            guard let self = self else { return }
            
            if self._queuedStatements.count < self.maxQueueSize {
                self._queuedStatements.append(statement)
                
                self.publishUpdate(StatementUpdate(
                    statement: statement,
                    status: .queued,
                    timestamp: Date()
                ))
            }
        }
    }
    
    public func processQueue() async throws -> Int {
        let statementsToProcess = queue.sync { 
            let statements = _queuedStatements
            _queuedStatements.removeAll()
            return statements
        }
        
        let results = try await processBatch(statementsToProcess)
        
        // Re-queue failed statements
        for (statement, _) in results.failed {
            queueStatement(statement)
        }
        
        return results.successful.count
    }
    
    // MARK: - Retry Mechanism
    
    public func processWithRetry(
        _ statement: XAPIStatement,
        maxAttempts: Int = 3,
        delay: TimeInterval = 1.0
    ) async throws -> String {
        var lastError: Error?
        
        for attempt in 1...maxAttempts {
            do {
                return try await processStatement(statement)
            } catch {
                lastError = error
                
                if attempt < maxAttempts {
                    // Exponential backoff
                    let backoffDelay = delay * pow(2.0, Double(attempt - 1))
                    try await Task.sleep(nanoseconds: UInt64(backoffDelay * 1_000_000_000))
                }
            }
        }
        
        throw ProcessingError.maxRetriesExceeded
    }
    
    // MARK: - Deduplication
    
    public func deduplicateStatements(_ statements: [XAPIStatement]) -> [XAPIStatement] {
        var seen = Set<String>()
        var unique: [XAPIStatement] = []
        
        for statement in statements {
            let id = statement.id ?? UUID().uuidString
            if !seen.contains(id) {
                seen.insert(id)
                unique.append(statement)
            }
        }
        
        return unique
    }
    
    // MARK: - Real-time Updates
    
    public func publishUpdate(_ update: StatementUpdate) {
        statementUpdates.send(update)
    }
    
    // MARK: - Progress Integration
    
    private func updateProgressIfNeeded(for statement: XAPIStatement) {
        // Extract course ID from context
        guard let extensions = statement.context?.extensions,
              let courseIdValue = extensions["https://example.com/courseId"],
              let courseIdString = (courseIdValue.value as? String),
              let courseId = UUID(uuidString: courseIdString) else {
            return
        }
        
        // Calculate progress (simplified)
        let progress = statement.result?.completion == true ? 1.0 : 0.5
        
        lastProgressUpdate = ProgressUpdate(
            courseId: courseId,
            progress: progress,
            timestamp: Date()
        )
    }
    
    // MARK: - Private Helpers
    
    private func isValidISO8601Duration(_ duration: String) -> Bool {
        // Simple check for ISO 8601 duration format (P[n]Y[n]M[n]DT[n]H[n]M[n]S)
        let pattern = #"^P(?:\d+Y)?(?:\d+M)?(?:\d+D)?(?:T(?:\d+H)?(?:\d+M)?(?:\d+(?:\.\d+)?S)?)?$"#
        return duration.range(of: pattern, options: .regularExpression) != nil
    }
}

// MARK: - Mock for Testing

/// Mock LRS service for testing (should already be in LRSService.swift)
extension MockLRSService {
    var sentStatements: [XAPIStatement] {
        statements
    }
    
    var shouldFailNextCalls: Int {
        get { 0 } // Default implementation
        set { } // For testing
    }
    
    var sendAttempts: Int {
        0 // Default implementation
    }
} 

// MARK: - StatementProcessorProtocol Conformance

extension StatementProcessor: StatementProcessorProtocol {
    public func processBatch(_ batch: [OfflineStatementStore.PendingStatement]) async throws {
        // Process each statement in the batch
        for pendingStatement in batch {
            try await processStatement(pendingStatement.statement)
        }
    }
} 