//
//  ReleaseNewsUITests.swift
//  LMSUITests
//
//  UI тесты для функциональности новостей о релизах
//

import XCTest

class ReleaseNewsUITests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["UI_TESTING", "SIMULATE_NEW_RELEASE"]
        app.launch()
        
        // Wait for app to load
        _ = app.wait(for: .runningForeground, timeout: 5)
    }
    
    // MARK: - Tests
    
    func testReleaseAlertAppearsOnNewVersion() {
        // Given - app launched with SIMULATE_NEW_RELEASE flag
        
        // Then - alert should appear
        let alert = app.alerts["🎉 Новая версия!"]
        XCTAssertTrue(alert.waitForExistence(timeout: 5), "Release alert should appear")
        
        // Verify alert content
        XCTAssertTrue(alert.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] 'Доступна версия'")).count > 0)
        
        // Verify buttons
        XCTAssertTrue(alert.buttons["Посмотреть"].exists)
        XCTAssertTrue(alert.buttons["Позже"].exists)
    }
    
    func testNavigateToFeedFromAlert() {
        // Given
        let alert = app.alerts["🎉 Новая версия!"]
        _ = alert.waitForExistence(timeout: 5)
        
        // When
        alert.buttons["Посмотреть"].tap()
        
        // Then - should navigate to feed
        Thread.sleep(forTimeInterval: 1.0)
        
        let feedNavBar = app.navigationBars.matching(
            NSPredicate(format: "identifier CONTAINS[c] 'feed' OR identifier CONTAINS[c] 'новост' OR identifier CONTAINS[c] 'лент'")
        ).firstMatch
        
        XCTAssertTrue(feedNavBar.exists || app.staticTexts["Лента новостей"].exists, "Should navigate to feed")
    }
    
    func testReleaseNewsInFeed() {
        // Given - dismiss alert first
        if app.alerts.firstMatch.exists {
            app.alerts.buttons["Позже"].tap()
        }
        
        // Navigate to feed
        navigateToFeed()
        
        // Then - release news should be at top
        let firstCell = app.collectionViews.cells.firstMatch.exists ?
                       app.collectionViews.cells.firstMatch :
                       app.tables.cells.firstMatch
        
        if firstCell.waitForExistence(timeout: 5) {
            // Check for release indicators
            let hasReleaseContent = firstCell.staticTexts.matching(
                NSPredicate(format: "label CONTAINS[c] 'версия' OR label CONTAINS[c] 'version' OR label CONTAINS[c] 'build'")
            ).count > 0
            
            XCTAssertTrue(hasReleaseContent, "First feed item should be release news")
        }
    }
    
    func testReleaseNewsContent() {
        // Given - navigate to feed
        if app.alerts.firstMatch.exists {
            app.alerts.buttons["Позже"].tap()
        }
        navigateToFeed()
        
        // Open first item (should be release news)
        let firstCell = app.collectionViews.cells.firstMatch.exists ?
                       app.collectionViews.cells.firstMatch :
                       app.tables.cells.firstMatch
        
        if firstCell.waitForExistence(timeout: 5) {
            firstCell.tap()
            Thread.sleep(forTimeInterval: 1.0)
            
            // Verify content
            let contentTexts = app.scrollViews.staticTexts
            
            // Should contain version info
            XCTAssertTrue(
                contentTexts.matching(NSPredicate(format: "label CONTAINS[c] '2.1.1' OR label CONTAINS[c] '206'")).count > 0,
                "Should show version and build number"
            )
            
            // Should contain change categories
            XCTAssertTrue(
                contentTexts.matching(NSPredicate(format: "label CONTAINS[c] 'изменен' OR label CONTAINS[c] 'улучшен'")).count > 0,
                "Should show changes"
            )
        }
    }
    
    func testDebugMenuReleaseNews() {
        // Given - dismiss alert
        if app.alerts.firstMatch.exists {
            app.alerts.buttons["Позже"].tap()
        }
        
        // Navigate to debug menu
        navigateToDebugMenu()
        
        // Find Release News Testing section
        let releaseSection = app.tables.cells.matching(
            NSPredicate(format: "label CONTAINS[c] 'Release News Testing'")
        ).firstMatch
        
        if releaseSection.exists {
            // Test simulate button
            let simulateButton = app.buttons["Simulate New Release"]
            if simulateButton.exists {
                simulateButton.tap()
                Thread.sleep(forTimeInterval: 1.0)
                
                // Should trigger alert again
                let alert = app.alerts["🎉 Новая версия!"]
                XCTAssertTrue(alert.waitForExistence(timeout: 3), "Should show alert after simulation")
                alert.buttons["Позже"].tap()
            }
        }
    }
    
    func testVersionInfoInSettings() {
        // Given - dismiss alert
        if app.alerts.firstMatch.exists {
            app.alerts.buttons["Позже"].tap()
        }
        
        // Navigate to settings
        navigateToSettings()
        
        // Find version section
        let versionCell = app.tables.cells.containing(.staticText, identifier: "Версия").firstMatch
        if versionCell.exists {
            // Should show version number
            XCTAssertTrue(
                versionCell.staticTexts.matching(NSPredicate(format: "label MATCHES '\\d+\\.\\d+\\.\\d+'")).count > 0,
                "Should show version number"
            )
        }
        
        // Test "What's New" button
        let whatsNewButton = app.buttons["Что нового"]
        if whatsNewButton.exists {
            whatsNewButton.tap()
            Thread.sleep(forTimeInterval: 1.0)
            
            // Should show release notes
            XCTAssertTrue(
                app.navigationBars["Release Notes"].exists ||
                app.scrollViews.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] 'release'")).count > 0,
                "Should show release notes"
            )
        }
    }
    
    // MARK: - Helper Methods
    
    private func navigateToFeed() {
        let tabBar = app.tabBars.firstMatch
        if tabBar.exists {
            let feedTabs = ["Новости", "Feed", "Лента", "News"]
            for tab in feedTabs {
                if tabBar.buttons[tab].exists {
                    tabBar.buttons[tab].tap()
                    Thread.sleep(forTimeInterval: 0.5)
                    return
                }
            }
            
            // Try through More
            if tabBar.buttons["Ещё"].exists || tabBar.buttons["More"].exists {
                let moreButton = tabBar.buttons["Ещё"].exists ? tabBar.buttons["Ещё"] : tabBar.buttons["More"]
                moreButton.tap()
                Thread.sleep(forTimeInterval: 0.5)
                
                let feedButton = app.buttons.matching(
                    NSPredicate(format: "label CONTAINS[c] 'feed' OR label CONTAINS[c] 'новост' OR label CONTAINS[c] 'лент'")
                ).firstMatch
                
                if feedButton.exists {
                    feedButton.tap()
                }
            }
        }
    }
    
    private func navigateToDebugMenu() {
        // Navigate to settings/debug
        let tabBar = app.tabBars.firstMatch
        if tabBar.exists {
            if tabBar.buttons["Ещё"].exists {
                tabBar.buttons["Ещё"].tap()
            } else if tabBar.buttons["More"].exists {
                tabBar.buttons["More"].tap()
            }
        }
        
        // Look for debug menu
        let debugButton = app.buttons["Debug Menu"]
        if debugButton.waitForExistence(timeout: 3) {
            debugButton.tap()
        }
    }
    
    private func navigateToSettings() {
        let tabBar = app.tabBars.firstMatch
        if tabBar.exists {
            if tabBar.buttons["Ещё"].exists {
                tabBar.buttons["Ещё"].tap()
            } else if tabBar.buttons["More"].exists {
                tabBar.buttons["More"].tap()
            }
        }
        
        let settingsButton = app.buttons["Настройки"].exists ? app.buttons["Настройки"] : app.buttons["Settings"]
        if settingsButton.exists {
            settingsButton.tap()
        }
    }
} 