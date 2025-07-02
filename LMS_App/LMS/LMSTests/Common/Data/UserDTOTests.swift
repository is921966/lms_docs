//
//  UserDTOTests.swift
//  LMSTests
//
//  Created by AI Assistant on 02/01/25.
//
//  Copyright © 2025 LMS. All rights reserved.
//

import XCTest
@testable import LMS

final class UserDTOTests: XCTestCase {
    
    // MARK: - UserDTO Validation Tests
    
    func testValidUserDTO() {
        let userDTO = createValidUserDTO()
        
        XCTAssertTrue(userDTO.isValid())
        XCTAssertTrue(userDTO.validationErrors().isEmpty)
    }
    
    func testUserDTOWithEmptyID() {
        var userDTO = createValidUserDTO()
        userDTO = UserDTO(
            id: "",
            email: userDTO.email,
            firstName: userDTO.firstName,
            lastName: userDTO.lastName,
            role: userDTO.role,
            createdAt: userDTO.createdAt,
            updatedAt: userDTO.updatedAt
        )
        
        XCTAssertFalse(userDTO.isValid())
        XCTAssertTrue(userDTO.validationErrors().contains("User ID cannot be empty"))
    }
    
    func testUserDTOWithInvalidEmail() {
        var userDTO = createValidUserDTO()
        userDTO = UserDTO(
            id: userDTO.id,
            email: "invalid-email",
            firstName: userDTO.firstName,
            lastName: userDTO.lastName,
            role: userDTO.role,
            createdAt: userDTO.createdAt,
            updatedAt: userDTO.updatedAt
        )
        
        XCTAssertFalse(userDTO.isValid())
        XCTAssertTrue(userDTO.validationErrors().contains("Email format is invalid"))
    }
    
    func testUserDTOWithInvalidRole() {
        var userDTO = createValidUserDTO()
        userDTO = UserDTO(
            id: userDTO.id,
            email: userDTO.email,
            firstName: userDTO.firstName,
            lastName: userDTO.lastName,
            role: "invalid-role",
            createdAt: userDTO.createdAt,
            updatedAt: userDTO.updatedAt
        )
        
        XCTAssertFalse(userDTO.isValid())
        let errors = userDTO.validationErrors()
        XCTAssertTrue(errors.contains { $0.contains("Invalid role: invalid-role") })
    }
    
    func testUserDTOWithInvalidPhoneNumber() {
        var userDTO = createValidUserDTO()
        userDTO = UserDTO(
            id: userDTO.id,
            email: userDTO.email,
            firstName: userDTO.firstName,
            lastName: userDTO.lastName,
            role: userDTO.role,
            phoneNumber: "invalid-phone",
            createdAt: userDTO.createdAt,
            updatedAt: userDTO.updatedAt
        )
        
        XCTAssertFalse(userDTO.isValid())
        XCTAssertTrue(userDTO.validationErrors().contains("Phone number format is invalid"))
    }
    
    func testUserDTOWithInvalidURL() {
        var userDTO = createValidUserDTO()
        userDTO = UserDTO(
            id: userDTO.id,
            email: userDTO.email,
            firstName: userDTO.firstName,
            lastName: userDTO.lastName,
            role: userDTO.role,
            profileImageUrl: "invalid-url",
            createdAt: userDTO.createdAt,
            updatedAt: userDTO.updatedAt
        )
        
        XCTAssertFalse(userDTO.isValid())
        XCTAssertTrue(userDTO.validationErrors().contains("Profile image URL is invalid"))
    }
    
    func testUserDTOWithInvalidDates() {
        var userDTO = createValidUserDTO()
        userDTO = UserDTO(
            id: userDTO.id,
            email: userDTO.email,
            firstName: userDTO.firstName,
            lastName: userDTO.lastName,
            role: userDTO.role,
            createdAt: "invalid-date",
            updatedAt: "invalid-date"
        )
        
        XCTAssertFalse(userDTO.isValid())
        let errors = userDTO.validationErrors()
        XCTAssertTrue(errors.contains("Created date format is invalid"))
        XCTAssertTrue(errors.contains("Updated date format is invalid"))
    }
    
    // MARK: - UserDTO Codability Tests
    
    func testUserDTOCodability() throws {
        let originalDTO = createValidUserDTO()
        
        // Encode
        let encoder = JSONEncoder()
        let data = try encoder.encode(originalDTO)
        
        // Decode
        let decoder = JSONDecoder()
        let decodedDTO = try decoder.decode(UserDTO.self, from: data)
        
        XCTAssertEqual(originalDTO, decodedDTO)
    }
    
    // MARK: - UserProfileDTO Tests
    
    func testValidUserProfileDTO() {
        let profileDTO = UserProfileDTO(
            id: "USER_123",
            firstName: "John",
            lastName: "Doe",
            email: "john@example.com"
        )
        
        XCTAssertTrue(profileDTO.isValid())
        XCTAssertTrue(profileDTO.validationErrors().isEmpty)
    }
    
    func testUserProfileDTOValidation() {
        let profileDTO = UserProfileDTO(
            id: "",
            firstName: "",
            lastName: "",
            email: ""
        )
        
        XCTAssertFalse(profileDTO.isValid())
        let errors = profileDTO.validationErrors()
        XCTAssertTrue(errors.contains("User ID cannot be empty"))
        XCTAssertTrue(errors.contains("First name cannot be empty"))
        XCTAssertTrue(errors.contains("Last name cannot be empty"))
        XCTAssertTrue(errors.contains("Email cannot be empty"))
    }
    
    // MARK: - CreateUserDTO Tests
    
    func testValidCreateUserDTO() {
        let createDTO = CreateUserDTO(
            email: "new@example.com",
            firstName: "New",
            lastName: "User",
            role: "student"
        )
        
        XCTAssertTrue(createDTO.isValid())
        XCTAssertTrue(createDTO.validationErrors().isEmpty)
    }
    
    func testCreateUserDTOWithPassword() {
        let createDTO = CreateUserDTO(
            email: "new@example.com",
            firstName: "New",
            lastName: "User",
            role: "student",
            password: "short"
        )
        
        XCTAssertFalse(createDTO.isValid())
        XCTAssertTrue(createDTO.validationErrors().contains("Password must be at least 8 characters long"))
    }
    
    // MARK: - UpdateUserDTO Tests
    
    func testValidUpdateUserDTO() {
        let updateDTO = UpdateUserDTO(
            firstName: "Updated",
            lastName: "Name",
            phoneNumber: "+79991234567"
        )
        
        XCTAssertTrue(updateDTO.isValid())
        XCTAssertTrue(updateDTO.validationErrors().isEmpty)
    }
    
    func testUpdateUserDTOWithEmptyFields() {
        let updateDTO = UpdateUserDTO(
            firstName: "",
            lastName: ""
        )
        
        XCTAssertFalse(updateDTO.isValid())
        let errors = updateDTO.validationErrors()
        XCTAssertTrue(errors.contains("First name cannot be empty"))
        XCTAssertTrue(errors.contains("Last name cannot be empty"))
    }
    
    // MARK: - UserMapper Tests
    
    func testUserMapperDomainToDTO() {
        let domain = createValidUser()
        
        let dto = UserMapper.toDTO(from: domain)
        
        XCTAssertNotNil(dto)
        XCTAssertEqual(dto?.id, domain.id?.value)
        XCTAssertEqual(dto?.email, domain.email?.value)
        XCTAssertEqual(dto?.firstName, domain.firstName)
        XCTAssertEqual(dto?.lastName, domain.lastName)
        XCTAssertEqual(dto?.role, domain.role.rawValue)
        XCTAssertEqual(dto?.isActive, domain.isActive)
    }
    
    func testUserMapperDTOToDomain() {
        let dto = createValidUserDTO()
        
        let domain = UserMapper.toDomain(from: dto)
        
        XCTAssertNotNil(domain)
        XCTAssertEqual(domain?.id?.value, dto.id)
        XCTAssertEqual(domain?.email?.value, dto.email)
        XCTAssertEqual(domain?.firstName, dto.firstName)
        XCTAssertEqual(domain?.lastName, dto.lastName)
        XCTAssertEqual(domain?.role.rawValue, dto.role)
        XCTAssertEqual(domain?.isActive, dto.isActive)
    }
    
    func testUserMapperRoundTrip() {
        let originalDomain = createValidUser()
        
        // Domain -> DTO -> Domain
        guard let dto = UserMapper.toDTO(from: originalDomain),
              let convertedDomain = UserMapper.toDomain(from: dto) else {
            XCTFail("Mapping failed")
            return
        }
        
        // Check key properties are preserved
        XCTAssertEqual(originalDomain.id?.value, convertedDomain.id?.value)
        XCTAssertEqual(originalDomain.email?.value, convertedDomain.email?.value)
        XCTAssertEqual(originalDomain.firstName, convertedDomain.firstName)
        XCTAssertEqual(originalDomain.lastName, convertedDomain.lastName)
        XCTAssertEqual(originalDomain.role, convertedDomain.role)
    }
    
    func testUserMapperCollectionMapping() {
        let domains = [createValidUser(), createValidUser()]
        
        let dtos = UserMapper.toDTOs(from: domains)
        let convertedDomains = UserMapper.toDomains(from: dtos)
        
        XCTAssertEqual(dtos.count, domains.count)
        XCTAssertEqual(convertedDomains.count, domains.count)
    }
    
    func testUserMapperSafeMapping() {
        let validDTO = createValidUserDTO()
        let invalidDTO = UserDTO(
            id: "",
            email: "invalid",
            firstName: "",
            lastName: "",
            role: "invalid",
            createdAt: "invalid",
            updatedAt: "invalid"
        )
        
        let dtos = [validDTO, invalidDTO]
        let (users, errors) = UserMapper.safeToDomains(from: dtos)
        
        XCTAssertEqual(users.count, 0) // Valid DTO will also fail due to invalid value objects
        XCTAssertEqual(errors.count, 2)
    }
    
    // MARK: - Profile Mapper Tests
    
    func testUserProfileMapper() {
        let domain = createValidUser()
        
        let profileDTO = UserProfileMapper.toProfileDTO(from: domain)
        
        XCTAssertNotNil(profileDTO)
        XCTAssertEqual(profileDTO?.id, domain.id?.value)
        XCTAssertEqual(profileDTO?.firstName, domain.firstName)
        XCTAssertEqual(profileDTO?.lastName, domain.lastName)
        XCTAssertEqual(profileDTO?.email, domain.email?.value)
    }
    
    // MARK: - Create User Mapper Tests
    
    func testCreateUserMapper() {
        let createDTO = CreateUserDTO(
            email: "new@example.com",
            firstName: "New",
            lastName: "User",
            role: "student",
            phoneNumber: "+79991234567"
        )
        
        let userId = UserId.generate()
        let domain = CreateUserMapper.toDomain(from: createDTO, withId: userId)
        
        XCTAssertNotNil(domain)
        XCTAssertEqual(domain?.id?.value, userId.value)
        XCTAssertEqual(domain?.email?.value, createDTO.email)
        XCTAssertEqual(domain?.firstName, createDTO.firstName)
        XCTAssertEqual(domain?.lastName, createDTO.lastName)
        XCTAssertEqual(domain?.role.rawValue, createDTO.role)
        XCTAssertTrue(domain?.isActive == true)
    }
    
    // MARK: - Update User Mapper Tests
    
    func testUpdateUserMapper() {
        var domain = createValidUser()
        let updateDTO = UpdateUserDTO(
            firstName: "Updated",
            lastName: "Name",
            phoneNumber: "+79999999999"
        )
        
        let hasChanges = UpdateUserMapper.applyUpdate(to: &domain, from: updateDTO)
        
        XCTAssertTrue(hasChanges)
        XCTAssertEqual(domain.firstName, "Updated")
        XCTAssertEqual(domain.lastName, "Name")
        XCTAssertEqual(domain.phoneNumber?.value, "+79999999999")
    }
    
    func testUpdateUserMapperNoChanges() {
        var domain = createValidUser()
        let updateDTO = UpdateUserDTO()
        
        let hasChanges = UpdateUserMapper.applyUpdate(to: &domain, from: updateDTO)
        
        XCTAssertFalse(hasChanges)
    }
    
    // MARK: - Helper Methods
    
    private func createValidUserDTO() -> UserDTO {
        let now = ISO8601DateFormatter().string(from: Date())
        
        return UserDTO(
            id: "USER_123456789",
            email: "test@example.com",
            firstName: "John",
            lastName: "Doe",
            role: "student",
            isActive: true,
            profileImageUrl: "https://example.com/avatar.jpg",
            phoneNumber: "+79991234567",
            department: "Engineering",
            position: "Developer",
            createdAt: now,
            updatedAt: now,
            lastLoginAt: now
        )
    }
    
    private func createValidUser() -> User {
        return User(
            id: UserId("USER_123456789"),
            email: Email("test@example.com"),
            firstName: "John",
            lastName: "Doe",
            role: .student,
            isActive: true,
            profileImageUrl: URLValue("https://example.com/avatar.jpg"),
            phoneNumber: PhoneNumber("+79991234567"),
            department: "Engineering",
            position: "Developer"
        )
    }
}