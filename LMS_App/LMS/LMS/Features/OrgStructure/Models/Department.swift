import Foundation

struct Department: Identifiable, Codable, Equatable {
    let id: String
    let name: String
    let code: String
    let parentId: String?
    let employeeCount: Int
    var children: [Department]?
    
    init(id: String = UUID().uuidString,
         name: String,
         code: String,
         parentId: String? = nil,
         employeeCount: Int = 0,
         children: [Department]? = nil) {
        self.id = id
        self.name = name
        self.code = code
        self.parentId = parentId
        self.employeeCount = employeeCount
        self.children = children
    }
    
    // Computed properties
    var level: Int {
        code.components(separatedBy: ".").count
    }
    
    var hasChildren: Bool {
        children?.isEmpty == false
    }
    
    // For tree navigation
    var isExpanded: Bool = false
    
    // Recursive search
    func findDepartment(by id: String) -> Department? {
        if self.id == id {
            return self
        }
        
        return children?.compactMap { $0.findDepartment(by: id) }.first
    }
    
    // Total employee count including children
    var totalEmployeeCount: Int {
        var count = employeeCount
        children?.forEach { child in
            count += child.totalEmployeeCount
        }
        return count
    }
}

// MARK: - Mock Data
extension Department {
    static let mockRoot = Department(
        id: "1",
        name: "ЦУМ",
        code: "АП",
        employeeCount: 5,
        children: [
            Department(
                id: "2",
                name: "Департамент Развития",
                code: "АП.1",
                parentId: "1",
                employeeCount: 12,
                children: [
                    Department(
                        id: "3",
                        name: "Отдел Инноваций",
                        code: "АП.1.1",
                        parentId: "2",
                        employeeCount: 8
                    ),
                    Department(
                        id: "4",
                        name: "Отдел Стратегии",
                        code: "АП.1.2",
                        parentId: "2",
                        employeeCount: 4
                    )
                ]
            ),
            Department(
                id: "5",
                name: "IT Департамент",
                code: "АП.2",
                parentId: "1",
                employeeCount: 25,
                children: [
                    Department(
                        id: "6",
                        name: "Отдел Разработки",
                        code: "АП.2.1",
                        parentId: "5",
                        employeeCount: 15
                    ),
                    Department(
                        id: "7",
                        name: "Отдел Инфраструктуры",
                        code: "АП.2.2",
                        parentId: "5",
                        employeeCount: 10
                    )
                ]
            ),
            Department(
                id: "8",
                name: "HR Департамент",
                code: "АП.3",
                parentId: "1",
                employeeCount: 8
            )
        ]
    )
} 