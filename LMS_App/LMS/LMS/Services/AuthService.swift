import Combine
import Foundation
import UIKit

// MARK: - AuthService
@MainActor
final class AuthService: ObservableObject, AuthServiceProtocol {
    static let shared = AuthService()

    @Published private(set) var isAuthenticated = false
    @Published private(set) var currentUser: UserResponse?
    @Published private(set) var isLoading = false
    @Published private(set) var error: APIError?
    @Published private(set) var authStatus: AuthStatusDTO?

    private let apiClient = APIClient.shared
    private let tokenManager = TokenManager.shared
    var cancellables = Set<AnyCancellable>()

    private init() {
        checkAuthState()
    }

    private func checkAuthState() {
        // Check if we have a valid token
        if TokenManager.shared.accessToken != nil {
            isAuthenticated = true
            // In a real app, we'd load the user from cache or make an API call
        }
    }

    // MARK: - Authentication Status
    private func checkAuthenticationStatus() {
        isAuthenticated = tokenManager.hasValidTokens()

        if isAuthenticated {
            loadCachedUser()
            updateAuthStatus()
        }
    }

    private func loadCachedUser() {
        // Load user from UserDefaults
        if let userData = UserDefaults.standard.data(forKey: "currentUser"),
           let user = try? JSONDecoder().decode(UserResponse.self, from: userData) {
            self.currentUser = user
            self.isAuthenticated = true
        }
    }

    private func updateAuthStatus() {
        let tokenExpiresAt = tokenManager.getTokenExpiryDate()
        let formatter = ISO8601DateFormatter()
        
        var userProfile: AuthUserProfileDTO? = nil
        if let user = currentUser {
            userProfile = AuthUserProfileDTO(
                id: user.id,
                email: user.email,
                firstName: user.firstName ?? user.name.components(separatedBy: " ").first ?? "",
                lastName: user.lastName ?? user.name.components(separatedBy: " ").last ?? "",
                role: user.role.rawValue,
                isActive: user.isActive,
                profileImageUrl: user.avatarURL
            )
        }
        
        authStatus = AuthStatusDTO(
            isAuthenticated: isAuthenticated,
            user: userProfile,
            tokenExpiresAt: tokenExpiresAt.map { formatter.string(from: $0) },
            lastLoginAt: nil
        )
    }

    // MARK: - Login
    func login(email: String, password: String) async throws -> LoginResponse {
        // Mock implementation
        let user = UserResponse(
            id: UUID().uuidString,
            email: email,
            name: "Test User",
            role: .admin,
            firstName: "Test",
            lastName: "User",
            department: "IT",
            isActive: true,
            createdAt: Date(),
            updatedAt: Date()
        )
        
        let response = LoginResponse(
            accessToken: "mock-access-token",
            refreshToken: "mock-refresh-token",
            user: user,
            expiresIn: 3600
        )
        
        await MainActor.run {
            self.currentUser = user
            self.isAuthenticated = true
        }
        
        // Save token
        TokenManager.shared.saveTokens(
            accessToken: response.accessToken,
            refreshToken: response.refreshToken,
            expiresIn: response.expiresIn
        )
        
        // Save user to cache
        if let userData = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(userData, forKey: "currentUser")
        }
        
        return response
    }

    // MARK: - Logout
    func logout() async throws {
        await MainActor.run {
            self.currentUser = nil
            self.isAuthenticated = false
        }
        
        // Clear tokens
        TokenManager.shared.clearTokens()
        
        // Clear cached user data
        UserDefaults.standard.removeObject(forKey: "currentUser")
    }

    // MARK: - Get Current User
    func getCurrentUser() async throws -> UserResponse {
        guard let user = currentUser else {
            throw APIError.unauthorized
        }
        return user
    }

    // MARK: - Refresh Token
    func refreshToken() async throws -> String {
        // Mock implementation
        return "refreshed-token"
    }

    // MARK: - Update Profile
    func updateProfile(firstName: String, lastName: String) async throws -> UserResponse {
        guard var user = currentUser else {
            throw APIError.unauthorized
        }
        
        // Update name fields
        user.firstName = firstName
        user.lastName = lastName
        user.name = "\(firstName) \(lastName)"
        user.updatedAt = Date()
        
        await MainActor.run {
            self.currentUser = user
        }
        
        // Save updated user to cache
        if let userData = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(userData, forKey: "currentUser")
        }
        
        return user
    }

    // MARK: - Authentication State Checks
    
    /// Check if current token needs refresh
    func needsTokenRefresh() -> Bool {
        guard let expiryDate = tokenManager.getTokenExpiryDate() else { return false }
        // Refresh if token expires within 5 minutes
        return Date().addingTimeInterval(300) >= expiryDate
    }
    
    /// Get time remaining until token expires
    func tokenTimeRemaining() -> TimeInterval {
        guard let expiryDate = tokenManager.getTokenExpiryDate() else {
            return 0
        }
        
        return expiryDate.timeIntervalSinceNow
    }
    
    /// Check if token is expired
    func isTokenExpired() -> Bool {
        guard let expiryDate = tokenManager.getTokenExpiryDate() else {
            return true
        }
        
        return Date() >= expiryDate
    }

    // MARK: - User Management
    func loadCurrentUser() {
        loadCachedUser()
        updateAuthStatus()
    }

    // MARK: - Private Methods
    private func clearAuthState() {
        tokenManager.clearTokens()
        currentUser = nil
        isAuthenticated = false
        isLoading = false
        error = nil
        authStatus = nil
        
        // Clear cached user data
        UserDefaults.standard.removeObject(forKey: "currentUser")
        
        // Post notification
        NotificationCenter.default.post(name: .userDidLogout, object: nil)
    }
    
    // MARK: - Testing Support
    
    /// Reset all state for testing purposes
    /// Only use this method in tests to ensure clean state
    func resetForTesting() {
        clearAuthState()
        // Force re-check of authentication status to ensure clean state
        checkAuthenticationStatus()
    }
}

// MARK: - TokenManager Extension
extension TokenManager {
    func saveTokenExpiryDate(_ expiryDate: Date?) {
        if let date = expiryDate {
            UserDefaults.standard.set(date.timeIntervalSince1970, forKey: "tokenExpiryDate")
        } else {
            UserDefaults.standard.removeObject(forKey: "tokenExpiryDate")
        }
    }
    
    func getTokenExpiryDate() -> Date? {
        guard let interval = UserDefaults.standard.object(forKey: "tokenExpiryDate") as? TimeInterval else {
            return nil
        }
        return Date(timeIntervalSince1970: interval)
    }
    
    var isAuthenticated: Bool {
        return hasValidTokens()
    }
}

// MARK: - Notification Names
extension NSNotification.Name {
    static let userDidLogout = NSNotification.Name("userDidLogout")
}
