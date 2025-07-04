import XCTest
@testable import LMS

final class APIClientTests: XCTestCase {
    
    var sut: APIClient!
    var mockURLSession: URLSession!
    
    override func setUp() {
        super.setUp()
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        mockURLSession = URLSession(configuration: configuration)
        
        // Reset mock responses before each test
        MockURLProtocol.stubResponses = [:]
        MockURLProtocol.requestHandler = nil
        
        // Create APIClient with test configuration
        sut = APIClient(
            baseURL: "https://api.example.com",
            session: mockURLSession,
            tokenManager: TokenManager.shared
        )
    }
    
    override func tearDown() {
        sut = nil
        mockURLSession = nil
        MockURLProtocol.stubResponses = [:]
        MockURLProtocol.requestHandler = nil
        super.tearDown()
    }
    
    // MARK: - Successful Request Tests
    
    func testSuccessfulAPIRequest() async throws {
        // Given
        let expectedData = """
        {
            "id": 1,
            "name": "Test User",
            "email": "test@example.com"
        }
        """.data(using: .utf8)!
        
        MockURLProtocol.stubResponses["/api/users/1"] = (
            data: expectedData,
            response: HTTPURLResponse(
                url: URL(string: "https://api.example.com/api/users/1")!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: ["Content-Type": "application/json"]
            )!,
            error: nil
        )
        
        // When
        let user: MockUserResponse = try await sut.request(
            MockEndpoint.getUser(id: 1)
        )
        
        // Then
        XCTAssertEqual(user.id, 1)
        XCTAssertEqual(user.name, "Test User")
        XCTAssertEqual(user.email, "test@example.com")
    }
    
    // MARK: - Error Handling Tests
    
    func testAPIRequestWithNetworkError() async {
        // Given
        MockURLProtocol.stubResponses["/api/users/1"] = (
            data: nil,
            response: nil,
            error: URLError(.notConnectedToInternet)
        )
        
        // When/Then
        do {
            let _: MockUserResponse = try await sut.request(
                MockEndpoint.getUser(id: 1)
            )
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertTrue(error is APIError)
            if case .noInternet = error as? APIError {
                // Success - APIClient.mapError converts URLError.notConnectedToInternet to .noInternet
            } else {
                XCTFail("Expected no internet error, got: \(error)")
            }
        }
    }
    
    func testAPIRequestWith401Unauthorized() async {
        // Given
        MockURLProtocol.stubResponses["/api/users/1"] = (
            data: Data(),
            response: HTTPURLResponse(
                url: URL(string: "https://api.example.com/api/users/1")!,
                statusCode: 401,
                httpVersion: nil,
                headerFields: nil
            )!,
            error: nil
        )
        
        // When/Then
        do {
            let _: MockUserResponse = try await sut.request(
                MockEndpoint.getUser(id: 1)
            )
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertTrue(error is APIError)
            if case .unauthorized = error as? APIError {
                // Success
            } else {
                XCTFail("Expected unauthorized error, got: \(error)")
            }
        }
    }
    
    // MARK: - Token Refresh Tests
    
    func testTokenRefreshOnUnauthorized() async throws {
        // Skip this test for now as it requires more complex setup
        throw XCTSkip("Token refresh test requires AuthService integration")
    }
    
    // MARK: - Concurrent Request Tests
    
    func testConcurrentRequests() async throws {
        // Given
        for i in 1...5 {
            let data = """
            {"id": \(i), "name": "User \(i)", "email": "user\(i)@example.com"}
            """.data(using: .utf8)!
            
            MockURLProtocol.stubResponses["/api/users/\(i)"] = (
                data: data,
                response: HTTPURLResponse(
                    url: URL(string: "https://api.example.com/api/users/\(i)")!,
                    statusCode: 200,
                    httpVersion: nil,
                    headerFields: ["Content-Type": "application/json"]
                )!,
                error: nil
            )
        }
        
        // When
        async let user1: MockUserResponse = sut.request(MockEndpoint.getUser(id: 1))
        async let user2: MockUserResponse = sut.request(MockEndpoint.getUser(id: 2))
        async let user3: MockUserResponse = sut.request(MockEndpoint.getUser(id: 3))
        async let user4: MockUserResponse = sut.request(MockEndpoint.getUser(id: 4))
        async let user5: MockUserResponse = sut.request(MockEndpoint.getUser(id: 5))
        
        let users = try await [user1, user2, user3, user4, user5]
        
        // Then
        XCTAssertEqual(users.count, 5)
        for (index, user) in users.enumerated() {
            XCTAssertEqual(user.id, index + 1)
            XCTAssertEqual(user.name, "User \(index + 1)")
            XCTAssertEqual(user.email, "user\(index + 1)@example.com")
        }
    }
    
    // MARK: - Request Cancellation Tests
    
    func testRequestCancellation() async {
        // Given
        let expectation = XCTestExpectation(description: "Request cancelled")
        
        // Create a slow mock response
        MockURLProtocol.requestHandler = { request in
            // Wait for cancellation
            do {
                try await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
                return (Data(), HTTPURLResponse(), nil)
            } catch {
                // Task was cancelled, throw URLError
                throw URLError(.cancelled)
            }
        }
        
        // When
        let task = Task {
            do {
                let _: MockUserResponse = try await sut.request(
                    MockEndpoint.getUser(id: 1)
                )
                XCTFail("Request should have been cancelled")
            } catch {
                // Check for either APIError.cancelled or the underlying error
                if let apiError = error as? APIError {
                    switch apiError {
                    case .cancelled:
                        expectation.fulfill()
                    case .networkError(let urlError) where urlError.code == .cancelled:
                        expectation.fulfill()
                    default:
                        XCTFail("Unexpected error type: \(apiError)")
                    }
                } else if error is CancellationError {
                    expectation.fulfill()
                } else {
                    XCTFail("Unexpected error type: \(error)")
                }
            }
        }
        
        // Cancel after short delay
        Task {
            try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
            task.cancel()
        }
        
        // Then
        await fulfillment(of: [expectation], timeout: 3.0)
    }
}

// MARK: - Mock Helpers

private enum MockEndpoint: APIEndpoint {
    case getUser(id: Int)
    
    var path: String {
        switch self {
        case .getUser(let id):
            return "/api/users/\(id)"
        }
    }
    
    var method: HTTPMethod { .get }
    var requiresAuth: Bool { false }
    var parameters: [String: Any]? { nil }
    var body: Encodable? { nil }
    var headers: [String: String]? { nil }
}

private struct MockUserResponse: Decodable {
    let id: Int
    let name: String
    let email: String?
}

// MARK: - MockURLProtocol

private class MockURLProtocol: URLProtocol {
    static var stubResponses: [String: (data: Data?, response: URLResponse?, error: Error?)] = [:]
    static var requestHandler: ((URLRequest) async throws -> (Data, URLResponse, Error?))? = nil
    
    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    override func startLoading() {
        guard let url = request.url else {
            client?.urlProtocol(self, didFailWithError: NSError(domain: "MockURLProtocol", code: 0))
            return
        }
        
        let path = url.path
        
        // First check if we have a custom request handler
        if let handler = Self.requestHandler {
            Task {
                do {
                    let (data, response, error) = try await handler(request)
                    if let error = error {
                        client?.urlProtocol(self, didFailWithError: error)
                    } else {
                        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
                        client?.urlProtocol(self, didLoad: data)
                        client?.urlProtocolDidFinishLoading(self)
                    }
                } catch {
                    client?.urlProtocol(self, didFailWithError: error)
                }
            }
        } else if let stub = Self.stubResponses[path] {
            // Use pre-configured stub response
            if let error = stub.error {
                client?.urlProtocol(self, didFailWithError: error)
            } else if let response = stub.response, let data = stub.data {
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
                client?.urlProtocol(self, didLoad: data)
                client?.urlProtocolDidFinishLoading(self)
            } else {
                client?.urlProtocol(self, didFailWithError: NSError(domain: "MockURLProtocol", code: 404))
            }
        } else {
            // No stub found
            client?.urlProtocol(self, didFailWithError: NSError(domain: "MockURLProtocol", code: 404))
        }
    }
    
    override func stopLoading() {
        // No-op
    }
} 