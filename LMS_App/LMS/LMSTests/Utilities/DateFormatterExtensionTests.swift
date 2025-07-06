//
//  DateFormatterExtensionTests.swift
//  LMSTests
//

import XCTest
@testable import LMS

class DateFormatterExtensionTests: XCTestCase {
    
    // MARK: - ISO8601 Formatter Tests
    
    func testISO8601Formatter_DateFormat() {
        let formatter = DateFormatter.iso8601
        XCTAssertEqual(formatter.dateFormat, "yyyy-MM-dd'T'HH:mm:ss'Z'")
    }
    
    func testISO8601Formatter_TimeZone() {
        let formatter = DateFormatter.iso8601
        XCTAssertEqual(formatter.timeZone, TimeZone(abbreviation: "UTC"))
    }
    
    func testISO8601Formatter_FormatsDateCorrectly() {
        let formatter = DateFormatter.iso8601
        
        // Create a specific date
        var components = DateComponents()
        components.year = 2025
        components.month = 1
        components.day = 15
        components.hour = 10
        components.minute = 30
        components.second = 45
        components.timeZone = TimeZone(abbreviation: "UTC")
        
        let calendar = Calendar(identifier: .gregorian)
        if let date = calendar.date(from: components) {
            let formattedDate = formatter.string(from: date)
            XCTAssertEqual(formattedDate, "2025-01-15T10:30:45Z")
        }
    }
    
    func testISO8601Formatter_FormatsCurrentDate() {
        let formatter = DateFormatter.iso8601
        let date = Date()
        let formattedDate = formatter.string(from: date)
        
        // Check format pattern
        let regex = try! NSRegularExpression(pattern: "^\\d{4}-\\d{2}-\\d{2}T\\d{2}:\\d{2}:\\d{2}Z$")
        let matches = regex.matches(in: formattedDate, range: NSRange(formattedDate.startIndex..., in: formattedDate))
        
        XCTAssertEqual(matches.count, 1, "Date should match ISO8601 format")
    }
    
    func testISO8601Formatter_ParsesDateCorrectly() {
        let formatter = DateFormatter.iso8601
        let dateString = "2025-07-15T14:30:00Z"
        
        if let date = formatter.date(from: dateString) {
            // Convert back to string to verify
            let reformattedString = formatter.string(from: date)
            XCTAssertEqual(reformattedString, dateString)
        } else {
            XCTFail("Failed to parse valid ISO8601 date string")
        }
    }
    
    // MARK: - Relative Formatter Tests
    
    func testRelativeFormatter_DateStyle() {
        let formatter = DateFormatter.relative
        XCTAssertEqual(formatter.dateStyle, .medium)
    }
    
    func testRelativeFormatter_TimeStyle() {
        let formatter = DateFormatter.relative
        XCTAssertEqual(formatter.timeStyle, .short)
    }
    
    func testRelativeFormatter_FormatsDateCorrectly() {
        let formatter = DateFormatter.relative
        let date = Date()
        let formattedDate = formatter.string(from: date)
        
        // Should not be empty
        XCTAssertFalse(formattedDate.isEmpty)
        
        // Should contain date and time components
        // Note: Exact format depends on locale
    }
    
    // MARK: - Static Property Tests
    
    func testISO8601Formatter_IsSingleton() {
        let formatter1 = DateFormatter.iso8601
        let formatter2 = DateFormatter.iso8601
        
        // Should be the same instance
        XCTAssertTrue(formatter1 === formatter2)
    }
    
    func testRelativeFormatter_IsSingleton() {
        let formatter1 = DateFormatter.relative
        let formatter2 = DateFormatter.relative
        
        // Should be the same instance
        XCTAssertTrue(formatter1 === formatter2)
    }
    
    // MARK: - Edge Cases Tests
    
    func testISO8601Formatter_HandlesLeapYear() {
        let formatter = DateFormatter.iso8601
        
        var components = DateComponents()
        components.year = 2024
        components.month = 2
        components.day = 29
        components.hour = 23
        components.minute = 59
        components.second = 59
        components.timeZone = TimeZone(abbreviation: "UTC")
        
        let calendar = Calendar(identifier: .gregorian)
        if let date = calendar.date(from: components) {
            let formattedDate = formatter.string(from: date)
            XCTAssertEqual(formattedDate, "2024-02-29T23:59:59Z")
        }
    }
    
    func testISO8601Formatter_HandlesNewYear() {
        let formatter = DateFormatter.iso8601
        
        var components = DateComponents()
        components.year = 2025
        components.month = 1
        components.day = 1
        components.hour = 0
        components.minute = 0
        components.second = 0
        components.timeZone = TimeZone(abbreviation: "UTC")
        
        let calendar = Calendar(identifier: .gregorian)
        if let date = calendar.date(from: components) {
            let formattedDate = formatter.string(from: date)
            XCTAssertEqual(formattedDate, "2025-01-01T00:00:00Z")
        }
    }
    
    func testISO8601Formatter_HandlesEndOfYear() {
        let formatter = DateFormatter.iso8601
        
        var components = DateComponents()
        components.year = 2024
        components.month = 12
        components.day = 31
        components.hour = 23
        components.minute = 59
        components.second = 59
        components.timeZone = TimeZone(abbreviation: "UTC")
        
        let calendar = Calendar(identifier: .gregorian)
        if let date = calendar.date(from: components) {
            let formattedDate = formatter.string(from: date)
            XCTAssertEqual(formattedDate, "2024-12-31T23:59:59Z")
        }
    }
}

// MARK: - DateFormatter Performance Tests

class DateFormatterPerformanceTests: XCTestCase {
    
    func testISO8601Formatter_Performance() {
        let formatter = DateFormatter.iso8601
        
        self.measure {
            let dates = (0..<1000).map { _ in
                Date().addingTimeInterval(Double.random(in: -365*24*60*60...365*24*60*60))
            }
            
            for date in dates {
                _ = formatter.string(from: date)
            }
        }
    }
    
    func testRelativeFormatter_Performance() {
        let formatter = DateFormatter.relative
        
        self.measure {
            let dates = (0..<1000).map { _ in
                Date().addingTimeInterval(Double.random(in: -365*24*60*60...365*24*60*60))
            }
            
            for date in dates {
                _ = formatter.string(from: date)
            }
        }
    }
    
    func testISO8601Parsing_Performance() {
        let formatter = DateFormatter.iso8601
        let dateStrings = (0..<1000).map { i in
            "2025-01-\(String(format: "%02d", (i % 28) + 1))T\(String(format: "%02d", i % 24)):30:00Z"
        }
        
        self.measure {
            for dateString in dateStrings {
                _ = formatter.date(from: dateString)
            }
        }
    }
} 