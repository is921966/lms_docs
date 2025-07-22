import SwiftUI

@main
struct LMSApp: App {
    @StateObject private var appCoordinator = AppCoordinator()
    @StateObject private var diContainer = DIContainer()
    
    init() {
        setupAppearance()
        configureDependencies()
    }
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(appCoordinator)
                .environmentObject(diContainer)
                .onAppear {
                    appCoordinator.start()
                }
        }
    }
    
    private func setupAppearance() {
        // Configure navigation bar appearance
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.systemBackground
        appearance.titleTextAttributes = [.foregroundColor: UIColor.label]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.label]
        
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        
        // Configure tab bar appearance
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithOpaqueBackground()
        tabBarAppearance.backgroundColor = UIColor.systemBackground
        
        UITabBar.appearance().standardAppearance = tabBarAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
    }
    
    private func configureDependencies() {
        // Dependencies will be configured in DIContainer
    }
} 