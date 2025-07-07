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
        sut = AnalyticsService()
        cancellables = []
    }
    
    override func tearDown() {
        cancellables = nil
        sut = nil
        super.tearDown()
    }
    
    // MARK: - Basic Tests
    
    func testServiceInitialization() {
        XCTAssertNotNil(sut)
        XCTAssertFalse(sut.analyticsData.isEmpty)
        XCTAssertFalse(sut.reports.isEmpty)
    }
    
    // MARK: - Analytics Summary Tests
    
    func testGetAnalyticsSummary() {
        // Given
        let period = AnalyticsPeriod.month
        
        // When
        let summary = sut.getAnalyticsSummary(for: period)
        
        // Then
        XCTAssertEqual(summary.period, period)
        XCTAssertGreaterThan(summary.totalUsers, 0)
        XCTAssertGreaterThan(summary.activeUsers, 0)
        XCTAssertGreaterThan(summary.completedCourses, 0)
        XCTAssertGreaterThan(summary.averageScore, 0)
        XCTAssertGreaterThan(summary.totalLearningHours, 0)
        XCTAssertFalse(summary.topPerformers.isEmpty)
        XCTAssertFalse(summary.popularCourses.isEmpty)
        XCTAssertFalse(summary.competencyProgress.isEmpty)
    }
    
    func testGetAnalyticsSummaryForDifferentPeriods() {
        // Test different periods
        let periods: [AnalyticsPeriod] = [.week, .month, .quarter, .year]
        
        for period in periods {
            let summary = sut.getAnalyticsSummary(for: period)
            XCTAssertEqual(summary.period, period)
            XCTAssertNotNil(summary.startDate)
            XCTAssertNotNil(summary.endDate)
        }
    }
    
    // MARK: - User Performance Tests
    
    func testGetUserPerformance() {
        // Given
        let userId = "user-1"
        let period = AnalyticsPeriod.month
        
        // When
        let performance = sut.getUserPerformance(userId: userId, period: period)
        
        // Then
        XCTAssertNotNil(performance)
        XCTAssertEqual(performance?.userId, userId)
        XCTAssertGreaterThan(performance?.totalScore ?? 0, 0)
        XCTAssertGreaterThan(performance?.completedCourses ?? 0, 0)
        XCTAssertGreaterThan(performance?.averageTestScore ?? 0, 0)
        XCTAssertLessThanOrEqual(performance?.averageTestScore ?? 0, 100)
    }
    
    // MARK: - Course Statistics Tests
    
    func testGetCourseStatistics() {
        // Given
        let period = AnalyticsPeriod.month
        
        // When
        let statistics = sut.getCourseStatistics(period: period)
        
        // Then
        XCTAssertFalse(statistics.isEmpty)
        
        for stat in statistics {
            XCTAssertFalse(stat.courseId.isEmpty)
            XCTAssertFalse(stat.courseName.isEmpty)
            XCTAssertGreaterThanOrEqual(stat.enrolledCount, stat.completedCount)
            XCTAssertGreaterThanOrEqual(stat.averageProgress, 0)
            XCTAssertLessThanOrEqual(stat.averageProgress, 1.0)
            XCTAssertGreaterThanOrEqual(stat.averageScore, 0)
            XCTAssertLessThanOrEqual(stat.averageScore, 100)
            XCTAssertGreaterThan(stat.averageTimeToComplete, 0)
            XCTAssertGreaterThanOrEqual(stat.satisfactionRating, 0)
            XCTAssertLessThanOrEqual(stat.satisfactionRating, 5.0)
        }
    }
    
    // MARK: - Competency Progress Tests
    
    func testGetCompetencyProgress() {
        // Given
        let period = AnalyticsPeriod.month
        
        // When
        let progress = sut.getCompetencyProgress(period: period)
        
        // Then
        XCTAssertFalse(progress.isEmpty)
        
        for comp in progress {
            XCTAssertFalse(comp.competencyId.isEmpty)
            XCTAssertFalse(comp.competencyName.isEmpty)
            XCTAssertGreaterThan(comp.usersCount, 0)
            XCTAssertGreaterThan(comp.averageLevel, 0)
            XCTAssertGreaterThan(comp.targetLevel, 0)
            XCTAssertGreaterThanOrEqual(comp.progressPercentage, 0)
            XCTAssertLessThanOrEqual(comp.progressPercentage, 100)
        }
    }
    
    // MARK: - Report Generation Tests
    
    func testGenerateReport() async {
        // Given
        let report = Report(
            title: "Test Report",
            description: "Test report description",
            type: .learningProgress,
            status: .draft,
            period: .month,
            createdBy: "user-1"
        )
        let expectation = XCTestExpectation(description: "Report generated")
        
        // When
        sut.generateReport(report)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { generatedReport in
                    // Then
                    XCTAssertEqual(generatedReport.status, .ready)
                    XCTAssertFalse(generatedReport.sections.isEmpty)
                    expectation.fulfill()
                }
            )
            .store(in: &cancellables)
        
        await fulfillment(of: [expectation], timeout: 3.0)
    }
    
    // MARK: - Track Event Tests
    
    func testTrackEvent() {
        // Given
        let initialCount = sut.analyticsData.count
        let event = AnalyticsData(
            userId: "user-1",
            timestamp: Date(),
            type: .courseProgress,
            metrics: ["progress": 0.75, "score": 85.0],
            metadata: ["courseId": "course-test"]
        )
        
        // When
        sut.trackEvent(event)
        
        // Then
        XCTAssertEqual(sut.analyticsData.count, initialCount + 1)
        XCTAssertEqual(sut.analyticsData.last?.userId, event.userId)
        XCTAssertEqual(sut.analyticsData.last?.type, event.type)
    }
    
    // MARK: - Export Report Tests
    
    func testExportReport() {
        // Given
        let report = sut.reports.first ?? Report(
            title: "Test Export",
            description: "Test",
            type: .learningProgress,
            status: .ready,
            period: .month,
            createdBy: "user-1"
        )
        
        // When
        let url = sut.exportReport(report, format: .pdf)
        
        // Then
        XCTAssertNotNil(url)
        if let url = url {
            XCTAssertTrue(url.lastPathComponent.contains(report.title))
            XCTAssertTrue(url.lastPathComponent.hasSuffix(".pdf"))
        }
    }
} 