//
//  RealDataFeedServiceTests.swift
//  LMSTests
//
//  TDD тесты для RealDataFeedService
//

import XCTest
@testable import LMS

class RealDataFeedServiceTests: XCTestCase {
    
    var service: RealDataFeedService!
    
    override func setUp() {
        super.setUp()
        service = RealDataFeedService()
        ComprehensiveLogger.shared.log(.test, .info, "Starting RealDataFeedServiceTests")
    }
    
    override func tearDown() {
        service = nil
        super.tearDown()
    }
    
    // MARK: - Test: Загружает все release notes, не только последние 10
    
    func test_loadsAllReleaseNotes_notJustLast10() async {
        // Given
        let expectation = expectation(description: "Load all release notes")
        
        // When
        let posts = await service.loadReleaseNotes()
        
        // Then
        XCTAssertTrue(posts.count > 10 || posts.count == getAllReleaseFiles().count,
                     "Should load all release notes, not limited to 10")
        
        // Проверяем что загружены файлы из разных версий
        let versions = Set(posts.compactMap { post in
            post.metadata?["version"] as? String
        })
        XCTAssertTrue(versions.count > 5 || versions.count == posts.count,
                     "Should include releases from multiple versions")
        
        expectation.fulfill()
        await fulfillment(of: [expectation], timeout: 5.0)
    }
    
    // MARK: - Test: Загружает все sprint отчеты
    
    func test_loadsAllSprintReports() async {
        // Given
        let expectation = expectation(description: "Load all sprint reports")
        
        // When
        let posts = await service.loadSprintReports()
        
        // Then
        XCTAssertTrue(posts.count > 10 || posts.count == getAllSprintFiles().count,
                     "Should load all sprint reports, not limited to 10")
        
        // Проверяем что есть отчеты из разных спринтов
        let sprintNumbers = posts.compactMap { post -> Int? in
            guard let title = post.metadata?["title"] as? String else { return nil }
            // Извлекаем номер спринта из заголовка
            let pattern = #"Sprint (\d+)"#
            if let regex = try? NSRegularExpression(pattern: pattern),
               let match = regex.firstMatch(in: title, range: NSRange(title.startIndex..., in: title)),
               let numberRange = Range(match.range(at: 1), in: title) {
                return Int(title[numberRange])
            }
            return nil
        }
        
        XCTAssertTrue(sprintNumbers.count > 5,
                     "Should include reports from multiple sprints")
        
        expectation.fulfill()
        await fulfillment(of: [expectation], timeout: 5.0)
    }
    
    // MARK: - Test: Загружает все обновления методологии
    
    func test_loadsAllMethodologyUpdates() async {
        // Given
        let expectation = expectation(description: "Load all methodology updates")
        
        // When
        let posts = await service.loadMethodologyUpdates()
        
        // Then
        // Методология обновляется реже, поэтому может быть меньше 10 файлов
        XCTAssertTrue(posts.count >= 1,
                     "Should load at least one methodology update")
        
        // Проверяем что загружены все найденные файлы методологии
        let methodologyFiles = getAllMethodologyFiles()
        XCTAssertEqual(posts.count, methodologyFiles.count,
                      "Should load all methodology files found")
        
        expectation.fulfill()
        await fulfillment(of: [expectation], timeout: 5.0)
    }
    
    // MARK: - Test: Сортирует посты по дате (новые первые)
    
    func test_sortsPostsByDateDescending() async {
        // Given
        let expectation = expectation(description: "Posts sorted by date")
        
        // When
        let posts = await service.loadReleaseNotes()
        
        // Then
        guard posts.count > 1 else {
            XCTFail("Need at least 2 posts to test sorting")
            return
        }
        
        // Проверяем что посты отсортированы по убыванию даты
        for i in 0..<(posts.count - 1) {
            let currentDate = posts[i].createdAt
            let nextDate = posts[i + 1].createdAt
            
            XCTAssertTrue(currentDate >= nextDate,
                         "Posts should be sorted by date in descending order")
        }
        
        expectation.fulfill()
        await fulfillment(of: [expectation], timeout: 5.0)
    }
    
    // MARK: - Helper Methods
    
    private func getAllReleaseFiles() -> [String] {
        let fileManager = FileManager.default
        let docsPath = "/Users/ishirokov/lms_docs/docs/releases"
        
        do {
            let files = try fileManager.contentsOfDirectory(atPath: docsPath)
            return files.filter { $0.hasSuffix(".md") }
        } catch {
            return []
        }
    }
    
    private func getAllSprintFiles() -> [String] {
        let fileManager = FileManager.default
        let reportsPath = "/Users/ishirokov/lms_docs/reports/sprints"
        
        do {
            let files = try fileManager.contentsOfDirectory(atPath: reportsPath)
            return files.filter { 
                $0.contains("COMPLETION_REPORT") && $0.hasSuffix(".md")
            }
        } catch {
            return []
        }
    }
    
    private func getAllMethodologyFiles() -> [String] {
        let fileManager = FileManager.default
        let methodologyPath = "/Users/ishirokov/lms_docs/reports/methodology"
        
        do {
            let files = try fileManager.contentsOfDirectory(atPath: methodologyPath)
            return files.filter { $0.hasSuffix(".md") }
        } catch {
            return []
        }
    }
} 