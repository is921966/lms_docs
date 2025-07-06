//
//  AnalyticsViewModelTests.swift
//  LMSTests
//
//  Created on 09/07/2025.
//

import XCTest
import Combine
@testable import LMS

final class AnalyticsViewModelTests: XCTestCase {
    private var sut: AnalyticsViewModel!
    private var mockService: MockAnalyticsService!
    private var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        mockService = MockAnalyticsService()
        sut = AnalyticsViewModel(service: mockService)
        cancellables = Set<AnyCancellable>()
    }
    
    override func tearDown() {
        cancellables = nil
        sut = nil
        mockService = nil
        super.tearDown()
    }
    
    // MARK: - Initialization Tests
    
    func testInitialization() {
        // Check initial state
        XCTAssertEqual(sut.selectedPeriod, .month)
        XCTAssertNotNil(sut.analyticsSummary)
        XCTAssertNotNil(sut.userPerformance)
        XCTAssertFalse(sut.courseStatistics.isEmpty)
        XCTAssertFalse(sut.competencyProgress.isEmpty)
        XCTAssertFalse(sut.isLoading)
        XCTAssertNil(sut.errorMessage)
        XCTAssertNil(sut.selectedDepartment)
        XCTAssertNil(sut.selectedPosition)
        XCTAssertNil(sut.selectedCourse)
    }
    
    func testInitialDataLoad() {
        // Verify that data is loaded on init
        XCTAssertNotNil(sut.analyticsSummary)
        XCTAssertGreaterThan(sut.courseStatistics.count, 0)
        XCTAssertTrue(mockService.getAnalyticsSummaryCalled)
        XCTAssertTrue(mockService.getUserPerformanceCalled)
        XCTAssertTrue(mockService.getCourseStatisticsCalled)
        XCTAssertTrue(mockService.getCompetencyProgressCalled)
    }
    
    // MARK: - Period Tests
    
    func testChangePeriod() {
        // Reset mock service flags
        mockService.reset()
        
        // Change period
        sut.changePeriod(.week)
        
        // Verify period changed and data reloaded
        XCTAssertEqual(sut.selectedPeriod, .week)
        XCTAssertTrue(mockService.getAnalyticsSummaryCalled)
        XCTAssertTrue(mockService.getUserPerformanceCalled)
        XCTAssertTrue(mockService.getCourseStatisticsCalled)
        XCTAssertTrue(mockService.getCompetencyProgressCalled)
    }
    
    func testLoadAnalytics() {
        // Reset mock service
        mockService.reset()
        
        // Trigger load
        sut.loadAnalytics()
        
        // Verify all service methods called
        XCTAssertTrue(mockService.getAnalyticsSummaryCalled)
        XCTAssertTrue(mockService.getUserPerformanceCalled)
        XCTAssertTrue(mockService.getCourseStatisticsCalled)
        XCTAssertTrue(mockService.getCompetencyProgressCalled)
        XCTAssertFalse(sut.isLoading)
        XCTAssertNil(sut.errorMessage)
    }
    
    // MARK: - Event Tracking Tests
    
    func testTrackEvent() {
        // Track an event
        let metrics = ["score": 85.0, "time": 120.0]
        let metadata = ["courseId": "course-1", "section": "intro"]
        
        sut.trackEvent(type: .courseProgress, metrics: metrics, metadata: metadata)
        
        // Verify event was tracked
        XCTAssertTrue(mockService.trackEventCalled)
        XCTAssertEqual(mockService.lastTrackedEvent?.type, .courseProgress)
        XCTAssertEqual(mockService.lastTrackedEvent?.metrics["score"], 85.0)
        XCTAssertEqual(mockService.lastTrackedEvent?.metadata["courseId"], "course-1")
    }
    
    // MARK: - Filtering Tests
    
    func testFilteredCourseStatistics() {
        // Without filter, should return all
        XCTAssertEqual(sut.filteredCourseStatistics.count, sut.courseStatistics.count)
        
        // Apply filter
        if let firstCourse = sut.courseStatistics.first {
            sut.selectedCourse = firstCourse.courseId
            
            // Should only return matching courses
            let filtered = sut.filteredCourseStatistics
            XCTAssertTrue(filtered.allSatisfy { $0.courseId == firstCourse.courseId })
        }
    }
    
    func testTopPerformers() {
        // Should return top performers from summary
        let performers = sut.topPerformers
        
        if let summary = sut.analyticsSummary {
            XCTAssertEqual(performers.count, summary.topPerformers.count)
            XCTAssertEqual(performers.first?.userId, summary.topPerformers.first?.userId)
        }
    }
    
    func testPopularCourses() {
        // Should return popular courses from summary
        let popular = sut.popularCourses
        
        if let summary = sut.analyticsSummary {
            XCTAssertEqual(popular.count, summary.popularCourses.count)
            XCTAssertEqual(popular.first?.courseId, summary.popularCourses.first?.courseId)
        }
    }
    
    // MARK: - Chart Data Tests
    
    func testLearningProgressChartData() {
        // Test for different periods
        let periods: [AnalyticsPeriod] = [.day, .week, .month]
        
        for period in periods {
            sut.changePeriod(period)
            let data = sut.learningProgressChartData
            
            XCTAssertGreaterThan(data.count, 0)
            
            switch period {
            case .day:
                XCTAssertEqual(data.count, 24) // 24 hours
            case .week:
                XCTAssertEqual(data.count, 7) // 7 days
            case .month:
                XCTAssertEqual(data.count, 4) // 4 weeks
            default:
                break
            }
            
            // All values should be non-negative
            XCTAssertTrue(data.allSatisfy { $0.value >= 0 })
        }
    }
    
    func testCompetencyGrowthChartData() {
        let data = sut.competencyGrowthChartData
        
        // Should have data for each competency progress
        XCTAssertEqual(data.count, sut.competencyProgress.count)
        
        // Verify labels match competency names
        for (index, dataPoint) in data.enumerated() {
            XCTAssertEqual(dataPoint.label, sut.competencyProgress[index].competencyName)
            XCTAssertEqual(dataPoint.value, sut.competencyProgress[index].progressPercentage)
        }
    }
    
    func testTestScoresChartData() {
        // Test for week
        sut.changePeriod(.week)
        var data = sut.testScoresChartData
        XCTAssertEqual(data.count, 7)
        XCTAssertTrue(data.allSatisfy { $0.value >= 0 })
        
        // Test for month
        sut.changePeriod(.month)
        data = sut.testScoresChartData
        XCTAssertEqual(data.count, 4)
        XCTAssertTrue(data.allSatisfy { $0.value >= 0 })
    }
    
    // MARK: - Statistics Tests
    
    func testTotalLearningHours() {
        // Should format hours correctly
        let hours = sut.totalLearningHours
        
        if let summary = sut.analyticsSummary {
            let expected = String(format: "%.0f", summary.totalLearningHours)
            XCTAssertEqual(hours, expected)
        }
    }
    
    func testAverageScore() {
        // Should format score as percentage
        let score = sut.averageScore
        
        if let summary = sut.analyticsSummary {
            let expected = String(format: "%.1f%%", summary.averageScore)
            XCTAssertEqual(score, expected)
        }
    }
    
    func testActiveUsersPercentage() {
        let percentage = sut.activeUsersPercentage
        
        if let summary = sut.analyticsSummary {
            let expected = Double(summary.activeUsers) / Double(summary.totalUsers) * 100
            XCTAssertEqual(percentage, expected, accuracy: 0.01)
        }
    }
    
    func testCompletionRate() {
        let rate = sut.completionRate
        
        // Should be between 0 and 100
        XCTAssertGreaterThanOrEqual(rate, 0)
        XCTAssertLessThanOrEqual(rate, 100)
        
        // Manual calculation
        let totalEnrolled = sut.courseStatistics.reduce(0) { $0 + $1.enrolledCount }
        let totalCompleted = sut.courseStatistics.reduce(0) { $0 + $1.completedCount }
        
        if totalEnrolled > 0 {
            let expected = Double(totalCompleted) / Double(totalEnrolled) * 100
            XCTAssertEqual(rate, expected, accuracy: 0.01)
        } else {
            XCTAssertEqual(rate, 0)
        }
    }
    
    // MARK: - Export Tests
    
    func testExportDashboard() {
        let url = sut.exportDashboard()
        
        // Should return a valid URL
        XCTAssertNotNil(url)
        
        if let url = url {
            // File should exist
            XCTAssertTrue(FileManager.default.fileExists(atPath: url.path))
            
            // Should be HTML file
            XCTAssertTrue(url.pathExtension == "html")
            
            // Read content
            if let content = try? String(contentsOf: url) {
                // Should contain basic HTML structure
                XCTAssertTrue(content.contains("<html>"))
                XCTAssertTrue(content.contains("</html>"))
                XCTAssertTrue(content.contains(sut.selectedPeriod.rawValue))
                
                // Should contain metrics
                if let summary = sut.analyticsSummary {
                    XCTAssertTrue(content.contains("\(summary.activeUsers)"))
                    XCTAssertTrue(content.contains("\(summary.completedCourses)"))
                }
            }
            
            // Cleanup
            try? FileManager.default.removeItem(at: url)
        }
    }
}

// MARK: - Mock Analytics Service

class MockAnalyticsService: AnalyticsServiceProtocol {
    var getAnalyticsSummaryCalled = false
    var getUserPerformanceCalled = false
    var getCourseStatisticsCalled = false
    var getCompetencyProgressCalled = false
    var trackEventCalled = false
    
    var lastTrackedEvent: AnalyticsData?
    
    func reset() {
        getAnalyticsSummaryCalled = false
        getUserPerformanceCalled = false
        getCourseStatisticsCalled = false
        getCompetencyProgressCalled = false
        trackEventCalled = false
        lastTrackedEvent = nil
    }
    
    func getAnalyticsSummary(for period: AnalyticsPeriod) -> AnalyticsSummary {
        getAnalyticsSummaryCalled = true
        
        return AnalyticsSummary(
            period: period,
            startDate: Date().addingTimeInterval(-Double(period.days) * 24 * 3600),
            endDate: Date(),
            totalUsers: 100,
            activeUsers: 75,
            completedCourses: 150,
            averageScore: 82.3,
            totalLearningHours: 1250.5,
            topPerformers: [
                UserPerformance(
                    userId: "user-1",
                    userName: "Test User 1",
                    avatar: nil,
                    totalScore: 950,
                    completedCourses: 8,
                    averageTestScore: 92.5,
                    learningHours: 120,
                    rank: 1,
                    badges: ["star", "trophy", "crown"],
                    trend: .improving
                )
            ],
            popularCourses: [
                CourseStatistics(
                    courseId: "course-1",
                    courseName: "Test Course",
                    enrolledCount: 50,
                    completedCount: 30,
                    averageProgress: 0.6,
                    averageScore: 85.0,
                    averageTimeToComplete: 10.5,
                    satisfactionRating: 4.5
                )
            ],
            competencyProgress: [
                CompetencyProgress(
                    competencyId: "comp-1",
                    competencyName: "iOS Development",
                    usersCount: 50,
                    averageLevel: 3.5,
                    targetLevel: 4.0,
                    progressPercentage: 87.5
                )
            ]
        )
    }
    
    func getUserPerformance(userId: String, period: AnalyticsPeriod) -> UserPerformance? {
        getUserPerformanceCalled = true
        
        return UserPerformance(
            userId: userId,
            userName: "Current User",
            avatar: nil,
            totalScore: 850,
            completedCourses: 5,
            averageTestScore: 87.5,
            learningHours: 80,
            rank: 3,
            badges: ["star"],
            trend: .stable
        )
    }
    
    func getCourseStatistics(period: AnalyticsPeriod) -> [CourseStatistics] {
        getCourseStatisticsCalled = true
        
        return [
            CourseStatistics(
                courseId: "course-1",
                courseName: "iOS Development",
                enrolledCount: 50,
                completedCount: 30,
                averageProgress: 0.6,
                averageScore: 85.0,
                averageTimeToComplete: 10.5,
                satisfactionRating: 4.5
            ),
            CourseStatistics(
                courseId: "course-2",
                courseName: "Swift Basics",
                enrolledCount: 80,
                completedCount: 60,
                averageProgress: 0.75,
                averageScore: 90.0,
                averageTimeToComplete: 5.0,
                satisfactionRating: 4.7
            )
        ]
    }
    
    func getCompetencyProgress(period: AnalyticsPeriod) -> [CompetencyProgress] {
        getCompetencyProgressCalled = true
        
        return [
            CompetencyProgress(
                competencyId: "comp-1",
                competencyName: "iOS Development",
                usersCount: 50,
                averageLevel: 3.5,
                targetLevel: 4.0,
                progressPercentage: 87.5
            ),
            CompetencyProgress(
                competencyId: "comp-2",
                competencyName: "Team Work",
                usersCount: 40,
                averageLevel: 3.0,
                targetLevel: 4.0,
                progressPercentage: 75.0
            )
        ]
    }
    
    func trackEvent(_ event: AnalyticsData) {
        trackEventCalled = true
        lastTrackedEvent = event
    }
    
    // Missing protocol methods
    func generateReport(_ report: Report) -> AnyPublisher<Report, Error> {
        Future<Report, Error> { promise in
            promise(.success(report))
        }.eraseToAnyPublisher()
    }
    
    func getReports(for userId: String) -> [Report] {
        []
    }
    
    func exportReport(_ report: Report, format: ReportFormat) -> URL? {
        nil
    }
} 