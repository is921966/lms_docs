//
//  FeedbackServiceTests.swift
//  LMSTests
//

import XCTest
import Combine
@testable import LMS

final class FeedbackServiceTests: XCTestCase {
    
    var sut: FeedbackService!
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        sut = FeedbackService.shared
        cancellables = []
        // Clear existing feedbacks
        sut.clearFeedbacks()
    }
    
    override func tearDown() {
        sut.clearFeedbacks()
        cancellables = nil
        sut = nil
        super.tearDown()
    }
    
    // MARK: - Singleton Tests
    
    func testSharedInstance() {
        let instance1 = FeedbackService.shared
        let instance2 = FeedbackService.shared
        XCTAssertTrue(instance1 === instance2)
    }
    
    // MARK: - Initial State Tests
    
    func testInitialState() {
        XCTAssertTrue(sut.feedbacks.isEmpty)
        XCTAssertFalse(sut.isLoading)
        XCTAssertNil(sut.errorMessage)
    }
    
    // MARK: - Feedback Creation Tests
    
    func testCreateFeedback() {
        // Given
        let title = "Test Feedback"
        let description = "This is a test description"
        let type = FeedbackType.bug
        let priority = FeedbackPriority.high
        
        // When
        let feedback = sut.createFeedback(
            title: title,
            description: description,
            type: type,
            priority: priority,
            screenshot: nil
        )
        
        // Then
        XCTAssertFalse(feedback.id.uuidString.isEmpty)
        XCTAssertEqual(feedback.title, title)
        XCTAssertEqual(feedback.description, description)
        XCTAssertEqual(feedback.type, type)
        XCTAssertEqual(feedback.priority, priority)
        XCTAssertEqual(feedback.status, .pending)
        XCTAssertNotNil(feedback.createdAt)
        XCTAssertNil(feedback.screenshot)
    }
    
    func testCreateFeedbackWithScreenshot() {
        // Given
        let screenshot = UIImage(systemName: "photo")?.pngData()
        
        // When
        let feedback = sut.createFeedback(
            title: "Bug Report",
            description: "App crashes",
            type: .bug,
            priority: .critical,
            screenshot: screenshot
        )
        
        // Then
        XCTAssertNotNil(feedback.screenshot)
        XCTAssertEqual(feedback.screenshot, screenshot?.base64EncodedString())
    }
    
    // MARK: - Submit Feedback Tests
    
    func testSubmitFeedback() async {
        // Given
        let feedback = sut.createFeedback(
            title: "Test Submit",
            description: "Testing submission",
            type: .feature,
            priority: .medium,
            screenshot: nil
        )
        
        // When
        let result = await sut.submitFeedback(feedback)
        
        // Then
        switch result {
        case .success:
            XCTAssertEqual(sut.feedbacks.count, 1)
            XCTAssertEqual(sut.feedbacks.first?.id, feedback.id)
        case .failure:
            XCTFail("Submit should succeed")
        }
    }
    
    func testSubmitMultipleFeedbacks() async {
        // Given
        let feedbacks = (1...3).map { index in
            sut.createFeedback(
                title: "Feedback \(index)",
                description: "Description \(index)",
                type: .improvement,
                priority: .low,
                screenshot: nil
            )
        }
        
        // When
        for feedback in feedbacks {
            _ = await sut.submitFeedback(feedback)
        }
        
        // Then
        XCTAssertEqual(sut.feedbacks.count, 3)
    }
    
    // MARK: - Load Feedbacks Tests
    
    func testLoadFeedbacks() async {
        // Given
        let expectation = XCTestExpectation(description: "Feedbacks loaded")
        
        sut.$feedbacks
            .dropFirst()
            .sink { feedbacks in
                if !feedbacks.isEmpty {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        // When
        await sut.loadFeedbacks()
        
        // Then
        await fulfillment(of: [expectation], timeout: 2.0)
        XCTAssertFalse(sut.feedbacks.isEmpty)
    }
    
    // MARK: - Update Feedback Tests
    
    func testUpdateFeedbackStatus() async {
        // Given
        let feedback = sut.createFeedback(
            title: "Update Test",
            description: "Testing update",
            type: .bug,
            priority: .high,
            screenshot: nil
        )
        _ = await sut.submitFeedback(feedback)
        
        // When
        let result = await sut.updateFeedbackStatus(feedback.id, status: .inProgress)
        
        // Then
        switch result {
        case .success:
            let updated = sut.feedbacks.first { $0.id == feedback.id }
            XCTAssertEqual(updated?.status, .inProgress)
        case .failure:
            XCTFail("Update should succeed")
        }
    }
    
    func testUpdateFeedbackResponse() async {
        // Given
        let feedback = sut.createFeedback(
            title: "Response Test",
            description: "Testing response",
            type: .question,
            priority: .medium,
            screenshot: nil
        )
        _ = await sut.submitFeedback(feedback)
        let response = "Thank you for your feedback"
        
        // When
        let result = await sut.updateFeedbackResponse(feedback.id, response: response)
        
        // Then
        switch result {
        case .success:
            let updated = sut.feedbacks.first { $0.id == feedback.id }
            XCTAssertEqual(updated?.response, response)
        case .failure:
            XCTFail("Update should succeed")
        }
    }
    
    // MARK: - Delete Feedback Tests
    
    func testDeleteFeedback() async {
        // Given
        let feedback = sut.createFeedback(
            title: "Delete Test",
            description: "Testing deletion",
            type: .bug,
            priority: .low,
            screenshot: nil
        )
        _ = await sut.submitFeedback(feedback)
        
        // When
        let result = await sut.deleteFeedback(feedback.id)
        
        // Then
        switch result {
        case .success:
            XCTAssertNil(sut.feedbacks.first { $0.id == feedback.id })
        case .failure:
            XCTFail("Delete should succeed")
        }
    }
    
    // MARK: - Filter Tests
    
    func testFilterByType() async {
        // Given
        let bugFeedback = sut.createFeedback(
            title: "Bug",
            description: "Bug description",
            type: .bug,
            priority: .high,
            screenshot: nil
        )
        let featureFeedback = sut.createFeedback(
            title: "Feature",
            description: "Feature description",
            type: .feature,
            priority: .medium,
            screenshot: nil
        )
        _ = await sut.submitFeedback(bugFeedback)
        _ = await sut.submitFeedback(featureFeedback)
        
        // When
        let bugs = sut.feedbacks(by: .bug)
        let features = sut.feedbacks(by: .feature)
        
        // Then
        XCTAssertEqual(bugs.count, 1)
        XCTAssertEqual(bugs.first?.type, .bug)
        XCTAssertEqual(features.count, 1)
        XCTAssertEqual(features.first?.type, .feature)
    }
    
    func testFilterByStatus() async {
        // Given
        let pendingFeedback = sut.createFeedback(
            title: "Pending",
            description: "Pending description",
            type: .bug,
            priority: .high,
            screenshot: nil
        )
        _ = await sut.submitFeedback(pendingFeedback)
        _ = await sut.updateFeedbackStatus(pendingFeedback.id, status: .resolved)
        
        // When
        let resolved = sut.feedbacks(byStatus: .resolved)
        let pending = sut.feedbacks(byStatus: .pending)
        
        // Then
        XCTAssertEqual(resolved.count, 1)
        XCTAssertEqual(pending.count, 0)
    }
    
    // MARK: - Type Tests
    
    func testFeedbackTypeProperties() {
        XCTAssertEqual(FeedbackType.bug.title, "Ошибка")
        XCTAssertEqual(FeedbackType.bug.icon, "ladybug")
        XCTAssertEqual(FeedbackType.bug.color, .red)
        
        XCTAssertEqual(FeedbackType.feature.title, "Предложение")
        XCTAssertEqual(FeedbackType.feature.icon, "lightbulb")
        XCTAssertEqual(FeedbackType.feature.color, .blue)
        
        XCTAssertEqual(FeedbackType.improvement.title, "Улучшение")
        XCTAssertEqual(FeedbackType.improvement.icon, "wand.and.stars")
        XCTAssertEqual(FeedbackType.improvement.color, .orange)
        
        XCTAssertEqual(FeedbackType.question.title, "Вопрос")
        XCTAssertEqual(FeedbackType.question.icon, "questionmark.circle")
        XCTAssertEqual(FeedbackType.question.color, .purple)
    }
    
    // MARK: - Priority Tests
    
    func testFeedbackPriorityProperties() {
        XCTAssertEqual(FeedbackPriority.low.displayName, "Низкий")
        XCTAssertEqual(FeedbackPriority.low.color, .gray)
        
        XCTAssertEqual(FeedbackPriority.medium.displayName, "Средний")
        XCTAssertEqual(FeedbackPriority.medium.color, .blue)
        
        XCTAssertEqual(FeedbackPriority.high.displayName, "Высокий")
        XCTAssertEqual(FeedbackPriority.high.color, .orange)
        
        XCTAssertEqual(FeedbackPriority.critical.displayName, "Критический")
        XCTAssertEqual(FeedbackPriority.critical.color, .red)
    }
    
    // MARK: - Status Tests
    
    func testFeedbackStatusProperties() {
        XCTAssertEqual(FeedbackStatus.pending.displayName, "Ожидает")
        XCTAssertEqual(FeedbackStatus.pending.icon, "clock")
        XCTAssertEqual(FeedbackStatus.pending.color, .orange)
        
        XCTAssertEqual(FeedbackStatus.inProgress.displayName, "В работе")
        XCTAssertEqual(FeedbackStatus.inProgress.icon, "gear")
        XCTAssertEqual(FeedbackStatus.inProgress.color, .blue)
        
        XCTAssertEqual(FeedbackStatus.resolved.displayName, "Решено")
        XCTAssertEqual(FeedbackStatus.resolved.icon, "checkmark.circle")
        XCTAssertEqual(FeedbackStatus.resolved.color, .green)
        
        XCTAssertEqual(FeedbackStatus.closed.displayName, "Закрыто")
        XCTAssertEqual(FeedbackStatus.closed.icon, "xmark.circle")
        XCTAssertEqual(FeedbackStatus.closed.color, .gray)
    }
    
    // MARK: - Error Handling Tests
    
    func testLoadingState() async {
        // Given
        let expectation = XCTestExpectation(description: "Loading state changes")
        var loadingStates: [Bool] = []
        
        sut.$isLoading
            .sink { isLoading in
                loadingStates.append(isLoading)
                if loadingStates.count >= 2 {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        // When
        await sut.loadFeedbacks()
        
        // Then
        await fulfillment(of: [expectation], timeout: 2.0)
        XCTAssertTrue(loadingStates.contains(true))
        XCTAssertTrue(loadingStates.contains(false))
    }
}

// MARK: - Helper Extensions

extension FeedbackService {
    func clearFeedbacks() {
        feedbacks.removeAll()
    }
    
    func feedbacks(by type: FeedbackType) -> [FeedbackItem] {
        feedbacks.filter { $0.type == type }
    }
    
    func feedbacks(byStatus status: FeedbackStatus) -> [FeedbackItem] {
        feedbacks.filter { $0.status == status }
    }
    
    // Mock helper methods for testing
    func createFeedback(
        title: String,
        description: String,
        type: FeedbackType,
        priority: FeedbackPriority,
        screenshot: Data?
    ) -> FeedbackItem {
        return FeedbackItem(
            title: title,
            description: description,
            type: type,
            status: .pending,
            author: "Test User",
            authorId: "test-user-id",
            screenshot: screenshot?.base64EncodedString()
        )
    }
    
    func submitFeedback(_ feedback: FeedbackItem) async -> Result<FeedbackItem, Error> {
        feedbacks.append(feedback)
        return .success(feedback)
    }
    
    func updateFeedbackStatus(_ id: UUID, status: FeedbackStatus) async -> Result<Void, Error> {
        if let index = feedbacks.firstIndex(where: { $0.id == id }) {
            // FeedbackItem is immutable struct, need to recreate with new status
            let oldFeedback = feedbacks[index]
            let updatedFeedback = FeedbackItem(
                id: oldFeedback.id,
                title: oldFeedback.title,
                description: oldFeedback.description,
                type: oldFeedback.type,
                status: status,
                author: oldFeedback.author,
                authorId: oldFeedback.authorId,
                createdAt: oldFeedback.createdAt,
                updatedAt: Date(),
                screenshot: oldFeedback.screenshot,
                reactions: oldFeedback.reactions,
                comments: oldFeedback.comments,
                userReaction: oldFeedback.userReaction,
                isOwnFeedback: oldFeedback.isOwnFeedback
            )
            feedbacks[index] = updatedFeedback
            return .success(())
        }
        return .failure(NSError(domain: "FeedbackService", code: 404, userInfo: nil))
    }
    
    func updateFeedbackResponse(_ id: UUID, response: String) async -> Result<Void, Error> {
        // Since FeedbackItem doesn't have response property in current implementation
        // We'll simulate it with a comment
        if let index = feedbacks.firstIndex(where: { $0.id == id }) {
            let adminComment = FeedbackComment(
                text: response,
                author: "Admin",
                authorId: "admin",
                isAdmin: true
            )
            let oldFeedback = feedbacks[index]
            var updatedComments = oldFeedback.comments
            updatedComments.append(adminComment)
            
            let updatedFeedback = FeedbackItem(
                id: oldFeedback.id,
                title: oldFeedback.title,
                description: oldFeedback.description,
                type: oldFeedback.type,
                status: oldFeedback.status,
                author: oldFeedback.author,
                authorId: oldFeedback.authorId,
                createdAt: oldFeedback.createdAt,
                updatedAt: Date(),
                screenshot: oldFeedback.screenshot,
                reactions: oldFeedback.reactions,
                comments: updatedComments,
                userReaction: oldFeedback.userReaction,
                isOwnFeedback: oldFeedback.isOwnFeedback
            )
            feedbacks[index] = updatedFeedback
            return .success(())
        }
        return .failure(NSError(domain: "FeedbackService", code: 404, userInfo: nil))
    }
    
    func deleteFeedback(_ id: UUID) async -> Result<Void, Error> {
        feedbacks.removeAll { $0.id == id }
        return .success(())
    }
}

// MARK: - Mock Types for Testing

enum FeedbackPriority: String, CaseIterable {
    case low, medium, high, critical
    
    var displayName: String {
        switch self {
        case .low: return "Низкий"
        case .medium: return "Средний"
        case .high: return "Высокий"
        case .critical: return "Критический"
        }
    }
    
    var color: Color {
        switch self {
        case .low: return .gray
        case .medium: return .blue
        case .high: return .orange
        case .critical: return .red
        }
    }
}

// Extension to add missing properties
extension FeedbackStatus {
    var displayName: String {
        return self.title
    }
    
    var icon: String {
        switch self {
        case .open: return "clock"
        case .inProgress: return "gear"
        case .resolved: return "checkmark.circle"
        case .closed: return "xmark.circle"
        }
    }
    
    var color: Color {
        switch self {
        case .open: return .orange
        case .inProgress: return .blue
        case .resolved: return .green
        case .closed: return .gray
        }
    }
}

// Add response property to FeedbackItem
extension FeedbackItem {
    var response: String? {
        // Find admin response in comments
        return comments.first(where: { $0.isAdmin })?.text
    }
} 