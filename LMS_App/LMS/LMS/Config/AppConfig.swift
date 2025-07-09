//
//  AppConfig.swift
//  LMS
//
//  Created by LMS Team on 13.01.2025.
//

import Foundation

struct AppConfig {
    // MARK: - API Configuration
    
    /// Base URL for API endpoints
    static var baseURL: String {
        #if DEBUG
        // Local development server
        return ProcessInfo.processInfo.environment["API_URL"] ?? "http://localhost:8000/api/v1"
        #else
        // Production server on Railway
        // TODO: Replace with your actual Railway app URL
        return "https://lms-backend-production.up.railway.app/api/v1"
        #endif
    }
    
    /// API version
    static let apiVersion = "v1"
    
    /// Request timeout in seconds
    static let requestTimeout: TimeInterval = 30
    
    /// Maximum retry attempts for failed requests
    static let maxRetryAttempts = 3
    
    // MARK: - Authentication
    
    /// Key for storing JWT token in Keychain
    static let jwtTokenKey = "com.lms.jwt.token"
    
    /// Key for storing refresh token in Keychain
    static let refreshTokenKey = "com.lms.jwt.refresh"
    
    // MARK: - Feature Flags
    
    /// Enable mock data for development
    static var useMockData: Bool {
        #if DEBUG
        return ProcessInfo.processInfo.environment["USE_MOCK_DATA"] == "1"
        #else
        return false
        #endif
    }
    
    /// Enable debug logging
    static var enableDebugLogging: Bool {
        #if DEBUG
        return true
        #else
        return false
        #endif
    }
    
    // MARK: - Cache Configuration
    
    /// Cache expiration time in seconds (24 hours)
    static let cacheExpirationTime: TimeInterval = 86400
    
    /// Maximum cache size in MB
    static let maxCacheSize = 100
    
    // MARK: - Push Notifications
    
    /// Enable push notifications
    static let pushNotificationsEnabled = true
    
    // MARK: - Analytics
    
    /// Enable analytics tracking
    static let analyticsEnabled = true
    
    // MARK: - App Info
    
    /// App version
    static var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    }
    
    /// Build number
    static var buildNumber: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }
}
