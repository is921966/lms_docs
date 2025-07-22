//
//  UnreadBadgeTests.swift
//  LMSTests
//
//  Sprint 50 - День 1: Тесты для компонента счетчика непрочитанных
//

import XCTest
import SwiftUI
import ViewInspector
@testable import LMS

final class UnreadBadgeTests: XCTestCase {
    
    // MARK: - Display Text Tests
    
    func testUnreadBadgeDisplayText() throws {
        // Normal count (1-99)
        XCTAssertEqual(try UnreadBadge(count: 1).displayText, "1")
        XCTAssertEqual(try UnreadBadge(count: 50).displayText, "50")
        XCTAssertEqual(try UnreadBadge(count: 99).displayText, "99")
        
        // Large count (100-999)
        XCTAssertEqual(try UnreadBadge(count: 100).displayText, "100")
        XCTAssertEqual(try UnreadBadge(count: 518).displayText, "518")
        XCTAssertEqual(try UnreadBadge(count: 999).displayText, "999")
        
        // Very large count (1000+)
        XCTAssertEqual(try UnreadBadge(count: 1000).displayText, "1K")
        XCTAssertEqual(try UnreadBadge(count: 2500).displayText, "2K")
        XCTAssertEqual(try UnreadBadge(count: 9999).displayText, "9K")
        XCTAssertEqual(try UnreadBadge(count: 10000).displayText, "10K")
        XCTAssertEqual(try UnreadBadge(count: 99999).displayText, "99K")
    }
    
    // MARK: - Background Color Tests
    
    func testUnreadBadgeBackgroundColor() throws {
        // Blue for small counts
        let smallBadge = UnreadBadge(count: 50)
        XCTAssertEqual(smallBadge.backgroundColor, .blue)
        
        // Gray for large counts
        let largeBadge = UnreadBadge(count: 100)
        XCTAssertEqual(largeBadge.backgroundColor, Color(UIColor.systemGray3))
        
        let veryLargeBadge = UnreadBadge(count: 1000)
        XCTAssertEqual(veryLargeBadge.backgroundColor, Color(UIColor.systemGray3))
    }
    
    // MARK: - View Structure Tests
    
    func testUnreadBadgeViewStructure() throws {
        let badge = UnreadBadge(count: 42)
        let inspected = try badge.inspect()
        
        // Should have Text
        let text = try inspected.text()
        XCTAssertEqual(try text.string(), "42")
        
        // Should have proper font
        XCTAssertEqual(try text.font(), .some(.system(size: 14, weight: .medium)))
        
        // Should have white foreground color
        XCTAssertEqual(try text.foregroundColor(), .white)
    }
    
    func testUnreadBadgeFrame() throws {
        // Small count (single digit)
        let smallBadge = UnreadBadge(count: 5)
        let smallInspected = try smallBadge.inspect()
        
        // Should have minimum width
        let smallFrame = try smallInspected.frame()
        XCTAssertEqual(try smallFrame.minWidth(), 22)
        XCTAssertEqual(try smallFrame.height(), 22)
        
        // Large count (multiple digits)
        let largeBadge = UnreadBadge(count: 999)
        let largeInspected = try largeBadge.inspect()
        
        // Should have larger horizontal padding
        let largeText = try largeInspected.text()
        let largePadding = try largeText.padding(.horizontal)
        XCTAssertEqual(largePadding, 8)
    }
    
    func testUnreadBadgeBackground() throws {
        let badge = UnreadBadge(count: 10)
        let inspected = try badge.inspect()
        
        // Should have capsule background
        let background = try inspected.background()
        XCTAssertNotNil(background)
        
        // Verify it's a Capsule shape
        let capsule = try background.shape(0)
        XCTAssertTrue(capsule is Capsule)
    }
    
    // MARK: - Edge Cases
    
    func testUnreadBadgeZeroCount() {
        // Badge with 0 count should not be shown (handled by parent)
        let badge = UnreadBadge(count: 0)
        XCTAssertEqual(badge.displayText, "")
    }
    
    func testUnreadBadgeVeryLargeNumbers() {
        // Test millions
        let millionBadge = UnreadBadge(count: 1_000_000)
        XCTAssertEqual(millionBadge.displayText, "1000K")
        
        // Should still show K format
        let largeBadge = UnreadBadge(count: 123_456)
        XCTAssertEqual(largeBadge.displayText, "123K")
    }
    
    // MARK: - Accessibility Tests
    
    func testUnreadBadgeAccessibility() throws {
        let badge = UnreadBadge(count: 42)
        let inspected = try badge.inspect()
        
        // Should have accessibility label
        let text = try inspected.text()
        XCTAssertEqual(try text.accessibilityLabel(), "42 непрочитанных")
    }
} 