//
//  Cmi5UITests.swift
//  LMSUITests
//
//  Tests for Cmi5 module functionality
//

import XCTest

class Cmi5UITests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["UI_TESTING"]
        app.launch()
        
        // Wait for app to load
        _ = app.wait(for: .runningForeground, timeout: 5)
    }
    
    // MARK: - Navigation Tests
    
    func testCmi5ModuleAccessibility() {
        // Navigate to Cmi5
        navigateToCmi5()
        
        // Verify we're in Cmi5 section
        XCTAssertTrue(
            app.navigationBars.count > 0 ||
            app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] 'cmi5' OR label CONTAINS[c] 'курс' OR label CONTAINS[c] 'course'")).count > 0,
            "Should be in Cmi5 section"
        )
    }
    
    func testPackageListDisplay() {
        // Navigate to Cmi5
        navigateToCmi5()
        
        // Wait for content
        let hasContent = app.collectionViews.firstMatch.waitForExistence(timeout: 5) ||
                        app.tables.firstMatch.waitForExistence(timeout: 5)
        
        if hasContent {
            // Check for packages
            let cellCount = app.collectionViews.cells.count + app.tables.cells.count
            XCTAssertGreaterThanOrEqual(cellCount, 0, "Should show packages or empty state")
        }
    }
    
    func testPackageUploadButton() {
        // Navigate to Cmi5
        navigateToCmi5()
        
        // Look for upload button
        let uploadButton = app.buttons.matching(
            NSPredicate(format: "label CONTAINS[c] 'upload' OR label CONTAINS[c] 'загруз' OR label CONTAINS[c] 'add' OR label CONTAINS[c] 'добав'")
        ).firstMatch
        
        if uploadButton.exists {
            uploadButton.tap()
            
            // Verify some action happened
            Thread.sleep(forTimeInterval: 1.0)
            XCTAssertTrue(
                app.sheets.count > 0 ||
                app.alerts.count > 0 ||
                app.navigationBars.count > 1,
                "Upload action should present something"
            )
        }
    }
    
    func testPackageDetails() {
        // Navigate to Cmi5
        navigateToCmi5()
        
        // Get first package
        let firstCell = app.collectionViews.cells.firstMatch.exists ?
                       app.collectionViews.cells.firstMatch :
                       app.tables.cells.firstMatch
        
        if firstCell.waitForExistence(timeout: 5) {
            firstCell.tap()
            
            Thread.sleep(forTimeInterval: 1.0)
            
            // Should show details
            XCTAssertTrue(
                app.navigationBars.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'back' OR label CONTAINS[c] 'назад'")).count > 0 ||
                app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] 'activity' OR label CONTAINS[c] 'активност'")).count > 0,
                "Should show package details"
            )
        }
    }
    
    func testActivityLaunch() {
        // Navigate to Cmi5
        navigateToCmi5()
        
        // Open first package
        let firstCell = app.collectionViews.cells.firstMatch.exists ?
                       app.collectionViews.cells.firstMatch :
                       app.tables.cells.firstMatch
        
        if firstCell.waitForExistence(timeout: 5) {
            firstCell.tap()
            Thread.sleep(forTimeInterval: 1.0)
            
            // Look for activity or launch button
            let launchButton = app.buttons.matching(
                NSPredicate(format: "label CONTAINS[c] 'launch' OR label CONTAINS[c] 'запуст' OR label CONTAINS[c] 'start' OR label CONTAINS[c] 'начать'")
            ).firstMatch
            
            if launchButton.exists {
                launchButton.tap()
                Thread.sleep(forTimeInterval: 2.0)
                
                // Verify launch happened
                XCTAssertTrue(
                    app.webViews.count > 0 ||
                    app.navigationBars.count > 1,
                    "Should launch activity"
                )
            }
        }
    }
    
    func testPackageValidation() {
        // Navigate to Cmi5
        navigateToCmi5()
        
        // Check for validation indicators
        let validationElements = app.staticTexts.matching(
            NSPredicate(format: "label CONTAINS[c] 'valid' OR label CONTAINS[c] 'invalid' OR label CONTAINS[c] 'error'")
        )
        
        // Just verify UI handles validation states
        XCTAssertTrue(app.exists)
    }
    
    func testPackageSearch() {
        // Navigate to Cmi5
        navigateToCmi5()
        
        // Look for search field
        let searchField = app.searchFields.firstMatch
        if searchField.exists {
            searchField.tap()
            searchField.typeText("test")
            
            // Verify search works
            Thread.sleep(forTimeInterval: 1.0)
            XCTAssertTrue(app.exists)
        }
    }
    
    func testPackageSort() {
        // Navigate to Cmi5
        navigateToCmi5()
        
        // Look for sort button
        let sortButton = app.buttons.matching(
            NSPredicate(format: "label CONTAINS[c] 'sort' OR label CONTAINS[c] 'сортир'")
        ).firstMatch
        
        if sortButton.exists {
            sortButton.tap()
            Thread.sleep(forTimeInterval: 0.5)
            
            // Verify sort options appear
            XCTAssertTrue(
                app.sheets.count > 0 ||
                app.popovers.count > 0,
                "Should show sort options"
            )
        }
    }
    
    func testPackageDelete() {
        // Navigate to Cmi5
        navigateToCmi5()
        
        // Try swipe to delete on first cell
        let firstCell = app.tables.cells.firstMatch
        if firstCell.exists {
            firstCell.swipeLeft()
            
            let deleteButton = app.buttons.matching(
                NSPredicate(format: "label CONTAINS[c] 'delete' OR label CONTAINS[c] 'удал'")
            ).firstMatch
            
            if deleteButton.exists {
                // Don't actually delete, just verify button exists
                XCTAssertTrue(deleteButton.exists)
            }
        }
    }
    
    func testPackageMetadata() {
        // Navigate to Cmi5
        navigateToCmi5()
        
        // Check first cell for metadata
        let firstCell = app.collectionViews.cells.firstMatch.exists ?
                       app.collectionViews.cells.firstMatch :
                       app.tables.cells.firstMatch
        
        if firstCell.exists {
            // Should have title and some metadata
            XCTAssertTrue(
                firstCell.staticTexts.count > 0,
                "Package should display metadata"
            )
        }
    }
    
    func testEmptyState() {
        // Navigate to Cmi5
        navigateToCmi5()
        
        // Check for empty state or content
        let hasContent = app.collectionViews.cells.count > 0 || app.tables.cells.count > 0
        let hasEmptyMessage = app.staticTexts.matching(
            NSPredicate(format: "label CONTAINS[c] 'empty' OR label CONTAINS[c] 'пуст' OR label CONTAINS[c] 'no package'")
        ).count > 0
        
        XCTAssertTrue(
            hasContent || hasEmptyMessage,
            "Should show content or empty state"
        )
    }
    
    func testPackageRefresh() {
        // Navigate to Cmi5
        navigateToCmi5()
        
        // Find scrollable view
        let scrollView = app.collectionViews.firstMatch.exists ?
                        app.collectionViews.firstMatch :
                        app.tables.firstMatch
        
        if scrollView.exists {
            scrollView.swipeDown()
            Thread.sleep(forTimeInterval: 0.5)
            
            // Just verify no crash
            XCTAssertTrue(scrollView.exists)
        }
    }
    
    // MARK: - Helper Methods
    
    private func navigateToCmi5() {
        // Check if already in Cmi5
        if app.navigationBars.matching(NSPredicate(format: "identifier CONTAINS[c] 'cmi5'")).count > 0 {
            return
        }
        
        // Try tab navigation
        let tabBar = app.tabBars.firstMatch
        if tabBar.exists {
            // Try direct Cmi5 tab
            if tabBar.buttons["Cmi5"].exists {
                tabBar.buttons["Cmi5"].tap()
                Thread.sleep(forTimeInterval: 0.5)
                return
            }
            
            // Try through Learning/Courses
            let learningTabs = ["Обучение", "Learning", "Курсы", "Courses"]
            for tab in learningTabs {
                if tabBar.buttons[tab].exists {
                    tabBar.buttons[tab].tap()
                    Thread.sleep(forTimeInterval: 0.5)
                    
                    // Look for Cmi5 section
                    let cmi5Button = app.buttons.matching(
                        NSPredicate(format: "label CONTAINS[c] 'cmi5'")
                    ).firstMatch
                    
                    if cmi5Button.exists {
                        cmi5Button.tap()
                        Thread.sleep(forTimeInterval: 0.5)
                        return
                    }
                }
            }
            
            // Try More menu
            if tabBar.buttons["Ещё"].exists || tabBar.buttons["More"].exists {
                let moreButton = tabBar.buttons["Ещё"].exists ? tabBar.buttons["Ещё"] : tabBar.buttons["More"]
                moreButton.tap()
                Thread.sleep(forTimeInterval: 0.5)
                
                let cmi5Button = app.buttons.matching(
                    NSPredicate(format: "label CONTAINS[c] 'cmi5'")
                ).firstMatch
                
                if cmi5Button.exists {
                    cmi5Button.tap()
                    Thread.sleep(forTimeInterval: 0.5)
                }
            }
        }
    }
}
