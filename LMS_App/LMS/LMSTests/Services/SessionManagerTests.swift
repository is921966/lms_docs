//
//  SessionManagerTests.swift
//  LMSTests
//
//  Created on Sprint 39 Day 2 - TDD Excellence
//

import XCTest
@testable import LMS

final class SessionManagerTests: XCTestCase {
    
    var sut: SessionManager!
    
    override func setUp() {
        super.setUp()
        sut = SessionManager.shared
        sut.endSession()
        
        // Wait for async operation
        let expectation = XCTestExpectation(description: "Session ended")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 0.5)
    }
    
    override func tearDown() {
        sut.endSession()
        sut = nil
        super.tearDown()
    }
    
    // MARK: - Session Lifecycle Tests
    
    func testStartSession() {
        // Arrange
        let userId = "user123"
        let userInfo = ["role": "student", "department": "IT"]
        
        // Act
        let sessionId = sut.startSession(userId: userId, userInfo: userInfo)
        
        // Assert
        XCTAssertFalse(sessionId.isEmpty)
        XCTAssertTrue(sut.isSessionActive())
        XCTAssertEqual(sut.getCurrentUserId(), userId)
        XCTAssertEqual(sut.getUserInfo()["role"], "student")
    }
    
    func testSessionTimeout() async {
        // Arrange
        sut.startSession(userId: "user123", timeout: 0.1) // 0.1 second timeout
        
        // Act
        try? await Task.sleep(nanoseconds: 200_000_000) // 0.2 seconds
        
        // Assert
        XCTAssertFalse(sut.isSessionActive())
        XCTAssertNil(sut.getCurrentUserId())
    }
    
    func testRefreshSession() {
        // Arrange
        let sessionId1 = sut.startSession(userId: "user123")
        let startTime1 = sut.getSessionStartTime()
        
        // Act
        sut.refreshSession()
        
        // Wait for async operation
        let expectation = XCTestExpectation(description: "Session refreshed")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 0.5)
        
        let sessionId2 = sut.getCurrentSessionId()
        let sessionInfo = sut.getSessionInfo()
        
        // Assert
        XCTAssertEqual(sessionId1, sessionId2) // Same session
        XCTAssertEqual(startTime1, sessionInfo?.startTime) // Same start time
        XCTAssertNotEqual(sessionInfo?.lastActivityTime, startTime1) // But updated activity
    }
    
    // MARK: - Additional Tests for Refactored Features
    
    func testSessionPersistence() {
        // Note: In real test we would need to mock UserDefaults
        // For now just test that session info is available
        
        // Arrange & Act
        let sessionId = sut.startSession(userId: "user456", userInfo: ["test": "data"])
        let sessionInfo = sut.getSessionInfo()
        
        // Assert
        XCTAssertNotNil(sessionInfo)
        XCTAssertEqual(sessionInfo?.sessionId, sessionId)
        XCTAssertEqual(sessionInfo?.userId, "user456")
        XCTAssertEqual(sessionInfo?.userInfo["test"], "data")
        XCTAssertFalse(sessionInfo?.isExpired ?? true)
        XCTAssertGreaterThan(sessionInfo?.remainingTime ?? 0, 0)
    }
    
    func testUpdateUserInfo() {
        // Arrange
        sut.startSession(userId: "user789", userInfo: ["role": "student"])
        
        // Act
        sut.updateUserInfo(["role": "admin", "department": "IT"])
        
        // Wait for async operation
        let expectation = XCTestExpectation(description: "User info updated")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 0.5)
        
        // Assert
        let userInfo = sut.getUserInfo()
        XCTAssertEqual(userInfo["role"], "admin") // Updated
        XCTAssertEqual(userInfo["department"], "IT") // Added
    }
} 