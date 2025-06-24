import Foundation
import SwiftUI

@MainActor
class SettingsViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var currentUser: User?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showingLogoutConfirmation = false
    @Published var showingDeleteAccountConfirmation = false
    
    // Notification Settings
    @Published var pushNotificationsEnabled = true
    @Published var emailNotificationsEnabled = true
    @Published var courseUpdatesEnabled = true
    @Published var gradeNotificationsEnabled = true
    
    // App Settings
    @Published var biometricAuthEnabled = false
    @Published var downloadOverWifiOnly = true
    @Published var autoplayVideos = false
    
    // MARK: - App Storage
    @AppStorage("isAdminMode") var isAdminMode = false
    @AppStorage("appTheme") var appTheme = "system"
    
    // MARK: - Dependencies
    private let authService: AuthServiceProtocol
    private let userService: UserServiceProtocol
    
    // MARK: - Initialization
    init(authService: AuthServiceProtocol? = nil, userService: UserServiceProtocol? = nil) {
        self.authService = authService ?? AuthService()
        self.userService = userService ?? MockUserService()
        
        Task {
            await loadCurrentUser()
            loadSettings()
        }
    }
    
    // MARK: - Methods
    func loadCurrentUser() async {
        // In real app, get from auth service
        currentUser = User(
            id: UUID(),
            email: "admin@example.com",
            name: "Admin User",
            role: .admin,
            avatarURL: nil
        )
    }
    
    func toggleAdminMode() {
        guard let user = currentUser,
              user.role == .admin || user.role == .superAdmin else { return }
        
        isAdminMode.toggle()
    }
    
    func updateNotificationSettings() async {
        isLoading = true
        
        // Simulate API call
        try? await Task.sleep(nanoseconds: 500_000_000)
        
        // In real app, save to backend
        UserDefaults.standard.set(pushNotificationsEnabled, forKey: "pushNotifications")
        UserDefaults.standard.set(emailNotificationsEnabled, forKey: "emailNotifications")
        UserDefaults.standard.set(courseUpdatesEnabled, forKey: "courseUpdates")
        UserDefaults.standard.set(gradeNotificationsEnabled, forKey: "gradeNotifications")
        
        isLoading = false
    }
    
    func updateAppSettings() async {
        isLoading = true
        
        // Simulate API call
        try? await Task.sleep(nanoseconds: 300_000_000)
        
        // In real app, save to backend
        UserDefaults.standard.set(biometricAuthEnabled, forKey: "biometricAuth")
        UserDefaults.standard.set(downloadOverWifiOnly, forKey: "wifiOnly")
        UserDefaults.standard.set(autoplayVideos, forKey: "autoplay")
        
        isLoading = false
    }
    
    func logout() async {
        isLoading = true
        
        do {
            try await authService.logout()
            // Clear local data
            clearLocalData()
            // Navigate to login
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func deleteAccount() async {
        isLoading = true
        errorMessage = nil
        
        do {
            // In real app, call delete account API
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            
            // Clear all data and logout
            clearLocalData()
            try await authService.logout()
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func clearCache() async {
        isLoading = true
        
        // Simulate clearing cache
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        
        // In real app, clear image cache, downloaded files, etc.
        URLCache.shared.removeAllCachedResponses()
        
        isLoading = false
    }
    
    // MARK: - Private Methods
    private func loadSettings() {
        pushNotificationsEnabled = UserDefaults.standard.bool(forKey: "pushNotifications")
        emailNotificationsEnabled = UserDefaults.standard.bool(forKey: "emailNotifications")
        courseUpdatesEnabled = UserDefaults.standard.bool(forKey: "courseUpdates")
        gradeNotificationsEnabled = UserDefaults.standard.bool(forKey: "gradeNotifications")
        
        biometricAuthEnabled = UserDefaults.standard.bool(forKey: "biometricAuth")
        downloadOverWifiOnly = UserDefaults.standard.bool(forKey: "wifiOnly")
        autoplayVideos = UserDefaults.standard.bool(forKey: "autoplay")
    }
    
    private func clearLocalData() {
        // Clear user defaults
        let domain = Bundle.main.bundleIdentifier!
        UserDefaults.standard.removePersistentDomain(forName: domain)
        UserDefaults.standard.synchronize()
        
        // Clear keychain
        // In real app, clear keychain items
        
        // Reset app storage
        isAdminMode = false
        appTheme = "system"
    }
    
    // MARK: - Computed Properties
    var isAdmin: Bool {
        guard let user = currentUser else { return false }
        return user.role == .admin || user.role == .superAdmin
    }
    
    var cacheSize: String {
        // In real app, calculate actual cache size
        return "125 MB"
    }
    
    var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    }
    
    var buildNumber: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }
} 