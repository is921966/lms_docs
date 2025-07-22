import Foundation
import Combine

protocol SettingsServiceProtocol: AnyObject {
    // Notification Settings
    var notificationsEnabled: Bool { get set }
    var pushNotificationsEnabled: Bool { get set }
    var emailNotificationsEnabled: Bool { get set }
    var courseUpdatesEnabled: Bool { get set }
    var gradeNotificationsEnabled: Bool { get set }
    
    // Language Settings
    var currentLanguage: AppLanguage { get set }
    var availableLanguages: [AppLanguage] { get }
    
    // Theme Settings
    var currentTheme: AppTheme { get set }
    
    // Publishers
    var notificationsEnabledPublisher: AnyPublisher<Bool, Never> { get }
    var currentLanguagePublisher: AnyPublisher<AppLanguage, Never> { get }
    var currentThemePublisher: AnyPublisher<AppTheme, Never> { get }
    
    // Methods
    func saveSettings() async throws
    func resetSettings()
    func exportUserData() async throws -> URL
    func deleteAccount() async throws
}

enum AppLanguage: String, CaseIterable {
    case russian = "ru"
    case english = "en"
    
    var displayName: String {
        switch self {
        case .russian: return "Русский"
        case .english: return "English"
        }
    }
}

enum AppTheme: String, CaseIterable {
    case system = "system"
    case light = "light"
    case dark = "dark"
    
    var displayName: String {
        switch self {
        case .system: return "Системная"
        case .light: return "Светлая"
        case .dark: return "Тёмная"
        }
    }
} 