import Foundation

// MARK: - UserResponse

struct UserResponse: Codable {
    let id: String
    let email: String
    var name: String
    var role: UserRole
    var avatarURL: String?
    var firstName: String?
    var lastName: String?
    var middleName: String?
    var phone: String?
    var birthDate: Date?
    var department: String?
    var position: String?
    var hireDate: Date?
    var isActive: Bool
    var permissions: [String]
    let createdAt: Date
    var updatedAt: Date
    
    // For backward compatibility
    var avatar: String? {
        get { avatarURL }
        set { avatarURL = newValue }
    }
    
    init(
        id: String,
        email: String,
        name: String,
        role: UserRole,
        avatarURL: String? = nil,
        firstName: String? = nil,
        lastName: String? = nil,
        middleName: String? = nil,
        phone: String? = nil,
        birthDate: Date? = nil,
        department: String? = nil,
        position: String? = nil,
        hireDate: Date? = nil,
        isActive: Bool = true,
        permissions: [String] = [],
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.email = email
        self.name = name
        self.role = role
        self.avatarURL = avatarURL
        self.firstName = firstName
        self.lastName = lastName
        self.middleName = middleName
        self.phone = phone
        self.birthDate = birthDate
        self.department = department
        self.position = position
        self.hireDate = hireDate
        self.isActive = isActive
        self.permissions = permissions.isEmpty ? role.permissions : permissions
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

// MARK: - Equatable

extension UserResponse: Equatable {
    static func == (lhs: UserResponse, rhs: UserResponse) -> Bool {
        return lhs.id == rhs.id
    }
} 