import Foundation

// MARK: - AuthEndpoint

enum AuthEndpoint: APIEndpoint {
    case login(credentials: LoginRequest)
    case refreshToken(request: RefreshTokenRequest)
    case logout
    case getCurrentUser
    
    // MARK: - Backward Compatibility
    
    /// Create refresh endpoint (backward compatibility)
    static func refresh(token: String) -> AuthEndpoint {
        return .refreshToken(request: RefreshTokenRequest(refreshToken: token))
    }
    
    var path: String {
        switch self {
        case .login:
            return "/auth/login"
        case .refreshToken:
            return "/auth/refresh"
        case .logout:
            return "/auth/logout"
        case .getCurrentUser:
            return "/auth/me"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .login, .refreshToken, .logout:
            return .post
        case .getCurrentUser:
            return .get
        }
    }
    
    var requiresAuth: Bool {
        switch self {
        case .login, .refreshToken:
            return false
        case .logout, .getCurrentUser:
            return true
        }
    }
    
    var parameters: [String: Any]? {
        return nil
    }
    
    var body: Encodable? {
        switch self {
        case .login(let credentials):
            return credentials
        case .refreshToken(let request):
            return request
        default:
            return nil
        }
    }
} 