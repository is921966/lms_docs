//
//  MockAuthServiceExtensions.swift
//  LMSTests
//
//  Created by LMS Team on 13.01.2025.
//

import XCTest
@testable import LMS

extension MockAuthService {
    
    /// Synchronous login for UI tests
    func loginSync(email: String, password: String) -> Bool {
        let expectation = XCTestExpectation(description: "Login")
        var success = false
        
        Task {
            do {
                _ = try await self.login(email: email, password: password)
                success = true
                expectation.fulfill()
            } catch {
                success = false
                expectation.fulfill()
            }
        }
        
        _ = XCTWaiter.wait(for: [expectation], timeout: 5.0)
        return success
    }
    
    /// Synchronous logout for UI tests
    func logoutSync() {
        let expectation = XCTestExpectation(description: "Logout")
        
        Task {
            do {
                try await self.logout()
                expectation.fulfill()
            } catch {
                // Ignore logout errors
                expectation.fulfill()
            }
        }
        
        _ = XCTWaiter.wait(for: [expectation], timeout: 5.0)
    }
    
    /// Set authenticated user for testing
    func setAuthenticatedForTesting(user: UserResponse) {
        self.currentUser = user
        self.isAuthenticated = true
    }
} 