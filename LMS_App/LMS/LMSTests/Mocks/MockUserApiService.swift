//
//  MockUserApiService.swift
//  LMSTests
//
//  Created on 06/07/2025.
//

import Foundation
@testable import LMS

// Mock для тестирования
class MockUserService {
    var mockUsers: [UserResponse] = []
    var shouldThrowError = false
    var error: Error = APIError.serverError(statusCode: 500)
    
    func getUsers(page: Int, limit: Int) async throws -> UsersResponse {
        if shouldThrowError { throw error }
        
        let startIndex = (page - 1) * limit
        let endIndex = min(startIndex + limit, mockUsers.count)
        let pageUsers = Array(mockUsers[startIndex..<endIndex])
        
        return UsersResponse(
            users: pageUsers,
            pagination: PaginationInfo(
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
    
    func createUser(_ request: CreateUserRequest) async throws -> UserResponse {
        if shouldThrowError { throw error }
        
        let newUser = UserResponse(
            id: UUID().uuidString,
            email: request.email,
            name: request.name,
            role: request.role,
            department: request.department,
            isActive: true,
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
        user.avatarURL = "https://example.com/avatar.jpg"
        user.updatedAt = Date()
        mockUsers[0] = user
        return user
    }
    
    func searchUsers(query: String, filters: UserFilters?) async throws -> UsersResponse {
        if shouldThrowError { throw error }
        
        let filteredUsers = mockUsers.filter { user in
            let matchesQuery = user.name.localizedCaseInsensitiveContains(query.lowercased()) ||
                             user.email.localizedCaseInsensitiveContains(query.lowercased())
            
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
            pagination: PaginationInfo(
                page: 1,
                limit: filteredUsers.count,
                total: filteredUsers.count,
                totalPages: 1
            )
        )
    }
}

// MARK: - Mock Auth Service
@MainActor
class MockAuthService: AuthServiceProtocol {
    static let shared = MockAuthService()
    
    var isAuthenticated: Bool = false
    var currentUser: UserResponse? = nil
    var authError: Error? = nil
    var shouldFail = false
    var hasRefreshedToken = false
    
    private init() {}
    
    func login(email: String, password: String) async throws -> LoginResponse {
        if shouldFail {
            throw authError ?? APIError.invalidCredentials
        }
        
        let user = UserResponse(
            id: "user123",
            email: email,
            name: "Test User",
            role: .student,
            avatarURL: nil,
            firstName: "Test",
            lastName: "User",
            middleName: nil,
            phone: nil,
            birthDate: nil,
            department: nil,
            position: nil,
            hireDate: nil,
            isActive: true,
            permissions: [],
            createdAt: Date(),
            updatedAt: Date()
        )
        
        self.currentUser = user
        self.isAuthenticated = true
        
        return LoginResponse(
            accessToken: "mock-access-token",
            refreshToken: "mock-refresh-token",
            user: user,
            expiresIn: 3600
        )
    }
    
    func logout() async throws {
        self.currentUser = nil
        self.isAuthenticated = false
    }
    
    func refreshToken() async throws -> String {
        if shouldFail {
            throw authError ?? APIError.invalidCredentials
        }
        hasRefreshedToken = true
        return "mock-refreshed-token"
    }
    
    func getCurrentUser() async throws -> UserResponse {
        if shouldFail {
            throw authError ?? APIError.unauthorized
        }
        guard let user = currentUser else {
            throw APIError.unauthorized
        }
        return user
    }
    
    func updateProfile(firstName: String, lastName: String) async throws -> UserResponse {
        guard var user = currentUser else {
            throw APIError.unauthorized
        }
        
        user.firstName = firstName
        user.lastName = lastName
        user.name = "\(firstName) \(lastName)"
        user.updatedAt = Date()
        
        self.currentUser = user
        return user
    }
    
    func isTokenValid() -> Bool {
        return isAuthenticated && !shouldFail
    }
    
    func clearSession() {
        currentUser = nil
        isAuthenticated = false
    }
}

// MARK: - Mock Competency Service
class MockCompetencyService {
    func getCompetencies(page: Int, limit: Int, filters: [String: Any]?) async throws -> CompetencyListResponse {
        // Return mock competencies
        let competencies = [
            CompetencyDTO(
                id: "comp1",
                name: "iOS Development",
                description: "iOS разработка",
                level: "Senior",
                category: "Technical"
            ),
            CompetencyDTO(
                id: "comp2",
                name: "Swift Programming",
                description: "Программирование на Swift",
                level: "Middle",
                category: "Technical"
            ),
            CompetencyDTO(
                id: "comp3",
                name: "Team Leadership",
                description: "Управление командой",
                level: "Senior",
                category: "Management"
            )
        ]
        
        return CompetencyListResponse(
            competencies: competencies,
            total: competencies.count,
            page: page,
            limit: limit
        )
    }
} 