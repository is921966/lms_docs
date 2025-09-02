//
//  FeedChannelTests.swift
//  LMSUITests
//
//  Test for checking Feed channels content
//

import XCTest

final class FeedChannelTests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }
    
    override func tearDownWithError() throws {
        app = nil
    }
    
    func testReleasesChannelShowsMultiplePosts() throws {
        // Navigate to Feed tab
        let feedTab = app.tabBars.buttons["Новости"]
        XCTAssertTrue(feedTab.exists, "Feed tab should exist")
        feedTab.tap()
        
        // Wait for feed to load
        let feedList = app.scrollViews.firstMatch
        XCTAssertTrue(feedList.waitForExistence(timeout: 5), "Feed list should appear")
        
        // Find and tap on Releases channel
        let releasesChannel = app.scrollViews.descendants(matching: .any).matching(identifier: "channel-releases").firstMatch
        if !releasesChannel.exists {
            // Try finding by text
            let releasesText = app.staticTexts["Релизы и обновления"].firstMatch
            XCTAssertTrue(releasesText.exists, "Releases channel should exist")
            releasesText.tap()
        } else {
            releasesChannel.tap()
        }
        
        // Wait for channel detail to load
        sleep(2)
        
        // Count posts in the channel
        let posts = app.scrollViews.descendants(matching: .any).matching(identifier: "post-cell")
        let postsCount = posts.count
        
        print("🔍 Found \(postsCount) posts in Releases channel")
        
        // Take screenshot for debugging
        let screenshot = app.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = "Releases_Channel_Content"
        attachment.lifetime = .keepAlways
        add(attachment)
        
        // Assert we have more than 1 post
        XCTAssertGreaterThan(postsCount, 1, "Releases channel should have more than 1 post, but found \(postsCount)")
        
        // Try to count any visible text elements that look like posts
        let textElements = app.scrollViews.descendants(matching: .staticText)
        print("📝 Found \(textElements.count) text elements in view")
        
        // Log some text content for debugging
        for i in 0..<min(5, textElements.count) {
            let text = textElements.element(boundBy: i).label
            print("  Text \(i): \(text.prefix(50))...")
        }
    }
    
    func testSprintsChannelShowsMultiplePosts() throws {
        // Navigate to Feed tab
        let feedTab = app.tabBars.buttons["Новости"]
        XCTAssertTrue(feedTab.exists, "Feed tab should exist")
        feedTab.tap()
        
        // Wait for feed to load
        let feedList = app.scrollViews.firstMatch
        XCTAssertTrue(feedList.waitForExistence(timeout: 5), "Feed list should appear")
        
        // Find and tap on Sprints channel
        let sprintsText = app.staticTexts["Отчеты спринтов"].firstMatch
        if sprintsText.exists {
            sprintsText.tap()
        } else {
            // Try scrolling to find it
            feedList.swipeUp()
            sleep(1)
            let sprintsAfterScroll = app.staticTexts["Отчеты спринтов"].firstMatch
            XCTAssertTrue(sprintsAfterScroll.exists, "Sprints channel should exist")
            sprintsAfterScroll.tap()
        }
        
        // Wait for channel detail to load
        sleep(2)
        
        // Count any cells or list items
        let cells = app.cells.count
        let buttons = app.buttons.count
        let staticTexts = app.staticTexts.count
        
        print("🔍 Sprint channel content:")
        print("  - Cells: \(cells)")
        print("  - Buttons: \(buttons)")  
        print("  - Static texts: \(staticTexts)")
        
        // Take screenshot
        let screenshot = app.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = "Sprints_Channel_Content"
        attachment.lifetime = .keepAlways
        add(attachment)
        
        // We expect to see multiple items
        XCTAssertGreaterThan(staticTexts, 5, "Should have multiple text elements for posts")
    }
    
    func testChannelNavigationAndContent() throws {
        // Navigate to Feed
        app.tabBars.buttons["Новости"].tap()
        sleep(2)
        
        // Take initial screenshot
        let screenshot1 = app.screenshot()
        let attachment1 = XCTAttachment(screenshot: screenshot1)
        attachment1.name = "Feed_List"
        add(attachment1)
        
        // Debug: Print all visible elements
        print("\n🔍 FEED LIST ELEMENTS:")
        let allElements = app.descendants(matching: .any)
        for i in 0..<min(20, allElements.count) {
            let element = allElements.element(boundBy: i)
            if element.label != "" {
                print("  [\(element.elementType.rawValue)] \(element.label)")
            }
        }
        
        // Tap on first channel
        let firstChannel = app.scrollViews.descendants(matching: .staticText).element(boundBy: 2)
        if firstChannel.exists {
            print("\n📱 Tapping on: \(firstChannel.label)")
            firstChannel.tap()
            sleep(3)
            
            // Take screenshot of channel detail
            let screenshot2 = app.screenshot()
            let attachment2 = XCTAttachment(screenshot: screenshot2)
            attachment2.name = "Channel_Detail"
            add(attachment2)
            
            // Debug: Print channel content
            print("\n🔍 CHANNEL DETAIL ELEMENTS:")
            let channelElements = app.descendants(matching: .any)
            var postCount = 0
            for i in 0..<min(30, channelElements.count) {
                let element = channelElements.element(boundBy: i)
                if element.label != "" {
                    print("  [\(element.elementType.rawValue)] \(element.label.prefix(100))")
                    if element.label.contains("#release") || element.label.contains("#testflight") {
                        postCount += 1
                    }
                }
            }
            
            print("\n📊 Estimated posts found: \(postCount)")
            XCTAssertGreaterThan(postCount, 0, "Should find at least one post in channel")
        }
    }
} 