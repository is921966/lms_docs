//
//  AnalyticsData.swift
//  LMS
//
//  Created on 26/01/2025.
//

import Foundation

// MARK: - Analytics Data
struct AnalyticsData: Identifiable, Codable {
    let id: UUID
    let userId: String
    let timestamp: Date
    let type: AnalyticsType
    let metrics: [String: Double]
    let metadata: [String: String]

    init(
        id: UUID = UUID(),
        userId: String,
        timestamp: Date = Date(),
        type: AnalyticsType,
        metrics: [String: Double] = [:],
        metadata: [String: String] = [:]
    ) {
        self.id = id
        self.userId = userId
        self.timestamp = timestamp
        self.type = type
        self.metrics = metrics
        self.metadata = metadata
    }
}

// MARK: - Analytics Type
enum AnalyticsType: String, CaseIterable, Codable {
    case courseProgress = "Прогресс курса"
    case testResult = "Результат теста"
    case competencyGrowth = "Рост компетенций"
    case learningTime = "Время обучения"
    case engagement = "Вовлеченность"
    case achievement = "Достижение"

    var icon: String {
        switch self {
        case .courseProgress: return "chart.line.uptrend.xyaxis"
        case .testResult: return "checkmark.seal"
        case .competencyGrowth: return "star.fill"
        case .learningTime: return "clock"
        case .engagement: return "person.3.fill"
        case .achievement: return "trophy.fill"
        }
    }
}

// MARK: - Analytics Period
enum AnalyticsPeriod: String, CaseIterable, Codable {
    case day = "День"
    case week = "Неделя"
    case month = "Месяц"
    case quarter = "Квартал"
    case year = "Год"
    case all = "Все время"

    var days: Int {
        switch self {
        case .day: return 1
        case .week: return 7
        case .month: return 30
        case .quarter: return 90
        case .year: return 365
        case .all: return 9_999
        }
    }
}

// MARK: - Analytics Summary
struct AnalyticsSummary {
    let period: AnalyticsPeriod
    let startDate: Date
    let endDate: Date
    let totalUsers: Int
    let activeUsers: Int
    let completedCourses: Int
    let averageScore: Double
    let totalLearningHours: Double
    let topPerformers: [UserPerformance]
    let popularCourses: [CourseStatistics]
    let competencyProgress: [CompetencyProgress]
}

// MARK: - User Performance
struct UserPerformance: Identifiable {
    let id = UUID()
    let userId: String
    let userName: String
    let avatar: String?
    let totalScore: Double
    let completedCourses: Int
    let averageTestScore: Double
    let learningHours: Double
    let rank: Int
    let badges: [String]
    let trend: PerformanceTrend
}

// MARK: - Performance Trend
enum PerformanceTrend {
    case improving
    case stable
    case declining

    var icon: String {
        switch self {
        case .improving: return "arrow.up.right"
        case .stable: return "arrow.right"
        case .declining: return "arrow.down.right"
        }
    }

    var color: String {
        switch self {
        case .improving: return "green"
        case .stable: return "blue"
        case .declining: return "red"
        }
    }
}

// MARK: - Course Statistics
struct CourseStatistics: Identifiable {
    let id = UUID()
    let courseId: String
    let courseName: String
    let enrolledCount: Int
    let completedCount: Int
    let averageProgress: Double
    let averageScore: Double
    let averageTimeToComplete: Double // в часах
    let satisfactionRating: Double
}

// MARK: - Competency Progress
struct CompetencyProgress: Identifiable {
    let id = UUID()
    let competencyId: String
    let competencyName: String
    let usersCount: Int
    let averageLevel: Double
    let targetLevel: Double
    let progressPercentage: Double
}

// MARK: - Learning Path Analytics
struct LearningPathAnalytics {
    let pathId: String
    let pathName: String
    let totalUsers: Int
    let completionRate: Double
    let averageTimeToComplete: Double
    let successRate: Double
    let commonDropOffPoints: [DropOffPoint]
}

// MARK: - Drop Off Point
struct DropOffPoint: Identifiable {
    let id = UUID()
    let stage: String
    let dropOffRate: Double
    let averageTimeSpent: Double
    let commonReasons: [String]
}
