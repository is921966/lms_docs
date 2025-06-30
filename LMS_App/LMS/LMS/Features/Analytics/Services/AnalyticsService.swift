//
//  AnalyticsService.swift
//  LMS
//
//  Created on 26/01/2025.
//

import Combine
import Foundation

// MARK: - Analytics Service Protocol
protocol AnalyticsServiceProtocol {
    func trackEvent(_ event: AnalyticsData)
    func getAnalyticsSummary(for period: AnalyticsPeriod) -> AnalyticsSummary
    func getUserPerformance(userId: String, period: AnalyticsPeriod) -> UserPerformance?
    func getCourseStatistics(period: AnalyticsPeriod) -> [CourseStatistics]
    func getCompetencyProgress(period: AnalyticsPeriod) -> [CompetencyProgress]
    func generateReport(_ report: Report) -> AnyPublisher<Report, Error>
    func getReports(for userId: String) -> [Report]
    func exportReport(_ report: Report, format: ReportFormat) -> URL?
}

// MARK: - Analytics Service
class AnalyticsService: ObservableObject, AnalyticsServiceProtocol {
    @Published var analyticsData: [AnalyticsData] = []
    @Published var reports: [Report] = []

    private let currentUserId = "user-1" // Mock user

    init() {
        loadMockData()
    }

    // MARK: - Track Event
    func trackEvent(_ event: AnalyticsData) {
        analyticsData.append(event)
    }

    // MARK: - Get Analytics Summary
    func getAnalyticsSummary(for period: AnalyticsPeriod) -> AnalyticsSummary {
        let endDate = Date()
        let startDate = Calendar.current.date(byAdding: .day, value: -period.days, to: endDate)!

        // Mock data
        let topPerformers = [
            UserPerformance(
                userId: "user-1",
                userName: "Иван Иванов",
                avatar: nil,
                totalScore: 950,
                completedCourses: 12,
                averageTestScore: 92.5,
                learningHours: 48.5,
                rank: 1,
                badges: ["star", "trophy", "crown"],
                trend: .improving
            ),
            UserPerformance(
                userId: "user-2",
                userName: "Мария Петрова",
                avatar: nil,
                totalScore: 920,
                completedCourses: 10,
                averageTestScore: 90.0,
                learningHours: 42.0,
                rank: 2,
                badges: ["star", "trophy"],
                trend: .stable
            ),
            UserPerformance(
                userId: "user-3",
                userName: "Алексей Сидоров",
                avatar: nil,
                totalScore: 890,
                completedCourses: 9,
                averageTestScore: 88.5,
                learningHours: 38.5,
                rank: 3,
                badges: ["star"],
                trend: .improving
            )
        ]

        let popularCourses = [
            CourseStatistics(
                courseId: "course-1",
                courseName: "Основы продаж",
                enrolledCount: 250,
                completedCount: 180,
                averageProgress: 0.72,
                averageScore: 85.5,
                averageTimeToComplete: 12.5,
                satisfactionRating: 4.5
            ),
            CourseStatistics(
                courseId: "course-2",
                courseName: "Клиентский сервис",
                enrolledCount: 200,
                completedCount: 150,
                averageProgress: 0.75,
                averageScore: 88.0,
                averageTimeToComplete: 10.0,
                satisfactionRating: 4.7
            ),
            CourseStatistics(
                courseId: "course-3",
                courseName: "Визуальный мерчандайзинг",
                enrolledCount: 150,
                completedCount: 90,
                averageProgress: 0.60,
                averageScore: 82.0,
                averageTimeToComplete: 15.0,
                satisfactionRating: 4.3
            )
        ]

        let competencyProgress = [
            CompetencyProgress(
                competencyId: "comp-1",
                competencyName: "Продажи",
                usersCount: 250,
                averageLevel: 3.5,
                targetLevel: 4.0,
                progressPercentage: 87.5
            ),
            CompetencyProgress(
                competencyId: "comp-2",
                competencyName: "Коммуникация",
                usersCount: 300,
                averageLevel: 3.8,
                targetLevel: 4.0,
                progressPercentage: 95.0
            ),
            CompetencyProgress(
                competencyId: "comp-3",
                competencyName: "Лидерство",
                usersCount: 50,
                averageLevel: 3.2,
                targetLevel: 4.5,
                progressPercentage: 71.1
            )
        ]

        return AnalyticsSummary(
            period: period,
            startDate: startDate,
            endDate: endDate,
            totalUsers: 350,
            activeUsers: 280,
            completedCourses: 420,
            averageScore: 86.5,
            totalLearningHours: 5_250.0,
            topPerformers: topPerformers,
            popularCourses: popularCourses,
            competencyProgress: competencyProgress
        )
    }

    // MARK: - Get User Performance
    func getUserPerformance(userId: String, period: AnalyticsPeriod) -> UserPerformance? {
        UserPerformance(
            userId: userId,
            userName: "Иван Иванов",
            avatar: nil,
            totalScore: 950,
            completedCourses: 12,
            averageTestScore: 92.5,
            learningHours: 48.5,
            rank: 1,
            badges: ["star", "trophy", "crown"],
            trend: .improving
        )
    }

    // MARK: - Get Course Statistics
    func getCourseStatistics(period: AnalyticsPeriod) -> [CourseStatistics] {
        [
            CourseStatistics(
                courseId: "course-1",
                courseName: "Основы продаж",
                enrolledCount: 250,
                completedCount: 180,
                averageProgress: 0.72,
                averageScore: 85.5,
                averageTimeToComplete: 12.5,
                satisfactionRating: 4.5
            ),
            CourseStatistics(
                courseId: "course-2",
                courseName: "Клиентский сервис",
                enrolledCount: 200,
                completedCount: 150,
                averageProgress: 0.75,
                averageScore: 88.0,
                averageTimeToComplete: 10.0,
                satisfactionRating: 4.7
            ),
            CourseStatistics(
                courseId: "course-3",
                courseName: "Визуальный мерчандайзинг",
                enrolledCount: 150,
                completedCount: 90,
                averageProgress: 0.60,
                averageScore: 82.0,
                averageTimeToComplete: 15.0,
                satisfactionRating: 4.3
            ),
            CourseStatistics(
                courseId: "course-4",
                courseName: "Товароведение",
                enrolledCount: 180,
                completedCount: 120,
                averageProgress: 0.67,
                averageScore: 83.5,
                averageTimeToComplete: 14.0,
                satisfactionRating: 4.4
            )
        ]
    }

    // MARK: - Get Competency Progress
    func getCompetencyProgress(period: AnalyticsPeriod) -> [CompetencyProgress] {
        [
            CompetencyProgress(
                competencyId: "comp-1",
                competencyName: "Продажи",
                usersCount: 250,
                averageLevel: 3.5,
                targetLevel: 4.0,
                progressPercentage: 87.5
            ),
            CompetencyProgress(
                competencyId: "comp-2",
                competencyName: "Коммуникация",
                usersCount: 300,
                averageLevel: 3.8,
                targetLevel: 4.0,
                progressPercentage: 95.0
            ),
            CompetencyProgress(
                competencyId: "comp-3",
                competencyName: "Лидерство",
                usersCount: 50,
                averageLevel: 3.2,
                targetLevel: 4.5,
                progressPercentage: 71.1
            ),
            CompetencyProgress(
                competencyId: "comp-4",
                competencyName: "Аналитика",
                usersCount: 80,
                averageLevel: 3.0,
                targetLevel: 4.0,
                progressPercentage: 75.0
            )
        ]
    }

    // MARK: - Generate Report
    func generateReport(_ report: Report) -> AnyPublisher<Report, Error> {
        Future<Report, Error> { promise in
            // Simulate report generation
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                var updatedReport = report
                updatedReport.status = .ready
                updatedReport.updatedAt = Date()

                // Add sections based on report type
                updatedReport.sections = self.generateReportSections(for: report.type)

                self.reports.append(updatedReport)
                promise(.success(updatedReport))
            }
        }
        .eraseToAnyPublisher()
    }

    // MARK: - Get Reports
    func getReports(for userId: String) -> [Report] {
        reports.filter { $0.createdBy == userId || $0.recipients.contains(userId) }
    }

    // MARK: - Export Report
    func exportReport(_ report: Report, format: ReportFormat) -> URL? {
        // Mock export - in real app would generate actual file
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileName = "\(report.title)_\(Date().timeIntervalSince1970).\(format.rawValue.lowercased())"
        let fileURL = documentsPath.appendingPathComponent(fileName)

        // Create mock file
        let content = "Mock report content for \(report.title)"
        try? content.write(to: fileURL, atomically: true, encoding: .utf8)

        return fileURL
    }

    // MARK: - Private Methods

    private func loadMockData() {
        // Load mock analytics events
        analyticsData = generateMockAnalyticsData()

        // Load mock reports
        reports = generateMockReports()
    }

    private func generateMockAnalyticsData() -> [AnalyticsData] {
        var data: [AnalyticsData] = []

        // Course progress events
        for i in 1...10 {
            data.append(AnalyticsData(
                userId: "user-\(i % 3 + 1)",
                timestamp: Date().addingTimeInterval(-Double(i * 3_600)),
                type: .courseProgress,
                metrics: ["progress": Double.random(in: 0.5...1.0), "score": Double.random(in: 70...100)],
                metadata: ["courseId": "course-\(i % 4 + 1)"]
            ))
        }

        // Test results
        for i in 1...8 {
            data.append(AnalyticsData(
                userId: "user-\(i % 3 + 1)",
                timestamp: Date().addingTimeInterval(-Double(i * 7_200)),
                type: .testResult,
                metrics: ["score": Double.random(in: 60...100), "time": Double.random(in: 300...1_800)],
                metadata: ["testId": "test-\(i % 3 + 1)"]
            ))
        }

        return data
    }

    private func generateMockReports() -> [Report] {
        [
            Report(
                title: "Ежемесячный отчет по обучению",
                description: "Общая статистика обучения за последний месяц",
                type: .learningProgress,
                status: .ready,
                period: .month,
                createdBy: currentUserId,
                sections: generateReportSections(for: .learningProgress)
            ),
            Report(
                title: "Матрица компетенций команды",
                description: "Текущий уровень компетенций сотрудников",
                type: .competencyMatrix,
                status: .ready,
                period: .all,
                createdBy: currentUserId,
                sections: generateReportSections(for: .competencyMatrix)
            ),
            Report(
                title: "ROI обучения Q4 2024",
                description: "Анализ возврата инвестиций в обучение",
                type: .roi,
                status: .draft,
                period: .quarter,
                createdBy: currentUserId
            )
        ]
    }

    private func generateReportSections(for type: ReportType) -> [ReportSection] {
        switch type {
        case .learningProgress:
            return [
                ReportSection(
                    title: "Общая статистика",
                    type: .metrics,
                    order: 1,
                    data: .metrics([
                        MetricData(title: "Активные пользователи", value: "280", change: 12.5, icon: "person.3.fill"),
                        MetricData(title: "Завершенные курсы", value: "420", change: 8.3, icon: "checkmark.seal.fill"),
                        MetricData(title: "Средний балл", value: "86.5", change: 2.1, unit: "%", icon: "star.fill"),
                        MetricData(title: "Часы обучения", value: "5,250", change: 15.7, icon: "clock.fill")
                    ])
                ),
                ReportSection(
                    title: "Прогресс по месяцам",
                    type: .chart,
                    order: 2,
                    data: .chart(ChartData(
                        type: .line,
                        title: "Динамика обучения",
                        xAxis: "Месяц",
                        yAxis: "Завершенные курсы",
                        dataPoints: [
                            DataPoint(label: "Янв", value: 320),
                            DataPoint(label: "Фев", value: 350),
                            DataPoint(label: "Мар", value: 380),
                            DataPoint(label: "Апр", value: 420)
                        ]
                    ))
                )
            ]

        case .competencyMatrix:
            return [
                ReportSection(
                    title: "Сводка по компетенциям",
                    type: .summary,
                    order: 1,
                    data: .summary(SummaryData(
                        highlights: [
                            "95% сотрудников достигли целевого уровня в коммуникации",
                            "Лидерские компетенции требуют дополнительного развития",
                            "Средний уровень компетенций вырос на 0.3 пункта"
                        ],
                        keyFindings: [
                            "Наибольший прогресс в области продаж (+0.5)",
                            "50 сотрудников развивают лидерские навыки",
                            "Требуется фокус на аналитических компетенциях"
                        ],
                        recommendations: [
                            "Запустить программу развития лидеров",
                            "Увеличить количество курсов по аналитике",
                            "Провести оценку компетенций через 3 месяца"
                        ]
                    ))
                ),
                ReportSection(
                    title: "Матрица компетенций",
                    type: .table,
                    order: 2,
                    data: .table(TableData(
                        headers: ["Компетенция", "Сотрудников", "Средний уровень", "Цель", "Прогресс"],
                        rows: [
                            ["Продажи", "250", "3.5", "4.0", "87.5%"],
                            ["Коммуникация", "300", "3.8", "4.0", "95.0%"],
                            ["Лидерство", "50", "3.2", "4.5", "71.1%"],
                            ["Аналитика", "80", "3.0", "4.0", "75.0%"]
                        ]
                    ))
                )
            ]

        default:
            return []
        }
    }
}
