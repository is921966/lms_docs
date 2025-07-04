import Testing
import Foundation
@testable import LMS

struct UserServiceTests {
    
    @Test("Get users returns correct data")
    func testGetUsersSuccess() async throws {
        // Given
        let sut = MockUserService()
        let expectedUser = UserResponse(
            id: "1",
            email: "user1@example.com",
            name: "User 1",
            role: "student",
            department: "IT",
            isActive: true,
            avatar: nil,
            createdAt: Date(),
            updatedAt: Date()
        )
        sut.mockUsers = [expectedUser]
        
        // When
        let result = try await sut.getUsers(page: 1, limit: 20)
        
        // Then
        #expect(result.users.count == 1)
        #expect(result.users[0].email == "user1@example.com")
        #expect(result.pagination.page == 1)
        #expect(result.pagination.total == 1)
    }
    
    @Test("Get users throws error when error is set")
    func testGetUsersFailure() async throws {
        // Given
        let sut = MockUserService()
        sut.shouldThrowError = true
        sut.error = APIError.networkError(URLError(.notConnectedToInternet))
        
        // When/Then
        await #expect(throws: (any Error).self) {
            _ = try await sut.getUsers(page: 1, limit: 20)
        }
    }
    
    @Test("Get users pagination works correctly")
    func testGetUsersPagination() async throws {
        // Given
        let sut = MockUserService()
        var users: [UserResponse] = []
        for i in 1...25 {
            users.append(UserResponse(
                id: "\(i)",
                email: "user\(i)@example.com",
                name: "User \(i)",
                role: "student",
                department: "IT",
                isActive: true,
                avatar: nil,
                createdAt: Date(),
                updatedAt: Date()
            ))
        }
        sut.mockUsers = users
        
        // When - Get page 2 with limit 10
        let result = try await sut.getUsers(page: 2, limit: 10)
        
        // Then
        #expect(result.users.count == 10)
        #expect(result.users[0].id == "11") // First user on page 2
        #expect(result.pagination.page == 2)
        #expect(result.pagination.totalPages == 3)
    }
    
    @Test("Get user by ID returns correct user")
    func testGetUserSuccess() async throws {
        // Given
        let sut = MockUserService()
        let expectedUser = UserResponse(
            id: "123",
            email: "test@example.com",
            name: "Test User",
            role: "student",
            department: "IT",
            isActive: true,
            avatar: nil,
            createdAt: Date(),
            updatedAt: Date()
        )
        sut.mockUsers = [expectedUser]
        
        // When
        let result = try await sut.getUser(id: "123")
        
        // Then
        #expect(result.id == "123")
        #expect(result.email == "test@example.com")
    }
    
    @Test("Get user throws not found error")
    func testGetUserNotFound() async throws {
        // Given
        let sut = MockUserService()
        sut.mockUsers = []
        
        // When/Then
        do {
            _ = try await sut.getUser(id: "non-existent")
            Issue.record("Expected error to be thrown")
        } catch {
            // Check if it's the correct error type
            if case APIError.notFound = error {
                // Success - correct error was thrown
            } else {
                Issue.record("Expected APIError.notFound but got \(error)")
            }
        }
    }
    
    @Test("Create user adds user to storage")
    func testCreateUserSuccess() async throws {
        // Given
        let sut = MockUserService()
        let createRequest = CreateUserRequest(
            email: "new@example.com",
            name: "New User",
            role: "student",
            department: "IT",
            password: "password123"
        )
        
        // When
        let result = try await sut.createUser(createRequest)
        
        // Then
        #expect(result.email == createRequest.email)
        #expect(result.name == createRequest.name)
        #expect(result.role == createRequest.role)
        #expect(result.department == createRequest.department)
        #expect(result.isActive == true)
        #expect(sut.mockUsers.count == 1)
    }
    
    @Test("Update user modifies existing user")
    func testUpdateUserSuccess() async throws {
        // Given
        let sut = MockUserService()
        let existingUser = UserResponse(
            id: "123",
            email: "test@example.com",
            name: "Test User",
            role: "student",
            department: "IT",
            isActive: true,
            avatar: nil,
            createdAt: Date(),
            updatedAt: Date()
        )
        sut.mockUsers = [existingUser]
        
        let updateRequest = UpdateUserRequest(
            name: "Updated Name",
            role: "admin",
            department: "HR",
            isActive: true
        )
        
        // When
        let result = try await sut.updateUser(id: "123", user: updateRequest)
        
        // Then
        #expect(result.name == "Updated Name")
        #expect(result.role == "admin")
        #expect(result.department == "HR")
        #expect(result.isActive == true)
    }
    
    @Test("Delete user removes from storage")
    func testDeleteUserSuccess() async throws {
        // Given
        let sut = MockUserService()
        let user = UserResponse(
            id: "123",
            email: "test@example.com",
            name: "Test User",
            role: "student",
            department: "IT",
            isActive: true,
            avatar: nil,
            createdAt: Date(),
            updatedAt: Date()
        )
        sut.mockUsers = [user]
        
        // When
        try await sut.deleteUser(id: "123")
        
        // Then
        #expect(sut.mockUsers.count == 0)
    }
    
    @Test("Search users with filters returns filtered results")
    func testSearchUsersWithFilters() async throws {
        // Given
        let sut = MockUserService()
        let users = [
            UserResponse(id: "1", email: "student@example.com", name: "Student User", role: "student", department: "IT", isActive: true, avatar: nil, createdAt: Date(), updatedAt: Date()),
            UserResponse(id: "2", email: "teacher@example.com", name: "Teacher User", role: "teacher", department: "IT", isActive: true, avatar: nil, createdAt: Date(), updatedAt: Date()),
            UserResponse(id: "3", email: "admin@example.com", name: "Admin User", role: "admin", department: "HR", isActive: true, avatar: nil, createdAt: Date(), updatedAt: Date())
        ]
        sut.mockUsers = users
        
        let filters = UserFilters(
            role: "student",
            department: "IT",
            isActive: true,
            search: nil
        )
        
        // When
        let result = try await sut.searchUsers(query: "student", filters: filters)
        
        // Then
        #expect(result.users.count == 1)
        #expect(result.users[0].role == "student")
        #expect(result.users[0].department == "IT")
    }
    
    @Test("Update profile updates first user")
    func testUpdateProfileSuccess() async throws {
        // Given
        let sut = MockUserService()
        let user = UserResponse(
            id: "123",
            email: "test@example.com",
            name: "Test User",
            role: "student",
            department: "IT",
            isActive: true,
            avatar: nil,
            createdAt: Date(),
            updatedAt: Date()
        )
        sut.mockUsers = [user]
        
        let updateRequest = UpdateProfileRequest(
            name: "Updated Profile Name",
            department: nil,
            avatar: nil,
            phone: "+1234567890",
            bio: "Updated bio",
            preferences: nil
        )
        
        // When
        let result = try await sut.updateProfile(updateRequest)
        
        // Then
        #expect(result.name == "Updated Profile Name")
    }
    
    @Test("Upload avatar sets avatar URL")
    func testUploadAvatarSuccess() async throws {
        // Given
        let sut = MockUserService()
        let user = UserResponse(
            id: "123",
            email: "test@example.com",
            name: "Test User",
            role: "student",
            department: "IT",
            isActive: true,
            avatar: nil,
            createdAt: Date(),
            updatedAt: Date()
        )
        sut.mockUsers = [user]
        
        let imageData = Data("fake-image-data".utf8)
        
        // When
        let result = try await sut.uploadAvatar(data: imageData)
        
        // Then
        #expect(result.avatar != nil)
        #expect(result.avatar == "https://example.com/avatar.jpg")
    }
} 