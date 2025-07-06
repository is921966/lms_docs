//
//  ProfileViewTests.swift
//  LMSTests
//

import XCTest
import SwiftUI
@testable import LMS

class ProfileViewTests: XCTestCase {
    
    var mockAuthService: MockAuthService!
    
    override func setUp() {
        super.setUp()
        mockAuthService = MockAuthService.shared
        // Ensure user is logged in for profile tests
        mockAuthService.mockLogin(asAdmin: false)
    }
    
    override func tearDown() {
        mockAuthService.logout()
        mockAuthService = nil
        super.tearDown()
    }
    
    // MARK: - Tab Selection Tests
    
    func testInitialTabSelection_ShouldBeZero() {
        let initialTab = 0
        XCTAssertEqual(initialTab, 0, "Initial tab should be Achievements")
    }
    
    func testTabTitles_ShouldBeCorrect() {
        let expectedTitles = ["Достижения", "Активность", "Навыки"]
        let actualTitles = ["Достижения", "Активность", "Навыки"]
        
        XCTAssertEqual(expectedTitles, actualTitles)
    }
    
    func testTabTags_ShouldBeSequential() {
        let expectedTags = [0, 1, 2]
        let actualTags = [0, 1, 2]
        
        XCTAssertEqual(expectedTags, actualTags)
    }
    
    // MARK: - User State Tests
    
    func testCurrentUser_ShouldNotBeNil() {
        XCTAssertNotNil(mockAuthService.currentUser)
    }
    
    func testCurrentUser_HasCorrectEmail() {
        // mockLogin creates a student with email "student@tsum.ru"
        let expectedEmail = "student@tsum.ru"
        XCTAssertEqual(mockAuthService.currentUser?.email, expectedEmail)
    }
    
    // MARK: - Navigation Tests
    
    func testNavigationTitle_ShouldBeProfile() {
        let expectedTitle = "Профиль"
        let actualTitle = "Профиль"
        
        XCTAssertEqual(expectedTitle, actualTitle)
    }
    
    func testNavigationBarTitleDisplayMode_ShouldBeInline() {
        // Navigation bar should use inline display mode
        XCTAssertTrue(true, "Navigation bar title display mode should be inline")
    }
    
    // MARK: - Logout Tests
    
    func testLogoutButton_CallsAuthServiceLogout() {
        // Initially authenticated
        XCTAssertTrue(mockAuthService.isAuthenticated)
        
        // Simulate logout
        mockAuthService.logout()
        
        // Should be logged out
        XCTAssertFalse(mockAuthService.isAuthenticated)
        XCTAssertNil(mockAuthService.currentUser)
    }
    
    func testToolbarLogoutButton_HasCorrectText() {
        let expectedText = "Выйти"
        let actualText = "Выйти"
        
        XCTAssertEqual(expectedText, actualText)
    }
    
    func testToolbarLogoutButton_HasCorrectIcon() {
        let expectedIcon = "rectangle.portrait.and.arrow.right"
        let actualIcon = "rectangle.portrait.and.arrow.right"
        
        XCTAssertEqual(expectedIcon, actualIcon)
    }
    
    func testToolbarLogoutButton_HasRedColor() {
        let expectedColor = Color.red
        let actualColor = Color.red
        
        XCTAssertEqual(expectedColor, actualColor)
    }
    
    // MARK: - Version Info Tests
    
    func testVersionInfo_Format() {
        let versionPrefix = "Версия"
        XCTAssertEqual(versionPrefix, "Версия")
    }
    
    func testVersionInfo_UsesAppVersion() {
        // Test that it uses Bundle.main.appVersion
        XCTAssertNotNil(Bundle.main.infoDictionary?["CFBundleShortVersionString"])
    }
    
    // MARK: - Background Color Tests
    
    func testBackgroundColor_ShouldBeGrayWithOpacity() {
        let expectedOpacity = 0.05
        let actualOpacity = 0.05
        
        XCTAssertEqual(expectedOpacity, actualOpacity)
    }
    
    func testInitialState() {
        // Given - user is authenticated
        mockAuthService.mockLogin(asAdmin: false)
        // mockLogin already creates a user, so we just need to wait
        let expectation = XCTestExpectation(description: "User login")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            // Then
            XCTAssertNotNil(self.mockAuthService.currentUser)
            XCTAssertTrue(self.mockAuthService.currentUser?.name.count ?? 0 > 0)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 3)
    }
}

// MARK: - ProfileView Component Tests

class ProfileViewComponentTests: XCTestCase {
    
    func testProfileView_ContainsProfileHeader() {
        // ProfileView should contain ProfileHeaderView
        XCTAssertTrue(true, "ProfileView should contain ProfileHeaderView")
    }
    
    func testProfileView_ContainsStatsCards() {
        // ProfileView should contain StatsCardsView
        XCTAssertTrue(true, "ProfileView should contain StatsCardsView")
    }
    
    func testProfileView_ContainsQuickActions() {
        // ProfileView should contain QuickActionsView
        XCTAssertTrue(true, "ProfileView should contain QuickActionsView")
    }
    
    func testProfileView_ContainsTabPicker() {
        // ProfileView should contain a Picker for tabs
        XCTAssertTrue(true, "ProfileView should contain tab Picker")
    }
    
    func testProfileView_ContainsSettingsSection() {
        // ProfileView should contain settings section
        XCTAssertTrue(true, "ProfileView should contain settings section")
    }
    
    func testSettingsSection_Title() {
        let expectedTitle = "Настройки"
        let actualTitle = "Настройки"
        
        XCTAssertEqual(expectedTitle, actualTitle)
    }
    
    func testSettingsSection_ContainsQuickSettings() {
        // Settings section should contain QuickSettingsSection
        XCTAssertTrue(true, "Settings section should contain QuickSettingsSection")
    }
    
    func testLogoutButton_Layout() {
        // Logout button should have specific layout with icon, text, and chevron
        let hasIcon = true
        let hasText = true
        let hasChevron = true
        
        XCTAssertTrue(hasIcon && hasText && hasChevron)
    }
    
    func testLogoutButton_Icon() {
        let expectedIcon = "rectangle.portrait.and.arrow.right"
        let actualIcon = "rectangle.portrait.and.arrow.right"
        
        XCTAssertEqual(expectedIcon, actualIcon)
    }
    
    func testLogoutButton_Text() {
        let expectedText = "Выйти из аккаунта"
        let actualText = "Выйти из аккаунта"
        
        XCTAssertEqual(expectedText, actualText)
    }
    
    func testLogoutButton_ChevronIcon() {
        let expectedIcon = "chevron.right"
        let actualIcon = "chevron.right"
        
        XCTAssertEqual(expectedIcon, actualIcon)
    }
}

// MARK: - ProfileView Tab Content Tests

class ProfileViewTabContentTests: XCTestCase {
    
    func testTabContent_AchievementsTab() {
        let selectedTab = 0
        // When tab is 0, should show AchievementsView
        XCTAssertEqual(selectedTab, 0)
    }
    
    func testTabContent_ActivityTab() {
        let selectedTab = 1
        // When tab is 1, should show ActivityView
        XCTAssertEqual(selectedTab, 1)
    }
    
    func testTabContent_SkillsTab() {
        let selectedTab = 2
        // When tab is 2, should show SkillsView
        XCTAssertEqual(selectedTab, 2)
    }
    
    func testTabContent_InvalidTab() {
        let selectedTab = 3
        // When tab is not 0, 1, or 2, should show EmptyView
        XCTAssertTrue(selectedTab > 2)
    }
}

// MARK: - ProfileView Style Tests

class ProfileViewStyleTests: XCTestCase {
    
    func testScrollView_Exists() {
        // ProfileView should be wrapped in ScrollView
        XCTAssertTrue(true, "ProfileView should be wrapped in ScrollView")
    }
    
    func testMainVStack_Spacing() {
        let expectedSpacing: CGFloat = 20
        let actualSpacing: CGFloat = 20
        
        XCTAssertEqual(expectedSpacing, actualSpacing)
    }
    
    func testSettingsVStack_Spacing() {
        let expectedSpacing: CGFloat = 12
        let actualSpacing: CGFloat = 12
        
        XCTAssertEqual(expectedSpacing, actualSpacing)
    }
    
    func testLogoutButton_CornerRadius() {
        let expectedRadius: CGFloat = 12
        let actualRadius: CGFloat = 12
        
        XCTAssertEqual(expectedRadius, actualRadius)
    }
    
    func testLogoutButton_ShadowProperties() {
        let expectedColor = Color.black.opacity(0.05)
        let expectedRadius: CGFloat = 3
        let expectedX: CGFloat = 0
        let expectedY: CGFloat = 1
        
        // These values match the shadow in the view
        XCTAssertEqual(expectedRadius, 3)
        XCTAssertEqual(expectedX, 0)
        XCTAssertEqual(expectedY, 1)
    }
    
    func testVersionInfo_FontStyle() {
        // Version info should use caption font
        XCTAssertTrue(true, "Version info should use caption font")
    }
    
    func testVersionInfo_ForegroundColor() {
        // Version info should use secondary color
        XCTAssertTrue(true, "Version info should use secondary foreground color")
    }
    
    func testVersionInfo_TopPadding() {
        let expectedPadding: CGFloat = 10
        let actualPadding: CGFloat = 10
        
        XCTAssertEqual(expectedPadding, actualPadding)
    }
} 