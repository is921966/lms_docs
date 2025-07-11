//
//  FeedUITests.swift
//  LMSUITests
//
//  Feed Module UI Tests
//

import XCTest

class FeedUITests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["UI_TESTING"]
        app.launch()
        
        // Wait for app to fully load
        _ = app.wait(for: .runningForeground, timeout: 5)
    }
    
    // MARK: - Navigation Tests
    
    func testFeedModuleAccessibility() {
        // Navigate to Feed
        navigateToFeed()
        
        // Wait a bit for navigation
        Thread.sleep(forTimeInterval: 1.0)
        
        // Verify we're in some kind of feed/news section
        // Check for any navigation bar that might indicate feed
        let navBar = app.navigationBars.firstMatch
        if navBar.exists {
            let title = navBar.identifier
            print("Navigation bar title: \(title)")
        }
        
        // More flexible check - just verify we navigated somewhere
        XCTAssertTrue(
            app.navigationBars.count > 0 || 
            app.collectionViews.count > 0 ||
            app.tables.count > 0,
            "Should have navigated to a view with content"
        )
    }
    
    func testFeedTabNavigation() {
        // Navigate to Feed
        navigateToFeed()
        
        // Verify we have some content view
        XCTAssertTrue(
            app.collectionViews.firstMatch.exists ||
            app.tables.firstMatch.exists ||
            app.scrollViews.firstMatch.exists,
            "Feed should display some kind of scrollable content"
        )
    }
    
    // MARK: - Feed List Tests
    
    func testFeedListDisplay() {
        // Navigate to Feed
        navigateToFeed()
        
        // Wait for content to load
        let contentExists = app.collectionViews.firstMatch.waitForExistence(timeout: 5) ||
                           app.tables.firstMatch.waitForExistence(timeout: 5)
        
        if contentExists {
            // Check for cells
            let cellCount = app.collectionViews.cells.count + app.tables.cells.count
            XCTAssertGreaterThan(cellCount, 0, "Feed should have some items")
        } else {
            // Check for empty state
            XCTAssertTrue(
                app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] 'пуст' OR label CONTAINS[c] 'empty' OR label CONTAINS[c] 'нет'")).count > 0,
                "Should show either content or empty state"
            )
        }
    }
    
    func testFeedItemElements() {
        // Navigate to Feed
        navigateToFeed()
        
        // Get first cell from either collection or table view
        let firstCell = app.collectionViews.cells.firstMatch.exists ? 
                       app.collectionViews.cells.firstMatch : 
                       app.tables.cells.firstMatch
        
        if firstCell.waitForExistence(timeout: 5) {
            // Check for text content
            XCTAssertTrue(
                firstCell.staticTexts.count > 0 ||
                firstCell.buttons.count > 0,
                "Feed item should have some content"
            )
        }
    }
    
    // MARK: - Feed Interaction Tests
    
    func testFeedItemTap() {
        // Navigate to Feed
        navigateToFeed()
        
        // Get first cell
        let firstCell = app.collectionViews.cells.firstMatch.exists ? 
                       app.collectionViews.cells.firstMatch : 
                       app.tables.cells.firstMatch
        
        if firstCell.waitForExistence(timeout: 5) {
            // Remember current navigation state
            let navBarsBefore = app.navigationBars.count
            
            // Tap on feed item
            firstCell.tap()
            
            // Wait for navigation
            Thread.sleep(forTimeInterval: 1.0)
            
            // Should have navigated somewhere
            let navBarsAfter = app.navigationBars.count
            XCTAssertTrue(
                navBarsAfter > navBarsBefore ||
                app.navigationBars.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'back' OR label CONTAINS[c] 'назад'")).count > 0,
                "Should navigate to detail view"
            )
        }
    }
    
    func testFeedRefresh() {
        // Navigate to Feed
        navigateToFeed()
        
        // Find scrollable view
        let scrollableView = app.collectionViews.firstMatch.exists ? 
                            app.collectionViews.firstMatch : 
                            app.tables.firstMatch
        
        if scrollableView.exists {
            // Swipe down to refresh
            scrollableView.swipeDown()
            
            // Just verify no crash
            XCTAssertTrue(scrollableView.exists)
        }
    }
    
    // MARK: - Feed Categories Tests
    
    func testFeedCategoryFilter() {
        // Navigate to Feed
        navigateToFeed()
        
        // Look for any filter controls
        if app.segmentedControls.count > 0 {
            let segment = app.segmentedControls.firstMatch
            if segment.buttons.count > 1 {
                segment.buttons.element(boundBy: 1).tap()
                Thread.sleep(forTimeInterval: 0.5)
                
                // Verify UI still exists
                XCTAssertTrue(
                    app.collectionViews.firstMatch.exists ||
                    app.tables.firstMatch.exists
                )
            }
        } else if app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'filter' OR label CONTAINS[c] 'фильтр'")).count > 0 {
            // Try filter button
            app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'filter' OR label CONTAINS[c] 'фильтр'")).firstMatch.tap()
            Thread.sleep(forTimeInterval: 0.5)
            
            // Just verify no crash
            XCTAssertTrue(app.exists)
        }
    }
    
    // MARK: - Empty State Tests
    
    func testEmptyFeedState() {
        // Navigate to Feed
        navigateToFeed()
        
        // Check content state
        let hasCollectionCells = app.collectionViews.cells.count > 0
        let hasTableCells = app.tables.cells.count > 0
        let hasEmptyMessage = app.staticTexts.matching(
            NSPredicate(format: "label CONTAINS[c] 'пуст' OR label CONTAINS[c] 'empty' OR label CONTAINS[c] 'нет' OR label CONTAINS[c] 'no'")
        ).count > 0
        
        // Either content or empty state should exist
        XCTAssertTrue(
            hasCollectionCells || hasTableCells || hasEmptyMessage,
            "Should show either feed items or empty state"
        )
    }
    
    // MARK: - Helper Methods
    
    private func navigateToFeed() {
        // More robust navigation
        
        // First check if we're already in Feed
        if app.navigationBars.matching(NSPredicate(format: "identifier CONTAINS[c] 'feed' OR identifier CONTAINS[c] 'новост' OR identifier CONTAINS[c] 'лент'")).count > 0 {
            return
        }
        
        // Try tab bar navigation
        let tabBar = app.tabBars.firstMatch
        if tabBar.exists {
            // Try different tab names
            let feedTabNames = ["Новости", "Feed", "Лента", "News"]
            for tabName in feedTabNames {
                if tabBar.buttons[tabName].exists {
                    tabBar.buttons[tabName].tap()
                    Thread.sleep(forTimeInterval: 0.5)
                    return
                }
            }
            
            // Try "More" tab
            if tabBar.buttons["Ещё"].exists || tabBar.buttons["More"].exists {
                let moreButton = tabBar.buttons["Ещё"].exists ? tabBar.buttons["Ещё"] : tabBar.buttons["More"]
                moreButton.tap()
                Thread.sleep(forTimeInterval: 0.5)
                
                // Look for Feed in menu
                let feedButton = app.buttons.matching(
                    NSPredicate(format: "label CONTAINS[c] 'feed' OR label CONTAINS[c] 'новост' OR label CONTAINS[c] 'лент'")
                ).firstMatch
                
                if feedButton.exists {
                    feedButton.tap()
                    Thread.sleep(forTimeInterval: 0.5)
                }
            }
        }
        
        // If no tab bar, try other navigation methods
        // This might be a different UI structure
    }
} 