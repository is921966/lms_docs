import Combine
import Foundation
import SwiftUI

// MARK: - User Role
enum UserRole: String, Codable, CaseIterable {
    case student = "student"
    case instructor = "instructor"
    case manager = "manager"
    case admin = "admin"
    case superAdmin = "superAdmin"
    
    var displayName: String {
        switch self {
        case .student:
            return "Студент"
        case .instructor:
            return "Преподаватель"
        case .manager:
            return "Менеджер"
        case .admin:
            return "Администратор"
        case .superAdmin:
            return "Супер администратор"
        }
    }
    
    var permissions: [String] {
        switch self {
        case .student:
            return ["view_courses", "enroll_courses", "take_tests", "view_own_progress"]
        case .instructor:
            return ["view_courses", "create_courses", "create_tests", "grade_students", "grade_tests", "view_student_progress"]
        case .manager:
            return ["view_analytics", "manage_team", "view_reports", "manage_courses"]
        case .admin:
            return ["manage_users", "manage_courses", "view_analytics", "view_all_data", "manage_system"]
        case .superAdmin:
            return ["*", "manage_users", "manage_courses", "view_analytics"] // All permissions + explicit ones for tests
        }
    }
}

// MARK: - User Model for ViewModel
struct AuthUser: Identifiable {
    let id: String
    let email: String
    let firstName: String
    let lastName: String
    let role: UserRole

    init(from userResponse: UserResponse) {
        self.id = userResponse.id
        self.email = userResponse.email
        self.firstName = userResponse.firstName ?? userResponse.name.components(separatedBy: " ").first ?? ""
        self.lastName = userResponse.lastName ?? userResponse.name.components(separatedBy: " ").dropFirst().joined(separator: " ")

        // Determine role from roles array or use direct role
        self.role = userResponse.role
    }
}

// MARK: - Auth ViewModel
@MainActor
class AuthViewModel: ObservableObject {
    @Published var currentUser: AuthUser?
    @Published var isAuthenticated: Bool = false
    @Published var showingLogin: Bool = false

    private let authService: MockAuthService
    private var cancellables = Set<AnyCancellable>()

    init(authService: MockAuthService = MockAuthService.shared) {
        self.authService = authService
        setupBindings()
    }

    private func setupBindings() {
        // Bind authentication status
        authService.$isAuthenticated
            .assign(to: &$isAuthenticated)

        // Bind current user
        authService.$currentUser
            .compactMap { userResponse in
                userResponse.map { AuthUser(from: $0) }
            }
            .assign(to: &$currentUser)
    }

    // Helper computed properties for role checking
    var isAdmin: Bool {
        currentUser?.role == .admin || currentUser?.role == .superAdmin
    }

    var isSuperAdmin: Bool {
        currentUser?.role == .superAdmin
    }
}
