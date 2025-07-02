//
//  DTOProtocolTests.swift
//  LMSTests
//
//  Created by AI Assistant on 02/01/25.
//
//  Copyright © 2025 LMS. All rights reserved.
//

import XCTest
@testable import LMS

final class DTOProtocolTests: XCTestCase {
    
    // MARK: - APIResponse Tests
    
    func testValidAPIResponse() {
        let userDTO = createTestUserDTO()
        let response = APIResponse(
            data: userDTO,
            success: true,
            message: "User retrieved successfully"
        )
        
        XCTAssertTrue(response.isValid())
        XCTAssertTrue(response.validationErrors().isEmpty)
        XCTAssertEqual(response.data, userDTO)
        XCTAssertTrue(response.success)
    }
    
    func testAPIResponseErrorWithoutCode() {
        let response = APIResponse<UserDTO>(
            data: nil,
            success: false,
            message: "Something went wrong"
        )
        
        XCTAssertFalse(response.isValid())
        XCTAssertTrue(response.validationErrors().contains("Error response must have error code"))
    }
    
    func testAPIResponseWithInvalidData() {
        let invalidUserDTO = UserDTO(
            id: "", // Invalid - empty ID
            email: "invalid-email", // Invalid format
            firstName: "",
            lastName: "",
            role: "invalid-role",
            createdAt: "invalid-date",
            updatedAt: "invalid-date"
        )
        
        let response = APIResponse(
            data: invalidUserDTO,
            success: true
        )
        
        XCTAssertFalse(response.isValid())
        let errors = response.validationErrors()
        XCTAssertTrue(errors.first?.contains("Response data is invalid") == true)
    }
    
    func testAPIResponseCodability() throws {
        let userDTO = createTestUserDTO()
        let response = APIResponse(
            data: userDTO,
            success: true,
            message: "Success",
            requestId: "req-123"
        )
        
        // Encode
        let encoder = JSONEncoder()
        let data = try encoder.encode(response)
        
        // Decode
        let decoder = JSONDecoder()
        let decodedResponse = try decoder.decode(APIResponse<UserDTO>.self, from: data)
        
        XCTAssertEqual(response.data, decodedResponse.data)
        XCTAssertEqual(response.success, decodedResponse.success)
        XCTAssertEqual(response.message, decodedResponse.message)
        XCTAssertEqual(response.requestId, decodedResponse.requestId)
    }
    
    // MARK: - CollectionResponse Tests
    
    func testValidCollectionResponse() {
        let users = [createTestUserDTO(), createTestUserDTO()]
        let response = CollectionResponse(
            items: users,
            totalCount: 10,
            page: 1,
            pageSize: 5
        )
        
        XCTAssertTrue(response.isValid())
        XCTAssertTrue(response.validationErrors().isEmpty)
        XCTAssertEqual(response.items.count, 2)
        XCTAssertTrue(response.hasNextPage)
        XCTAssertFalse(response.hasPreviousPage)
    }
    
    func testCollectionResponseInvalidPage() {
        let response = CollectionResponse(
            items: [UserDTO](),
            totalCount: 10,
            page: 0, // Invalid - must be > 0
            pageSize: 5
        )
        
        XCTAssertFalse(response.isValid())
        XCTAssertTrue(response.validationErrors().contains("Page must be greater than 0"))
    }
    
    func testCollectionResponseInvalidPageSize() {
        let response = CollectionResponse(
            items: [UserDTO](),
            totalCount: 10,
            page: 1,
            pageSize: 0 // Invalid - must be > 0
        )
        
        XCTAssertFalse(response.isValid())
        XCTAssertTrue(response.validationErrors().contains("Page size must be greater than 0"))
    }
    
    func testCollectionResponseNegativeTotalCount() {
        let response = CollectionResponse(
            items: [UserDTO](),
            totalCount: -1, // Invalid - cannot be negative
            page: 1,
            pageSize: 5
        )
        
        XCTAssertFalse(response.isValid())
        XCTAssertTrue(response.validationErrors().contains("Total count cannot be negative"))
    }
    
    func testCollectionResponseTooManyItems() {
        let users = Array(repeating: createTestUserDTO(), count: 10)
        let response = CollectionResponse(
            items: users,
            totalCount: 100,
            page: 1,
            pageSize: 5 // Only 5 items allowed, but we have 10
        )
        
        XCTAssertFalse(response.isValid())
        XCTAssertTrue(response.validationErrors().contains("Items count cannot exceed page size"))
    }
    
    func testCollectionResponseWithInvalidItems() {
        let validUser = createTestUserDTO()
        let invalidUser = UserDTO(
            id: "",
            email: "invalid",
            firstName: "",
            lastName: "",
            role: "invalid",
            createdAt: "invalid",
            updatedAt: "invalid"
        )
        
        let response = CollectionResponse(
            items: [validUser, invalidUser],
            totalCount: 2,
            page: 1,
            pageSize: 5
        )
        
        XCTAssertFalse(response.isValid())
        let errors = response.validationErrors()
        XCTAssertTrue(errors.contains { $0.contains("Item at index 1 is invalid") })
    }
    
    func testCollectionResponsePagination() {
        // First page
        let firstPage = CollectionResponse(
            items: [UserDTO](),
            totalCount: 25,
            page: 1,
            pageSize: 10
        )
        XCTAssertFalse(firstPage.hasPreviousPage)
        XCTAssertTrue(firstPage.hasNextPage)
        
        // Middle page
        let middlePage = CollectionResponse(
            items: [UserDTO](),
            totalCount: 25,
            page: 2,
            pageSize: 10
        )
        XCTAssertTrue(middlePage.hasPreviousPage)
        XCTAssertTrue(middlePage.hasNextPage)
        
        // Last page
        let lastPage = CollectionResponse(
            items: [UserDTO](),
            totalCount: 25,
            page: 3,
            pageSize: 10
        )
        XCTAssertTrue(lastPage.hasPreviousPage)
        XCTAssertFalse(lastPage.hasNextPage)
    }
    
    // MARK: - DTOErrorResponse Tests
    
    func testValidErrorResponse() {
        let errorResponse = DTOErrorResponse(
            code: "USER_NOT_FOUND",
            message: "The requested user was not found",
            details: ["User ID: 123", "Database: primary"]
        )
        
        XCTAssertTrue(errorResponse.isValid())
        XCTAssertTrue(errorResponse.validationErrors().isEmpty)
    }
    
    func testErrorResponseEmptyCode() {
        let errorResponse = DTOErrorResponse(
            code: "",
            message: "Some error occurred"
        )
        
        XCTAssertFalse(errorResponse.isValid())
        XCTAssertTrue(errorResponse.validationErrors().contains("Error code cannot be empty"))
    }
    
    func testErrorResponseEmptyMessage() {
        let errorResponse = DTOErrorResponse(
            code: "ERROR_CODE",
            message: ""
        )
        
        XCTAssertFalse(errorResponse.isValid())
        XCTAssertTrue(errorResponse.validationErrors().contains("Error message cannot be empty"))
    }
    
    // MARK: - MappingUtilities Tests
    
    func testMappingUtilitiesToDTO() {
        let domains = ["test1", "test2", "test3"]
        
        let dtos = MappingUtilities.mapToDTO(domains) { domain -> TestDTO? in
            return TestDTO(value: domain)
        }
        
        XCTAssertEqual(dtos.count, 3)
        XCTAssertEqual(dtos[0].value, "test1")
        XCTAssertEqual(dtos[1].value, "test2")
        XCTAssertEqual(dtos[2].value, "test3")
    }
    
    func testMappingUtilitiesToDTOWithFailures() {
        let domains = ["valid", "", "also_valid"]
        
        let dtos = MappingUtilities.mapToDTO(domains) { domain -> TestDTO? in
            return domain.isEmpty ? nil : TestDTO(value: domain)
        }
        
        XCTAssertEqual(dtos.count, 2) // Empty string should be filtered out
        XCTAssertEqual(dtos[0].value, "valid")
        XCTAssertEqual(dtos[1].value, "also_valid")
    }
    
    func testMappingUtilitiesToDomain() {
        let dtos = [
            TestDTO(value: "test1"),
            TestDTO(value: "test2"),
            TestDTO(value: "test3")
        ]
        
        let domains = MappingUtilities.mapToDomain(dtos) { dto -> String? in
            return dto.value
        }
        
        XCTAssertEqual(domains.count, 3)
        XCTAssertEqual(domains[0], "test1")
        XCTAssertEqual(domains[1], "test2")
        XCTAssertEqual(domains[2], "test3")
    }
    
    func testMappingUtilitiesSafeMap() {
        let inputs = ["1", "invalid", "3", "4"]
        
        let (results, errors) = MappingUtilities.safeMap(inputs) { input -> Int in
            guard let number = Int(input) else {
                throw MappingError.invalidFormat("Not a number: \(input)")
            }
            return number
        }
        
        XCTAssertEqual(results.count, 3)
        XCTAssertEqual(results, [1, 3, 4])
        XCTAssertEqual(errors.count, 1)
    }
    
    // MARK: - MappingError Tests
    
    func testMappingErrorDescriptions() {
        let invalidDataError = MappingError.invalidData("Test data")
        XCTAssertEqual(invalidDataError.localizedDescription, "Invalid data: Test data")
        
        let missingFieldError = MappingError.missingRequiredField("email")
        XCTAssertEqual(missingFieldError.localizedDescription, "Missing required field: email")
        
        let invalidFormatError = MappingError.invalidFormat("date")
        XCTAssertEqual(invalidFormatError.localizedDescription, "Invalid format for field: date")
        
        let validationError = MappingError.validationFailed(["Error 1", "Error 2"])
        XCTAssertEqual(validationError.localizedDescription, "Validation failed: Error 1, Error 2")
    }
    
    // MARK: - Helper Methods and Types
    
    private func createTestUserDTO() -> UserDTO {
        let now = ISO8601DateFormatter().string(from: Date())
        
        return UserDTO(
            id: "USER_123",
            email: "test@example.com",
            firstName: "Test",
            lastName: "User",
            role: "student",
            createdAt: now,
            updatedAt: now
        )
    }
    
    // Simple test DTO for utility testing
    private struct TestDTO: DataTransferObject {
        let value: String
        
        func validationErrors() -> [String] {
            return value.isEmpty ? ["Value cannot be empty"] : []
        }
    }
} 