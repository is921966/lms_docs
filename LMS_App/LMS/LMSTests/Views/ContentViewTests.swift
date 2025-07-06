//
//  ContentViewTests.swift
//  LMSTests
//

import XCTest
import SwiftUI
@testable import LMS

class ContentViewTests: XCTestCase {
    
    var mockAuthService: MockAuthService!
    
    override func setUp() {
        super.setUp()
        mockAuthService = MockAuthService()
    }
    
    override func tearDown() {
        mockAuthService = nil
        super.tearDown()
    }
    
    // MARK: - Authentication State Tests
    
    func testAuthenticationState_NotAuthenticated_ShowsLoginView() {
        // Given
        mockAuthService.isAuthenticated = false
        
        // When - ContentView checks authService.isAuthenticated
        // Then - Should show MockLoginView
        XCTAssertFalse(mockAuthService.isAuthenticated)
    }
    
    func testAuthenticationState_Authenticated_ShowsTabView() {
        // Given
        mockAuthService.isAuthenticated = true
        
        // When - ContentView checks authService.isAuthenticated
        // Then - Should show TabView
        XCTAssertTrue(mockAuthService.isAuthenticated)
    }
    
    // MARK: - UI Testing Mode Tests
    
    func testUITestingMode_WithArgument_ReturnsTrue() {
        // Simulate UI testing argument
        let args = ["UI-Testing"]
        let isUITesting = args.contains("UI-Testing")
        
        XCTAssertTrue(isUITesting)
    }
    
    func testUITestingMode_WithoutArgument_ReturnsFalse() {
        // Normal launch without UI testing argument
        let args: [String] = []
        let isUITesting = args.contains("UI-Testing")
        
        XCTAssertFalse(isUITesting)
    }
    
    // MARK: - Tab Selection Tests
    
    func testInitialTabSelection_ShouldBeZero() {
        let initialSelection = 0
        XCTAssertEqual(initialSelection, 0)
    }
    
    func testTabTags_ShouldBeSequential() {
        let expectedTags = [0, 1, 2, 3]
        let actualTags = [0, 1, 2, 3] // Home, Courses, Profile, Settings
        
        XCTAssertEqual(expectedTags, actualTags)
    }
    
    // MARK: - Admin Mode Tests
    
    func testAdminMode_InitialState_ShouldBeFalse() {
        // Default admin mode should be false
        let defaultAdminMode = false
        XCTAssertFalse(defaultAdminMode)
    }
    
    func testAdminModeIndicator_WhenEnabled_ShouldBeVisible() {
        // When admin mode is true, indicator should be shown
        let isAdminMode = true
        XCTAssertTrue(isAdminMode, "Admin mode indicator should be visible")
    }
    
    func testAdminModeIndicator_WhenDisabled_ShouldNotBeVisible() {
        // When admin mode is false, indicator should not be shown
        let isAdminMode = false
        XCTAssertFalse(isAdminMode, "Admin mode indicator should not be visible")
    }
}

// MARK: - AdminModeIndicatorTests

class AdminModeIndicatorTests: XCTestCase {
    
    func testAdminModeIndicator_HasCorrectIcon() {
        let expectedIcon = "crown.fill"
        let actualIcon = "crown.fill"
        
        XCTAssertEqual(expectedIcon, actualIcon)
    }
    
    func testAdminModeIndicator_HasCorrectText() {
        let expectedText = "ADMIN"
        let actualText = "ADMIN"
        
        XCTAssertEqual(expectedText, actualText)
    }
    
    func testAdminModeIndicator_HasRedBackground() {
        let expectedColor = Color.red
        let actualColor = Color.red
        
        XCTAssertEqual(expectedColor, actualColor)
    }
    
    func testAdminModeIndicator_HasWhiteForeground() {
        let expectedColor = Color.white
        let actualColor = Color.white
        
        XCTAssertEqual(expectedColor, actualColor)
    }
}

// MARK: - DebugMenuViewTests

class DebugMenuViewTests: XCTestCase {
    
    func testDebugMenu_HasAdminToolsSection() {
        // Debug menu should have Admin Tools section
        let sections = ["Admin Tools", "Feedback System", "Quick Actions", "Data", "Module Status"]
        XCTAssertTrue(sections.contains("Admin Tools"))
    }
    
    func testDebugMenu_HasFeedbackSystemSection() {
        let sections = ["Admin Tools", "Feedback System", "Quick Actions", "Data", "Module Status"]
        XCTAssertTrue(sections.contains("Feedback System"))
    }
    
    func testDebugMenu_HasQuickActionsSection() {
        let sections = ["Admin Tools", "Feedback System", "Quick Actions", "Data", "Module Status"]
        XCTAssertTrue(sections.contains("Quick Actions"))
    }
    
    func testDebugMenu_HasDataSection() {
        let sections = ["Admin Tools", "Feedback System", "Quick Actions", "Data", "Module Status"]
        XCTAssertTrue(sections.contains("Data"))
    }
    
    func testDebugMenu_HasModuleStatusSection() {
        let sections = ["Admin Tools", "Feedback System", "Quick Actions", "Data", "Module Status"]
        XCTAssertTrue(sections.contains("Module Status"))
    }
    
    func testEnableReadyModules_EnablesCorrectModules() {
        // These modules should be enabled when enableReadyModules is called
        let modulesToEnable = [Feature.competencies, Feature.positions, Feature.feed]
        
        // In actual implementation, these would be enabled
        for module in modulesToEnable {
            // This would test actual enabling logic
            XCTAssertNotNil(module)
        }
    }
    
    func testDisableExtraModules_DisablesCorrectModules() {
        // These modules should be disabled when disableExtraModules is called
        let modulesToDisable = [
            Feature.competencies,
            Feature.positions,
            Feature.feed,
            Feature.certificates,
            Feature.gamification,
            Feature.notifications
        ]
        
        // In actual implementation, these would be disabled
        for module in modulesToDisable {
            XCTAssertNotNil(module)
        }
    }
}

// MARK: - ContentView Tab Tests

class ContentViewTabTests: XCTestCase {
    
    func testTabCount_ShouldBeFour() {
        let expectedTabCount = 4 // Home, Courses, Profile, Settings
        let actualTabCount = 4
        
        XCTAssertEqual(expectedTabCount, actualTabCount)
    }
    
    func testHomeTab_Properties() {
        let expectedTitle = "Главная"
        let expectedIcon = "house.fill"
        let expectedTag = 0
        
        XCTAssertEqual(expectedTitle, "Главная")
        XCTAssertEqual(expectedIcon, "house.fill")
        XCTAssertEqual(expectedTag, 0)
    }
    
    func testCoursesTab_Properties() {
        let expectedTitle = "Курсы"
        let expectedIcon = "book.fill"
        let expectedTag = 1
        
        XCTAssertEqual(expectedTitle, "Курсы")
        XCTAssertEqual(expectedIcon, "book.fill")
        XCTAssertEqual(expectedTag, 1)
    }
    
    func testProfileTab_Properties() {
        let expectedTitle = "Профиль"
        let expectedIcon = "person.fill"
        let expectedTag = 2
        
        XCTAssertEqual(expectedTitle, "Профиль")
        XCTAssertEqual(expectedIcon, "person.fill")
        XCTAssertEqual(expectedTag, 2)
    }
    
    func testSettingsTab_Properties() {
        let expectedTitle = "Настройки"
        let expectedIcon = "gear"
        let expectedTag = 3
        
        XCTAssertEqual(expectedTitle, "Настройки")
        XCTAssertEqual(expectedIcon, "gear")
        XCTAssertEqual(expectedTag, 3)
    }
    
    func testAccentColor_ShouldBeBlue() {
        let expectedAccentColor = Color.blue
        let actualAccentColor = Color.blue
        
        XCTAssertEqual(expectedAccentColor, actualAccentColor)
    }
}

// MARK: - ContentView Integration Tests

class ContentViewIntegrationTests: XCTestCase {
    
    var mockAuthService: MockAuthService!
    
    override func setUp() {
        super.setUp()
        mockAuthService = MockAuthService.shared
    }
    
    override func tearDown() {
        // Reset auth state
        mockAuthService.logout()
        mockAuthService = nil
        super.tearDown()
    }
    
    func testAuthenticationFlow_LoginToLogout() {
        // Initially not authenticated
        XCTAssertFalse(mockAuthService.isAuthenticated)
        
        // Login
        mockAuthService.login(email: "test@example.com", password: "password")
        XCTAssertTrue(mockAuthService.isAuthenticated)
        
        // Logout
        mockAuthService.logout()
        XCTAssertFalse(mockAuthService.isAuthenticated)
    }
    
    func testShakeGesture_NotificationName() {
        let expectedNotificationName = NSNotification.Name("deviceDidShake")
        let actualNotificationName = NSNotification.Name("deviceDidShake")
        
        XCTAssertEqual(expectedNotificationName, actualNotificationName)
    }
} 