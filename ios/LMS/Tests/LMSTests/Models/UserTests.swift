import XCTest
@testable import LMS

final class UserTests: XCTestCase {
    
    func testUserInitialization() {
        // Given
        let id = UUID()
        let email = "test@example.com"
        let name = "Test User"
        let role = User.Role.student
        let avatarURL = URL(string: "https://example.com/avatar.jpg")
        
        // When
        let user = User(
            id: id,
            email: email,
            name: name,
            role: role,
            avatarURL: avatarURL
        )
        
        // Then
        XCTAssertEqual(user.id, id)
        XCTAssertEqual(user.email, email)
        XCTAssertEqual(user.name, name)
        XCTAssertEqual(user.role, role)
        XCTAssertEqual(user.avatarURL, avatarURL)
    }
    
    func testUserDecodingFromJSON() throws {
        // Given
        let json = """
        {
            "id": "550e8400-e29b-41d4-a716-446655440000",
            "email": "john.doe@example.com",
            "name": "John Doe",
            "role": "admin",
            "avatarURL": "https://example.com/john.jpg"
        }
        """.data(using: .utf8)!
        
        // When
        let user = try JSONDecoder().decode(User.self, from: json)
        
        // Then
        XCTAssertEqual(user.id.uuidString, "550E8400-E29B-41D4-A716-446655440000")
        XCTAssertEqual(user.email, "john.doe@example.com")
        XCTAssertEqual(user.name, "John Doe")
        XCTAssertEqual(user.role, .admin)
        XCTAssertEqual(user.avatarURL?.absoluteString, "https://example.com/john.jpg")
    }
    
    func testUserEncodingToJSON() throws {
        // Given
        let user = User(
            id: UUID(uuidString: "550e8400-e29b-41d4-a716-446655440000")!,
            email: "jane.doe@example.com",
            name: "Jane Doe",
            role: .instructor,
            avatarURL: nil
        )
        
        // When
        let encoder = JSONEncoder()
        encoder.outputFormatting = .sortedKeys
        let data = try encoder.encode(user)
        let json = String(data: data, encoding: .utf8)!
        
        // Then
        XCTAssertTrue(json.contains("\"email\":\"jane.doe@example.com\""))
        XCTAssertTrue(json.contains("\"name\":\"Jane Doe\""))
        XCTAssertTrue(json.contains("\"role\":\"instructor\""))
        XCTAssertTrue(json.contains("\"id\":\"550E8400-E29B-41D4-A716-446655440000\""))
    }
    
    func testUserRoles() {
        // Test all possible roles
        XCTAssertEqual(User.Role.student.rawValue, "student")
        XCTAssertEqual(User.Role.instructor.rawValue, "instructor")
        XCTAssertEqual(User.Role.admin.rawValue, "admin")
        XCTAssertEqual(User.Role.superAdmin.rawValue, "super_admin")
    }
    
    func testUserDisplayName() {
        // Given
        let user = User(
            id: UUID(),
            email: "test@example.com",
            name: "Test User",
            role: .student,
            avatarURL: nil
        )
        
        // Then
        XCTAssertEqual(user.displayName, "Test User")
    }
    
    func testUserInitials() {
        // Test various name formats
        let testCases = [
            ("John Doe", "JD"),
            ("Jane", "J"),
            ("Mary Jane Watson", "MW"),
            ("", "?"),
            ("a", "A")
        ]
        
        for (name, expectedInitials) in testCases {
            let user = User(
                id: UUID(),
                email: "test@example.com",
                name: name,
                role: .student,
                avatarURL: nil
            )
            XCTAssertEqual(user.initials, expectedInitials, "Failed for name: \(name)")
        }
    }
} 