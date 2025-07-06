import Combine
import Foundation
import SwiftUI

// MARK: - MockAuthService
class MockAuthService: ObservableObject {
    static let shared = MockAuthService()

    @Published private(set) var currentUser: UserResponse?
    @Published private(set) var isAuthenticated = false
    @Published private(set) var isApprovedByAdmin = false
    @Published private(set) var isLoading = false
    @Published private(set) var error: String?

    private init() {
        checkAuthenticationStatus()
    }

    // MARK: - Mock Login
    func mockLogin(asAdmin: Bool = false) {
        isLoading = true
        error = nil

        // Simulate network delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.isLoading = false

            // Create mock user
            let mockUser = UserResponse(
                id: "mock_user_123",
                email: asAdmin ? "admin@tsum.ru" : "student@tsum.ru",
                name: asAdmin ? "Админ Админов" : "Иван Иванов",
                role: asAdmin ? "admin" : "student",
                department: "IT",
                isActive: true,
                avatar: nil,
                createdAt: Date(),
                updatedAt: Date()
            )

            // Save mock tokens
            TokenManager.shared.saveTokens(
                accessToken: "mock_access_token_\(UUID().uuidString)",
                refreshToken: "mock_refresh_token_\(UUID().uuidString)"
            )
            TokenManager.shared.userId = mockUser.id

            // Update state
            self.currentUser = mockUser
            self.isAuthenticated = true
            self.isApprovedByAdmin = asAdmin // Admins are auto-approved

            print("Mock login successful as \(asAdmin ? "Admin" : "Student")")
        }
    }

    // Alias for UI compatibility
    func loginAsMockUser(isAdmin: Bool) {
        mockLogin(asAdmin: isAdmin)
    }

    // MARK: - Login method for tests
    func login(email: String, password: String) {
        // For tests - simulate login based on email
        let isAdmin = email.contains("admin")
        mockLogin(asAdmin: isAdmin)
    }

    // MARK: - Mock Approve
    func mockApprove() {
        guard isAuthenticated && !isApprovedByAdmin else { return }

        isLoading = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.isLoading = false
            self.isApprovedByAdmin = true

            // Update user permissions
            if var user = self.currentUser {
                // Permissions are derived from role, no need to update
                self.currentUser = user
            }

            print("User approved by admin (mock)")
        }
    }

    // MARK: - Check Status
    private func checkAuthenticationStatus() {
        isAuthenticated = TokenManager.shared.isAuthenticated

        if isAuthenticated {
            // Restore mock user
            if let userId = TokenManager.shared.userId {
                let isAdmin = userId.contains("admin")
                currentUser = UserResponse(
                    id: userId,
                    email: isAdmin ? "admin@tsum.ru" : "student@tsum.ru",
                    name: isAdmin ? "Админ Админов" : "Иван Иванов",
                    role: isAdmin ? "admin" : "student",
                    department: "IT",
                    isActive: true,
                    avatar: nil,
                    createdAt: Date(),
                    updatedAt: Date()
                )
                isApprovedByAdmin = true
            }
        }
    }

    // MARK: - Logout
    func logout() {
        TokenManager.shared.clearTokens()
        currentUser = nil
        isAuthenticated = false
        isApprovedByAdmin = false
        error = nil
    }

    // MARK: - Get Users (for testing)
    func getUsers() -> [UserResponse] {
        [
            UserResponse(
                id: "user_1",
                email: "ivanov@tsum.ru",
                name: "Иван Петрович Иванов",
                role: "student",
                department: "Отдел продаж",
                isActive: true,
                avatar: nil,
                createdAt: Date(),
                updatedAt: Date()
            ),
            UserResponse(
                id: "user_2",
                email: "petrova@tsum.ru",
                name: "Мария Петрова",
                role: "student",
                department: "Операционный отдел",
                isActive: true,
                avatar: nil,
                createdAt: Date(),
                updatedAt: Date()
            ),
            UserResponse(
                id: "user_3",
                email: "sidorov@tsum.ru",
                name: "Алексей Сидоров",
                role: "student",
                department: "Отдел маркетинга",
                isActive: true,
                avatar: nil,
                createdAt: Date(),
                updatedAt: Date()
            ),
            UserResponse(
                id: "manager_1",
                email: "smirnov@tsum.ru",
                name: "Сергей Смирнов",
                role: "manager",
                department: "Отдел продаж",
                isActive: true,
                avatar: nil,
                createdAt: Date(),
                updatedAt: Date()
            ),
            UserResponse(
                id: "admin_1",
                email: "admin@tsum.ru",
                name: "Админ Админов",
                role: "admin",
                department: "IT",
                isActive: true,
                avatar: nil,
                createdAt: Date(),
                updatedAt: Date()
            )
        ]
    }
}

// MARK: - Mock Admin Service
class MockAdminService: ObservableObject {
    static let shared = MockAdminService()

    @Published var pendingUsers: [PendingUser] = []
    @Published var isLoading = false
    @Published var error: String?

    private init() {
        generateMockPendingUsers()
    }

    // MARK: - Generate Mock Data
    private func generateMockPendingUsers() {
        pendingUsers = [
            PendingUser(
                id: "pending_1",
                vkId: "123456789",
                email: "petrov@example.com",
                firstName: "Петр",
                lastName: "Петров",
                avatar: nil,
                registeredAt: "2025-06-25T10:00:00Z"
            ),
            PendingUser(
                id: "pending_2",
                vkId: "987654321",
                email: "sidorova@example.com",
                firstName: "Мария",
                lastName: "Сидорова",
                avatar: nil,
                registeredAt: "2025-06-25T11:30:00Z"
            ),
            PendingUser(
                id: "pending_3",
                vkId: "555666777",
                email: "kozlov@example.com",
                firstName: "Алексей",
                lastName: "Козлов",
                avatar: nil,
                registeredAt: "2025-06-25T14:15:00Z"
            )
        ]
    }

    // MARK: - Fetch Pending Users
    func fetchPendingUsers() {
        isLoading = true
        error = nil

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            self?.isLoading = false
            // Data already loaded in init
        }
    }

    // MARK: - Approve Users
    func approveSelectedUsers(userIds: [String], completion: @escaping (Bool) -> Void) {
        guard !userIds.isEmpty else {
            error = "Выберите хотя бы одного пользователя"
            completion(false)
            return
        }

        isLoading = true
        error = nil

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            self?.isLoading = false

            // Remove approved users
            self?.pendingUsers.removeAll { user in
                userIds.contains(user.id)
            }

            print("Approved \(userIds.count) users (mock)")
            completion(true)
        }
    }
}
