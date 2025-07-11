import Foundation
import Combine

// MARK: - TokenRefreshManager

/// Менеджер для автоматического обновления JWT токенов
@MainActor
final class TokenRefreshManager {
    
    // MARK: - Properties
    
    static let shared = TokenRefreshManager()
    
    private var refreshTimer: Timer?
    private let tokenManager = TokenManager.shared
    private let authService = AuthService.shared
    private var cancellables = Set<AnyCancellable>()
    
    // Refresh token за 5 минут до истечения
    private let refreshBeforeExpiry: TimeInterval = 300 // 5 minutes
    
    // MARK: - Initialization
    
    private init() {
        setupTokenRefreshMonitoring()
    }
    
    // MARK: - Public Methods
    
    /// Начать мониторинг токенов
    func startTokenRefreshMonitoring() {
        setupTokenRefreshMonitoring()
    }
    
    /// Остановить мониторинг токенов
    func stopTokenRefreshMonitoring() {
        refreshTimer?.invalidate()
        refreshTimer = nil
    }
    
    /// Проверить и обновить токен если необходимо
    func checkAndRefreshTokenIfNeeded() async throws {
        guard authService.isAuthenticated else { return }
        
        if authService.needsTokenRefresh() {
            // Just refresh the token
            _ = try await authService.refreshToken()
            scheduleNextRefresh()
        }
    }
    
    // MARK: - Private Methods
    
    private func setupTokenRefreshMonitoring() {
        // Monitor authentication state changes
        authService.$isAuthenticated
            .sink { [weak self] isAuthenticated in
                if isAuthenticated {
                    self?.scheduleNextRefresh()
                } else {
                    self?.stopTokenRefreshMonitoring()
                }
            }
            .store(in: &cancellables)
        
        // Schedule initial refresh if authenticated
        if authService.isAuthenticated {
            scheduleNextRefresh()
        }
    }
    
    private func scheduleNextRefresh() {
        // Cancel existing timer
        refreshTimer?.invalidate()
        
        // Calculate time until refresh needed
        let timeRemaining = authService.tokenTimeRemaining()
        let refreshIn = max(0, timeRemaining - refreshBeforeExpiry)
        
        // Don't schedule if token is already expired or about to expire
        guard refreshIn > 0 else {
            // Refresh immediately
            Task {
                try? await checkAndRefreshTokenIfNeeded()
            }
            return
        }
        
        // Schedule refresh
        refreshTimer = Timer.scheduledTimer(withTimeInterval: refreshIn, repeats: false) { [weak self] _ in
            Task { @MainActor in
                try? await self?.checkAndRefreshTokenIfNeeded()
            }
        }
    }
}

// MARK: - App Lifecycle Integration

extension TokenRefreshManager {
    
    /// Handle app becoming active
    func handleAppDidBecomeActive() {
        Task {
            try? await checkAndRefreshTokenIfNeeded()
        }
    }
    
    /// Handle app entering background
    func handleAppDidEnterBackground() {
        // Optionally stop timer to save battery
        stopTokenRefreshMonitoring()
    }
    
    /// Handle app returning to foreground
    func handleAppWillEnterForeground() {
        // Restart monitoring
        startTokenRefreshMonitoring()
    }
} 