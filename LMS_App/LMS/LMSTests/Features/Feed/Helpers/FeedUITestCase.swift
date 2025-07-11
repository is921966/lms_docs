//
//  FeedUITestCase.swift
//  LMSTests
//
//  Created by LMS Team on 13.01.2025.
//

import XCTest
@testable import LMS

class FeedUITestCase: XCTestCase {
    
    var feedService: FeedService!
    var authService: MockAuthService!
    
    override func setUp() {
        super.setUp()
        feedService = FeedService.shared
        authService = MockAuthService.shared
    }
    
    override func tearDown() {
        logoutSync()
        super.tearDown()
    }
    
    // MARK: - Helper Methods for Sync Operations
    
    func loginSync(email: String, password: String) {
        let expectation = expectation(description: "Login")
        
        Task {
            do {
                _ = try await authService.login(email: email, password: password)
                expectation.fulfill()
            } catch {
                XCTFail("Login failed: \(error)")
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func logoutSync() {
        let expectation = expectation(description: "Logout")
        
        Task {
            do {
                try await authService.logout()
                expectation.fulfill()
            } catch {
                // Ignore logout errors
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func createPostSync(content: String, visibility: FeedVisibility = .everyone) {
        let expectation = expectation(description: "Create Post")
        
        Task {
            do {
                try await feedService.createPost(content: content, visibility: visibility)
                expectation.fulfill()
            } catch {
                XCTFail("Create post failed: \(error)")
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
} 