import XCTest
@testable import LMS

final class UserResponseTests: XCTestCase {
    
    var decoder: JSONDecoder!
    
    // Helper method to create UserResponse with defaults
    private func createUser(
        id: String = "test",
        email: String = "test@example.com",
        name: String = "Test User",
        role: UserRole = .student,
        department: String? = nil,
        isActive: Bool = true,
        avatarURL: String? = nil
    ) -> UserResponse {
        return UserResponse(
            id: id,
            email: email,
            name: name,
            role: role,
            avatarURL: avatarURL,
            department: department,
            isActive: isActive,
            createdAt: Date(),
            updatedAt: Date()
        )
    }
    
    override func setUp() {
        super.setUp()
        decoder = JSONDecoder()
    }
    
    override func tearDown() {
        decoder = nil
        super.tearDown()
    }
    
    // MARK: - Basic Decoding Tests
    
    func testUserResponseDecoding() throws {
        // Given
        let json = """
        {
            "id": "123",
            "email": "test@example.com",
            "name": "Test User",
            "role": "admin",
            "department": "IT",
            "isActive": true,
            "avatar": "https://example.com/avatar.jpg",
            "createdAt": "2025-01-01T00:00:00Z",
            "updatedAt": "2025-01-01T00:00:00Z"
        }
        """.data(using: .utf8)!
        
        decoder.dateDecodingStrategy = .iso8601
        
        // When
        let user = try decoder.decode(UserResponse.self, from: json)
        
        // Then
        XCTAssertEqual(user.id, "123")
        XCTAssertEqual(user.email, "test@example.com")
        XCTAssertEqual(user.name, "Test User")
        XCTAssertEqual(user.role, .admin)
        XCTAssertEqual(user.department, "IT")
        XCTAssertTrue(user.isActive)
        XCTAssertEqual(user.avatar, "https://example.com/avatar.jpg")
    }
    
    func testUserResponseDecodingWithOptionalFields() throws {
        // Given
        let json = """
        {
            "id": "456",
            "email": "minimal@example.com",
            "name": "Minimal User",
            "role": "student",
            "isActive": false,
            "createdAt": "2025-01-01T00:00:00Z",
            "updatedAt": "2025-01-01T00:00:00Z"
        }
        """.data(using: .utf8)!
        
        decoder.dateDecodingStrategy = .iso8601
        
        // When
        let user = try decoder.decode(UserResponse.self, from: json)
        
        // Then
        XCTAssertEqual(user.id, "456")
        XCTAssertEqual(user.email, "minimal@example.com")
        XCTAssertEqual(user.name, "Minimal User")
        XCTAssertEqual(user.role, .student)
        XCTAssertNil(user.department)
        XCTAssertNil(user.avatar)
        XCTAssertFalse(user.isActive)
    }
    
    // MARK: - Compatibility Extension Tests
    
    func testFirstNameLastNameMapping() {
        // Given
        let user = createUser(
            id: "789",
            email: "john.doe@example.com",
            name: "John Doe",
            role: .student
        )
        
        // When/Then
        XCTAssertEqual(user.firstName, "John")
        XCTAssertEqual(user.lastName, "Doe")
        XCTAssertEqual(user.fullName, "John Doe")
    }
    
    func testFirstNameLastNameWithSingleName() {
        // Given
        let user = createUser(
            id: "999",
            email: "admin@example.com",
            name: "Admin",
            role: .admin
        )
        
        // When/Then
        XCTAssertEqual(user.firstName, "Admin")
        XCTAssertEqual(user.lastName, "")
        XCTAssertEqual(user.fullName, "Admin")
    }
    
    func testFirstNameLastNameWithComplexName() {
        // Given
        let user = createUser(
            id: "111",
            email: "complex@example.com",
            name: "John Paul Jones Smith",
            role: .student
        )
        
        // When/Then
        XCTAssertEqual(user.firstName, "John")
        XCTAssertEqual(user.lastName, "Paul Jones Smith")
        XCTAssertEqual(user.fullName, "John Paul Jones Smith")
    }
    
    // MARK: - Role and Permission Tests
    
    func testRolePermissionMapping() {
        // Test Admin
        let admin = createUser(id: "1", email: "admin@test.com", name: "Admin", role: .admin)
        XCTAssertEqual(admin.roles, ["admin"])
        XCTAssertTrue(admin.permissions.contains("manage_users"))
        XCTAssertTrue(admin.permissions.contains("manage_courses"))
        XCTAssertTrue(admin.permissions.contains("view_analytics"))
        XCTAssertTrue(admin.isAdmin)
        XCTAssertFalse(admin.isStudent)
        
        // Test Student
        let student = createUser(id: "2", email: "student@test.com", name: "Student", role: .student)
        XCTAssertEqual(student.roles, ["student"])
        XCTAssertTrue(student.permissions.contains("view_courses"))
        XCTAssertTrue(student.permissions.contains("enroll_courses"))
        XCTAssertFalse(student.isAdmin)
        XCTAssertTrue(student.isStudent)
        
        // Test Instructor
        let instructor = createUser(id: "3", email: "instructor@test.com", name: "Instructor", role: .instructor)
        XCTAssertEqual(instructor.roles, ["instructor"])
        XCTAssertTrue(instructor.permissions.contains("create_courses"))
        XCTAssertTrue(instructor.permissions.contains("grade_students"))
        XCTAssertFalse(instructor.isAdmin)
        XCTAssertFalse(instructor.isStudent)
    }
    
    func testHasRoleMethod() {
        let user = createUser(id: "1", email: "test@test.com", name: "Test", role: .admin)
        
        XCTAssertTrue(user.hasRole("admin"))
        XCTAssertFalse(user.hasRole("student"))
        XCTAssertFalse(user.hasRole("instructor"))
        XCTAssertFalse(user.hasRole("unknown"))
    }
    
    func testHasPermissionMethod() {
        let admin = createUser(id: "1", email: "admin@test.com", name: "Admin", role: .admin)
        
        XCTAssertTrue(admin.hasPermission("manage_users"))
        XCTAssertTrue(admin.hasPermission("view_analytics"))
        XCTAssertFalse(admin.hasPermission("nonexistent_permission"))
        
        let student = createUser(id: "2", email: "student@test.com", name: "Student", role: .student)
        XCTAssertTrue(student.hasPermission("view_courses"))
        XCTAssertFalse(student.hasPermission("manage_users"))
    }
    
    // MARK: - Null Value Handling Tests
    
    func testNullValueHandling() throws {
        // Given - JSON with null values
        let json = """
        {
            "id": "null-test",
            "email": "null@test.com",
            "name": "Null Test",
            "role": "student",
            "isActive": true,
            "department": null,
            "avatar": null,
            "createdAt": "2025-01-01T00:00:00Z",
            "updatedAt": "2025-01-01T00:00:00Z"
        }
        """.data(using: .utf8)!
        
        decoder.dateDecodingStrategy = .iso8601
        
        // When
        let user = try decoder.decode(UserResponse.self, from: json)
        
        // Then
        XCTAssertEqual(user.id, "null-test")
        XCTAssertEqual(user.email, "null@test.com")
        XCTAssertEqual(user.name, "Null Test")
        XCTAssertEqual(user.role, .student)
        XCTAssertNil(user.department)
        XCTAssertNil(user.avatar)
        XCTAssertTrue(user.isActive)
    }
    
    // MARK: - Identifiable Conformance Tests
    
    func testIdentifiableConformance() {
        // Given
        let user1 = createUser(id: "123", email: "user1@test.com", name: "User 1", role: .student)
        let user2 = createUser(id: "456", email: "user2@test.com", name: "User 2", role: .student)
        let user3 = createUser(id: "123", email: "user3@test.com", name: "User 3", role: .admin)
        
        // When/Then
        XCTAssertEqual(user1.id, "123")
        XCTAssertEqual(user2.id, "456")
        XCTAssertEqual(user3.id, "123")
        
        // Test that users with same ID are considered equal for Identifiable purposes
        XCTAssertEqual(user1.id, user3.id)
        XCTAssertNotEqual(user1.id, user2.id)
    }
    
    // MARK: - Edge Cases
    
    func testEmptyNameHandling() {
        // Given
        let user = createUser(id: "empty", email: "empty@test.com", name: "", role: .student)
        
        // When/Then
        XCTAssertEqual(user.firstName, "")
        XCTAssertEqual(user.lastName, "")
        XCTAssertEqual(user.fullName, "")
    }
    
    func testWhitespaceInNameHandling() {
        // Given
        let user = createUser(
            id: "space",
            email: "space@test.com",
            name: "  John   Doe  ",
            role: .student
        )
        
        // When/Then
        // The split function should handle spaces properly
        XCTAssertEqual(user.firstName, "John")
        XCTAssertEqual(user.lastName, "Doe")
        XCTAssertEqual(user.fullName, "  John   Doe  ")
    }
    
    // MARK: - Backward Compatibility Tests
    
    func testBackwardCompatibilityWithOldCode() {
        // Given - simulating old code that expects firstName/lastName
        let user = createUser(
            id: "compat",
            email: "compat@test.com",
            name: "Compatible User",
            role: .admin
        )
        
        // When - old code would access these properties
        let displayName = "\(user.firstName) \(user.lastName)".trimmingCharacters(in: .whitespaces)
        let isAdminUser = user.roles.contains("admin")
        let canManageUsers = user.permissions.contains("manage_users")
        
        // Then
        XCTAssertEqual(displayName, "Compatible User")
        XCTAssertTrue(isAdminUser)
        XCTAssertTrue(canManageUsers)
    }
} 