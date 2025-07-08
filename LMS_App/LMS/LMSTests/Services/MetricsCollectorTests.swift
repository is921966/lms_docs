//
//  MetricsCollectorTests.swift
//  LMSTests
//
//  Created on Sprint 39 Day 2 - TDD Excellence
//

import XCTest
@testable import LMS

final class MetricsCollectorTests: XCTestCase {
    
    var sut: MetricsCollector!
    
    override func setUp() {
        super.setUp()
        sut = MetricsCollector.shared
        sut.clearAll()
    }
    
    override func tearDown() {
        sut.clearAll()
        sut = nil
        super.tearDown()
    }
    
    // MARK: - Event Tracking Tests
    
    func testTrackEventWithParameters() {
        // Arrange
        let eventName = "button_clicked"
        let parameters: [String: Any] = ["screen": "home", "button": "login"]
        
        // Act
        sut.track(event: eventName, parameters: parameters)
        
        // Wait a bit for async operation
        let expectation = XCTestExpectation(description: "Event tracked")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
        
        // Assert
        let events = sut.getEvents(for: eventName)
        XCTAssertEqual(events.count, 1)
        XCTAssertEqual(events.first?.name, eventName)
        XCTAssertEqual(events.first?.parameters["screen"] as? String, "home")
    }
    
    func testTrackScreenView() {
        // Arrange
        let screenName = "CourseListView"
        
        // Act
        sut.trackScreenView(screenName)
        let duration = sut.endScreenView(screenName)
        
        // Assert
        XCTAssertNotNil(duration)
        XCTAssertGreaterThan(duration!, 0)
        
        let screenViews = sut.getScreenViews()
        XCTAssertEqual(screenViews.first?.name, screenName)
    }
    
    func testPerformanceMetric() async {
        // Arrange
        let operation = "api_call"
        
        // Act
        let result = await sut.measurePerformance(operation: operation) {
            try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 second
            return "Success"
        }
        
        // Assert
        XCTAssertEqual(result, "Success")
        
        let metrics = sut.getPerformanceMetrics(for: operation)
        XCTAssertEqual(metrics.count, 1)
        XCTAssertGreaterThanOrEqual(metrics.first?.duration ?? 0, 0.1)
        XCTAssertTrue(metrics.first?.success ?? false)
    }
    
    // MARK: - Additional Tests for Refactored Features
    
    func testSessionManagement() {
        // Arrange
        sut.track(event: "test_event_1")
        let firstSessionId = sut.getEvents(for: "test_event_1").first?.sessionId
        
        // Act - Clear all starts new session
        sut.clearAll()
        sut.track(event: "test_event_2")
        let secondSessionId = sut.getEvents(for: "test_event_2").first?.sessionId
        
        // Assert
        XCTAssertNotNil(firstSessionId)
        XCTAssertNotNil(secondSessionId)
        XCTAssertNotEqual(firstSessionId, secondSessionId)
    }
    
    func testSummaryStats() {
        // Arrange & Act
        sut.track(event: "event_1")
        sut.track(event: "event_1")
        sut.track(event: "event_2")
        sut.trackScreenView("Screen1")
        sut.endScreenView("Screen1")
        
        // Wait for async operations
        let expectation = XCTestExpectation(description: "Stats calculated")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
        
        // Assert
        let stats = sut.getSummaryStats()
        XCTAssertGreaterThan(stats.totalEvents, 3) // Including automatic screen view events
        XCTAssertEqual(stats.totalScreenViews, 1)
        XCTAssertGreaterThan(stats.sessionDuration, 0)
        
        let topEvent = stats.topEvents.first
        XCTAssertNotNil(topEvent)
    }
} 