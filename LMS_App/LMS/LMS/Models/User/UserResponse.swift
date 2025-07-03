import Foundation

// MARK: - UserResponse

struct UserResponse: Codable {
    let id: String
    let email: String
    var name: String
    var role: String
    var department: String?
    var isActive: Bool
    var avatar: String?
    let createdAt: Date
    var updatedAt: Date
}

// MARK: - Equatable

extension UserResponse: Equatable {
    static func == (lhs: UserResponse, rhs: UserResponse) -> Bool {
        return lhs.id == rhs.id
    }
} 