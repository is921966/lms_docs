import XCTest
import Combine
@testable import LMS

final class AnalyticsServiceExtendedTests: XCTestCase {
    
    // MARK: - Properties
    var sut: AnalyticsService!
    var cancellables: Set<AnyCancellable>!
    
    // MARK: - Setup
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
    
    // MARK: - Initialization Tests
    
    func testAnalyticsServiceInitialization() {
        // Then
        XCTAssertNotNil(sut, "AnalyticsService should be initialized")
        XCTAssertFalse(sut.analyticsData.isEmpty, "Should have mock analytics data")
        XCTAssertFalse(sut.reports.isEmpty, "Should have mock reports")
    }
    
    func testAnalyticsDataLoadedOnInit() {
        // Then
        XCTAssertGreaterThan(sut.analyticsData.count, 0, "Should have analytics data")
        
        // Verify data types
        let courseProgressCount = sut.analyticsData.filter { $0.type == .courseProgress }.count
        let testResultCount = sut.analyticsData.filter { $0.type == .testResult }.count
        
        XCTAssertGreaterThan(courseProgressCount, 0, "Should have course progress events")
        XCTAssertGreaterThan(testResultCount, 0, "Should have test result events")
    }
    
    func testReportsLoadedOnInit() {
        // Then
        XCTAssertEqual(sut.reports.count, 3, "Should have 3 mock reports")
        
        // Verify report types
        let learningProgressReports = sut.reports.filter { $0.type == .learningProgress }
        let competencyMatrixReports = sut.reports.filter { $0.type == .competencyMatrix }
        let roiReports = sut.reports.filter { $0.type == .roi }
        
        XCTAssertEqual(learningProgressReports.count, 1)
        XCTAssertEqual(competencyMatrixReports.count, 1)
        XCTAssertEqual(roiReports.count, 1)
    }
    
    // MARK: - Track Event Tests
    
    func testTrackEvent() {
        // Given
        let initialCount = sut.analyticsData.count
        let newEvent = AnalyticsData(
            userId: "test-user",
            timestamp: Date(),
            type: .courseProgress,
            metrics: ["progress": 0.8, "score": 85.0],
            metadata: ["courseId": "test-course"]
        )
        
        // When
        sut.trackEvent(newEvent)
        
        // Then
        XCTAssertEqual(sut.analyticsData.count, initialCount + 1)
        XCTAssertEqual(sut.analyticsData.last?.userId, "test-user")
        XCTAssertEqual(sut.analyticsData.last?.type, .courseProgress)
        XCTAssertEqual(sut.analyticsData.last?.metrics["progress"], 0.8)
    }
    
    func testTrackMultipleEvents() {
        // Given
        let initialCount = sut.analyticsData.count
        let events = [
            AnalyticsData(
                userId: "user-1",
                timestamp: Date(),
                type: .courseProgress,
                metrics: ["progress": 0.5],
                metadata: ["courseId": "course-1"]
            ),
            AnalyticsData(
                userId: "user-2",
                timestamp: Date(),
                type: .testResult,
                metrics: ["score": 90.0],
                metadata: ["testId": "test-1"]
            ),
            AnalyticsData(
                userId: "user-3",
                timestamp: Date(),
                type: .courseProgress,
                metrics: ["progress": 1.0],
                metadata: ["courseId": "course-2"]
            )
        ]
        
        // When
        events.forEach { sut.trackEvent($0) }
        
        // Then
        XCTAssertEqual(sut.analyticsData.count, initialCount + 3)
    }
    
    // MARK: - Analytics Summary Tests
    
    func testGetAnalyticsSummaryForWeek() {
        // When
        let summary = sut.getAnalyticsSummary(for: .week)
        
        // Then
        XCTAssertEqual(summary.period, .week)
        XCTAssertEqual(summary.totalUsers, 350)
        XCTAssertEqual(summary.activeUsers, 280)
        XCTAssertEqual(summary.completedCourses, 420)
        XCTAssertEqual(summary.averageScore, 86.5)
        XCTAssertEqual(summary.totalLearningHours, 5_250.0)
        
        // Verify dates
        let daysDifference = Calendar.current.dateComponents([.day], from: summary.startDate, to: summary.endDate).day
        XCTAssertEqual(daysDifference, 7, "Week period should be 7 days")
    }
    
    func testGetAnalyticsSummaryForMonth() {
        // When
        let summary = sut.getAnalyticsSummary(for: .month)
        
        // Then
        XCTAssertEqual(summary.period, .month)
        
        // Verify dates
        let daysDifference = Calendar.current.dateComponents([.day], from: summary.startDate, to: summary.endDate).day
        XCTAssertEqual(daysDifference, 30, "Month period should be 30 days")
    }
    
    func testGetAnalyticsSummaryForQuarter() {
        // When
        let summary = sut.getAnalyticsSummary(for: .quarter)
        
        // Then
        XCTAssertEqual(summary.period, .quarter)
        
        // Verify dates
        let daysDifference = Calendar.current.dateComponents([.day], from: summary.startDate, to: summary.endDate).day
        XCTAssertEqual(daysDifference, 90, "Quarter period should be 90 days")
    }
    
    func testGetAnalyticsSummaryTopPerformers() {
        // When
        let summary = sut.getAnalyticsSummary(for: .week)
        
        // Then
        XCTAssertEqual(summary.topPerformers.count, 3)
        
        // Verify first performer
        let topPerformer = summary.topPerformers[0]
        XCTAssertEqual(topPerformer.userId, "user-1")
        XCTAssertEqual(topPerformer.userName, "Иван Иванов")
        XCTAssertEqual(topPerformer.totalScore, 950)
        XCTAssertEqual(topPerformer.rank, 1)
        XCTAssertEqual(topPerformer.badges.count, 3)
        XCTAssertEqual(topPerformer.trend, .improving)
        
        // Verify ordering
        XCTAssertGreaterThan(summary.topPerformers[0].totalScore, summary.topPerformers[1].totalScore)
        XCTAssertGreaterThan(summary.topPerformers[1].totalScore, summary.topPerformers[2].totalScore)
    }
    
    func testGetAnalyticsSummaryPopularCourses() {
        // When
        let summary = sut.getAnalyticsSummary(for: .month)
        
        // Then
        XCTAssertEqual(summary.popularCourses.count, 3)
        
        // Verify first course
        let topCourse = summary.popularCourses[0]
        XCTAssertEqual(topCourse.courseId, "course-1")
        XCTAssertEqual(topCourse.courseName, "Основы продаж")
        XCTAssertEqual(topCourse.enrolledCount, 250)
        XCTAssertEqual(topCourse.completedCount, 180)
        XCTAssertEqual(topCourse.averageProgress, 0.72)
        XCTAssertEqual(topCourse.satisfactionRating, 4.5)
    }
    
    func testGetAnalyticsSummaryCompetencyProgress() {
        // When
        let summary = sut.getAnalyticsSummary(for: .all)
        
        // Then
        XCTAssertEqual(summary.competencyProgress.count, 3)
        
        // Verify competencies
        let communication = summary.competencyProgress.first { $0.competencyName == "Коммуникация" }
        XCTAssertNotNil(communication)
        XCTAssertEqual(communication?.progressPercentage, 95.0)
        XCTAssertEqual(communication?.averageLevel, 3.8)
        XCTAssertEqual(communication?.targetLevel, 4.0)
    }
    
    // MARK: - User Performance Tests
    
    func testGetUserPerformance() {
        // Given
        let userId = "test-user-123"
        
        // When
        let performance = sut.getUserPerformance(userId: userId, period: .month)
        
        // Then
        XCTAssertNotNil(performance)
        XCTAssertEqual(performance?.userId, userId)
        XCTAssertEqual(performance?.userName, "Иван Иванов")
        XCTAssertEqual(performance?.totalScore, 950)
        XCTAssertEqual(performance?.completedCourses, 12)
        XCTAssertEqual(performance?.averageTestScore, 92.5)
        XCTAssertEqual(performance?.learningHours, 48.5)
        XCTAssertEqual(performance?.rank, 1)
        XCTAssertEqual(performance?.badges, ["star", "trophy", "crown"])
        XCTAssertEqual(performance?.trend, .improving)
    }
    
    func testGetUserPerformanceForDifferentPeriods() {
        // Given
        let userId = "user-456"
        let periods: [AnalyticsPeriod] = [.week, .month, .quarter, .year, .all]
        
        // When/Then
        for period in periods {
            let performance = sut.getUserPerformance(userId: userId, period: period)
            XCTAssertNotNil(performance, "Should return performance for \(period)")
            XCTAssertEqual(performance?.userId, userId)
        }
    }
    
    // MARK: - Course Statistics Tests
    
    func testGetCourseStatistics() {
        // When
        let statistics = sut.getCourseStatistics(period: .month)
        
        // Then
        XCTAssertEqual(statistics.count, 4)
        
        // Verify first course
        let firstCourse = statistics[0]
        XCTAssertEqual(firstCourse.courseId, "course-1")
        XCTAssertEqual(firstCourse.courseName, "Основы продаж")
        XCTAssertEqual(firstCourse.enrolledCount, 250)
        XCTAssertEqual(firstCourse.completedCount, 180)
        XCTAssertEqual(firstCourse.averageProgress, 0.72)
        XCTAssertEqual(firstCourse.averageScore, 85.5)
        XCTAssertEqual(firstCourse.averageTimeToComplete, 12.5)
        XCTAssertEqual(firstCourse.satisfactionRating, 4.5)
    }
    
    func testGetCourseStatisticsProperties() {
        // When
        let statistics = sut.getCourseStatistics(period: .week)
        
        // Then
        for stat in statistics {
            XCTAssertFalse(stat.courseId.isEmpty)
            XCTAssertFalse(stat.courseName.isEmpty)
            XCTAssertGreaterThanOrEqual(stat.enrolledCount, 0)
            XCTAssertGreaterThanOrEqual(stat.completedCount, 0)
            XCTAssertLessThanOrEqual(stat.completedCount, stat.enrolledCount)
            XCTAssertGreaterThanOrEqual(stat.averageProgress, 0.0)
            XCTAssertLessThanOrEqual(stat.averageProgress, 1.0)
            XCTAssertGreaterThanOrEqual(stat.averageScore, 0.0)
            XCTAssertLessThanOrEqual(stat.averageScore, 100.0)
            XCTAssertGreaterThan(stat.averageTimeToComplete, 0.0)
            XCTAssertGreaterThanOrEqual(stat.satisfactionRating, 0.0)
            XCTAssertLessThanOrEqual(stat.satisfactionRating, 5.0)
        }
    }
    
    // MARK: - Competency Progress Tests
    
    func testGetCompetencyProgress() {
        // When
        let progress = sut.getCompetencyProgress(period: .quarter)
        
        // Then
        XCTAssertEqual(progress.count, 4)
        
        // Verify competencies
        let salesCompetency = progress.first { $0.competencyName == "Продажи" }
        XCTAssertNotNil(salesCompetency)
        XCTAssertEqual(salesCompetency?.usersCount, 250)
        XCTAssertEqual(salesCompetency?.averageLevel, 3.5)
        XCTAssertEqual(salesCompetency?.targetLevel, 4.0)
        XCTAssertEqual(salesCompetency?.progressPercentage, 87.5)
    }
    
    func testCompetencyProgressValidation() {
        // When
        let progress = sut.getCompetencyProgress(period: .year)
        
        // Then
        for competency in progress {
            XCTAssertFalse(competency.competencyId.isEmpty)
            XCTAssertFalse(competency.competencyName.isEmpty)
            XCTAssertGreaterThan(competency.usersCount, 0)
            XCTAssertGreaterThan(competency.averageLevel, 0.0)
            XCTAssertGreaterThan(competency.targetLevel, 0.0)
            XCTAssertGreaterThanOrEqual(competency.progressPercentage, 0.0)
            XCTAssertLessThanOrEqual(competency.progressPercentage, 100.0)
            
            // Progress percentage should match the calculation
            let expectedProgress = (competency.averageLevel / competency.targetLevel) * 100
            XCTAssertEqual(competency.progressPercentage, expectedProgress, accuracy: 0.1)
        }
    }
    
    // MARK: - Report Generation Tests
    
    func testGenerateReport() {
        // Given
        let expectation = XCTestExpectation(description: "Report generation")
        let newReport = Report(
            title: "Test Report",
            description: "Test description",
            type: .learningProgress,
            status: .generating,
            period: .month,
            createdBy: "test-user"
        )
        
        // When
        sut.generateReport(newReport)
            .sink(
                receiveCompletion: { completion in
                    if case .failure = completion {
                        XCTFail("Should not fail")
                    }
                },
                receiveValue: { generatedReport in
                    // Then
                    XCTAssertEqual(generatedReport.title, "Test Report")
                    XCTAssertEqual(generatedReport.status, .ready)
                    XCTAssertNotNil(generatedReport.updatedAt)
                    XCTAssertFalse(generatedReport.sections.isEmpty)
                    expectation.fulfill()
                }
            )
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 3.0)
    }
    
    func testGenerateReportSections() {
        // Given
        let expectation = XCTestExpectation(description: "Report sections generation")
        let learningReport = Report(
            title: "Learning Progress Report",
            description: "Test",
            type: .learningProgress,
            status: .generating,
            period: .week,
            createdBy: "user-1"
        )
        
        // When
        sut.generateReport(learningReport)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { report in
                    // Then
                    XCTAssertEqual(report.sections.count, 2)
                    
                    // Verify metrics section
                    let metricsSection = report.sections.first { $0.type == .metrics }
                    XCTAssertNotNil(metricsSection)
                    XCTAssertEqual(metricsSection?.title, "Общая статистика")
                    
                    // Verify chart section
                    let chartSection = report.sections.first { $0.type == .chart }
                    XCTAssertNotNil(chartSection)
                    XCTAssertEqual(chartSection?.title, "Прогресс по месяцам")
                    
                    expectation.fulfill()
                }
            )
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 3.0)
    }
    
    func testGenerateCompetencyMatrixReport() {
        // Given
        let expectation = XCTestExpectation(description: "Competency matrix report")
        let competencyReport = Report(
            title: "Competency Matrix",
            description: "Test",
            type: .competencyMatrix,
            status: .generating,
            period: .all,
            createdBy: "user-1"
        )
        
        // When
        sut.generateReport(competencyReport)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { report in
                    // Then
                    XCTAssertEqual(report.sections.count, 2)
                    
                    // Verify summary section
                    let summarySection = report.sections.first { $0.type == .summary }
                    XCTAssertNotNil(summarySection)
                    
                    // Verify table section
                    let tableSection = report.sections.first { $0.type == .table }
                    XCTAssertNotNil(tableSection)
                    
                    expectation.fulfill()
                }
            )
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 3.0)
    }
    
    // MARK: - Get Reports Tests
    
    func testGetReportsForUser() {
        // Given
        let userId = "user-1"
        
        // When
        let userReports = sut.getReports(for: userId)
        
        // Then
        XCTAssertGreaterThan(userReports.count, 0)
        
        // All reports should be created by or include the user
        for report in userReports {
            let isCreator = report.createdBy == userId
            let isRecipient = report.recipients.contains(userId)
            XCTAssertTrue(isCreator || isRecipient, "User should be creator or recipient")
        }
    }
    
    func testGetReportsForNonExistentUser() {
        // Given
        let userId = "non-existent-user"
        
        // When
        let userReports = sut.getReports(for: userId)
        
        // Then
        XCTAssertEqual(userReports.count, 0, "Non-existent user should have no reports")
    }
    
    // MARK: - Export Report Tests
    
    func testExportReportAsPDF() {
        // Given
        let report = sut.reports[0]
        
        // When
        let exportURL = sut.exportReport(report, format: .pdf)
        
        // Then
        XCTAssertNotNil(exportURL)
        XCTAssertTrue(exportURL!.path.contains(".pdf"))
        XCTAssertTrue(FileManager.default.fileExists(atPath: exportURL!.path))
        
        // Cleanup
        try? FileManager.default.removeItem(at: exportURL!)
    }
    
    func testExportReportAsExcel() {
        // Given
        let report = sut.reports[0]
        
        // When
        let exportURL = sut.exportReport(report, format: .excel)
        
        // Then
        XCTAssertNotNil(exportURL)
        XCTAssertTrue(exportURL!.path.contains(".excel"))
        
        // Cleanup
        try? FileManager.default.removeItem(at: exportURL!)
    }
    
    func testExportReportAsCSV() {
        // Given
        let report = sut.reports[0]
        
        // When
        let exportURL = sut.exportReport(report, format: .csv)
        
        // Then
        XCTAssertNotNil(exportURL)
        XCTAssertTrue(exportURL!.path.contains(".csv"))
        
        // Cleanup
        try? FileManager.default.removeItem(at: exportURL!)
    }
    
    // MARK: - Performance Tests
    
    func testAnalyticsSummaryPerformance() {
        measure {
            _ = sut.getAnalyticsSummary(for: .month)
        }
    }
    
    func testReportGenerationPerformance() {
        let report = Report(
            title: "Performance Test Report",
            description: "Test",
            type: .learningProgress,
            status: .generating,
            period: .week,
            createdBy: "user-1"
        )
        
        measure {
            let expectation = XCTestExpectation(description: "Performance test")
            
            sut.generateReport(report)
                .sink(
                    receiveCompletion: { _ in },
                    receiveValue: { _ in
                        expectation.fulfill()
                    }
                )
                .store(in: &cancellables)
            
            wait(for: [expectation], timeout: 3.0)
        }
    }
}

// MARK: - Analytics Data Tests
extension AnalyticsServiceExtendedTests {
    
    func testAnalyticsDataProperties() {
        // Given
        let data = sut.analyticsData
        
        // Then
        for event in data {
            XCTAssertFalse(event.userId.isEmpty, "User ID should not be empty")
            XCTAssertNotNil(event.timestamp, "Timestamp should not be nil")
            XCTAssertFalse(event.metrics.isEmpty, "Metrics should not be empty")
            
            // Verify metric values are reasonable
            for (_, value) in event.metrics {
                XCTAssertGreaterThanOrEqual(value, 0.0, "Metric values should be non-negative")
            }
        }
    }
    
    func testAnalyticsDataTypes() {
        // Given
        let data = sut.analyticsData
        
        // Then
        let types = Set(data.map { $0.type })
        XCTAssertTrue(types.contains(.courseProgress))
        XCTAssertTrue(types.contains(.testResult))
    }
} 