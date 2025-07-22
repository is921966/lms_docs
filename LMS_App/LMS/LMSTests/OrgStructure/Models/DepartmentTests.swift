import XCTest
@testable import LMS

final class DepartmentTests: XCTestCase {
    
    // MARK: - Basic Properties Tests
    
    func testDepartmentInitialization() {
        // Given
        let department = Department(
            id: "test-id",
            name: "IT Department",
            code: "АП.1",
            parentId: "parent-id",
            employeeCount: 10
        )
        
        // Then
        XCTAssertEqual(department.id, "test-id")
        XCTAssertEqual(department.name, "IT Department")
        XCTAssertEqual(department.code, "АП.1")
        XCTAssertEqual(department.parentId, "parent-id")
        XCTAssertEqual(department.employeeCount, 10)
        XCTAssertNil(department.children)
    }
    
    func testDepartmentDefaultId() {
        // Given
        let department = Department(
            name: "Test Department",
            code: "АП.2"
        )
        
        // Then
        XCTAssertFalse(department.id.isEmpty)
        XCTAssertTrue(department.id.contains("-")) // UUID format
    }
    
    // MARK: - Computed Properties Tests
    
    func testDepartmentLevel() {
        // Test cases
        let testCases: [(code: String, expectedLevel: Int)] = [
            ("АП", 1),
            ("АП.1", 2),
            ("АП.1.1", 3),
            ("АП.1.1.1", 4),
            ("АП.2.3.4.5", 5)
        ]
        
        for testCase in testCases {
            let department = Department(name: "Test", code: testCase.code)
            XCTAssertEqual(department.level, testCase.expectedLevel, 
                          "Code \(testCase.code) should have level \(testCase.expectedLevel)")
        }
    }
    
    func testHasChildren() {
        // Department without children
        var department = Department(name: "Test", code: "АП.1")
        XCTAssertFalse(department.hasChildren)
        
        // Department with empty children array
        department.children = []
        XCTAssertFalse(department.hasChildren)
        
        // Department with children
        department.children = [
            Department(name: "Child", code: "АП.1.1", parentId: department.id)
        ]
        XCTAssertTrue(department.hasChildren)
    }
    
    // MARK: - Hierarchy Tests
    
    func testFindDepartmentById() {
        // Given
        let child1 = Department(id: "child1", name: "Child 1", code: "АП.1.1")
        let child2 = Department(id: "child2", name: "Child 2", code: "АП.1.2")
        let grandchild = Department(id: "grandchild", name: "Grandchild", code: "АП.1.1.1")
        
        var parent = Department(id: "parent", name: "Parent", code: "АП.1")
        var childWithGrandchild = child1
        childWithGrandchild.children = [grandchild]
        parent.children = [childWithGrandchild, child2]
        
        // When & Then
        XCTAssertNotNil(parent.findDepartment(by: "parent"))
        XCTAssertEqual(parent.findDepartment(by: "parent")?.id, "parent")
        
        XCTAssertNotNil(parent.findDepartment(by: "child1"))
        XCTAssertEqual(parent.findDepartment(by: "child1")?.id, "child1")
        
        XCTAssertNotNil(parent.findDepartment(by: "grandchild"))
        XCTAssertEqual(parent.findDepartment(by: "grandchild")?.id, "grandchild")
        
        XCTAssertNil(parent.findDepartment(by: "non-existent"))
    }
    
    func testTotalEmployeeCount() {
        // Given
        let grandchild1 = Department(name: "Grandchild 1", code: "АП.1.1.1", employeeCount: 5)
        let grandchild2 = Department(name: "Grandchild 2", code: "АП.1.1.2", employeeCount: 3)
        
        var child1 = Department(name: "Child 1", code: "АП.1.1", employeeCount: 10)
        child1.children = [grandchild1, grandchild2]
        
        let child2 = Department(name: "Child 2", code: "АП.1.2", employeeCount: 7)
        
        var parent = Department(name: "Parent", code: "АП.1", employeeCount: 2)
        parent.children = [child1, child2]
        
        // When
        let totalCount = parent.totalEmployeeCount
        
        // Then
        XCTAssertEqual(totalCount, 27) // 2 + 10 + 5 + 3 + 7
    }
    
    func testTotalEmployeeCountWithoutChildren() {
        // Given
        let department = Department(name: "Test", code: "АП.1", employeeCount: 15)
        
        // When & Then
        XCTAssertEqual(department.totalEmployeeCount, 15)
    }
    
    // MARK: - Equatable Tests
    
    func testDepartmentEquality() {
        let dept1 = Department(id: "same-id", name: "Dept 1", code: "АП.1")
        let dept2 = Department(id: "same-id", name: "Dept 2", code: "АП.2")
        let dept3 = Department(id: "other-id", name: "Dept 1", code: "АП.1")
        
        XCTAssertEqual(dept1, dept2) // Same ID
        XCTAssertNotEqual(dept1, dept3) // Different ID
    }
    
    // MARK: - Mock Data Tests
    
    func testMockRootDepartment() {
        // Given
        let mockRoot = Department.mockRoot
        
        // Then
        XCTAssertEqual(mockRoot.id, "1")
        XCTAssertEqual(mockRoot.name, "ЦУМ")
        XCTAssertEqual(mockRoot.code, "АП")
        XCTAssertNotNil(mockRoot.children)
        XCTAssertEqual(mockRoot.children?.count, 3)
        
        // Check first level departments
        let departments = mockRoot.children!
        XCTAssertTrue(departments.contains { $0.name == "Департамент Развития" })
        XCTAssertTrue(departments.contains { $0.name == "IT Департамент" })
        XCTAssertTrue(departments.contains { $0.name == "HR Департамент" })
        
        // Check nested structure
        let itDept = departments.first { $0.name == "IT Департамент" }
        XCTAssertNotNil(itDept?.children)
        XCTAssertEqual(itDept?.children?.count, 2)
    }
    
    // MARK: - Codable Tests
    
    func testDepartmentCodable() throws {
        // Given
        let original = Department(
            id: "test-id",
            name: "Test Department",
            code: "АП.1",
            parentId: "parent-id",
            employeeCount: 10,
            children: [
                Department(name: "Child", code: "АП.1.1", parentId: "test-id")
            ]
        )
        
        // When
        let encoder = JSONEncoder()
        let data = try encoder.encode(original)
        
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(Department.self, from: data)
        
        // Then
        XCTAssertEqual(decoded.id, original.id)
        XCTAssertEqual(decoded.name, original.name)
        XCTAssertEqual(decoded.code, original.code)
        XCTAssertEqual(decoded.parentId, original.parentId)
        XCTAssertEqual(decoded.employeeCount, original.employeeCount)
        XCTAssertEqual(decoded.children?.count, original.children?.count)
    }
} 