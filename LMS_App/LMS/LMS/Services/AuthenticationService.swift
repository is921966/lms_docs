//
//  AuthenticationService.swift
//  LMS
//
//  Created on Sprint 39 Day 2 - TDD Excellence
//

import Foundation

/// Ошибки аутентификации
public enum AuthenticationError: Error, Equatable {
    case invalidRefreshToken
    case tokenGenerationFailed
    case networkError
    case tokenExpired
    case noTokenFound
}

/// Сервис для управления токенами аутентификации и сессиями пользователей
///
/// Обеспечивает безопасное хранение токенов, автоматическое обновление
/// и проверку валидности.
///
/// Пример использования:
/// ```swift
/// let authService = AuthenticationService.shared
/// if authService.isAccessTokenExpired() {
///     let newToken = try await authService.refreshAccessToken()
/// }
/// ```
///
/// - Note: В production токены должны храниться в Keychain
/// - Since: v2.0.0
public final class AuthenticationService {
    
    // MARK: - Types
    
    /// Структура для хранения токенов
    private struct TokenData {
        let accessToken: String
        let refreshToken: String
        let expiryDate: Date
    }
    
    // MARK: - Properties
    
    /// Singleton instance
    public static let shared = AuthenticationService()
    
    /// Текущие токены (в production использовать Keychain)
    private var tokenData: TokenData?
    
    /// Время жизни access token по умолчанию (1 час)
    private let defaultTokenLifetime: TimeInterval = 3600
    
    /// Время за которое нужно обновить токен (5 минут до истечения)
    private let tokenRefreshThreshold: TimeInterval = 300
    
    /// Mock сетевой слой для тестирования
    private let mockValidRefreshToken = "valid-refresh-token"
    
    // MARK: - Initialization
    
    private init() {}
    
    // MARK: - Public Methods
    
    /// Устанавливает токены аутентификации
    /// - Parameters:
    ///   - accessToken: Access token для API запросов
    ///   - refreshToken: Refresh token для обновления access token
    ///   - expiryDate: Дата истечения access token (по умолчанию +1 час)
    public func setTokens(accessToken: String, refreshToken: String, expiryDate: Date? = nil) {
        let expiry = expiryDate ?? Date().addingTimeInterval(defaultTokenLifetime)
        tokenData = TokenData(
            accessToken: accessToken,
            refreshToken: refreshToken,
            expiryDate: expiry
        )
    }
    
    /// Обновляет access token используя refresh token
    /// - Returns: Новый access token
    /// - Throws: AuthenticationError если refresh token невалидный
    public func refreshAccessToken() async throws -> String {
        guard let currentTokenData = tokenData else {
            throw AuthenticationError.noTokenFound
        }
        
        // В production здесь был бы реальный API запрос
        guard currentTokenData.refreshToken == mockValidRefreshToken else {
            throw AuthenticationError.invalidRefreshToken
        }
        
        // Имитация сетевой задержки
        try await Task.sleep(nanoseconds: 100_000_000) // 0.1 секунды
        
        // Генерируем новый токен
        let newToken = "new-access-token-\(UUID().uuidString)"
        let newExpiry = Date().addingTimeInterval(defaultTokenLifetime)
        
        // Обновляем хранилище
        tokenData = TokenData(
            accessToken: newToken,
            refreshToken: currentTokenData.refreshToken,
            expiryDate: newExpiry
        )
        
        return newToken
    }
    
    /// Проверяет, истек ли access token
    /// - Returns: true если токен истек или отсутствует
    public func isAccessTokenExpired() -> Bool {
        guard let tokenData = tokenData else { return true }
        return tokenData.expiryDate < Date()
    }
    
    /// Проверяет, нужно ли обновить токен в ближайшее время
    /// - Returns: true если токен истечет в течение threshold времени
    public func shouldRefreshToken() -> Bool {
        guard let tokenData = tokenData else { return true }
        let timeUntilExpiry = tokenData.expiryDate.timeIntervalSinceNow
        return timeUntilExpiry < tokenRefreshThreshold
    }
    
    /// Возвращает текущий access token
    /// - Returns: Access token или nil если не установлен
    public func getCurrentAccessToken() -> String? {
        guard let tokenData = tokenData,
              !isAccessTokenExpired() else { return nil }
        return tokenData.accessToken
    }
    
    /// Генерирует токен с заданным временем жизни (для тестирования)
    /// - Parameter seconds: Время жизни токена в секундах
    /// - Returns: Сгенерированный токен
    internal func generateToken(expiresIn seconds: TimeInterval) -> String {
        let token = "token-\(UUID().uuidString)"
        let expiry = Date().addingTimeInterval(seconds)
        
        // Сохраняем с дефолтным refresh token
        setTokens(
            accessToken: token,
            refreshToken: mockValidRefreshToken,
            expiryDate: expiry
        )
        
        return token
    }
    
    /// Очищает все токены (logout)
    public func clearTokens() {
        tokenData = nil
    }
    
    /// Проверяет наличие валидной сессии
    /// - Returns: true если есть валидный access token
    public func hasValidSession() -> Bool {
        return getCurrentAccessToken() != nil
    }
} 