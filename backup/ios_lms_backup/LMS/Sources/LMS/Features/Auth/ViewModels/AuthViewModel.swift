import Foundation
import SwiftUI
import LocalAuthentication
import Combine

@MainActor
class AuthViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var email = ""
    @Published var password = ""
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    
    // MARK: - Dependencies
    private let authService: AuthServiceProtocol
    private let context = LAContext()
    
    // MARK: - Computed Properties
    var isEmailValid: Bool {
        let emailRegex = #"^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
        let predicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return predicate.evaluate(with: email)
    }
    
    var isPasswordValid: Bool {
        password.count >= 6
    }
    
    var canLogin: Bool {
        !email.isEmpty && !password.isEmpty && isEmailValid && isPasswordValid && !isLoading
    }
    
    var isBiometricAvailable: Bool {
        var error: NSError?
        return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
    }
    
    // MARK: - Initialization
    init(authService: AuthServiceProtocol? = nil) {
        self.authService = authService ?? AuthService()
        
        // Clear error message when email changes
        $email
            .dropFirst()
            .sink { [weak self] _ in
                self?.errorMessage = nil
            }
            .store(in: &cancellables)
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Methods
    func login() async {
        guard canLogin else { return }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let user = try await authService.login(email: email, password: password)
            currentUser = user
            isAuthenticated = true
            
            // Save email for biometric login
            UserDefaults.standard.set(email, forKey: "lastAuthenticatedEmail")
        } catch {
            errorMessage = error.localizedDescription
            isAuthenticated = false
        }
        
        isLoading = false
    }
    
    func loginWithBiometric() async {
        guard isBiometricAvailable else { return }
        
        let reason = "Authenticate to access your account"
        
        do {
            let success = try await context.evaluatePolicy(
                .deviceOwnerAuthenticationWithBiometrics,
                localizedReason: reason
            )
            
            if success, let savedEmail = UserDefaults.standard.string(forKey: "lastAuthenticatedEmail") {
                // For demo, we'll simulate a successful login
                // In real app, you'd use stored credentials or token
                isLoading = true
                
                // Simulate API call
                try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
                
                currentUser = User(
                    id: UUID(),
                    email: savedEmail,
                    name: "Biometric User",
                    role: .student,
                    avatarURL: nil
                )
                isAuthenticated = true
                isLoading = false
            }
        } catch {
            errorMessage = "Biometric authentication failed"
        }
    }
    
    func logout() async {
        isLoading = true
        
        do {
            try await authService.logout()
            currentUser = nil
            isAuthenticated = false
            email = ""
            password = ""
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
}
