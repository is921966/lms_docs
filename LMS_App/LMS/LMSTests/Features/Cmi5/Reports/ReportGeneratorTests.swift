//
//  ReportGeneratorTests.swift
//  LMSTests
//
//  Created on Sprint 42 Day 3 - Reports
//

import XCTest
import PDFKit
@testable import LMS

final class ReportGeneratorTests: XCTestCase {
    
    private var generator: ReportGenerator!
    private var mockAnalytics: MockAnalyticsCollector!
    
    override func setUp() {
        super.setUp()
        mockAnalytics = MockAnalyticsCollector()
        generator = ReportGenerator(analytics: mockAnalytics)
    }
    
    override func tearDown() {
        generator = nil
        mockAnalytics = nil
        super.tearDown()
    }
    
    // MARK: - Progress Report Tests
    
    func testGenerateProgressReport() async throws {
        // Given
        mockAnalytics.mockProgressMetrics = AnalyticsCollector.ProgressMetrics(
            completionRate: 0.75,
            completedActivities: 15,
            totalActivities: 20,
            trend: [
                AnalyticsCollector.DailyProgress(date: Date(), completedCount: 3),
                AnalyticsCollector.DailyProgress(date: Date().addingTimeInterval(-86400), completedCount: 5)
            ]
        )
        
        // When
        let report = try await generator.generateProgressReport(
            userId: "user123",
            courseId: "course456"
        )
        
        // Then
        XCTAssertEqual(report.type, .progress)
        XCTAssertEqual(report.userId, "user123")
        XCTAssertEqual(report.courseId, "course456")
        XCTAssertNotNil(report.generatedAt)
        XCTAssertTrue(report.sections.contains(where: { $0.title == "Completion Status" }))
        XCTAssertTrue(report.sections.contains(where: { $0.title == "Daily Progress" }))
    }
    
    func testProgressReport_IncludesChart() async throws {
        // Given
        mockAnalytics.mockProgressMetrics = createMockProgressMetrics()
        
        // When
        let report = try await generator.generateProgressReport(
            userId: "user123",
            courseId: "course456"
        )
        
        // Then
        let chartSection = report.sections.first { $0.type == .chart }
        XCTAssertNotNil(chartSection)
        XCTAssertNotNil(chartSection?.chartData)
        XCTAssertEqual(chartSection?.chartData?.type, .line)
    }
    
    // MARK: - Performance Report Tests
    
    func testGeneratePerformanceReport() async throws {
        // Given
        mockAnalytics.mockPerformanceMetrics = AnalyticsCollector.PerformanceMetrics(
            successRate: 0.85,
            averageScore: 0.82,
            scoreDistribution: [0.7: 2, 0.8: 5, 0.9: 3],
            improvementTrend: 0.15
        )
        
        // When
        let report = try await generator.generatePerformanceReport(
            userId: "user123",
            courseId: "course456"
        )
        
        // Then
        XCTAssertEqual(report.type, .performance)
        XCTAssertTrue(report.sections.contains(where: { $0.title == "Overall Performance" }))
        XCTAssertTrue(report.sections.contains(where: { $0.title == "Score Distribution" }))
    }
    
    func testPerformanceReport_IncludesRecommendations() async throws {
        // Given
        mockAnalytics.mockPerformanceMetrics = AnalyticsCollector.PerformanceMetrics(
            successRate: 0.65,
            averageScore: 0.62,
            scoreDistribution: [:],
            improvementTrend: -0.05
        )
        
        // When
        let report = try await generator.generatePerformanceReport(
            userId: "user123",
            courseId: "course456"
        )
        
        // Then
        let recommendations = report.sections.first { $0.title == "Recommendations" }
        XCTAssertNotNil(recommendations)
        XCTAssertFalse(recommendations?.content.isEmpty ?? true)
    }
    
    // MARK: - Engagement Report Tests
    
    func testGenerateEngagementReport() async throws {
        // Given
        mockAnalytics.mockEngagementMetrics = AnalyticsCollector.EngagementMetrics(
            activeDays: 15,
            frequency: 0.75,
            peakHours: [
                AnalyticsCollector.HourActivity(hour: 14, count: 10),
                AnalyticsCollector.HourActivity(hour: 15, count: 8)
            ],
            averageTimePerDay: 2700 // 45 minutes
        )
        
        // When
        let report = try await generator.generateEngagementReport(
            userId: "user123",
            courseId: "course456",
            period: 30
        )
        
        // Then
        XCTAssertEqual(report.type, .engagement)
        XCTAssertTrue(report.sections.contains(where: { $0.title == "Learning Habits" }))
        XCTAssertTrue(report.sections.contains(where: { $0.title == "Peak Learning Hours" }))
    }
    
    // MARK: - Comparison Report Tests
    
    func testGenerateComparisonReport() async throws {
        // Given
        mockAnalytics.mockComparisonData = ComparisonData(
            userScore: 0.85,
            groupAverage: 0.78,
            percentile: 75,
            rank: 5,
            totalUsers: 20
        )
        
        // When
        let report = try await generator.generateComparisonReport(
            userId: "user123",
            courseId: "course456",
            groupId: "group789"
        )
        
        // Then
        XCTAssertEqual(report.type, .comparison)
        XCTAssertTrue(report.sections.contains(where: { $0.title.contains("Group Comparison") }))
        XCTAssertTrue(report.sections.contains(where: { $0.content.contains("75th percentile") }))
    }
    
    // MARK: - PDF Export Tests
    
    func testExportToPDF() async throws {
        // Given
        let report = createMockReport()
        
        // When
        let pdfData = try await generator.exportToPDF(report)
        
        // Then
        XCTAssertFalse(pdfData.isEmpty)
        
        // Verify it's valid PDF
        let pdfDocument = PDFDocument(data: pdfData)
        XCTAssertNotNil(pdfDocument)
        XCTAssertGreaterThan(pdfDocument?.pageCount ?? 0, 0)
    }
    
    func testPDF_ContainsAllSections() async throws {
        // Given
        let report = Report(
            id: UUID(),
            type: .progress,
            userId: "user123",
            courseId: "course456",
            generatedAt: Date(),
            sections: [
                ReportSection(title: "Section 1", content: "Content 1", type: .text),
                ReportSection(title: "Section 2", content: "Content 2", type: .table),
                ReportSection(title: "Section 3", content: "Content 3", type: .chart)
            ]
        )
        
        // When
        let pdfData = try await generator.exportToPDF(report)
        let pdfDocument = PDFDocument(data: pdfData)
        
        // Then
        XCTAssertNotNil(pdfDocument)
        let firstPage = pdfDocument?.page(at: 0)
        let pageContent = firstPage?.string ?? ""
        
        XCTAssertTrue(pageContent.contains("Section 1"))
        XCTAssertTrue(pageContent.contains("Section 2"))
    }
    
    // MARK: - CSV Export Tests
    
    func testExportToCSV() async throws {
        // Given
        let report = createMockReport()
        
        // When
        let csvString = try await generator.exportToCSV(report)
        
        // Then
        XCTAssertFalse(csvString.isEmpty)
        XCTAssertTrue(csvString.contains("Section,Content"))
        XCTAssertTrue(csvString.contains(report.sections[0].title))
    }
    
    func testCSV_EscapesSpecialCharacters() async throws {
        // Given
        let report = Report(
            id: UUID(),
            type: .progress,
            userId: "user123",
            courseId: "course456",
            generatedAt: Date(),
            sections: [
                ReportSection(
                    title: "Title with, comma",
                    content: "Content with \"quotes\" and\nnewlines",
                    type: .text
                )
            ]
        )
        
        // When
        let csv = try await generator.exportToCSV(report)
        
        // Then
        XCTAssertTrue(csv.contains("\"Title with, comma\""))
        XCTAssertTrue(csv.contains("\"Content with \"\"quotes\"\" and\nnewlines\""))
    }
    
    // MARK: - Template Tests
    
    func testApplyTemplate_Progress() async throws {
        // Given
        let template = ReportTemplate.progressTemplate
        let data = ["completion": "75%", "activities": "15/20"]
        
        // When
        let sections = generator.applyTemplate(template, with: data)
        
        // Then
        XCTAssertFalse(sections.isEmpty)
        XCTAssertTrue(sections[0].content.contains("75%"))
        XCTAssertTrue(sections[0].content.contains("15/20"))
    }
    
    func testCustomTemplate() async throws {
        // Given
        let customTemplate = ReportTemplate(
            name: "Custom",
            sections: [
                ReportTemplate.Section(
                    title: "{{title}}",
                    template: "Value: {{value}}",
                    type: .text
                )
            ]
        )
        
        let data = ["title": "Test Title", "value": "42"]
        
        // When
        let sections = generator.applyTemplate(customTemplate, with: data)
        
        // Then
        XCTAssertEqual(sections[0].title, "Test Title")
        XCTAssertEqual(sections[0].content, "Value: 42")
    }
    
    // MARK: - Error Handling Tests
    
    func testGenerateReport_ThrowsOnMissingData() async {
        // Given
        mockAnalytics.shouldThrowError = true
        
        // When/Then
        do {
            _ = try await generator.generateProgressReport(
                userId: "user123",
                courseId: "course456"
            )
            XCTFail("Expected error")
        } catch {
            XCTAssertTrue(error is ReportGenerator.ReportError)
        }
    }
    
    // MARK: - Performance Tests
    
    func testPerformance_GenerateLargeReport() {
        // Given
        mockAnalytics.mockProgressMetrics = AnalyticsCollector.ProgressMetrics(
            completionRate: 0.75,
            completedActivities: 100,
            totalActivities: 150,
            trend: (0..<30).map { day in
                AnalyticsCollector.DailyProgress(
                    date: Date().addingTimeInterval(Double(-day * 86400)),
                    completedCount: Int.random(in: 1...10)
                )
            }
        )
        
        // When/Then
        measure {
            let expectation = expectation(description: "Report generated")
            
            Task {
                _ = try await generator.generateProgressReport(
                    userId: "user123",
                    courseId: "course456"
                )
                expectation.fulfill()
            }
            
            wait(for: [expectation], timeout: 5.0)
        }
    }
    
    // MARK: - Helper Methods
    
    private func createMockReport() -> Report {
        return Report(
            id: UUID(),
            type: .progress,
            userId: "user123",
            courseId: "course456",
            generatedAt: Date(),
            sections: [
                ReportSection(
                    title: "Overview",
                    content: "This is the overview section",
                    type: .text
                ),
                ReportSection(
                    title: "Statistics",
                    content: "Completion: 75%",
                    type: .table
                )
            ]
        )
    }
    
    private func createMockProgressMetrics() -> AnalyticsCollector.ProgressMetrics {
        return AnalyticsCollector.ProgressMetrics(
            completionRate: 0.75,
            completedActivities: 15,
            totalActivities: 20,
            trend: (0..<7).map { day in
                AnalyticsCollector.DailyProgress(
                    date: Date().addingTimeInterval(Double(-day * 86400)),
                    completedCount: Int.random(in: 1...5)
                )
            }
        )
    }
}

// MARK: - Mock Classes

class MockAnalyticsCollector {
    var mockProgressMetrics: AnalyticsCollector.ProgressMetrics?
    var mockPerformanceMetrics: AnalyticsCollector.PerformanceMetrics?
    var mockEngagementMetrics: AnalyticsCollector.EngagementMetrics?
    var mockComparisonData: ComparisonData?
    var shouldThrowError = false
    
    func getProgressMetrics() async throws -> AnalyticsCollector.ProgressMetrics {
        if shouldThrowError {
            throw ReportGenerator.ReportError.dataNotAvailable
        }
        return mockProgressMetrics ?? AnalyticsCollector.ProgressMetrics(
            completionRate: 0,
            completedActivities: 0,
            totalActivities: 0,
            trend: []
        )
    }
    
    func getPerformanceMetrics() async throws -> AnalyticsCollector.PerformanceMetrics {
        if shouldThrowError {
            throw ReportGenerator.ReportError.dataNotAvailable
        }
        return mockPerformanceMetrics ?? AnalyticsCollector.PerformanceMetrics(
            successRate: 0,
            averageScore: 0,
            scoreDistribution: [:],
            improvementTrend: 0
        )
    }
    
    func getEngagementMetrics() async throws -> AnalyticsCollector.EngagementMetrics {
        if shouldThrowError {
            throw ReportGenerator.ReportError.dataNotAvailable
        }
        return mockEngagementMetrics ?? AnalyticsCollector.EngagementMetrics(
            activeDays: 0,
            frequency: 0,
            peakHours: [],
            averageTimePerDay: 0
        )
    }
}

struct ComparisonData {
    let userScore: Double
    let groupAverage: Double
    let percentile: Int
    let rank: Int
    let totalUsers: Int
} 