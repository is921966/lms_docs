//
//  LearningValues.swift
//  LMS
//
//  Created by AI Assistant on 01/31/25.
//
//  Copyright © 2025 LMS. All rights reserved.
//

import Foundation

// MARK: - Course Progress

/// Progress in a course (0-100%)
public struct CourseProgress: NumericValueObject {
    public let value: Double
    
    public static let minValue: Double = 0.0
    public static let maxValue: Double = 100.0
    
    public init?(_ value: Double) {
        guard Self.isValid(value) else { return nil }
        self.value = value
    }
    
    /// Create from percentage
    public static func percentage(_ value: Double) -> CourseProgress? {
        return CourseProgress(value)
    }
    
    /// Create from fraction (0.0 - 1.0)
    public static func fraction(_ value: Double) -> CourseProgress? {
        return CourseProgress(value * 100.0)
    }
    
    /// Progress as formatted string
    public var formatted: String {
        return "\(Int(value.rounded()))%"
    }
    
    /// Progress as fraction (0.0 - 1.0)
    public var fraction: Double {
        return value / 100.0
    }
    
    /// Check if course is completed
    public var isCompleted: Bool {
        return value >= 100.0
    }
    
    /// Check if course has been started
    public var hasStarted: Bool {
        return value > 0.0
    }
    
    /// Check if course is in progress
    public var isInProgress: Bool {
        return hasStarted && !isCompleted
    }
}

// MARK: - Domain Competency Level

/// Level of competency mastery (Domain layer)
public enum DomainCompetencyLevel: String, CaseIterable, Codable {
    case novice = "NOVICE"
    case beginner = "BEGINNER"
    case intermediate = "INTERMEDIATE"
    case advanced = "ADVANCED"
    case expert = "EXPERT"
    
    /// Numeric value for comparison (1-5)
    public var numericValue: Int {
        switch self {
        case .novice: return 1
        case .beginner: return 2
        case .intermediate: return 3
        case .advanced: return 4
        case .expert: return 5
        }
    }
    
    /// Localized display name
    public var displayName: String {
        switch self {
        case .novice: return "Новичок"
        case .beginner: return "Начинающий"
        case .intermediate: return "Средний"
        case .advanced: return "Продвинутый"
        case .expert: return "Эксперт"
        }
    }
    
    /// Minimum progress required to achieve this level
    public var requiredProgress: Double {
        switch self {
        case .novice: return 0.0
        case .beginner: return 20.0
        case .intermediate: return 40.0
        case .advanced: return 70.0
        case .expert: return 90.0
        }
    }
    
    /// Check if this level is higher than another
    public func isHigherThan(_ other: DomainCompetencyLevel) -> Bool {
        return self.numericValue > other.numericValue
    }
    
    /// Get the next level
    public var nextLevel: DomainCompetencyLevel? {
        switch self {
        case .novice: return .beginner
        case .beginner: return .intermediate
        case .intermediate: return .advanced
        case .advanced: return .expert
        case .expert: return nil
        }
    }
}

// MARK: - Course Duration

/// Duration of a course in minutes
public struct CourseDuration: NumericValueObject {
    public let value: Int
    
    public static let minValue: Int = 1
    public static let maxValue: Int = 10_080 // 1 week in minutes
    
    public init?(_ value: Int) {
        guard Self.isValid(value) else { return nil }
        self.value = value
    }
    
    /// Create from hours
    public static func hours(_ hours: Int) -> CourseDuration? {
        return CourseDuration(hours * 60)
    }
    
    /// Create from days
    public static func days(_ days: Int) -> CourseDuration? {
        return CourseDuration(days * 24 * 60)
    }
    
    /// Duration in hours
    public var hours: Double {
        return Double(value) / 60.0
    }
    
    /// Duration in days
    public var days: Double {
        return Double(value) / (24.0 * 60.0)
    }
    
    /// Formatted duration string
    public var formatted: String {
        if value < 60 {
            return "\(value) мин"
        } else if value < 1440 { // Less than a day
            let h = value / 60
            let m = value % 60
            if m == 0 {
                return "\(h) ч"
            } else {
                return "\(h) ч \(m) мин"
            }
        } else {
            let d = value / 1440
            let h = (value % 1440) / 60
            if h == 0 {
                return "\(d) дн"
            } else {
                return "\(d) дн \(h) ч"
            }
        }
    }
}

// MARK: - Test Score

/// Score on a test (0-100)
public struct TestScore: NumericValueObject {
    public let value: Int
    
    public static let minValue: Int = 0
    public static let maxValue: Int = 100
    
    public init?(_ value: Int) {
        guard Self.isValid(value) else { return nil }
        self.value = value
    }
    
    /// Check if score is passing (default threshold: 80%)
    public func isPassing(threshold: Int = 80) -> Bool {
        return value >= threshold
    }
    
    /// Get grade based on score
    public var grade: String {
        switch value {
        case 90...100: return "A"
        case 80..<90: return "B"
        case 70..<80: return "C"
        case 60..<70: return "D"
        default: return "F"
        }
    }
    
    /// Formatted score string
    public var formatted: String {
        return "\(value)%"
    }
}

// MARK: - Enrollment Status

/// Status of course enrollment
public enum EnrollmentStatus: String, CaseIterable, Codable {
    case pending = "PENDING"
    case active = "ACTIVE"
    case completed = "COMPLETED"
    case cancelled = "CANCELLED"
    case expired = "EXPIRED"
    
    /// Check if enrollment allows access to course
    public var allowsAccess: Bool {
        switch self {
        case .active, .completed:
            return true
        case .pending, .cancelled, .expired:
            return false
        }
    }
    
    /// Localized display name
    public var displayName: String {
        switch self {
        case .pending: return "Ожидает одобрения"
        case .active: return "Активен"
        case .completed: return "Завершен"
        case .cancelled: return "Отменен"
        case .expired: return "Истек"
        }
    }
} 