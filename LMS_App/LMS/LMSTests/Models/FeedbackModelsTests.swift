//
//  FeedbackModelsTests.swift
//  LMSTests
//
//  Created on 12/07/2025.
//

import XCTest
@testable import LMS

final class FeedbackModelsTests: XCTestCase {
    
    private var encoder: JSONEncoder!
    private var decoder: JSONDecoder!
    
    override func setUp() {
        super.setUp()
        encoder = JSONEncoder()
        decoder = JSONDecoder()
        encoder.dateEncodingStrategy = .iso8601
        decoder.dateDecodingStrategy = .iso8601
    }
    
    override func tearDown() {
        encoder = nil
        decoder = nil
        super.tearDown()
    }
    
    // MARK: - FeedbackItem Tests
    
    func testFeedbackItemInitialization() {
        // Given
        let item = FeedbackItem(
            title: "Test Feedback",
            description: "Test Description",
            type: .bug,
            author: "Test User",
            authorId: "user-123"
        )
        
        // Then
        XCTAssertNotNil(item.id)
        XCTAssertEqual(item.title, "Test Feedback")
        XCTAssertEqual(item.description, "Test Description")
        XCTAssertEqual(item.type, .bug)
        XCTAssertEqual(item.status, .open)
        XCTAssertEqual(item.author, "Test User")
        XCTAssertEqual(item.authorId, "user-123")
        XCTAssertNil(item.screenshot)
        XCTAssertEqual(item.reactions.like, 0)
        XCTAssertTrue(item.comments.isEmpty)
        XCTAssertNil(item.userReaction)
        XCTAssertFalse(item.isOwnFeedback)
    }
    
    func testFeedbackItemCodable() throws {
        // Given
        let originalItem = FeedbackItem(
            title: "Codable Test",
            description: "Testing encoding/decoding",
            type: .feature,
            status: .inProgress,
            author: "Coder",
            authorId: "coder-1",
            screenshot: "base64_screenshot_data",
            reactions: FeedbackReactions(like: 5, dislike: 1, heart: 3, fire: 2),
            comments: [
                FeedbackComment(text: "Great idea!", author: "User1", authorId: "user-1"),
                FeedbackComment(text: "Admin response", author: "Admin", authorId: "admin-1", isAdmin: true)
            ],
            userReaction: .heart,
            isOwnFeedback: true
        )
        
        // When
        let data = try encoder.encode(originalItem)
        let decodedItem = try decoder.decode(FeedbackItem.self, from: data)
        
        // Then
        XCTAssertEqual(decodedItem.id, originalItem.id)
        XCTAssertEqual(decodedItem.title, originalItem.title)
        XCTAssertEqual(decodedItem.description, originalItem.description)
        XCTAssertEqual(decodedItem.type, originalItem.type)
        XCTAssertEqual(decodedItem.status, originalItem.status)
        XCTAssertEqual(decodedItem.screenshot, originalItem.screenshot)
        XCTAssertEqual(decodedItem.reactions.like, originalItem.reactions.like)
        XCTAssertEqual(decodedItem.reactions.heart, originalItem.reactions.heart)
        XCTAssertEqual(decodedItem.comments.count, 2)
        XCTAssertEqual(decodedItem.userReaction, .heart)
        XCTAssertTrue(decodedItem.isOwnFeedback)
    }
    
    // MARK: - FeedbackStatus Tests
    
    func testFeedbackStatusProperties() {
        // Test all status cases
        XCTAssertEqual(FeedbackStatus.open.title, "Открыт")
        XCTAssertEqual(FeedbackStatus.inProgress.title, "В работе")
        XCTAssertEqual(FeedbackStatus.resolved.title, "Решён")
        XCTAssertEqual(FeedbackStatus.closed.title, "Закрыт")
        
        XCTAssertEqual(FeedbackStatus.open.color, "blue")
        XCTAssertEqual(FeedbackStatus.inProgress.color, "orange")
        XCTAssertEqual(FeedbackStatus.resolved.color, "green")
        XCTAssertEqual(FeedbackStatus.closed.color, "gray")
    }
    
    func testFeedbackStatusCodable() throws {
        // Given
        let statuses: [FeedbackStatus] = [.open, .inProgress, .resolved, .closed]
        
        // When/Then
        for status in statuses {
            let data = try encoder.encode(status)
            let decoded = try decoder.decode(FeedbackStatus.self, from: data)
            XCTAssertEqual(decoded, status)
        }
    }
    
    // MARK: - ReactionType Tests
    
    func testReactionTypeProperties() {
        // Test all reaction types
        XCTAssertEqual(ReactionType.like.emoji, "👍")
        XCTAssertEqual(ReactionType.dislike.emoji, "👎")
        XCTAssertEqual(ReactionType.heart.emoji, "❤️")
        XCTAssertEqual(ReactionType.fire.emoji, "🔥")
    }
    
    func testReactionTypeCodable() throws {
        // Given
        let reactions: [ReactionType] = [.like, .dislike, .heart, .fire]
        
        // When/Then
        for reaction in reactions {
            let data = try encoder.encode(reaction)
            let decoded = try decoder.decode(ReactionType.self, from: data)
            XCTAssertEqual(decoded, reaction)
        }
    }
    
    // MARK: - FeedbackReactions Tests
    
    func testFeedbackReactionsInitialization() {
        // Default initialization
        let reactions1 = FeedbackReactions()
        XCTAssertEqual(reactions1.like, 0)
        XCTAssertEqual(reactions1.dislike, 0)
        XCTAssertEqual(reactions1.heart, 0)
        XCTAssertEqual(reactions1.fire, 0)
        
        // Custom initialization
        let reactions2 = FeedbackReactions(like: 10, dislike: 2, heart: 5, fire: 3)
        XCTAssertEqual(reactions2.like, 10)
        XCTAssertEqual(reactions2.dislike, 2)
        XCTAssertEqual(reactions2.heart, 5)
        XCTAssertEqual(reactions2.fire, 3)
    }
    
    func testFeedbackReactionsCodable() throws {
        // Given
        let reactions = FeedbackReactions(like: 100, dislike: 5, heart: 50, fire: 25)
        
        // When
        let data = try encoder.encode(reactions)
        let decoded = try decoder.decode(FeedbackReactions.self, from: data)
        
        // Then
        XCTAssertEqual(decoded.like, reactions.like)
        XCTAssertEqual(decoded.dislike, reactions.dislike)
        XCTAssertEqual(decoded.heart, reactions.heart)
        XCTAssertEqual(decoded.fire, reactions.fire)
    }
    
    // MARK: - FeedbackComment Tests
    
    func testFeedbackCommentInitialization() {
        // Given
        let comment = FeedbackComment(
            text: "Test comment",
            author: "Commenter",
            authorId: "commenter-1"
        )
        
        // Then
        XCTAssertNotNil(comment.id)
        XCTAssertEqual(comment.text, "Test comment")
        XCTAssertEqual(comment.author, "Commenter")
        XCTAssertEqual(comment.authorId, "commenter-1")
        XCTAssertFalse(comment.isAdmin)
    }
    
    func testFeedbackCommentCodable() throws {
        // Given
        let comment = FeedbackComment(
            text: "Admin comment",
            author: "Admin User",
            authorId: "admin-123",
            isAdmin: true
        )
        
        // When
        let data = try encoder.encode(comment)
        let decoded = try decoder.decode(FeedbackComment.self, from: data)
        
        // Then
        XCTAssertEqual(decoded.id, comment.id)
        XCTAssertEqual(decoded.text, comment.text)
        XCTAssertEqual(decoded.author, comment.author)
        XCTAssertEqual(decoded.authorId, comment.authorId)
        XCTAssertTrue(decoded.isAdmin)
    }
    
    // MARK: - FeedbackType Tests
    
    func testFeedbackTypeProperties() {
        // Test all feedback types
        XCTAssertEqual(FeedbackType.bug.title, "Ошибка")
        XCTAssertEqual(FeedbackType.feature.title, "Предложение")
        XCTAssertEqual(FeedbackType.improvement.title, "Улучшение")
        XCTAssertEqual(FeedbackType.question.title, "Вопрос")
        
        XCTAssertEqual(FeedbackType.bug.icon, "ladybug")
        XCTAssertEqual(FeedbackType.feature.icon, "lightbulb")
        XCTAssertEqual(FeedbackType.improvement.icon, "wand.and.stars")
        XCTAssertEqual(FeedbackType.question.icon, "questionmark.circle")
        
        XCTAssertEqual(FeedbackType.bug.githubLabel, "bug")
        XCTAssertEqual(FeedbackType.feature.githubLabel, "enhancement")
        XCTAssertEqual(FeedbackType.improvement.githubLabel, "improvement")
        XCTAssertEqual(FeedbackType.question.githubLabel, "question")
        
        XCTAssertEqual(FeedbackType.bug.emoji, "🐛")
        XCTAssertEqual(FeedbackType.feature.emoji, "💡")
        XCTAssertEqual(FeedbackType.improvement.emoji, "✨")
        XCTAssertEqual(FeedbackType.question.emoji, "❓")
    }
    
    func testFeedbackTypeCodable() throws {
        // Given
        let types: [FeedbackType] = [.bug, .feature, .improvement, .question]
        
        // When/Then
        for type in types {
            let data = try encoder.encode(type)
            let decoded = try decoder.decode(FeedbackType.self, from: data)
            XCTAssertEqual(decoded, type)
        }
    }
    
    // MARK: - FeedbackModel Tests
    
    func testFeedbackModelInitialization() {
        // Given
        let deviceInfo = DeviceInfo(
            model: "iPhone",
            osVersion: "18.0",
            appVersion: "1.0",
            buildNumber: "100",
            locale: "en_US",
            screenSize: "390x844"
        )
        
        let model = FeedbackModel(
            type: "bug",
            text: "App crashes on launch",
            screenshot: "base64_data",
            deviceInfo: deviceInfo,
            userId: "user-456",
            userEmail: "user@example.com"
        )
        
        // Then
        XCTAssertNotNil(model.id)
        XCTAssertEqual(model.type, "bug")
        XCTAssertEqual(model.text, "App crashes on launch")
        XCTAssertEqual(model.screenshot, "base64_data")
        XCTAssertEqual(model.userId, "user-456")
        XCTAssertEqual(model.userEmail, "user@example.com")
        XCTAssertNil(model.appContext)
    }
    
    func testFeedbackModelCodable() throws {
        // Given
        let deviceInfo = DeviceInfo(
            model: "iPad",
            osVersion: "17.0",
            appVersion: "1.1",
            buildNumber: "110",
            locale: "ru_RU",
            screenSize: "1024x768"
        )
        
        let appContext = AppContext(
            currentScreen: "HomeView",
            previousScreen: "LoginView",
            sessionDuration: 300,
            memoryUsage: 1024000,
            batteryLevel: 0.75
        )
        
        let model = FeedbackModel(
            type: "feature",
            text: "Add dark mode",
            deviceInfo: deviceInfo,
            appContext: appContext
        )
        
        // When
        let data = try encoder.encode(model)
        let decoded = try decoder.decode(FeedbackModel.self, from: data)
        
        // Then
        XCTAssertEqual(decoded.id, model.id)
        XCTAssertEqual(decoded.type, model.type)
        XCTAssertEqual(decoded.text, model.text)
        XCTAssertEqual(decoded.deviceInfo.model, deviceInfo.model)
        XCTAssertEqual(decoded.appContext?.currentScreen, "HomeView")
        XCTAssertEqual(decoded.appContext?.batteryLevel, 0.75)
    }
    
    // MARK: - DeviceInfo Tests
    
    func testDeviceInfoCodable() throws {
        // Given
        let deviceInfo = DeviceInfo(
            model: "iPhone 15 Pro",
            osVersion: "18.5",
            appVersion: "2.0.0",
            buildNumber: "2024",
            locale: "en_GB",
            screenSize: "430x932"
        )
        
        // When
        let data = try encoder.encode(deviceInfo)
        let decoded = try decoder.decode(DeviceInfo.self, from: data)
        
        // Then
        XCTAssertEqual(decoded.model, deviceInfo.model)
        XCTAssertEqual(decoded.osVersion, deviceInfo.osVersion)
        XCTAssertEqual(decoded.appVersion, deviceInfo.appVersion)
        XCTAssertEqual(decoded.buildNumber, deviceInfo.buildNumber)
        XCTAssertEqual(decoded.locale, deviceInfo.locale)
        XCTAssertEqual(decoded.screenSize, deviceInfo.screenSize)
    }
    
    // MARK: - AppContext Tests
    
    func testAppContextCodable() throws {
        // Given
        let context = AppContext(
            currentScreen: "SettingsView",
            previousScreen: "ProfileView",
            sessionDuration: 1800.5,
            memoryUsage: 2048000,
            batteryLevel: 0.5
        )
        
        // When
        let data = try encoder.encode(context)
        let decoded = try decoder.decode(AppContext.self, from: data)
        
        // Then
        XCTAssertEqual(decoded.currentScreen, context.currentScreen)
        XCTAssertEqual(decoded.previousScreen, context.previousScreen)
        XCTAssertEqual(decoded.sessionDuration, context.sessionDuration)
        XCTAssertEqual(decoded.memoryUsage, context.memoryUsage)
        XCTAssertEqual(decoded.batteryLevel, context.batteryLevel)
    }
    
    func testAppContextWithNilValues() throws {
        // Given
        let context = AppContext(
            currentScreen: nil,
            previousScreen: nil,
            sessionDuration: nil,
            memoryUsage: nil,
            batteryLevel: nil
        )
        
        // When
        let data = try encoder.encode(context)
        let decoded = try decoder.decode(AppContext.self, from: data)
        
        // Then
        XCTAssertNil(decoded.currentScreen)
        XCTAssertNil(decoded.previousScreen)
        XCTAssertNil(decoded.sessionDuration)
        XCTAssertNil(decoded.memoryUsage)
        XCTAssertNil(decoded.batteryLevel)
    }
    
    // MARK: - Edge Cases
    
    func testEmptyFeedbackText() {
        // Given
        let item = FeedbackItem(
            title: "",
            description: "",
            type: .question,
            author: "Empty Author",
            authorId: "empty-1"
        )
        
        // Then
        XCTAssertEqual(item.title, "")
        XCTAssertEqual(item.description, "")
    }
    
    func testVeryLongFeedbackText() {
        // Given
        let longText = String(repeating: "Lorem ipsum ", count: 1000)
        let item = FeedbackItem(
            title: longText,
            description: longText,
            type: .improvement,
            author: "Long Author",
            authorId: "long-1"
        )
        
        // Then
        XCTAssertEqual(item.title, longText)
        XCTAssertEqual(item.description, longText)
    }
    
    func testFeedbackItemWithManyComments() {
        // Given
        var comments: [FeedbackComment] = []
        for i in 1...100 {
            comments.append(FeedbackComment(
                text: "Comment \(i)",
                author: "User \(i)",
                authorId: "user-\(i)"
            ))
        }
        
        let item = FeedbackItem(
            title: "Many Comments",
            description: "Item with many comments",
            type: .bug,
            author: "Author",
            authorId: "author-1",
            comments: comments
        )
        
        // Then
        XCTAssertEqual(item.comments.count, 100)
    }
} 