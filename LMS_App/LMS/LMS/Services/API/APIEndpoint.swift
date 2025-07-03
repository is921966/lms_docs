import Foundation

// MARK: - APIEndpoint Protocol

/// Протокол для определения API endpoints
protocol APIEndpoint {
    /// Путь к endpoint (без базового URL)
    var path: String { get }
    
    /// HTTP метод
    var method: HTTPMethod { get }
    
    /// Требует ли endpoint аутентификации
    var requiresAuth: Bool { get }
    
    /// Query параметры
    var parameters: [String: Any]? { get }
    
    /// HTTP body (для POST/PUT запросов)
    var body: Encodable? { get }
    
    /// Дополнительные headers
    var headers: [String: String]? { get }
}

// Default implementation
extension APIEndpoint {
    var requiresAuth: Bool { true }
    var parameters: [String: Any]? { nil }
    var body: Encodable? { nil }
    var headers: [String: String]? { nil }
}

// MARK: - HTTPMethod

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
}

// MARK: - API Errors

enum APIError: LocalizedError {
    case invalidURL
    case invalidResponse
    case noInternet
    case timeout
    case cancelled
    case unauthorized
    case forbidden
    case notFound
    case rateLimitExceeded
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
}

// MARK: - Bundle Extension

extension Bundle {
    var appVersion: String {
        let version = infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "\(version) (\(build))"
    }
} 