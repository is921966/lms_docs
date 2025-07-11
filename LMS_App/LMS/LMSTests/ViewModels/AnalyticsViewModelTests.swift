//
//  AnalyticsViewModelTests.swift
//  LMSTests
//
//  Created on 06/07/2025.
//

import XCTest
import Combine
@testable import LMS

// Mock Analytics Service
class MockAnalyticsService: AnalyticsServiceProtocol {
    var mockSummary: AnalyticsSummary?
    var mockUserPerformance: UserPerformance?
    var mockCourseStatistics: [CourseStatistics] = []
    var mockCompetencyProgress: [CompetencyProgress] = []
    var trackedEvents: [AnalyticsData] = []
    
    func getAnalyticsSummary(for period: AnalyticsPeriod) -> AnalyticsSummary {
        return mockSummary ?? AnalyticsSummary(
            period: period,
            startDate: Date().addingTimeInterval(-Double(period.days) * 24 * 60 * 60),
            endDate: Date(),
            totalUsers: 100,
            activeUsers: 75,
            completedCourses: 150,
            averageScore: 85.5,
            totalLearningHours: 1200,
            topPerformers: [],
            popularCourses: [],
            competencyProgress: []
        )
    }
    
    func getUserPerformance(userId: String, period: AnalyticsPeriod) -> UserPerformance? {
        return UserPerformance(
            userId: userId,
            userName: "Test User \(userId)",
            avatar: "person.circle.fill",
            totalScore: 950,
            completedCourses: 12,
            averageTestScore: 87.5,
            learningHours: 120,
            rank: 1,
            badges: ["star", "trophy", "checkmark.seal"],
            trend: .improving
        )
    }
    
    func getCourseStatistics(period: AnalyticsPeriod) -> [CourseStatistics] {
        return mockCourseStatistics.isEmpty ? [
            CourseStatistics(
                courseId: "course1",
                courseName: "iOS Development",
                enrolledCount: 50,
                completedCount: 35,
                averageProgress: 0.7,
                averageScore: 87.5,
                averageTimeToComplete: 15,
                satisfactionRating: 4.5
            )
        ] : mockCourseStatistics
    }
    
    func getCompetencyProgress(period: AnalyticsPeriod) -> [CompetencyProgress] {
        return mockCompetencyProgress.isEmpty ? [
            CompetencyProgress(
                competencyId: "comp1",
                competencyName: "Swift",
                usersCount: 30,
                averageLevel: 3.5,
                targetLevel: 4.0,
                progressPercentage: 75
            )
        ] : mockCompetencyProgress
    }
    
    func trackEvent(_ data: AnalyticsData) {
        trackedEvents.append(data)
    }
    
    func generateReport(_ report: Report) -> AnyPublisher<Report, Error> {
        return Just(report)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    func getReports(for userId: String) -> [Report] {
        return []
    }
    
    func exportReport(_ report: Report, format: ReportFormat) -> URL? {
        return URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("test_report.pdf")
    }
}

final class AnalyticsViewModelTests: XCTestCase {
    
    var viewModel: AnalyticsViewModel!
    var mockService: MockAnalyticsService!
    var cancellables: Set<AnyCancellable> = []
    
    override func setUp() {
        super.setUp()
        mockService = MockAnalyticsService()
        viewModel = AnalyticsViewModel(service: mockService)
        cancellables = []
    }
    
    override func tearDown() {
        viewModel = nil
        mockService = nil
        cancellables.removeAll()
        super.tearDown()
    }
    
    // MARK: - Initialization Tests
    
    func testInitialState() {
        XCTAssertEqual(viewModel.selectedPeriod, .month)
        XCTAssertNotNil(viewModel.analyticsSummary)
        XCTAssertNotNil(viewModel.userPerformance)
        XCTAssertFalse(viewModel.courseStatistics.isEmpty)
        XCTAssertFalse(viewModel.competencyProgress.isEmpty)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertNil(viewModel.selectedDepartment)
        XCTAssertNil(viewModel.selectedPosition)
        XCTAssertNil(viewModel.selectedCourse)
    }
    
    func testLoadAnalyticsOnInit() {
        // Given - mock service with custom data
        let customSummary = AnalyticsSummary(
            period: .month,
            startDate: Date().addingTimeInterval(-30 * 24 * 60 * 60),
            endDate: Date(),
            totalUsers: 200,
            activeUsers: 150,
            completedCourses: 300,
            averageScore: 90.0,
            totalLearningHours: 2400,
            topPerformers: [],
            popularCourses: [],
            competencyProgress: []
        )
        mockService.mockSummary = customSummary
        
        // When - create new view model
        let vm = AnalyticsViewModel(service: mockService)
        
        // Then
        XCTAssertEqual(vm.analyticsSummary?.totalUsers, 200)
        XCTAssertEqual(vm.analyticsSummary?.activeUsers, 150)
    }
    
    // MARK: - Period Change Tests
    
    func testChangePeriod() {
        // When
        viewModel.changePeriod(.week)
        
        // Then
        XCTAssertEqual(viewModel.selectedPeriod, .week)
        XCTAssertNotNil(viewModel.analyticsSummary)
    }
    
    func testChangePeriodReloadsData() {
        // Given
        let expectation = XCTestExpectation(description: "Data reloaded")
        var loadCount = 0
        
        viewModel.$analyticsSummary
            .sink { _ in
                loadCount += 1
                if loadCount > 1 {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        // When
        viewModel.changePeriod(.day)
        
        // Then
        wait(for: [expectation], timeout: 1)
        XCTAssertEqual(viewModel.selectedPeriod, .day)
    }
    
    // MARK: - Event Tracking Tests
    
    func testTrackEvent() {
        // Given
        let metrics = ["score": 95.0, "duration": 120.0]
        let metadata = ["courseId": "course1", "module": "module3"]
        
        // When
        viewModel.trackEvent(type: .testResult, metrics: metrics, metadata: metadata)
        
        // Then
        XCTAssertEqual(mockService.trackedEvents.count, 1)
        XCTAssertEqual(mockService.trackedEvents.first?.type, .testResult)
        XCTAssertEqual(mockService.trackedEvents.first?.metrics["score"], 95.0)
        XCTAssertEqual(mockService.trackedEvents.first?.metadata["courseId"], "course1")
    }
    
    func testTrackMultipleEvents() {
        // When
        viewModel.trackEvent(type: .courseProgress, metrics: [:])
        viewModel.trackEvent(type: .testResult, metrics: ["score": 85.0])
        viewModel.trackEvent(type: .achievement, metrics: ["progress": 100.0])
        
        // Then
        XCTAssertEqual(mockService.trackedEvents.count, 3)
        XCTAssertEqual(mockService.trackedEvents[0].type, .courseProgress)
        XCTAssertEqual(mockService.trackedEvents[1].type, .testResult)
        XCTAssertEqual(mockService.trackedEvents[2].type, .achievement)
    }
    
    // MARK: - Filtered Data Tests
    
    func testFilteredCourseStatistics() {
        // Given
        mockService.mockCourseStatistics = [
            CourseStatistics(
                courseId: "course1",
                courseName: "Course 1",
                enrolledCount: 10,
                completedCount: 5,
                averageProgress: 0.5,
                averageScore: 80,
                averageTimeToComplete: 10,
                satisfactionRating: 4.0
            ),
            CourseStatistics(
                courseId: "course2",
                courseName: "Course 2",
                enrolledCount: 20,
                completedCount: 15,
                averageProgress: 0.75,
                averageScore: 85,
                averageTimeToComplete: 12,
                satisfactionRating: 4.5
            )
        ]
        viewModel.loadAnalytics()
        
        // When - no filter
        XCTAssertEqual(viewModel.filteredCourseStatistics.count, 2)
        
        // When - filter by course
        viewModel.selectedCourse = "course1"
        
        // Then
        XCTAssertEqual(viewModel.filteredCourseStatistics.count, 1)
        XCTAssertEqual(viewModel.filteredCourseStatistics.first?.courseId, "course1")
    }
    
    func testTopPerformers() {
        // Given
        let performers = [
            UserPerformance(
                userId: "user1",
                userName: "User 1",
                avatar: "person.circle.fill",
                totalScore: 1000,
                completedCourses: 15,
                averageTestScore: 90.0,
                learningHours: 150,
                rank: 1,
                badges: ["star", "trophy"],
                trend: .improving
            )
        ]
        mockService.mockSummary = AnalyticsSummary(
            period: .month,
            startDate: Date().addingTimeInterval(-30 * 24 * 60 * 60),
            endDate: Date(),
            totalUsers: 100,
            activeUsers: 75,
            completedCourses: 150,
            averageScore: 85.5,
            totalLearningHours: 1200,
            topPerformers: performers,
            popularCourses: [],
            competencyProgress: []
        )
        viewModel.loadAnalytics()
        
        // Then
        XCTAssertEqual(viewModel.topPerformers.count, 1)
        XCTAssertEqual(viewModel.topPerformers.first?.userName, "User 1")
    }
    
    func testPopularCourses() {
        // Given
        let courses = [
            CourseStatistics(
                courseId: "popular1",
                courseName: "Popular Course",
                enrolledCount: 100,
                completedCount: 80,
                averageProgress: 0.8,
                averageScore: 90,
                averageTimeToComplete: 10,
                satisfactionRating: 4.8
            )
        ]
        mockService.mockSummary = AnalyticsSummary(
            period: .month,
            startDate: Date().addingTimeInterval(-30 * 24 * 60 * 60),
            endDate: Date(),
            totalUsers: 100,
            activeUsers: 75,
            completedCourses: 150,
            averageScore: 85.5,
            totalLearningHours: 1200,
            topPerformers: [],
            popularCourses: courses,
            competencyProgress: []
        )
        viewModel.loadAnalytics()
        
        // Then
        XCTAssertEqual(viewModel.popularCourses.count, 1)
        XCTAssertEqual(viewModel.popularCourses.first?.courseName, "Popular Course")
    }
    
    // MARK: - Chart Data Tests
    
    func testLearningProgressChartData() {
        // When - Day period
        viewModel.selectedPeriod = .day
        let dayData = viewModel.learningProgressChartData
        
        // Then
        XCTAssertEqual(dayData.count, 24) // 24 hours
        XCTAssertTrue(dayData.allSatisfy { $0.value >= 0 && $0.value <= 20 })
        
        // When - Week period
        viewModel.selectedPeriod = .week
        let weekData = viewModel.learningProgressChartData
        
        // Then
        XCTAssertEqual(weekData.count, 7) // 7 days
        XCTAssertTrue(weekData.allSatisfy { $0.value >= 40 && $0.value <= 100 })
        
        // When - Month period
        viewModel.selectedPeriod = .month
        let monthData = viewModel.learningProgressChartData
        
        // Then
        XCTAssertEqual(monthData.count, 4) // 4 weeks
        XCTAssertTrue(monthData.allSatisfy { $0.value >= 80 && $0.value <= 120 })
    }
    
    func testCompetencyGrowthChartData() {
        // Given
        mockService.mockCompetencyProgress = [
            CompetencyProgress(
                competencyId: "comp1",
                competencyName: "Swift",
                usersCount: 30,
                averageLevel: 3.5,
                targetLevel: 4.0,
                progressPercentage: 75
            ),
            CompetencyProgress(
                competencyId: "comp2",
                competencyName: "UIKit",
                usersCount: 25,
                averageLevel: 3.2,
                targetLevel: 4.0,
                progressPercentage: 65
            )
        ]
        viewModel.loadAnalytics()
        
        // When
        let chartData = viewModel.competencyGrowthChartData
        
        // Then
        XCTAssertEqual(chartData.count, 2)
        XCTAssertEqual(chartData[0].label, "Swift")
        XCTAssertEqual(chartData[0].value, 75)
        XCTAssertEqual(chartData[1].label, "UIKit")
        XCTAssertEqual(chartData[1].value, 65)
    }
    
    func testTestScoresChartData() {
        // When - Week period
        viewModel.selectedPeriod = .week
        let weekData = viewModel.testScoresChartData
        
        // Then
        XCTAssertEqual(weekData.count, 7)
        XCTAssertTrue(weekData.allSatisfy { $0.value >= 70 && $0.value <= 95 })
        
        // When - Month period
        viewModel.selectedPeriod = .month
        let monthData = viewModel.testScoresChartData
        
        // Then
        XCTAssertEqual(monthData.count, 4)
        XCTAssertTrue(monthData.allSatisfy { $0.value >= 75 && $0.value <= 92 })
    }
    
    // MARK: - Statistics Tests
    
    func testTotalLearningHours() {
        // Given
        mockService.mockSummary = AnalyticsSummary(
            period: .month,
            startDate: Date().addingTimeInterval(-30 * 24 * 60 * 60),
            endDate: Date(),
            totalUsers: 100,
            activeUsers: 75,
            completedCourses: 150,
            averageScore: 85.5,
            totalLearningHours: 1234.5,
            topPerformers: [],
            popularCourses: [],
            competencyProgress: []
        )
        viewModel.loadAnalytics()
        
        // Then
        XCTAssertEqual(viewModel.totalLearningHours, "1234")
    }
    
    func testAverageScore() {
        // Given
        mockService.mockSummary = AnalyticsSummary(
            period: .month,
            startDate: Date().addingTimeInterval(-30 * 24 * 60 * 60),
            endDate: Date(),
            totalUsers: 100,
            activeUsers: 75,
            completedCourses: 150,
            averageScore: 87.35,
            totalLearningHours: 1200,
            topPerformers: [],
            popularCourses: [],
            competencyProgress: []
        )
        viewModel.loadAnalytics()
        
        // Then
        XCTAssertEqual(viewModel.averageScore, "87.4%")
    }
    
    func testActiveUsersPercentage() {
        // Given
        mockService.mockSummary = AnalyticsSummary(
            period: .month,
            startDate: Date().addingTimeInterval(-30 * 24 * 60 * 60),
            endDate: Date(),
            totalUsers: 200,
            activeUsers: 150,
            completedCourses: 150,
            averageScore: 85.5,
            totalLearningHours: 1200,
            topPerformers: [],
            popularCourses: [],
            competencyProgress: []
        )
        viewModel.loadAnalytics()
        
        // Then
        XCTAssertEqual(viewModel.activeUsersPercentage, 75.0)
    }
    
    func testCompletionRate() {
        // Given
        mockService.mockCourseStatistics = [
            CourseStatistics(
                courseId: "course1",
                courseName: "Course 1",
                enrolledCount: 100,
                completedCount: 80,
                averageProgress: 0.8,
                averageScore: 80,
                averageTimeToComplete: 10,
                satisfactionRating: 4.2
            ),
            CourseStatistics(
                courseId: "course2",
                courseName: "Course 2",
                enrolledCount: 50,
                completedCount: 30,
                averageProgress: 0.6,
                averageScore: 85,
                averageTimeToComplete: 12,
                satisfactionRating: 4.0
            )
        ]
        viewModel.loadAnalytics()
        
        // Then
        let expectedRate = (80.0 + 30.0) / (100.0 + 50.0) * 100
        XCTAssertEqual(viewModel.completionRate, expectedRate, accuracy: 0.01)
    }
    
    func testCompletionRateWithNoEnrollments() {
        // Given
        mockService.mockCourseStatistics = []
        viewModel.loadAnalytics()
        
        // Then
        XCTAssertEqual(viewModel.completionRate, 0)
    }
    
    // MARK: - Export Tests
    
    func testExportDashboard() {
        // When
        let fileURL = viewModel.exportDashboard()
        
        // Then
        XCTAssertNotNil(fileURL)
        XCTAssertTrue(FileManager.default.fileExists(atPath: fileURL!.path))
        
        // Cleanup
        try? FileManager.default.removeItem(at: fileURL!)
    }
    
    func testExportDashboardContent() {
        // Given
        mockService.mockSummary = AnalyticsSummary(
            period: .month,
            startDate: Date().addingTimeInterval(-30 * 24 * 60 * 60),
            endDate: Date(),
            totalUsers: 100,
            activeUsers: 75,
            completedCourses: 150,
            averageScore: 85.5,
            totalLearningHours: 1200,
            topPerformers: [
                UserPerformance(
                    userId: "user1",
                    userName: "Top User",
                    avatar: "person.circle.fill",
                    totalScore: 1000,
                    completedCourses: 20,
                    averageTestScore: 92.5,
                    learningHours: 200,
                    rank: 1,
                    badges: ["star", "trophy", "checkmark.seal"],
                    trend: .improving
                )
            ],
            popularCourses: [],
            competencyProgress: []
        )
        viewModel.loadAnalytics()
        
        // When
        let fileURL = viewModel.exportDashboard()
        
        // Then
        XCTAssertNotNil(fileURL)
        
        if let url = fileURL,
           let content = try? String(contentsOf: url) {
            XCTAssertTrue(content.contains("75")) // Active users
            XCTAssertTrue(content.contains("150")) // Completed courses
            XCTAssertTrue(content.contains("85.5%")) // Average score
            XCTAssertTrue(content.contains("Top User")) // Top performer
            
            // Cleanup
            try? FileManager.default.removeItem(at: url)
        } else {
            XCTFail("Could not read exported file")
        }
    }
    
    // MARK: - Edge Cases
    
    func testNilAnalyticsSummary() {
        // Given
        mockService.mockSummary = nil
        viewModel.loadAnalytics()
        
        // Then
        XCTAssertEqual(viewModel.totalLearningHours, "0")
        XCTAssertEqual(viewModel.averageScore, "0%")
        XCTAssertEqual(viewModel.activeUsersPercentage, 0)
        XCTAssertTrue(viewModel.topPerformers.isEmpty)
        XCTAssertTrue(viewModel.popularCourses.isEmpty)
    }
} 