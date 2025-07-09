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
            // Try to load cached user or fetch from API
            Task {
                do {
                    if let cachedUser = loadCachedUser() {
                        self.currentUser = cachedUser
                    } else if !AppConfig.useMockData {
                        // Fetch user from API if not in mock mode
                        self.currentUser = try await getCurrentUser()
                    }
                } catch {
                    // If we can't get user, logout
                    await logout()
                }
            }
        }
    }

    // MARK: - Authentication Status
    private func checkAuthenticationStatus() {
        isAuthenticated = tokenManager.hasValidTokens()

        if isAuthenticated {
            if let user = loadCachedUser() {
                self.currentUser = user
            }
            updateAuthStatus()
        }
    }

    private func loadCachedUser() -> UserResponse? {
        // Load user from UserDefaults
        if let userData = UserDefaults.standard.data(forKey: "currentUser"),
           let user = try? JSONDecoder().decode(UserResponse.self, from: userData) {
            return user
        }
        return nil
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
        if AppConfig.useMockData {
            // Mock implementation for testing
            let user = UserResponse(
                id: UUID().uuidString,
                email: email,
                name: "Test User",
                role: email == "admin@lms.company.ru" ? .admin : .student,
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
        } else {
            // Real API implementation
            struct LoginRequest: Encodable {
                let email: String
                let password: String
            }
            
            let request = LoginRequest(email: email, password: password)
            let response: LoginResponse = try await apiClient.post("/auth/login", body: request)
            
            await MainActor.run {
                self.currentUser = response.user
                self.isAuthenticated = true
            }
            
            // Save tokens
            TokenManager.shared.saveTokens(
                accessToken: response.accessToken,
                refreshToken: response.refreshToken,
                expiresIn: response.expiresIn
            )
            
            // Save user to cache
            if let userData = try? JSONEncoder().encode(response.user) {
                UserDefaults.standard.set(userData, forKey: "currentUser")
            }
            
            return response
        }
    }

    // MARK: - Logout
    func logout() async {
        if !AppConfig.useMockData {
            // Try to call logout endpoint, but don't fail if it errors
            do {
                try await apiClient.post("/auth/logout", body: EmptyBody())
            } catch {
                // Ignore errors - we'll still clear local state
                print("Logout API call failed: \(error)")
            }
        }
        
        await MainActor.run {
            clearAuthState()
        }
    }

    // MARK: - Get Current User
    func getCurrentUser() async throws -> UserResponse {
        if AppConfig.useMockData {
            guard let user = currentUser else {
                throw APIError.unauthorized
            }
            return user
        } else {
            // Fetch from API
            let user: UserResponse = try await apiClient.get("/auth/me")
            
            await MainActor.run {
                self.currentUser = user
            }
            
            // Cache user
            if let userData = try? JSONEncoder().encode(user) {
                UserDefaults.standard.set(userData, forKey: "currentUser")
            }
            
            return user
        }
    }

    // MARK: - Refresh Token
    func refreshToken() async throws -> String {
        if AppConfig.useMockData {
            return "refreshed-mock-token"
        } else {
            guard let refreshToken = tokenManager.refreshToken else {
                throw APIError.unauthorized
            }
            
            struct RefreshRequest: Encodable {
                let refreshToken: String
            }
            
            struct RefreshResponse: Decodable {
                let accessToken: String
                let refreshToken: String
                let expiresIn: Int
            }
            
            let request = RefreshRequest(refreshToken: refreshToken)
            let response: RefreshResponse = try await apiClient.post("/auth/refresh", body: request)
            
            // Save new tokens
            tokenManager.saveTokens(
                accessToken: response.accessToken,
                refreshToken: response.refreshToken,
                expiresIn: response.expiresIn
            )
            
            return response.accessToken
        }
    }

    // MARK: - Update Profile
    func updateProfile(firstName: String, lastName: String) async throws -> UserResponse {
        if AppConfig.useMockData {
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
        } else {
            struct UpdateProfileRequest: Encodable {
                let firstName: String
                let lastName: String
            }
            
            let request = UpdateProfileRequest(firstName: firstName, lastName: lastName)
            let user: UserResponse = try await apiClient.put("/users/profile", body: request)
            
            await MainActor.run {
                self.currentUser = user
            }
            
            // Cache updated user
            if let userData = try? JSONEncoder().encode(user) {
                UserDefaults.standard.set(userData, forKey: "currentUser")
            }
            
            return user
        }
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

// MARK: - Empty Body for requests without payload
private struct EmptyBody: Encodable {}

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
