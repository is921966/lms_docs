import XCTest
@testable import LMS

class SprintReportsChannelTests: XCTestCase {
    
    func testSprintReportsChannelInitialization() {
        // Given
        let channel = SprintReportsChannel.shared
        
        // Then
        XCTAssertNotNil(channel)
        XCTAssertEqual(channel.channel.name, "📊 Отчеты спринтов")
        XCTAssertEqual(channel.channel.category, .announcement)
        XCTAssertEqual(channel.channel.priority, .important)
    }
    
    func testLoadSprintReportsFromDirectory() {
        // Given
        let channel = SprintReportsChannel.shared
        
        // When
        let reports = channel.getSprintReports()
        
        // Then
        XCTAssertFalse(reports.isEmpty)
        // Should have at least some sprint reports
        XCTAssertTrue(reports.count >= 1)
    }
    
    func testSprintReportStructure() {
        // Given
        let channel = SprintReportsChannel.shared
        
        // When
        let reports = channel.getSprintReports()
        
        // Then
        if let firstReport = reports.first {
            XCTAssertFalse(firstReport.sprintNumber.isEmpty)
            XCTAssertNotNil(firstReport.date)
            XCTAssertFalse(firstReport.title.isEmpty)
            XCTAssertFalse(firstReport.content.isEmpty)
        }
    }
    
    func testGenerateFeedMessages() {
        // Given
        let channel = SprintReportsChannel.shared
        
        // When
        let messages = channel.generateFeedMessages()
        
        // Then
        XCTAssertFalse(messages.isEmpty)
        
        // Each message should have proper content
        for message in messages {
            XCTAssertFalse(message.text.isEmpty)
            XCTAssertNotNil(message.timestamp)
            XCTAssertFalse(message.isFromUser)
            XCTAssertTrue(message.isFromChannel)
        }
    }
    
    func testSprintReportsSortedByNumber() {
        // Given
        let channel = SprintReportsChannel.shared
        
        // When
        let reports = channel.getSprintReports()
        
        // Then
        // Reports should be sorted by sprint number (descending)
        for i in 0..<reports.count-1 {
            if let num1 = Int(reports[i].sprintNumber),
               let num2 = Int(reports[i+1].sprintNumber) {
                XCTAssertGreaterThanOrEqual(num1, num2)
            }
        }
    }
} 