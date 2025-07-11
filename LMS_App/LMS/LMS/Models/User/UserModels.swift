import Foundation

// MARK: - Request Models

struct UserFilters: Encodable {
    let role: UserRole?
    let department: String?
    let isActive: Bool?
    let search: String?
}

struct CreateUserRequest: Encodable {
    let email: String
    let name: String
    let role: UserRole
    let department: String?
    let password: String
}

struct UpdateUserRequest: Encodable {
    let name: String?
    let role: UserRole?
    let department: String?
    let isActive: Bool?
}

struct UpdateProfileRequest: Encodable {
    let name: String?
    let department: String?
    let avatar: String?
    let phone: String?
    let bio: String?
    let preferences: UserPreferences?
}

// MARK: - Response Models

struct UsersResponse: Decodable {
    let users: [UserResponse]
    let pagination: PaginationInfo
}

struct AvatarUploadResponse: Decodable {
    let url: String
    let size: Int64
    let mimeType: String
}

