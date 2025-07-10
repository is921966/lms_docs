import Foundation
import Combine

// MARK: - NetworkEndpoint
// Extending APIEndpoint for NetworkService compatibility
typealias NetworkEndpoint = APIEndpoint

// MARK: - NetworkError
enum NetworkError: Error, LocalizedError {
    case invalidURL
    case noData
    case decodingError
    case decodingFailed(Error)
    case serverError(statusCode: Int)
    case unknown(statusCode: Int)
    case invalidResponse
    case unauthorized
    case forbidden
    case notFound
    case apiError(message: String, code: String?)
    case underlying(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .noData:
            return "No data received"
        case .decodingError, .decodingFailed:
            return "Failed to decode response"
        case .serverError(statusCode: let code):
            return "Server error: \(code)"
        case .unknown(statusCode: let code):
            return "Unknown error: \(code)"
        case .invalidResponse:
            return "Invalid response"
        case .unauthorized:
            return "Unauthorized"
        case .forbidden:
            return "Forbidden"
        case .notFound:
            return "Not found"
        case .apiError(let message, _):
            return message
        case .underlying(let error):
            return error.localizedDescription
        }
    }
}

// MARK: - NetworkServiceProtocol

/// Protocol defining network service capabilities
protocol NetworkServiceProtocol {
    /// Performs an asynchronous network request
    /// - Parameters:
    ///   - endpoint: The endpoint to request
    ///   - type: The type to decode the response into
    /// - Returns: Decoded response of the specified type
    func request<T: Decodable>(_ endpoint: NetworkEndpoint, as type: T.Type) async throws -> T
    
    /// Performs an asynchronous network request without expecting a response body
    /// - Parameter endpoint: The endpoint to request
    func request(_ endpoint: NetworkEndpoint) async throws
}

// MARK: - NetworkService

/// Concrete implementation of NetworkServiceProtocol
final class NetworkService: NetworkServiceProtocol {
    
    // MARK: - Properties
    
    private let session: URLSession
    private let baseURL: String
    private let decoder: JSONDecoder
    private let tokenProvider: TokenProviderProtocol?
    
    // MARK: - Initialization
    
    init(
        session: URLSession = .shared,
        baseURL: String? = nil,
        decoder: JSONDecoder = JSONDecoder(),
        tokenProvider: TokenProviderProtocol? = nil
    ) {
        self.session = session
        self.baseURL = baseURL ?? AppConfig.baseURL
        self.decoder = decoder
        self.tokenProvider = tokenProvider
        
        // Configure decoder
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601
    }
    
    // MARK: - NetworkServiceProtocol
    
    func request<T: Decodable>(_ endpoint: NetworkEndpoint, as type: T.Type) async throws -> T {
        let urlRequest = try buildURLRequest(for: endpoint)
        
        do {
            let (data, response) = try await session.data(for: urlRequest)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.invalidResponse
            }
            
            try validateResponse(httpResponse, data: data)
            
            do {
                return try decoder.decode(T.self, from: data)
            } catch {
                throw NetworkError.decodingFailed(error)
            }
        } catch let error as NetworkError {
            throw error
        } catch {
            throw NetworkError.underlying(error)
        }
    }
    
    func request(_ endpoint: NetworkEndpoint) async throws {
        let urlRequest = try buildURLRequest(for: endpoint)
        
        do {
            let (data, response) = try await session.data(for: urlRequest)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.invalidResponse
            }
            
            try validateResponse(httpResponse, data: data)
        } catch let error as NetworkError {
            throw error
        } catch {
            throw NetworkError.underlying(error)
        }
    }
    
    // MARK: - Private Methods
    
    private func buildURLRequest(for endpoint: NetworkEndpoint) throws -> URLRequest {
        guard let url = URL(string: baseURL + endpoint.path) else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.timeoutInterval = 30
        
        // Add headers
        endpoint.headers?.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        // Add default headers
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        // Add authorization if needed
        if endpoint.requiresAuth {
            if let token = tokenProvider?.accessToken {
                request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            } else {
                throw NetworkError.unauthorized
            }
        }
        
        // Add body if present
        if let body = endpoint.body {
            request.httpBody = body
        }
        
        // Add query parameters if present
        if let parameters = endpoint.parameters {
            var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
            components?.queryItems = parameters.map { URLQueryItem(name: $0.key, value: "\($0.value)") }
            request.url = components?.url
        }
        
        return request
    }
    
    private func validateResponse(_ response: HTTPURLResponse, data: Data) throws {
        switch response.statusCode {
        case 200...299:
            return
        case 401:
            throw NetworkError.unauthorized
        case 403:
            throw NetworkError.forbidden
        case 404:
            throw NetworkError.notFound
        case 500...599:
            throw NetworkError.serverError(statusCode: response.statusCode)
        default:
            // Try to decode error response
            if let errorResponse = try? decoder.decode(APIErrorResponse.self, from: data) {
                throw NetworkError.apiError(message: errorResponse.message, code: errorResponse.code)
            }
            throw NetworkError.unknown(statusCode: response.statusCode)
        }
    }
}

// MARK: - Supporting Types

/// Token provider protocol for authorization
protocol TokenProviderProtocol {
    var accessToken: String? { get }
}

/// API error response structure
struct APIErrorResponse: Decodable {
    let message: String
    let code: String?
}
