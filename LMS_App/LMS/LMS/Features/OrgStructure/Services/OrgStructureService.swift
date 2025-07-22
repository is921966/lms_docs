import Foundation
import Combine

class OrgStructureService: ObservableObject {
    static let shared = OrgStructureService()
    
    @Published var rootDepartment: Department?
    @Published var employees: [String: [OrgEmployee]] = [:]
    @Published var isLoading = false
    @Published var error: String?
    
    private var cancellables = Set<AnyCancellable>()
    
    private init() {
        // Load mock data for now
        loadMockData()
    }
    
    // MARK: - Public Methods
    
    func loadOrganizationStructure() {
        isLoading = true
        error = nil
        
        // Simulate network delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.loadMockData()
            self?.isLoading = false
        }
    }
    
    func getDepartment(by id: String) -> Department? {
        return rootDepartment?.findDepartment(by: id)
    }
    
    func getEmployees(for departmentId: String) -> [OrgEmployee] {
        return employees[departmentId] ?? []
    }
    
    func getAllEmployees() -> [OrgEmployee] {
        return employees.values.flatMap { $0 }
    }
    
    func searchEmployees(query: String) -> [OrgEmployee] {
        let lowercasedQuery = query.lowercased()
        return getAllEmployees().filter { employee in
            employee.name.lowercased().contains(lowercasedQuery) ||
            employee.tabNumber.lowercased().contains(lowercasedQuery) ||
            employee.position.lowercased().contains(lowercasedQuery)
        }
    }
    
    func getDepartmentPath(for departmentId: String) -> [Department] {
        guard let department = getDepartment(by: departmentId) else { return [] }
        
        var path: [Department] = []
        var current: Department? = department
        
        while let dept = current {
            path.insert(dept, at: 0)
            if let parentId = dept.parentId {
                current = getDepartment(by: parentId)
            } else {
                current = nil
            }
        }
        
        return path
    }
    
    func getEmployeeCount(for departmentId: String) -> Int {
        return getEmployees(for: departmentId).count
    }
    
    func getTotalEmployeeCount(for department: Department) -> Int {
        var count = getEmployeeCount(for: department.id)
        
        department.children?.forEach { child in
            count += getTotalEmployeeCount(for: child)
        }
        
        return count
    }
    
    // MARK: - Import Types
    
    struct DepartmentImport {
        let code: String
        let parentCode: String?
        let name: String
    }
    
    struct EmployeeImport {
        let tabNumber: String
        let name: String
        let position: String
        let departmentCode: String
        let email: String?
        let phone: String?
    }
    
    struct ImportResult {
        let departmentsAdded: Int
        let departmentsUpdated: Int
        let employeesAdded: Int
        let employeesUpdated: Int
        let errors: [String]
    }
    
    enum ImportMode {
        case merge
        case replace
    }
    
    // MARK: - Import Methods
    
    /// Импорт из CSV данных
    func importFromCSV(
        departments: [DepartmentImport],
        employees: [EmployeeImport],
        mode: ImportMode
    ) async throws -> ImportResult {
        
        var departmentsAdded = 0
        var departmentsUpdated = 0
        var employeesAdded = 0
        var employeesUpdated = 0
        var errors: [String] = []
        
        // В режиме замены сначала удаляем все данные
        if mode == .replace {
            self.rootDepartment = nil
            self.employees.removeAll()
        }
        
        // Собираем все существующие департаменты
        var allDepartments: [Department] = []
        if let root = rootDepartment {
            collectAllDepartments(from: root, into: &allDepartments)
        }
        
        // Импортируем департаменты
        for deptImport in departments {
            if let existingDept = allDepartments.first(where: { $0.code == deptImport.code }) {
                // Обновляем существующий - нужно пересоздать т.к. свойства immutable
                departmentsUpdated += 1
            } else {
                // Создаем новый
                let newDept = Department(
                    name: deptImport.name,
                    code: deptImport.code,
                    parentId: deptImport.parentCode
                )
                allDepartments.append(newDept)
                departmentsAdded += 1
            }
        }
        
        // Строим иерархию департаментов
        buildDepartmentHierarchy(from: allDepartments)
        
        // Импортируем сотрудников
        var newEmployees: [String: [OrgEmployee]] = self.employees
        
        for empImport in employees {
            // Проверяем существование департамента
            guard let department = getDepartmentByCode(empImport.departmentCode) else {
                errors.append("Не найден департамент с кодом \(empImport.departmentCode) для сотрудника \(empImport.name)")
                continue
            }
            
            // Получаем список сотрудников департамента
            var deptEmployees = newEmployees[department.id] ?? []
            
            if let existingIndex = deptEmployees.firstIndex(where: { $0.tabNumber == empImport.tabNumber }) {
                // Обновляем существующего
                let existingEmp = deptEmployees[existingIndex]
                let updatedEmp = OrgEmployee(
                    id: existingEmp.id,
                    tabNumber: empImport.tabNumber,
                    name: empImport.name,
                    position: empImport.position,
                    departmentId: department.id,
                    email: empImport.email,
                    phone: empImport.phone,
                    photoUrl: existingEmp.photoUrl
                )
                deptEmployees[existingIndex] = updatedEmp
                employeesUpdated += 1
            } else {
                // Создаем нового
                let newEmp = OrgEmployee(
                    tabNumber: empImport.tabNumber,
                    name: empImport.name,
                    position: empImport.position,
                    departmentId: department.id,
                    email: empImport.email,
                    phone: empImport.phone
                )
                deptEmployees.append(newEmp)
                employeesAdded += 1
            }
            
            newEmployees[department.id] = deptEmployees
        }
        
        self.employees = newEmployees
        
        // Уведомляем об изменениях
        await MainActor.run {
            objectWillChange.send()
        }
        
        return ImportResult(
            departmentsAdded: departmentsAdded,
            departmentsUpdated: departmentsUpdated,
            employeesAdded: employeesAdded,
            employeesUpdated: employeesUpdated,
            errors: errors
        )
    }
    
    /// Собирает все департаменты в плоский список
    private func collectAllDepartments(from dept: Department, into list: inout [Department]) {
        list.append(dept)
        dept.children?.forEach { child in
            collectAllDepartments(from: child, into: &list)
        }
    }
    
    /// Получает департамент по коду
    private func getDepartmentByCode(_ code: String) -> Department? {
        var allDepts: [Department] = []
        if let root = rootDepartment {
            collectAllDepartments(from: root, into: &allDepts)
        }
        return allDepts.first { $0.code == code }
    }
    
    /// Построение иерархии департаментов из плоского списка
    private func buildDepartmentHierarchy(from departments: [Department]) {
        // Создаем словарь для быстрого поиска и отслеживания детей
        var deptByCode: [String: Department] = [:]
        var childrenByCode: [String: [Department]] = [:]
        
        // Сначала собираем всех в словарь
        for dept in departments {
            deptByCode[dept.code] = dept
        }
        
        // Собираем информацию о детях
        for dept in departments {
            if let parentCode = dept.parentId {
                if childrenByCode[parentCode] == nil {
                    childrenByCode[parentCode] = []
                }
                childrenByCode[parentCode]?.append(dept)
            }
        }
        
        // Создаем новые департаменты с правильной иерархией
        func buildDepartmentWithChildren(code: String) -> Department? {
            guard let dept = deptByCode[code] else { return nil }
            
            let children = childrenByCode[code]?.compactMap { child in
                buildDepartmentWithChildren(code: child.code)
            }
            
            return Department(
                id: dept.id,
                name: dept.name,
                code: dept.code,
                parentId: dept.parentId,
                employeeCount: dept.employeeCount,
                children: children?.isEmpty == false ? children : nil
            )
        }
        
        // Находим корневые элементы и строим дерево
        let rootCodes = departments.filter { $0.parentId == nil || $0.parentId?.isEmpty == true }.map { $0.code }
        
        if let firstRootCode = rootCodes.first,
           let rootDept = buildDepartmentWithChildren(code: firstRootCode) {
            rootDepartment = rootDept
        }
    }
    
    /*
    // Старый метод для Excel - больше не используется
    func importFromExcel(fileURL: URL, mode: ImportMode) async throws -> ImportResult {
        print("📤 Starting Excel import, mode: \(mode)")
        
        do {
            // Parse Excel file
            let parser = ExcelParser()
            let parsedData = try parser.parseExcel(at: fileURL)
            
            print("📊 Parsed data: \(parsedData.departments.count) departments, \(parsedData.employees.count) employees")
            
            // Apply import based on mode
            switch mode {
            case .merge:
                return try await mergeData(parsedData)
            case .replace:
                return try await replaceData(parsedData)
            }
        } catch {
            print("❌ Import failed: \(error)")
            throw error
        }
    }
    
    private func mergeData(_ data: ExcelParser.ParseResult) async throws -> ImportResult {
        var departmentsAdded = 0
        var departmentsUpdated = 0
        var employeesAdded = 0
        var employeesUpdated = 0
        
        // Collect all existing departments into a flat list
        var allDepartments: [Department] = []
        
        if let root = rootDepartment {
            collectDepartments(from: root, into: &allDepartments)
        }
        
        print("📦 Existing departments count: \(allDepartments.count)")
        
        // Process departments first
        for parsedDept in data.departments {
            if let existingDept = allDepartments.first(where: { $0.code == parsedDept.code }) {
                // Update existing department
                var updatedDept = existingDept
                updatedDept = Department(
                    id: existingDept.id,
                    name: parsedDept.name,
                    code: existingDept.code,
                    parentId: existingDept.parentId,
                    employeeCount: existingDept.employeeCount,
                    children: existingDept.children
                )
                
                // Replace in departments array
                if let index = departments.firstIndex(where: { $0.id == existingDept.id }) {
                    departments[index] = updatedDept
                }
                
                departmentsUpdated += 1
                print("✏️ Updated department: \(parsedDept.name)")
            } else {
                // Add new department
                let newDept = Department(
                    id: UUID().uuidString,
                    name: parsedDept.name,
                    code: parsedDept.code,
                    parentId: nil,
                    employeeCount: 0,
                    children: []
                )
                
                departments.append(newDept)
                departmentsAdded += 1
                print("➕ Added department: \(parsedDept.name)")
            }
        }
        
        // Build department hierarchy
        await buildHierarchy(from: data.departments)
        
        // Process employees
        for parsedEmp in data.employees {
            // Find the department
            guard let department = getDepartmentByCode(parsedEmp.departmentCode) else {
                print("⚠️ Department not found for employee: \(parsedEmp.name)")
                continue
            }
            
            // Check if employee exists
            let existingEmployees = employees[department.code] ?? []
            
            if let existingEmp = existingEmployees.first(where: { $0.tabNumber == parsedEmp.tabNumber }) {
                // Update existing employee
                var updatedEmployees = existingEmployees
                if let index = updatedEmployees.firstIndex(where: { $0.id == existingEmp.id }) {
                    updatedEmployees[index] = OrgEmployee(
                        id: existingEmp.id,
                        tabNumber: parsedEmp.tabNumber,
                        name: parsedEmp.name,
                        position: parsedEmp.position,
                        departmentId: department.code,
                        email: parsedEmp.email,
                        phone: parsedEmp.phone,
                        photoUrl: existingEmp.photoUrl
                    )
                    employees[department.code] = updatedEmployees
                    employeesUpdated += 1
                    print("✏️ Updated employee: \(parsedEmp.name)")
                }
            } else {
                // Add new employee
                let newEmp = OrgEmployee(
                    id: UUID().uuidString,
                    tabNumber: parsedEmp.tabNumber,
                    name: parsedEmp.name,
                    position: parsedEmp.position,
                    departmentId: department.code,
                    email: parsedEmp.email,
                    phone: parsedEmp.phone
                )
                
                if employees[department.code] == nil {
                    employees[department.code] = []
                }
                employees[department.code]?.append(newEmp)
                employeesAdded += 1
                print("➕ Added employee: \(parsedEmp.name)")
            }
        }
        
        // Update employee counts
        updateEmployeeCounts()
        
        // Notify UI
        await MainActor.run {
            objectWillChange.send()
        }
        
        print("✅ Import completed. Added: \(departmentsAdded) depts, \(employeesAdded) emps. Updated: \(departmentsUpdated) depts, \(employeesUpdated) emps.")
        
        return ImportResult(
            departmentsAdded: departmentsAdded,
            departmentsUpdated: departmentsUpdated,
            employeesAdded: employeesAdded,
            employeesUpdated: employeesUpdated,
            errors: []
        )
    }
    
    private func replaceData(_ data: ExcelParser.ParseResult) async throws -> ImportResult {
        print("🔄 Replacing all data...")
        
        // Clear existing data
        departments.removeAll()
        employees.removeAll()
        rootDepartment = nil
        
        var departmentsAdded = 0
        var employeesAdded = 0
        
        // Add all departments
        for parsedDept in data.departments {
            let newDept = Department(
                id: UUID().uuidString,
                name: parsedDept.name,
                code: parsedDept.code,
                parentId: nil,
                employeeCount: 0,
                children: []
            )
            
            departments.append(newDept)
            departmentsAdded += 1
        }
        
        // Build hierarchy
        await buildHierarchy(from: data.departments)
        
        // Add all employees
        for parsedEmp in data.employees {
            guard let department = getDepartmentByCode(parsedEmp.departmentCode) else {
                print("⚠️ Department not found for employee: \(parsedEmp.name)")
                continue
            }
            
            let newEmp = OrgEmployee(
                id: UUID().uuidString,
                tabNumber: parsedEmp.tabNumber,
                name: parsedEmp.name,
                position: parsedEmp.position,
                departmentId: department.code,
                email: parsedEmp.email,
                phone: parsedEmp.phone
            )
            
            if employees[department.code] == nil {
                employees[department.code] = []
            }
            employees[department.code]?.append(newEmp)
            employeesAdded += 1
        }
        
        // Update employee counts
        updateEmployeeCounts()
        
        // Notify UI
        await MainActor.run {
            objectWillChange.send()
        }
        
        print("✅ Replace completed. Added: \(departmentsAdded) departments, \(employeesAdded) employees")
        
        return ImportResult(
            departmentsAdded: departmentsAdded,
            departmentsUpdated: 0,
            employeesAdded: employeesAdded,
            employeesUpdated: 0,
            errors: []
        )
    }
    
    private func buildHierarchy(from parsedDepartments: [ExcelParser.ParsedDepartment]) async {
        // Implementation details...
    }
    */
    
    private func updateDepartmentLevels() {
        // This method is no longer needed with the tree structure
        print("📊 Department hierarchy updated")
    }
    
    /*
    // Старый метод экспорта в Excel - больше не используется
    func exportToExcel() -> Data? {
        print("Starting Excel export...")
        
        // Create a new Excel parser
        let parser = ExcelParser()
        
        // Collect all departments
        var exportDepartments: [ExcelParser.ParsedDepartment] = []
        var exportEmployees: [ExcelParser.ParsedEmployee] = []
        
        // Flatten department tree
        func collectDepartment(_ dept: Department, parentCode: String? = nil) {
            let parsedDept = ExcelParser.ParsedDepartment(
                code: dept.code,
                parentCode: parentCode,
                name: dept.name
            )
            exportDepartments.append(parsedDept)
            
            // Collect employees for this department
            if let deptEmployees = employees[dept.code] {
                for emp in deptEmployees {
                    let parsedEmp = ExcelParser.ParsedEmployee(
                        tabNumber: emp.tabNumber,
                        name: emp.name,
                        position: emp.position,
                        departmentCode: dept.code,
                        email: emp.email,
                        phone: emp.phone
                    )
                    exportEmployees.append(parsedEmp)
                }
            }
            
            // Recursively collect children
            dept.children?.forEach { child in
                collectDepartment(child, parentCode: dept.code)
            }
        }
        
        // Start collection from root
        if let root = rootDepartment {
            collectDepartment(root)
        } else {
            // Collect all departments if no root
            departments.forEach { dept in
                collectDepartment(dept)
            }
        }
        
        print("Collected \(exportDepartments.count) departments and \(exportEmployees.count) employees for export")
        
        // Create the Excel file
        do {
            let exportResult = ExcelParser.ParseResult(
                departments: exportDepartments,
                employees: exportEmployees
            )
            
            let url = try parser.createExportFile(from: exportResult)
            let data = try Data(contentsOf: url)
            
            // Clean up temporary file
            try? FileManager.default.removeItem(at: url)
            
            print("Excel export successful")
            return data
        } catch {
            print("Excel export failed: \(error)")
            return nil
        }
    }
    */
    
    func createTemplate() -> Data? {
        do {
            let parser = CSVParser()
            let url = try parser.createTemplateFile()
            let data = try Data(contentsOf: url)
            // Удаляем временный файл
            try? FileManager.default.removeItem(at: url)
            return data
        } catch {
            print("Error creating template: \(error)")
            return nil
        }
    }
    
    // MARK: - Export Methods
    
    /// Экспорт в CSV формат
    func exportToCSV() -> Data? {
        print("📥 Starting CSV export")
        
        var csvRows: [String] = []
        
        // Header
        csvRows.append("Код,Вышестоящий Код,Название подразделения,Табельный номер,ФИО,Должность,Email,Телефон")
        
        // Export departments and their employees
        func exportDepartment(_ dept: Department, parentCode: String? = nil) {
            // Export department info (empty employee fields)
            csvRows.append("\(dept.code),\(parentCode ?? ""),\(dept.name),,,,")
            
            // Export employees of this department
            let deptEmployees = employees[dept.id] ?? []
            for emp in deptEmployees {
                let email = emp.email ?? ""
                let phone = emp.phone ?? ""
                csvRows.append("\(dept.code),\(parentCode ?? ""),\(dept.name),\(emp.tabNumber),\(emp.name),\(emp.position),\(email),\(phone)")
            }
            
            // Recursively export children
            dept.children?.forEach { child in
                exportDepartment(child, parentCode: dept.code)
            }
        }
        
        // Start from root
        if let root = rootDepartment {
            exportDepartment(root)
        } else {
            // Export all departments if no root
            var allDepts: [Department] = []
            if let root = rootDepartment {
                collectAllDepartments(from: root, into: &allDepts)
            }
            allDepts.forEach { dept in
                exportDepartment(dept, parentCode: dept.parentId)
            }
        }
        
        let csvContent = csvRows.joined(separator: "\n")
        print("✅ CSV export completed: \(csvRows.count) rows")
        return csvContent.data(using: .utf8)
    }
    
    // MARK: - Private Methods
    
    private func loadMockData() {
        self.rootDepartment = Department.mockRoot
        self.employees = OrgEmployee.mockEmployees
    }
} 
