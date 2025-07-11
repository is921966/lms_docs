import Foundation
import Combine

// MARK: - AuthService

/// Сервис для аутентификации и авторизации
@MainActor
final class AuthService: ObservableObject {
    
    // MARK: - Properties
    
    static let shared = AuthService()
    
    @Published private(set) var isAuthenticated = false
    @Published private(set) var currentUser: UserResponse?
    @Published private(set) var isLoading = false
    @Published private(set) var error: APIError?
    
    private let apiClient = APIClient.shared
    private let tokenManager = TokenManager.shared
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    
    private init() {
        checkAuthenticationStatus()
    }
    
    // MARK: - Public Methods
    
    /// Вход в систему
    func login(email: String, password: String) async throws -> UserResponse {
        isLoading = true
        error = nil
        
        do {
            let credentials = LoginRequest(email: email, password: password)
            let endpoint = AuthEndpoint.login(credentials: credentials)
            let response: AuthResponse = try await apiClient.request(endpoint)
            
            // Сохраняем токены
            tokenManager.saveTokens(
                accessToken: response.accessToken,
                refreshToken: response.refreshToken,
                expiresIn: response.expiresIn
            )
            
            // Сохраняем пользователя
            currentUser = response.user
            isAuthenticated = true
            
            // Сохраняем ID пользователя для backward compatibility
            tokenManager.userId = response.user.id
            
            isLoading = false
            return response.user
            
        } catch let apiError as APIError {
            error = apiError
            isLoading = false
            throw apiError
        } catch {
            let apiError = APIError.unknown(statusCode: 0)
            self.error = apiError
            isLoading = false
            throw apiError
        }
    }
    
    /// Выход из системы
    func logout() async {
        isLoading = true
        
        // Try to logout on server
        do {
            let endpoint = AuthEndpoint.logout
            try await apiClient.requestVoid(endpoint)
        } catch {
            // Ignore logout errors - clear local state anyway
        }
        
        // Clear local state
        tokenManager.clearTokens()
        currentUser = nil
        isAuthenticated = false
        error = nil
        isLoading = false
    }
    
    /// Обновление токена
    func refreshToken() async throws -> String {
        guard let refreshToken = tokenManager.refreshToken else {
            throw APIError.unauthorized
        }
        
        do {
            let request = RefreshTokenRequest(refreshToken: refreshToken)
            let endpoint = AuthEndpoint.refreshToken(request: request)
            let response: AuthResponse = try await apiClient.request(endpoint)
            
            // Сохраняем новые токены
            tokenManager.saveTokens(
                accessToken: response.accessToken,
                refreshToken: response.refreshToken,
                expiresIn: response.expiresIn
            )
            
            // Обновляем пользователя если пришел
            currentUser = response.user
            
            return response.accessToken
            
        } catch {
            // При ошибке обновления токена - выходим
            await logout()
            throw error
        }
    }
    
    /// Получение текущего пользователя
    func getCurrentUser() async throws -> UserResponse {
        isLoading = true
        error = nil
        
        do {
            let endpoint = AuthEndpoint.getCurrentUser
            let user: UserResponse = try await apiClient.request(endpoint)
            
            currentUser = user
            isLoading = false
            return user
            
        } catch let apiError as APIError {
            error = apiError
            isLoading = false
            
            // При 401 ошибке пробуем обновить токен
            if apiError == .unauthorized {
                _ = try await refreshToken()
                return try await getCurrentUser()
            }
            
            throw apiError
        } catch {
            let apiError = APIError.unknown(statusCode: 0)
            self.error = apiError
            isLoading = false
            throw apiError
        }
    }
    
    /// Обновление профиля пользователя
    func updateProfile(_ profile: UpdateProfileRequest) async throws -> UserResponse {
        isLoading = true
        error = nil
        
        do {
            let endpoint = UserEndpoint.updateProfile(profile: profile)
            let user: UserResponse = try await apiClient.request(endpoint)
            
            currentUser = user
            isLoading = false
            return user
            
        } catch let apiError as APIError {
            error = apiError
            isLoading = false
            throw apiError
        } catch {
            let apiError = APIError.unknown(statusCode: 0)
            self.error = apiError
            isLoading = false
            throw apiError
        }
    }
    
    /// Загрузка аватара
    func uploadAvatar(_ imageData: Data) async throws -> String {
        isLoading = true
        error = nil
        
        do {
            let endpoint = UserEndpoint.uploadAvatar(data: imageData)
            let response: AvatarUploadResponse = try await apiClient.upload(endpoint, data: imageData, mimeType: "image/jpeg")
            
            // Обновляем аватар в текущем пользователе
            if currentUser != nil {
                currentUser?.avatar = response.url
            }
            
            isLoading = false
            return response.url
            
        } catch let apiError as APIError {
            error = apiError
            isLoading = false
            throw apiError
        } catch {
            let apiError = APIError.unknown(statusCode: 0)
            self.error = apiError
            isLoading = false
            throw apiError
        }
    }
    
    // MARK: - Private Methods
    
    private func checkAuthenticationStatus() {
        // Проверяем наличие токенов
        if tokenManager.hasValidTokens() {
            isAuthenticated = true
            
            // Загружаем данные пользователя
            Task {
                do {
                    _ = try await getCurrentUser()
                } catch {
                    // При ошибке загрузки пользователя выходим
                    await logout()
                }
            }
        }
    }
    
    // MARK: - Token Management
    
    /// Проверка необходимости обновления токена
    func needsTokenRefresh() -> Bool {
        guard let expiryDate = tokenManager.tokenExpiryDate else {
            return true
        }
        
        // Обновляем за 5 минут до истечения
        let refreshThreshold: TimeInterval = 300 // 5 minutes
        return expiryDate.timeIntervalSinceNow < refreshThreshold
    }
    
    /// Время до истечения токена
    func tokenTimeRemaining() -> TimeInterval {
        guard let expiryDate = tokenManager.tokenExpiryDate else {
            return 0
        }
        
        return max(0, expiryDate.timeIntervalSinceNow)
    }
}

// MARK: - Backward Compatibility Extension

extension AuthService {
    
    /// Register new user (backward compatibility)
    func register(firstName: String, lastName: String, email: String, password: String) async throws -> UserResponse {
        let createUserRequest = CreateUserRequest(
            email: email,
            name: "\(firstName) \(lastName)",
            role: .student,
            department: nil,
            password: password
        )
        
        let endpoint = UserEndpoint.createUser(user: createUserRequest)
        let user: UserResponse = try await apiClient.request(endpoint)
        
        // After registration, login automatically
        return try await login(email: email, password: password)
    }
}
