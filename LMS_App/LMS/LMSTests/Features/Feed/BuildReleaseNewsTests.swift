//
//  BuildReleaseNewsTests.swift
//  LMSTests
//
//  Тесты для модели новостей о релизах
//

import XCTest
@testable import LMS

class BuildReleaseNewsTests: XCTestCase {
    
    // MARK: - Test Data
    
    let sampleReleaseNotes = """
    # TestFlight Release v2.1.1
    
    **Build**: 206
    
    ## 🎯 Основные изменения
    
    ### ✅ Исправлена тестовая инфраструктура
    - Удалены дубликаты файлов тестов
    - Исправлены все ошибки компиляции UI тестов
    - Обновлена инфраструктура для 43 UI тестов
    
    ### 🔧 Технические улучшения
    - Оптимизирована навигация в тестах
    - Добавлена поддержка разных UI структур
    
    ## 📋 Что нового для тестировщиков
    
    ### Проверьте следующие функции:
    - Отображение списка новостей
    - Навигация между новостями
    
    ## 🐛 Известные проблемы
    - Некоторые UI тесты могут показывать предупреждения
    """
    
    // MARK: - Tests
    
    func testBuildReleaseNewsCreation() {
        // Given
        let version = "2.1.1"
        let buildNumber = "206"
        
        // When
        let releaseNews = BuildReleaseNews.fromReleaseNotes(
            version: version,
            buildNumber: buildNumber,
            releaseNotesContent: sampleReleaseNotes
        )
        
        // Then
        XCTAssertEqual(releaseNews.version, version)
        XCTAssertEqual(releaseNews.buildNumber, buildNumber)
        XCTAssertNotNil(releaseNews.id)
        XCTAssertTrue(releaseNews.mainChanges.count > 0)
    }
    
    func testReleaseNotesParser() {
        // Given
        let parser = ReleaseNotesParser()
        
        // When
        let parsedData = parser.parse(sampleReleaseNotes)
        
        // Then
        XCTAssertEqual(parsedData.changes.count, 2, "Should parse 2 change categories")
        
        // Check first category
        let firstCategory = parsedData.changes[0]
        XCTAssertEqual(firstCategory.title, "Исправлена тестовая инфраструктура")
        XCTAssertEqual(firstCategory.icon, "✅")
        XCTAssertEqual(firstCategory.changes.count, 3)
        
        // Check testing focus
        XCTAssertEqual(parsedData.testingFocus.count, 2)
        XCTAssertTrue(parsedData.testingFocus.contains("Отображение списка новостей"))
        
        // Check known issues
        XCTAssertEqual(parsedData.knownIssues.count, 1)
    }
    
    func testToFeedItemConversion() {
        // Given
        let releaseNews = BuildReleaseNews.fromReleaseNotes(
            version: "2.1.1",
            buildNumber: "206",
            releaseNotesContent: sampleReleaseNotes
        )
        
        // When
        let feedItem = releaseNews.toFeedItem()
        
        // Then
        XCTAssertEqual(feedItem.type, .announcement)
        XCTAssertEqual(feedItem.title, "Доступна новая версия 2.1.1")
        XCTAssertEqual(feedItem.author, "Команда разработки")
        XCTAssertEqual(feedItem.priority, .high)
        XCTAssertTrue(feedItem.tags.contains("release"))
        XCTAssertTrue(feedItem.tags.contains("testflight"))
        
        // Check metadata
        XCTAssertEqual(feedItem.metadata["version"], "2.1.1")
        XCTAssertEqual(feedItem.metadata["build"], "206")
        XCTAssertEqual(feedItem.metadata["type"], "app_release")
        
        // Check content contains parsed data
        XCTAssertTrue(feedItem.content.contains("🚀 Новая версия"))
        XCTAssertTrue(feedItem.content.contains("Исправлена тестовая инфраструктура"))
    }
    
    func testEmptyReleaseNotes() {
        // Given
        let emptyNotes = ""
        
        // When
        let releaseNews = BuildReleaseNews.fromReleaseNotes(
            version: "1.0.0",
            buildNumber: "1",
            releaseNotesContent: emptyNotes
        )
        
        // Then
        XCTAssertEqual(releaseNews.version, "1.0.0")
        XCTAssertEqual(releaseNews.buildNumber, "1")
        XCTAssertEqual(releaseNews.mainChanges.count, 0)
        XCTAssertEqual(releaseNews.testingFocus.count, 0)
        XCTAssertEqual(releaseNews.knownIssues.count, 0)
    }
    
    func testParserWithDifferentFormats() {
        // Given
        let parser = ReleaseNotesParser()
        let alternativeNotes = """
        ### 🚀 New Features
        - Feature 1
        - Feature 2
        
        ## Testing Focus
        • Test this
        • Test that
        
        ## Known Issues
        - Issue 1
        """
        
        // When
        let parsedData = parser.parse(alternativeNotes)
        
        // Then
        XCTAssertEqual(parsedData.changes.count, 1)
        XCTAssertEqual(parsedData.changes[0].icon, "🚀")
        XCTAssertEqual(parsedData.testingFocus.count, 2)
        XCTAssertEqual(parsedData.knownIssues.count, 1)
    }
} 