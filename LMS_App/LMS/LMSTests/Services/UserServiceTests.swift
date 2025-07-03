import XCTest
@testable import LMS

final class UserServiceTests: XCTestCase {
    var sut: UserService!
    var mockAPIClient: MockAPIClient!
    
    override func setUp() {
        super.setUp()
        mockAPIClient = MockAPIClient()
        sut = UserService(apiClient: mockAPIClient)
    }
    
    override func tearDown() {
        sut = nil
        mockAPIClient = nil
        super.tearDown()
    }
    
    // MARK: - Get Users Tests
    
    func testGetUsersSuccess() async throws {
        // Given
        let expectedUsers = UsersResponse(
            users: [
                UserResponse(
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
            ],
            pagination: PaginationResponse(
                page: 1,
                limit: 20,
                total: 1,
                totalPages: 1
            )
        )
        mockAPIClient.mockResponse = expectedUsers
        
        // When
        let result = try await sut.getUsers(page: 1, limit: 20)
        
        // Then
        XCTAssertEqual(result.users.count, 1)
        XCTAssertEqual(result.users[0].email, "user1@example.com")
        XCTAssertEqual(result.pagination.page, 1)
    }
    
    func testGetUsersFailure() async {
        // Given
        mockAPIClient.shouldThrowError = true
        mockAPIClient.error = APIError.networkError(NSError(domain: "test", code: -1))
        
        // When/Then
        do {
            _ = try await sut.getUsers(page: 1, limit: 20)
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertTrue(error is APIError)
        }
    }
    
    // MARK: - Get User Tests
    
    func testGetUserSuccess() async throws {
        // Given
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
        mockAPIClient.mockResponse = expectedUser
        
        // When
        let result = try await sut.getUser(id: "123")
        
        // Then
        XCTAssertEqual(result.id, "123")
        XCTAssertEqual(result.email, "test@example.com")
    }
    
    // MARK: - Create User Tests
    
    func testCreateUserSuccess() async throws {
        // Given
        let createRequest = CreateUserRequest(
            email: "new@example.com",
            name: "New User",
            password: "password123",
            role: "student",
            department: "IT"
        )
        
        let expectedUser = UserResponse(
            id: "456",
            email: createRequest.email,
            name: createRequest.name,
            role: createRequest.role,
            department: createRequest.department,
            isActive: true,
            avatar: nil,
            createdAt: Date(),
            updatedAt: Date()
        )
        mockAPIClient.mockResponse = expectedUser
        
        // When
        let result = try await sut.createUser(createRequest)
        
        // Then
        XCTAssertEqual(result.email, createRequest.email)
        XCTAssertEqual(result.name, createRequest.name)
    }
    
    // MARK: - Update User Tests
    
    func testUpdateUserSuccess() async throws {
        // Given
        let updateRequest = UpdateUserRequest(
            name: "Updated Name",
            role: "admin",
            department: "HR",
            isActive: true
        )
        
        let expectedUser = UserResponse(
            id: "123",
            email: "test@example.com",
            name: "Updated Name",
            role: "admin",
            department: "HR",
            isActive: true,
            avatar: nil,
            createdAt: Date(),
            updatedAt: Date()
        )
        mockAPIClient.mockResponse = expectedUser
        
        // When
        let result = try await sut.updateUser(id: "123", user: updateRequest)
        
        // Then
        XCTAssertEqual(result.name, "Updated Name")
        XCTAssertEqual(result.role, "admin")
        XCTAssertEqual(result.department, "HR")
    }
    
    // MARK: - Delete User Tests
    
    func testDeleteUserSuccess() async throws {
        // Given
        mockAPIClient.mockResponse = EmptyResponse()
        
        // When/Then - Should not throw
        try await sut.deleteUser(id: "123")
    }
    
    // MARK: - Search Users Tests
    
    func testSearchUsersWithFilters() async throws {
        // Given
        let filters = UserFilters(
            role: "student",
            department: "IT",
            isActive: true
        )
        
        let expectedUsers = UsersResponse(
            users: [
                UserResponse(
                    id: "1",
                    email: "student@example.com",
                    name: "Student User",
                    role: "student",
                    department: "IT",
                    isActive: true,
                    avatar: nil,
                    createdAt: Date(),
                    updatedAt: Date()
                )
            ],
            pagination: PaginationResponse(
                page: 1,
                limit: 10,
                total: 1,
                totalPages: 1
            )
        )
        mockAPIClient.mockResponse = expectedUsers
        
        // When
        let result = try await sut.searchUsers(query: "student", filters: filters)
        
        // Then
        XCTAssertEqual(result.users.count, 1)
        XCTAssertEqual(result.users[0].role, "student")
        XCTAssertEqual(result.users[0].department, "IT")
    }
}

// MARK: - MockAPIClient

class MockAPIClient: APIClient {
    var mockResponse: Any?
    var shouldThrowError = false
    var error: Error = APIError.unknown("Mock error")
    
    override func request<T: Decodable>(_ endpoint: APIEndpoint) async throws -> T {
        if shouldThrowError {
            throw error
        }
        
        guard let response = mockResponse as? T else {
            throw APIError.decodingError
        }
        
        return response
    }
} 