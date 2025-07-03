import Foundation

// MARK: - CompetencyEndpoint

enum CompetencyEndpoint: APIEndpoint {
    case getCompetencies(page: Int, limit: Int, filters: CompetencyFilters?)
    case getCompetency(id: String)
    case createCompetency(competency: CreateCompetencyRequest)
    case updateCompetency(id: String, competency: UpdateCompetencyRequest)
    case deleteCompetency(id: String)
    case getCategories
    case getCompetencyLevels(competencyId: String)
    case getUserCompetencies(userId: String)
    case assignCompetency(assignment: CompetencyAssignmentRequest)
    
    var path: String {
        switch self {
        case .getCompetencies:
            return "/competencies"
        case .getCompetency(let id):
            return "/competencies/\(id)"
        case .createCompetency:
            return "/competencies"
        case .updateCompetency(let id, _):
            return "/competencies/\(id)"
        case .deleteCompetency(let id):
            return "/competencies/\(id)"
        case .getCategories:
            return "/competencies/categories"
        case .getCompetencyLevels(let competencyId):
            return "/competencies/\(competencyId)/levels"
        case .getUserCompetencies(let userId):
            return "/users/\(userId)/competencies"
        case .assignCompetency:
            return "/competencies/assign"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .getCompetencies, .getCompetency, .getCategories, .getCompetencyLevels, .getUserCompetencies:
            return .get
        case .createCompetency, .assignCompetency:
            return .post
        case .updateCompetency:
            return .put
        case .deleteCompetency:
            return .delete
        }
    }
    
    var requiresAuth: Bool {
        return true
    }
    
    var parameters: [String: Any]? {
        switch self {
        case .getCompetencies(let page, let limit, let filters):
            var params: [String: Any] = ["page": page, "limit": limit]
            if let filters = filters {
                if let category = filters.category {
                    params["category"] = category
                }
                if let type = filters.type {
                    params["type"] = type
                }
                if let search = filters.search {
                    params["search"] = search
                }
            }
            return params
        default:
            return nil
        }
    }
    
    var body: Encodable? {
        switch self {
        case .createCompetency(let competency):
            return competency
        case .updateCompetency(_, let competency):
            return competency
        case .assignCompetency(let assignment):
            return assignment
        default:
            return nil
        }
    }
} 