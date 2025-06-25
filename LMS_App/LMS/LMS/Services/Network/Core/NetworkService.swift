import Foundation
import Combine

// MARK: - NetworkError
enum NetworkError: LocalizedError {
    case invalidURL
    case noData
    case decodingError(Error)
    case serverError(statusCode: Int, data: Data?)
    case noInternetConnection
    case unauthorized
    case unknown(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .noData:
            return "No data received"
        case .decodingError(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        case .serverError(let statusCode, _):
            return "Server error with status code: \(statusCode)"
        case .noInternetConnection:
            return "No internet connection"
        case .unauthorized:
            return "Unauthorized. Please login again."
        case .unknown(let error):
            return error.localizedDescription
        }
    }
}

// MARK: - HTTPMethod
enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
    case patch = "PATCH"
}

// MARK: - NetworkService
class NetworkService: ObservableObject {
    static let shared = NetworkService()
    
    private let session: URLSession
    private var cancellables = Set<AnyCancellable>()
    
    // Configuration
    private let baseURL: String
    private let timeout: TimeInterval = 30
    
    init(session: URLSession = .shared) {
        self.session = session
        
        // Configure base URL based on environment
        #if DEBUG
        self.baseURL = "https://dev-api.lms.tsum.ru/api/v1"
        #else
        self.baseURL = "https://api.lms.tsum.ru/api/v1"
        #endif
    }
    
    // MARK: - Request Building
    func buildRequest(
        endpoint: String,
        method: HTTPMethod = .get,
        headers: [String: String]? = nil,
        body: Data? = nil
    ) throws -> URLRequest {
        guard let url = URL(string: baseURL + endpoint) else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.timeoutInterval = timeout
        
        // Default headers
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        // Add auth token if available
        if let token = TokenManager.shared.accessToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        // Custom headers
        headers?.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        // Body
        request.httpBody = body
        
        return request
    }
    
    // MARK: - Generic Request
    func request<T: Decodable>(
        endpoint: String,
        method: HTTPMethod = .get,
        headers: [String: String]? = nil,
        body: Data? = nil,
        responseType: T.Type
    ) -> AnyPublisher<T, NetworkError> {
        do {
            let request = try buildRequest(
                endpoint: endpoint,
                method: method,
                headers: headers,
                body: body
            )
            
            return session.dataTaskPublisher(for: request)
                .tryMap { data, response in
                    guard let httpResponse = response as? HTTPURLResponse else {
                        throw NetworkError.unknown(URLError(.badServerResponse))
                    }
                    
                    // Check status code
                    switch httpResponse.statusCode {
                    case 200...299:
                        return data
                    case 401:
                        throw NetworkError.unauthorized
                    default:
                        throw NetworkError.serverError(
                            statusCode: httpResponse.statusCode,
                            data: data
                        )
                    }
                }
                .decode(type: T.self, decoder: JSONDecoder())
                .mapError { error in
                    if let networkError = error as? NetworkError {
                        return networkError
                    } else if error is DecodingError {
                        return NetworkError.decodingError(error)
                    } else if (error as NSError).code == NSURLErrorNotConnectedToInternet {
                        return NetworkError.noInternetConnection
                    } else {
                        return NetworkError.unknown(error)
                    }
                }
                .receive(on: DispatchQueue.main)
                .eraseToAnyPublisher()
        } catch {
            return Fail(error: error as? NetworkError ?? NetworkError.unknown(error))
                .eraseToAnyPublisher()
        }
    }
    
    // MARK: - Convenience Methods
    func get<T: Decodable>(
        endpoint: String,
        headers: [String: String]? = nil,
        responseType: T.Type
    ) -> AnyPublisher<T, NetworkError> {
        request(
            endpoint: endpoint,
            method: .get,
            headers: headers,
            responseType: responseType
        )
    }
    
    func post<T: Decodable, B: Encodable>(
        endpoint: String,
        body: B,
        headers: [String: String]? = nil,
        responseType: T.Type
    ) -> AnyPublisher<T, NetworkError> {
        do {
            let bodyData = try JSONEncoder().encode(body)
            return request(
                endpoint: endpoint,
                method: .post,
                headers: headers,
                body: bodyData,
                responseType: responseType
            )
        } catch {
            return Fail(error: NetworkError.unknown(error))
                .eraseToAnyPublisher()
        }
    }
} 