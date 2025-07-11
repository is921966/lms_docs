//
//  EmailValidatorTests.swift
//  LMSTests
//
//  Created by AI Assistant on 03/07/2025.
//  Sprint 28: Parameterized Tests Implementation
//

import XCTest
@testable import LMS

class EmailValidatorTests: XCTestCase {
    
    // MARK: - Parameterized Email Validation Tests
    
    func testEmailValidation() {
        // Test data structure
        struct EmailTestCase {
            let email: String
            let isValid: Bool
            let description: String
        }
        
        // Comprehensive test cases
        let testCases: [EmailTestCase] = [
            // MARK: Valid Emails
            EmailTestCase(email: "user@example.com", isValid: true, description: "Standard email"),
            EmailTestCase(email: "test.user@example.com", isValid: true, description: "Email with dot in local part"),
            EmailTestCase(email: "user+tag@example.com", isValid: true, description: "Email with plus sign"),
            EmailTestCase(email: "user@subdomain.example.com", isValid: true, description: "Email with subdomain"),
            EmailTestCase(email: "user123@example.com", isValid: true, description: "Email with numbers"),
            EmailTestCase(email: "user_name@example.com", isValid: true, description: "Email with underscore"),
            EmailTestCase(email: "user-name@example.com", isValid: true, description: "Email with hyphen"),
            EmailTestCase(email: "a@example.com", isValid: true, description: "Single character local part"),
            EmailTestCase(email: "user@example.co.uk", isValid: true, description: "Email with country TLD"),
            EmailTestCase(email: "user@123.456.789.012", isValid: true, description: "Email with IP address"),
            EmailTestCase(email: "user@example-domain.com", isValid: true, description: "Domain with hyphen"),
            EmailTestCase(email: "user@mail.example.com", isValid: true, description: "Email with mail subdomain"),
            
            // MARK: Invalid Emails
            EmailTestCase(email: "", isValid: false, description: "Empty string"),
            EmailTestCase(email: "user", isValid: false, description: "Missing @ and domain"),
            EmailTestCase(email: "@example.com", isValid: false, description: "Missing local part"),
            EmailTestCase(email: "user@", isValid: false, description: "Missing domain"),
            EmailTestCase(email: "user @example.com", isValid: false, description: "Space in local part"),
            EmailTestCase(email: "user@example", isValid: false, description: "Missing TLD"),
            EmailTestCase(email: "user@@example.com", isValid: false, description: "Double @ symbol"),
            EmailTestCase(email: "user@.com", isValid: false, description: "Missing domain name"),
            EmailTestCase(email: "user@example..com", isValid: false, description: "Double dot in domain"),
            EmailTestCase(email: ".user@example.com", isValid: false, description: "Leading dot in local part"),
            EmailTestCase(email: "user.@example.com", isValid: false, description: "Trailing dot in local part"),
            EmailTestCase(email: "user@-example.com", isValid: false, description: "Leading hyphen in domain"),
            EmailTestCase(email: "user@example.com-", isValid: false, description: "Trailing hyphen in domain"),
            EmailTestCase(email: "user name@example.com", isValid: false, description: "Space in email"),
            EmailTestCase(email: "user@exam ple.com", isValid: false, description: "Space in domain"),
            
            // MARK: Edge Cases
            EmailTestCase(email: "user@localhost", isValid: false, description: "Localhost domain"),
            EmailTestCase(email: "user@.example.com", isValid: false, description: "Leading dot in domain"),
            EmailTestCase(email: "user@example.com.", isValid: false, description: "Trailing dot in domain"),
            EmailTestCase(email: "user..name@example.com", isValid: false, description: "Double dot in local part"),
            EmailTestCase(email: "user@[192.168.1.1]", isValid: true, description: "IP address in brackets"),
            EmailTestCase(email: "\"user name\"@example.com", isValid: false, description: "Quoted local part"),
            EmailTestCase(email: "user\\@name@example.com", isValid: false, description: "Escaped @ in local part"),
            
            // MARK: Length Edge Cases
            EmailTestCase(email: "a@b.c", isValid: true, description: "Minimal valid email"),
            EmailTestCase(email: String(repeating: "a", count: 64) + "@example.com", isValid: true, description: "Max length local part"),
            EmailTestCase(email: String(repeating: "a", count: 65) + "@example.com", isValid: false, description: "Exceeds max local part length"),
            EmailTestCase(email: "user@" + String(repeating: "a", count: 63) + ".com", isValid: true, description: "Max length domain label"),
            EmailTestCase(email: "user@" + String(repeating: "a", count: 64) + ".com", isValid: false, description: "Exceeds max domain label length"),
        ]
        
        // Run all test cases
        for testCase in testCases {
            let result = TestEmailValidator.isValid(testCase.email)
            XCTAssertEqual(
                result,
                testCase.isValid,
                "Failed for '\(testCase.email)': \(testCase.description). Expected \(testCase.isValid), got \(result)"
            )
        }
        
        // Log test summary
        print("✅ Tested \(testCases.count) email validation cases")
        print("   - Valid emails: \(testCases.filter { $0.isValid }.count)")
        print("   - Invalid emails: \(testCases.filter { !$0.isValid }.count)")
    }
    
    // MARK: - Performance Test
    
    func testEmailValidationPerformance() {
        let emails = [
            "user@example.com",
            "test.user+tag@subdomain.example.co.uk",
            "invalid@@email..com",
            "another.test@domain.org"
        ]
        
        measure {
            for _ in 0..<1000 {
                for email in emails {
                    _ = TestEmailValidator.isValid(email)
                }
            }
        }
    }
}

// MARK: - Email Validator Implementation
// TODO: Move to production code
// Removed duplicate TestEmailValidator - using the one from TestEmailValidator.swift 