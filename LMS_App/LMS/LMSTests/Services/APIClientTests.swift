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
        sut = APIClient(session: mockURLSession)
    }
    
    override func tearDown() {
        sut = nil
        mockURLSession = nil
        MockURLProtocol.stubResponses = [:]
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
        struct UserDTO: Decodable {
            let id: Int
            let name: String
            let email: String
        }
        
        let user: UserDTO = try await sut.request(
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
                // Success
            } else {
                XCTFail("Expected no internet error")
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
                XCTFail("Expected unauthorized error")
            }
        }
    }
    
    // MARK: - Token Refresh Tests
    
    func testTokenRefreshOnUnauthorized() async throws {
        // Given
        var callCount = 0
        MockURLProtocol.requestHandler = { request in
            callCount += 1
            
            if callCount == 1 {
                // First call returns 401
                return (
                    Data(),
                    HTTPURLResponse(
                        url: request.url!,
                        statusCode: 401,
                        httpVersion: nil,
                        headerFields: nil
                    )!,
                    nil
                )
            } else {
                // After token refresh, return success
                let data = """
                {"id": 1, "name": "Test User"}
                """.data(using: .utf8)!
                return (
                    data,
                    HTTPURLResponse(
                        url: request.url!,
                        statusCode: 200,
                        httpVersion: nil,
                        headerFields: ["Content-Type": "application/json"]
                    )!,
                    nil
                )
            }
        }
        
        // Mock token refresh
        TokenManager.shared.saveTokens(
            accessToken: "new-access-token",
            refreshToken: "refresh-token"
        )
        
        // When
        struct SimpleUser: Decodable {
            let id: Int
            let name: String
        }
        
        let user: SimpleUser = try await sut.request(
            MockEndpoint.getUser(id: 1)
        )
        
        // Then
        XCTAssertEqual(callCount, 2) // Original + retry after refresh
        XCTAssertEqual(user.id, 1)
        XCTAssertEqual(user.name, "Test User")
    }
    
    // MARK: - Concurrent Request Tests
    
    func testConcurrentRequests() async throws {
        // Given
        for i in 1...5 {
            let data = """
            {"id": \(i), "name": "User \(i)"}
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
        struct User: Decodable {
            let id: Int
            let name: String
        }
        
        async let user1: User = sut.request(MockEndpoint.getUser(id: 1))
        async let user2: User = sut.request(MockEndpoint.getUser(id: 2))
        async let user3: User = sut.request(MockEndpoint.getUser(id: 3))
        async let user4: User = sut.request(MockEndpoint.getUser(id: 4))
        async let user5: User = sut.request(MockEndpoint.getUser(id: 5))
        
        let users = try await [user1, user2, user3, user4, user5]
        
        // Then
        XCTAssertEqual(users.count, 5)
        for (index, user) in users.enumerated() {
            XCTAssertEqual(user.id, index + 1)
            XCTAssertEqual(user.name, "User \(index + 1)")
        }
    }
    
    // MARK: - Request Cancellation Tests
    
    func testRequestCancellation() async {
        // Given
        let expectation = XCTestExpectation(description: "Request cancelled")
        
        MockURLProtocol.requestHandler = { _ in
            // Simulate slow response
            try? await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
            return (Data(), HTTPURLResponse(), nil)
        }
        
        // When
        let task = Task {
            do {
                let _: MockUserResponse = try await sut.request(
                    MockEndpoint.getUser(id: 1)
                )
                XCTFail("Request should have been cancelled")
            } catch {
                if error is CancellationError {
                    expectation.fulfill()
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
            if let error = stub.error {
                client?.urlProtocol(self, didFailWithError: error)
            } else if let response = stub.response, let data = stub.data {
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
                client?.urlProtocol(self, didLoad: data)
                client?.urlProtocolDidFinishLoading(self)
            }
        } else {
            client?.urlProtocol(self, didFailWithError: NSError(domain: "MockURLProtocol", code: 404))
        }
    }
    
    override func stopLoading() {
        // No-op
    }
} 