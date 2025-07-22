import XCTest
@testable import LMS

final class OrgEmployeeTests: XCTestCase {
    
    // MARK: - Initialization Tests
    
    func testEmployeeInitialization() {
        // Given
        let employee = OrgEmployee(
            id: "test-id",
            tabNumber: "АР21000001",
            name: "Иванов Иван Иванович",
            position: "Разработчик",
            departmentId: "dept-1",
            email: "ivanov@tsum.ru",
            phone: "+79991234567",
            photoUrl: "https://example.com/photo.jpg"
        )
        
        // Then
        XCTAssertEqual(employee.id, "test-id")
        XCTAssertEqual(employee.tabNumber, "АР21000001")
        XCTAssertEqual(employee.name, "Иванов Иван Иванович")
        XCTAssertEqual(employee.position, "Разработчик")
        XCTAssertEqual(employee.departmentId, "dept-1")
        XCTAssertEqual(employee.email, "ivanov@tsum.ru")
        XCTAssertEqual(employee.phone, "+79991234567")
        XCTAssertEqual(employee.photoUrl, "https://example.com/photo.jpg")
    }
    
    func testEmployeeMinimalInitialization() {
        // Given
        let employee = OrgEmployee(
            tabNumber: "АР21000002",
            name: "Петров Петр",
            position: "Менеджер",
            departmentId: "dept-2"
        )
        
        // Then
        XCTAssertFalse(employee.id.isEmpty)
        XCTAssertEqual(employee.tabNumber, "АР21000002")
        XCTAssertEqual(employee.name, "Петров Петр")
        XCTAssertEqual(employee.position, "Менеджер")
        XCTAssertEqual(employee.departmentId, "dept-2")
        XCTAssertNil(employee.email)
        XCTAssertNil(employee.phone)
        XCTAssertNil(employee.photoUrl)
    }
    
    // MARK: - Initials Tests
    
    func testInitialsGeneration() {
        let testCases: [(name: String, expectedInitials: String)] = [
            ("Иванов Иван Иванович", "ИИ"),
            ("Петров Петр", "ПП"),
            ("Сидоров", "С"),
            ("Мария Александровна Козлова", "МА"),
            ("", ""),
            ("А", "А"),
            ("А Б В", "АБ")
        ]
        
        for testCase in testCases {
            let employee = OrgEmployee(
                tabNumber: "АР21000000",
                name: testCase.name,
                position: "Test",
                departmentId: "1"
            )
            
            XCTAssertEqual(employee.initials, testCase.expectedInitials,
                          "Name '\(testCase.name)' should produce initials '\(testCase.expectedInitials)'")
        }
    }
    
    // MARK: - Phone Formatting Tests
    
    func testPhoneFormatting() {
        let testCases: [(phone: String?, expectedFormatted: String?)] = [
            ("+79991234567", "+7 (999) 123-45-67"),
            ("+79001234567", "+7 (900) 123-45-67"),
            ("+71234567890", "+7 (123) 456-78-90"),
            ("89991234567", "89991234567"), // Not starting with +7
            ("+7999123456", "+7999123456"), // Too short
            ("+799912345678", "+799912345678"), // Too long
            ("1234567890", "1234567890"), // Different format
            (nil, nil)
        ]
        
        for testCase in testCases {
            let employee = OrgEmployee(
                tabNumber: "АР21000000",
                name: "Test",
                position: "Test",
                departmentId: "1",
                phone: testCase.phone
            )
            
            XCTAssertEqual(employee.formattedPhone, testCase.expectedFormatted,
                          "Phone '\(testCase.phone ?? "nil")' should be formatted as '\(testCase.expectedFormatted ?? "nil")'")
        }
    }
    
    // MARK: - Equatable Tests
    
    func testEmployeeEquality() {
        let emp1 = OrgEmployee(
            id: "same-id",
            tabNumber: "АР21000001",
            name: "Иванов",
            position: "Dev",
            departmentId: "1"
        )
        
        let emp2 = OrgEmployee(
            id: "same-id",
            tabNumber: "АР21000002",
            name: "Петров",
            position: "Manager",
            departmentId: "2"
        )
        
        let emp3 = OrgEmployee(
            id: "other-id",
            tabNumber: "АР21000001",
            name: "Иванов",
            position: "Dev",
            departmentId: "1"
        )
        
        XCTAssertEqual(emp1, emp2) // Same ID
        XCTAssertNotEqual(emp1, emp3) // Different ID
    }
    
    // MARK: - Mock Data Tests
    
    func testMockEmployeesStructure() {
        // Test that mock data is properly structured
        XCTAssertFalse(OrgEmployee.mockEmployees.isEmpty)
        
        // Check specific departments have employees
        XCTAssertNotNil(OrgEmployee.mockEmployees["1"]) // ЦУМ
        XCTAssertNotNil(OrgEmployee.mockEmployees["5"]) // IT Департамент
        XCTAssertNotNil(OrgEmployee.mockEmployees["6"]) // Отдел Разработки
        XCTAssertNotNil(OrgEmployee.mockEmployees["8"]) // HR Департамент
        
        // Check employee counts
        XCTAssertEqual(OrgEmployee.mockEmployees["1"]?.count, 2)
        XCTAssertEqual(OrgEmployee.mockEmployees["6"]?.count, 3)
    }
    
    func testMockEmployeesForDepartment() {
        // Test existing department
        let itEmployees = OrgEmployee.mockEmployees(for: "5")
        XCTAssertEqual(itEmployees.count, 1)
        XCTAssertEqual(itEmployees.first?.name, "Сидоров Алексей Николаевич")
        
        // Test non-existing department
        let emptyEmployees = OrgEmployee.mockEmployees(for: "999")
        XCTAssertTrue(emptyEmployees.isEmpty)
    }
    
    func testAllMockEmployees() {
        let allEmployees = OrgEmployee.allMockEmployees
        
        // Count total employees
        let expectedCount = OrgEmployee.mockEmployees.values.reduce(0) { $0 + $1.count }
        XCTAssertEqual(allEmployees.count, expectedCount)
        
        // Check all have valid tab numbers
        for employee in allEmployees {
            XCTAssertTrue(employee.tabNumber.starts(with: "АР"))
            XCTAssertEqual(employee.tabNumber.count, 10) // АР + 8 digits
        }
    }
    
    // MARK: - Codable Tests
    
    func testEmployeeCodable() throws {
        // Given
        let original = OrgEmployee(
            id: "test-id",
            tabNumber: "АР21000001",
            name: "Тест Тестович",
            position: "Тестировщик",
            departmentId: "dept-1",
            email: "test@example.com",
            phone: "+79991234567"
        )
        
        // When
        let encoder = JSONEncoder()
        let data = try encoder.encode(original)
        
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(OrgEmployee.self, from: data)
        
        // Then
        XCTAssertEqual(decoded.id, original.id)
        XCTAssertEqual(decoded.tabNumber, original.tabNumber)
        XCTAssertEqual(decoded.name, original.name)
        XCTAssertEqual(decoded.position, original.position)
        XCTAssertEqual(decoded.departmentId, original.departmentId)
        XCTAssertEqual(decoded.email, original.email)
        XCTAssertEqual(decoded.phone, original.phone)
    }
    
    // MARK: - Tab Number Validation Tests
    
    func testTabNumberFormat() {
        // Valid tab numbers
        let validTabNumbers = [
            "АР21000001",
            "АР12345678",
            "АР99999999",
            "АР00000000"
        ]
        
        for tabNumber in validTabNumbers {
            let employee = OrgEmployee(
                tabNumber: tabNumber,
                name: "Test",
                position: "Test",
                departmentId: "1"
            )
            
            XCTAssertTrue(employee.tabNumber.starts(with: "АР"))
            XCTAssertEqual(employee.tabNumber.count, 10)
        }
    }
} 