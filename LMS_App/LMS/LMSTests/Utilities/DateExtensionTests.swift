//
//  DateExtensionTests.swift
//  LMSTests
//

import XCTest
@testable import LMS

class DateExtensionTests: XCTestCase {
    
    // MARK: - isWithinNext24Hours Tests
    
    func testIsWithinNext24Hours_CurrentTime_ReturnsTrue() {
        let date = Date()
        XCTAssertTrue(date.isWithinNext24Hours)
    }
    
    func testIsWithinNext24Hours_In12Hours_ReturnsTrue() {
        let date = Date().addingTimeInterval(12 * 60 * 60) // 12 hours from now
        XCTAssertTrue(date.isWithinNext24Hours)
    }
    
    func testIsWithinNext24Hours_In23Hours_ReturnsTrue() {
        let date = Date().addingTimeInterval(23 * 60 * 60) // 23 hours from now
        XCTAssertTrue(date.isWithinNext24Hours)
    }
    
    func testIsWithinNext24Hours_In25Hours_ReturnsFalse() {
        let date = Date().addingTimeInterval(25 * 60 * 60) // 25 hours from now
        XCTAssertFalse(date.isWithinNext24Hours)
    }
    
    func testIsWithinNext24Hours_Yesterday_ReturnsFalse() {
        let date = Date().addingTimeInterval(-24 * 60 * 60) // 24 hours ago
        XCTAssertFalse(date.isWithinNext24Hours)
    }
    
    func testIsWithinNext24Hours_OneMinuteAgo_ReturnsFalse() {
        let date = Date().addingTimeInterval(-60) // 1 minute ago
        XCTAssertFalse(date.isWithinNext24Hours)
    }
    
    func testIsWithinNext24Hours_ExactlyIn24Hours_ReturnsTrue() {
        let date = Date().addingTimeInterval(24 * 60 * 60) // Exactly 24 hours from now
        // This might be true or false depending on exact timing, but based on implementation
        // it should be true since it's <= tomorrow
        XCTAssertTrue(date.isWithinNext24Hours)
    }
    
    // MARK: - daysUntilString Tests
    
    func testDaysUntilString_PastDate_ReturnsOverdue() {
        let date = Date().addingTimeInterval(-24 * 60 * 60) // Yesterday
        XCTAssertEqual(date.daysUntilString, "Просрочено")
    }
    
    func testDaysUntilString_Today_ReturnsToday() {
        let date = Date() // Now
        XCTAssertEqual(date.daysUntilString, "Сегодня")
    }
    
    func testDaysUntilString_LaterToday_ReturnsToday() {
        let date = Date().addingTimeInterval(2 * 60 * 60) // 2 hours from now
        XCTAssertEqual(date.daysUntilString, "Сегодня")
    }
    
    func testDaysUntilString_Tomorrow_ReturnsTomorrow() {
        let calendar = Calendar.current
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: Date())) ?? Date()
        XCTAssertEqual(tomorrow.daysUntilString, "Завтра")
    }
    
    func testDaysUntilString_InTwoDays_ReturnsCorrectString() {
        let calendar = Calendar.current
        let date = calendar.date(byAdding: .day, value: 2, to: calendar.startOfDay(for: Date())) ?? Date()
        XCTAssertEqual(date.daysUntilString, "Через 2 дн.")
    }
    
    func testDaysUntilString_InSevenDays_ReturnsCorrectString() {
        let calendar = Calendar.current
        let date = calendar.date(byAdding: .day, value: 7, to: calendar.startOfDay(for: Date())) ?? Date()
        XCTAssertEqual(date.daysUntilString, "Через 7 дн.")
    }
    
    func testDaysUntilString_In30Days_ReturnsCorrectString() {
        let calendar = Calendar.current
        let date = calendar.date(byAdding: .day, value: 30, to: calendar.startOfDay(for: Date())) ?? Date()
        XCTAssertEqual(date.daysUntilString, "Через 30 дн.")
    }
    
    func testDaysUntilString_OneWeekAgo_ReturnsOverdue() {
        let date = Date().addingTimeInterval(-7 * 24 * 60 * 60) // 7 days ago
        XCTAssertEqual(date.daysUntilString, "Просрочено")
    }
}

// MARK: - Date Extension Edge Cases Tests

class DateExtensionEdgeCasesTests: XCTestCase {
    
    func testIsWithinNext24Hours_ExactMidnight() {
        let calendar = Calendar.current
        let midnight = calendar.startOfDay(for: Date())
        
        // Midnight today should be within next 24 hours
        XCTAssertTrue(midnight.isWithinNext24Hours)
    }
    
    func testIsWithinNext24Hours_JustBeforeMidnightTomorrow() {
        let calendar = Calendar.current
        if let tomorrowMidnight = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: Date())),
           let justBefore = calendar.date(byAdding: .minute, value: -1, to: tomorrowMidnight) {
            // 23:59 tomorrow should be within next 24 hours
            XCTAssertTrue(justBefore.isWithinNext24Hours)
        }
    }
    
    func testDaysUntilString_JustBeforeMidnight() {
        let calendar = Calendar.current
        if let todayEnd = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: Date())),
           let justBefore = calendar.date(byAdding: .minute, value: -1, to: todayEnd) {
            // 23:59 today should still show "Сегодня"
            XCTAssertEqual(justBefore.daysUntilString, "Сегодня")
        }
    }
    
    func testDaysUntilString_JustAfterMidnight() {
        let calendar = Calendar.current
        if let tomorrowStart = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: Date())),
           let justAfter = calendar.date(byAdding: .minute, value: 1, to: tomorrowStart) {
            // 00:01 tomorrow should show "Завтра"
            XCTAssertEqual(justAfter.daysUntilString, "Завтра")
        }
    }
    
    func testDaysUntilString_ExactlyOneYearFromNow() {
        let calendar = Calendar.current
        if let oneYear = calendar.date(byAdding: .year, value: 1, to: Date()) {
            let days = calendar.dateComponents([.day], from: Date(), to: oneYear).day ?? 0
            XCTAssertEqual(oneYear.daysUntilString, "Через \(days) дн.")
        }
    }
    
    func testDaysUntilString_LeapYearConsideration() {
        // Create a date on Feb 28 of a leap year
        var components = DateComponents()
        components.year = 2024 // Leap year
        components.month = 2
        components.day = 28
        
        let calendar = Calendar.current
        if let feb28 = calendar.date(from: components),
           let feb29 = calendar.date(byAdding: .day, value: 1, to: feb28) {
            // Feb 29 should exist in leap year
            let dayComponent = calendar.component(.day, from: feb29)
            XCTAssertEqual(dayComponent, 29)
        }
    }
}

// MARK: - Date Extension Performance Tests

class DateExtensionPerformanceTests: XCTestCase {
    
    func testIsWithinNext24Hours_Performance() {
        self.measure {
            let dates = (0..<1000).map { _ in
                Date().addingTimeInterval(Double.random(in: -48*60*60...48*60*60))
            }
            
            for date in dates {
                _ = date.isWithinNext24Hours
            }
        }
    }
    
    func testDaysUntilString_Performance() {
        self.measure {
            let dates = (0..<1000).map { _ in
                Date().addingTimeInterval(Double.random(in: -365*24*60*60...365*24*60*60))
            }
            
            for date in dates {
                _ = date.daysUntilString
            }
        }
    }
} 