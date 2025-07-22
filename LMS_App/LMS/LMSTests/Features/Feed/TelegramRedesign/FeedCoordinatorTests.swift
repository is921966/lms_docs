import XCTest
@testable import LMS

class FeedCoordinatorTests: XCTestCase {
    var coordinator: FeedCoordinator!
    var mockNavigationController: MockNavigationController!
    
    override func setUp() {
        super.setUp()
        mockNavigationController = MockNavigationController()
        coordinator = FeedCoordinator(navigationController: mockNavigationController)
    }
    
    override func tearDown() {
        coordinator = nil
        mockNavigationController = nil
        super.tearDown()
    }
    
    // MARK: - Initialization Tests
    
    func testInitialization() {
        XCTAssertNotNil(coordinator)
        XCTAssertTrue(coordinator.navigationController === mockNavigationController)
    }
    
    // MARK: - Navigation Tests
    
    func testStartShowsTelegramFeedView() {
        // Given
        let expectation = XCTestExpectation(description: "Navigation completed")
        mockNavigationController.onPushViewController = { _ in
            expectation.fulfill()
        }
        
        // When
        coordinator.start()
        
        // Then
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(mockNavigationController.viewControllers.count, 1)
        XCTAssertTrue(mockNavigationController.viewControllers.first is UIHostingController<TelegramFeedView>)
    }
    
    func testShowChannelDetail() {
        // Given
        let channel = FeedChannel(
            id: "1",
            title: "Test Channel",
            lastMessage: "Test message",
            timestamp: Date(),
            unreadCount: 5,
            avatarType: .text("TC"),
            isPinned: false,
            isMuted: false,
            category: .general
        )
        
        // When
        coordinator.showChannelDetail(channel)
        
        // Then
        XCTAssertEqual(mockNavigationController.viewControllers.count, 1)
        XCTAssertTrue(mockNavigationController.viewControllers.first is UIHostingController<FeedDetailView>)
    }
    
    func testShowSettings() {
        // When
        coordinator.showSettings()
        
        // Then
        XCTAssertEqual(mockNavigationController.presentedViewController?.classForCoder, UINavigationController.self)
        if let navController = mockNavigationController.presentedViewController as? UINavigationController {
            XCTAssertTrue(navController.viewControllers.first is UIHostingController<TelegramFeedSettingsView>)
        }
    }
    
    func testDismissSettings() {
        // Given
        coordinator.showSettings()
        
        // When
        coordinator.dismissSettings()
        
        // Then
        XCTAssertNil(mockNavigationController.presentedViewController)
    }
    
    // MARK: - Transition Tests
    
    func testTransitionToLegacyFeed() {
        // When
        coordinator.transitionToLegacyFeed()
        
        // Then
        XCTAssertEqual(mockNavigationController.viewControllers.count, 1)
        // Verify it shows the old FeedView
    }
    
    func testHandleDeepLink() {
        // Given
        let channelId = "test-channel-123"
        
        // When
        let handled = coordinator.handleDeepLink(channelId: channelId)
        
        // Then
        XCTAssertTrue(handled)
        XCTAssertEqual(mockNavigationController.viewControllers.count, 1)
    }
}

// MARK: - Mock Classes

class MockNavigationController: UINavigationController {
    var onPushViewController: ((UIViewController) -> Void)?
    var pushedViewControllers: [UIViewController] = []
    
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        pushedViewControllers.append(viewController)
        viewControllers.append(viewController)
        onPushViewController?(viewController)
    }
    
    override func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
        presentedViewController = viewControllerToPresent
        completion?()
    }
    
    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        presentedViewController = nil
        completion?()
    }
} 