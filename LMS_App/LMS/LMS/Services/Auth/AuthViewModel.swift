import Foundation
import SwiftUI
import Combine

// MARK: - User Role
enum UserRole: String, Codable, CaseIterable {
    case student = "student"
    case moderator = "moderator"
    case admin = "admin"
    case superAdmin = "superAdmin"
}

// MARK: - User Model for ViewModel
struct User: Identifiable {
    let id: String
    let email: String
    let firstName: String
    let lastName: String
    let role: UserRole

    init(from userResponse: UserResponse) {
        self.id = userResponse.id
        self.email = userResponse.email
        self.firstName = userResponse.firstName
        self.lastName = userResponse.lastName

        // Determine role from roles array
        if userResponse.roles.contains("superAdmin") {
            self.role = .superAdmin
        } else if userResponse.roles.contains("admin") {
            self.role = .admin
        } else if userResponse.roles.contains("moderator") {
            self.role = .moderator
        } else {
            self.role = .student
        }
    }
}

// MARK: - Auth ViewModel
class AuthViewModel: ObservableObject {
    @Published var currentUser: User?
    @Published var isAuthenticated: Bool = false

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
                userResponse.map { User(from: $0) }
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
