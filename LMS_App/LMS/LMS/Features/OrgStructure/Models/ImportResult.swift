import Foundation

// MARK: - Import Result
public struct ImportResult {
    let departmentsAdded: Int
    let departmentsUpdated: Int
    let employeesAdded: Int
    let employeesUpdated: Int
    let errors: [String]
    
    var totalDepartments: Int {
        departmentsAdded + departmentsUpdated
    }
    
    var totalEmployees: Int {
        employeesAdded + employeesUpdated
    }
    
    var isSuccess: Bool {
        errors.isEmpty
    }
    
    var summary: String {
        var parts: [String] = []
        
        if departmentsAdded > 0 {
            parts.append("\(departmentsAdded) подразделений добавлено")
        }
        if departmentsUpdated > 0 {
            parts.append("\(departmentsUpdated) подразделений обновлено")
        }
        if employeesAdded > 0 {
            parts.append("\(employeesAdded) сотрудников добавлено")
        }
        if employeesUpdated > 0 {
            parts.append("\(employeesUpdated) сотрудников обновлено")
        }
        
        if parts.isEmpty {
            return "Нет изменений"
        }
        
        return parts.joined(separator: ", ")
    }
}

// MARK: - Import Mode
public enum ImportMode: String, CaseIterable {
    case merge = "merge"
    case replace = "replace"
    
    var description: String {
        switch self {
        case .merge:
            return "Объединить с существующими"
        case .replace:
            return "Заменить все данные"
        }
    }
} 