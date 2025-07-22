import SwiftUI
import Combine

// MARK: - Navigation Tracker
class NavigationTracker: ObservableObject {
    static let shared = NavigationTracker()
    
    @Published private(set) var currentScreen: String = "Unknown"
    @Published private(set) var previousScreen: String = "Unknown"
    @Published private(set) var screenHistory: [ScreenInfo] = []
    @Published private(set) var activeViews: Set<String> = []
    
    private let maxHistorySize = 50
    
    struct ScreenInfo {
        let name: String
        let timestamp: Date
        let metadata: [String: Any]
    }
    
    private init() {
        // Start tracking
        ComprehensiveLogger.shared.log(.system, .info, "NavigationTracker initialized")
    }
    
    // MARK: - Screen Tracking
    func trackScreen(_ screenName: String, metadata: [String: Any] = [:]) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            // Update current and previous
            self.previousScreen = self.currentScreen
            self.currentScreen = screenName
            
            // Add to history
            let info = ScreenInfo(name: screenName, timestamp: Date(), metadata: metadata)
            self.screenHistory.append(info)
            
            // Limit history size
            if self.screenHistory.count > self.maxHistorySize {
                self.screenHistory.removeFirst()
            }
            
            // Log navigation
            ComprehensiveLogger.shared.log(.navigation, .info, "Screen changed", details: [
                "from": self.previousScreen,
                "to": screenName,
                "metadata": metadata,
                "activeViewsCount": self.activeViews.count
            ])
            
            // Update log server with current screen
            LogUploader.shared.updateCurrentScreen(screenName)
        }
    }
    
    // MARK: - View Lifecycle Tracking
    func viewAppeared(_ viewName: String, metadata: [String: Any] = [:]) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.activeViews.insert(viewName)
            
            ComprehensiveLogger.shared.log(.ui, .debug, "View appeared", details: [
                "view": viewName,
                "metadata": metadata,
                "activeViews": Array(self.activeViews)
            ])
            
            // If this is a main screen view, track it as current screen
            if self.isMainScreenView(viewName) {
                self.trackScreen(viewName, metadata: metadata)
            }
        }
    }
    
    func viewDisappeared(_ viewName: String) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.activeViews.remove(viewName)
            
            ComprehensiveLogger.shared.log(.ui, .debug, "View disappeared", details: [
                "view": viewName,
                "remainingViews": Array(self.activeViews)
            ])
        }
    }
    
    // MARK: - Tab Tracking
    func tabSelected(_ tabName: String) {
        trackScreen("Tab: \(tabName)", metadata: ["tabName": tabName])
        
        ComprehensiveLogger.shared.log(.navigation, .info, "Tab selected", details: [
            "tab": tabName,
            "previousScreen": previousScreen
        ])
    }
    
    // MARK: - Helper Methods
    private func isMainScreenView(_ viewName: String) -> Bool {
        // List of views that represent main screens
        let mainScreens = [
            "FeedView", "TelegramFeedView", "ProfileView", "SettingsView",
            "AdminPanelView", "MoreMenuView", "CourseListView", "CompetencyView",
            "LoginView", "OnboardingView", "CourseManagementView", "LogTestView"
        ]
        
        return mainScreens.contains { viewName.contains($0) }
    }
    
    // MARK: - Debug Info
    func getCurrentNavigationState() -> [String: Any] {
        return [
            "currentScreen": currentScreen,
            "previousScreen": previousScreen,
            "activeViews": Array(activeViews),
            "historyCount": screenHistory.count,
            "lastTransition": screenHistory.last?.timestamp ?? "Never"
        ]
    }
}

// MARK: - SwiftUI View Extension
extension View {
    func trackNavigation(_ screenName: String, metadata: [String: Any] = [:]) -> some View {
        self
            .onAppear {
                NavigationTracker.shared.viewAppeared(screenName, metadata: metadata)
            }
            .onDisappear {
                NavigationTracker.shared.viewDisappeared(screenName)
            }
    }
    
    func trackScreen(_ screenName: String, metadata: [String: Any] = [:]) -> some View {
        self
            .onAppear {
                NavigationTracker.shared.trackScreen(screenName, metadata: metadata)
            }
    }
}

// MARK: - UIViewController Extension for UIKit integration
extension UIViewController {
    @objc dynamic func swizzled_viewDidAppear(_ animated: Bool) {
        self.swizzled_viewDidAppear(animated)
        
        let viewName = String(describing: type(of: self))
        NavigationTracker.shared.viewAppeared(viewName, metadata: [
            "isModal": self.isModal,
            "presentationStyle": self.modalPresentationStyle.rawValue
        ])
    }
    
    @objc dynamic func swizzled_viewDidDisappear(_ animated: Bool) {
        self.swizzled_viewDidDisappear(animated)
        
        let viewName = String(describing: type(of: self))
        NavigationTracker.shared.viewDisappeared(viewName)
    }
    
    var isModal: Bool {
        return self.presentingViewController != nil ||
               self.navigationController?.presentingViewController?.presentedViewController == self.navigationController ||
               self.tabBarController?.presentingViewController is UITabBarController
    }
} 