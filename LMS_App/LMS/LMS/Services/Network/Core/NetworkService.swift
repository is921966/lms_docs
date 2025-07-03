import Combine
import Foundation

// MARK: - NetworkError
enum NetworkError: Error {
    case invalidURL
    case noData
    case decodingError
    case serverError(Int)
    case unknown
}

// MARK: - NetworkServiceProtocol
protocol NetworkServiceProtocol {
    func request<T: Decodable>(
        _ url: String,
        method: HTTPMethod,
        headers: [String: String]?,
        body: Data?
    ) -> AnyPublisher<T, Error>
    
    func request<T: Decodable>(
        _ url: String,
        method: HTTPMethod,
        headers: [String: String]?,
        body: Data?
    ) async throws -> T
}

// MARK: - NetworkService
final class NetworkService: NetworkServiceProtocol {
    static let shared = NetworkService()
    
    private let session: URLSession
    private let baseURL: String
    
    private init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 60
        
        self.session = URLSession(configuration: configuration)
        self.baseURL = AppConfig.shared.apiBaseURL
    }
    
    // MARK: - Combine API
    
    func request<T: Decodable>(
        _ endpoint: String,
        method: HTTPMethod = .get,
        headers: [String: String]? = nil,
        body: Data? = nil
    ) -> AnyPublisher<T, Error> {
        guard let url = URL(string: baseURL + endpoint) else {
            return Fail(error: NetworkError.invalidURL)
                .eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.httpBody = body
        
        // Default headers
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        // Add authorization header if token exists
        if let token = TokenManager.shared.accessToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        // Custom headers
        headers?.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        return session.dataTaskPublisher(for: request)
            .tryMap { data, response in
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw NetworkError.unknown
                }
                
                if httpResponse.statusCode >= 400 {
                    throw NetworkError.serverError(httpResponse.statusCode)
                }
                
                return data
            }
            .decode(type: T.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
    
    // MARK: - Async/Await API
    
    func request<T: Decodable>(
        _ endpoint: String,
        method: HTTPMethod = .get,
        headers: [String: String]? = nil,
        body: Data? = nil
    ) async throws -> T {
        guard let url = URL(string: baseURL + endpoint) else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.httpBody = body
        
        // Default headers
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        // Add authorization header if token exists
        if let token = TokenManager.shared.accessToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        // Custom headers
        headers?.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.unknown
        }
        
        if httpResponse.statusCode >= 400 {
            throw NetworkError.serverError(httpResponse.statusCode)
        }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw NetworkError.decodingError
        }
    }
}

// MARK: - MockNetworkService
final class MockNetworkService: NetworkServiceProtocol {
    var mockResponse: Any?
    var shouldThrowError = false
    var error: Error = NetworkError.unknown
    
    func request<T: Decodable>(
        _ url: String,
        method: HTTPMethod,
        headers: [String: String]?,
        body: Data?
    ) -> AnyPublisher<T, Error> {
        if shouldThrowError {
            return Fail(error: error)
                .eraseToAnyPublisher()
        }
        
        guard let response = mockResponse as? T else {
            return Fail(error: NetworkError.decodingError)
                .eraseToAnyPublisher()
        }
        
        return Just(response)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    func request<T: Decodable>(
        _ url: String,
        method: HTTPMethod,
        headers: [String: String]?,
        body: Data?
    ) async throws -> T {
        if shouldThrowError {
            throw error
        }
        
        guard let response = mockResponse as? T else {
            throw NetworkError.decodingError
        }
        
        return response
    }
}
