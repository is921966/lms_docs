import Combine
import Foundation
import SwiftUI

// MARK: - MockAuthService
@MainActor
class MockAuthService: ObservableObject, AuthServiceProtocol {
    static let shared = MockAuthService()

    @Published private(set) var currentUser: UserResponse?
    @Published private(set) var isAuthenticated = false
    @Published private(set) var isApprovedByAdmin = false
    @Published private(set) var isLoading = false
    @Published private(set) var error: String?
    
    // Test helpers
    var shouldFail = false
    var authError: Error?
    var hasRefreshedToken = false

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
                role: asAdmin ? .admin : .student,
                firstName: asAdmin ? "Админ" : "Иван",
                lastName: asAdmin ? "Админов" : "Иванов",
                department: "IT",
                isActive: true,
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

    // MARK: - Login method for tests (AuthServiceProtocol)
    func login(email: String, password: String) async throws -> LoginResponse {
        // For testing: check if we should fail
        if shouldFail {
            if let error = authError {
                throw error
            } else {
                throw APIError.invalidCredentials
            }
        }
        
        // For tests - simulate login based on email
        let role: UserRole
        if email.contains("superadmin") {
            role = .superAdmin
        } else if email.contains("admin") {
            role = .admin
        } else if email.contains("instructor") {
            role = .instructor
        } else if email.contains("manager") {
            role = .manager
        } else {
            role = .student
        }
        
        let mockUser = UserResponse(
            id: "mock_user_\(UUID().uuidString)",
            email: email,
            name: "Test User",
            role: role,
            firstName: "Test",
            lastName: "User",
            department: "IT",
            isActive: true,
            createdAt: Date(),
            updatedAt: Date()
        )
        
        let accessToken = "mock_access_token_\(UUID().uuidString)"
        let refreshToken = "mock_refresh_token_\(UUID().uuidString)"
        let expiresIn = 3600
        
        // Save tokens and update state
        TokenManager.shared.saveTokens(
            accessToken: accessToken,
            refreshToken: refreshToken,
            expiresIn: expiresIn
        )
        TokenManager.shared.userId = mockUser.id
        
        self.currentUser = mockUser
        self.isAuthenticated = true
        self.isApprovedByAdmin = (role == .admin || role == .superAdmin)
        
        return LoginResponse(
            accessToken: accessToken,
            refreshToken: refreshToken,
            user: mockUser,
            expiresIn: expiresIn
        )
    }
    
    // MARK: - Refresh Token (AuthServiceProtocol)
    func refreshToken() async throws -> String {
        // For testing: mark that token was refreshed
        hasRefreshedToken = true
        
        // Mock implementation - just return a new token
        return "mock_access_token_\(UUID().uuidString)"
    }
    
    // MARK: - Get Current User (AuthServiceProtocol)
    func getCurrentUser() async throws -> UserResponse {
        guard let user = currentUser else {
            throw APIError.unauthorized
        }
        return user
    }
    
    // MARK: - Update Profile (AuthServiceProtocol)
    func updateProfile(firstName: String, lastName: String) async throws -> UserResponse {
        guard var user = currentUser else {
            throw APIError.unauthorized
        }
        
        user.firstName = firstName
        user.lastName = lastName
        user.name = "\(firstName) \(lastName)"
        user.updatedAt = Date()
        
        self.currentUser = user
        return user
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
        isAuthenticated = TokenManager.shared.hasValidTokens()

        if isAuthenticated {
            // Restore mock user
            if let userId = TokenManager.shared.userId {
                let isAdmin = userId.contains("admin")
                currentUser = UserResponse(
                    id: userId,
                    email: isAdmin ? "admin@tsum.ru" : "student@tsum.ru",
                    name: isAdmin ? "Админ Админов" : "Иван Иванов",
                    role: isAdmin ? .admin : .student,
                    firstName: isAdmin ? "Админ" : "Иван",
                    lastName: isAdmin ? "Админов" : "Иванов",
                    department: "IT",
                    isActive: true,
                    createdAt: Date(),
                    updatedAt: Date()
                )
                isApprovedByAdmin = true
            }
        }
    }

    // MARK: - Logout
    func logout() async throws {
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
                role: .student,
                firstName: "Иван",
                lastName: "Иванов",
                middleName: "Петрович",
                department: "Отдел продаж",
                isActive: true,
                createdAt: Date(),
                updatedAt: Date()
            ),
            UserResponse(
                id: "user_2",
                email: "petrova@tsum.ru",
                name: "Мария Петрова",
                role: .student,
                firstName: "Мария",
                lastName: "Петрова",
                department: "Операционный отдел",
                isActive: true,
                createdAt: Date(),
                updatedAt: Date()
            ),
            UserResponse(
                id: "user_3",
                email: "sidorov@tsum.ru",
                name: "Алексей Сидоров",
                role: .student,
                firstName: "Алексей",
                lastName: "Сидоров",
                department: "Отдел маркетинга",
                isActive: true,
                createdAt: Date(),
                updatedAt: Date()
            ),
            UserResponse(
                id: "manager_1",
                email: "smirnov@tsum.ru",
                name: "Сергей Смирнов",
                role: .manager,
                firstName: "Сергей",
                lastName: "Смирнов",
                department: "Отдел продаж",
                isActive: true,
                createdAt: Date(),
                updatedAt: Date()
            ),
            UserResponse(
                id: "admin_1",
                email: "admin@tsum.ru",
                name: "Админ Админов",
                role: .admin,
                firstName: "Админ",
                lastName: "Админов",
                department: "IT",
                isActive: true,
                createdAt: Date(),
                updatedAt: Date()
            )
        ]
    }

    // MARK: - Test Helpers
    
    /// Reset authentication state for tests
    func resetForTesting() {
        TokenManager.shared.clearTokens()
        currentUser = nil
        isAuthenticated = false
        isApprovedByAdmin = false
        error = nil
        shouldFail = false
        authError = nil
        hasRefreshedToken = false
    }
    
    /// Set authenticated state for tests
    func setAuthenticatedForTesting(user: UserResponse) {
        self.currentUser = user
        self.isAuthenticated = true
        self.isApprovedByAdmin = (user.role == .admin || user.role == .superAdmin)
        TokenManager.shared.userId = user.id
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
