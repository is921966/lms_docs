import Foundation

protocol AuthServiceProtocol {
    var currentUser: User? { get }
    
    func login(email: String, password: String) async throws -> User
    func logout() async throws
    func refreshToken() async throws
}

enum AuthError: LocalizedError {
    case invalidCredentials(String)
    case networkError(String)
    case tokenExpired
    case biometricFailed
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .invalidCredentials(let message):
            return message
        case .networkError(let message):
            return "Network error: \(message)"
        case .tokenExpired:
            return "Session expired. Please login again."
        case .biometricFailed:
            return "Biometric authentication failed"
        case .unknown:
            return "An unknown error occurred"
        }
    }
} 