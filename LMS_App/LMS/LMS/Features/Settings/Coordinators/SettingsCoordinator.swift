import UIKit
import SwiftUI

protocol SettingsCoordinatorProtocol: Coordinator {
    func showNotificationSettings()
    func showLanguageSettings()
    func showAbout()
    func showPrivacyPolicy()
    func showTermsOfService()
    func showDebugMenu()
    func logout()
}

final class SettingsCoordinator: SettingsCoordinatorProtocol {
    weak var parentCoordinator: Coordinator?
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    
    // Dependencies
    private let authService: AuthServiceProtocol
    private let settingsService: SettingsServiceProtocol
    
    init(
        navigationController: UINavigationController,
        authService: AuthServiceProtocol,
        settingsService: SettingsServiceProtocol
    ) {
        self.navigationController = navigationController
        self.authService = authService
        self.settingsService = settingsService
    }
    
    @MainActor
    func start() {
        let settingsView = SettingsView()
        let hostingController = UIHostingController(rootView: settingsView)
        hostingController.title = "Настройки"
        
        navigationController.pushViewController(hostingController, animated: false)
    }
    
    func showNotificationSettings() {
        // TODO: Implement NotificationSettingsView
        print("showNotificationSettings not yet implemented")
    }
    
    func showLanguageSettings() {
        // TODO: Implement LanguageSettingsView
        print("showLanguageSettings not yet implemented")
    }
    
    func showAbout() {
        // TODO: Implement AboutView
        print("showAbout not yet implemented")
    }
    
    func showPrivacyPolicy() {
        // TODO: Implement privacy policy view
        print("showPrivacyPolicy not yet implemented")
    }
    
    func showTermsOfService() {
        // TODO: Implement terms of service view
        print("showTermsOfService not yet implemented")
    }
    
    func showDebugMenu() {
        #if DEBUG
        let view = DebugMenuView()
        let hostingController = UIHostingController(rootView: view)
        hostingController.title = "Debug Menu"
        
        navigationController.pushViewController(hostingController, animated: true)
        #endif
    }
    
    func logout() {
        Task {
            do {
                try await authService.logout()
                
                // Notify parent coordinator to handle logout
                await MainActor.run {
                    // TODO: Implement logout navigation
                    navigationController.popToRootViewController(animated: true)
                }
            } catch {
                // Handle error
                print("Logout error: \(error)")
            }
        }
    }
    
    func didFinish() {
        parentCoordinator?.childDidFinish(self)
    }
} 