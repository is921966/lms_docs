import Foundation

// MARK: - AuthEndpoint

enum AuthEndpoint: APIEndpoint {
    case login(email: String, password: String)
    case logout
    case refresh(token: String)
    case me
    
    var path: String {
        switch self {
        case .login:
            return "/auth/login"
        case .logout:
            return "/auth/logout"
        case .refresh:
            return "/auth/refresh"
        case .me:
            return "/auth/me"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .login, .logout, .refresh:
            return .post
        case .me:
            return .get
        }
    }
    
    var requiresAuth: Bool {
        switch self {
        case .login, .refresh:
            return false
        case .logout, .me:
            return true
        }
    }
    
    var body: Encodable? {
        switch self {
        case .login(let email, let password):
            return LoginRequest(email: email, password: password)
        case .refresh(let token):
            return RefreshTokenRequest(refreshToken: token)
        case .logout, .me:
            return nil
        }
    }
}

// MARK: - Request Models

struct LoginRequest: Encodable {
    let email: String
    let password: String
}

struct RefreshTokenRequest: Encodable {
    let refreshToken: String
}

// MARK: - Response Models

struct AuthResponse: Decodable {
    let user: UserResponse
    let accessToken: String
    let refreshToken: String
    let tokenType: String
    let expiresIn: Int
}

struct UserResponse: Decodable {
    let id: String
    let email: String
    let name: String
    let role: String
    let avatarUrl: String?
    let createdAt: Date
    let updatedAt: Date
} 