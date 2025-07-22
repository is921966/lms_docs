import Foundation
import Combine

@MainActor
final class SettingsViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var notificationsEnabled: Bool = true
    @Published var currentLanguage: AppLanguage = .russian
    @Published var currentTheme: AppTheme = .system
    @Published var userName: String = ""
    @Published var userEmail: String = ""
    @Published var userRole: String = ""
    @Published var isLoading = false
    @Published var error: String?
    
    // MARK: - Dependencies
    private let authService: AuthServiceProtocol
    private let settingsService: SettingsServiceProtocol
    private weak var coordinator: SettingsCoordinatorProtocol?
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    init(
        authService: AuthServiceProtocol,
        settingsService: SettingsServiceProtocol,
        coordinator: SettingsCoordinatorProtocol? = nil
    ) {
        self.authService = authService
        self.settingsService = settingsService
        self.coordinator = coordinator
        
        setupBindings()
        loadUserInfo()
    }
    
    // MARK: - Setup
    private func setupBindings() {
        // Bind settings
        settingsService.notificationsEnabledPublisher
            .receive(on: DispatchQueue.main)
            .assign(to: &$notificationsEnabled)
        
        settingsService.currentLanguagePublisher
            .receive(on: DispatchQueue.main)
            .assign(to: &$currentLanguage)
        
        settingsService.currentThemePublisher
            .receive(on: DispatchQueue.main)
            .assign(to: &$currentTheme)
        
        // Two-way binding for settings
        $notificationsEnabled
            .dropFirst()
            .sink { [weak self] value in
                self?.settingsService.notificationsEnabled = value
            }
            .store(in: &cancellables)
        
        $currentLanguage
            .dropFirst()
            .sink { [weak self] value in
                self?.settingsService.currentLanguage = value
            }
            .store(in: &cancellables)
        
        $currentTheme
            .dropFirst()
            .sink { [weak self] value in
                self?.settingsService.currentTheme = value
            }
            .store(in: &cancellables)
    }
    
    private func loadUserInfo() {
        if let currentUser = authService.currentUser {
            userName = currentUser.name
            userEmail = currentUser.email ?? ""
            userRole = currentUser.role.rawValue
        }
    }
    
    // MARK: - Navigation
    func showNotificationSettings() {
        coordinator?.showNotificationSettings()
    }
    
    func showLanguageSettings() {
        coordinator?.showLanguageSettings()
    }
    
    func showAbout() {
        coordinator?.showAbout()
    }
    
    func showPrivacyPolicy() {
        coordinator?.showPrivacyPolicy()
    }
    
    func showTermsOfService() {
        coordinator?.showTermsOfService()
    }
    
    func showDebugMenu() {
        #if DEBUG
        coordinator?.showDebugMenu()
        #endif
    }
    
    // MARK: - Actions
    func saveSettings() {
        Task {
            isLoading = true
            error = nil
            
            do {
                try await settingsService.saveSettings()
            } catch {
                self.error = error.localizedDescription
            }
            
            isLoading = false
        }
    }
    
    func resetSettings() {
        settingsService.resetSettings()
    }
    
    func exportUserData() {
        Task {
            isLoading = true
            error = nil
            
            do {
                let fileURL = try await settingsService.exportUserData()
                // Handle file sharing
                await shareFile(fileURL)
            } catch {
                self.error = error.localizedDescription
            }
            
            isLoading = false
        }
    }
    
    func logout() {
        coordinator?.logout()
    }
    
    func deleteAccount() {
        Task {
            isLoading = true
            error = nil
            
            do {
                try await settingsService.deleteAccount()
                coordinator?.logout()
            } catch {
                self.error = error.localizedDescription
            }
            
            isLoading = false
        }
    }
    
    // MARK: - Helpers
    private func shareFile(_ url: URL) async {
        // Implementation for file sharing
    }
    
    // MARK: - Computed Properties
    var hasError: Bool {
        error != nil
    }
    
    var errorMessage: String {
        error ?? ""
    }
    
    var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "\(version) (\(build))"
    }
} 