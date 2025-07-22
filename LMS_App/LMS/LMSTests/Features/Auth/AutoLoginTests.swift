//
//  AutoLoginTests.swift
//  LMSTests
//
//  Created by Assistant on 15.07.2025.
//

import XCTest
import SwiftUI
@testable import LMS

final class AutoLoginTests: XCTestCase {
    
    var authService: MockAuthService!
    
    override func setUp() {
        super.setUp()
        authService = MockAuthService()
    }
    
    override func tearDown() {
        authService = nil
        super.tearDown()
    }
    
    func testAutoLoginInSimulator() {
        // Given
        XCTAssertFalse(authService.isAuthenticated)
        
        // When
        #if targetEnvironment(simulator)
        // Simulate ContentView onAppear
        if !authService.isAuthenticated {
            authService.mockLogin(asAdmin: true)
        }
        #endif
        
        // Then
        #if targetEnvironment(simulator)
        XCTAssertTrue(authService.isAuthenticated)
        XCTAssertTrue(authService.isAdminMode)
        XCTAssertNotNil(authService.currentUser)
        XCTAssertEqual(authService.currentUser?.role, .admin)
        #else
        XCTAssertFalse(authService.isAuthenticated)
        #endif
    }
    
    func testMockLoginAsAdmin() {
        // Given
        XCTAssertFalse(authService.isAuthenticated)
        
        // When
        authService.mockLogin(asAdmin: true)
        
        // Then
        XCTAssertTrue(authService.isAuthenticated)
        XCTAssertTrue(authService.isAdminMode)
        XCTAssertNotNil(authService.currentUser)
        XCTAssertEqual(authService.currentUser?.name, "Администратор")
        XCTAssertEqual(authService.currentUser?.role, .admin)
        XCTAssertTrue(authService.isApprovedByAdmin)
    }
    
    func testMockLoginAsStudent() {
        // Given
        XCTAssertFalse(authService.isAuthenticated)
        
        // When
        authService.mockLogin(asAdmin: false)
        
        // Then
        XCTAssertTrue(authService.isAuthenticated)
        XCTAssertFalse(authService.isAdminMode)
        XCTAssertNotNil(authService.currentUser)
        XCTAssertEqual(authService.currentUser?.name, "Тестовый студент")
        XCTAssertEqual(authService.currentUser?.role, .student)
        XCTAssertFalse(authService.isApprovedByAdmin)
    }
    
    func testTokensAreSetAfterLogin() {
        // Given
        XCTAssertNil(TokenManager.shared.accessToken)
        XCTAssertNil(TokenManager.shared.refreshToken)
        
        // When
        authService.mockLogin(asAdmin: true)
        
        // Then
        XCTAssertNotNil(TokenManager.shared.accessToken)
        XCTAssertNotNil(TokenManager.shared.refreshToken)
        XCTAssertTrue(TokenManager.shared.accessToken!.hasPrefix("mock_access_token_"))
        XCTAssertTrue(TokenManager.shared.refreshToken!.hasPrefix("mock_refresh_token_"))
    }
    
    func testLogout() {
        // Given
        authService.mockLogin(asAdmin: true)
        XCTAssertTrue(authService.isAuthenticated)
        
        // When
        authService.logout()
        
        // Then
        XCTAssertFalse(authService.isAuthenticated)
        XCTAssertNil(authService.currentUser)
        XCTAssertNil(TokenManager.shared.accessToken)
        XCTAssertNil(TokenManager.shared.refreshToken)
    }
} 