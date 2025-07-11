import Foundation

// MARK: - Cmi5Endpoint

enum Cmi5Endpoint: APIEndpoint {
    case uploadPackage(data: Data, filename: String)
    case validatePackage(uploadId: String)
    case importPackage(courseId: String, uploadId: String, options: Cmi5ImportOptions)
    case getPackages(page: Int, limit: Int)
    case getPackage(id: String)
    case deletePackage(id: String)
    case getPackageActivities(packageId: String)
    case createSession(activityId: String, userId: String)
    case sendStatement(statement: XAPIStatement)
    case getStatements(activityId: String, userId: String?, limit: Int)
    case getProgress(activityId: String, userId: String)
    
    var path: String {
        switch self {
        case .uploadPackage:
            return "/cmi5/upload"
        case .validatePackage(let uploadId):
            return "/cmi5/validate/\(uploadId)"
        case .importPackage(let courseId, _, _):
            return "/cmi5/import/\(courseId)"
        case .getPackages:
            return "/cmi5/packages"
        case .getPackage(let id):
            return "/cmi5/packages/\(id)"
        case .deletePackage(let id):
            return "/cmi5/packages/\(id)"
        case .getPackageActivities(let packageId):
            return "/cmi5/packages/\(packageId)/activities"
        case .createSession:
            return "/cmi5/sessions"
        case .sendStatement:
            return "/xapi/statements"
        case .getStatements:
            return "/xapi/statements"
        case .getProgress(let activityId, let userId):
            return "/cmi5/activities/\(activityId)/users/\(userId)/progress"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .uploadPackage, .importPackage, .createSession, .sendStatement:
            return .post
        case .validatePackage:
            return .post
        case .getPackages, .getPackage, .getPackageActivities, .getStatements, .getProgress:
            return .get
        case .deletePackage:
            return .delete
        }
    }
    
    var requiresAuth: Bool {
        return true
    }
    
    var parameters: [String: Any]? {
        switch self {
        case .getPackages(let page, let limit):
            return ["page": page, "limit": limit]
        case .getStatements(_, let userId, let limit):
            var params: [String: Any] = ["limit": limit]
            if let userId = userId {
                params["agent"] = ["account": ["name": userId]]
            }
            return params
        default:
            return nil
        }
    }
    
    var body: Encodable? {
        switch self {
        case .validatePackage(let uploadId):
            return ["uploadId": uploadId]
        case .importPackage(_, let uploadId, let options):
            return Cmi5ImportRequest(uploadId: uploadId, options: options)
        case .createSession(let activityId, let userId):
            return Cmi5SessionRequest(activityId: activityId, userId: userId)
        case .sendStatement(let statement):
            return statement
        default:
            return nil
        }
    }
    
    var headers: [String: String]? {
        switch self {
        case .uploadPackage(_, let filename):
            return [
                "Content-Type": "multipart/form-data",
                "X-Filename": filename
            ]
        case .sendStatement:
            return [
                "Content-Type": "application/json",
                "X-Experience-API-Version": "1.0.3"
            ]
        case .getStatements:
            return [
                "X-Experience-API-Version": "1.0.3"
            ]
        default:
            return nil
        }
    }
}

// MARK: - Request Models

struct Cmi5ImportRequest: Encodable {
    let uploadId: String
    let options: Cmi5ImportOptions
}

struct Cmi5ImportOptions: Encodable {
    let replaceExisting: Bool
    let importActivities: Bool
    let importResources: Bool
    
    init(replaceExisting: Bool = false,
         importActivities: Bool = true,
         importResources: Bool = true) {
        self.replaceExisting = replaceExisting
        self.importActivities = importActivities
        self.importResources = importResources
    }
}

struct Cmi5SessionRequest: Encodable {
    let activityId: String
    let userId: String
    let registration: String?
    
    init(activityId: String, userId: String, registration: String? = nil) {
        self.activityId = activityId
        self.userId = userId
        self.registration = registration ?? UUID().uuidString
    }
}

// MARK: - Response Models

struct Cmi5UploadResponse: Decodable {
    let uploadId: String
    let status: String
    let message: String?
}

struct Cmi5ValidationResponse: Decodable {
    let isValid: Bool
    let errors: [String]
    let warnings: [String]
    let manifest: Cmi5ManifestSummary?
}

struct Cmi5ManifestSummary: Decodable {
    let id: String
    let title: String
    let description: String?
    let activityCount: Int
    let version: String
}

struct Cmi5SessionResponse: Decodable {
    let sessionId: String
    let launchUrl: String
    let authToken: String
    let expiresAt: Date
}

struct Cmi5ProgressResponse: Decodable {
    let activityId: String
    let userId: String
    let progress: Double
    let completed: Bool
    let passed: Bool?
    let score: XAPIScore?
    let lastAccessed: Date?
} 