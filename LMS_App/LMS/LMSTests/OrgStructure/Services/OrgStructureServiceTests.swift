import XCTest
import Combine
@testable import LMS

final class OrgStructureServiceTests: XCTestCase {
    
    var service: OrgStructureService!
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        service = OrgStructureService.shared
        cancellables = []
    }
    
    override func tearDown() {
        cancellables = nil
        super.tearDown()
    }
    
    // MARK: - Initialization Tests
    
    func testServiceSingleton() {
        let service1 = OrgStructureService.shared
        let service2 = OrgStructureService.shared
        
        XCTAssertTrue(service1 === service2)
    }
    
    func testServiceInitialState() {
        // Service should load mock data on init
        XCTAssertNotNil(service.rootDepartment)
        XCTAssertFalse(service.employees.isEmpty)
        XCTAssertFalse(service.isLoading)
        XCTAssertNil(service.error)
    }
    
    // MARK: - Department Tests
    
    func testGetDepartmentById() {
        // Test existing departments
        let dept1 = service.getDepartment(by: "1")
        XCTAssertNotNil(dept1)
        XCTAssertEqual(dept1?.name, "ЦУМ")
        
        let dept5 = service.getDepartment(by: "5")
        XCTAssertNotNil(dept5)
        XCTAssertEqual(dept5?.name, "IT Департамент")
        
        // Test nested department
        let dept6 = service.getDepartment(by: "6")
        XCTAssertNotNil(dept6)
        XCTAssertEqual(dept6?.name, "Отдел Разработки")
        XCTAssertEqual(dept6?.parentId, "5")
        
        // Test non-existing department
        let deptNone = service.getDepartment(by: "999")
        XCTAssertNil(deptNone)
    }
    
    func testGetDepartmentPath() {
        // Test root department path
        let rootPath = service.getDepartmentPath(for: "1")
        XCTAssertEqual(rootPath.count, 1)
        XCTAssertEqual(rootPath.first?.id, "1")
        
        // Test nested department path
        let nestedPath = service.getDepartmentPath(for: "6")
        XCTAssertEqual(nestedPath.count, 3)
        XCTAssertEqual(nestedPath[0].id, "1") // ЦУМ
        XCTAssertEqual(nestedPath[1].id, "5") // IT Департамент
        XCTAssertEqual(nestedPath[2].id, "6") // Отдел Разработки
        
        // Test non-existing department
        let emptyPath = service.getDepartmentPath(for: "999")
        XCTAssertTrue(emptyPath.isEmpty)
    }
    
    // MARK: - Employee Tests
    
    func testGetEmployeesForDepartment() {
        // Test department with employees
        let dept1Employees = service.getEmployees(for: "1")
        XCTAssertEqual(dept1Employees.count, 2)
        
        let dept6Employees = service.getEmployees(for: "6")
        XCTAssertEqual(dept6Employees.count, 3)
        
        // Test department without employees
        let emptyEmployees = service.getEmployees(for: "999")
        XCTAssertTrue(emptyEmployees.isEmpty)
    }
    
    func testGetAllEmployees() {
        let allEmployees = service.getAllEmployees()
        
        // Should return all employees from all departments
        let expectedCount = service.employees.values.reduce(0) { $0 + $1.count }
        XCTAssertEqual(allEmployees.count, expectedCount)
        
        // Check that we have employees from different departments
        let departmentIds = Set(allEmployees.map { $0.departmentId })
        XCTAssertTrue(departmentIds.count > 1)
    }
    
    func testSearchEmployees() {
        // Search by name
        let ivanovResults = service.searchEmployees(query: "Иванов")
        XCTAssertEqual(ivanovResults.count, 1)
        XCTAssertEqual(ivanovResults.first?.name, "Иванов Иван Иванович")
        
        // Search by partial name (case insensitive)
        let mariaResults = service.searchEmployees(query: "мария")
        XCTAssertEqual(mariaResults.count, 1)
        XCTAssertEqual(mariaResults.first?.name, "Петрова Мария Сергеевна")
        
        // Search by tab number
        let tabResults = service.searchEmployees(query: "АР21000620")
        XCTAssertEqual(tabResults.count, 1)
        XCTAssertEqual(tabResults.first?.name, "Козлов Дмитрий Андреевич")
        
        // Search by position
        let devResults = service.searchEmployees(query: "разработчик")
        XCTAssertTrue(devResults.count >= 2)
        
        // Empty search
        let emptyResults = service.searchEmployees(query: "")
        XCTAssertEqual(emptyResults.count, service.getAllEmployees().count)
        
        // No results
        let noResults = service.searchEmployees(query: "xyz123")
        XCTAssertTrue(noResults.isEmpty)
    }
    
    // MARK: - Employee Count Tests
    
    func testGetEmployeeCount() {
        // Department with employees
        XCTAssertEqual(service.getEmployeeCount(for: "1"), 2)
        XCTAssertEqual(service.getEmployeeCount(for: "6"), 3)
        
        // Department without employees
        XCTAssertEqual(service.getEmployeeCount(for: "999"), 0)
    }
    
    func testGetTotalEmployeeCount() {
        // Root department should count all employees
        if let root = service.rootDepartment {
            let totalCount = service.getTotalEmployeeCount(for: root)
            let allEmployeesCount = service.getAllEmployees().count
            XCTAssertEqual(totalCount, allEmployeesCount)
        }
        
        // Department with children
        if let itDept = service.getDepartment(by: "5") {
            let itTotalCount = service.getTotalEmployeeCount(for: itDept)
            // IT Dept (1) + Отдел Разработки (3) + Отдел Инфраструктуры (0)
            XCTAssertEqual(itTotalCount, 4)
        }
        
        // Leaf department
        if let hrDept = service.getDepartment(by: "8") {
            let hrCount = service.getTotalEmployeeCount(for: hrDept)
            XCTAssertEqual(hrCount, 2)
        }
    }
    
    // MARK: - Loading Tests
    
    func testLoadOrganizationStructure() {
        let expectation = expectation(description: "Loading completes")
        
        // Subscribe to isLoading changes
        var loadingStates: [Bool] = []
        service.$isLoading
            .sink { isLoading in
                loadingStates.append(isLoading)
                if loadingStates.count >= 2 && !isLoading {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        // Trigger loading
        service.loadOrganizationStructure()
        
        waitForExpectations(timeout: 2) { _ in
            // Should transition from false -> true -> false
            XCTAssertTrue(loadingStates.contains(true))
            XCTAssertEqual(loadingStates.last, false)
            
            // Data should be loaded
            XCTAssertNotNil(self.service.rootDepartment)
            XCTAssertFalse(self.service.employees.isEmpty)
        }
    }
    
    // MARK: - Import Tests
    
    func testImportFromExcel() async throws {
        // Create temporary file
        let tempURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("test.xlsx")
        let data = Data("test".utf8)
        try data.write(to: tempURL)
        
        defer {
            try? FileManager.default.removeItem(at: tempURL)
        }
        
        // Test merge mode
        try await service.importFromExcel(fileURL: tempURL, mode: .merge)
        
        // Should still have data after import (mock implementation)
        XCTAssertNotNil(service.rootDepartment)
        XCTAssertFalse(service.employees.isEmpty)
        
        // Test replace mode
        try await service.importFromExcel(fileURL: tempURL, mode: .replace)
        
        // Should still have data after import (mock implementation)
        XCTAssertNotNil(service.rootDepartment)
        XCTAssertFalse(service.employees.isEmpty)
    }
    
    // MARK: - Mock Data Tests
    
    func testMockDataConsistency() {
        // All employees should belong to existing departments
        let allEmployees = service.getAllEmployees()
        
        for employee in allEmployees {
            let department = service.getDepartment(by: employee.departmentId)
            XCTAssertNotNil(department,
                           "Employee \(employee.name) belongs to non-existent department \(employee.departmentId)")
        }
        
        // All parent IDs should reference existing departments
        func checkDepartmentHierarchy(_ dept: Department) {
            if let parentId = dept.parentId {
                let parent = service.getDepartment(by: parentId)
                XCTAssertNotNil(parent,
                               "Department \(dept.name) has non-existent parent \(parentId)")
            }
            
            dept.children?.forEach { checkDepartmentHierarchy($0) }
        }
        
        if let root = service.rootDepartment {
            checkDepartmentHierarchy(root)
        }
    }
} 