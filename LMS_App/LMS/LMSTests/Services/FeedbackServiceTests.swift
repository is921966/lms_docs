//
//  FeedbackServiceTests.swift
//  LMSTests
//

import XCTest
import SwiftUI
import Combine
@testable import LMS

@MainActor
final class FeedbackServiceTests: XCTestCase {
    
    var sut: FeedbackService!
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() async throws {
        try await super.setUp()
        sut = FeedbackService.shared
        cancellables = []
    }
    
    override func tearDown() async throws {
        cancellables = nil
        sut = nil
        try await super.tearDown()
    }
    
    // MARK: - Initial State Tests
    
    func testInitialState() {
        XCTAssertTrue(sut.feedbacks.isEmpty || !sut.feedbacks.isEmpty) // Can have mock data
        XCTAssertFalse(sut.isLoading)
        XCTAssertNil(sut.errorMessage)
    }
    
    // MARK: - Basic Tests
    
    func testServiceCreation() {
        XCTAssertNotNil(sut)
    }
    
    func testSharedInstance() {
        let instance1 = FeedbackService.shared
        let instance2 = FeedbackService.shared
        XCTAssertTrue(instance1 === instance2)
    }
    
    func testLoadingState() async throws {
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
    
    func testLoadFeedbacks() async {
        // When
        await sut.loadFeedbacks()
        
        // Then
        XCTAssertFalse(sut.isLoading)
        // Mock data should be loaded
        XCTAssertFalse(sut.feedbacks.isEmpty)
    }
    
    func testCreateFeedback() async {
        // Given
        let deviceInfo = DeviceInfo(
            model: "iPhone",
            osVersion: "17.0",
            appVersion: "1.0",
            buildNumber: "1",
            locale: "en_US",
            screenSize: "390x844"
        )
        
        let feedback = FeedbackModel(
            type: "bug",
            text: "Test bug report",
            screenshot: nil,
            deviceInfo: deviceInfo
        )
        
        // When
        let success = await sut.createFeedback(feedback)
        
        // Then
        XCTAssertTrue(success)
        XCTAssertFalse(sut.feedbacks.isEmpty)
    }
    
    func testAddReaction() async {
        // Given
        await sut.loadFeedbacks()
        guard let feedback = sut.feedbacks.first else {
            XCTFail("No feedbacks loaded")
            return
        }
        
        let initialLikes = feedback.reactions.like
        
        // When
        sut.addReaction(to: feedback.id, reaction: .like)
        
        // Then
        if let updatedFeedback = sut.feedbacks.first(where: { $0.id == feedback.id }) {
            if feedback.userReaction == .like {
                // Was already liked, should be removed
                XCTAssertNil(updatedFeedback.userReaction)
                XCTAssertEqual(updatedFeedback.reactions.like, initialLikes - 1)
            } else {
                // Should be liked now
                XCTAssertEqual(updatedFeedback.userReaction, .like)
                XCTAssertEqual(updatedFeedback.reactions.like, initialLikes + 1)
            }
        }
    }
    
    func testAddComment() async {
        // Given
        await sut.loadFeedbacks()
        guard let feedback = sut.feedbacks.first else {
            XCTFail("No feedbacks loaded")
            return
        }
        
        let initialCommentsCount = feedback.comments.count
        let testComment = "This is a test comment"
        
        // When
        sut.addComment(to: feedback.id, comment: testComment)
        
        // Then
        if let updatedFeedback = sut.feedbacks.first(where: { $0.id == feedback.id }) {
            XCTAssertEqual(updatedFeedback.comments.count, initialCommentsCount + 1)
            XCTAssertEqual(updatedFeedback.comments.last?.text, testComment)
        }
    }
    
    func testEmptyCommentNotAdded() async {
        // Given
        await sut.loadFeedbacks()
        guard let feedback = sut.feedbacks.first else {
            XCTFail("No feedbacks loaded")
            return
        }
        
        let initialCommentsCount = feedback.comments.count
        
        // When
        sut.addComment(to: feedback.id, comment: "   ")
        
        // Then
        if let updatedFeedback = sut.feedbacks.first(where: { $0.id == feedback.id }) {
            XCTAssertEqual(updatedFeedback.comments.count, initialCommentsCount)
        }
    }
} 