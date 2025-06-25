import Foundation

// MARK: - Login Request
struct LoginRequest: Encodable {
    let email: String
    let password: String
}

// MARK: - Login Response
struct LoginResponse: Decodable {
    let user: UserResponse
    let tokens: TokensResponse
}

// MARK: - Tokens Response
struct TokensResponse: Decodable {
    let accessToken: String
    let refreshToken: String
    let expiresIn: Int
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
        case expiresIn = "expires_in"
    }
}

// MARK: - User Response
struct UserResponse: Decodable {
    let id: String
    let email: String
    let firstName: String
    let lastName: String
    let middleName: String?
    let position: String?
    let department: String?
    let avatar: String?
    let roles: [String]
    var permissions: [String]
    
    enum CodingKeys: String, CodingKey {
        case id
        case email
        case firstName = "first_name"
        case lastName = "last_name"
        case middleName = "middle_name"
        case position
        case department
        case avatar
        case roles
        case permissions
    }
}

// MARK: - Refresh Token Request
struct RefreshTokenRequest: Encodable {
    let refreshToken: String
    
    enum CodingKeys: String, CodingKey {
        case refreshToken = "refresh_token"
    }
}

// MARK: - Error Response
struct ErrorResponse: Decodable {
    let error: String
    let message: String
    let statusCode: Int
    
    enum CodingKeys: String, CodingKey {
        case error
        case message
        case statusCode = "status_code"
    }
} 