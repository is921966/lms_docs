//
//  AnalyticsCollector.swift
//  LMS
//
//  Created on Sprint 42 Day 3 - Analytics
//

import Foundation
import Combine

/// Собирает и анализирует метрики обучения из xAPI statements
public final class AnalyticsCollector {
    
    // MARK: - Types
    
    public struct GeneralMetrics {
        public let totalStatements: Int
        public let averageScore: Double
        public let lastUpdated: Date
    }
    
    public struct LearningTimeMetrics {
        public let totalTime: TimeInterval
        public let sessions: [Session]
        public let averageSessionDuration: TimeInterval
        
        public struct Session {
            public let start: Date
            public let end: Date
            public let duration: TimeInterval
        }
    }
    
    public struct ProgressMetrics {
        public let completionRate: Double
        public let completedActivities: Int
        public let totalActivities: Int
        public let trend: [DailyProgress]
    }
    
    public struct DailyProgress {
        public let date: Date
        public let completedCount: Int
    }
    
    public struct PerformanceMetrics {
        public let successRate: Double
        public let averageScore: Double
        public let scoreDistribution: [Double: Int]
        public let improvementTrend: Double
    }
    
    public struct EngagementMetrics {
        public let activeDays: Int
        public let frequency: Double
        public let peakHours: [HourActivity]
        public let averageTimePerDay: TimeInterval
    }
    
    public struct HourActivity {
        public let hour: Int
        public let count: Int
    }
    
    // MARK: - Properties
    
    private let statementStore: Any // Would be StatementStoreProtocol
    private var statements: [XAPIStatement] = []
    private let queue = DispatchQueue(label: "com.lms.analytics", attributes: .concurrent)
    
    // Cache
    private var metricsCache: GeneralMetrics?
    private var cacheValidUntil: Date?
    private let cacheLifetime: TimeInterval = 60 // 1 minute
    
    // Publishers
    private let metricsSubject = PassthroughSubject<GeneralMetrics, Never>()
    public var metricsPublisher: AnyPublisher<GeneralMetrics, Never> {
        metricsSubject.eraseToAnyPublisher()
    }
    
    // MARK: - Initialization
    
    public init(statementStore: Any) {
        self.statementStore = statementStore
    }
    
    // MARK: - Collection
    
    public func collect(_ statement: XAPIStatement) async {
        await withCheckedContinuation { continuation in
            queue.async(flags: .barrier) {
                self.statements.append(statement)
                self.invalidateCache()
                continuation.resume()
            }
        }
        
        // Notify subscribers
        if let metrics = await getCurrentMetrics() {
            metricsSubject.send(metrics)
        }
    }
    
    // MARK: - General Metrics
    
    public func getCurrentMetrics() async -> GeneralMetrics {
        // Check cache first
        if let cached = getCachedMetrics() {
            return cached
        }
        
        return await withCheckedContinuation { continuation in
            queue.async {
                let metrics = self.calculateGeneralMetrics()
                self.cacheMetrics(metrics)
                continuation.resume(returning: metrics)
            }
        }
    }
    
    // MARK: - Time Metrics
    
    public func getLearningTimeMetrics() async -> LearningTimeMetrics {
        await withCheckedContinuation { continuation in
            queue.async {
                let sessions = self.extractSessions()
                let totalTime = sessions.reduce(0) { $0 + $1.duration }
                let avgDuration = sessions.isEmpty ? 0 : totalTime / Double(sessions.count)
                
                let metrics = LearningTimeMetrics(
                    totalTime: totalTime,
                    sessions: sessions,
                    averageSessionDuration: avgDuration
                )
                continuation.resume(returning: metrics)
            }
        }
    }
    
    // MARK: - Progress Metrics
    
    public func getProgressMetrics(totalActivities: Int) async -> ProgressMetrics {
        await withCheckedContinuation { continuation in
            queue.async {
                let completed = self.statements.filter { $0.verb == .completed }
                let uniqueCompleted = Set(completed.compactMap { self.getActivityId($0) })
                let completionRate = Double(uniqueCompleted.count) / Double(totalActivities)
                
                let metrics = ProgressMetrics(
                    completionRate: completionRate,
                    completedActivities: uniqueCompleted.count,
                    totalActivities: totalActivities,
                    trend: []
                )
                continuation.resume(returning: metrics)
            }
        }
    }
    
    public func getProgressTrend(days: Int) async -> [DailyProgress] {
        await withCheckedContinuation { continuation in
            queue.async {
                let calendar = Calendar.current
                let now = Date()
                var trend: [DailyProgress] = []
                
                for dayOffset in 0..<days {
                    let targetDate = calendar.date(byAdding: .day, value: -dayOffset, to: now)!
                    let dayStart = calendar.startOfDay(for: targetDate)
                    let dayEnd = calendar.date(byAdding: .day, value: 1, to: dayStart)!
                    
                    let dayStatements = self.statements.filter { statement in
                        guard let timestamp = statement.timestamp else { return false }
                        return timestamp >= dayStart && timestamp < dayEnd && statement.verb == .completed
                    }
                    
                    trend.append(DailyProgress(date: dayStart, completedCount: dayStatements.count))
                }
                
                continuation.resume(returning: trend.reversed())
            }
        }
    }
    
    // MARK: - Performance Metrics
    
    public func getPerformanceMetrics() async -> PerformanceMetrics {
        await withCheckedContinuation { continuation in
            queue.async {
                let resultsWithSuccess = self.statements.compactMap { statement -> Bool? in
                    statement.result?.success
                }
                
                let successCount = resultsWithSuccess.filter { $0 }.count
                let successRate = resultsWithSuccess.isEmpty ? 0 : Double(successCount) / Double(resultsWithSuccess.count)
                
                let scores = self.statements.compactMap { $0.result?.score?.scaled }
                let avgScore = scores.isEmpty ? 0 : scores.reduce(0, +) / Double(scores.count)
                
                let metrics = PerformanceMetrics(
                    successRate: successRate,
                    averageScore: avgScore,
                    scoreDistribution: [:],
                    improvementTrend: 0
                )
                continuation.resume(returning: metrics)
            }
        }
    }
    
    public func getScoreDistribution() async -> [Double: Int] {
        await withCheckedContinuation { continuation in
            queue.async {
                var distribution: [Double: Int] = [:]
                
                let scores = self.statements.compactMap { $0.result?.score?.scaled }
                for score in scores {
                    let rounded = round(score * 10) / 10 // Round to 0.1
                    distribution[rounded, default: 0] += 1
                }
                
                continuation.resume(returning: distribution)
            }
        }
    }
    
    // MARK: - Engagement Metrics
    
    public func getEngagementMetrics(period: Int) async -> EngagementMetrics {
        await withCheckedContinuation { continuation in
            queue.async {
                let calendar = Calendar.current
                let now = Date()
                let periodStart = calendar.date(byAdding: .day, value: -period, to: now)!
                
                var activeDates = Set<Date>()
                
                for statement in self.statements {
                    guard let timestamp = statement.timestamp,
                          timestamp >= periodStart else { continue }
                    
                    let dayStart = calendar.startOfDay(for: timestamp)
                    activeDates.insert(dayStart)
                }
                
                let frequency = Double(activeDates.count) / Double(period)
                
                let metrics = EngagementMetrics(
                    activeDays: activeDates.count,
                    frequency: frequency,
                    peakHours: [],
                    averageTimePerDay: 0
                )
                continuation.resume(returning: metrics)
            }
        }
    }
    
    public func getPeakLearningHours() async -> [HourActivity] {
        await withCheckedContinuation { continuation in
            queue.async {
                var hourCounts: [Int: Int] = [:]
                let calendar = Calendar.current
                
                for statement in self.statements {
                    guard let timestamp = statement.timestamp else { continue }
                    let hour = calendar.component(.hour, from: timestamp)
                    hourCounts[hour, default: 0] += 1
                }
                
                let activities = hourCounts.map { HourActivity(hour: $0.key, count: $0.value) }
                    .sorted { $0.count > $1.count }
                
                continuation.resume(returning: activities)
            }
        }
    }
    
    // MARK: - Filtering
    
    public func getMetrics(from startDate: Date, to endDate: Date) async -> GeneralMetrics {
        await withCheckedContinuation { continuation in
            queue.async {
                let filtered = self.statements.filter { statement in
                    guard let timestamp = statement.timestamp else { return false }
                    return timestamp >= startDate && timestamp <= endDate
                }
                
                let metrics = self.calculateMetricsForStatements(filtered)
                continuation.resume(returning: metrics)
            }
        }
    }
    
    public func getMetricsByActivity(activityId: String) async -> GeneralMetrics {
        await withCheckedContinuation { continuation in
            queue.async {
                let filtered = self.statements.filter { statement in
                    self.getActivityId(statement) == activityId
                }
                
                let metrics = self.calculateMetricsForStatements(filtered)
                continuation.resume(returning: metrics)
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func calculateGeneralMetrics() -> GeneralMetrics {
        let scores = statements.compactMap { $0.result?.score?.scaled }
        let avgScore = scores.isEmpty ? 0 : scores.reduce(0, +) / Double(scores.count)
        
        return GeneralMetrics(
            totalStatements: statements.count,
            averageScore: avgScore,
            lastUpdated: Date()
        )
    }
    
    private func calculateMetricsForStatements(_ statements: [XAPIStatement]) -> GeneralMetrics {
        let scores = statements.compactMap { $0.result?.score?.scaled }
        let avgScore = scores.isEmpty ? 0 : scores.reduce(0, +) / Double(scores.count)
        
        return GeneralMetrics(
            totalStatements: statements.count,
            averageScore: avgScore,
            lastUpdated: Date()
        )
    }
    
    private func extractSessions() -> [LearningTimeMetrics.Session] {
        var sessions: [LearningTimeMetrics.Session] = []
        var sessionStart: Date?
        
        let sorted = statements.sorted { ($0.timestamp ?? Date()) < ($1.timestamp ?? Date()) }
        
        for statement in sorted {
            guard let timestamp = statement.timestamp else { continue }
            
            if statement.verb == .launched {
                sessionStart = timestamp
            } else if statement.verb == .terminated, let start = sessionStart {
                let session = LearningTimeMetrics.Session(
                    start: start,
                    end: timestamp,
                    duration: timestamp.timeIntervalSince(start)
                )
                sessions.append(session)
                sessionStart = nil
            }
        }
        
        return sessions
    }
    
    private func getActivityId(_ statement: XAPIStatement) -> String? {
        switch statement.object {
        case .activity(let activity):
            return activity.id
        default:
            return nil
        }
    }
    
    // MARK: - Cache Management
    
    private func getCachedMetrics() -> GeneralMetrics? {
        guard let cache = metricsCache,
              let validUntil = cacheValidUntil,
              Date() < validUntil else {
            return nil
        }
        return cache
    }
    
    private func cacheMetrics(_ metrics: GeneralMetrics) {
        metricsCache = metrics
        cacheValidUntil = Date().addingTimeInterval(cacheLifetime)
    }
    
    private func invalidateCache() {
        metricsCache = nil
        cacheValidUntil = nil
    }
} 