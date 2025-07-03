import Foundation

// MARK: - UserEndpoint

enum UserEndpoint: APIEndpoint {
    case getUsers(page: Int, limit: Int)
    case getUser(id: String)
    case createUser(user: CreateUserRequest)
    case updateUser(id: String, user: UpdateUserRequest)
    case deleteUser(id: String)
    case updateProfile(profile: UpdateProfileRequest)
    case uploadAvatar(data: Data)
    case searchUsers(query: String, filters: UserFilters?)
    
    var path: String {
        switch self {
        case .getUsers:
            return "/users"
        case .getUser(let id):
            return "/users/\(id)"
        case .createUser:
            return "/users"
        case .updateUser(let id, _):
            return "/users/\(id)"
        case .deleteUser(let id):
            return "/users/\(id)"
        case .updateProfile:
            return "/users/me"
        case .uploadAvatar:
            return "/users/me/avatar"
        case .searchUsers:
            return "/users/search"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .getUsers, .getUser, .searchUsers:
            return .get
        case .createUser, .uploadAvatar:
            return .post
        case .updateUser, .updateProfile:
            return .put
        case .deleteUser:
            return .delete
        }
    }
    
    var requiresAuth: Bool {
        return true
    }
    
    var parameters: [String: Any]? {
        switch self {
        case .getUsers(let page, let limit):
            return ["page": page, "limit": limit]
        case .searchUsers(let query, let filters):
            var params: [String: Any] = ["q": query]
            if let filters = filters {
                if let role = filters.role {
                    params["role"] = role
                }
                if let department = filters.department {
                    params["department"] = department
                }
                if let isActive = filters.isActive {
                    params["is_active"] = isActive
                }
            }
            return params
        default:
            return nil
        }
    }
    
    var body: Encodable? {
        switch self {
        case .createUser(let user):
            return user
        case .updateUser(_, let user):
            return user
        case .updateProfile(let profile):
            return profile
        default:
            return nil
        }
    }
}

// MARK: - Additional Models (not duplicated)

struct UserPreferences: Codable {
    let language: String
    let notifications: NotificationPreferences
    let theme: String
}

struct NotificationPreferences: Codable {
    let email: Bool
    let push: Bool
    let sms: Bool
} 