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
    
    enum CodingKeys: String, CodingKey {
        case id
        case email
        case name
        case role
        case avatarURL
        case avatar
        case firstName
        case lastName
        case middleName
        case phone
        case birthDate
        case department
        case position
        case hireDate
        case isActive
        case permissions
        case createdAt
        case updatedAt
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
    
    // Custom decoder to handle both avatar and avatarURL
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(String.self, forKey: .id)
        email = try container.decode(String.self, forKey: .email)
        name = try container.decode(String.self, forKey: .name)
        role = try container.decode(UserRole.self, forKey: .role)
        
        // Try avatarURL first, then avatar
        if let avatarURLValue = try container.decodeIfPresent(String.self, forKey: .avatarURL) {
            avatarURL = avatarURLValue
        } else if let avatarValue = try container.decodeIfPresent(String.self, forKey: .avatar) {
            avatarURL = avatarValue
        } else {
            avatarURL = nil
        }
        
        firstName = try container.decodeIfPresent(String.self, forKey: .firstName)
        lastName = try container.decodeIfPresent(String.self, forKey: .lastName)
        middleName = try container.decodeIfPresent(String.self, forKey: .middleName)
        phone = try container.decodeIfPresent(String.self, forKey: .phone)
        birthDate = try container.decodeIfPresent(Date.self, forKey: .birthDate)
        department = try container.decodeIfPresent(String.self, forKey: .department)
        position = try container.decodeIfPresent(String.self, forKey: .position)
        hireDate = try container.decodeIfPresent(Date.self, forKey: .hireDate)
        isActive = try container.decodeIfPresent(Bool.self, forKey: .isActive) ?? true
        permissions = try container.decodeIfPresent([String].self, forKey: .permissions) ?? []
        createdAt = try container.decode(Date.self, forKey: .createdAt)
        updatedAt = try container.decode(Date.self, forKey: .updatedAt)
        
        // Set default permissions based on role if empty
        if permissions.isEmpty {
            permissions = role.permissions
        }
    }
    
    // Custom encoder to maintain backward compatibility
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(id, forKey: .id)
        try container.encode(email, forKey: .email)
        try container.encode(name, forKey: .name)
        try container.encode(role, forKey: .role)
        try container.encodeIfPresent(avatarURL, forKey: .avatarURL)
        try container.encodeIfPresent(firstName, forKey: .firstName)
        try container.encodeIfPresent(lastName, forKey: .lastName)
        try container.encodeIfPresent(middleName, forKey: .middleName)
        try container.encodeIfPresent(phone, forKey: .phone)
        try container.encodeIfPresent(birthDate, forKey: .birthDate)
        try container.encodeIfPresent(department, forKey: .department)
        try container.encodeIfPresent(position, forKey: .position)
        try container.encodeIfPresent(hireDate, forKey: .hireDate)
        try container.encode(isActive, forKey: .isActive)
        try container.encode(permissions, forKey: .permissions)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(updatedAt, forKey: .updatedAt)
    }
}

// MARK: - Equatable

extension UserResponse: Equatable {
    static func == (lhs: UserResponse, rhs: UserResponse) -> Bool {
        return lhs.id == rhs.id
    }
} 