import Foundation

// MARK: - Login Models

struct LoginRequest: Encodable {
    let email: String
    let password: String
}

struct LoginResponse: Decodable {
    let accessToken: String
    let refreshToken: String
    let user: UserResponse
    let expiresIn: Int
}

// MARK: - Refresh Token Models

struct RefreshTokenRequest: Encodable {
    let refreshToken: String
}

struct RefreshTokenResponse: Decodable {
    let accessToken: String
    let refreshToken: String
    let expiresIn: Int
}

// MARK: - Backward Compatibility

/// Alias for LoginResponse to maintain backward compatibility
typealias AuthResponse = LoginResponse
