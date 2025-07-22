//
//  HTMLContentViewTests.swift
//  LMSTests
//
//  Тесты для проверки HTML рендеринга в ленте новостей
//

import XCTest
import SwiftUI
@testable import LMS

class HTMLContentViewTests: XCTestCase {
    
    // MARK: - HTML Content Generation Tests
    
    func testBuildReleaseNewsGeneratesHTML() {
        // Given
        let releaseNews = BuildReleaseNews(
            id: UUID(),
            version: "2.1.1",
            buildNumber: "206",
            releaseDate: Date(),
            mainChanges: [
                BuildReleaseNews.ChangeCategory(
                    title: "Новые функции",
                    icon: "✨",
                    changes: ["Функция 1", "Функция 2"]
                )
            ],
            testingFocus: ["Проверить стабильность"],
            knownIssues: ["Известная проблема"],
            technicalInfo: BuildReleaseNews.TechnicalInfo(
                minIOSVersion: "17.0",
                recommendedIOSVersion: "18.5",
                appSize: "45 MB"
            )
        )
        
        // When
        let feedItem = releaseNews.toFeedItem()
        
        // Then
        XCTAssertTrue(feedItem.content.contains("<div"))
        XCTAssertTrue(feedItem.content.contains("<h1"))
        XCTAssertTrue(feedItem.content.contains("<ul"))
        XCTAssertTrue(feedItem.content.contains("2.1.1"))
        XCTAssertTrue(feedItem.content.contains("Build 206"))
        XCTAssertEqual(feedItem.metadata["contentType"], "html")
        XCTAssertEqual(feedItem.metadata["type"], "app_release")
    }
    
    func testReleaseNotesParserExtractsData() {
        // Given
        let parser = ReleaseNotesParser()
        let markdownContent = """
        ### ✅ Исправления
        - Исправлена ошибка 1
        - Исправлена ошибка 2
        
        ## Что протестировать
        - Функцию A
        - Функцию B
        
        ## Известные проблемы
        - Проблема 1
        """
        
        // When
        let parsedData = parser.parse(markdownContent)
        
        // Then
        XCTAssertEqual(parsedData.changes.count, 1)
        XCTAssertEqual(parsedData.changes.first?.title, "Исправления")
        XCTAssertEqual(parsedData.changes.first?.icon, "✅")
        XCTAssertEqual(parsedData.changes.first?.changes.count, 2)
        XCTAssertEqual(parsedData.testingFocus.count, 2)
        XCTAssertEqual(parsedData.knownIssues.count, 1)
    }
    
    // MARK: - FeedPost HTML Detection Tests
    
    func testFeedPostDetectsHTMLContent() {
        // Given
        let htmlPost = FeedPost(
            id: "1",
            author: UserResponse(
                id: "test",
                email: "test@test.com",
                name: "Test",
                role: .admin,
                isActive: true,
                createdAt: Date()
            ),
            content: "<div>HTML Content</div>",
            images: [],
            attachments: [],
            createdAt: Date(),
            visibility: .everyone,
            likes: [],
            comments: [],
            tags: ["release"],
            mentions: [],
            metadata: ["contentType": "html", "type": "app_release"]
        )
        
        // When/Then
        let postContentView = PostContentView(post: htmlPost)
        XCTAssertNotNil(postContentView)
    }
    
    func testMockFeedItemHasHTMLContent() {
        // Given
        let mockItems = FeedItem.mockItems
        
        // When
        let releaseItem = mockItems.first { $0.type == .announcement }
        
        // Then
        XCTAssertNotNil(releaseItem)
        XCTAssertTrue(releaseItem!.content.contains("<div"))
        XCTAssertEqual(releaseItem!.metadata["contentType"], "html")
        XCTAssertEqual(releaseItem!.metadata["type"], "app_release")
    }
    
    // MARK: - ReleaseNewsService Tests
    
    func testReleaseNewsServiceGeneratesHTMLContent() {
        // Given
        let service = ReleaseNewsService.shared
        
        // When
        let defaultNotes = service.getCurrentReleaseNotes()
        
        // Then
        XCTAssertTrue(defaultNotes.contains("<div"))
        XCTAssertTrue(defaultNotes.contains("<h1"))
        XCTAssertTrue(defaultNotes.contains("TestFlight Release"))
    }
} 