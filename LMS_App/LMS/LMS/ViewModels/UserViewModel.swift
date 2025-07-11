import Foundation
import SwiftUI
import Combine

@MainActor
class UserViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var users: [User] = []
    @Published var filteredUsers: [User] = []
    @Published var searchText = ""
    @Published var selectedRole: User.Role?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var selectedUsers: Set<UUID> = []
    @Published var isSelectionMode = false
    
    // MARK: - Dependencies
    private let userService: UserServiceProtocol
    
    // MARK: - Initialization
    init(userService: UserServiceProtocol? = nil) {
        self.userService = userService ?? MockUserService()
        setupSearch()
    }
    
    // MARK: - Methods
    func loadUsers() async {
        isLoading = true
        errorMessage = nil
        
        do {
            // Simulate network delay
            try? await Task.sleep(nanoseconds: 500_000_000)
            
            users = try await userService.fetchUsers()
            applyFilters()
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func refreshUsers() async {
        await loadUsers()
    }
    
    func deleteUser(_ user: User) async {
        do {
            try await userService.deleteUser(user.id)
            users.removeAll { $0.id == user.id }
            applyFilters()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func deleteSelectedUsers() async {
        isLoading = true
        
        for userId in selectedUsers {
            do {
                try await userService.deleteUser(userId)
                users.removeAll { $0.id == userId }
            } catch {
                errorMessage = error.localizedDescription
            }
        }
        
        selectedUsers.removeAll()
        isSelectionMode = false
        applyFilters()
        isLoading = false
    }
    
    func toggleUserSelection(_ user: User) {
        if selectedUsers.contains(user.id) {
            selectedUsers.remove(user.id)
        } else {
            selectedUsers.insert(user.id)
        }
    }
    
    func selectAll() {
        selectedUsers = Set(filteredUsers.map { $0.id })
    }
    
    func deselectAll() {
        selectedUsers.removeAll()
    }
    
    // MARK: - Private Methods
    private func setupSearch() {
        // Observe search text changes
        $searchText
            .removeDuplicates()
            .sink { [weak self] _ in
                self?.applyFilters()
            }
            .store(in: &cancellables)
        
        // Observe role filter changes
        $selectedRole
            .sink { [weak self] _ in
                self?.applyFilters()
            }
            .store(in: &cancellables)
    }
    
    private func applyFilters() {
        filteredUsers = users.filter { user in
            let matchesSearch = searchText.isEmpty ||
                user.name.localizedCaseInsensitiveContains(searchText) ||
                user.email.localizedCaseInsensitiveContains(searchText)
            
            let matchesRole = selectedRole == nil || user.role == selectedRole
            
            return matchesSearch && matchesRole
        }
    }
    
    private var cancellables = Set<AnyCancellable>()
}

// MARK: - Mock Service
class MockUserService: UserServiceProtocol {
    private var mockUsers: [User] = [
        User(id: UUID(), email: "john.doe@example.com", name: "John Doe", role: .student, avatarURL: nil),
        User(id: UUID(), email: "jane.smith@example.com", name: "Jane Smith", role: .instructor, avatarURL: nil),
        User(id: UUID(), email: "admin@example.com", name: "Admin User", role: .admin, avatarURL: nil),
        User(id: UUID(), email: "super@example.com", name: "Super Admin", role: .superAdmin, avatarURL: nil),
        User(id: UUID(), email: "alice.johnson@example.com", name: "Alice Johnson", role: .student, avatarURL: nil),
        User(id: UUID(), email: "bob.wilson@example.com", name: "Bob Wilson", role: .student, avatarURL: nil),
        User(id: UUID(), email: "carol.davis@example.com", name: "Carol Davis", role: .instructor, avatarURL: nil),
        User(id: UUID(), email: "david.brown@example.com", name: "David Brown", role: .student, avatarURL: nil),
    ]
    
    func fetchUsers() async throws -> [User] {
        return mockUsers
    }
    
    func fetchUser(id: UUID) async throws -> User {
        guard let user = mockUsers.first(where: { $0.id == id }) else {
            throw UserError.notFound
        }
        return user
    }
    
    func createUser(_ user: User) async throws -> User {
        mockUsers.append(user)
        return user
    }
    
    func updateUser(_ user: User) async throws -> User {
        guard let index = mockUsers.firstIndex(where: { $0.id == user.id }) else {
            throw UserError.notFound
        }
        mockUsers[index] = user
        return user
    }
    
    func deleteUser(_ id: UUID) async throws {
        mockUsers.removeAll { $0.id == id }
    }
}

enum UserError: LocalizedError {
    case notFound
    case invalidData
    case networkError
    
    var errorDescription: String? {
        switch self {
        case .notFound:
            return "User not found"
        case .invalidData:
            return "Invalid user data"
        case .networkError:
            return "Network error occurred"
        }
    }
}
