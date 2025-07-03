import Combine
import Foundation
import UIKit

// MARK: - AuthService
final class AuthService: ObservableObject {
    static let shared = AuthService()

    @Published private(set) var isAuthenticated = false
    @Published var currentUser: DomainUser?
    @Published private(set) var isLoading = false
    @Published private(set) var error: APIError?
    @Published private(set) var authStatus: AuthStatusDTO?

    private let apiClient = APIClient.shared
    private let tokenManager = TokenManager.shared
    var cancellables = Set<AnyCancellable>()

    private init() {
        // Check if user is already authenticated
        checkAuthenticationStatus()
    }

    // MARK: - Authentication Status
    private func checkAuthenticationStatus() {
        isAuthenticated = tokenManager.hasValidTokens

        if isAuthenticated {
            loadCachedUser()
            updateAuthStatus()
        }
    }

    private func loadCachedUser() {
        // Load user from UserDefaults using DTO
        if let userData = UserDefaults.standard.data(forKey: "currentUser"),
           let authUserProfileDTO = try? JSONDecoder().decode(AuthUserProfileDTO.self, from: userData) {
            
            // Convert AuthUserProfileDTO to DomainUser
            self.currentUser = AuthMapper.toDomainUser(from: authUserProfileDTO)
            self.isAuthenticated = true
        }
    }

    private func updateAuthStatus() {
        let tokenExpiresAt = tokenManager.tokenExpiryDate
        
        authStatus = AuthMapper.createAuthStatus(
            isAuthenticated: isAuthenticated,
            user: currentUser,
            tokenExpiresAt: tokenExpiresAt,
            lastLoginAt: currentUser?.lastLoginAt
        )
    }

    // MARK: - Login
    func login(email: String, password: String) async throws -> DomainUser {
        isLoading = true
        error = nil
        
        do {
            let endpoint = AuthEndpoint.login(email: email, password: password)
            let response: AuthResponse = try await apiClient.request(endpoint)
            
            // Save tokens
            tokenManager.saveTokens(
                accessToken: response.accessToken,
                refreshToken: response.refreshToken
            )
            
            // Convert to domain user
            let domainUser = DomainUser(
                id: response.user.id,
                email: response.user.email,
                name: response.user.name,
                role: response.user.role,
                avatarUrl: response.user.avatarUrl,
                createdAt: response.user.createdAt,
                updatedAt: response.user.updatedAt,
                lastLoginAt: Date()
            )
            
            // Update state
            currentUser = domainUser
            isAuthenticated = true
            updateAuthStatus()
            
            // Save to cache
            if let userData = try? JSONEncoder().encode(response.user) {
                UserDefaults.standard.set(userData, forKey: "currentUser")
            }
            
            isLoading = false
            return domainUser
            
        } catch let apiError as APIError {
            self.error = apiError
            isLoading = false
            throw apiError
        } catch {
            let apiError = APIError.unknown(statusCode: 0)
            self.error = apiError
            isLoading = false
            throw apiError
        }
    }

    // MARK: - Logout
    func logout() async throws {
        isLoading = true
        
        do {
            let endpoint = AuthEndpoint.logout
            try await apiClient.requestVoid(endpoint)
            clearAuthState()
        } catch {
            // Even if logout fails on server, clear local state
            clearAuthState()
        }
        
        isLoading = false
    }

    // MARK: - Get Current User
    func getCurrentUser() async throws -> DomainUser {
        let endpoint = AuthEndpoint.me
        let response: UserResponse = try await apiClient.request(endpoint)
        
        // Convert to domain user
        let domainUser = DomainUser(
            id: response.id,
            email: response.email,
            name: response.name,
            role: response.role,
            avatarUrl: response.avatarUrl,
            createdAt: response.createdAt,
            updatedAt: response.updatedAt,
            lastLoginAt: currentUser?.lastLoginAt
        )
        
        // Update state
        currentUser = domainUser
        updateAuthStatus()
        
        // Save to cache
        if let userData = try? JSONEncoder().encode(response) {
            UserDefaults.standard.set(userData, forKey: "currentUser")
        }
        
        return domainUser
    }

    // MARK: - Refresh Token
    func refreshTokenIfNeeded() async throws {
        guard tokenManager.hasValidTokens,
              let refreshToken = tokenManager.getRefreshToken() else {
            throw APIError.unauthorized
        }
        
        let endpoint = AuthEndpoint.refresh(token: refreshToken)
        let response: AuthResponse = try await apiClient.request(endpoint)
        
        // Save new tokens
        tokenManager.saveTokens(
            accessToken: response.accessToken,
            refreshToken: response.refreshToken
        )
        
        updateAuthStatus()
    }

    // MARK: - Authentication State Checks
    
    /// Check if current token needs refresh
    func needsTokenRefresh() -> Bool {
        guard let expiryDate = tokenManager.tokenExpiryDate else { return false }
        // Refresh if token expires within 5 minutes
        return Date().addingTimeInterval(300) >= expiryDate
    }
    
    /// Get time remaining until token expires
    func tokenTimeRemaining() -> TimeInterval {
        guard let expiryDate = tokenManager.tokenExpiryDate else {
            return 0
        }
        
        return expiryDate.timeIntervalSinceNow
    }
    
    /// Check if token is expired
    func isTokenExpired() -> Bool {
        guard let expiryDate = tokenManager.tokenExpiryDate else {
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
}

// MARK: - TokenManager Extension
extension TokenManager {
    var tokenExpiryDate: Date? {
        get {
            guard let interval = UserDefaults.standard.object(forKey: "tokenExpiryDate") as? TimeInterval else {
                return nil
            }
            return Date(timeIntervalSince1970: interval)
        }
        set {
            if let date = newValue {
                UserDefaults.standard.set(date.timeIntervalSince1970, forKey: "tokenExpiryDate")
            } else {
                UserDefaults.standard.removeObject(forKey: "tokenExpiryDate")
            }
        }
    }
    
    var isAuthenticated: Bool {
        return hasValidTokens
    }
}

// MARK: - Notification Names
extension NSNotification.Name {
    static let userDidLogout = NSNotification.Name("userDidLogout")
}
