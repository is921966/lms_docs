//
//  SettingsViewModelTests.swift
//  LMSTests
//
//  Created on 06/07/2025.
//

import XCTest
import Combine
@testable import LMS

@MainActor
final class SettingsViewModelTests: XCTestCase {
    
    var viewModel: SettingsViewModel!
    var cancellables: Set<AnyCancellable> = []
    
    override func setUp() async throws {
        try await super.setUp()
        viewModel = SettingsViewModel()
        cancellables = []
    }
    
    override func tearDown() {
        viewModel = nil
        cancellables.removeAll()
        super.tearDown()
    }
    
    // MARK: - Initialization Tests
    
    func testInitialState() async {
        // Initial state
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertFalse(viewModel.showingLogoutConfirmation)
        XCTAssertFalse(viewModel.showingDeleteAccountConfirmation)
        
        // Wait for async init to complete
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        // Should have loaded current user
        XCTAssertNotNil(viewModel.currentUser)
        XCTAssertEqual(viewModel.currentUser?.email, "admin@example.com")
    }
    
    // MARK: - Notification Settings Tests
    
    func testNotificationSettingsDefaults() {
        XCTAssertTrue(viewModel.pushNotificationsEnabled)
        XCTAssertTrue(viewModel.emailNotificationsEnabled)
        XCTAssertTrue(viewModel.courseUpdatesEnabled)
        XCTAssertTrue(viewModel.gradeNotificationsEnabled)
    }
    
    func testUpdateNotificationSettings() async {
        // Change settings
        viewModel.pushNotificationsEnabled = false
        viewModel.emailNotificationsEnabled = false
        
        // Update
        await viewModel.updateNotificationSettings()
        
        // Verify saved to UserDefaults
        XCTAssertFalse(UserDefaults.standard.bool(forKey: "pushNotifications"))
        XCTAssertFalse(UserDefaults.standard.bool(forKey: "emailNotifications"))
    }
    
    // MARK: - App Settings Tests
    
    func testAppSettingsDefaults() {
        XCTAssertFalse(viewModel.biometricAuthEnabled)
        XCTAssertTrue(viewModel.downloadOverWifiOnly)
        XCTAssertFalse(viewModel.autoplayVideos)
    }
    
    func testUpdateAppSettings() async {
        // Change settings
        viewModel.biometricAuthEnabled = true
        viewModel.autoplayVideos = true
        
        // Update
        await viewModel.updateAppSettings()
        
        // Verify saved to UserDefaults
        XCTAssertTrue(UserDefaults.standard.bool(forKey: "biometricAuth"))
        XCTAssertTrue(UserDefaults.standard.bool(forKey: "autoplay"))
    }
    
    // MARK: - Admin Mode Tests
    
    func testToggleAdminMode() async {
        // Wait for user to load
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        // Initial state
        let initialState = viewModel.isAdminMode
        
        // Toggle
        viewModel.toggleAdminMode()
        
        // Should be toggled
        XCTAssertNotEqual(viewModel.isAdminMode, initialState)
    }
    
    func testToggleAdminModeRequiresAdminRole() async {
        // Set non-admin user
        viewModel.currentUser = User(
            id: UUID(),
            email: "student@example.com",
            name: "Student User",
            role: .student,
            avatarURL: nil
        )
        
        // Initial state
        let initialState = viewModel.isAdminMode
        
        // Try to toggle
        viewModel.toggleAdminMode()
        
        // Should not change
        XCTAssertEqual(viewModel.isAdminMode, initialState)
    }
    
    // MARK: - Logout Tests
    
    func testLogout() async {
        // Perform logout
        await viewModel.logout()
        
        // Should not be loading after completion
        XCTAssertFalse(viewModel.isLoading)
    }
    
    func testShowLogoutConfirmation() {
        viewModel.showingLogoutConfirmation = true
        XCTAssertTrue(viewModel.showingLogoutConfirmation)
    }
    
    // MARK: - Delete Account Tests
    
    func testDeleteAccount() async {
        // Initial state
        viewModel.isAdminMode = true
        viewModel.appTheme = "dark"
        
        // Delete account
        await viewModel.deleteAccount()
        
        // Should clear app storage
        XCTAssertFalse(viewModel.isAdminMode)
        XCTAssertEqual(viewModel.appTheme, "system")
        XCTAssertFalse(viewModel.isLoading)
    }
    
    func testShowDeleteAccountConfirmation() {
        viewModel.showingDeleteAccountConfirmation = true
        XCTAssertTrue(viewModel.showingDeleteAccountConfirmation)
    }
    
    // MARK: - Cache Tests
    
    func testClearCache() async {
        // Clear cache
        await viewModel.clearCache()
        
        // Should complete
        XCTAssertFalse(viewModel.isLoading)
    }
    
    func testCacheSize() {
        // Should return mock size
        XCTAssertEqual(viewModel.cacheSize, "125 MB")
    }
    
    // MARK: - App Info Tests
    
    func testAppVersion() {
        let version = viewModel.appVersion
        XCTAssertFalse(version.isEmpty)
        // Should be in format X.X.X or default to 1.0.0
        XCTAssertTrue(version.contains(".") || version == "1.0.0")
    }
    
    func testBuildNumber() {
        let build = viewModel.buildNumber
        XCTAssertFalse(build.isEmpty)
        // Should be numeric or default to "1"
        XCTAssertTrue(Int(build) != nil || build == "1")
    }
    
    // MARK: - Computed Properties Tests
    
    func testIsAdmin() async {
        // Wait for user to load
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        // With admin user
        XCTAssertTrue(viewModel.isAdmin)
        
        // With student user
        viewModel.currentUser = User(
            id: UUID(),
            email: "student@example.com",
            name: "Student",
            role: .student,
            avatarURL: nil
        )
        XCTAssertFalse(viewModel.isAdmin)
        
        // With nil user
        viewModel.currentUser = nil
        XCTAssertFalse(viewModel.isAdmin)
    }
    
    // MARK: - Error Handling Tests
    
    func testErrorMessage() {
        // Set error
        viewModel.errorMessage = "Test error"
        XCTAssertEqual(viewModel.errorMessage, "Test error")
        
        // Clear error
        viewModel.errorMessage = nil
        XCTAssertNil(viewModel.errorMessage)
    }
    
    // MARK: - Loading State Tests
    
    func testLoadingStateDuringOperations() async {
        // Test notification settings update
        let notificationExpectation = XCTestExpectation(description: "Notification loading")
        viewModel.$isLoading
            .dropFirst()
            .sink { isLoading in
                if isLoading {
                    notificationExpectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        Task {
            await viewModel.updateNotificationSettings()
        }
        
        await fulfillment(of: [notificationExpectation], timeout: 1)
    }
} 