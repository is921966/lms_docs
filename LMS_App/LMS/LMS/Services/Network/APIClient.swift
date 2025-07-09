//
//  APIClient.swift
//  LMS
//
//  Created by LMS Team on 13.01.2025.
//

import Foundation
import Combine

/// Main API client for network requests
class APIClient: ObservableObject {
    static let shared = APIClient()
    
    private let session: URLSession
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()
    
    @Published var isAuthenticated = false
    private var authToken: String?
    
    private init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = AppConfig.requestTimeout
        configuration.waitsForConnectivity = true
        
        self.session = URLSession(configuration: configuration)
        
        // Configure JSON decoder/encoder
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601
        encoder.keyEncodingStrategy = .convertToSnakeCase
        encoder.dateEncodingStrategy = .iso8601
        
        // Load saved token
        loadAuthToken()
    }
    
    // MARK: - Authentication
    
    /// Set authentication token
    func setAuthToken(_ token: String?) {
        self.authToken = token
        self.isAuthenticated = token != nil
        
        if let token = token {
            // Save to Keychain
            KeychainHelper.save(token, forKey: AppConfig.jwtTokenKey)
        } else {
            // Remove from Keychain
            KeychainHelper.delete(forKey: AppConfig.jwtTokenKey)
        }
    }
    
    /// Load saved authentication token
    private func loadAuthToken() {
        if let token = KeychainHelper.load(forKey: AppConfig.jwtTokenKey) {
            self.authToken = token
            self.isAuthenticated = true
        }
    }
    
    // MARK: - Request Methods
    
    /// Perform GET request
    func get<T: Decodable>(_ endpoint: String, parameters: [String: String]? = nil) async throws -> T {
        let request = try buildRequest(endpoint: endpoint, method: "GET", parameters: parameters)
        return try await performRequest(request)
    }
    
    /// Perform POST request
    func post<T: Decodable, B: Encodable>(_ endpoint: String, body: B) async throws -> T {
        let request = try buildRequest(endpoint: endpoint, method: "POST", body: body)
        return try await performRequest(request)
    }
    
    /// Perform PUT request
    func put<T: Decodable, B: Encodable>(_ endpoint: String, body: B) async throws -> T {
        let request = try buildRequest(endpoint: endpoint, method: "PUT", body: body)
        return try await performRequest(request)
    }
    
    /// Perform DELETE request
    func delete(_ endpoint: String) async throws {
        let request = try buildRequest(endpoint: endpoint, method: "DELETE")
        let _: EmptyResponse = try await performRequest(request)
    }
    
    // MARK: - Private Methods
    
    /// Build URL request
    private func buildRequest<B: Encodable>(
        endpoint: String,
        method: String,
        parameters: [String: String]? = nil,
        body: B? = nil
    ) throws -> URLRequest {
        // Build URL
        var urlComponents = URLComponents(string: AppConfig.baseURL + endpoint)!
        
        if let parameters = parameters {
            urlComponents.queryItems = parameters.map { URLQueryItem(name: $0.key, value: $0.value) }
        }
        
        guard let url = urlComponents.url else {
            throw APIError.invalidURL
        }
        
        // Create request
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        // Add auth token if available
        if let token = authToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        // Add body if provided
        if let body = body {
            request.httpBody = try encoder.encode(body)
        }
        
        return request
    }
    
    /// Build URL request without body
    private func buildRequest(
        endpoint: String,
        method: String,
        parameters: [String: String]? = nil
    ) throws -> URLRequest {
        let emptyBody: EmptyBody? = nil
        return try buildRequest(endpoint: endpoint, method: method, parameters: parameters, body: emptyBody)
    }
    
    /// Perform network request
    private func performRequest<T: Decodable>(_ request: URLRequest) async throws -> T {
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }
            
            // Log response in debug mode
            if AppConfig.enableDebugLogging {
                print("API Response [\(httpResponse.statusCode)]: \(String(data: data, encoding: .utf8) ?? "")")
            }
            
            // Handle different status codes
            switch httpResponse.statusCode {
            case 200...299:
                return try decoder.decode(T.self, from: data)
            case 401:
                // Token expired, try to refresh
                throw APIError.unauthorized
            case 400...499:
                let errorResponse = try? decoder.decode(ErrorResponse.self, from: data)
                throw APIError.clientError(statusCode: httpResponse.statusCode, message: errorResponse?.message)
            case 500...599:
                throw APIError.serverError(statusCode: httpResponse.statusCode)
            default:
                throw APIError.unexpectedStatusCode(httpResponse.statusCode)
            }
        } catch {
            if AppConfig.enableDebugLogging {
                print("API Error: \(error)")
            }
            throw error
        }
    }
}

// MARK: - Supporting Types

/// API Error types
enum APIError: LocalizedError {
    case invalidURL
    case invalidResponse
    case unauthorized
    case clientError(statusCode: Int, message: String?)
    case serverError(statusCode: Int)
    case unexpectedStatusCode(Int)
    case decodingError(Error)
    case networkError(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response from server"
        case .unauthorized:
            return "Authentication required"
        case .clientError(_, let message):
            return message ?? "Request error"
        case .serverError(let statusCode):
            return "Server error (\(statusCode))"
        case .unexpectedStatusCode(let code):
            return "Unexpected response code: \(code)"
        case .decodingError(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        }
    }
}

/// Empty body for requests without payload
private struct EmptyBody: Encodable {}

/// Empty response for requests without response body
private struct EmptyResponse: Decodable {}

/// Error response from API
private struct ErrorResponse: Decodable {
    let message: String?
    let errors: [String: [String]]?
} 