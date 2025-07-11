import SwiftUI

struct MainTabView: View {
    @StateObject private var authViewModel = AuthViewModel()
    @AppStorage("isAdminMode") private var isAdminMode = false
    @State private var selectedTab = 0
    @State private var showingSettings = false
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Courses Tab
            NavigationStack {
                CourseListView()
            }
            .tabItem {
                Label("Courses", systemImage: "book.fill")
            }
            .tag(0)
            .badge(authViewModel.currentUser?.role == .student ? 3 : 0)
            
            // Users Tab (Admin only)
            if authViewModel.currentUser?.role == .admin || authViewModel.currentUser?.role == .superAdmin {
                NavigationStack {
                    UserListView()
                }
                .tabItem {
                    Label("Users", systemImage: "person.3.fill")
                }
                .tag(1)
            }
            
            // Profile Tab
            NavigationStack {
                ProfileView()
            }
            .tabItem {
                Label("Profile", systemImage: "person.crop.circle.fill")
            }
            .tag(2)
            
            // Settings Tab
            NavigationStack {
                SettingsView()
            }
            .tabItem {
                Label("Settings", systemImage: "gearshape.fill")
            }
            .tag(3)
        }
        .accentColor(isAdminMode ? .purple : .blue)
        .onAppear {
            setupAppearance()
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