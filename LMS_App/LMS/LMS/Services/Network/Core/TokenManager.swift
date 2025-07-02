import Foundation
import Security

// MARK: - TokenManager
class TokenManager {
    static let shared = TokenManager()

    private let accessTokenKey = "ru.tsum.lms.accessToken"
    private let refreshTokenKey = "ru.tsum.lms.refreshToken"
    private let userIdKey = "ru.tsum.lms.userId"
    private let tokenExpiryKey = "ru.tsum.lms.tokenExpiry"

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

    // MARK: - Token Expiry Date
    var tokenExpiryDate: Date? {
        get {
            guard let timestamp = UserDefaults.standard.object(forKey: tokenExpiryKey) as? TimeInterval else {
                return nil
            }
            return Date(timeIntervalSince1970: timestamp)
        }
        set {
            if let date = newValue {
                UserDefaults.standard.set(date.timeIntervalSince1970, forKey: tokenExpiryKey)
            } else {
                UserDefaults.standard.removeObject(forKey: tokenExpiryKey)
            }
        }
    }

    // MARK: - Token Management
    var isAuthenticated: Bool {
        guard let token = accessToken, !token.isEmpty else {
            return false
        }
        
        // Check if token is expired
        if let expiryDate = tokenExpiryDate {
            return Date() < expiryDate
        }
        
        // If no expiry date, assume token is valid
        return true
    }

    /// Check if token is expired
    var isTokenExpired: Bool {
        guard let expiryDate = tokenExpiryDate else {
            return false // No expiry date means we don't know, assume valid
        }
        
        return Date() >= expiryDate
    }

    /// Check if token needs refresh (expires in less than 5 minutes)
    var needsRefresh: Bool {
        guard let expiryDate = tokenExpiryDate else {
            return false
        }
        
        let fiveMinutesFromNow = Date().addingTimeInterval(300)
        return fiveMinutesFromNow >= expiryDate
    }

    /// Time remaining until token expires
    var timeUntilExpiry: TimeInterval {
        guard let expiryDate = tokenExpiryDate else {
            return 0
        }
        
        let remaining = expiryDate.timeIntervalSince(Date())
        return max(0, remaining)
    }

    func saveTokens(accessToken: String, refreshToken: String) {
        self.accessToken = accessToken
        self.refreshToken = refreshToken
    }

    func saveTokens(accessToken: String, refreshToken: String, expiryDate: Date) {
        self.accessToken = accessToken
        self.refreshToken = refreshToken
        self.tokenExpiryDate = expiryDate
    }

    func clearTokens() {
        accessToken = nil
        refreshToken = nil
        userId = nil
        tokenExpiryDate = nil
    }

    // MARK: - Token Validation
    
    /// Validate current tokens and return status
    func validateTokens() -> TokenValidationResult {
        guard let accessToken = accessToken, !accessToken.isEmpty else {
            return .noToken
        }
        
        if isTokenExpired {
            return .expired
        }
        
        if needsRefresh {
            return .needsRefresh
        }
        
        return .valid
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

// MARK: - Token Validation Result

enum TokenValidationResult {
    case valid
    case needsRefresh
    case expired
    case noToken
    
    var isValid: Bool {
        switch self {
        case .valid, .needsRefresh:
            return true
        case .expired, .noToken:
            return false
        }
    }
    
    var description: String {
        switch self {
        case .valid:
            return "Token is valid"
        case .needsRefresh:
            return "Token needs refresh"
        case .expired:
            return "Token is expired"
        case .noToken:
            return "No token available"
        }
    }
}
