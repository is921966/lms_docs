import Combine
import Foundation
import UIKit

// MARK: - AuthService
final class AuthService: ObservableObject {
    static let shared = AuthService()

    @Published private(set) var isAuthenticated = false
    @Published var currentUser: DomainUser?
    @Published private(set) var isLoading = false
    @Published private(set) var error: NetworkError?
    @Published private(set) var authStatus: AuthStatusDTO?

    private let networkService = NetworkService.shared
    var cancellables = Set<AnyCancellable>()

    private init() {
        // Check if user is already authenticated
        checkAuthenticationStatus()
    }

    // MARK: - Authentication Status
    private func checkAuthenticationStatus() {
        isAuthenticated = TokenManager.shared.isAuthenticated

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
        let tokenExpiresAt = TokenManager.shared.tokenExpiryDate
        
        authStatus = AuthMapper.createAuthStatus(
            isAuthenticated: isAuthenticated,
            user: currentUser,
            tokenExpiresAt: tokenExpiresAt,
            lastLoginAt: currentUser?.lastLoginAt
        )
    }

    // MARK: - Login with DTO
    func login(email: String, password: String, rememberMe: Bool = false) -> AnyPublisher<DomainUser, NetworkError> {
        isLoading = true
        error = nil

        let loginRequestDTO = AuthMapper.createLoginRequest(
            email: email,
            password: password,
            rememberMe: rememberMe,
            deviceId: UIDevice.current.identifierForVendor?.uuidString
        )

        return networkService.post(
            endpoint: "/auth/login",
            body: loginRequestDTO,
            responseType: LoginResponseDTO.self
        )
        .handleEvents(
            receiveOutput: { [weak self] response in
                self?.handleLoginResponse(response)
                self?.isLoading = false
            },
            receiveCompletion: { [weak self] completion in
                self?.isLoading = false

                if case .failure(let error) = completion {
                    self?.error = error
                }
            }
        )
        .compactMap { [weak self] _ in
            self?.currentUser
        }
        .eraseToAnyPublisher()
    }

    // MARK: - Logout with DTO
    func logout(logoutAllDevices: Bool = false) -> AnyPublisher<Void, NetworkError> {
        isLoading = true

        let logoutRequestDTO = AuthMapper.createLogoutRequest(
            refreshToken: TokenManager.shared.refreshToken,
            deviceId: UIDevice.current.identifierForVendor?.uuidString,
            logoutAllDevices: logoutAllDevices
        )

        return networkService.post(
            endpoint: "/auth/logout",
            body: logoutRequestDTO,
            responseType: EmptyResponse.self
        )
        .handleEvents(
            receiveOutput: { [weak self] _ in
                self?.clearAuthState()
            }
        )
        .map { _ in () }
        .catch { [weak self] _ -> AnyPublisher<Void, NetworkError> in
            // Even if logout fails on server, clear local state
            self?.clearAuthState()
            return Just(()).setFailureType(to: NetworkError.self).eraseToAnyPublisher()
        }
        .eraseToAnyPublisher()
    }

    // MARK: - Refresh Token with DTO
    func refreshToken() -> AnyPublisher<Void, NetworkError> {
        guard let refreshToken = TokenManager.shared.refreshToken else {
            return Fail(error: NetworkError.unauthorized)
                .eraseToAnyPublisher()
        }

        let refreshRequestDTO = AuthMapper.createTokenRefreshRequest(
            refreshToken: refreshToken,
            deviceId: UIDevice.current.identifierForVendor?.uuidString
        )

        return networkService.post(
            endpoint: "/auth/refresh",
            body: refreshRequestDTO,
            responseType: TokenRefreshResponseDTO.self
        )
        .handleEvents(
            receiveOutput: { [weak self] response in
                self?.handleTokenRefreshResponse(response)
            }
        )
        .map { _ in () }
        .eraseToAnyPublisher()
    }

    // MARK: - Get Current User with DTO
    func getCurrentUser() -> AnyPublisher<DomainUser, NetworkError> {
        networkService.get(
            endpoint: "/users/me",
            responseType: AuthUserProfileDTO.self
        )
        .handleEvents(
            receiveOutput: { [weak self] authUserProfileDTO in
                // Convert AuthUserProfileDTO to DomainUser
                self?.currentUser = AuthMapper.toDomainUser(from: authUserProfileDTO)
                self?.updateAuthStatus()
                
                // Save to cache
                if let userData = try? JSONEncoder().encode(authUserProfileDTO) {
                    UserDefaults.standard.set(userData, forKey: "currentUser")
                }
            }
        )
        .compactMap { [weak self] _ in
            self?.currentUser
        }
        .eraseToAnyPublisher()
    }

    // MARK: - Authentication State Checks
    
    /// Check if current token needs refresh
    func needsTokenRefresh() -> Bool {
        guard let expiryDate = TokenManager.shared.tokenExpiryDate else { return false }
        // Refresh if token expires within 5 minutes
        return Date().addingTimeInterval(300) >= expiryDate
    }
    
    /// Get time remaining until token expires
    func tokenTimeRemaining() -> TimeInterval {
        guard let expiryDate = TokenManager.shared.tokenExpiryDate else {
            return 0
        }
        
        return expiryDate.timeIntervalSinceNow
    }
    
    /// Check if token is expired
    func isTokenExpired() -> Bool {
        guard let expiryDate = TokenManager.shared.tokenExpiryDate else {
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
        TokenManager.shared.clearTokens()
        currentUser = nil
        isAuthenticated = false
        isLoading = false
        error = nil
        authStatus = nil
        
        // Clear cached user data
        UserDefaults.standard.removeObject(forKey: "currentUser")
    }

    private func handleLoginResponse(_ response: LoginResponseDTO) {
        // Validate response DTO
        let validationErrors = response.validationErrors()
        if !validationErrors.isEmpty {
            error = NetworkError.serverError(statusCode: 500, data: "Invalid login response: \(validationErrors.joined(separator: ", "))".data(using: .utf8))
            return
        }
        
        // Extract tokens and expiry date
        let tokens = AuthMapper.extractTokens(from: response)
        let expiresAt = AuthMapper.extractExpiryDate(from: response)
        
        // Save tokens
        TokenManager.shared.saveTokens(
            accessToken: tokens.accessToken,
            refreshToken: tokens.refreshToken
        )
        
        // Set expiry date if available
        if let expiresAt = expiresAt {
            TokenManager.shared.tokenExpiryDate = expiresAt
        }

        // Convert user profile to domain user
        currentUser = AuthMapper.toDomainUser(from: response)

        // Update state
        isAuthenticated = true
        updateAuthStatus()

        // Save user data to cache
        if let userData = try? JSONEncoder().encode(response.user) {
            UserDefaults.standard.set(userData, forKey: "currentUser")
        }
    }
    
    private func handleTokenRefreshResponse(_ response: TokenRefreshResponseDTO) {
        // Validate response DTO
        let validationErrors = response.validationErrors()
        if !validationErrors.isEmpty {
            error = NetworkError.serverError(statusCode: 500, data: "Invalid token refresh response: \(validationErrors.joined(separator: ", "))".data(using: .utf8))
            return
        }
        
        // Extract tokens and expiry date
        let tokens = AuthMapper.extractTokens(from: response)
        let expiresAt = AuthMapper.extractExpiryDate(from: response)
        
        // Save new tokens
        TokenManager.shared.saveTokens(
            accessToken: tokens.accessToken,
            refreshToken: tokens.refreshToken
        )
        
        // Set expiry date if available
        if let expiresAt = expiresAt {
            TokenManager.shared.tokenExpiryDate = expiresAt
        }
        
        // Update auth status
        updateAuthStatus()
    }
}

// MARK: - Helper Types
private struct EmptyResponse: Decodable {}

// MARK: - Notification Names
extension NSNotification.Name {
    static let userDidLogout = NSNotification.Name("userDidLogout")
}
