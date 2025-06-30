//
//  AnalyticsViewModel.swift
//  LMS
//
//  Created on 26/01/2025.
//

import Combine
import Foundation
import SwiftUI

// MARK: - Analytics View Model
class AnalyticsViewModel: ObservableObject {
    @Published var selectedPeriod: AnalyticsPeriod = .month
    @Published var analyticsSummary: AnalyticsSummary?
    @Published var userPerformance: UserPerformance?
    @Published var courseStatistics: [CourseStatistics] = []
    @Published var competencyProgress: [CompetencyProgress] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    // Filters
    @Published var selectedDepartment: String?
    @Published var selectedPosition: String?
    @Published var selectedCourse: String?

    private let service: AnalyticsServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    private let currentUserId = "user-1"

    init(service: AnalyticsServiceProtocol = AnalyticsService()) {
        self.service = service
        loadAnalytics()
    }

    // MARK: - Load Analytics
    func loadAnalytics() {
        isLoading = true
        errorMessage = nil

        // Load summary
        analyticsSummary = service.getAnalyticsSummary(for: selectedPeriod)

        // Load user performance
        userPerformance = service.getUserPerformance(userId: currentUserId, period: selectedPeriod)

        // Load course statistics
        courseStatistics = service.getCourseStatistics(period: selectedPeriod)

        // Load competency progress
        competencyProgress = service.getCompetencyProgress(period: selectedPeriod)

        isLoading = false
    }

    // MARK: - Change Period
    func changePeriod(_ period: AnalyticsPeriod) {
        selectedPeriod = period
        loadAnalytics()
    }

    // MARK: - Track Event
    func trackEvent(type: AnalyticsType, metrics: [String: Double], metadata: [String: String] = [:]) {
        let event = AnalyticsData(
            userId: currentUserId,
            type: type,
            metrics: metrics,
            metadata: metadata
        )
        service.trackEvent(event)
    }

    // MARK: - Filtered Data
    var filteredCourseStatistics: [CourseStatistics] {
        guard let selectedCourse = selectedCourse else {
            return courseStatistics
        }
        return courseStatistics.filter { $0.courseId == selectedCourse }
    }

    var topPerformers: [UserPerformance] {
        analyticsSummary?.topPerformers ?? []
    }

    var popularCourses: [CourseStatistics] {
        analyticsSummary?.popularCourses ?? []
    }

    // MARK: - Chart Data
    var learningProgressChartData: [DataPoint] {
        // Generate mock chart data based on period
        switch selectedPeriod {
        case .day:
            return (0..<24).map { hour in
                DataPoint(
                    label: "\(hour):00",
                    value: Double.random(in: 0...20)
                )
            }
        case .week:
            return ["Пн", "Вт", "Ср", "Чт", "Пт", "Сб", "Вс"].map { day in
                DataPoint(
                    label: day,
                    value: Double.random(in: 40...100)
                )
            }
        case .month:
            return (1...4).map { week in
                DataPoint(
                    label: "Неделя \(week)",
                    value: Double.random(in: 80...120)
                )
            }
        default:
            return []
        }
    }

    var competencyGrowthChartData: [DataPoint] {
        competencyProgress.map { competency in
            DataPoint(
                label: competency.competencyName,
                value: competency.progressPercentage
            )
        }
    }

    var testScoresChartData: [DataPoint] {
        // Mock test scores over time
        switch selectedPeriod {
        case .week:
            return (1...7).map { day in
                DataPoint(
                    label: "День \(day)",
                    value: Double.random(in: 70...95)
                )
            }
        case .month:
            return (1...4).map { week in
                DataPoint(
                    label: "Неделя \(week)",
                    value: Double.random(in: 75...92)
                )
            }
        default:
            return []
        }
    }

    // MARK: - Statistics
    var totalLearningHours: String {
        guard let summary = analyticsSummary else { return "0" }
        return String(format: "%.0f", summary.totalLearningHours)
    }

    var averageScore: String {
        guard let summary = analyticsSummary else { return "0%" }
        return String(format: "%.1f%%", summary.averageScore)
    }

    var activeUsersPercentage: Double {
        guard let summary = analyticsSummary else { return 0 }
        return Double(summary.activeUsers) / Double(summary.totalUsers) * 100
    }

    var completionRate: Double {
        let totalEnrolled = courseStatistics.reduce(0) { $0 + $1.enrolledCount }
        let totalCompleted = courseStatistics.reduce(0) { $0 + $1.completedCount }
        guard totalEnrolled > 0 else { return 0 }
        return Double(totalCompleted) / Double(totalEnrolled) * 100
    }

    // MARK: - Export
    func exportDashboard() -> URL? {
        // Create a simple HTML dashboard
        let html = """
        <html>
        <head>
            <title>Analytics Dashboard - \(selectedPeriod.rawValue)</title>
            <style>
                body { font-family: Arial, sans-serif; padding: 20px; }
                h1 { color: #333; }
                .metric { display: inline-block; margin: 10px; padding: 15px; background: #f0f0f0; border-radius: 8px; }
                .metric-value { font-size: 24px; font-weight: bold; color: #007AFF; }
                table { border-collapse: collapse; width: 100%; margin-top: 20px; }
                th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
                th { background-color: #f2f2f2; }
            </style>
        </head>
        <body>
            <h1>Аналитика обучения - \(selectedPeriod.rawValue)</h1>

            <div class="metrics">
                <div class="metric">
                    <div>Активные пользователи</div>
                    <div class="metric-value">\(analyticsSummary?.activeUsers ?? 0)</div>
                </div>
                <div class="metric">
                    <div>Завершенные курсы</div>
                    <div class="metric-value">\(analyticsSummary?.completedCourses ?? 0)</div>
                </div>
                <div class="metric">
                    <div>Средний балл</div>
                    <div class="metric-value">\(averageScore)</div>
                </div>
            </div>

            <h2>Топ исполнители</h2>
            <table>
                <tr>
                    <th>Ранг</th>
                    <th>Имя</th>
                    <th>Баллы</th>
                    <th>Курсы</th>
                </tr>
                \(topPerformers.map { performer in
                    "<tr><td>\(performer.rank)</td><td>\(performer.userName)</td><td>\(performer.totalScore)</td><td>\(performer.completedCourses)</td></tr>"
                }.joined())
            </table>
        </body>
        </html>
        """

        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileName = "analytics_dashboard_\(Date().timeIntervalSince1970).html"
        let fileURL = documentsPath.appendingPathComponent(fileName)

        try? html.write(to: fileURL, atomically: true, encoding: .utf8)

        return fileURL
    }
}
