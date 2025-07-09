//
//  KeychainHelper.swift
//  LMS
//
//  Created by LMS Team on 13.01.2025.
//

import Foundation
import Security

/// Helper class for secure storage in Keychain
class KeychainHelper {
    
    private static let serviceName = "com.lms.corporate.university"
    
    /// Save string value to Keychain
    static func save(_ value: String, forKey key: String) {
        guard let data = value.data(using: .utf8) else { return }
        
        // Delete any existing item
        delete(forKey: key)
        
        // Create query
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]
        
        // Add item
        let status = SecItemAdd(query as CFDictionary, nil)
        
        if status != errSecSuccess {
            print("Error saving to Keychain: \(status)")
        }
    }
    
    /// Load string value from Keychain
    static func load(forKey key: String) -> String? {
        // Create query
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        // Search for item
        var dataTypeRef: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
        
        if status == errSecSuccess {
            if let data = dataTypeRef as? Data,
               let value = String(data: data, encoding: .utf8) {
                return value
            }
        }
        
        return nil
    }
    
    /// Delete value from Keychain
    static func delete(forKey key: String) {
        // Create query
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: key
        ]
        
        // Delete item
        SecItemDelete(query as CFDictionary)
    }
    
    /// Clear all stored values
    static func clearAll() {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName
        ]
        
        SecItemDelete(query as CFDictionary)
    }
} 