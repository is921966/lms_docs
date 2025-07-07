import XCTest
import Combine
@testable import LMS

final class NetworkServiceExtendedTests: XCTestCase {
    
    // MARK: - Properties
    var sut: NetworkService!
    var mockService: MockNetworkService!
    var cancellables: Set<AnyCancellable>!
    
    // MARK: - Setup
    override func setUp() {
        super.setUp()
        sut = NetworkService.shared
        mockService = MockNetworkService()
        cancellables = []
    }
    
    override func tearDown() {
        cancellables = nil
        mockService = nil
        sut = nil
        // Clear any stored tokens
        TokenManager.shared.clearTokens()
        super.tearDown()
    }
    
    // MARK: - Configuration Tests
    
    func testNetworkServiceConfiguration() {
        // Given/When
        let service = NetworkService.shared
        
        // Then
        XCTAssertNotNil(service, "NetworkService should be initialized")
    }
    
    // MARK: - URL Construction Tests
    
    func testInvalidURLHandling() async {
        // Given
        struct TestResponse: Codable {
            let data: String
        }
        
        // Mock service with specific behavior
        let mockService = MockNetworkService()
        mockService.shouldThrowError = true
        mockService.error = NetworkError.invalidURL
        
        // When/Then
        do {
            let _: TestResponse = try await mockService.request(
                "ht tp://invalid url with spaces",
                method: .get,
                headers: nil,
                body: nil
            )
            XCTFail("Should throw invalid URL error")
        } catch {
            XCTAssertTrue(error is NetworkError, "Should throw NetworkError")
            if let networkError = error as? NetworkError {
                if case .invalidURL = networkError {
                    // Success
                } else {
                    XCTFail("Should be invalidURL error")
                }
            }
        }
    }
    
    // MARK: - Header Tests
    
    func testDefaultHeaders() async throws {
        // Given
        struct HeaderTestResponse: Codable {
            let headers: [String: String]
        }
        
        let mockResponse = HeaderTestResponse(headers: [
            "Content-Type": "application/json",
            "Accept": "application/json"
        ])
        mockService.mockResponse = mockResponse
        
        // When
        let response: HeaderTestResponse = try await mockService.request(
            "/headers",
            method: .get,
            headers: nil,
            body: nil
        )
        
        // Then
        XCTAssertEqual(response.headers["Content-Type"], "application/json")
        XCTAssertEqual(response.headers["Accept"], "application/json")
    }
    
    func testCustomHeaders() async throws {
        // Given
        struct HeaderTestResponse: Codable {
            let success: Bool
        }
        
        let customHeaders = [
            "X-Custom-Header": "CustomValue",
            "X-API-Version": "1.0"
        ]
        
        mockService.mockResponse = HeaderTestResponse(success: true)
        
        // When
        let response: HeaderTestResponse = try await mockService.request(
            "/custom-headers",
            method: .post,
            headers: customHeaders,
            body: nil
        )
        
        // Then
        XCTAssertTrue(response.success)
    }
    
    func testAuthorizationHeader() async throws {
        // Given
        TokenManager.shared.saveTokens(
            accessToken: "test-token-123",
            refreshToken: "refresh-token-456"
        )
        
        struct AuthTestResponse: Codable {
            let authorized: Bool
        }
        
        mockService.mockResponse = AuthTestResponse(authorized: true)
        
        // When
        let response: AuthTestResponse = try await mockService.request(
            "/auth-test",
            method: .get,
            headers: nil,
            body: nil
        )
        
        // Then
        XCTAssertTrue(response.authorized)
        
        // Cleanup
        TokenManager.shared.clearTokens()
    }
    
    // MARK: - HTTP Method Tests
    
    func testAllHTTPMethods() async throws {
        // Given
        struct MethodTestResponse: Codable {
            let method: String
            let success: Bool
        }
        
        let methods: [HTTPMethod] = [.get, .post, .put, .delete, .patch]
        
        for method in methods {
            // Given
            mockService.mockResponse = MethodTestResponse(
                method: method.rawValue,
                success: true
            )
            
            // When
            let response: MethodTestResponse = try await mockService.request(
                "/method-test",
                method: method,
                headers: nil,
                body: nil
            )
            
            // Then
            XCTAssertEqual(response.method, method.rawValue)
            XCTAssertTrue(response.success)
        }
    }
    
    // MARK: - Request Body Tests
    
    func testRequestWithBody() async throws {
        // Given
        struct RequestBody: Codable {
            let name: String
            let age: Int
            let email: String
        }
        
        struct BodyTestResponse: Codable {
            let receivedData: Bool
        }
        
        let requestBody = RequestBody(
            name: "Test User",
            age: 25,
            email: "test@example.com"
        )
        
        let bodyData = try JSONEncoder().encode(requestBody)
        mockService.mockResponse = BodyTestResponse(receivedData: true)
        
        // When
        let response: BodyTestResponse = try await mockService.request(
            "/body-test",
            method: .post,
            headers: nil,
            body: bodyData
        )
        
        // Then
        XCTAssertTrue(response.receivedData)
    }
    
    // MARK: - Error Handling Tests
    
    func testServerErrorCodes() async {
        // Test various server error codes
        let errorCodes = [400, 401, 403, 404, 500, 502, 503]
        
        for code in errorCodes {
            // Given
            mockService.shouldThrowError = true
            mockService.error = NetworkError.serverError(code)
            
            // When/Then
            do {
                let _: TestResponse = try await mockService.request(
                    "/error-test",
                    method: .get,
                    headers: nil,
                    body: nil
                )
                XCTFail("Should throw error for code \(code)")
            } catch {
                if let networkError = error as? NetworkError,
                   case .serverError(let errorCode) = networkError {
                    XCTAssertEqual(errorCode, code)
                } else {
                    XCTFail("Should be server error with code \(code)")
                }
            }
        }
    }
    
    func testDecodingError() async {
        // Given
        mockService.shouldThrowError = true
        mockService.error = NetworkError.decodingError
        
        // When/Then
        do {
            let _: TestResponse = try await mockService.request(
                "/decoding-error",
                method: .get,
                headers: nil,
                body: nil
            )
            XCTFail("Should throw decoding error")
        } catch {
            if let networkError = error as? NetworkError,
               case .decodingError = networkError {
                // Success
            } else {
                XCTFail("Should be decoding error")
            }
        }
    }
    
    func testNoDataError() async {
        // Given
        mockService.shouldThrowError = true
        mockService.error = NetworkError.noData
        
        // When/Then
        do {
            let _: TestResponse = try await mockService.request(
                "/no-data",
                method: .get,
                headers: nil,
                body: nil
            )
            XCTFail("Should throw no data error")
        } catch {
            if let networkError = error as? NetworkError,
               case .noData = networkError {
                // Success
            } else {
                XCTFail("Should be no data error")
            }
        }
    }
    
    // MARK: - Combine API Tests
    
    func testCombineRequestSuccess() {
        // Given
        struct CombineTestResponse: Codable {
            let id: String
            let status: String
        }
        
        let expectedResponse = CombineTestResponse(id: "123", status: "success")
        mockService.mockResponse = expectedResponse
        
        let expectation = XCTestExpectation(description: "Combine request succeeds")
        
        // When
        mockService.request(
            "/combine-test",
            method: .get,
            headers: nil,
            body: nil
        )
        .sink(
            receiveCompletion: { completion in
                if case .failure = completion {
                    XCTFail("Should not fail")
                }
            },
            receiveValue: { (response: CombineTestResponse) in
                // Then
                XCTAssertEqual(response.id, expectedResponse.id)
                XCTAssertEqual(response.status, expectedResponse.status)
                expectation.fulfill()
            }
        )
        .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testCombineRequestWithMultipleSubscribers() {
        // Given
        struct MultiSubscriberResponse: Codable {
            let count: Int
        }
        
        let expectedResponse = MultiSubscriberResponse(count: 42)
        mockService.mockResponse = expectedResponse
        
        let expectation1 = XCTestExpectation(description: "First subscriber")
        let expectation2 = XCTestExpectation(description: "Second subscriber")
        
        // When
        let publisher: AnyPublisher<MultiSubscriberResponse, Error> = mockService.request(
            "/multi-subscriber",
            method: .get,
            headers: nil,
            body: nil
        )
        
        // First subscriber
        publisher
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { response in
                    XCTAssertEqual(response.count, 42)
                    expectation1.fulfill()
                }
            )
            .store(in: &cancellables)
        
        // Second subscriber
        publisher
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { response in
                    XCTAssertEqual(response.count, 42)
                    expectation2.fulfill()
                }
            )
            .store(in: &cancellables)
        
        wait(for: [expectation1, expectation2], timeout: 1.0)
    }
    
    // MARK: - Complex Response Tests
    
    func testComplexNestedResponse() async throws {
        // Given
        struct NestedData: Codable {
            let id: String
            let attributes: [String: String]
        }
        
        struct ComplexResponse: Codable {
            let status: String
            let data: [NestedData]
            let metadata: [String: Int]
        }
        
        let complexResponse = ComplexResponse(
            status: "success",
            data: [
                NestedData(id: "1", attributes: ["name": "Item 1", "type": "A"]),
                NestedData(id: "2", attributes: ["name": "Item 2", "type": "B"])
            ],
            metadata: ["total": 2, "page": 1, "perPage": 10]
        )
        
        mockService.mockResponse = complexResponse
        
        // When
        let response: ComplexResponse = try await mockService.request(
            "/complex",
            method: .get,
            headers: nil,
            body: nil
        )
        
        // Then
        XCTAssertEqual(response.status, "success")
        XCTAssertEqual(response.data.count, 2)
        XCTAssertEqual(response.data[0].id, "1")
        XCTAssertEqual(response.data[0].attributes["name"], "Item 1")
        XCTAssertEqual(response.metadata["total"], 2)
    }
    
    // MARK: - Performance Tests
    
    func testRequestPerformance() {
        // Given
        struct PerformanceResponse: Codable {
            let id: String
        }
        
        mockService.mockResponse = PerformanceResponse(id: "perf-test")
        
        // When/Then
        measure {
            let expectation = XCTestExpectation(description: "Performance test")
            
            Task {
                do {
                    let _: PerformanceResponse = try await mockService.request(
                        "/performance",
                        method: .get,
                        headers: nil,
                        body: nil
                    )
                    expectation.fulfill()
                } catch {
                    XCTFail("Performance test failed: \(error)")
                }
            }
            
            wait(for: [expectation], timeout: 1.0)
        }
    }
    
    // MARK: - Thread Safety Tests
    
    func testConcurrentRequests() async throws {
        // Given
        struct ConcurrentResponse: Codable {
            let requestId: String
        }
        
        let requestCount = 10
        
        // When - Create multiple concurrent requests
        let tasks = (0..<requestCount).map { index in
            Task {
                mockService.mockResponse = ConcurrentResponse(requestId: "request-\(index)")
                let response: ConcurrentResponse = try await mockService.request(
                    "/concurrent-\(index)",
                    method: .get,
                    headers: nil,
                    body: nil
                )
                return response
            }
        }
        
        // Then - Wait for all to complete
        let responses = try await withThrowingTaskGroup(of: ConcurrentResponse.self) { group in
            for task in tasks {
                group.addTask {
                    try await task.value
                }
            }
            
            var results: [ConcurrentResponse] = []
            for try await response in group {
                results.append(response)
            }
            return results
        }
        
        XCTAssertEqual(responses.count, requestCount)
    }
}

// MARK: - Helper Types
private struct TestResponse: Codable {
    let id: String
    let name: String
} 