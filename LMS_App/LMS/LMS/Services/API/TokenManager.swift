import Foundation
import Security

// MARK: - TokenManager

/// Менеджер для безопасного хранения и управления JWT токенами
final class TokenManager {
    
    // MARK: - Properties
    
    static let shared = TokenManager()
    
    private let accessTokenKey = "accessToken"
    private let refreshTokenKey = "refreshToken"
    private let keychainService = "com.lms.app"
    
    // MARK: - Initialization
    
    private init() {}
    
    // MARK: - Public Properties
    
    var accessToken: String? {
        return getToken(for: accessTokenKey)
    }
    
    var refreshToken: String? {
        return getToken(for: refreshTokenKey)
    }
    
    // MARK: - Public Methods
    
    /// Сохраняет токены в Keychain
    func saveTokens(accessToken: String, refreshToken: String) {
        saveToken(accessToken, for: accessTokenKey)
        saveToken(refreshToken, for: refreshTokenKey)
    }
    
    /// Удаляет все токены
    func clearTokens() {
        deleteToken(for: accessTokenKey)
        deleteToken(for: refreshTokenKey)
    }
    
    /// Проверяет, есть ли сохраненные токены
    func hasValidTokens() -> Bool {
        return accessToken != nil && refreshToken != nil
    }
    
    // MARK: - Backward Compatibility Methods
    
    /// Get access token (backward compatibility)
    func getAccessToken() -> String? {
        return accessToken
    }
    
    /// Get refresh token (backward compatibility)
    func getRefreshToken() -> String? {
        return refreshToken
    }
    
    /// User ID property for backward compatibility
    var userId: String? {
        get { return UserDefaults.standard.string(forKey: "currentUserId") }
        set { UserDefaults.standard.set(newValue, forKey: "currentUserId") }
    }
    
    // MARK: - Private Methods
    
    private func saveToken(_ token: String, for key: String) {
        let data = token.data(using: .utf8)!
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ]
        
        // Delete any existing item
        SecItemDelete(query as CFDictionary)
        
        // Add new item
        SecItemAdd(query as CFDictionary, nil)
    }
    
    private func getToken(for key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var dataTypeRef: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
        
        if status == errSecSuccess,
           let data = dataTypeRef as? Data,
           let token = String(data: data, encoding: .utf8) {
            return token
        }
        
        return nil
    }
    
    private func deleteToken(for key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: key
        ]
        
        SecItemDelete(query as CFDictionary)
    }
} 