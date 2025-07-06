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
            totalUsers: 100,
            activeUsers: 75,
            completedCourses: 150,
            totalLearningHours: 1200,
            averageScore: 85.5,
            topPerformers: [],
            popularCourses: []
        )
    }
    
    func getUserPerformance(userId: String, period: AnalyticsPeriod) -> UserPerformance {
        return mockUserPerformance ?? UserPerformance(
            userId: userId,
            userName: "Test User",
            rank: 1,
            totalScore: 950,
            completedCourses: 10,
            learningHours: 120,
            lastActivityDate: Date()
        )
    }
    
    func getCourseStatistics(period: AnalyticsPeriod) -> [CourseStatistics] {
        return mockCourseStatistics.isEmpty ? [
            CourseStatistics(
                courseId: "course1",
                courseName: "iOS Development",
                enrolledCount: 50,
                completedCount: 35,
                averageScore: 87.5,
                averageCompletionTime: 15
            )
        ] : mockCourseStatistics
    }
    
    func getCompetencyProgress(period: AnalyticsPeriod) -> [CompetencyProgress] {
        return mockCompetencyProgress.isEmpty ? [
            CompetencyProgress(
                competencyId: "comp1",
                competencyName: "Swift",
                progressPercentage: 75,
                usersCount: 30
            )
        ] : mockCompetencyProgress
    }
    
    func trackEvent(_ data: AnalyticsData) {
        trackedEvents.append(data)
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
            totalUsers: 200,
            activeUsers: 150,
            completedCourses: 300,
            totalLearningHours: 2400,
            averageScore: 90.0,
            topPerformers: [],
            popularCourses: []
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
        viewModel.trackEvent(type: .courseCompleted, metrics: metrics, metadata: metadata)
        
        // Then
        XCTAssertEqual(mockService.trackedEvents.count, 1)
        XCTAssertEqual(mockService.trackedEvents.first?.type, .courseCompleted)
        XCTAssertEqual(mockService.trackedEvents.first?.metrics["score"], 95.0)
        XCTAssertEqual(mockService.trackedEvents.first?.metadata["courseId"], "course1")
    }
    
    func testTrackMultipleEvents() {
        // When
        viewModel.trackEvent(type: .courseStarted, metrics: [:])
        viewModel.trackEvent(type: .testCompleted, metrics: ["score": 85.0])
        viewModel.trackEvent(type: .moduleCompleted, metrics: ["progress": 100.0])
        
        // Then
        XCTAssertEqual(mockService.trackedEvents.count, 3)
        XCTAssertEqual(mockService.trackedEvents[0].type, .courseStarted)
        XCTAssertEqual(mockService.trackedEvents[1].type, .testCompleted)
        XCTAssertEqual(mockService.trackedEvents[2].type, .moduleCompleted)
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
                averageScore: 80,
                averageCompletionTime: 10
            ),
            CourseStatistics(
                courseId: "course2",
                courseName: "Course 2",
                enrolledCount: 20,
                completedCount: 15,
                averageScore: 85,
                averageCompletionTime: 12
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
                rank: 1,
                totalScore: 1000,
                completedCourses: 15,
                learningHours: 150,
                lastActivityDate: Date()
            )
        ]
        mockService.mockSummary = AnalyticsSummary(
            period: .month,
            totalUsers: 100,
            activeUsers: 75,
            completedCourses: 150,
            totalLearningHours: 1200,
            averageScore: 85.5,
            topPerformers: performers,
            popularCourses: []
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
                averageScore: 90,
                averageCompletionTime: 10
            )
        ]
        mockService.mockSummary = AnalyticsSummary(
            period: .month,
            totalUsers: 100,
            activeUsers: 75,
            completedCourses: 150,
            totalLearningHours: 1200,
            averageScore: 85.5,
            topPerformers: [],
            popularCourses: courses
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
                progressPercentage: 75,
                usersCount: 30
            ),
            CompetencyProgress(
                competencyId: "comp2",
                competencyName: "UIKit",
                progressPercentage: 65,
                usersCount: 25
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
            totalUsers: 100,
            activeUsers: 75,
            completedCourses: 150,
            totalLearningHours: 1234.5,
            averageScore: 85.5,
            topPerformers: [],
            popularCourses: []
        )
        viewModel.loadAnalytics()
        
        // Then
        XCTAssertEqual(viewModel.totalLearningHours, "1234")
    }
    
    func testAverageScore() {
        // Given
        mockService.mockSummary = AnalyticsSummary(
            period: .month,
            totalUsers: 100,
            activeUsers: 75,
            completedCourses: 150,
            totalLearningHours: 1200,
            averageScore: 87.35,
            topPerformers: [],
            popularCourses: []
        )
        viewModel.loadAnalytics()
        
        // Then
        XCTAssertEqual(viewModel.averageScore, "87.4%")
    }
    
    func testActiveUsersPercentage() {
        // Given
        mockService.mockSummary = AnalyticsSummary(
            period: .month,
            totalUsers: 200,
            activeUsers: 150,
            completedCourses: 150,
            totalLearningHours: 1200,
            averageScore: 85.5,
            topPerformers: [],
            popularCourses: []
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
                averageScore: 80,
                averageCompletionTime: 10
            ),
            CourseStatistics(
                courseId: "course2",
                courseName: "Course 2",
                enrolledCount: 50,
                completedCount: 30,
                averageScore: 85,
                averageCompletionTime: 12
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
            totalUsers: 100,
            activeUsers: 75,
            completedCourses: 150,
            totalLearningHours: 1200,
            averageScore: 85.5,
            topPerformers: [
                UserPerformance(
                    userId: "user1",
                    userName: "Top User",
                    rank: 1,
                    totalScore: 1000,
                    completedCourses: 20,
                    learningHours: 200,
                    lastActivityDate: Date()
                )
            ],
            popularCourses: []
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