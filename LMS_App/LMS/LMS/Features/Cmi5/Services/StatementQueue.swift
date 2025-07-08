//
//  StatementQueue.swift
//  LMS
//
//  Created on Sprint 42 Day 1 - xAPI Statement Queue Management
//

import Foundation
import Combine

/// Приоритетная очередь для xAPI statements
public final class StatementQueue {
    
    // MARK: - Types
    
    public enum Priority: Int, Comparable {
        case low = 0
        case normal = 1
        case high = 2
        
        public static func < (lhs: Priority, rhs: Priority) -> Bool {
            lhs.rawValue < rhs.rawValue
        }
    }
    
    public struct QueueChange {
        public enum ChangeType {
            case enqueued
            case dequeued
            case cleared
        }
        
        public let type: ChangeType
        public let count: Int
        public let timestamp: Date
    }
    
    public struct Statistics {
        public let totalEnqueued: Int
        public let totalDequeued: Int
        public let currentSize: Int
        public let byPriority: [Priority: Int]
        public let oldestStatementAge: TimeInterval?
    }
    
    private struct QueueItem {
        let statement: XAPIStatement
        let priority: Priority
        let timestamp: Date
    }
    
    // MARK: - Properties
    
    private let queue = DispatchQueue(label: "com.lms.statementqueue", attributes: .concurrent)
    private var items: [QueueItem] = []
    private let maxSize: Int
    
    // Statistics
    private var totalEnqueued: Int = 0
    private var totalDequeued: Int = 0
    
    // Publishers
    public let queueChanges = PassthroughSubject<QueueChange, Never>()
    
    // MARK: - Computed Properties
    
    public var count: Int {
        queue.sync { items.count }
    }
    
    public var isEmpty: Bool {
        queue.sync { items.isEmpty }
    }
    
    public var isFull: Bool {
        queue.sync { items.count >= maxSize }
    }
    
    public var statistics: Statistics {
        queue.sync {
            var byPriority: [Priority: Int] = [:]
            var oldestAge: TimeInterval?
            
            for item in items {
                byPriority[item.priority, default: 0] += 1
                
                if oldestAge == nil {
                    oldestAge = Date().timeIntervalSince(item.timestamp)
                }
            }
            
            return Statistics(
                totalEnqueued: totalEnqueued,
                totalDequeued: totalDequeued,
                currentSize: items.count,
                byPriority: byPriority,
                oldestStatementAge: oldestAge
            )
        }
    }
    
    // MARK: - Initialization
    
    public init(maxSize: Int = 10000) {
        self.maxSize = maxSize
    }
    
    // MARK: - Enqueue Operations
    
    @discardableResult
    public func enqueue(_ statement: XAPIStatement, priority: Priority = .normal) -> Bool {
        return queue.sync(flags: .barrier) {
            guard items.count < maxSize else {
                return false
            }
            
            let item = QueueItem(
                statement: statement,
                priority: priority,
                timestamp: Date()
            )
            
            // Insert based on priority
            if let insertIndex = items.firstIndex(where: { $0.priority < priority }) {
                items.insert(item, at: insertIndex)
            } else {
                items.append(item)
            }
            
            totalEnqueued += 1
            
            publishChange(.enqueued, count: 1)
            return true
        }
    }
    
    public func enqueueBatch(_ statements: [XAPIStatement], priority: Priority = .normal) {
        queue.sync(flags: .barrier) {
            let availableSpace = maxSize - items.count
            let toEnqueue = min(statements.count, availableSpace)
            
            for i in 0..<toEnqueue {
                let item = QueueItem(
                    statement: statements[i],
                    priority: priority,
                    timestamp: Date()
                )
                
                if let insertIndex = items.firstIndex(where: { $0.priority < priority }) {
                    items.insert(item, at: insertIndex)
                } else {
                    items.append(item)
                }
            }
            
            totalEnqueued += toEnqueue
            publishChange(.enqueued, count: toEnqueue)
        }
    }
    
    // MARK: - Dequeue Operations
    
    public func dequeue() -> XAPIStatement? {
        return queue.sync(flags: .barrier) {
            guard !items.isEmpty else {
                return nil
            }
            
            let item = items.removeFirst()
            totalDequeued += 1
            
            publishChange(.dequeued, count: 1)
            return item.statement
        }
    }
    
    public func dequeueBatch(count: Int) -> [XAPIStatement] {
        return queue.sync(flags: .barrier) {
            let toDequeue = min(count, items.count)
            var statements: [XAPIStatement] = []
            
            for _ in 0..<toDequeue {
                let item = items.removeFirst()
                statements.append(item.statement)
            }
            
            totalDequeued += toDequeue
            publishChange(.dequeued, count: toDequeue)
            
            return statements
        }
    }
    
    // MARK: - Peek Operations
    
    public func peek() -> XAPIStatement? {
        queue.sync {
            items.first?.statement
        }
    }
    
    public func peekBatch(count: Int) -> [XAPIStatement] {
        queue.sync {
            let toPeek = min(count, items.count)
            return Array(items.prefix(toPeek)).map { $0.statement }
        }
    }
    
    // MARK: - Clear Operations
    
    public func clear() {
        queue.sync(flags: .barrier) {
            let count = items.count
            items.removeAll()
            publishChange(.cleared, count: count)
        }
    }
    
    public func clear(priority: Priority) {
        queue.sync(flags: .barrier) {
            let before = items.count
            items.removeAll { $0.priority == priority }
            let removed = before - items.count
            
            if removed > 0 {
                publishChange(.cleared, count: removed)
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func publishChange(_ type: QueueChange.ChangeType, count: Int) {
        let change = QueueChange(
            type: type,
            count: count,
            timestamp: Date()
        )
        
        // Publish on main queue
        DispatchQueue.main.async { [weak self] in
            self?.queueChanges.send(change)
        }
    }
} 