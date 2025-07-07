//
//  NetworkServiceTests.swift
//  LMSTests
//

import XCTest
import Combine
@testable import LMS

final class NetworkServiceTests: XCTestCase {
    
    var sut: NetworkService!
    var mockService: MockNetworkService!
    var cancellables: Set<AnyCancellable>!
    
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
        super.tearDown()
    }
    
    // MARK: - Singleton Tests
    
    func testSharedInstance() {
        let instance1 = NetworkService.shared
        let instance2 = NetworkService.shared
        XCTAssertTrue(instance1 === instance2)
    }
    
    // MARK: - HTTP Method Tests
    
    func testHTTPMethods() {
        XCTAssertEqual(HTTPMethod.get.rawValue, "GET")
        XCTAssertEqual(HTTPMethod.post.rawValue, "POST")
        XCTAssertEqual(HTTPMethod.put.rawValue, "PUT")
        XCTAssertEqual(HTTPMethod.delete.rawValue, "DELETE")
        XCTAssertEqual(HTTPMethod.patch.rawValue, "PATCH")
    }
    
    // MARK: - Mock Service Tests
    
    func testMockServiceSuccess() async throws {
        // Given
        struct TestResponse: Codable {
            let id: String
            let name: String
        }
        
        let expectedResponse = TestResponse(id: "123", name: "Test")
        mockService.mockResponse = expectedResponse
        
        // When
        let response: TestResponse = try await mockService.request(
            "/test",
            method: .get,
            headers: nil,
            body: nil
        )
        
        // Then
        XCTAssertEqual(response.id, expectedResponse.id)
        XCTAssertEqual(response.name, expectedResponse.name)
    }
    
    func testMockServiceError() async {
        // Given
        mockService.shouldThrowError = true
        mockService.error = NetworkError.noData
        
        // When/Then
        do {
            let _: TestResponse = try await mockService.request(
                "/test",
                method: .get,
                headers: nil,
                body: nil
            )
            XCTFail("Should throw error")
        } catch {
            XCTAssertTrue(error is NetworkError)
        }
    }
    
    func testMockServiceCombineSuccess() {
        // Given
        struct TestResponse: Codable {
            let success: Bool
        }
        
        let expectedResponse = TestResponse(success: true)
        mockService.mockResponse = expectedResponse
        
        let expectation = XCTestExpectation(description: "Request completes")
        
        // When
        mockService.request(
            "/test",
            method: .post,
            headers: ["Content-Type": "application/json"],
            body: nil
        )
        .sink(
            receiveCompletion: { completion in
                if case .failure = completion {
                    XCTFail("Should not fail")
                }
            },
            receiveValue: { (response: TestResponse) in
                // Then
                XCTAssertTrue(response.success)
                expectation.fulfill()
            }
        )
        .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testMockServiceCombineError() {
        // Given
        mockService.shouldThrowError = true
        mockService.error = NetworkError.invalidURL
        
        let expectation = XCTestExpectation(description: "Request fails")
        
        // When
        mockService.request(
            "/test",
            method: .get,
            headers: nil,
            body: nil
        )
        .sink(
            receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    // Then
                    XCTAssertTrue(error is NetworkError)
                    expectation.fulfill()
                }
            },
            receiveValue: { (_: TestResponse) in
                XCTFail("Should not receive value")
            }
        )
        .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    // MARK: - Network Error Tests
    
    func testNetworkErrorTypes() {
        XCTAssertNotNil(NetworkError.invalidURL)
        XCTAssertNotNil(NetworkError.noData)
        XCTAssertNotNil(NetworkError.decodingError)
        XCTAssertNotNil(NetworkError.serverError(404))
        XCTAssertNotNil(NetworkError.unknown)
    }
    
    func testNetworkErrorServerCodes() {
        let badRequest = NetworkError.serverError(400)
        if case .serverError(let code) = badRequest {
            XCTAssertEqual(code, 400)
        } else {
            XCTFail("Should be server error")
        }
        
        let notFound = NetworkError.serverError(404)
        if case .serverError(let code) = notFound {
            XCTAssertEqual(code, 404)
        } else {
            XCTFail("Should be server error")
        }
        
        let serverError = NetworkError.serverError(500)
        if case .serverError(let code) = serverError {
            XCTAssertEqual(code, 500)
        } else {
            XCTFail("Should be server error")
        }
    }
}

// MARK: - Test Response Struct

private struct TestResponse: Codable {
    let id: String
    let name: String
    let email: String
} 