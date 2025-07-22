import SwiftUI

@main
struct LMSApp: App {
    @StateObject private var appCoordinator = AppCoordinator()
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(appCoordinator)
        }
    }
}
