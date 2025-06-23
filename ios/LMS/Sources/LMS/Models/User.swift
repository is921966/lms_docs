import Foundation

struct User: Identifiable, Codable, Equatable {
    let id: UUID
    let email: String
    let name: String
    let role: Role
    let avatarURL: URL?
    
    enum Role: String, Codable, CaseIterable {
        case student = "student"
        case instructor = "instructor"
        case admin = "admin"
        case superAdmin = "super_admin"
    }
}

// MARK: - Computed Properties
extension User {
    var displayName: String {
        name
    }
    
    var initials: String {
        guard !name.isEmpty else { return "?" }
        
        let components = name.split(separator: " ")
        if components.count >= 2 {
            let firstInitial = components.first?.first?.uppercased() ?? ""
            let lastInitial = components.last?.first?.uppercased() ?? ""
            return firstInitial + lastInitial
        } else if let firstChar = name.first {
            return String(firstChar).uppercased()
        }
        
        return "?"
    }
}
