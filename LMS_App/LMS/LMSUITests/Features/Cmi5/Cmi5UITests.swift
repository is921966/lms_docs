//
//  Cmi5UITests.swift
//  LMSUITests
//
//  Created on Sprint 40 Day 5 - UI Tests
//

import XCTest

/// UI tests for Cmi5 module user interface
class Cmi5UITests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["UI_TESTING"]
        app.launch()
        
        // Navigate to Cmi5 section
        navigateToCmi5()
    }
    
    // MARK: - Navigation Tests
    
    func testCmi5ModuleAccessibility() {
        // Verify Cmi5 module is accessible from main menu
        XCTAssertTrue(app.navigationBars["Cmi5 Player"].exists)
        
        // Check main sections are visible
        XCTAssertTrue(app.buttons["Browse Courses"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["My Learning"].exists)
        XCTAssertTrue(app.buttons["Analytics"].exists)
        XCTAssertTrue(app.buttons["Reports"].exists)
    }
    
    func testNavigationFlow() {
        // Test navigation through all Cmi5 sections
        
        // Browse Courses
        app.buttons["Browse Courses"].tap()
        XCTAssertTrue(app.navigationBars["Course Catalog"].exists)
        app.navigationBars.buttons["Back"].tap()
        
        // My Learning
        app.buttons["My Learning"].tap()
        XCTAssertTrue(app.navigationBars["My Learning"].exists)
        app.navigationBars.buttons["Back"].tap()
        
        // Analytics
        app.buttons["Analytics"].tap()
        XCTAssertTrue(app.navigationBars["Learning Analytics"].exists)
        app.navigationBars.buttons["Back"].tap()
        
        // Reports
        app.buttons["Reports"].tap()
        XCTAssertTrue(app.navigationBars["Learning Reports"].exists)
    }
    
    // MARK: - Course Launch Tests
    
    func testCourseLaunchFlow() {
        // Navigate to course catalog
        app.buttons["Browse Courses"].tap()
        
        // Select first course
        let courseCell = app.collectionViews.cells.firstMatch
        XCTAssertTrue(courseCell.waitForExistence(timeout: 5))
        courseCell.tap()
        
        // Verify course details
        XCTAssertTrue(app.staticTexts["Course Details"].exists)
        XCTAssertTrue(app.buttons["Launch Course"].exists)
        
        // Launch course
        app.buttons["Launch Course"].tap()
        
        // Verify player view
        XCTAssertTrue(app.otherElements["CoursePlayer"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.buttons["Exit Course"].exists)
    }
    
    func testCoursePlayerControls() {
        launchTestCourse()
        
        // Verify player controls
        XCTAssertTrue(app.buttons["Pause"].exists)
        XCTAssertTrue(app.progressIndicators["CourseProgress"].exists)
        XCTAssertTrue(app.staticTexts["Session Time"].exists)
        
        // Test pause/resume
        app.buttons["Pause"].tap()
        XCTAssertTrue(app.buttons["Resume"].exists)
        
        app.buttons["Resume"].tap()
        XCTAssertTrue(app.buttons["Pause"].exists)
    }
    
    // MARK: - Analytics Dashboard Tests
    
    func testAnalyticsDashboardDisplay() {
        app.buttons["Analytics"].tap()
        
        // Verify metrics cards
        XCTAssertTrue(app.otherElements["CompletionRateCard"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.otherElements["AverageScoreCard"].exists)
        XCTAssertTrue(app.otherElements["TimeSpentCard"].exists)
        XCTAssertTrue(app.otherElements["ActiveSessionsCard"].exists)
        
        // Verify chart
        XCTAssertTrue(app.otherElements["ProgressChart"].exists)
        
        // Verify heatmap
        XCTAssertTrue(app.otherElements["ActivityHeatmap"].exists)
    }
    
    func testAnalyticsInteraction() {
        app.buttons["Analytics"].tap()
        
        // Test time range selector
        app.buttons["TimeRangeSelector"].tap()
        XCTAssertTrue(app.buttons["Last 7 Days"].exists)
        XCTAssertTrue(app.buttons["Last 30 Days"].exists)
        XCTAssertTrue(app.buttons["All Time"].exists)
        
        app.buttons["Last 30 Days"].tap()
        
        // Verify data updates (check loading indicator)
        XCTAssertTrue(app.activityIndicators["LoadingAnalytics"].exists)
        XCTAssertFalse(app.activityIndicators["LoadingAnalytics"].exists)
    }
    
    // MARK: - Report Generation Tests
    
    func testReportGeneration() {
        app.buttons["Reports"].tap()
        
        // Select report type
        app.buttons["Generate Report"].tap()
        XCTAssertTrue(app.sheets["Report Options"].exists)
        
        // Select progress report
        app.buttons["Progress Report"].tap()
        
        // Verify preview
        XCTAssertTrue(app.staticTexts["Report Preview"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["Export"].exists)
    }
    
    func testReportExportOptions() {
        generateTestReport()
        
        // Test export options
        app.buttons["Export"].tap()
        XCTAssertTrue(app.sheets["Export Options"].exists)
        
        // Verify format options
        XCTAssertTrue(app.buttons["Export as PDF"].exists)
        XCTAssertTrue(app.buttons["Export as CSV"].exists)
        XCTAssertTrue(app.buttons["Share"].exists)
        
        // Test PDF export
        app.buttons["Export as PDF"].tap()
        XCTAssertTrue(app.activityIndicators["ExportingReport"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.alerts["Export Complete"].waitForExistence(timeout: 10))
    }
    
    // MARK: - Offline Mode Tests
    
    func testOfflineModeIndicator() {
        // Enable airplane mode (simulated)
        app.launchArguments.append("SIMULATE_OFFLINE")
        app.terminate()
        app.launch()
        navigateToCmi5()
        
        // Verify offline indicator
        XCTAssertTrue(app.staticTexts["Offline Mode"].exists)
        XCTAssertTrue(app.images["OfflineIcon"].exists)
    }
    
    func testOfflineFunctionality() {
        // Launch in offline mode
        app.launchArguments.append("SIMULATE_OFFLINE")
        app.terminate()
        app.launch()
        navigateToCmi5()
        
        // Launch course offline
        launchTestCourse()
        
        // Verify offline features work
        XCTAssertTrue(app.staticTexts["Statements will sync when online"].exists)
        
        // Complete an action
        app.buttons["Mark Complete"].tap()
        XCTAssertTrue(app.staticTexts["Saved offline"].exists)
    }
    
    // MARK: - Loading States Tests
    
    func testLoadingStates() {
        // Test course catalog loading
        app.buttons["Browse Courses"].tap()
        XCTAssertTrue(app.otherElements["SkeletonLoader"].exists)
        XCTAssertFalse(app.otherElements["SkeletonLoader"].waitForExistence(timeout: 5))
        
        // Test analytics loading
        app.navigationBars.buttons["Back"].tap()
        app.buttons["Analytics"].tap()
        XCTAssertTrue(app.activityIndicators["LoadingAnalytics"].exists)
        XCTAssertFalse(app.activityIndicators["LoadingAnalytics"].waitForExistence(timeout: 5))
    }
    
    // MARK: - Error Handling Tests
    
    func testErrorHandling() {
        // Simulate network error
        app.launchArguments.append("SIMULATE_NETWORK_ERROR")
        app.terminate()
        app.launch()
        navigateToCmi5()
        
        app.buttons["Browse Courses"].tap()
        
        // Verify error state
        XCTAssertTrue(app.staticTexts["Unable to load courses"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["Retry"].exists)
        
        // Test retry
        app.buttons["Retry"].tap()
        XCTAssertTrue(app.activityIndicators["LoadingCourses"].exists)
    }
    
    // MARK: - Accessibility Tests
    
    func testAccessibilityLabels() {
        // Verify accessibility labels
        XCTAssertTrue(app.buttons["Browse Courses"].isHittable)
        XCTAssertEqual(app.buttons["Browse Courses"].label, "Browse available courses")
        
        app.buttons["Analytics"].tap()
        
        let completionCard = app.otherElements["CompletionRateCard"]
        XCTAssertTrue(completionCard.isAccessibilityElement)
        XCTAssertTrue(completionCard.label.contains("Completion rate"))
    }
    
    func testVoiceOverNavigation() {
        // Enable VoiceOver simulation
        app.launchArguments.append("ENABLE_ACCESSIBILITY_TESTING")
        app.terminate()
        app.launch()
        navigateToCmi5()
        
        // Test navigation with accessibility
        let elements = app.descendants(matching: .any).allElementsBoundByAccessibilityElement
        XCTAssertGreaterThan(elements.count, 0)
        
        // Verify all interactive elements have labels
        for element in [app.buttons, app.staticTexts, app.images].flatMap({ $0.allElementsBoundByIndex }) {
            if element.isHittable {
                XCTAssertFalse(element.label.isEmpty, "Element \(element) missing accessibility label")
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func navigateToCmi5() {
        // Navigate to Learning tab
        if app.tabBars.buttons["Learning"].exists {
            app.tabBars.buttons["Learning"].tap()
        }
        
        // Find and tap Cmi5 Player
        let cmi5Button = app.collectionViews.buttons["Cmi5 Player"]
        if cmi5Button.exists {
            cmi5Button.tap()
        } else {
            // Scroll to find it
            let collectionView = app.collectionViews.firstMatch
            collectionView.swipeUp()
            if cmi5Button.exists {
                cmi5Button.tap()
            }
        }
    }
    
    private func launchTestCourse() {
        app.buttons["Browse Courses"].tap()
        app.collectionViews.cells.firstMatch.tap()
        app.buttons["Launch Course"].tap()
        _ = app.otherElements["CoursePlayer"].waitForExistence(timeout: 10)
    }
    
    private func generateTestReport() {
        app.buttons["Reports"].tap()
        app.buttons["Generate Report"].tap()
        app.buttons["Progress Report"].tap()
        _ = app.staticTexts["Report Preview"].waitForExistence(timeout: 5)
    }
} 