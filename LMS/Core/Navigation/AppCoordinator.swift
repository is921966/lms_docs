import SwiftUI
import Combine

final class AppCoordinator: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentTab: Tab = .courses
    @Published var navigationPath = NavigationPath()
    
    private var cancellables = Set<AnyCancellable>()
    
    enum Tab: Int, CaseIterable {
        case courses = 0
        case feed = 1
        case profile = 2
        case more = 3
        
        var title: String {
            switch self {
            case .courses: return "Курсы"
            case .feed: return "Лента"
            case .profile: return "Профиль"
            case .more: return "Ещё"
            }
        }
        
        var icon: String {
            switch self {
            case .courses: return "book.fill"
            case .feed: return "newspaper.fill"
            case .profile: return "person.fill"
            case .more: return "ellipsis"
            }
        }
    }
    
    func start() {
        checkAuthentication()
    }
    
    private func checkAuthentication() {
        // Check if user is authenticated
        // For now, we'll simulate authentication
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.isAuthenticated = true
        }
    }
    
    func logout() {
        isAuthenticated = false
        currentTab = .courses
        navigationPath = NavigationPath()
    }
    
    // MARK: - Navigation Methods
    
    func showCourseDetail(_ course: Course) {
        navigationPath.append(NavigationDestination.courseDetail(course))
    }
    
    func showProfile() {
        currentTab = .profile
    }
    
    func showSettings() {
        navigationPath.append(NavigationDestination.settings)
    }
    
    func showFeedback() {
        navigationPath.append(NavigationDestination.feedback)
    }
    
    func pop() {
        if !navigationPath.isEmpty {
            navigationPath.removeLast()
        }
    }
    
    func popToRoot() {
        navigationPath = NavigationPath()
    }
}

// MARK: - Navigation Destinations

enum NavigationDestination: Hashable {
    case courseDetail(Course)
    case settings
    case feedback
    case courseManagement
    case notifications
    
    static func == (lhs: NavigationDestination, rhs: NavigationDestination) -> Bool {
        switch (lhs, rhs) {
        case (.courseDetail(let lhsCourse), .courseDetail(let rhsCourse)):
            return lhsCourse.id == rhsCourse.id
        case (.settings, .settings),
             (.feedback, .feedback),
             (.courseManagement, .courseManagement),
             (.notifications, .notifications):
            return true
        default:
            return false
        }
    }
    
    func hash(into hasher: inout Hasher) {
        switch self {
        case .courseDetail(let course):
            hasher.combine("courseDetail")
            hasher.combine(course.id)
        case .settings:
            hasher.combine("settings")
        case .feedback:
            hasher.combine("feedback")
        case .courseManagement:
            hasher.combine("courseManagement")
        case .notifications:
            hasher.combine("notifications")
        }
    }
} 