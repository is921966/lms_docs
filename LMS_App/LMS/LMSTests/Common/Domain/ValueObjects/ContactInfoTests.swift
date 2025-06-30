//
//  ContactInfoTests.swift
//  LMSTests
//
//  Created by AI Assistant on 01/31/25.
//
//  Copyright © 2025 LMS. All rights reserved.
//

import XCTest
@testable import LMS

final class ContactInfoTests: XCTestCase {
    
    // MARK: - Email Tests
    
    func testEmailValidation() {
        // Valid emails
        XCTAssertNotNil(Email("user@example.com"))
        XCTAssertNotNil(Email("test.user@company.co.uk"))
        XCTAssertNotNil(Email("john+tag@domain.com"))
        XCTAssertNotNil(Email("123@numbers.com"))
        
        // Invalid emails
        XCTAssertNil(Email(""))
        XCTAssertNil(Email("invalid"))
        XCTAssertNil(Email("@domain.com"))
        XCTAssertNil(Email("user@"))
        XCTAssertNil(Email("user@.com"))
        XCTAssertNil(Email("user@domain"))
        XCTAssertNil(Email("user @domain.com"))
        XCTAssertNil(Email("user@domain..com"))
    }
    
    func testEmailNormalization() {
        // Lowercase normalization
        let email1 = Email("User@EXAMPLE.COM")
        XCTAssertEqual(email1?.value, "user@example.com")
        
        // Whitespace trimming
        let email2 = Email("  test@example.com  ")
        XCTAssertEqual(email2?.value, "test@example.com")
    }
    
    func testEmailDomainExtraction() {
        let email = Email("user@example.com")!
        XCTAssertEqual(email.domain, "example.com")
        XCTAssertEqual(email.localPart, "user")
        
        let complexEmail = Email("test.user+tag@sub.domain.co.uk")!
        XCTAssertEqual(complexEmail.domain, "sub.domain.co.uk")
        XCTAssertEqual(complexEmail.localPart, "test.user+tag")
    }
    
    func testEmailDomainCheck() {
        let email = Email("user@company.com")!
        XCTAssertTrue(email.isFromDomain("company.com"))
        XCTAssertTrue(email.isFromDomain("COMPANY.COM"))
        XCTAssertFalse(email.isFromDomain("other.com"))
    }
    
    func testEmailEquality() {
        let email1 = Email("test@example.com")!
        let email2 = Email("test@example.com")!
        let email3 = Email("other@example.com")!
        
        XCTAssertEqual(email1, email2)
        XCTAssertNotEqual(email1, email3)
    }
    
    // MARK: - PhoneNumber Tests
    
    func testPhoneNumberValidation() {
        // Valid phone numbers
        XCTAssertNotNil(PhoneNumber("+79991234567"))
        XCTAssertNotNil(PhoneNumber("79991234567"))
        XCTAssertNotNil(PhoneNumber("+1234567890"))
        XCTAssertNotNil(PhoneNumber("1234567890"))
        
        // Invalid phone numbers
        XCTAssertNil(PhoneNumber(""))
        XCTAssertNil(PhoneNumber("123"))
        XCTAssertNil(PhoneNumber("1234567890123456")) // Too long
        XCTAssertNil(PhoneNumber("abc"))
    }
    
    func testPhoneNumberNormalization() {
        // Various formats should normalize to same value
        let formats = [
            "+7 (999) 123-45-67",
            "+7-999-123-45-67",
            "+7 999 123 45 67",
            "+79991234567",
            "+7.999.123.45.67"
        ]
        
        let normalizedValue = "+79991234567"
        for format in formats {
            let phone = PhoneNumber(format)
            XCTAssertNotNil(phone)
            XCTAssertEqual(phone?.value, normalizedValue)
        }
    }
    
    func testPhoneNumberFormatting() {
        // Russian number
        let russianPhone = PhoneNumber("+79991234567")!
        XCTAssertEqual(russianPhone.formatted, "+7 (999) 123-45-67")
        
        // US number
        let usPhone = PhoneNumber("+15551234567")!
        XCTAssertEqual(usPhone.formatted, "+1 (555) 123-4567")
        
        // Other number (no special formatting)
        let otherPhone = PhoneNumber("+44123456789")!
        XCTAssertEqual(otherPhone.formatted, "+44123456789")
    }
    
    func testPhoneNumberMobileCheck() {
        let mobileRussian = PhoneNumber("+79991234567")!
        XCTAssertTrue(mobileRussian.isMobile)
        
        let landlineRussian = PhoneNumber("+74951234567")!
        XCTAssertFalse(landlineRussian.isMobile)
    }
    
    func testPhoneNumberEquality() {
        // Different formats of same number should be equal
        let phone1 = PhoneNumber("+7 (999) 123-45-67")!
        let phone2 = PhoneNumber("+79991234567")!
        let phone3 = PhoneNumber("+79991234568")!
        
        XCTAssertEqual(phone1, phone2)
        XCTAssertNotEqual(phone1, phone3)
    }
    
    // MARK: - URLValue Tests
    
    func testURLValueValidation() {
        // Valid URLs
        XCTAssertNotNil(URLValue("https://example.com"))
        XCTAssertNotNil(URLValue("http://test.com/path"))
        XCTAssertNotNil(URLValue("https://sub.domain.com:8080/path?query=1"))
        
        // Invalid URLs
        XCTAssertNil(URLValue(""))
        XCTAssertNil(URLValue("not a url"))
        XCTAssertNil(URLValue("ftp://example.com")) // Only http(s) allowed
        XCTAssertNil(URLValue("//example.com")) // No scheme
        XCTAssertNil(URLValue("https://")) // No host
    }
    
    func testURLValueSecurityCheck() {
        let secureURL = URLValue("https://example.com")!
        XCTAssertTrue(secureURL.isSecure)
        
        let insecureURL = URLValue("http://example.com")!
        XCTAssertFalse(insecureURL.isSecure)
    }
    
    func testURLValueEquality() {
        let url1 = URLValue("https://example.com/path")!
        let url2 = URLValue("https://example.com/path")!
        let url3 = URLValue("https://example.com/other")!
        
        XCTAssertEqual(url1, url2)
        XCTAssertNotEqual(url1, url3)
    }
} 