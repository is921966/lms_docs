import SwiftUI

struct MainTabView: View {
    @StateObject private var authViewModel = AuthViewModel()
    @AppStorage("isAdminMode") private var isAdminMode = false
    @AppStorage("useNewFeedDesign") private var useNewFeedDesign = false
    @StateObject private var feedViewModel = TelegramFeedViewModel()
    @State private var selectedTab = 0
    @State private var showingSettings = false
    @State private var forceRefresh = UUID() // Для принудительного обновления
    
    init() {
        print("📱 MainTabView init")
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Feed Tab (New)
            feedTab
                .tabItem {
                    Label("Лента", systemImage: "newspaper.fill")
                }
                .tag(0)
                .badge(feedViewModel.totalUnreadCount)
            
            // Courses Tab
            NavigationStack {
                CourseListView()
            }
            .tabItem {
                Label("Courses", systemImage: "book.fill")
            }
            .tag(1)
            .badge(authViewModel.currentUser?.role == .student ? 3 : 0)
            
            // Users Tab (Admin only)
            if authViewModel.currentUser?.role == .admin || authViewModel.currentUser?.role == .superAdmin {
                NavigationStack {
                    UserListView()
                }
                .tabItem {
                    Label("Users", systemImage: "person.3.fill")
                }
                .tag(2)
            }
            
            // Profile Tab
            NavigationStack {
                ProfileView()
            }
            .tabItem {
                Label("Profile", systemImage: "person.crop.circle.fill")
            }
            .tag(3)
            
            // Settings Tab
            NavigationStack {
                SettingsView()
            }
            .tabItem {
                Label("Settings", systemImage: "gearshape.fill")
            }
            .tag(4)
        }
        .accentColor(isAdminMode ? .purple : .blue)
        .onAppear {
            setupAppearance()
        }
        .onChange(of: selectedTab) { oldValue, newValue in
            let tabNames = ["Лента", "Курсы", "Пользователи", "Профиль", "Настройки"]
            let tabName = tabNames[safe: newValue] ?? "Unknown"
            NavigationTracker.shared.tabSelected(tabName)
            
            ComprehensiveLogger.shared.log(.navigation, .info, "Tab changed", details: [
                "oldTab": oldValue,
                "newTab": newValue,
                "tabName": tabName
            ])
        }
        .sheet(isPresented: $authViewModel.showingLogin) {
            LoginView()
                .interactiveDismissDisabled(true)
        }

    }
    
    private func setupAppearance() {
        // Tab bar appearance
        let appearance = UITabBarAppearance()
        appearance.configureWithDefaultBackground()
        appearance.backgroundColor = UIColor.secondarySystemBackground
        
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
        
        // Navigation bar appearance
        let navAppearance = UINavigationBarAppearance()
        navAppearance.configureWithDefaultBackground()
        
        UINavigationBar.appearance().standardAppearance = navAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navAppearance
    }
    
    // MARK: - Private Views
    
    @ViewBuilder
    private var feedTab: some View {
        NavigationStack {
            if useNewFeedDesign {
                TelegramFeedView()
                    .onAppear {
                        print("🆕 TelegramFeedView appeared")
                        print("   - useNewFeedDesign: \(useNewFeedDesign)")
                        print("   - UserDefaults useNewFeedDesign: \(UserDefaults.standard.bool(forKey: "useNewFeedDesign"))")
                        ComprehensiveLogger.shared.log(.ui, .info, "TelegramFeedView shown", details: [
                            "useNewFeedDesign": useNewFeedDesign,
                            "userDefaultsValue": UserDefaults.standard.bool(forKey: "useNewFeedDesign")
                        ])
                    }
            } else {
                FeedView()
                    .onAppear {
                        print("📰 Classic FeedView appeared")
                        print("   - useNewFeedDesign: \(useNewFeedDesign)")
                        print("   - UserDefaults useNewFeedDesign: \(UserDefaults.standard.bool(forKey: "useNewFeedDesign"))")
                        ComprehensiveLogger.shared.log(.ui, .info, "Classic FeedView shown", details: [
                            "useNewFeedDesign": useNewFeedDesign,
                            "userDefaultsValue": UserDefaults.standard.bool(forKey: "useNewFeedDesign")
                        ])
                    }
            }
        }
        .id(forceRefresh) // Используем UUID для гарантированного обновления
        .onReceive(NotificationCenter.default.publisher(for: FeedDesignManager.feedDesignChangedNotification)) { _ in
            print("⚡ Feed design changed notification received")
            // Принудительно обновляем view
            forceRefresh = UUID()
        }
    }
}

// MARK: - Tab Badge Helper
struct TabBadge: ViewModifier {
    let count: Int
    let color: Color
    
    func body(content: Content) -> some View {
        ZStack(alignment: .topTrailing) {
            content
            
            if count > 0 {
                Text("\(count)")
                    .font(.caption2)
                    .foregroundColor(.white)
                    .frame(minWidth: 16, minHeight: 16)
                    .background(color)
                    .clipShape(Circle())
                    .offset(x: 10, y: -10)
            }
        }
    }
}

// MARK: - Preview
struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
    }
} 