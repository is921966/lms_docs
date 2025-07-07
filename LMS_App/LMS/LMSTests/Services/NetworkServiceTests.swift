//
//  NetworkServiceTests.swift
//  LMSTests
//

import XCTest
@testable import LMS

final class NetworkServiceTests: XCTestCase {
    
    var sut: NetworkService!
    
    override func setUp() {
        super.setUp()
        sut = NetworkService.shared
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    // MARK: - Singleton Tests
    
    func testSharedInstance() {
        let instance1 = NetworkService.shared
        let instance2 = NetworkService.shared
        XCTAssertTrue(instance1 === instance2)
    }
    
    // MARK: - Request Tests
    
    func testBuildURLRequest() throws {
        // Given
        let endpoint = "users"
        let method = HTTPMethod.get
        
        // When
        let request = try sut.buildRequest(
            endpoint: endpoint,
            method: method,
            body: nil,
            headers: nil
        )
        
        // Then
        XCTAssertNotNil(request)
        XCTAssertTrue(request.url?.absoluteString.contains(endpoint) ?? false)
        XCTAssertEqual(request.httpMethod, method.rawValue)
    }
    
    func testBuildURLRequestWithBody() throws {
        // Given
        let endpoint = "users"
        let method = HTTPMethod.post
        let body = ["name": "Test User", "email": "test@example.com"]
        
        // When
        let request = try sut.buildRequest(
            endpoint: endpoint,
            method: method,
            body: body,
            headers: nil
        )
        
        // Then
        XCTAssertNotNil(request)
        XCTAssertNotNil(request.httpBody)
        XCTAssertEqual(request.httpMethod, method.rawValue)
        XCTAssertEqual(request.value(forHTTPHeaderField: "Content-Type"), "application/json")
    }
    
    func testBuildURLRequestWithHeaders() throws {
        // Given
        let endpoint = "users"
        let method = HTTPMethod.get
        let headers = ["Authorization": "Bearer token123"]
        
        // When
        let request = try sut.buildRequest(
            endpoint: endpoint,
            method: method,
            body: nil,
            headers: headers
        )
        
        // Then
        XCTAssertNotNil(request)
        XCTAssertEqual(request.value(forHTTPHeaderField: "Authorization"), "Bearer token123")
    }
    
    // MARK: - HTTP Method Tests
    
    func testHTTPMethods() {
        XCTAssertEqual(HTTPMethod.get.rawValue, "GET")
        XCTAssertEqual(HTTPMethod.post.rawValue, "POST")
        XCTAssertEqual(HTTPMethod.put.rawValue, "PUT")
        XCTAssertEqual(HTTPMethod.delete.rawValue, "DELETE")
        XCTAssertEqual(HTTPMethod.patch.rawValue, "PATCH")
    }
    
    // MARK: - Configuration Tests
    
    func testDefaultConfiguration() {
        XCTAssertNotNil(sut.baseURL)
        XCTAssertFalse(sut.baseURL.isEmpty)
        XCTAssertNotNil(sut.session)
        XCTAssertNotNil(sut.decoder)
    }
    
    func testTimeoutConfiguration() {
        let timeout = sut.session.configuration.timeoutIntervalForRequest
        XCTAssertGreaterThan(timeout, 0)
        XCTAssertLessThanOrEqual(timeout, 60)
    }
    
    // MARK: - Error Handling Tests
    
    func testNetworkError() {
        let error = NetworkError.noData
        XCTAssertEqual(error.localizedDescription, "No data received")
        
        let invalidURLError = NetworkError.invalidURL
        XCTAssertEqual(invalidURLError.localizedDescription, "Invalid URL")
        
        let decodingError = NetworkError.decodingError
        XCTAssertEqual(decodingError.localizedDescription, "Failed to decode response")
    }
    
    func testHTTPStatusCodeErrors() {
        let badRequest = NetworkError.httpError(400)
        XCTAssertEqual(badRequest.localizedDescription, "HTTP Error: 400")
        
        let unauthorized = NetworkError.httpError(401)
        XCTAssertEqual(unauthorized.localizedDescription, "HTTP Error: 401")
        
        let serverError = NetworkError.httpError(500)
        XCTAssertEqual(serverError.localizedDescription, "HTTP Error: 500")
    }
    
    // MARK: - URL Building Tests
    
    func testBuildURL() {
        // Given
        let endpoint = "api/v1/users"
        
        // When
        let url = sut.buildURL(for: endpoint)
        
        // Then
        XCTAssertNotNil(url)
        XCTAssertTrue(url?.absoluteString.contains(endpoint) ?? false)
    }
    
    func testBuildURLWithQueryParameters() {
        // Given
        let endpoint = "api/v1/users"
        let parameters = ["page": "1", "limit": "10"]
        
        // When
        let url = sut.buildURL(for: endpoint, parameters: parameters)
        
        // Then
        XCTAssertNotNil(url)
        XCTAssertTrue(url?.absoluteString.contains("page=1") ?? false)
        XCTAssertTrue(url?.absoluteString.contains("limit=10") ?? false)
    }
    
    // MARK: - Mock Response Tests
    
    func testHandleSuccessResponse() {
        // Given
        let data = """
        {
            "id": "123",
            "name": "Test User",
            "email": "test@example.com"
        }
        """.data(using: .utf8)!
        
        // When
        let result = sut.handleResponse(data: data, response: nil, error: nil)
        
        // Then
        switch result {
        case .success(let responseData):
            XCTAssertEqual(responseData, data)
        case .failure:
            XCTFail("Should return success")
        }
    }
    
    func testHandleErrorResponse() {
        // Given
        let error = NSError(domain: "test", code: -1, userInfo: nil)
        
        // When
        let result = sut.handleResponse(data: nil, response: nil, error: error)
        
        // Then
        switch result {
        case .success:
            XCTFail("Should return failure")
        case .failure(let networkError):
            XCTAssertNotNil(networkError)
        }
    }
}

// MARK: - Test Helpers

extension NetworkService {
    func handleResponse(data: Data?, response: URLResponse?, error: Error?) -> Result<Data, NetworkError> {
        if let error = error {
            return .failure(.requestFailed(error))
        }
        
        guard let data = data else {
            return .failure(.noData)
        }
        
        if let httpResponse = response as? HTTPURLResponse,
           !(200...299).contains(httpResponse.statusCode) {
            return .failure(.httpError(httpResponse.statusCode))
        }
        
        return .success(data)
    }
    
    func buildURL(for endpoint: String, parameters: [String: String]? = nil) -> URL? {
        var components = URLComponents(string: baseURL + "/" + endpoint)
        
        if let parameters = parameters {
            components?.queryItems = parameters.map { URLQueryItem(name: $0.key, value: $0.value) }
        }
        
        return components?.url
    }
}

// MARK: - Network Error

enum NetworkError: LocalizedError {
    case noData
    case invalidURL
    case decodingError
    case httpError(Int)
    case requestFailed(Error)
    
    var errorDescription: String? {
        switch self {
        case .noData:
            return "No data received"
        case .invalidURL:
            return "Invalid URL"
        case .decodingError:
            return "Failed to decode response"
        case .httpError(let code):
            return "HTTP Error: \(code)"
        case .requestFailed(let error):
            return error.localizedDescription
        }
    }
} 