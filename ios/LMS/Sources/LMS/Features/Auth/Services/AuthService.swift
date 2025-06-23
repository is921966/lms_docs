import Foundation
import Combine

class AuthService: AuthServiceProtocol {
    @Published private(set) var currentUser: User?
    
    func login(email: String, password: String) async throws -> User {
        // Simulate network delay
        try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
        
        // For demo purposes, accept any email/password
        // In real app, this would call the API
        if email == "admin@example.com" {
            let user = User(
                id: UUID(),
                email: email,
                name: "Admin User",
                role: .admin,
                avatarURL: nil
            )
            currentUser = user
            return user
        } else {
            let user = User(
                id: UUID(),
                email: email,
                name: "Regular User",
                role: .student,
                avatarURL: nil
            )
            currentUser = user
            return user
        }
    }
    
    func logout() async throws {
        // Clear stored credentials
        currentUser = nil
        
        // In real app, would call API to invalidate token
        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
    }
    
    func refreshToken() async throws {
        // In real app, would refresh JWT token
        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
    }
}
