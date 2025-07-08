//
//  AnalyticsCollectorTests.swift
//  LMSTests
//
//  Created on Sprint 42 Day 3 - Analytics
//

import XCTest
import Combine
@testable import LMS

final class AnalyticsCollectorTests: XCTestCase {
    
    private var collector: AnalyticsCollector!
    private var mockStore: MockStatementStore!
    private var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        mockStore = MockStatementStore()
        collector = AnalyticsCollector(statementStore: mockStore)
        cancellables = []
    }
    
    override func tearDown() {
        collector = nil
        mockStore = nil
        cancellables = nil
        super.tearDown()
    }
    
    // MARK: - Collection Tests
    
    func testCollectStatement_UpdatesMetrics() async {
        // Given
        let statement = createCompletedStatement(score: 0.8)
        
        // When
        await collector.collect(statement)
        
        // Then
        let metrics = await collector.getCurrentMetrics()
        XCTAssertEqual(metrics.totalStatements, 1)
        XCTAssertEqual(metrics.averageScore, 0.8)
    }
    
    func testCollectMultipleStatements_AggregatesCorrectly() async {
        // Given
        let statements = [
            createCompletedStatement(score: 0.8),
            createCompletedStatement(score: 0.9),
            createCompletedStatement(score: 0.7)
        ]
        
        // When
        for statement in statements {
            await collector.collect(statement)
        }
        
        // Then
        let metrics = await collector.getCurrentMetrics()
        XCTAssertEqual(metrics.totalStatements, 3)
        XCTAssertEqual(metrics.averageScore, 0.8, accuracy: 0.01)
    }
    
    // MARK: - Time-based Metrics Tests
    
    func testCalculateLearningTime() async {
        // Given
        let startStatement = createStatement(verb: .launched, timestamp: Date())
        let endStatement = createStatement(verb: .terminated, timestamp: Date().addingTimeInterval(3600)) // 1 hour
        
        // When
        await collector.collect(startStatement)
        await collector.collect(endStatement)
        
        // Then
        let metrics = await collector.getLearningTimeMetrics()
        XCTAssertEqual(metrics.totalTime, 3600, accuracy: 1)
    }
    
    func testCalculateAverageSessionDuration() async {
        // Given
        // Session 1: 30 minutes
        await collector.collect(createStatement(verb: .launched, timestamp: Date()))
        await collector.collect(createStatement(verb: .terminated, timestamp: Date().addingTimeInterval(1800)))
        
        // Session 2: 45 minutes
        await collector.collect(createStatement(verb: .launched, timestamp: Date().addingTimeInterval(3600)))
        await collector.collect(createStatement(verb: .terminated, timestamp: Date().addingTimeInterval(6300)))
        
        // When
        let metrics = await collector.getLearningTimeMetrics()
        
        // Then
        XCTAssertEqual(metrics.sessions.count, 2)
        XCTAssertEqual(metrics.averageSessionDuration, 2250, accuracy: 1) // 37.5 minutes
    }
    
    // MARK: - Progress Metrics Tests
    
    func testCalculateCompletionRate() async {
        // Given
        let totalActivities = 10
        let completedStatements = Array(0..<7).map { _ in
            createCompletedStatement()
        }
        
        // When
        for statement in completedStatements {
            await collector.collect(statement)
        }
        
        // Then
        let progress = await collector.getProgressMetrics(totalActivities: totalActivities)
        XCTAssertEqual(progress.completionRate, 0.7)
        XCTAssertEqual(progress.completedActivities, 7)
    }
    
    func testTrackProgressOverTime() async {
        // Given
        let day1 = Date()
        let day2 = day1.addingTimeInterval(86400)
        let day3 = day2.addingTimeInterval(86400)
        
        await collector.collect(createCompletedStatement(timestamp: day1))
        await collector.collect(createCompletedStatement(timestamp: day1))
        await collector.collect(createCompletedStatement(timestamp: day2))
        await collector.collect(createCompletedStatement(timestamp: day3))
        
        // When
        let trend = await collector.getProgressTrend(days: 3)
        
        // Then
        XCTAssertEqual(trend.count, 3)
        XCTAssertEqual(trend[0].completedCount, 2)
        XCTAssertEqual(trend[1].completedCount, 1)
        XCTAssertEqual(trend[2].completedCount, 1)
    }
    
    // MARK: - Performance Metrics Tests
    
    func testCalculateSuccessRate() async {
        // Given
        let statements = [
            createCompletedStatement(success: true),
            createCompletedStatement(success: true),
            createCompletedStatement(success: false),
            createCompletedStatement(success: true)
        ]
        
        // When
        for statement in statements {
            await collector.collect(statement)
        }
        
        // Then
        let performance = await collector.getPerformanceMetrics()
        XCTAssertEqual(performance.successRate, 0.75)
    }
    
    func testCalculateScoreDistribution() async {
        // Given
        let scores = [0.5, 0.6, 0.7, 0.7, 0.8, 0.8, 0.8, 0.9, 1.0]
        
        // When
        for score in scores {
            await collector.collect(createCompletedStatement(score: score))
        }
        
        // Then
        let distribution = await collector.getScoreDistribution()
        XCTAssertEqual(distribution[0.8], 3) // Most common score
        XCTAssertEqual(distribution[0.7], 2)
        XCTAssertEqual(distribution[1.0], 1)
    }
    
    // MARK: - Engagement Metrics Tests
    
    func testCalculateEngagementFrequency() async {
        // Given
        let dates = [
            Date(),
            Date().addingTimeInterval(-86400), // Yesterday
            Date().addingTimeInterval(-172800), // 2 days ago
            Date().addingTimeInterval(-604800) // 7 days ago
        ]
        
        // When
        for date in dates {
            await collector.collect(createStatement(timestamp: date))
        }
        
        // Then
        let engagement = await collector.getEngagementMetrics(period: 7)
        XCTAssertEqual(engagement.activeDays, 4)
        XCTAssertEqual(engagement.frequency, 4.0/7.0, accuracy: 0.01)
    }
    
    func testIdentifyPeakLearningHours() async {
        // Given
        let calendar = Calendar.current
        let statements = [
            createStatement(hour: 9),
            createStatement(hour: 9),
            createStatement(hour: 10),
            createStatement(hour: 14),
            createStatement(hour: 14),
            createStatement(hour: 14)
        ]
        
        // When
        for statement in statements {
            await collector.collect(statement)
        }
        
        // Then
        let peakHours = await collector.getPeakLearningHours()
        XCTAssertEqual(peakHours.first?.hour, 14)
        XCTAssertEqual(peakHours.first?.count, 3)
    }
    
    // MARK: - Filtering Tests
    
    func testFilterByDateRange() async {
        // Given
        let now = Date()
        let statements = [
            createStatement(timestamp: now),
            createStatement(timestamp: now.addingTimeInterval(-86400)),
            createStatement(timestamp: now.addingTimeInterval(-172800)),
            createStatement(timestamp: now.addingTimeInterval(-259200))
        ]
        
        for statement in statements {
            await collector.collect(statement)
        }
        
        // When
        let filtered = await collector.getMetrics(
            from: now.addingTimeInterval(-172800),
            to: now
        )
        
        // Then
        XCTAssertEqual(filtered.totalStatements, 3)
    }
    
    func testFilterByActivity() async {
        // Given
        let activity1 = "activity1"
        let activity2 = "activity2"
        
        await collector.collect(createStatement(activityId: activity1))
        await collector.collect(createStatement(activityId: activity1))
        await collector.collect(createStatement(activityId: activity2))
        
        // When
        let metrics = await collector.getMetricsByActivity(activityId: activity1)
        
        // Then
        XCTAssertEqual(metrics.totalStatements, 2)
    }
    
    // MARK: - Real-time Updates Tests
    
    func testMetricsPublisher_UpdatesOnNewStatement() {
        // Given
        let expectation = expectation(description: "Metrics updated")
        var receivedUpdates = 0
        
        collector.metricsPublisher
            .sink { _ in
                receivedUpdates += 1
                if receivedUpdates == 2 {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        // When
        Task {
            await collector.collect(createStatement())
            await collector.collect(createStatement())
        }
        
        // Then
        waitForExpectations(timeout: 2.0)
        XCTAssertEqual(receivedUpdates, 2)
    }
    
    // MARK: - Cache Tests
    
    func testCacheMetrics_ImprovedPerformance() async {
        // Given
        for _ in 0..<100 {
            await collector.collect(createStatement())
        }
        
        // When
        let start1 = Date()
        _ = await collector.getCurrentMetrics()
        let duration1 = Date().timeIntervalSince(start1)
        
        let start2 = Date()
        _ = await collector.getCurrentMetrics() // Should be cached
        let duration2 = Date().timeIntervalSince(start2)
        
        // Then
        XCTAssertLessThan(duration2, duration1 * 0.1) // Cached should be 10x faster
    }
    
    // MARK: - Helper Methods
    
    private func createStatement(
        verb: XAPIVerb = .completed,
        timestamp: Date = Date(),
        activityId: String = "default-activity",
        hour: Int? = nil
    ) -> XAPIStatement {
        var date = timestamp
        if let hour = hour {
            let calendar = Calendar.current
            var components = calendar.dateComponents([.year, .month, .day], from: timestamp)
            components.hour = hour
            date = calendar.date(from: components) ?? timestamp
        }
        
        var statement = XAPIStatement(
            actor: XAPIActor(name: "Test User", mbox: "mailto:test@example.com"),
            verb: verb,
            object: .activity(XAPIActivity(id: activityId, definition: nil))
        )
        statement.timestamp = date
        return statement
    }
    
    private func createCompletedStatement(
        score: Double = 1.0,
        success: Bool = true,
        timestamp: Date = Date()
    ) -> XAPIStatement {
        var statement = createStatement(verb: .completed, timestamp: timestamp)
        statement.result = XAPIResult(
            score: XAPIScore(scaled: score),
            success: success,
            completion: true
        )
        return statement
    }
}

// MARK: - Mock Classes

class MockStatementStore {
    var statements: [XAPIStatement] = []
    
    func save(_ statement: XAPIStatement) {
        statements.append(statement)
    }
    
    func getAll() -> [XAPIStatement] {
        return statements
    }
} 