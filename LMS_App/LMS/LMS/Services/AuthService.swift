import Foundation
import Combine

// MARK: - AuthService
class AuthService: ObservableObject {
    static let shared = AuthService()
    
    @Published private(set) var currentUser: UserResponse?
    @Published private(set) var isAuthenticated = false
    @Published private(set) var isLoading = false
    @Published private(set) var error: NetworkError?
    
    private let networkService = NetworkService.shared
    var cancellables = Set<AnyCancellable>()  // Made public for external use
    
    private init() {
        // Check if user is already authenticated
        checkAuthenticationStatus()
    }
    
    // MARK: - Authentication Status
    private func checkAuthenticationStatus() {
        isAuthenticated = TokenManager.shared.isAuthenticated
        
        if isAuthenticated {
            // Try to load user info from cache
            loadCachedUser()
        }
    }
    
    private func loadCachedUser() {
        // TODO: Implement user caching
    }
    
    // MARK: - Login
    func login(email: String, password: String) -> AnyPublisher<UserResponse, NetworkError> {
        isLoading = true
        error = nil
        
        let loginRequest = LoginRequest(email: email, password: password)
        
        return networkService.post(
            endpoint: "/auth/login",
            body: loginRequest,
            responseType: LoginResponse.self
        )
        .handleEvents(
            receiveOutput: { [weak self] response in
                // Save tokens
                TokenManager.shared.saveTokens(
                    accessToken: response.tokens.accessToken,
                    refreshToken: response.tokens.refreshToken
                )
                TokenManager.shared.userId = response.user.id
                
                // Update state
                self?.currentUser = response.user
                self?.isAuthenticated = true
                self?.isLoading = false
            },
            receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                
                if case .failure(let error) = completion {
                    self?.error = error
                }
            }
        )
        .map { $0.user }
        .eraseToAnyPublisher()
    }
    
    // MARK: - Logout
    func logout() -> AnyPublisher<Void, NetworkError> {
        isLoading = true
        
        return networkService.post(
            endpoint: "/auth/logout",
            body: EmptyBody(),
            responseType: EmptyResponse.self
        )
        .handleEvents(
            receiveCompletion: { [weak self] _ in
                self?.clearAuthState()
            }
        )
        .map { _ in () }
        .catch { [weak self] error -> AnyPublisher<Void, NetworkError> in
            // Even if logout fails on server, clear local state
            self?.clearAuthState()
            return Just(()).setFailureType(to: NetworkError.self).eraseToAnyPublisher()
        }
        .eraseToAnyPublisher()
    }
    
    // MARK: - Refresh Token
    func refreshToken() -> AnyPublisher<Void, NetworkError> {
        guard let refreshToken = TokenManager.shared.refreshToken else {
            return Fail(error: NetworkError.unauthorized)
                .eraseToAnyPublisher()
        }
        
        let request = RefreshTokenRequest(refreshToken: refreshToken)
        
        return networkService.post(
            endpoint: "/auth/refresh",
            body: request,
            responseType: TokensResponse.self
        )
        .handleEvents(
            receiveOutput: { [weak self] response in
                TokenManager.shared.saveTokens(
                    accessToken: response.accessToken,
                    refreshToken: response.refreshToken
                )
            }
        )
        .map { _ in () }
        .eraseToAnyPublisher()
    }
    
    // MARK: - Get Current User
    func getCurrentUser() -> AnyPublisher<UserResponse, NetworkError> {
        networkService.get(
            endpoint: "/users/me",
            responseType: UserResponse.self
        )
        .handleEvents(
            receiveOutput: { [weak self] user in
                self?.currentUser = user
            }
        )
        .eraseToAnyPublisher()
    }
    
    // MARK: - Private Methods
    private func clearAuthState() {
        TokenManager.shared.clearTokens()
        currentUser = nil
        isAuthenticated = false
        isLoading = false
        error = nil
    }
}

// MARK: - Helper Types
private struct EmptyBody: Encodable {}
private struct EmptyResponse: Decodable {} 