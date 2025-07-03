import Foundation
import Combine

// MARK: - APIClient

/// Основной клиент для работы с API Gateway
final class APIClient {
    
    // MARK: - Properties
    
    static let shared = APIClient()
    
    private let baseURL: String
    private let session: URLSession
    private var authToken: String?
    private let tokenManager: TokenManager
    private let networkMonitor = NetworkMonitor.shared
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()
    
    // MARK: - Initialization
    
    init(baseURL: String = APIConfig.baseURL,
         session: URLSession = .shared,
         tokenManager: TokenManager = .shared) {
        self.baseURL = baseURL
        self.session = session
        self.tokenManager = tokenManager
        
        // Configure decoder
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601
        
        // Configure encoder
        encoder.keyEncodingStrategy = .convertToSnakeCase
        encoder.dateEncodingStrategy = .iso8601
        
        // Load saved token
        self.authToken = tokenManager.getAccessToken()
    }
    
    // MARK: - Public Methods
    
    /// Выполняет запрос к API
    func request<T: Decodable>(_ endpoint: APIEndpoint) async throws -> T {
        // Check network connectivity
        try networkMonitor.checkConnectivity()
        
        let request = try buildRequest(for: endpoint)
        
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }
            
            // Check for token expiration
            if httpResponse.statusCode == 401 && endpoint.requiresAuth {
                try await refreshTokenAndRetry(endpoint)
            }
            
            // Handle response
            try handleResponse(httpResponse, data: data)
            
            // Decode response
            return try decoder.decode(T.self, from: data)
            
        } catch {
            throw mapError(error)
        }
    }
    
    /// Выполняет запрос без ожидания ответа
    func requestVoid(_ endpoint: APIEndpoint) async throws {
        // Check network connectivity
        try networkMonitor.checkConnectivity()
        
        let request = try buildRequest(for: endpoint)
        
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }
            
            try handleResponse(httpResponse, data: data)
            
        } catch {
            throw mapError(error)
        }
    }
    
    /// Загружает данные (файлы, изображения)
    func download(_ endpoint: APIEndpoint) async throws -> Data {
        // Check network connectivity
        try networkMonitor.checkConnectivity()
        
        let request = try buildRequest(for: endpoint)
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        try handleResponse(httpResponse, data: data)
        
        return data
    }
    
    /// Загружает файл на сервер
    func upload<T: Decodable>(_ endpoint: APIEndpoint, data: Data, mimeType: String) async throws -> T {
        // Check network connectivity
        try networkMonitor.checkConnectivity()
        
        var request = try buildRequest(for: endpoint)
        
        // Create multipart form data
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        let body = createMultipartBody(data: data, mimeType: mimeType, boundary: boundary)
        request.httpBody = body
        
        let (responseData, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        try handleResponse(httpResponse, data: responseData)
        
        return try decoder.decode(T.self, from: responseData)
    }
    
    // MARK: - Private Methods
    
    private func buildRequest(for endpoint: APIEndpoint) throws -> URLRequest {
        guard let url = URL(string: baseURL + endpoint.path) else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.timeoutInterval = 30
        
        // Add headers
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("iOS/\(Bundle.main.appVersion)", forHTTPHeaderField: "User-Agent")
        
        // Add auth token if required
        if endpoint.requiresAuth {
            if let token = tokenManager.getAccessToken() {
                request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            } else {
                throw APIError.unauthorized
            }
        }
        
        // Add custom headers
        endpoint.headers?.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        // Add body if needed
        if let body = endpoint.body {
            request.httpBody = try encoder.encode(body)
        }
        
        // Add query parameters
        if let parameters = endpoint.parameters {
            var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
            components?.queryItems = parameters.map { URLQueryItem(name: $0.key, value: "\($0.value)") }
            request.url = components?.url
        }
        
        return request
    }
    
    private func handleResponse(_ response: HTTPURLResponse, data: Data) throws {
        switch response.statusCode {
        case 200...299:
            return
        case 401:
            throw APIError.unauthorized
        case 403:
            throw APIError.forbidden
        case 404:
            throw APIError.notFound
        case 429:
            throw APIError.rateLimitExceeded
        case 500...599:
            throw APIError.serverError(statusCode: response.statusCode)
        default:
            // Try to decode error message
            if let errorResponse = try? decoder.decode(ErrorResponse.self, from: data) {
                throw APIError.custom(message: errorResponse.message)
            }
            throw APIError.unknown(statusCode: response.statusCode)
        }
    }
    
    private func refreshTokenAndRetry<T: Decodable>(_ endpoint: APIEndpoint) async throws -> T {
        // Try to refresh token
        guard let refreshToken = tokenManager.getRefreshToken() else {
            throw APIError.unauthorized
        }
        
        let refreshEndpoint = AuthEndpoint.refresh(token: refreshToken)
        let response: AuthResponse = try await request(refreshEndpoint)
        
        // Save new tokens
        tokenManager.saveTokens(
            accessToken: response.accessToken,
            refreshToken: response.refreshToken
        )
        
        // Retry original request
        return try await request(endpoint)
    }
    
    private func mapError(_ error: Error) -> APIError {
        if let apiError = error as? APIError {
            return apiError
        }
        
        if let urlError = error as? URLError {
            switch urlError.code {
            case .notConnectedToInternet, .networkConnectionLost:
                return .noInternet
            case .timedOut:
                return .timeout
            case .cancelled:
                return .cancelled
            default:
                return .networkError(urlError)
            }
        }
        
        return .unknown(statusCode: 0)
    }
    
    private func createMultipartBody(data: Data, mimeType: String, boundary: String) -> Data {
        var body = Data()
        
        // Add file data
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"upload\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: \(mimeType)\r\n\r\n".data(using: .utf8)!)
        body.append(data)
        body.append("\r\n".data(using: .utf8)!)
        
        // End boundary
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        return body
    }
}

// MARK: - Supporting Types

/// API Configuration
struct APIConfig {
    #if DEBUG
    static let baseURL = "http://localhost:8000/api/v1"
    #else
    static let baseURL = "https://api.lms.example.com/api/v1"
    #endif
}

 