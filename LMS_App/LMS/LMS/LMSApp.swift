//
//  LMSApp.swift
//  LMS
//
//  Created by Igor Shirokov on 24.06.2025.
//

import SwiftUI

@main
struct LMSApp: App {
    // let persistenceController = PersistenceController.shared
    @StateObject private var authService = MockAuthService.shared
    @StateObject private var authViewModel = AuthViewModel()
    @StateObject private var adminService = MockAdminService.shared
    // @StateObject private var networkMonitor = NetworkMonitor()
    @StateObject private var feedbackManager = FeedbackManager.shared

    init() {
        setupAppearance()
        setupFeedback()

        // Enable battery monitoring for device info
        UIDevice.current.isBatteryMonitoringEnabled = true

        // Проверяем запущены ли мы в режиме UI тестирования
        let isUITesting = ProcessInfo.processInfo.arguments.contains("UI-Testing")

        // В DEBUG режиме или при UI тестировании включаем готовые модули
        #if DEBUG
        let shouldEnableModules = true
        #else
        let shouldEnableModules = isUITesting
        #endif

        if shouldEnableModules {
            // Включаем готовые модули СИНХРОННО при старте
            // КРИТИЧЕСКИ ВАЖНО: Используем FeatureRegistryManager для уведомления UI
            FeatureRegistryManager.shared.enableReadyModules()
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authService)
                .environmentObject(authViewModel)
                .environmentObject(adminService)
                .environmentObject(feedbackManager)
                // .environment(\.managedObjectContext, persistenceController.container.viewContext)
                // .environmentObject(networkMonitor)
                .feedbackEnabled()
                .preferredColorScheme(.light)
                .onAppear {
                    // Auth status is checked automatically in MockAuthService.init()
                }
        }
    }

    private func setupAppearance() {
        // Navigation bar appearance
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.systemBackground
        appearance.titleTextAttributes = [.foregroundColor: UIColor.label]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.label]

        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance

        // Tab bar appearance
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithOpaqueBackground()
        tabBarAppearance.backgroundColor = UIColor.systemBackground

        UITabBar.appearance().standardAppearance = tabBarAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
    }
}

// Extension to fix the window reference warning
extension UIApplication {
    var currentWindow: UIWindow? {
        connectedScenes
            .filter { $0.activationState == .foregroundActive }
            .compactMap { $0 as? UIWindowScene }
            .first?
            .windows
            .filter { $0.isKeyWindow }
            .first
    }
}
