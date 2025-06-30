import Foundation
import Security

// MARK: - TokenManager
class TokenManager {
    static let shared = TokenManager()

    private let accessTokenKey = "ru.tsum.lms.accessToken"
    private let refreshTokenKey = "ru.tsum.lms.refreshToken"
    private let userIdKey = "ru.tsum.lms.userId"

    private init() {}

    // MARK: - Access Token
    var accessToken: String? {
        get { getFromKeychain(key: accessTokenKey) }
        set {
            if let token = newValue {
                saveToKeychain(key: accessTokenKey, value: token)
            } else {
                deleteFromKeychain(key: accessTokenKey)
            }
        }
    }

    // MARK: - Refresh Token
    var refreshToken: String? {
        get { getFromKeychain(key: refreshTokenKey) }
        set {
            if let token = newValue {
                saveToKeychain(key: refreshTokenKey, value: token)
            } else {
                deleteFromKeychain(key: refreshTokenKey)
            }
        }
    }

    // MARK: - User ID
    var userId: String? {
        get { UserDefaults.standard.string(forKey: userIdKey) }
        set { UserDefaults.standard.set(newValue, forKey: userIdKey) }
    }

    // MARK: - Token Management
    var isAuthenticated: Bool {
        accessToken != nil
    }

    func saveTokens(accessToken: String, refreshToken: String) {
        self.accessToken = accessToken
        self.refreshToken = refreshToken
    }

    func clearTokens() {
        accessToken = nil
        refreshToken = nil
        userId = nil
    }

    // MARK: - Keychain Operations
    private func saveToKeychain(key: String, value: String) {
        let data = value.data(using: .utf8)!

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ]

        // Delete existing item
        SecItemDelete(query as CFDictionary)

        // Add new item
        let status = SecItemAdd(query as CFDictionary, nil)
        if status != errSecSuccess {
            print("Error saving to keychain: \(status)")
        }
    }

    private func getFromKeychain(key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var dataTypeRef: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)

        if status == errSecSuccess,
           let data = dataTypeRef as? Data,
           let value = String(data: data, encoding: .utf8) {
            return value
        }

        return nil
    }

    private func deleteFromKeychain(key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]

        SecItemDelete(query as CFDictionary)
    }
}
