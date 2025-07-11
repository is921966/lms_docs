//
//  ConflictResolverTests.swift
//  LMSTests
//
//  Created on Sprint 42 Day 2 - Conflict Resolution
//

import XCTest
@testable import LMS

final class ConflictResolverTests: XCTestCase {
    
    private var resolver: ConflictResolver!
    
    override func setUp() {
        super.setUp()
        resolver = ConflictResolver()
    }
    
    override func tearDown() {
        resolver = nil
        super.tearDown()
    }
    
    // MARK: - Last Write Wins Tests
    
    func testResolveConflict_LastWriteWins_SelectsNewerStatement() {
        // Given
        let oldStatement = createStatement(
            id: "same-id",
            timestamp: Date().addingTimeInterval(-60) // 1 minute ago
        )
        let newStatement = createStatement(
            id: "same-id",
            timestamp: Date() // Now
        )
        
        // When
        let resolved = resolver.resolveConflict(
            local: oldStatement,
            remote: newStatement,
            strategy: .lastWriteWins
        )
        
        // Then
        XCTAssertEqual(resolved.timestamp, newStatement.timestamp)
    }
    
    func testResolveConflict_LastWriteWins_HandlesNilTimestamps() {
        // Given
        var statementNoTime = createStatement(id: "same-id")
        statementNoTime.timestamp = nil
        
        let statementWithTime = createStatement(
            id: "same-id",
            timestamp: Date()
        )
        
        // When
        let resolved = resolver.resolveConflict(
            local: statementNoTime,
            remote: statementWithTime,
            strategy: .lastWriteWins
        )
        
        // Then
        XCTAssertEqual(resolved.id, statementWithTime.id)
        XCTAssertNotNil(resolved.timestamp)
    }
    
    // MARK: - Merge Strategy Tests
    
    func testResolveConflict_Merge_CombinesResults() {
        // Given
        var localStatement = createStatement(id: "same-id")
        localStatement.result = XAPIResult(
            score: XAPIScore(scaled: 0.8),
            completion: true
        )
        
        var remoteStatement = createStatement(id: "same-id")
        remoteStatement.result = XAPIResult(
            score: XAPIScore(scaled: 0.9),
            success: true
        )
        
        // When
        let resolved = resolver.resolveConflict(
            local: localStatement,
            remote: remoteStatement,
            strategy: .merge
        )
        
        // Then
        XCTAssertNotNil(resolved.result)
        XCTAssertEqual(resolved.result?.score?.scaled, 0.9) // Higher score
        XCTAssertEqual(resolved.result?.completion, true) // From local
        XCTAssertEqual(resolved.result?.success, true) // From remote
    }
    
    func testResolveConflict_Merge_CombinesExtensions() {
        // Given
        var localStatement = createStatement(id: "same-id")
        localStatement.context = XAPIContext(
            extensions: ["local": AnyCodable("value1")]
        )
        
        var remoteStatement = createStatement(id: "same-id")
        remoteStatement.context = XAPIContext(
            extensions: ["remote": AnyCodable("value2")]
        )
        
        // When
        let resolved = resolver.resolveConflict(
            local: localStatement,
            remote: remoteStatement,
            strategy: .merge
        )
        
        // Then
        let extensions = resolved.context?.extensions
        XCTAssertEqual(extensions?.count, 2)
        XCTAssertEqual(extensions?["local"]?.value as? String, "value1")
        XCTAssertEqual(extensions?["remote"]?.value as? String, "value2")
    }
    
    // MARK: - Local Priority Tests
    
    func testResolveConflict_LocalPriority_SelectsLocal() {
        // Given
        let localStatement = createStatement(
            id: "same-id",
            timestamp: Date().addingTimeInterval(-60) // Older
        )
        let remoteStatement = createStatement(
            id: "same-id",
            timestamp: Date() // Newer
        )
        
        // When
        let resolved = resolver.resolveConflict(
            local: localStatement,
            remote: remoteStatement,
            strategy: .localPriority
        )
        
        // Then
        XCTAssertEqual(resolved.timestamp, localStatement.timestamp)
    }
    
    // MARK: - Remote Priority Tests
    
    func testResolveConflict_RemotePriority_SelectsRemote() {
        // Given
        let localStatement = createStatement(
            id: "same-id",
            timestamp: Date() // Newer
        )
        let remoteStatement = createStatement(
            id: "same-id",
            timestamp: Date().addingTimeInterval(-60) // Older
        )
        
        // When
        let resolved = resolver.resolveConflict(
            local: localStatement,
            remote: remoteStatement,
            strategy: .remotePriority
        )
        
        // Then
        XCTAssertEqual(resolved.timestamp, remoteStatement.timestamp)
    }
    
    // MARK: - Batch Resolution Tests
    
    func testResolveBatch_RemovesDuplicates() {
        // Given
        let statements = [
            createStatement(id: "1", timestamp: Date()),
            createStatement(id: "2", timestamp: Date()),
            createStatement(id: "1", timestamp: Date().addingTimeInterval(60)), // Duplicate, newer
            createStatement(id: "3", timestamp: Date()),
            createStatement(id: "2", timestamp: Date().addingTimeInterval(-60)) // Duplicate, older
        ]
        
        // When
        let resolved = resolver.resolveBatch(statements, strategy: .lastWriteWins)
        
        // Then
        XCTAssertEqual(resolved.count, 3)
        
        // Check that newer versions were kept
        let id1Statement = resolved.first { $0.id == "1" }
        XCTAssertEqual(id1Statement?.timestamp, statements[2].timestamp)
        
        let id2Statement = resolved.first { $0.id == "2" }
        XCTAssertEqual(id2Statement?.timestamp, statements[1].timestamp)
    }
    
    func testResolveBatch_PreservesOrder() {
        // Given
        let statements = [
            createStatement(id: "3", timestamp: Date()),
            createStatement(id: "1", timestamp: Date()),
            createStatement(id: "2", timestamp: Date())
        ]
        
        // When
        let resolved = resolver.resolveBatch(statements, strategy: .lastWriteWins)
        
        // Then
        XCTAssertEqual(resolved.count, 3)
        // Order should be preserved based on original appearance
        XCTAssertEqual(resolved[0].id, "3")
        XCTAssertEqual(resolved[1].id, "1")
        XCTAssertEqual(resolved[2].id, "2")
    }
    
    // MARK: - Score Conflict Tests
    
    func testResolveScoreConflict_SelectsHigherScore() {
        // Given
        let score1 = XAPIScore(scaled: 0.7, raw: 70, min: 0, max: 100)
        let score2 = XAPIScore(scaled: 0.9, raw: 90, min: 0, max: 100)
        
        // When
        let resolved = resolver.resolveScoreConflict(score1, score2)
        
        // Then
        XCTAssertEqual(resolved.scaled, 0.9)
        XCTAssertEqual(resolved.raw, 90)
    }
    
    func testResolveScoreConflict_HandlesNilValues() {
        // Given
        let score1 = XAPIScore(scaled: 0.8)
        let score2: XAPIScore? = nil
        
        // When
        let resolved1 = resolver.resolveScoreConflict(score1, score2)
        let resolved2 = resolver.resolveScoreConflict(score2, score1)
        
        // Then
        XCTAssertEqual(resolved1.scaled, 0.8)
        XCTAssertEqual(resolved2.scaled, 0.8)
    }
    
    // MARK: - Logging Tests
    
    func testConflictLogging_RecordsConflicts() {
        // Given
        let local = createStatement(id: "conflict-id")
        let remote = createStatement(id: "conflict-id")
        
        // When
        _ = resolver.resolveConflict(
            local: local,
            remote: remote,
            strategy: .lastWriteWins
        )
        
        // Then
        let logs = resolver.getConflictLogs()
        XCTAssertEqual(logs.count, 1)
        XCTAssertEqual(logs.first?.statementId, "conflict-id")
        XCTAssertEqual(logs.first?.strategy, .lastWriteWins)
    }
    
    func testConflictLogging_LimitsLogSize() {
        // Given
        let maxLogs = 100
        
        // When
        for i in 0..<150 {
            let local = createStatement(id: "id-\(i)")
            let remote = createStatement(id: "id-\(i)")
            _ = resolver.resolveConflict(
                local: local,
                remote: remote,
                strategy: .lastWriteWins
            )
        }
        
        // Then
        let logs = resolver.getConflictLogs()
        XCTAssertEqual(logs.count, maxLogs)
        // Should keep the most recent logs
        XCTAssertEqual(logs.last?.statementId, "id-149")
    }
    
    // MARK: - Performance Tests
    
    func testPerformance_ResolveLargeBatch() {
        // Given
        var statements: [XAPIStatement] = []
        for i in 0..<1000 {
            statements.append(createStatement(id: "id-\(i % 500)")) // 50% duplicates
        }
        
        // When/Then
        measure {
            _ = resolver.resolveBatch(statements, strategy: .lastWriteWins)
        }
    }
    
    // MARK: - Helper Methods
    
    private func createStatement(
        id: String = UUID().uuidString,
        timestamp: Date = Date()
    ) -> XAPIStatement {
        var statement = XAPIStatement(
            actor: XAPIActor(
                name: "Test User",
                mbox: "mailto:test@example.com"
            ),
            verb: XAPIVerb.completed,
            object: .activity(XAPIActivity(
                id: "https://example.com/activity/test",
                definition: nil
            ))
        )
        statement.id = id
        statement.timestamp = timestamp
        return statement
    }
} 