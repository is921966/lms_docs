import Foundation

// MARK: - UserServiceProtocol

protocol UserServiceProtocol {
    func getUsers(page: Int, limit: Int) async throws -> UsersResponse
    func getUser(id: String) async throws -> UserResponse
    func createUser(_ user: CreateUserRequest) async throws -> UserResponse
    func updateUser(id: String, user: UpdateUserRequest) async throws -> UserResponse
    func deleteUser(id: String) async throws
    func updateProfile(_ profile: UpdateProfileRequest) async throws -> UserResponse
    func uploadAvatar(data: Data) async throws -> UserResponse
    func searchUsers(query: String, filters: UserFilters?) async throws -> UsersResponse
}

// MARK: - UserService

final class UserService: UserServiceProtocol {
    private let apiClient: APIClient
    
    init(apiClient: APIClient = .shared) {
        self.apiClient = apiClient
    }
    
    func getUsers(page: Int = 1, limit: Int = 20) async throws -> UsersResponse {
        return try await apiClient.request(UserEndpoint.getUsers(page: page, limit: limit))
    }
    
    func getUser(id: String) async throws -> UserResponse {
        return try await apiClient.request(UserEndpoint.getUser(id: id))
    }
    
    func createUser(_ user: CreateUserRequest) async throws -> UserResponse {
        return try await apiClient.request(UserEndpoint.createUser(user: user))
    }
    
    func updateUser(id: String, user: UpdateUserRequest) async throws -> UserResponse {
        return try await apiClient.request(UserEndpoint.updateUser(id: id, user: user))
    }
    
    func deleteUser(id: String) async throws {
        let _: EmptyResponse = try await apiClient.request(UserEndpoint.deleteUser(id: id))
    }
    
    func updateProfile(_ profile: UpdateProfileRequest) async throws -> UserResponse {
        return try await apiClient.request(UserEndpoint.updateProfile(profile: profile))
    }
    
    func uploadAvatar(data: Data) async throws -> UserResponse {
        // TODO: Implement multipart upload
        return try await apiClient.request(UserEndpoint.uploadAvatar(data: data))
    }
    
    func searchUsers(query: String, filters: UserFilters? = nil) async throws -> UsersResponse {
        return try await apiClient.request(UserEndpoint.searchUsers(query: query, filters: filters))
    }
}

// MARK: - EmptyResponse

struct EmptyResponse: Decodable {}

// MARK: - MockUserService

final class MockUserService: UserServiceProtocol {
    var mockUsers: [UserResponse] = []
    var shouldThrowError = false
    var error: Error = APIError.unknown(statusCode: 500)
    
    func getUsers(page: Int, limit: Int) async throws -> UsersResponse {
        if shouldThrowError { throw error }
        
        let startIndex = (page - 1) * limit
        let endIndex = min(startIndex + limit, mockUsers.count)
        let pageUsers = Array(mockUsers[startIndex..<endIndex])
        
        return UsersResponse(
            users: pageUsers,
            pagination: PaginationResponse(
                page: page,
                limit: limit,
                total: mockUsers.count,
                totalPages: (mockUsers.count + limit - 1) / limit
            )
        )
    }
    
    func getUser(id: String) async throws -> UserResponse {
        if shouldThrowError { throw error }
        
        guard let user = mockUsers.first(where: { $0.id == id }) else {
            throw APIError.notFound
        }
        return user
    }
    
    func createUser(_ user: CreateUserRequest) async throws -> UserResponse {
        if shouldThrowError { throw error }
        
        let newUser = UserResponse(
            id: UUID().uuidString,
            email: user.email,
            name: user.name,
            role: user.role,
            department: user.department,
            isActive: true,
            avatar: nil,
            createdAt: Date(),
            updatedAt: Date()
        )
        mockUsers.append(newUser)
        return newUser
    }
    
    func updateUser(id: String, user: UpdateUserRequest) async throws -> UserResponse {
        if shouldThrowError { throw error }
        
        guard let index = mockUsers.firstIndex(where: { $0.id == id }) else {
            throw APIError.notFound
        }
        
        var updatedUser = mockUsers[index]
        if let name = user.name { updatedUser.name = name }
        if let role = user.role { updatedUser.role = role }
        if let department = user.department { updatedUser.department = department }
        if let isActive = user.isActive { updatedUser.isActive = isActive }
        updatedUser.updatedAt = Date()
        
        mockUsers[index] = updatedUser
        return updatedUser
    }
    
    func deleteUser(id: String) async throws {
        if shouldThrowError { throw error }
        
        guard let index = mockUsers.firstIndex(where: { $0.id == id }) else {
            throw APIError.notFound
        }
        mockUsers.remove(at: index)
    }
    
    func updateProfile(_ profile: UpdateProfileRequest) async throws -> UserResponse {
        if shouldThrowError { throw error }
        
        // Mock implementation - update first user
        guard !mockUsers.isEmpty else {
            throw APIError.notFound
        }
        
        var user = mockUsers[0]
        if let name = profile.name { user.name = name }
        user.updatedAt = Date()
        mockUsers[0] = user
        return user
    }
    
    func uploadAvatar(data: Data) async throws -> UserResponse {
        if shouldThrowError { throw error }
        
        // Mock implementation
        guard !mockUsers.isEmpty else {
            throw APIError.notFound
        }
        
        var user = mockUsers[0]
        user.avatar = "https://example.com/avatar.jpg"
        user.updatedAt = Date()
        mockUsers[0] = user
        return user
    }
    
    func searchUsers(query: String, filters: UserFilters?) async throws -> UsersResponse {
        if shouldThrowError { throw error }
        
        let filteredUsers = mockUsers.filter { user in
            let matchesQuery = user.name.lowercased().contains(query.lowercased()) ||
                             user.email.lowercased().contains(query.lowercased())
            
            guard matchesQuery else { return false }
            
            if let filters = filters {
                if let role = filters.role, user.role != role { return false }
                if let department = filters.department, user.department != department { return false }
                if let isActive = filters.isActive, user.isActive != isActive { return false }
            }
            
            return true
        }
        
        return UsersResponse(
            users: filteredUsers,
            pagination: PaginationResponse(
                page: 1,
                limit: filteredUsers.count,
                total: filteredUsers.count,
                totalPages: 1
            )
        )
    }
} 