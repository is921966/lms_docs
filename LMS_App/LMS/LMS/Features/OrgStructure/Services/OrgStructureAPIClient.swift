import Foundation
import Combine

protocol OrgStructureAPIClientProtocol {
    func fetchOrganizationStructure() async throws -> Department
    func importFromExcel(fileData: Data, mode: ImportMode) async throws -> ImportResult
    func searchEmployees(query: String) async throws -> [OrgEmployee]
}

class OrgStructureAPIClient: OrgStructureAPIClientProtocol {
    
    private let apiClient: APIClient
    
    init(apiClient: APIClient = APIClient.shared) {
        self.apiClient = apiClient
    }
    
    // MARK: - API Methods
    
    func fetchOrganizationStructure() async throws -> Department {
        let endpoint = OrgStructureEndpoint.getStructure
        let response: DepartmentResponse = try await apiClient.request(endpoint)
        return response.toDomain()
    }
    
    func importFromExcel(fileData: Data, mode: ImportMode) async throws -> ImportResult {
        let endpoint = OrgStructureEndpoint.importExcel(fileData: fileData, mode: mode)
        let response: ImportResponse = try await apiClient.request(endpoint)
        
        return ImportResult(
            departmentsAdded: response.imported?.departments ?? 0,
            departmentsUpdated: 0,
            employeesAdded: response.imported?.employees ?? 0,
            employeesUpdated: 0,
            errors: response.success ? [] : [response.message]
        )
    }
    
    func searchEmployees(query: String) async throws -> [OrgEmployee] {
        let endpoint = OrgStructureEndpoint.searchEmployees(query: query)
        let response: EmployeeSearchResponse = try await apiClient.request(endpoint)
        return response.employees.map { $0.toDomain() }
    }
}

// MARK: - Endpoints

enum OrgStructureEndpoint: APIEndpoint {
    case getStructure
    case importExcel(fileData: Data, mode: ImportMode)
    case searchEmployees(query: String)
    
    var path: String {
        switch self {
        case .getStructure:
            return "/api/organization/structure"
        case .importExcel:
            return "/api/organization/import"
        case .searchEmployees:
            return "/api/organization/employees/search"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .getStructure, .searchEmployees:
            return .get
        case .importExcel:
            return .post
        }
    }
    
    var body: Data? {
        switch self {
        case .importExcel(let fileData, let mode):
            // For multipart form data, we need to construct proper body
            // This is simplified version - real implementation would use multipart
            let dict: [String: Any] = [
                "mode": mode == .merge ? "merge" : "replace",
                "file": fileData.base64EncodedString()
            ]
            return try? JSONSerialization.data(withJSONObject: dict)
        default:
            return nil
        }
    }
    
    var queryItems: [URLQueryItem]? {
        switch self {
        case .searchEmployees(let query):
            return [URLQueryItem(name: "q", value: query)]
        default:
            return nil
        }
    }
    
    var requiresAuth: Bool {
        return true
    }
    
    var headers: [String: String]? {
        switch self {
        case .importExcel:
            return ["Content-Type": "application/json"]
        default:
            return nil
        }
    }
}

// MARK: - Response DTOs

struct DepartmentResponse: Codable {
    let id: String
    let name: String
    let code: String
    let parentId: String?
    let employeeCount: Int
    let children: [DepartmentResponse]?
    
    func toDomain() -> Department {
        Department(
            id: id,
            name: name,
            code: code,
            parentId: parentId,
            employeeCount: employeeCount,
            children: children?.map { $0.toDomain() }
        )
    }
}

struct EmployeeResponse: Codable {
    let id: String
    let tabNumber: String
    let name: String
    let position: String
    let departmentId: String
    let email: String?
    let phone: String?
    let photoUrl: String?
    
    func toDomain() -> OrgEmployee {
        OrgEmployee(
            id: id,
            tabNumber: tabNumber,
            name: name,
            position: position,
            departmentId: departmentId,
            email: email,
            phone: phone,
            photoUrl: photoUrl
        )
    }
}

struct EmployeeSearchResponse: Codable {
    let employees: [EmployeeResponse]
    let total: Int
}

struct ImportResponse: Codable {
    let success: Bool
    let message: String
    let imported: ImportStats?
}

struct ImportStats: Codable {
    let departments: Int
    let employees: Int
}

// MARK: - Mock Implementation

class MockOrgStructureAPIClient: OrgStructureAPIClientProtocol {
    
    var shouldFail = false
    var delay: TimeInterval = 1.0
    
    func fetchOrganizationStructure() async throws -> Department {
        if shouldFail {
            throw APIError.networkError(URLError(.notConnectedToInternet))
        }
        
        try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
        return Department.mockRoot
    }
    
    func importFromExcel(fileData: Data, mode: ImportMode) async throws -> ImportResult {
        if shouldFail {
            throw APIError.serverError(statusCode: 500)
        }
        
        try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
        
        return ImportResult(
            departmentsAdded: 10,
            departmentsUpdated: 5,
            employeesAdded: 25,
            employeesUpdated: 10,
            errors: []
        )
    }
    
    func searchEmployees(query: String) async throws -> [OrgEmployee] {
        if shouldFail {
            throw APIError.networkError(URLError(.timedOut))
        }
        
        try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
        
        let allEmployees = OrgEmployee.allMockEmployees
        let filtered = allEmployees.filter { employee in
            employee.name.localizedCaseInsensitiveContains(query) ||
            employee.tabNumber.localizedCaseInsensitiveContains(query) ||
            employee.position.localizedCaseInsensitiveContains(query)
        }
        
        return filtered
    }
} 