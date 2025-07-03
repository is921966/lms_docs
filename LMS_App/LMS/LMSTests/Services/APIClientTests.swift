import XCTest
@testable import LMS

class APIClientTests: XCTestCase {
    
    var apiClient: APIClient!
    var mockSession: URLSession!
    var mockTokenManager: MockTokenManager!
    
    override func setUp() {
        super.setUp()
        
        // Create mock URLSession
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        mockSession = URLSession(configuration: configuration)
        
        // Create mock token manager
        mockTokenManager = MockTokenManager()
        
        // Create API client with mocks
        apiClient = APIClient(
            baseURL: "https://api.test.com",
            session: mockSession,
            tokenManager: mockTokenManager
        )
    }
    
    override func tearDown() {
        apiClient = nil
        mockSession = nil
        mockTokenManager = nil
        MockURLProtocol.requestHandler = nil
        super.tearDown()
    }
    
    // MARK: - Tests
    
    func testSuccessfulRequest() async throws {
        // Given
        let expectedUser = UserResponse(
            id: "123",
            email: "test@example.com",
            name: "Test User",
            role: "user",
            avatarUrl: nil,
            createdAt: Date(),
            updatedAt: Date()
        )
        
        MockURLProtocol.requestHandler = { request in
            XCTAssertEqual(request.url?.path, "/auth/me")
            XCTAssertEqual(request.httpMethod, "GET")
            XCTAssertEqual(request.value(forHTTPHeaderField: "Authorization"), "Bearer test-token")
            
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!
            
            let encoder = JSONEncoder()
            encoder.keyEncodingStrategy = .convertToSnakeCase
            encoder.dateEncodingStrategy = .iso8601
            let data = try encoder.encode(expectedUser)
            
            return (response, data)
        }
        
        mockTokenManager.accessToken = "test-token"
        
        // When
        let endpoint = AuthEndpoint.me
        let result: UserResponse = try await apiClient.request(endpoint)
        
        // Then
        XCTAssertEqual(result.id, expectedUser.id)
        XCTAssertEqual(result.email, expectedUser.email)
        XCTAssertEqual(result.name, expectedUser.name)
    }
    
    func testUnauthorizedError() async {
        // Given
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 401,
                httpVersion: nil,
                headerFields: nil
            )!
            
            return (response, Data())
        }
        
        mockTokenManager.accessToken = "expired-token"
        
        // When/Then
        do {
            let endpoint = AuthEndpoint.me
            let _: UserResponse = try await apiClient.request(endpoint)
            XCTFail("Should throw unauthorized error")
        } catch let error as APIError {
            if case .unauthorized = error {
                // Success
            } else {
                XCTFail("Wrong error type: \(error)")
            }
        } catch {
            XCTFail("Wrong error type: \(error)")
        }
    }
    
    func testNetworkError() async {
        // Given
        MockURLProtocol.requestHandler = { request in
            throw URLError(.notConnectedToInternet)
        }
        
        mockTokenManager.accessToken = "test-token"
        
        // When/Then
        do {
            let endpoint = AuthEndpoint.me
            let _: UserResponse = try await apiClient.request(endpoint)
            XCTFail("Should throw network error")
        } catch let error as APIError {
            if case .noInternet = error {
                // Success
            } else {
                XCTFail("Wrong error type: \(error)")
            }
        } catch {
            XCTFail("Wrong error type: \(error)")
        }
    }
    
    func testRequestWithoutAuth() async throws {
        // Given
        let loginRequest = LoginRequest(email: "test@example.com", password: "password")
        let expectedResponse = AuthResponse(
            user: UserResponse(
                id: "123",
                email: "test@example.com",
                name: "Test User",
                role: "user",
                avatarUrl: nil,
                createdAt: Date(),
                updatedAt: Date()
            ),
            accessToken: "new-access-token",
            refreshToken: "new-refresh-token",
            tokenType: "Bearer",
            expiresIn: 3600
        )
        
        MockURLProtocol.requestHandler = { request in
            XCTAssertEqual(request.url?.path, "/auth/login")
            XCTAssertEqual(request.httpMethod, "POST")
            XCTAssertNil(request.value(forHTTPHeaderField: "Authorization"))
            
            // Verify request body
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let body = try decoder.decode(LoginRequest.self, from: request.httpBody!)
            XCTAssertEqual(body.email, loginRequest.email)
            XCTAssertEqual(body.password, loginRequest.password)
            
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!
            
            let encoder = JSONEncoder()
            encoder.keyEncodingStrategy = .convertToSnakeCase
            encoder.dateEncodingStrategy = .iso8601
            let data = try encoder.encode(expectedResponse)
            
            return (response, data)
        }
        
        // When
        let endpoint = AuthEndpoint.login(email: "test@example.com", password: "password")
        let result: AuthResponse = try await apiClient.request(endpoint)
        
        // Then
        XCTAssertEqual(result.accessToken, expectedResponse.accessToken)
        XCTAssertEqual(result.refreshToken, expectedResponse.refreshToken)
        XCTAssertEqual(result.user.email, expectedResponse.user.email)
    }
}

// MARK: - Mock Helpers

class MockURLProtocol: URLProtocol {
    static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse, Data))?
    
    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    override func startLoading() {
        guard let handler = MockURLProtocol.requestHandler else {
            client?.urlProtocol(self, didFailWithError: URLError(.badServerResponse))
            return
        }
        
        do {
            let (response, data) = try handler(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }
    
    override func stopLoading() {}
}

class MockTokenManager: TokenManager {
    var accessToken: String?
    var refreshToken: String?
    
    override func getAccessToken() -> String? {
        return accessToken
    }
    
    override func getRefreshToken() -> String? {
        return refreshToken
    }
    
    override func saveTokens(accessToken: String, refreshToken: String) {
        self.accessToken = accessToken
        self.refreshToken = refreshToken
    }
    
    override func clearTokens() {
        accessToken = nil
        refreshToken = nil
    }
    
    override var hasValidTokens: Bool {
        return accessToken != nil
    }
} 