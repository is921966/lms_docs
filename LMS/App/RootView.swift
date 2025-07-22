import SwiftUI

struct RootView: View {
    @EnvironmentObject var coordinator: AppCoordinator
    @EnvironmentObject var container: DIContainer
    
    var body: some View {
        if coordinator.isAuthenticated {
            MainTabView()
                .environmentObject(coordinator)
                .environmentObject(container)
        } else {
            LoginView(viewModel: container.makeLoginViewModel())
                .environmentObject(coordinator)
                .environmentObject(container)
        }
    }
}

struct MainTabView: View {
    @EnvironmentObject var coordinator: AppCoordinator
    @EnvironmentObject var container: DIContainer
    
    var body: some View {
        TabView(selection: $coordinator.currentTab) {
            ForEach(AppCoordinator.Tab.allCases, id: \.self) { tab in
                NavigationStack(path: $coordinator.navigationPath) {
                    tabContent(for: tab)
                        .navigationDestination(for: NavigationDestination.self) { destination in
                            destinationView(for: destination)
                        }
                }
                .tabItem {
                    Label(tab.title, systemImage: tab.icon)
                }
                .tag(tab)
            }
        }
    }
    
    @ViewBuilder
    private func tabContent(for tab: AppCoordinator.Tab) -> some View {
        switch tab {
        case .courses:
            CourseListView(viewModel: container.makeCourseListViewModel())
        case .feed:
            FeedView(viewModel: container.makeFeedViewModel())
        case .profile:
            ProfileView(viewModel: container.makeProfileViewModel())
        case .more:
            MoreMenuView()
        }
    }
    
    @ViewBuilder
    private func destinationView(for destination: NavigationDestination) -> some View {
        switch destination {
        case .courseDetail(let course):
            CourseDetailView(course: course)
        case .settings:
            SettingsView(viewModel: container.makeSettingsViewModel())
        case .feedback:
            FeedbackView()
        case .courseManagement:
            CourseManagementView()
        case .notifications:
            NotificationsView()
        }
    }
}

#Preview {
    RootView()
        .environmentObject(AppCoordinator())
        .environmentObject(DIContainer())
} 