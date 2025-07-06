//
//  APIErrorTests.swift
//  LMSTests
//

import XCTest
@testable import LMS

class APIErrorTests: XCTestCase {
    
    // MARK: - Error Description Tests
    
    func testInvalidURL_ErrorDescription() {
        let error = APIError.invalidURL
        XCTAssertEqual(error.errorDescription, "Invalid URL")
    }
    
    func testInvalidResponse_ErrorDescription() {
        let error = APIError.invalidResponse
        XCTAssertEqual(error.errorDescription, "Invalid server response")
    }
    
    func testNoInternet_ErrorDescription() {
        let error = APIError.noInternet
        XCTAssertEqual(error.errorDescription, "No internet connection")
    }
    
    func testTimeout_ErrorDescription() {
        let error = APIError.timeout
        XCTAssertEqual(error.errorDescription, "Request timed out")
    }
    
    func testCancelled_ErrorDescription() {
        let error = APIError.cancelled
        XCTAssertEqual(error.errorDescription, "Request was cancelled")
    }
    
    func testUnauthorized_ErrorDescription() {
        let error = APIError.unauthorized
        XCTAssertEqual(error.errorDescription, "Authentication required")
    }
    
    func testForbidden_ErrorDescription() {
        let error = APIError.forbidden
        XCTAssertEqual(error.errorDescription, "Access denied")
    }
    
    func testNotFound_ErrorDescription() {
        let error = APIError.notFound
        XCTAssertEqual(error.errorDescription, "Resource not found")
    }
    
    func testRateLimitExceeded_ErrorDescription() {
        let error = APIError.rateLimitExceeded
        XCTAssertEqual(error.errorDescription, "Too many requests. Please try again later")
    }
    
    func testServerError_ErrorDescription() {
        let error = APIError.serverError(statusCode: 500)
        XCTAssertEqual(error.errorDescription, "Server error (500)")
        
        let error502 = APIError.serverError(statusCode: 502)
        XCTAssertEqual(error502.errorDescription, "Server error (502)")
    }
    
    func testNetworkError_ErrorDescription() {
        let urlError = URLError(.notConnectedToInternet)
        let error = APIError.networkError(urlError)
        XCTAssertEqual(error.errorDescription, urlError.localizedDescription)
    }
    
    func testDecodingError_ErrorDescription() {
        let error = APIError.decodingError(NSError(domain: "test", code: 0, userInfo: nil))
        XCTAssertEqual(error.errorDescription, "Failed to parse server response")
    }
    
    func testCustom_ErrorDescription() {
        let customMessage = "Custom error message"
        let error = APIError.custom(message: customMessage)
        XCTAssertEqual(error.errorDescription, customMessage)
    }
    
    func testUnknown_ErrorDescription() {
        let error = APIError.unknown(statusCode: 999)
        XCTAssertEqual(error.errorDescription, "Unknown error (999)")
    }
    
    // MARK: - LocalizedError Conformance Tests
    
    func testAPIError_ConformsToLocalizedError() {
        let error: LocalizedError = APIError.invalidURL
        XCTAssertNotNil(error.errorDescription)
    }
    
    // MARK: - Edge Cases Tests
    
    func testServerError_VariousStatusCodes() {
        let statusCodes = [500, 501, 502, 503, 504, 505]
        
        for code in statusCodes {
            let error = APIError.serverError(statusCode: code)
            XCTAssertEqual(error.errorDescription, "Server error (\(code))")
        }
    }
    
    func testUnknown_VariousStatusCodes() {
        let statusCodes = [400, 418, 451, 599]
        
        for code in statusCodes {
            let error = APIError.unknown(statusCode: code)
            XCTAssertEqual(error.errorDescription, "Unknown error (\(code))")
        }
    }
    
    func testNetworkError_VariousURLErrors() {
        let urlErrors: [(URLError.Code, String)] = [
            (.notConnectedToInternet, "The Internet connection appears to be offline."),
            (.timedOut, "The request timed out."),
            (.cannotFindHost, "A server with the specified hostname could not be found."),
            (.cannotConnectToHost, "Could not connect to the server."),
            (.networkConnectionLost, "The network connection was lost.")
        ]
        
        for (code, _) in urlErrors {
            let urlError = URLError(code)
            let apiError = APIError.networkError(urlError)
            
            // Just check that it returns the URLError's localized description
            XCTAssertEqual(apiError.errorDescription, urlError.localizedDescription)
        }
    }
    
    func testCustom_EmptyMessage() {
        let error = APIError.custom(message: "")
        XCTAssertEqual(error.errorDescription, "")
    }
    
    func testCustom_LongMessage() {
        let longMessage = String(repeating: "Error ", count: 100)
        let error = APIError.custom(message: longMessage)
        XCTAssertEqual(error.errorDescription, longMessage)
    }
}

// MARK: - APIError Equality Tests

class APIErrorEqualityTests: XCTestCase {
    
    func testAPIError_Equatable() {
        // Test same error types are equal
        XCTAssertEqual(APIError.invalidURL, APIError.invalidURL)
        XCTAssertEqual(APIError.unauthorized, APIError.unauthorized)
        
        // Test different error types are not equal
        XCTAssertNotEqual(APIError.invalidURL, APIError.unauthorized)
        XCTAssertNotEqual(APIError.timeout, APIError.cancelled)
    }
    
    func testAPIError_ServerErrorEquality() {
        XCTAssertEqual(APIError.serverError(statusCode: 500), APIError.serverError(statusCode: 500))
        XCTAssertNotEqual(APIError.serverError(statusCode: 500), APIError.serverError(statusCode: 502))
    }
    
    func testAPIError_UnknownErrorEquality() {
        XCTAssertEqual(APIError.unknown(statusCode: 400), APIError.unknown(statusCode: 400))
        XCTAssertNotEqual(APIError.unknown(statusCode: 400), APIError.unknown(statusCode: 401))
    }
    
    func testAPIError_CustomErrorEquality() {
        XCTAssertEqual(APIError.custom(message: "Test"), APIError.custom(message: "Test"))
        XCTAssertNotEqual(APIError.custom(message: "Test1"), APIError.custom(message: "Test2"))
    }
} 