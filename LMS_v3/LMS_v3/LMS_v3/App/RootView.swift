import SwiftUI

struct RootView: View {
    @EnvironmentObject var coordinator: AppCoordinator
    
    var body: some View {
        Group {
            if coordinator.isAuthenticated {
                MainTabView()
            } else {
                LoginView()
            }
        }
    }
}

struct MainTabView: View {
    var body: some View {
        TabView {
            CourseListView()
                .tabItem {
                    Label("Курсы", systemImage: "book.fill")
                }
            
            FeedView()
                .tabItem {
                    Label("Лента", systemImage: "newspaper.fill")
                }
            
            ProfileView()
                .tabItem {
                    Label("Профиль", systemImage: "person.fill")
                }
            
            SettingsView()
                .tabItem {
                    Label("Настройки", systemImage: "gear")
                }
        }
    }
}
