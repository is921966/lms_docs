import XCTest
@testable import LMS

final class CoordinatorTests: XCTestCase {
    
    func testAppCoordinatorInitialization() {
        // Given
        let window = UIWindow()
        let container = DIContainer()
        
        // When
        let coordinator = AppCoordinator(window: window, container: container)
        
        // Then
        XCTAssertNotNil(coordinator.navigationController)
        XCTAssertTrue(coordinator.childCoordinators.isEmpty)
    }
    
    func testMainTabCoordinatorSetup() {
        // Given
        let navigationController = UINavigationController()
        let container = createMockContainer()
        
        // When
        let coordinator = MainTabCoordinator(
            navigationController: navigationController,
            container: container
        )
        coordinator.start()
        
        // Then
        XCTAssertEqual(coordinator.childCoordinators.count, 4) // Feed, Courses, Profile, More
        XCTAssertNotNil(navigationController.viewControllers.first as? UITabBarController)
    }
    
    func testFeedCoordinatorNavigation() {
        // Given
        let navigationController = UINavigationController()
        let feedService = MockFeedServiceProtocol()
        let authService = MockAuthServiceProtocol()
        
        let coordinator = FeedCoordinator(
            navigationController: navigationController,
            feedService: feedService,
            authService: authService
        )
        
        // When
        coordinator.start()
        
        // Then
        XCTAssertEqual(navigationController.viewControllers.count, 1)
        XCTAssertNotNil(navigationController.viewControllers.first as? UIHostingController<FeedView>)
    }
    
    func testSettingsCoordinatorLogout() {
        // Given
        let navigationController = UINavigationController()
        let authService = MockAuthServiceProtocol()
        let settingsService = MockSettingsServiceProtocol()
        
        let coordinator = SettingsCoordinator(
            navigationController: navigationController,
            authService: authService,
            settingsService: settingsService
        )
        
        let mockParent = MockAppCoordinator()
        coordinator.parentCoordinator = mockParent
        
        // When
        coordinator.logout()
        
        // Then
        XCTAssertTrue(authService.logoutCalled)
    }
    
    func testMoreCoordinatorMenuItems() {
        // Given
        let navigationController = UINavigationController()
        let container = createMockContainer()
        
        let coordinator = MoreCoordinator(
            navigationController: navigationController,
            container: container
        )
        
        // When
        coordinator.start()
        
        // Then
        XCTAssertEqual(navigationController.viewControllers.count, 1)
        
        // Test navigation methods
        coordinator.showSettings()
        XCTAssertEqual(coordinator.childCoordinators.count, 1)
        XCTAssertTrue(coordinator.childCoordinators.first is SettingsCoordinator)
    }
    
    func testCoordinatorMemoryManagement() {
        // Given
        var coordinator: MainTabCoordinator? = MainTabCoordinator(
            navigationController: UINavigationController(),
            container: createMockContainer()
        )
        
        weak var weakCoordinator = coordinator
        
        // When
        coordinator?.start()
        coordinator = nil
        
        // Then
        XCTAssertNil(weakCoordinator, "Coordinator should be deallocated")
    }
    
    // MARK: - Helpers
    
    private func createMockContainer() -> DIContainer {
        let container = DIContainer()
        
        container.register(AuthServiceProtocol.self) { _ in
            MockAuthServiceProtocol()
        }
        
        container.register(FeedServiceProtocol.self) { _ in
            MockFeedServiceProtocol()
        }
        
        container.register(SettingsServiceProtocol.self) { _ in
            MockSettingsServiceProtocol()
        }
        
        // Register other mock services...
        
        return container
    }
}

// MARK: - Mock Classes

private class MockAuthServiceProtocol: AuthServiceProtocol {
    var currentUser: UserResponse? = UserResponse(
        id: "1",
        name: "Test User",
        email: "test@example.com",
        role: "Student"
    )
    
    var isAuthenticated: Bool { currentUser != nil }
    var logoutCalled = false
    
    func login(email: String, password: String) async throws -> UserResponse {
        return currentUser!
    }
    
    func logout() async throws {
        logoutCalled = true
        currentUser = nil
    }
    
    func refreshToken() async throws {}
}

private class MockSettingsServiceProtocol: SettingsServiceProtocol {
    var notificationsEnabled = true
    var pushNotificationsEnabled = true
    var emailNotificationsEnabled = true
    var courseUpdatesEnabled = true
    var gradeNotificationsEnabled = true
    var currentLanguage: AppLanguage = .russian
    var availableLanguages: [AppLanguage] = AppLanguage.allCases
    var currentTheme: AppTheme = .system
    
    var notificationsEnabledPublisher: AnyPublisher<Bool, Never> {
        Just(notificationsEnabled).eraseToAnyPublisher()
    }
    
    var currentLanguagePublisher: AnyPublisher<AppLanguage, Never> {
        Just(currentLanguage).eraseToAnyPublisher()
    }
    
    var currentThemePublisher: AnyPublisher<AppTheme, Never> {
        Just(currentTheme).eraseToAnyPublisher()
    }
    
    func saveSettings() async throws {}
    func resetSettings() {}
    func exportUserData() async throws -> URL { URL(string: "file://")! }
    func deleteAccount() async throws {}
}

private class MockAppCoordinator: AppCoordinator {
    var showLoginCalled = false
    
    override func showLogin() {
        showLoginCalled = true
    }
} 