//
//  LearningMetrics.swift
//  LMS
//
//  Created on Sprint 42 Day 3 - Analytics
//

import Foundation

/// Определения и вычисления для метрик обучения
public enum LearningMetrics {
    
    // MARK: - Metric Types
    
    public enum MetricType: String, CaseIterable {
        case completion = "completion_rate"
        case averageScore = "average_score"
        case timeSpent = "time_spent"
        case attempts = "attempts_count"
        case successRate = "success_rate"
        case engagement = "engagement_level"
        case velocity = "learning_velocity"
        case retention = "retention_rate"
    }
    
    // MARK: - Calculations
    
    /// Вычисляет скорость обучения (activities per hour)
    public static func calculateLearningVelocity(
        completedActivities: Int,
        totalTime: TimeInterval
    ) -> Double {
        guard totalTime > 0 else { return 0 }
        let hours = totalTime / 3600
        return Double(completedActivities) / hours
    }
    
    /// Вычисляет уровень вовлеченности (0-1)
    public static func calculateEngagementLevel(
        activeDays: Int,
        totalDays: Int,
        avgSessionDuration: TimeInterval,
        optimalSessionDuration: TimeInterval = 2700 // 45 minutes
    ) -> Double {
        guard totalDays > 0 else { return 0 }
        
        let frequencyScore = Double(activeDays) / Double(totalDays)
        let durationScore = min(avgSessionDuration / optimalSessionDuration, 1.0)
        
        return (frequencyScore + durationScore) / 2
    }
    
    /// Вычисляет коэффициент удержания знаний
    public static func calculateRetentionRate(
        initialScore: Double,
        retestScore: Double,
        daysBetween: Int
    ) -> Double {
        guard initialScore > 0 else { return 0 }
        
        let retention = retestScore / initialScore
        let decayFactor = 1.0 - (Double(daysBetween) * 0.01) // 1% decay per day
        
        return min(retention / decayFactor, 1.0)
    }
    
    /// Вычисляет прогнозируемое время завершения
    public static func estimateCompletionTime(
        completed: Int,
        total: Int,
        elapsedTime: TimeInterval
    ) -> TimeInterval? {
        guard completed > 0 && completed < total else { return nil }
        
        let remaining = total - completed
        let avgTimePerActivity = elapsedTime / Double(completed)
        
        return avgTimePerActivity * Double(remaining)
    }
    
    // MARK: - Thresholds
    
    public struct PerformanceThresholds {
        public static let excellent = 0.9
        public static let good = 0.8
        public static let satisfactory = 0.7
        public static let needsImprovement = 0.6
        
        public static func getLevel(for score: Double) -> PerformanceLevel {
            switch score {
            case excellent...:
                return .excellent
            case good..<excellent:
                return .good
            case satisfactory..<good:
                return .satisfactory
            case needsImprovement..<satisfactory:
                return .needsImprovement
            default:
                return .poor
            }
        }
    }
    
    public enum PerformanceLevel: String {
        case excellent = "Excellent"
        case good = "Good"
        case satisfactory = "Satisfactory"
        case needsImprovement = "Needs Improvement"
        case poor = "Poor"
        
        public var emoji: String {
            switch self {
            case .excellent: return "🌟"
            case .good: return "✨"
            case .satisfactory: return "👍"
            case .needsImprovement: return "📈"
            case .poor: return "⚠️"
            }
        }
    }
    
    // MARK: - Aggregations
    
    /// Агрегирует оценки по различным периодам
    public static func aggregateScoresByPeriod(
        statements: [XAPIStatement],
        period: Calendar.Component
    ) -> [Date: [Double]] {
        var aggregated: [Date: [Double]] = [:]
        let calendar = Calendar.current
        
        for statement in statements {
            guard let timestamp = statement.timestamp,
                  let score = statement.result?.score?.scaled else { continue }
            
            let periodStart = calendar.dateInterval(of: period, for: timestamp)?.start ?? timestamp
            aggregated[periodStart, default: []].append(score)
        }
        
        return aggregated
    }
    
    /// Находит паттерны в обучении
    public static func findLearningPatterns(
        statements: [XAPIStatement]
    ) -> LearningPattern {
        let calendar = Calendar.current
        var hourCounts: [Int: Int] = [:]
        var dayCounts: [Int: Int] = [:]
        var streaks: [Int] = []
        
        // Analyze time patterns
        for statement in statements {
            guard let timestamp = statement.timestamp else { continue }
            
            let hour = calendar.component(.hour, from: timestamp)
            let weekday = calendar.component(.weekday, from: timestamp)
            
            hourCounts[hour, default: 0] += 1
            dayCounts[weekday, default: 0] += 1
        }
        
        // Find peak times
        let peakHour = hourCounts.max(by: { $0.value < $1.value })?.key
        let peakDay = dayCounts.max(by: { $0.value < $1.value })?.key
        
        return LearningPattern(
            preferredHour: peakHour,
            preferredWeekday: peakDay,
            averageStreak: streaks.isEmpty ? 0 : streaks.reduce(0, +) / streaks.count
        )
    }
    
    // MARK: - Types
    
    public struct LearningPattern {
        public let preferredHour: Int?
        public let preferredWeekday: Int?
        public let averageStreak: Int
        
        public var timePreference: String {
            guard let hour = preferredHour else { return "No preference" }
            
            switch hour {
            case 5..<12:
                return "Morning learner 🌅"
            case 12..<17:
                return "Afternoon learner ☀️"
            case 17..<22:
                return "Evening learner 🌆"
            default:
                return "Night owl 🦉"
            }
        }
    }
    
    // MARK: - Formatters
    
    /// Форматирует время обучения в читаемый вид
    public static func formatLearningTime(_ seconds: TimeInterval) -> String {
        let hours = Int(seconds) / 3600
        let minutes = (Int(seconds) % 3600) / 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
    
    /// Форматирует процент с нужной точностью
    public static func formatPercentage(_ value: Double, decimals: Int = 1) -> String {
        let percentage = value * 100
        return String(format: "%.\(decimals)f%%", percentage)
    }
} 