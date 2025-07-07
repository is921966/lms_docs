//
//  AnalyticsServiceTests.swift
//  LMSTests
//

import XCTest
import Combine
@testable import LMS

final class AnalyticsServiceTests: XCTestCase {
    
    var sut: AnalyticsService!
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        sut = AnalyticsService.shared
        cancellables = []
    }
    
    override func tearDown() {
        cancellables = nil
        sut = nil
        super.tearDown()
    }
    
    // MARK: - Singleton Tests
    
    func testSharedInstance() {
        let instance1 = AnalyticsService.shared
        let instance2 = AnalyticsService.shared
        XCTAssertTrue(instance1 === instance2)
    }
    
    // MARK: - Fetch Analytics Tests
    
    func testFetchAnalytics() {
        // Given
        let expectation = XCTestExpectation(description: "Analytics fetched")
        var receivedData: AnalyticsData?
        
        sut.$analyticsData
            .dropFirst()
            .sink { data in
                receivedData = data
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        // When
        sut.fetchAnalytics(for: .month)
        
        // Then
        wait(for: [expectation], timeout: 2.0)
        XCTAssertNotNil(receivedData)
        XCTAssertEqual(receivedData?.period, .month)
    }
    
    func testFetchAnalyticsForAllPeriods() {
        // Test each period
        AnalyticsPeriod.allCases.forEach { period in
            sut.fetchAnalytics(for: period)
            XCTAssertEqual(sut.analyticsData?.period, period)
        }
    }
    
    // MARK: - Analytics Data Tests
    
    func testAnalyticsDataProperties() {
        // When
        sut.fetchAnalytics(for: .week)
        
        // Then
        let data = sut.analyticsData
        XCTAssertNotNil(data)
        XCTAssertGreaterThanOrEqual(data?.totalUsers ?? 0, 0)
        XCTAssertGreaterThanOrEqual(data?.activeUsers ?? 0, 0)
        XCTAssertGreaterThanOrEqual(data?.averageScore ?? 0, 0)
        XCTAssertLessThanOrEqual(data?.averageScore ?? 0, 100)
        XCTAssertGreaterThanOrEqual(data?.learningHours ?? 0, 0)
    }
    
    func testAnalyticsDataHasCharts() {
        // When
        sut.fetchAnalytics(for: .month)
        
        // Then
        let data = sut.analyticsData
        XCTAssertNotNil(data?.learningProgressData)
        XCTAssertFalse(data?.learningProgressData.isEmpty ?? true)
        XCTAssertNotNil(data?.competencyGrowthData)
        XCTAssertFalse(data?.competencyGrowthData.isEmpty ?? true)
        XCTAssertNotNil(data?.testScoresData)
        XCTAssertFalse(data?.testScoresData.isEmpty ?? true)
    }
    
    func testAnalyticsDataHasTopPerformers() {
        // When
        sut.fetchAnalytics(for: .month)
        
        // Then
        let data = sut.analyticsData
        XCTAssertNotNil(data?.topPerformers)
        XCTAssertFalse(data?.topPerformers.isEmpty ?? true)
        XCTAssertLessThanOrEqual(data?.topPerformers.count ?? 0, 10)
    }
    
    func testAnalyticsDataHasCourseStatistics() {
        // When
        sut.fetchAnalytics(for: .year)
        
        // Then
        let data = sut.analyticsData
        XCTAssertNotNil(data?.courseStatistics)
        XCTAssertFalse(data?.courseStatistics.isEmpty ?? true)
    }
    
    func testAnalyticsDataHasCompetencyProgress() {
        // When
        sut.fetchAnalytics(for: .all)
        
        // Then
        let data = sut.analyticsData
        XCTAssertNotNil(data?.competencyProgress)
        XCTAssertFalse(data?.competencyProgress.isEmpty ?? true)
    }
    
    // MARK: - Reports Tests
    
    func testFetchReports() {
        // Given
        let expectation = XCTestExpectation(description: "Reports fetched")
        var receivedReports: [AnalyticsReport] = []
        
        sut.$reports
            .dropFirst()
            .sink { reports in
                receivedReports = reports
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        // When
        sut.fetchReports()
        
        // Then
        wait(for: [expectation], timeout: 2.0)
        XCTAssertFalse(receivedReports.isEmpty)
    }
    
    func testReportsProperties() {
        // When
        sut.fetchReports()
        
        // Then
        let reports = sut.reports
        XCTAssertFalse(reports.isEmpty)
        
        // Check first report
        if let firstReport = reports.first {
            XCTAssertFalse(firstReport.id.isEmpty)
            XCTAssertFalse(firstReport.title.isEmpty)
            XCTAssertNotNil(firstReport.type)
            XCTAssertNotNil(firstReport.createdAt)
            XCTAssertNotNil(firstReport.status)
        }
    }
    
    // MARK: - Export Tests
    
    func testGenerateHTMLReport() {
        // Given
        sut.fetchAnalytics(for: .month)
        
        // When
        let html = sut.generateHTMLReport()
        
        // Then
        XCTAssertFalse(html.isEmpty)
        XCTAssertTrue(html.contains("<html"))
        XCTAssertTrue(html.contains("</html>"))
        XCTAssertTrue(html.contains("Analytics Report"))
    }
    
    func testExportHTMLReport() async {
        // Given
        sut.fetchAnalytics(for: .month)
        
        // When
        let result = await sut.exportHTMLReport()
        
        // Then
        switch result {
        case .success(let url):
            XCTAssertTrue(FileManager.default.fileExists(atPath: url.path))
            // Clean up
            try? FileManager.default.removeItem(at: url)
        case .failure:
            XCTFail("Export should succeed")
        }
    }
    
    // MARK: - Chart Data Tests
    
    func testChartDataPoint() {
        let point = ChartDataPoint(
            x: "Monday",
            y: 85.5,
            label: "Average Score"
        )
        
        XCTAssertEqual(point.x, "Monday")
        XCTAssertEqual(point.y, 85.5)
        XCTAssertEqual(point.label, "Average Score")
    }
    
    func testUserPerformance() {
        let performance = UserPerformance(
            userId: "user123",
            userName: "John Doe",
            avatar: "person.circle",
            totalScore: 950,
            completedCourses: 10,
            averageTestScore: 87.5,
            learningHours: 120,
            rank: 1,
            badges: ["star", "trophy"],
            trend: .improving
        )
        
        XCTAssertEqual(performance.userId, "user123")
        XCTAssertEqual(performance.userName, "John Doe")
        XCTAssertEqual(performance.totalScore, 950)
        XCTAssertEqual(performance.rank, 1)
        XCTAssertEqual(performance.trend, .improving)
    }
    
    func testCourseStatistics() {
        let stats = CourseStatistics(
            courseId: "course123",
            courseName: "iOS Development",
            enrolledCount: 50,
            completedCount: 35,
            averageProgress: 0.7,
            averageScore: 85.5,
            averageTimeToComplete: 15,
            satisfactionRating: 4.5
        )
        
        XCTAssertEqual(stats.courseId, "course123")
        XCTAssertEqual(stats.courseName, "iOS Development")
        XCTAssertEqual(stats.completionRate, 0.7)
        XCTAssertEqual(stats.satisfactionRating, 4.5)
    }
    
    func testCompetencyProgress() {
        let progress = CompetencyProgress(
            competencyId: "comp123",
            competencyName: "Swift Programming",
            usersCount: 30,
            averageLevel: 3.5,
            targetLevel: 4.0,
            progressPercentage: 75
        )
        
        XCTAssertEqual(progress.competencyId, "comp123")
        XCTAssertEqual(progress.competencyName, "Swift Programming")
        XCTAssertEqual(progress.averageLevel, 3.5)
        XCTAssertEqual(progress.progressPercentage, 75)
    }
    
    // MARK: - Analytics Period Tests
    
    func testAnalyticsPeriodDisplayNames() {
        XCTAssertEqual(AnalyticsPeriod.week.displayName, "Неделя")
        XCTAssertEqual(AnalyticsPeriod.month.displayName, "Месяц")
        XCTAssertEqual(AnalyticsPeriod.year.displayName, "Год")
        XCTAssertEqual(AnalyticsPeriod.all.displayName, "Все время")
    }
    
    func testAnalyticsPeriodAllCases() {
        let periods = AnalyticsPeriod.allCases
        XCTAssertEqual(periods.count, 4)
        XCTAssertTrue(periods.contains(.week))
        XCTAssertTrue(periods.contains(.month))
        XCTAssertTrue(periods.contains(.year))
        XCTAssertTrue(periods.contains(.all))
    }
    
    // MARK: - Report Type Tests
    
    func testReportTypeDisplayNames() {
        XCTAssertEqual(ReportType.monthly.displayName, "Ежемесячный отчет")
        XCTAssertEqual(ReportType.quarterly.displayName, "Квартальный отчет")
        XCTAssertEqual(ReportType.annual.displayName, "Годовой отчет")
        XCTAssertEqual(ReportType.custom.displayName, "Пользовательский отчет")
    }
    
    func testReportTypeIcon() {
        XCTAssertEqual(ReportType.monthly.icon, "calendar")
        XCTAssertEqual(ReportType.quarterly.icon, "calendar.badge.clock")
        XCTAssertEqual(ReportType.annual.icon, "calendar.circle")
        XCTAssertEqual(ReportType.custom.icon, "doc.text")
    }
    
    // MARK: - Performance Trend Tests
    
    func testPerformanceTrendIcon() {
        XCTAssertEqual(PerformanceTrend.improving.icon, "arrow.up.circle.fill")
        XCTAssertEqual(PerformanceTrend.stable.icon, "minus.circle.fill")
        XCTAssertEqual(PerformanceTrend.declining.icon, "arrow.down.circle.fill")
    }
    
    func testPerformanceTrendColor() {
        XCTAssertEqual(PerformanceTrend.improving.color, .green)
        XCTAssertEqual(PerformanceTrend.stable.color, .blue)
        XCTAssertEqual(PerformanceTrend.declining.color, .red)
    }
} 