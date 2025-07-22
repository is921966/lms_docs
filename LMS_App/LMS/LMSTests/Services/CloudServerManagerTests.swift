import XCTest
@testable import LMS

final class CloudServerManagerTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Reset to defaults before each test
        CloudServerManager.shared.resetToDefaults()
    }
    
    func test_defaultURLs_areCorrect() {
        // Given
        let manager = CloudServerManager.shared
        
        // Then
        XCTAssertEqual(manager.logServerURL, "https://lms-log-server-production.up.railway.app")
        XCTAssertEqual(manager.feedbackServerURL, "https://lms-feedback-server-production.up.railway.app")
    }
    
    func test_logAPIEndpoint_isCorrectlyFormatted() {
        // Given
        let manager = CloudServerManager.shared
        
        // Then
        XCTAssertEqual(manager.logAPIEndpoint, "https://lms-log-server-production.up.railway.app/api/logs")
    }
    
    func test_feedbackAPIEndpoint_isCorrectlyFormatted() {
        // Given
        let manager = CloudServerManager.shared
        
        // Then
        XCTAssertEqual(manager.feedbackAPIEndpoint, "https://lms-feedback-server-production.up.railway.app/api/v1/feedback")
    }
    
    func test_updateURLs_updatesLogServerURL() {
        // Given
        let manager = CloudServerManager.shared
        let newURL = "https://custom-log-server.com"
        
        // When
        manager.updateURLs(logServer: newURL)
        
        // Then
        XCTAssertEqual(manager.logServerURL, newURL)
        XCTAssertEqual(manager.logAPIEndpoint, "\(newURL)/api/logs")
    }
    
    func test_updateURLs_updatesFeedbackServerURL() {
        // Given
        let manager = CloudServerManager.shared
        let newURL = "https://custom-feedback-server.com"
        
        // When
        manager.updateURLs(feedbackServer: newURL)
        
        // Then
        XCTAssertEqual(manager.feedbackServerURL, newURL)
        XCTAssertEqual(manager.feedbackAPIEndpoint, "\(newURL)/api/v1/feedback")
    }
    
    func test_resetToDefaults_restoresDefaultURLs() {
        // Given
        let manager = CloudServerManager.shared
        manager.updateURLs(logServer: "https://custom.com", feedbackServer: "https://custom2.com")
        
        // When
        manager.resetToDefaults()
        
        // Then
        XCTAssertEqual(manager.logServerURL, "https://lms-log-server-production.up.railway.app")
        XCTAssertEqual(manager.feedbackServerURL, "https://lms-feedback-server-production.up.railway.app")
    }
    
    func test_updateURLs_sendsNotification() {
        // Given
        let manager = CloudServerManager.shared
        let expectation = XCTestExpectation(description: "Notification sent")
        
        let observer = NotificationCenter.default.addObserver(
            forName: NSNotification.Name("cloudServerURLsChanged"),
            object: nil,
            queue: .main
        ) { _ in
            expectation.fulfill()
        }
        
        // When
        manager.updateURLs(logServer: "https://new-server.com")
        
        // Then
        wait(for: [expectation], timeout: 1.0)
        NotificationCenter.default.removeObserver(observer)
    }
    
    func test_checkServerHealth_callsCompletionHandler() {
        // Given
        let manager = CloudServerManager.shared
        let expectation = XCTestExpectation(description: "Health check completed")
        
        // When
        manager.checkServerHealth { _, _ in
            expectation.fulfill()
        }
        
        // Then
        wait(for: [expectation], timeout: 5.0)
    }
} 