import Foundation

// MARK: - APIEndpoint Protocol

/// Протокол для определения API endpoints
public protocol APIEndpoint {
    /// Путь к endpoint (без базового URL)
    var path: String { get }
    
    /// HTTP метод
    var method: HTTPMethod { get }
    
    /// Требует ли endpoint аутентификации
    var requiresAuth: Bool { get }
    
    /// Query параметры
    var parameters: [String: Any]? { get }
    
    /// HTTP body (для POST/PUT запросов)
    var body: Data? { get }
    
    /// Дополнительные headers
    var headers: [String: String]? { get }
}

// Default implementation
public extension APIEndpoint {
    var requiresAuth: Bool { true }
    var parameters: [String: Any]? { nil }
    var body: Data? { nil }
    var headers: [String: String]? { nil }
}

// MARK: - HTTPMethod

public enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
}

// MARK: - API Errors

enum APIError: LocalizedError, Equatable {
    case invalidURL
    case invalidResponse
    case noInternet
    case timeout
    case cancelled
    case unauthorized
    case forbidden
    case notFound
    case rateLimitExceeded
    case invalidCredentials
    case serverError(statusCode: Int)
    case networkError(URLError)
    case decodingError(Error)
    case custom(message: String)
    case unknown(statusCode: Int)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid server response"
        case .noInternet:
            return "No internet connection"
        case .timeout:
            return "Request timed out"
        case .cancelled:
            return "Request was cancelled"
        case .unauthorized:
            return "Authentication required"
        case .forbidden:
            return "Access denied"
        case .notFound:
            return "Resource not found"
        case .rateLimitExceeded:
            return "Too many requests. Please try again later"
        case .invalidCredentials:
            return "Invalid email or password"
        case .serverError(let code):
            return "Server error (\(code))"
        case .networkError(let error):
            return error.localizedDescription
        case .decodingError:
            return "Failed to parse server response"
        case .custom(let message):
            return message
        case .unknown(let code):
            return "Unknown error (\(code))"
        }
    }
    
    static func == (lhs: APIError, rhs: APIError) -> Bool {
        switch (lhs, rhs) {
        case (.invalidURL, .invalidURL),
             (.invalidResponse, .invalidResponse),
             (.noInternet, .noInternet),
             (.timeout, .timeout),
             (.cancelled, .cancelled),
             (.unauthorized, .unauthorized),
             (.forbidden, .forbidden),
             (.notFound, .notFound),
             (.rateLimitExceeded, .rateLimitExceeded),
             (.invalidCredentials, .invalidCredentials):
            return true
        case (.serverError(let lCode), .serverError(let rCode)):
            return lCode == rCode
        case (.networkError(let lError), .networkError(let rError)):
            return lError.code == rError.code
        case (.decodingError, .decodingError):
            return true
        case (.custom(let lMsg), .custom(let rMsg)):
            return lMsg == rMsg
        case (.unknown(let lCode), .unknown(let rCode)):
            return lCode == rCode
        default:
            return false
        }
    }
}

// MARK: - Bundle Extension

extension Bundle {
    var appVersion: String {
        let version = infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "\(version) (\(build))"
    }
} 