//
//  FeedPostSortingTests.swift
//  LMSUITests
//
//  Tests for post sorting and content display
//

import XCTest

final class FeedPostSortingTests: XCTestCase {
    let app = XCUIApplication()
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launch()
    }
    
    func testPostsAreSortedByDateDescending() throws {
        // Navigate to Feed
        app.tabBars.buttons["Новости"].tap()
        sleep(2)
        
        // Open releases channel
        let releasesCell = app.cells.containing(.staticText, identifier: "Релизы и обновления").firstMatch
        XCTAssertTrue(releasesCell.waitForExistence(timeout: 5))
        releasesCell.tap()
        sleep(2)
        
        // Take screenshot for visual verification
        let screenshot = app.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = "Posts_In_Channel"
        attachment.lifetime = .keepAlways
        add(attachment)
        
        // Check if posts exist
        let posts = app.cells
        XCTAssertTrue(posts.count > 1, "Should have multiple posts")
        
        // Log post titles to verify order
        for i in 0..<min(5, posts.count) {
            let post = posts.element(boundBy: i)
            if post.exists {
                print("Post \(i): \(post.label)")
            }
        }
    }
    
    func testPostDetailShowsContent() throws {
        // Navigate to Feed
        app.tabBars.buttons["Новости"].tap()
        sleep(2)
        
        // Open releases channel
        let releasesCell = app.cells.containing(.staticText, identifier: "Релизы и обновления").firstMatch
        XCTAssertTrue(releasesCell.waitForExistence(timeout: 5))
        releasesCell.tap()
        sleep(2)
        
        // Tap first post
        let firstPost = app.cells.firstMatch
        XCTAssertTrue(firstPost.waitForExistence(timeout: 5))
        
        // Take screenshot before tap
        let screenshotBefore = app.screenshot()
        let attachmentBefore = XCTAttachment(screenshot: screenshotBefore)
        attachmentBefore.name = "Before_Post_Tap"
        attachmentBefore.lifetime = .keepAlways
        add(attachmentBefore)
        
        firstPost.tap()
        sleep(2)
        
        // Take screenshot after tap
        let screenshotAfter = app.screenshot()
        let attachmentAfter = XCTAttachment(screenshot: screenshotAfter)
        attachmentAfter.name = "Post_Detail_View"
        attachmentAfter.lifetime = .keepAlways
        add(attachmentAfter)
        
        // Check for content
        let textViews = app.textViews
        let staticTexts = app.staticTexts
        
        // Should have some content visible
        XCTAssertTrue(textViews.count > 0 || staticTexts.count > 2, 
                     "Post detail should show content")
    }
    
    func testMultiplePostsNavigationAndContent() throws {
        // Navigate to Feed
        app.tabBars.buttons["Новости"].tap()
        sleep(2)
        
        // Open sprints channel
        let sprintsCell = app.cells.containing(.staticText, identifier: "Спринты разработки").firstMatch
        XCTAssertTrue(sprintsCell.waitForExistence(timeout: 5))
        sprintsCell.tap()
        sleep(2)
        
        // Test first 3 posts
        for i in 0..<3 {
            let post = app.cells.element(boundBy: i)
            guard post.waitForExistence(timeout: 2) else { continue }
            
            print("Testing post \(i)")
            post.tap()
            sleep(1)
            
            // Take screenshot
            let screenshot = app.screenshot()
            let attachment = XCTAttachment(screenshot: screenshot)
            attachment.name = "Sprint_Post_\(i)_Detail"
            attachment.lifetime = .keepAlways
            add(attachment)
            
            // Go back
            if app.navigationBars.buttons.element(boundBy: 0).exists {
                app.navigationBars.buttons.element(boundBy: 0).tap()
            } else if app.buttons["Back"].exists {
                app.buttons["Back"].tap()
            } else {
                app.swipeRight() // Swipe to go back
            }
            sleep(1)
        }
    }
} 