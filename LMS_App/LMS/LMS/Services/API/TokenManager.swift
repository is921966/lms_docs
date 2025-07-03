import Foundation
import Security

// MARK: - TokenManager

/// Менеджер для безопасного хранения и управления JWT токенами
final class TokenManager {
    
    // MARK: - Properties
    
    static let shared = TokenManager()
    
    private let accessTokenKey = "com.lms.accessToken"
    private let refreshTokenKey = "com.lms.refreshToken"
    private let keychainService = "com.lms.keychain"
    
    // MARK: - Initialization
    
    private init() {}
    
    // MARK: - Public Methods
    
    /// Сохраняет токены в Keychain
    func saveTokens(accessToken: String, refreshToken: String) {
        saveToKeychain(accessToken, key: accessTokenKey)
        saveToKeychain(refreshToken, key: refreshTokenKey)
    }
    
    /// Получает access token
    func getAccessToken() -> String? {
        return loadFromKeychain(key: accessTokenKey)
    }
    
    /// Получает refresh token
    func getRefreshToken() -> String? {
        return loadFromKeychain(key: refreshTokenKey)
    }
    
    /// Удаляет все токены
    func clearTokens() {
        deleteFromKeychain(key: accessTokenKey)
        deleteFromKeychain(key: refreshTokenKey)
    }
    
    /// Проверяет, есть ли сохраненные токены
    var hasValidTokens: Bool {
        return getAccessToken() != nil
    }
    
    // MARK: - Private Keychain Methods
    
    private func saveToKeychain(_ value: String, key: String) {
        guard let data = value.data(using: .utf8) else { return }
        
        // Delete existing item first
        deleteFromKeychain(key: key)
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]
        
        let status = SecItemAdd(query as CFDictionary, nil)
        
        if status != errSecSuccess {
            print("Failed to save to keychain: \(status)")
        }
    }
    
    private func loadFromKeychain(key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess,
              let data = result as? Data,
              let value = String(data: data, encoding: .utf8) else {
            return nil
        }
        
        return value
    }
    
    private func deleteFromKeychain(key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: key
        ]
        
        SecItemDelete(query as CFDictionary)
    }
} 