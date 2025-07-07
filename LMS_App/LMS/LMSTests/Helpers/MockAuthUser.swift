import Foundation
@testable import LMS

struct MockAuthUser {
    let id: String
    let email: String
    let firstName: String
    let lastName: String
    let role: UserRole
    
    init(
        id: String = UUID().uuidString,
        email: String = "test@example.com",
        firstName: String = "Test",
        lastName: String = "User",
        role: UserRole = .student
    ) {
        self.id = id
        self.email = email
        self.firstName = firstName
        self.lastName = lastName
        self.role = role
    }
    
    func toAuthUser() -> AuthUser {
        let userResponse = UserResponse(
            id: id,
            email: email,
            name: "\(firstName) \(lastName)",
            role: role,
            avatarURL: nil,
            firstName: firstName,
            lastName: lastName
        )
        return AuthUser(from: userResponse)
    }
}
